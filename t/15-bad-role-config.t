use strict;
use warnings;

#
# Test non array passed to role configuration
#

BEGIN {
    use Test::More;
    eval "use Moose";
    plan skip_all => "Moose required for testing using default model" if $@;
}

use FindBin;
use lib "$FindBin::Bin/lib";

plan tests => 8;

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
                only_with => 'Test::ExtraRole',
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;
    template 'index', { news => model('News') };|;

    eval $app;

    my $ret = $@;
    ok( $ret, 'App should fail to load' );
    like( $ret, qr/'only_with' must be an array/, "Error: '...must be array'" );
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
                only_with => '',
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;
    template 'index', { news => model('News') };|;

    eval $app;

    my $ret = $@;
    ok( $ret, 'App should fail to load' );
    like( $ret, qr/'only_with' must be an array/, "Error: '...must be array'" );
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
                does_roles => 'Test::Role',
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;
    template 'index', { news => model('News') };|;

    eval $app;

    my $ret = $@;
    ok( $ret, 'App should fail to load' );
    like( $ret, qr/'does_roles' must be an array/,
        "Error: '...must be array'" );
}

{
    my $app = q|
    package TestApp4;
    use Dancer2;
    use FindBin;
    use lib "$FindBin::Bin/lib";

    BEGIN {
        setting views => path( 't', 'views' );
        setting template => 'tiny';
           
        set plugins => {
            DomainModel => {
                namespace  => 'Test::MyModels',
                does_roles => '',
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;
    template 'index', { news => model('News') };|;

    eval $app;

    my $ret = $@;
    ok( $ret, 'App should fail to load' );
    like( $ret, qr/'does_roles' must be an array/,
        "Error: '...must be array'" );
}

