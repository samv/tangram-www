#  ______________________
#  ___  __ \_  ___/__    |  Copyright (c) Sam Vilain, 2001, 2003. All
#  __  /_/ /____ \__  /| |  rights reserved.  This program is free
#  _  ____/____/ /_  ___ |  software; you may use/modify/distribute it
#  /_/     /____/ /_/  |_|  under the same terms as Perl itself.
#
#  This is the main entry point in the web server.  It receives
#  requests for everything except flat files.
#
#  This function gets passed one variable - the PSA object, which
#  contains the Request, a Response object which you put your output
#  in.
#
#  save flat stuff in %{$psa->heap}.  Don't save references to objects
#  in storage, save their object IDs ($psa->storage->id($object))
#  instead.  This will become automatic in later versions.

my $psa = shift;

$psa->response->set_data("Hello, world!");

return;

my ($result, $eperm);

# Get request filename - this comes from the PATH_INFO via
# PSA::Request::CGI
my $filename = $psa->request->filename();

print STDERR "filename is $filename\n";

use CGI::Cookie;

# eval block to catch errors, etc
eval {
    if ( $filename ) {
	while ( $filename and
      		! $psa->cache->stat_file($filename) ) {
      		$filename =~ s{/?[^/]*$}{};
	}
	# check the entry point they asked for exists
	if ( $filename and $psa->cache->executable($filename) ) {
	    $psa->run($filename);
	    $psa->response->set_cookie
		(
		 new CGI::Cookie
		 ( -name => "SID",
		   -value => $psa->sid,
		   -domain => $psa->request->server_name,
		   -path => $psa->request->script_name, )
		) if ($psa->heap_obj->fresh or
		      !$psa->heap->{sent_cookie}++);
	}
	else {
	    $eperm = 1;
	}
    } else {
	# redirect them to main.pl
	$psa->response->make_redirect
	    ($psa->request->uri(absolute => post => "main.pl"));
    }
};

if ( $@ ) {
    # caught an exception - ugh
    $psa->response->set_header(-status => "500 Internal Error");
    $psa->response->set_template([Template => "internal_error",
				  {
				   exception => $@
				  }]);

} elsif ( $eperm ) {
    # file not found or no execute permission
    $psa->response->set_header(-status => "404 Not Found");
    $psa->response->set_template([Template => "404",
				 {
				  page => $psa->request->filename()
				 }]);

} elsif ( $psa->response->is_null ) {
    # no response - erp
    $psa->response->set_header(-status => "500 Internal Error");
    $psa->response->set_template([Template => "empty_response",
				 {
				  page => $psa->request->filename()
				 }]);

} else {
    # This request worked.  Cool.
}
