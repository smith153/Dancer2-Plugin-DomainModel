package Models;
use strict;
use warnings;

use Carp;
use Module::Pluggable::Object;
use Module::Runtime 'use_module';
use Types::Standard
  qw( ArrayRef Bool Dict InstanceOf Int Optional Str HashRef Object);
use Moo;
use namespace::autoclean;

my $base = __PACKAGE__;

# model instances
has _models => (
    is  => 'lazy',
    isa => HashRef [Object],
);

# you probably want some kind of DB access
has schema => (
    is  => 'rwp',
    isa => Object,
);

# and sending log messages back to Dancer would be nice too
has logger => (
    is  => 'rwp',
    isa => Object,
);

sub BUILD
{
    my ( $self, $args ) = @_;
    my $schema;
    my $schema_class = $args->{schema_class};

    $self->_set_logger( $args->{app}->logger_engine );

    eval {
        if ($schema_class) {
            use_module($schema_class);
            $schema = $schema_class->connect( $args->{dsn} );
            $self->_set_schema($schema);
        }
    };

    croak "$base:" . $@ if $@;
}

# loads all model files under the current __PACKAGE__ namespace
# and passes any custom arguments to them (which can be from config.yml)
# One should probably also check that each model inherits from a proper
# base object or does a certain role
sub _build__models
{
    my ($self) = @_;
    my $finder = Module::Pluggable::Object->new( search_path => [$base] );
    my $models = {};
    my %args   = ( logger => $self->logger );

    if ( $self->schema ) {
        $args{schema} = $self->schema;
    }

    foreach my $class ( $finder->plugins ) {

        #get package name minus path
        ( my $name = $class ) =~ s/^\Q${base}::\E//;

        $models->{$name} = use_module($class)->new(%args);

    }
    return $models;
}

sub get
{
    my ( $self, $model ) = @_;
    if ( not exists $self->_models->{$model} ) {
        croak "Model '$model' not found!";
    }
    return $self->_models->{$model};
}

1;
