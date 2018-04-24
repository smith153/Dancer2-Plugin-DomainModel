use strict;
use warnings;

#
# Test out some 'typical' model with the built in model base class
#

BEGIN {
    use Test::More;
    eval "use Moose";
    plan skip_all => "Moose required for testing using default model" if $@;
}

use Plack::Test;
use HTTP::Request::Common;

plan tests => 8;

use_ok 'Dancer2::Plugin::DomainModel';

{

    package TestApp;
    use Dancer2;
    use FindBin;
    use lib "$FindBin::Bin/lib";

    BEGIN {
        use File::Temp;
        my $tmp = File::Temp->new( EXLOCK => 0 );
        my $filename = $tmp->filename;

        setting views => path( 't', 'views' );
        setting template => 'tiny';

        set plugins => {
            DBIC => {
                default => {
                    dsn          => 'dbi:SQLite:dbname=' . $filename,
                    schema_class => 'Test::Schema',
                }
            },
            DomainModel => {
                namespace => 'Test::MyModels',
                DBIC      => {
                    dsn          => 'dbi:SQLite:dbname=' . $filename,
                    schema_class => 'Test::Schema',
                },
            },
        };
    }
    use Dancer2::Plugin::DBIC;
    use Dancer2::Plugin::DomainModel;

    schema->deploy();
    rset('Weather')
      ->populate(
        [ { id => 1, entry => 'first' }, { id => 2, entry => 'second' } ] );

    get '/' => sub {
        template 'index', { news => model('Weather')->latest };
    };

    get '/rset' => sub {
        template 'index', { news => model('Weather')->rset_latest };
    };

    get '/no_db_latest' => sub {
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
like( $res->content, qr/<span>first<\/span>/, '[GET / ] Correct content' );

$req = GET 'http://127.0.0.1/rset';
$res = $test->request($req);
is( $res->code, 200, '[GET /rset ] Request successful' );
like( $res->content, qr/<span>first<\/span>/, '[GET /rset ] Correct content' );

$req = GET 'http://127.0.0.1/no_db_latest';
$res = $test->request($req);
is( $res->code, 200, '[GET /no_db_latest ] Request successful' );
like( $res->content, qr/<span>one<\/span>/,
    '[GET /no_db_latest ] Correct content' );

