
BEGIN {
  unless ($ENV{RELEASE_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for release candidate testing');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.06

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Search/Elasticsearch.pm',
    'lib/Search/Elasticsearch/Bulk.pm',
    'lib/Search/Elasticsearch/Client/0_90/Direct.pm',
    'lib/Search/Elasticsearch/Client/0_90/Direct/Cluster.pm',
    'lib/Search/Elasticsearch/Client/0_90/Direct/Indices.pm',
    'lib/Search/Elasticsearch/Client/Direct.pm',
    'lib/Search/Elasticsearch/Client/Direct/Cat.pm',
    'lib/Search/Elasticsearch/Client/Direct/Cluster.pm',
    'lib/Search/Elasticsearch/Client/Direct/Indices.pm',
    'lib/Search/Elasticsearch/Client/Direct/Nodes.pm',
    'lib/Search/Elasticsearch/Client/Direct/Snapshot.pm',
    'lib/Search/Elasticsearch/Cxn/Factory.pm',
    'lib/Search/Elasticsearch/Cxn/HTTPTiny.pm',
    'lib/Search/Elasticsearch/Cxn/Hijk.pm',
    'lib/Search/Elasticsearch/Cxn/LWP.pm',
    'lib/Search/Elasticsearch/CxnPool/Sniff.pm',
    'lib/Search/Elasticsearch/CxnPool/Static.pm',
    'lib/Search/Elasticsearch/CxnPool/Static/NoPing.pm',
    'lib/Search/Elasticsearch/Error.pm',
    'lib/Search/Elasticsearch/Logger/LogAny.pm',
    'lib/Search/Elasticsearch/Role/API.pm',
    'lib/Search/Elasticsearch/Role/API/0_90.pm',
    'lib/Search/Elasticsearch/Role/Bulk.pm',
    'lib/Search/Elasticsearch/Role/Client.pm',
    'lib/Search/Elasticsearch/Role/Client/Direct.pm',
    'lib/Search/Elasticsearch/Role/Cxn.pm',
    'lib/Search/Elasticsearch/Role/Cxn/HTTP.pm',
    'lib/Search/Elasticsearch/Role/CxnPool.pm',
    'lib/Search/Elasticsearch/Role/CxnPool/Sniff.pm',
    'lib/Search/Elasticsearch/Role/CxnPool/Static.pm',
    'lib/Search/Elasticsearch/Role/CxnPool/Static/NoPing.pm',
    'lib/Search/Elasticsearch/Role/Is_Sync.pm',
    'lib/Search/Elasticsearch/Role/Logger.pm',
    'lib/Search/Elasticsearch/Role/Scroll.pm',
    'lib/Search/Elasticsearch/Role/Serializer.pm',
    'lib/Search/Elasticsearch/Role/Serializer/JSON.pm',
    'lib/Search/Elasticsearch/Role/Transport.pm',
    'lib/Search/Elasticsearch/Scroll.pm',
    'lib/Search/Elasticsearch/Serializer/JSON.pm',
    'lib/Search/Elasticsearch/Serializer/JSON/Cpanel.pm',
    'lib/Search/Elasticsearch/Serializer/JSON/PP.pm',
    'lib/Search/Elasticsearch/Serializer/JSON/XS.pm',
    'lib/Search/Elasticsearch/TestServer.pm',
    'lib/Search/Elasticsearch/Transport.pm',
    'lib/Search/Elasticsearch/Util.pm',
    'lib/Search/Elasticsearch/Util/API/Path.pm',
    'lib/Search/Elasticsearch/Util/API/QS.pm'
);

notabs_ok($_) foreach @files;
done_testing;
