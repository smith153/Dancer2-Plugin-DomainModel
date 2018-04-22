use strict;
use warnings;

#
# Test logger role works with default model
#

BEGIN {
    use Test::More;
    eval "use Moose";
    plan skip_all => "Moose required for testing using default model" if $@;
}

use Plack::Test;
use HTTP::Request::Common;
use Capture::Tiny 'capture_stderr';

plan tests => 10;

{

    package TestApp;
    use Dancer2;
    use FindBin;
    use lib "$FindBin::Bin/lib";

    BEGIN {

        setting views => path( 't', 'views' );
        setting template => 'tiny';
        set logger       => 'console';
        set log          => 'debug';

        set plugins => {
            DomainModel => {
                namespace => 'Test::MyModels',
            },
        };
    }
    use Dancer2::Plugin::DomainModel;

    get '/info' => sub {
        model('News')->hi_from_info;
        return 'hi from info';
    };

    get '/debug' => sub {
        model('News')->hi_from_debug;
        return 'hi from debug';
    };

    get '/warn' => sub {
        model('News')->hi_from_warn;
        return 'hi from warn';
    };

}
my $app = TestApp->to_app;
is( ref $app, 'CODE', 'Got app' );
my $test = Plack::Test->create($app);
my ( $req, $res, $stderr );

$stderr = capture_stderr {

    $req = GET 'http://127.0.0.1/info';
    $res = $test->request($req);

};

is( $res->code, 200, '[GET /info ] Request successful' );
like( $res->content, qr/hi from info/, '[GET /info ] Correct content' );
like( $stderr, qr/info.*?Hi from info logger/, 'Info logger correct' );

$stderr = capture_stderr {

    $req = GET 'http://127.0.0.1/warn';
    $res = $test->request($req);

};

is( $res->code, 200, '[GET /warn ] Request successful' );
like( $res->content, qr/hi from warn/, '[GET /warn ] Correct content' );
like( $stderr, qr/warn.*?Hi from warn logger/, 'Warn logger correct' );

$stderr = capture_stderr {

    $req = GET 'http://127.0.0.1/debug';
    $res = $test->request($req);

};

is( $res->code, 200, '[GET /debug ] Request successful' );
like( $res->content, qr/hi from debug/, '[GET /debug ] Correct content' );
like( $stderr, qr/debug.*?Hi from debug logger/, 'Debug logger correct' );

