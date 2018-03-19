use strict;
use warnings;

#
# Test how model plugin handles bad arguments
#

use Test::More;
plan tests => 3;

my $app = q|
    package TestApp;
    use Dancer2;

    BEGIN {
                
        set plugins => {
            DomainModel => {
                base_class => 'Base',
                foo => '1',
                bar => '1',
            },
        };
    }
    
    use Dancer2::Plugin::DomainModel;
|;

eval $app;

my $ret = $@;
ok( $ret, 'app with extra arguments should fail' );
like( $ret, qr/invalid configuration key.*$_/, "'$_' included in error" )
  for qw( bar foo );
