use strict;
use warnings;

#
# Test out some 'typical' model usage
#

use Test::More;
plan tests => 4;
use Plack::Test;
use HTTP::Request::Common;

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
                base_class => 'Models',
                args       => {
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
        template 'index', { news => model('News')->latest };
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

