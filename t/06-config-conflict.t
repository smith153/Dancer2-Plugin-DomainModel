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
    use FindBin;
    use lib "$FindBin::Bin/lib";

    BEGIN {
        setting views => path( 't', 'views' );
        setting template => 'tiny';
           
        set plugins => {
            DomainModel => {
                base_class => 'Models',
                model_dir  => 'Models',
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;

    template 'index', { news => model('News')->latest };

|;

eval $app;

my $ret = $@;
ok( $ret, 'Model with bad schema_class should fail' );
like( $ret, qr/mutually exclusive/, "Can't use conflicting conf keys" );
