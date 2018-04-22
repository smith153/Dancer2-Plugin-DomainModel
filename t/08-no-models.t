use strict;
use warnings;

#
# Test how our custom model dies with no models
#

BEGIN {
    use Test::More;
    eval "use Moose";
    plan skip_all => "Moose required for testing using default model" if $@;
}

plan tests => 2;

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
                namespace  => 'Test::NoModel',
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;

    template 'index', { news => model('Weather')->latest };

|;

eval $app;

my $ret = $@;
ok( $ret, 'App should should fail if no models found' );
like( $ret, qr/No models found under/, "Error says 'No models found under..'" );
