package Meguro::Model::ExtractTreeText;
use strict;
use warnings;
use base 'Catalyst::Model::Factory';

__PACKAGE__->config( 
    class       => 'HTML::Extract::TreeText',
    constructor => 'new',
);

1;
