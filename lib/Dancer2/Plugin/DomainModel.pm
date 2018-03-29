package Dancer2::Plugin::DomainModel;

use strict;
use warnings;

use Carp;

use Dancer2::Core::Types qw/Str Object HashRef ArrayRef/;
use Dancer2::Plugin 0.200000;
use Module::Runtime 'use_module';

# ABSTRACT: Combat the anemic domain model
our $VERSION = '0.01';
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
    default => sub { [qw/base_class args model_dir/] }
);

plugin_keywords qw/model/;

sub BUILD
{
    my $plugin = shift;
    my %directives;

    $plugin->_is_valid_config();
    $plugin->_set__args(
        {
            app => $plugin->app,
            %{ $plugin->config->{args} || {} }
        }
    );
    $plugin->_set__base_class( $plugin->config->{base_class} );

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

    unless ( exists $conf->{base_class} ) {
        croak __PACKAGE__ . ": Missing configuration 'base_class'!";
    }

    my %is_allowed_setting =
      map { $_ => 1 } @{ $plugin->_allowed_conf };

    if ( my @extra = grep { !$is_allowed_setting{$_} } keys %$conf ) {
        croak __PACKAGE__ . ": invalid configuration key(s): --(@extra)-- ";
    }

    if ( exists $conf->{base_class} && exists $conf->{model_dir} ) {

        croak __PACKAGE__
          . ": Invalid configuration - keys base_class and "
          . "model_dir are mutually exclusive!";
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
      base_class: ModelBase # your base class or factory
      args:                 # optional args passed to base_class constructor
        dsn: dbname
        user: uname

  # in your app

  use Dancer2::Plugin::DomainModel;
  get '/' => sub {
    template 'index', { news => model('News')->latest };
  };

=head1 DESCRIPTION

In the original definition of I<MVC>, the I<model> manages the behavior and 
data of the application domain. However, in most modern I<MVC> frameworks, 
a I<model> typically is just thought of a I<thing> coupled with some form of 
ORM and thus each I<model> represents a single table in a database. Typically 
this will lead to including your application and business logic inside of your 
controllers, causing 'fat controllers' and an 
L<anemic domain model|https://en.wikipedia.org/wiki/Anemic_domain_model>.

Having yet another layer between your I<DAO> (data access object) and 
application framework allows you to decouple your business logic into easily 
testable modules that will no longer be restricted to the limitations of your 
I<DAO> or framework implementations. Effectively, your model goes from B<ISA> 
I<DAO> to B<HASA> I<DAO>

=head1 USAGE

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

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

 
