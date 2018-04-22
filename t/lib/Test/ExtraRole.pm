package Test::ExtraRole;
use strict;
use warnings;

use Carp;
use Moose::Role;

has extra => (
    is      => 'ro',
    isa     => 'Str',
    default => 'hi',
);

1;
