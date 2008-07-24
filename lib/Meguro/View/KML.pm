package Meguro::View::KML;

use strict;
use base 'Catalyst::View::TT::ForceUTF8';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    INCLUDE_PATH => [
        Meguro->path_to('root', 'templates'),
    ],
);

=head1 NAME

Meguro::View::KML - TT View for Meguro

=head1 DESCRIPTION

TT View for Meguro. 

=head1 AUTHOR

=head1 SEE ALSO

L<Meguro>

ono takatoshi

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
