package Models::News;
use strict;
use warnings;

use Carp;
use Moo;
use Types::Standard
  qw( ArrayRef Bool Dict InstanceOf Int Optional Str HashRef Object);
use namespace::autoclean;

has schema => (
    is  => 'rwp',
    isa => Object,
);

has logger => (
    is  => 'rwp',
    isa => Object,
);

sub latest
{
    my ($self) = @_;
    return [ $self->schema->resultset('News')->all() ];
}

sub no_db_latest
{
    my ($self) = @_;
    return [ { entry => 'one' }, { entry => 'two' } ];
}

sub hi_from_logger
{
    my ($self) = @_;
    $self->logger->log( 'info', 'Hi from logger' );
}

1;
