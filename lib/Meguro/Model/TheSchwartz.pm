package Meguro::Model::TheSchwartz;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( 
    class       => 'TheSchwartz',
    constructor => 'new',
    args        => {
        databases => [
            {dsn => 'dbi:mysql:theschwartz', user => 'root', pass => ''}
        ],
    },
);

sub mangle_arguments {
    my ($self, $args) = @_;
    return %$args;
}

1;
