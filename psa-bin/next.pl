
my $psa = shift;

$psa->response->set_template
    ([ Template => "main.tt",
       {
	message => ("This is the next page!  This page is going to be "
		    ."changed in a few seconds, using `Server Push'."),
       },
     ]);
$psa->response->set_nonfinal(1);

$psa->run("issue.pl");

sleep 10;

$psa->response->set_template
    ([ Template => "main.tt",
       {
	message => ("This is the last page!"),
       },
     ]);
