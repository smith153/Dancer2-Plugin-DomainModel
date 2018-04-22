package Dancer2::Plugin::DomainModel;

use strict;
use warnings;

use Carp;

use Dancer2::Core::Types qw/Str Object HashRef ArrayRef/;
use Module::Runtime 'use_module';
use Dancer2::Plugin 0.200000;

# ABSTRACT: Combat the anemic domain model
our $VERSION = '0.02';
$VERSION = eval $VERSION;

has _base_class => (
    is  => 'rwp',
    isa => Str,
);

has _model => (
    is  => 'lazy',
    isa => Object,
);

has _args => (
    is  => 'rwp',
    isa => HashRef,
);

has _allowed_conf => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub {
        [
            'base_class', 'args',      'namespace', 'DBIC',
            'does_roles', 'add_roles', 'only_with', 'make_immutable',
            'with_logger'
        ];
    }
);

plugin_keywords qw/model/;

sub BUILD
{
    my $plugin = shift;
    my $args   = {};
    my $base_class;

    $plugin->_is_valid_config();

    #use user supplied base class
    if ( exists $plugin->config->{base_class} ) {
        $base_class = $plugin->config->{base_class};
        $args       = {
            app => $plugin->app,
            %{ $plugin->config->{args} || {} }
        };
    } else {    #or use a default base class
        $base_class = "Dancer2::Plugin::DomainModel::Model";
        $args = { app => $plugin->app, };

        foreach my $a ( grep( !/base_class|arg/, @{ $plugin->_allowed_conf } ) )
        {
            $args->{$a} = $plugin->config->{$a} if exists $plugin->config->{$a};
        }
    }

    $plugin->_set__args($args);
    $plugin->_set__base_class($base_class);

}

sub _build__model
{
    my ($plugin) = @_;
    return use_module( $plugin->_base_class )->new( %{ $plugin->_args } );

}

sub _is_valid_config
{
    my ($plugin) = @_;
    my $conf = $plugin->config;

    unless ( exists $conf->{base_class} || exists $conf->{namespace} ) {
        croak "Missing configuration 'base_class' or 'namespace'!";
    }

    my %is_allowed_setting =
      map { $_ => 1 } @{ $plugin->_allowed_conf };

    if ( my @extra = grep { !$is_allowed_setting{$_} } keys %$conf ) {
        croak "invalid configuration key(s): --(@extra)-- ";
    }

    if ( exists $conf->{base_class} && exists $conf->{namespace} ) {

        croak "Invalid configuration - keys 'base_class' "
          . "and 'namespace' are mutually exclusive!";
    }

    if ( exists $conf->{DBIC} ) {
        croak "DBIC is missing 'schema_class'"
          unless exists $conf->{DBIC}{schema_class};
        croak "DBIC is missing 'dsn'"
          unless exists $conf->{DBIC}{dsn};
    }

}

sub model
{
    my ( $plugin, $model ) = @_;

    return $plugin->_model->get($model);
}

1;

__END__

=head1 NAME

Dancer2::Plugin::DomainModel - Combat the anemic domain model

=head1 SYNOPSIS

  # in config.yml

  plugins:
    DomainModel:
      namespace: MyApp::MyModels    # the parent namespace of your model classes

  # in your app

  use Dancer2;
  use Dancer2::Plugin::DomainModel;

  get '/' => sub {
    template 'index', { news => model('News')->latest };
  };

=head1 DESCRIPTION

In the original definition of I<MVC>, the I<model> manages the behavior and 
data of the application domain. However, in most modern I<MVC> frameworks, 
a I<model> is typically treated as a I<thing> coupled with some form of 
ORM and thus each I<model> represents a single table in a database. In most 
cases, this will lead to including your application and business logic inside 
of your controllers, causing 'fat controllers' and an 
L<anemic domain model|https://en.wikipedia.org/wiki/Anemic_domain_model>.

Having yet another layer between your I<DAO> (data access object) and 
application framework allows you to decouple your business logic into easily 
testable modules that will no longer be restricted to the limitations of your 
I<DAO> or framework implementations. Effectively, your model goes from B<ISA> 
I<DAO> to B<HASA> I<DAO>

=head1 USAGE (via base_class)

    DomainModel:
      base_class: ModelBase # your base class or factory
      args:                 # optional args passed to base_class constructor
        dsn: dbname
        user: uname


=head2 model

  model('<model_name>')->method_name

The C<model> keyword is provided for interfacing with your models.

