package Dancer2::Plugin::DomainModel::Model;
use strict;
use warnings;

use Carp;
use Module::Pluggable::Object;
use Module::Runtime 'require_module';
use Moose;
use namespace::autoclean;

# model instances
has _models => (
    is      => 'ro',
    isa     => 'HashRef[Object]',
    traits  => ['Hash'],
    handles => {
        _add_model => 'set',
        _has_model => 'exists',
        _model     => 'get',
    },
);

has namespace => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub BUILD
{
    my ( $self, $args ) = @_;

    my $schema;
    my $schema_class;
    my $config = {
        does_roles     => [],
        add_roles      => [],
        model_args     => {},
        make_immutable => 1,
    };

    if ( exists $args->{DBIC} ) {

        $schema_class = $args->{DBIC}{schema_class};
        require_module($schema_class);

        $config->{model_args}{schema} =
          $schema_class->connect( $args->{DBIC}{dsn} );
        push(
            @{ $config->{add_roles} },
            'Dancer2::Plugin::DomainModel::RoleDBIC'
        );
    }

    if ( not( exists $args->{with_logger} && $args->{with_logger} == 0 ) ) {
        $config->{model_args}{logger} = $args->{app}->logger_engine;
        push(
            @{ $config->{add_roles} },
            'Dancer2::Plugin::DomainModel::RoleLogger'
        );
    }

    if ( exists $args->{make_immutable} ) {
        $config->{make_immutable} = $args->{make_immutable};
    }

    if ( exists $args->{add_roles} ) {
        push( @{ $config->{add_roles} }, @{ $args->{add_roles} } );
    }

    if ( exists $args->{does_roles} ) {
        croak "'does_roles' must be an array!"
          unless ref $args->{does_roles} eq 'ARRAY';
        $config->{does_roles} = $args->{does_roles};
    }

    if ( exists $args->{only_with} ) {
        croak "'only_with' must be an array!"
          unless ref $args->{only_with} eq 'ARRAY';
        $config->{only_with} = $args->{only_with};
    }

    $self->_build_models($config);
}

sub _build_models
{
    my ( $self, $config ) = @_;
    my $base = $self->namespace;
    my $finder = Module::Pluggable::Object->new( search_path => [$base] );

    unless ( $finder && $finder->plugins ) {
        croak "No models found under " . $self->namespace;
    }

    foreach my $class ( $finder->plugins ) {

        #get package name minus path
        ( my $name = $class ) =~ s/^\Q${base}::\E//;
        require_module($class);

        if ( exists $config->{only_with} ) {
            next unless $class->meta->does_role( @{ $config->{only_with} } );
        }

        if ( @{ $config->{add_roles} } ) {
            Moose::Util::apply_all_roles( $class, @{ $config->{add_roles} } );
        }

        foreach my $role ( @{ $config->{does_roles} } ) {
            $class->meta->does_role($role)
              || croak "Model '$class' does not consume role '$role'";
        }

        $class->meta->make_immutable if $config->{make_immutable};
        $self->_add_model( $name => $class->new( %{ $config->{model_args} } ) );

    }
}

sub get
{
    my ( $self, $model ) = @_;
    if ( not $self->_has_model($model) ) {
        croak "Model '$model' not found!";
    }
    return $self->_model($model);
}
__PACKAGE__->meta->make_immutable;
