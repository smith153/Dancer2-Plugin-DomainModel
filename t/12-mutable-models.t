use strict;
use warnings;

#
# Test model immutable
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

plan tests => 7;

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
                only_with => ['Test::ExtraRole'],
                with_logger => 0,
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
        Test::MyModels::News->meta->is_mutable,
        'Actual News model class is mutable'
    );
    ok(
        Test::MyModels::Weather->meta->is_mutable,
        'Actual Weather model class is mutable'
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
                only_with => ['Test::ExtraRole'],
                with_logger => 0,
                make_immutable => 1,
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;
    template 'index', { news => model('News') };|;

    eval $app;

    my $ret = $@;
    ok( !$ret, 'App should not fail to load' );
    ok(
        Test::MyModels::News->meta->is_immutable,
        'Actual News model class is immutable'
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
                with_logger => 0,
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;
    template 'index', { news => model('Weather') };|;

    eval $app;

    my $ret = $@;
    ok( !$ret, 'App should not fail to load' );
    ok(
        Test::MyModels::Weather->meta->is_immutable,
        'Actual model class is immutable'
    );

}
