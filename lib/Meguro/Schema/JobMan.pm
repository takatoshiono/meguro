package Meguro::Schema::JobMan;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("ResultSetManager", "Core");
__PACKAGE__->table("job_man");
__PACKAGE__->add_columns(
  "uniqueid",
  { data_type => "CHAR", default_value => "", is_nullable => 0, size => 32 },
  "jobid",
  { data_type => "BIGINT", default_value => "", is_nullable => 0, size => 20 },
  "updated_at",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
);
__PACKAGE__->set_primary_key("jobid");
__PACKAGE__->add_unique_constraint("uniqueid", ["uniqueid"]);


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-04-03 00:56:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ShTqi7Rez+m1m3EC6JIQUA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
