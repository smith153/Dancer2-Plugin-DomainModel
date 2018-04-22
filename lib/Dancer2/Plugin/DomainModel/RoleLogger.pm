package Dancer2::Plugin::DomainModel::RoleLogger;
use strict;
use warnings;

use Carp;
use Moose::Role;

has logger => (
    is       => 'ro',
    isa      => 'Object',
    required => 1,
    handles  => [qw/log/]
);

sub info
{
    my ( $self, $txt ) = @_;
    return $self->log( 'info', $txt );
}

sub warn
{
    my ( $self, $txt ) = @_;
    return $self->log( 'warn', $txt );
}

sub debug
{
    my ( $self, $txt ) = @_;
    return $self->log( 'debug', $txt );
}

1;
