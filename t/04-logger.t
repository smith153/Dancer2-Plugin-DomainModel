use strict;
use warnings;

#
# Test using the Dancer logger instance
# (since you still probably want to log to dancer from your models)
#

use Test::More;
plan tests => 4;
use Plack::Test;
use HTTP::Request::Common;
use Capture::Tiny 'capture_stderr';

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
                base_class => 'Models',
            },
        };
    }
    use Dancer2::Plugin::DomainModel;

    get '/' => sub {
        model('News')->hi_from_logger;
        return 'hi from route';
    };

}
my $app = TestApp->to_app;
is( ref $app, 'CODE', 'Got app' );
my $test = Plack::Test->create($app);
my ( $req, $res );

my $stderr = capture_stderr {

    $req = GET 'http://127.0.0.1/';
    $res = $test->request($req);

};

is( $res->code, 200, '[GET / ] Request successful' );
like( $res->content, qr/hi from route/,         '[GET / ] Correct content' );
like( $stderr,       qr/info.*?Hi from logger/, 'Logger output correct' );

