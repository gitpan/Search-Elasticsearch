
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
    'lib/Elasticsearch.pm',
    'lib/Elasticsearch/Bulk.pm',
    'lib/Elasticsearch/Client/0_90/Direct.pm',
    'lib/Elasticsearch/Client/0_90/Direct/Cluster.pm',
    'lib/Elasticsearch/Client/0_90/Direct/Indices.pm',
    'lib/Elasticsearch/Client/Direct.pm',
    'lib/Elasticsearch/Client/Direct/Cat.pm',
    'lib/Elasticsearch/Client/Direct/Cluster.pm',
    'lib/Elasticsearch/Client/Direct/Indices.pm',
    'lib/Elasticsearch/Client/Direct/Nodes.pm',
    'lib/Elasticsearch/Client/Direct/Snapshot.pm',
    'lib/Elasticsearch/Cxn/Factory.pm',
    'lib/Elasticsearch/Cxn/HTTPTiny.pm',
    'lib/Elasticsearch/Cxn/LWP.pm',
    'lib/Elasticsearch/CxnPool/Sniff.pm',
    'lib/Elasticsearch/CxnPool/Static.pm',
    'lib/Elasticsearch/CxnPool/Static/NoPing.pm',
    'lib/Elasticsearch/Error.pm',
    'lib/Elasticsearch/Logger/LogAny.pm',
    'lib/Elasticsearch/Role/API.pm',
    'lib/Elasticsearch/Role/API/0_90.pm',
    'lib/Elasticsearch/Role/Bulk.pm',
    'lib/Elasticsearch/Role/Client.pm',
    'lib/Elasticsearch/Role/Client/Direct.pm',
    'lib/Elasticsearch/Role/Cxn.pm',
    'lib/Elasticsearch/Role/Cxn/HTTP.pm',
    'lib/Elasticsearch/Role/CxnPool.pm',
    'lib/Elasticsearch/Role/CxnPool/Sniff.pm',
    'lib/Elasticsearch/Role/CxnPool/Static.pm',
    'lib/Elasticsearch/Role/CxnPool/Static/NoPing.pm',
    'lib/Elasticsearch/Role/Is_Sync.pm',
    'lib/Elasticsearch/Role/Logger.pm',
    'lib/Elasticsearch/Role/Scroll.pm',
    'lib/Elasticsearch/Role/Serializer.pm',
    'lib/Elasticsearch/Role/Transport.pm',
    'lib/Elasticsearch/Scroll.pm',
    'lib/Elasticsearch/Serializer/JSON.pm',
    'lib/Elasticsearch/TestServer.pm',
    'lib/Elasticsearch/Transport.pm',
    'lib/Elasticsearch/Util.pm',
    'lib/Elasticsearch/Util/API/Path.pm',
    'lib/Elasticsearch/Util/API/QS.pm'
);

notabs_ok($_) foreach @files;
done_testing;