On initialization, L<Dancer2::Plugin::DomainModel> creates an instance of 
C<base_class> via C<< base_class->new(app => $self) >> where C<app> will 
be the L<Dancer2> instance itself that was passed to the plugin. This will 
allow easy access to interfacing with the current L<Dancer2> instance (such as 
calling the built in logging methods or other accessible API functions. See 
L<Modifying-the-app-at-building-time|https://metacpan.org/pod/Dancer2::Plugin#Modifying-the-app-at-building-time>). 
Calling C<< model('model_name') >> will proxy to 
C<< base_class->get('model_name') >>. Thus your C<base_class> is responsible 
for dispatching the correct model object. A simple example is provided in the 
test files F<t/lib/Models.pm>.


=head1 USAGE (via namespace)

    DomainModel:
      namespace: MyApp::MyModels        # the parent namespace of your model classes
      DBIC:                             # use the optional DBIC plugin
        dsn: dbi:SQLite:dbname=test.db  # required
        schema_class: MyApp::Schema     # required
      does_roles:                       # ensures each model consumes these roles
        - MyApp::BigRole
        - MyApp::BiggerRole

Configuration via the C<base_class> parameter is nice if you want full control 
over initialization of your own models. However, a default model driver 
(AKA model 'factory') is provided and can be enabled by specifying the 
C<namespace> configuration parameter.

=head2 model

    model('<model_name>')->method_name

The C<model> keyword functions the same whether 
L<Dancer2::Plugin::DomainModel> is configured using C<base_class> or 
C<namespace>.


=head2 Namespace configuration parameters

=head3 namespace

Obviously, L<Dancer2::Plugin::DomainModel> needs to know where to look for 
your model classes. C<namespace> should be a parent namespace/directory under 
which your model classes are located.

=head3 DBIC

If set, this will apply the L<Dancer2::Plugin::DomainModel::RoleDBIC> role 
to all your models. As such, the needed C<dsn> and C<schema_class> need to be 
specified.

This will add the following callable L<DBIx::Class> methods to your models:

=over 4

=item * schema

The L<DBIx::Class::Schema> schema object.

=item * resultset

The L<DBIx::Class::ResultSet> resultset object

=item * rset

Same as C<resultset>

=back


=head3 does_roles

On larger projects, you might want to ensure that every model that is loaded 
consumes a certain role or implements a certain interface. C<does_roles> takes 
a list of these roles that you may provide.

=head3 only_with

    only_with:
      - Awesome::Role
      - Awesomer::Role

On even larger projects, you might have classes under your C<namespace> 
directory that are not even models (yuck!). In that case, you may choose to 
only load classes that consume a certain role which would denote it as a model 
class and not something else.

=head3 with_logger

    with_logger: 1

By default, for every model class under C<namespace>, 
L<Dancer2::Plugin::DomainModel> will apply the 
L<Dancer2::Plugin::DomainModel::RoleLogger> role to every model that is loaded. 
This will give you the following methods callable from your model object:

=over 4

=item * logger

The raw Dancer2 logger engine object

=item * info

Print a log message of level 'info'

=item * warn

Print a log message of level 'warn'

=item * debug

Print a log message of level 'debug'

=back

If you do not want this role applied, set C<with_logger> to a false value.

=head3 make_immutable

    make_immutable: 1

By default, for every model class under C<namespace>, 
L<Dancer2::Plugin::DomainModel> will call 
C<< ClassName->meta->make_immutable >> before initialization. If you don't 
want this, set C<make_immutable> to false.

=head1 CAVEATS

A few gotchas

=head2 Configuration conflicts

C<namespace> and C<base_class> are mutually exclusive and will fail on app load.

=head2 Moose

L<Moose> is required in order to load the default model driver provided via 
the C<namespace> parameter. Your model classes should use L<Moose> (Or at 
least allow applying roles via C<< ClassName->meta >> semantics).

=head2 Immutable Models

Depending on your use case, most models (if they make use of L<Moose> at least) 
will need to not be set as immutable as model classes might have roles applied 
to them on initialization. Nonetheless, C<< meta->immutable >> is called on 
each loaded class (unless C<make_immutable> is set to 0).

=head1 Examples

See the files under the F<t> directory.

=over 4

=item * F<t/lib/Models.pm>

An example custom model 'driver' class for use with C<base_class>

=item * F<t/lib/Models/News.pm>

An example model for use with a custom model driver.

=item * F<t/lib/Test/MyModels/Weather.pm>

An example of what a model might look like when used with the built in model 
driver class (enabled via the C<namespace> configuration).

=back

=head1 See also

L<Domain Driven Design|https://en.wikipedia.org/wiki/Domain-driven_design>

=head1 AUTHORS

Samuel Smith E<lt>esaym@cpan.orgE<gt>

=head1 BUGS

See L<http://rt.cpan.org> to report and view bugs.

=head1 SOURCE

The source code repository for Dancer2::Plugin::DomainModel can be found at 
L<https://github.com/smith153/Dancer2-Plugin-DomainModel>.

=head1 COPYRIGHT

Copyright 2018 by Samuel Smith E<lt>esaym@cpan.orgE<gt>.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

 
