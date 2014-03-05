
BEGIN {
  unless ($ENV{RELEASE_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for release candidate testing');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::NoTabsTests 0.06

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/ElasticSearch.pm',
    'lib/ElasticSearch/Error.pm',
    'lib/ElasticSearch/QueryParser.pm',
    'lib/ElasticSearch/RequestParser.pm',
    'lib/ElasticSearch/ScrolledSearch.pm',
    'lib/ElasticSearch/TestServer.pm',
    'lib/ElasticSearch/Transport.pm',
    'lib/ElasticSearch/Transport/HTTP.pm',
    'lib/ElasticSearch/Transport/HTTPLite.pm',
    'lib/ElasticSearch/Transport/HTTPTiny.pm',
    'lib/ElasticSearch/Util.pm'
);

notabs_ok($_) foreach @files;
done_testing;
