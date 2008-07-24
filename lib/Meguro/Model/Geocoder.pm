package Meguro::Model::Geocoder;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( 
    class       => 'Meguro::Logic::Geocoder',
    constructor => 'new',
);

1;
