my $psa = shift;

$psa->response->set_template(
    [
     Template => "dumpenv",
     { envr => \%ENV,
       zero => $0,
     },
    ]);
