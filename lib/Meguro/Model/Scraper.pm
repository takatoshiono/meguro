package Meguro::Model::Scraper;
use strict;
use warnings;
use base 'Catalyst::Model::Factory';

__PACKAGE__->config( 
    class       => 'Meguro::Logic::Scraper',
    constructor => 'new',
);

1;
