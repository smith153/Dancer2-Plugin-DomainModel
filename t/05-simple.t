use strict;
use warnings;

#
# Test a simple case (no extra args)
#

use Test::More;
plan tests => 3;
use Plack::Test;
use HTTP::Request::Common;

{

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
            },
        };
    }
    use Dancer2::Plugin::DomainModel;

    get '/' => sub {
        template 'index', { news => model('News')->no_db_latest };
    };
}

my $app = TestApp->to_app;
is( ref $app, 'CODE', 'Got app' );
my $test = Plack::Test->create($app);
my ( $req, $res );

$req = GET 'http://127.0.0.1/';
$res = $test->request($req);
is( $res->code, 200, '[GET / ] Request successful' );
like( $res->content, qr/<span>one<\/span>/, '[GET / ] Correct content' );

