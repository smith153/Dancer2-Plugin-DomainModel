use strict;
use warnings;

#
# Test how our custom model dies with bad config
#

use Test::More;
plan tests => 2;

my $app = q|
    package TestApp;
    use Dancer2;

    BEGIN {
        setting views => path( 't', 'views' );
        setting template => 'tiny';
           
        set plugins => {
            DomainModel => {
                base_class => 'Models',
                namespace  => 'Models',
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;

    template 'index', { news => model('Weather')->latest };

|;

eval $app;

my $ret = $@;
ok( $ret, 'App should fail with conflicting config' );
like( $ret, qr/mutually exclusive/, "Error shows conflicting conf keys" );
