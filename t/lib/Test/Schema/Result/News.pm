package Test::Schema::Result::News;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("news");

__PACKAGE__->add_columns(
    "id",
    {
        data_type   => "integer",
        is_nullable => 0,
    },
    "entry",
    {
        data_type   => "text",
        is_nullable => 1,
    },
);

1;
