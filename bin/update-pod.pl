#!/usr/bin/env perl

use Scriptalicious
    -progname => 'update-pod';

=head1 NAME

update-pod.pl - update POD on intranet

=head1 SYNOPSIS

update-pod.pl [options]

=head1 DESCRIPTION

Builds all of the Perl module documentation on the intranet from POD
found in the module source and application library directories.

=head1 COMMAND LINE OPTIONS

=over

=item B<-h, --help>

Display a program usage screen and exit.

=item B<-V, --version>

Display program version and exit.

=item B<-v, --verbose>

Verbose command execution, displaying things like the
commands run, their output, etc.

=item B<-q, --quiet>

Suppress all normal program output; only display errors and
warnings.

=item B<-d, --debug>

Display output to help someone debug this script, not the
process going on.

=back

=cut

use strict;
use warnings;
our $VERSION = '1.00';

use constant DESTDIR => "/home/samv/proj/tangram/website/docs/pod/";
use constant MODULES => "/home/samv/src";
#use constant APPS    => "/mv/app/prod";

use constant ROOT    => "/docs";
use constant CSS     => "/styles/pod.css";
use File::Find;
use Pod::Html;

#---------------------------------------------------------------------
#  scan_podules(PATH) : LIST
# Scans a given path for .pod and .pm files, not returning .pm files
# where a corresponding .pod exists
#---------------------------------------------------------------------
sub scan_podules {
    my @pod_files;
    find( sub {
	      if ( /^blib$/ ) {
		  $File::Find::prune = 1;
	      }
	      elsif ( /^.*\.pod\z/s ) {
		  push @pod_files, $File::Find::name;
	      }
	      elsif ( /^.*\.pm\z/s ) {
		  (my $pod_file = $_) =~ s{pm$}{pod};
		  if ( -f $pod_file ) {
		      whisper "skipping $_ - .pod file exists";
		  } else {
		      push @pod_files, $File::Find::name
		  }
	      }
	  }, @_);
    @pod_files;
}

#=====================================================================
#  MAIN SECTION STARTS HERE
#=====================================================================
getopt();

chdir(MODULES) or abort "failed to change to ${\(MODULES)}; $!";

my $dir = shift;
my @dirs;
if ($dir)  {
   @dirs = $dir."/lib";
} else {
   @dirs = <*/lib>;
}
say "scanning Perl modules in ${\(MODULES)}: @dirs";

my @pod_files = scan_podules(@dirs);

say "extracting POD from ".@pod_files." file(s)";
for my $pod_file ( @pod_files ) {
    say "processing $pod_file";

    (my $dest_file = $pod_file) =~ s{\.(pod|pm)$}{.html};
    $dest_file =~ s{.*/lib/}{};

    if ( $dest_file =~ m{/} ) {
	(my $dirname = $dest_file) =~ s{/[^/]*$}{};
	$dirname = DESTDIR."/".$dirname;

	( -d $dirname ) or run "mkdir", "-p", $dirname;
    }

    pod2html( "--htmlroot=".ROOT,
	      "--css=".CSS,
	      "--libpods=perlfunc:perlguts:perlvar:perlrun:perlop",
	      "--infile=".$pod_file,
	      "--outfile=".DESTDIR."/$dest_file",
	    );
}

