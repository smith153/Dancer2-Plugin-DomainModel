package Dancer2::Plugin::DomainModel::RoleModel;
use strict;
use warnings;

use Carp;
use Moose::Role;

has _model => (
    is       => 'ro',
    isa      => 'Object',
    required => 1,
    handles  => { model => 'get' },
);

1;
