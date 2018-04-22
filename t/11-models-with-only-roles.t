use strict;
use warnings;

#
# Test only loading models that have a certain role applied
#

BEGIN {
    use Test::More;
    eval "use Moose";
    plan skip_all => "Moose required for testing using default model" if $@;
}

use Plack::Test;
use HTTP::Request::Common;

plan tests => 5;

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
        setting logger   => 'Null';

        set plugins => {
            DBIC => {
                default => {
                    dsn          => 'dbi:SQLite:dbname=' . $filename,
                    schema_class => 'Test::Schema',
                }
            },
            DomainModel => {
                namespace => 'Test::MyModels',
                only_with => ['Test::ExtraRole'],
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
    rset('News')
      ->populate(
        [ { id => 1, entry => 'first' }, { id => 2, entry => 'second' } ] );

    get '/' => sub {
        template 'index', { news => model('Weather')->latest };
    };
    get '/news' => sub {
        template 'index', { news => model('News')->latest };
    };
}

my $app = TestApp->to_app;
is( ref $app, 'CODE', 'Got app' );
my $test = Plack::Test->create($app);
my ( $req, $res );

$req = GET 'http://127.0.0.1/';
$res = $test->request($req);
is( $res->code, 500, '[GET / ] Request failed because Weather model skipped' );

$req = GET 'http://127.0.0.1/news';
$res = $test->request($req);
is( $res->code, 200, '[GET /news ] Request successful' );
like( $res->content, qr/<span>first<\/span>/, '[GET /news ] Correct content' );

