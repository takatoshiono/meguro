package Meguro::Model::DBIC;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Meguro::Schema',
    connect_info => [
        'dbi:mysql:meguro',
        'root',
        
    ],
);

=head1 NAME

Meguro::Model::DBIC - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<Meguro>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Meguro::Schema>

=head1 AUTHOR

ono takatoshi

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
