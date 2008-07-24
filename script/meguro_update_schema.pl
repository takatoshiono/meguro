#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use File::Spec;
use lib File::Spec->catfile( $FindBin::Bin, qw/.. lib/ );

use DBIx::Class::Schema::Loader qw/make_schema_at/;

die unless @ARGV;

make_schema_at(
    'Meguro::Schema',
    {   components     => ['ResultSetManager'],
        dump_directory => File::Spec->catfile( $FindBin::Bin, '..', 'lib' ),
        debug => 1,
        really_erase_my_files => 1,
    },
    \@ARGV,
);

