
# This page is the entry point to the site - it should set up the
# response for the home page.

my $psa = shift;

$psa->response->set_template
    ([
      Template => "main.tt",
      {
       message => "Hello, world!",
      },
    ]);
