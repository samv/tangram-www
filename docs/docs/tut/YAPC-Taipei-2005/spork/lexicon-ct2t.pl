sub _schema {

    my $schema = { classes => [ ] };

    for my $class ( @classes ) {
	no strict 'refs';
	my $class_schema =
        ${"${class}::schema"}
	    or die "no ${class}::schema!";

	push @{$schema->{classes}},
        $class => $class_schema;
    }

    $db_schema = Tangram::Schema->new
        ($schema);

}
