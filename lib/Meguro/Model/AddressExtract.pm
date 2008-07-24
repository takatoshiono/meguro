package Meguro::Model::AddressExtract;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( 
    class       => 'Meguro::Logic::AddressExtract',
    constructor => 'new',
);

1;
