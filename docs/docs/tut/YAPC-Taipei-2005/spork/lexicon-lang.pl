package Lexicon::Lang;

use base qw(Class::Tangram);
use Carp;

our $schema = {
    fields => {
        string => {
            lang => {
                # /* supports CPD */
                sql => "varchar(16)",
                required => 1,
            }}}};

sub set_lang {
    my $self = shift;
    my $lang = shift;
    is_language_tag($lang) or croak
       ("'$lang' is not in RFC3066");
    $self->SUPER::set_lang($lang);
};

42;
