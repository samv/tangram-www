#!/usr/bin/env perl -w
#

use Scriptalicious
    -name => "psa_handler";

BEGIN { say "scriptalicious!";

	start_timer();
	my ($is_loading, %seen);
	$is_loading = "";
	unshift @INC, sub {
	    shift;
	    my $module = shift;
	    say("last: $is_loading (".show_delta().")")
		unless $seen{$module}++;
	    $is_loading = $module;
	    return undef;
	};
};

use strict;
use warnings;

# the PSA non-framework ;)
use PSA qw(Acceptor::AutoCGI
	   Cache
	   Config
	   Request::CGI Response::HTTP
	   Session);

BEGIN { say "PSA! - total: ".show_elapsed };

use Maptastic;

our $VERSION = '1.00';

use lib "lib";

#---------------------------------------------------------------------
#  init code
#---------------------------------------------------------------------
use vars qw($storage $schema $page_cache $template_obj $acceptor
	    $config);

BEGIN {
    $config = PSA::Config->new;
    $config->getopt(\@ARGV);
    $config->engage;
}

# your application schema
use utsl;

if ( my $env = $config->{env} ) {
    while ( my ($key, $value) = each %$env ) {
	if (exists($ENV{$key})) {
	    moan "overriding config: $key=$ENV{$key}";
	} else {
	    $ENV{$key} = $value;
	}
    }
}

if ( my $globals = $config->{globals} ) {
    no strict 'refs';
    map_each { ${$_[0]} = $_[1] } $globals;
}

$acceptor ||= PSA::Acceptor::AutoCGI->new(%{ $config->{acceptor}||{} });

BEGIN { say "acceptor init" };

# Load the application Schema
$schema ||= utsl->schema;

BEGIN { say "schema" };

# Connect to the application database
$storage ||= utsl->storage($config);
#$acceptor->add_pre_fork(sub { $storage->disconnect() });
#$acceptor->add_post_fork(sub { $storage = utsl->storage });

# Set up the page cache, similar to Apache::Registry
$page_cache   ||= PSA::Cache->new( base_dir => "psa-bin",
				   stat_age => 10         );

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#  main application loop
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
while (my $request = $acceptor->get_request()) {

    $page_cache->flush_stat();

    # optional - so any prints go somewhere (hopefully) visible
    select(STDERR);

    # build the PSA object; this object is valid for a single request
    my $psa = PSA->new(
		       config => $config,
		       response => PSA::Response::HTTP->new(),
		       request => $request,
		       cache => $page_cache,
		       #storage => $storage,
		       #schema => $schema,
		       acceptor => $acceptor,
		      );

    $psa->{times} = [];
    start_timer();

    reload();

    push @{ $psa->{times} }, "reload: ".show_delta;

    # Wicked, now whassap.pl - result comes back in $psa->response
    $psa->run("whassap.pl");
    push @{ $psa->{times} }, "page: ".show_delta;

    $psa->run("issue.pl");
    push @{ $psa->{times} }, "issue: ".show_delta;

    last if $acceptor->stale();

    say("times[$$]: ".join(", ", @{$psa->{times}}, "total: ".show_elapsed())
	." - ".$psa->request->filename)
	unless $psa->request->filename =~ m{\.(js|css)$};

    #$storage->recycle("clear_refs");

    $Tangram::TRACE = undef unless $ENV{TANGRAM_TRACE};
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

my $Debug = 1;
my %Stat;
sub reload {
    my $c=0;
    while (my($key,$file) = each %INC) {
	next unless $file =~ m{Fozzie};
	local $^W = 0;
	my $mtime = (stat $file)[9];
	$Stat{$file} = $^T
	    unless defined $Stat{$file};
	if ($mtime > $Stat{$file}) {
	    delete $INC{$key};
	    eval { 
		local $SIG{__WARN__} = \&warn;
		require $key;
	    };
	    if ($@) {
		warn "Module::Reload: error during reload of '$key': $@\n"
	    }
	    elsif ($Debug) {
		warn "Module::Reload: process $$ reloaded '$key'\n"
		    if $Debug == 1;
		warn("Module::Reload: process $$ reloaded '$key' (\@INC=".
		     join(', ',@INC).")\n")
		    if $Debug >= 2;
	    }
	    ++$c;
	}
	$Stat{$file} = $mtime;
    }
    $c;
}
