#!perl

our $test_num;
BEGIN { $test_num = 270 }

#use Test::Most qw(defer_plan);
use Test::More tests => $test_num;
use Test::Exception;
use Module::Build;
use lib 't/request_tests';

our $instances = 3;

my $transport = $ENV{ES_TRANSPORT} || 'http';
$transport = 'http'
    unless $ElasticSearch::Transport::Transport{$transport};

BEGIN {
    use_ok 'ElasticSearch'             || print "Bail out!";
    use_ok 'ElasticSearch::TestServer' || print "Bail out!";
}

diag "";
diag "Testing ElasticSearch $ElasticSearch::VERSION, Perl $], $^X";
diag "Transport: $transport (Set ES_TRANSPORT=http|httplite|httptiny|thrift)";
diag "";

our $es = eval {
    connect_to_es(
        instances   => $instances,
        transport   => $transport,
        trace_calls => 'log'
    );
} or do { diag $_ for split /\n/, $@ };

# ./bin/elasticsearch -Des.path.data=/tmp/elastic \
# -Des.network.host=127.0.0.1 \
# -Des.cluster.name=es_test \
# -Des.action.auto_create_index=1
#
#   our $es = ElasticSearch->new(
#       servers     => ['127.0.0.1:9200'],
#       trace_calls => 'log'
#   );

#===================================
sub run_tests {
#===================================
    while ( my $module = shift ) {
        my $str = "Testing: $module";
        note '';
        note $str;
        note '-' x length $str;
        do "$module.pl" or die $!;

    }
}

SKIP: {
    skip "ElasticSearch server not available for testing", $test_num - 2
        unless $es;

    ok $es, 'Connected to an ES cluster';
    ok $es->transport->current_server, 'Current server set';

    wait_for_es();

    create_indices();
    run_tests( qw(
            version
            cluster_state
            cluster_health
            nodes
            module_options
            )
    );

    drop_indices();
    run_tests( qw(
            create_index
            index_status
            update_settings
            index_admin
            analyze
            clear_cache
            index_alias
            open_close_index
            delete_index
            )
    );

    drop_indices();
    run_tests( qw(
            index_templates
            rivers
            )
    );

    create_indices();
    run_tests( qw(
            index_and_create
            get
            delete
            )
    );

    drop_indices();
    run_tests('mapping');

    drop_indices();
    run_tests( 'bulk', 'as_json' );

    create_indices();
    index_test_docs();

    run_tests( qw(
            search_query
            search_from_size
            search_types
            search_facets
            search_explain
            search_sort
            search_fields
            search_script_fields
            search_highlight
            search_scroll
            search_indices_boost
            search_custom_score
            count
            more_like_this
            search_highlight
            delete_by_query
            )
    );

    #    all_done;
}

#===================================
sub create_indices {
#===================================

    note("Creating indices");

    drop_indices();

    my %properties = (
        properties => {
            text => { type => 'string' },
            num  => { type => 'integer', store => 'yes' },
            date => { type => 'date', format => 'yyyy-MM-dd HH:mm:ss' }
        }
    );

    for ( 1 .. 2 ) {
        $es->create_index(
            index    => 'es_test_' . $_,
            mappings => {
                type_1 => \%properties,
                type_2 => \%properties,

            }
        );
    }

    wait_for_es();
}

