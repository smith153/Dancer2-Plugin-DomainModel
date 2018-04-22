use strict;
use warnings;

#
# Test adding roles actually does something
#

BEGIN {
    use Test::More;
    eval "use Moose";
    plan skip_all => "Moose required for testing using default model" if $@;
}

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::MyModels::Weather;

plan tests => 5;

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
                does_roles => ['Test::ExtraRole'],
                make_immutable => 0,
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;

    template 'index', { news => model('Weather')->no_db_latest };|;

    eval $app;

    my $ret = $@;
    ok( $ret, 'App should should fail without role' );
    ok( !Test::MyModels::Weather->meta->does_role('Test::ExtraRole'),
        'Actual class should not do ExtraRole' );
    like(
        $ret,
        qr/does not consume role 'Test::ExtraRole'/i,
        "Error says 'does not consume role 'Test::ExtraRole'..'"
    );
}

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
                add_roles => ['Test::ExtraRole'],
                does_roles => ['Test::ExtraRole'],
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;

    template 'index', { news => model('Weather')->no_db_latest };|;

    eval $app;

    my $ret = $@;
    ok( !$ret, 'App should should not fail with added role' );
    ok( Test::MyModels::Weather->meta->does_role('Test::ExtraRole'),
        'Actual class should do ExtraRole now' );
}
