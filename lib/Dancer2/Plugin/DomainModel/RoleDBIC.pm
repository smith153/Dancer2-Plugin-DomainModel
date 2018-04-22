package Dancer2::Plugin::DomainModel::RoleDBIC;
use strict;
use warnings;

use Carp;
use Moose::Role;

has schema => (
    is       => 'ro',
    isa      => 'Object',
    required => 1,
    handles  => {
        resultset => 'resultset',
        rset      => 'resultset'
    },
);

1;
