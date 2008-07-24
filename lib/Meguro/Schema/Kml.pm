package Meguro::Schema::Kml;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("ResultSetManager", "Core");
__PACKAGE__->table("kml");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => "", is_nullable => 0, size => 11 },
  "title",
  { data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 64 },
  "kml",
  { data_type => "TEXT", default_value => "", is_nullable => 0, size => 65535 },
  "created_at",
  { data_type => "DATETIME", default_value => "", is_nullable => 0, size => 19 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-04-03 00:56:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XhvH/L+fx/wDz7p1FhvqJw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
