use strict;
use warnings;

#
# Test default model includes the RoleModel role
#

BEGIN {
    use Test::More;
    eval "use Moose";
    plan skip_all => "Moose required for testing using default model" if $@;
}

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::MyModels::News;
use Test::MyModels::Weather;

plan tests => 6;

{
    my $app = q|
    package TestApp2;
    use Dancer2;
    use FindBin;
    use lib "$FindBin::Bin/lib";

    BEGIN {
        setting views => path( 't', 'views' );
        setting template => 'tiny';
           
        set plugins => {
            DomainModel => {
                namespace  => 'Test::MyModels',
                only_with => ['Test::ExtraRole'],
                with_model => 0,
                make_immutable => 0,
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;
    template 'index', { news => model('News') };|;

    eval $app;

    my $ret = $@;

    ok( !$ret, 'App should not fail to load' );
    ok(
        !Test::MyModels::News->meta->does_role(
            'Dancer2::Plugin::DomainModel::RoleModel'),
        'News model has no RoleModel by request'
    );
}

{
    my $app = q|
    package TestApp3;
    use Dancer2;
    use FindBin;
    use lib "$FindBin::Bin/lib";

    BEGIN {
        setting views => path( 't', 'views' );
        setting template => 'tiny';
           
        set plugins => {
            DomainModel => {
                namespace  => 'Test::MyModels',
                only_with => ['Test::ExtraRole'],
                with_model => 1,
                make_immutable => 0,
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;
    template 'index', { news => model('News') };|;

    eval $app;

    my $ret = $@;
    ok( !$ret, 'App should not fail to load' );
    ok(
        Test::MyModels::News->meta->does_role(
            'Dancer2::Plugin::DomainModel::RoleModel'),
        'News model has RoleModel by request'
    );

}

{
    my $app = q|
    package TestApp;
    use Dancer2;
    use FindBin;
    use lib "$FindBin::Bin/lib";

    BEGIN {
        setting views => path( 't', 'views' );
        setting template => 'tiny';
           
        set plugins => {
            DomainModel => {
                namespace  => 'Test::MyModels',
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;
    template 'index', { news => model('Weather') };|;

    eval $app;

    my $ret = $@;
    ok( !$ret, 'App should not fail to load' );
    ok(
        Test::MyModels::Weather->meta->does_role(
            'Dancer2::Plugin::DomainModel::RoleModel'),
        'Weather model has RoleModel by default'
    );
}

