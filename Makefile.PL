use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'               => 'Dancer2::Plugin::DomainModel',
    'VERSION_FROM'       => 'lib/Dancer2/Plugin/DomainModel.pm',
    'AUTHOR'             => 'Samuel Smith',
    'ABSTRACT_FROM'      => 'lib/Dancer2/Plugin/DomainModel.pm',
    'CONFIGURE_REQUIRES' => {
        'ExtUtils::MakeMaker' => 0
    },
    'TEST_REQUIRES' => {
        'Dancer2'                   => 0,
        'Test::More'                => 0,
        'Plack::Test'               => 0,
        'HTTP::Request::Common'     => 0,
        'Dancer2::Plugin::DBIC'     => 0,
        'Moo'                       => 0,
        'Module::Pluggable::Object' => 0,
        'Types::Standard'           => 0,
        'namespace::autoclean'      => 0,
        'DBIx::Class'               => 0,
    },
    'PREREQ_PM' => {
        'Dancer2::Plugin' => "0.200000",
        'Module::Runtime' => 0,
        'Carp'            => 0,
    },
    'LICENSE'    => 'perl_5',
    'META_MERGE' => {
        'resources' => {
            'repository' =>
              'https://github.com/smith153/Dancer2-Plugin-DomainModel',
        },
    },
);
