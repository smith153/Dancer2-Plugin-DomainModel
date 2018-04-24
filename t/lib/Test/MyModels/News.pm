package Test::MyModels::News;
use strict;
use warnings;

use Carp;
use Moose;
use namespace::autoclean;
with 'Test::ExtraRole';

sub latest
{
    my ($self) = @_;
    return [ $self->schema->resultset('News')->all() ];
}

sub hi_from_info
{
    my ($self) = @_;
    $self->info('Hi from info logger');
}

sub hi_from_debug
{
    my ($self) = @_;
    $self->debug('Hi from debug logger');
}

sub hi_from_warn
{
    my ($self) = @_;
    $self->warn('Hi from warn logger');
}

sub no_db_latest
{
    my ($self) = @_;
    $self->model('Weather')->no_db_latest;
}

1;
