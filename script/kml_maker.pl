#!/usr/bin/perl
use strict;
use warnings;

use FindBin::libs;
use TheSchwartz;
use TheSchwartz::Worker::KMLMaker;

my $client = TheSchwartz->new(
    databases => [
        { dsn => 'dbi:mysql:theschwartz', user => 'root', pass => ''},
    ],
);
$client->can_do('TheSchwartz::Worker::KMLMaker');
$client->work();

__END__

