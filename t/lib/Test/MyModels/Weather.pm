package Test::MyModels::Weather;
use strict;
use warnings;

use Carp;
use Moose;
use namespace::autoclean;

sub latest
{
    my ($self) = @_;
    return [ $self->schema->resultset('Weather')->all() ];
}

sub rset_latest
{
    my ($self) = @_;
    return [ $self->rset('Weather')->all() ];
}

sub no_db_latest
{
    my ($self) = @_;
    return [ { entry => 'one' }, { entry => 'two' } ];
}

sub hi_from_logger
{
    my ($self) = @_;
    $self->info('Hi from logger');
}

1;