#===================================
sub index_test_docs {
#===================================

    note("Loading test docs");

    my @rows = map {
        {
            index    => "es_test_" . $_->[0],
                type => "type_" . $_->[1],
                id   => $_->[2],
                data => {
                text => $_->[3],
                num  => $_->[2] + 1,
                date => $_->[4] . ' 00:00:00'
                }
        }
        } (
        [ 1, 1, 1,  'foo',         '2010-04-02' ],
        [ 1, 2, 2,  'foo',         '2010-04-03' ],
        [ 2, 1, 3,  'foo',         '2010-04-04' ],
        [ 2, 2, 4,  'foo',         '2010-04-05' ],
        [ 1, 1, 5,  'foo bar',     '2010-04-06' ],
        [ 1, 2, 6,  'foo bar',     '2010-04-07' ],
        [ 2, 1, 7,  'foo bar',     '2010-04-08' ],
        [ 2, 2, 8,  'foo bar',     '2010-04-09' ],
        [ 1, 1, 9,  'foo bar baz', '2010-04-10' ],
        [ 1, 2, 10, 'foo bar baz', '2010-04-11' ],
        [ 2, 1, 11, 'foo bar baz', '2010-04-12' ],
        [ 2, 2, 12, 'foo bar baz', '2010-04-13' ],
        [ 1, 1, 13, 'bar baz',     '2010-04-14' ],
        [ 1, 2, 14, 'bar baz',     '2010-04-15' ],
        [ 2, 1, 15, 'bar baz',     '2010-04-16' ],
        [ 2, 2, 16, 'bar baz',     '2010-04-17' ],
        [ 1, 1, 17, 'baz',         '2010-04-18' ],
        [ 1, 2, 18, 'baz',         '2010-04-19' ],
        [ 2, 1, 19, 'baz',         '2010-04-20' ],
        [ 2, 2, 20, 'baz',         '2010-04-21' ],
        [ 1, 1, 21, 'bar',         '2010-04-22' ],
        [ 1, 2, 22, 'bar',         '2010-04-23' ],
        [ 2, 1, 23, 'bar',         '2010-04-24' ],
        [ 2, 2, 24, 'bar',         '2010-04-25' ],
        [ 1, 1, 25, 'foo baz',     '2010-04-26' ],
        [ 1, 2, 26, 'foo baz',     '2010-04-27' ],
        [ 2, 1, 27, 'foo baz',     '2010-04-28' ],
        [ 2, 2, 28, 'foo baz',     '2010-04-29' ],
        [ 1, 1, 30, 'foo',         '2010-05-01' ],

        );

    $es->bulk_index( \@rows, { refresh => 1 } );

}

#===================================
sub parent_child_docs {
#===================================
    note("Preparing indices for parent/child tests");

    drop_indices();

    $es->create_index( index => 'es_test_1' );
    $es->put_mapping(
        index      => 'es_test_1',
        type       => 'myparent',
        properties => { text => { type => 'string' } }
    );
    $es->put_mapping(
        index      => 'es_test_1',
        type       => 'mychild',
        _parent    => { type => 'myparent' },
        properties => { text => { type => 'string' } }
    );

    wait_for_es();

    $es->bulk_index( {
            index => 'es_test_1',
            type  => 'myparent',
            id    => 1,
            data  => { text => 'john smith' }
        },
        {   index => 'es_test_1',
            type  => 'myparent',
            id    => 2,
            data  => { text => 'mary smith' }
        },
        {   index   => 'es_test_1',
            type    => 'mychild',
            id      => 3,
            _parent => 1,
            data    => { text => 'abigail' }
        },
        {   index   => 'es_test_1',
            type    => 'mychild',
            id      => 4,
            _parent => 1,
            data    => { text => 'percival' }
        },
        {   index   => 'es_test_1',
            type    => 'mychild',
            id      => 5,
            _parent => 2,
            data    => { text => 'abigail' }
        },
        {   index   => 'es_test_1',
            type    => 'mychild',
            id      => 6,
            _parent => 2,
            data    => { text => 'oscar' }
        },
    );
    wait_for_es();
}

#===================================
sub drop_indices {
#===================================
    eval {
        $es->delete_index( index => 'es_test_1' );
        $es->delete_index( index => 'es_test_2' );
        wait_for_es();
    };

}

#===================================
sub wait_for_es {
#===================================
    sleep $_[0] if $_[0];
    $es->cluster_health(
        wait_for_status => 'green',
        timeout         => '30s'
    );
    $es->refresh_index();
}