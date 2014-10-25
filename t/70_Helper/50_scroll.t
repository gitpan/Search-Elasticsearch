use Test::More;
use Test::Deep;
use Test::Exception;
use lib 't/lib';

use strict;
use warnings;

our $es;

BEGIN {
    $es = do "es_test_server.pl";
    use_ok 'Elasticsearch::Scroll';
}

$es->indices->delete( index => '_all', ignore => 404 );

if ( $es->info->{version}{number} ge '0.90.5' ) {
    test_scroll(
        "No indices",
        {},
        total     => 0,
        max_score => 0,
        steps     => [
            eof           => 1,
            next          => [0],
            refill_buffer => 0,
            drain_buffer  => [0],
        ]
    );
}

do "index_test_data.pl" or die $!;

test_scroll(
    "Match all",
    {},
    total     => 100,
    max_score => 1,
    steps     => [
        eof           => '',
        buffer_size   => 10,
        next          => [1],
        drain_buffer  => [9],
        refill_buffer => 10,
        refill_buffer => 20,
        eof           => '',
        next_81       => [81],
        next_20       => [9],
        next          => [0],
        eof           => 1,
    ]
);

SKIP: {
    skip "Bug in Elasticsearch suggest JSON parsing pre 0.90.2", 2
        if $es->info->{version}{number} lt '0.90.2';

    test_scroll(
        "Query",
        {   body => {
                query   => { term => { color => 'red' } },
                suggest => {
                    mysuggest =>
                        { text => 'green', term => { field => 'color' } }
                },
                facets => { color => { terms => { field => 'color' } } }
            }
        },
        total     => 50,
        max_score => num( 1.6, 0.2 ),
        facets    => bool(1),
        suggest   => bool(1),
        steps     => [
            next    => [1],
            next_50 => [49],
            eof     => 1,
        ]
    );

    test_scroll(
        "Scan",
        {   search_type => 'scan',
            body        => {
                suggest => {
                    mysuggest =>
                        { text => 'green', term => { field => 'color' } }
                },
                facets => { color => { terms => { field => 'color' } } }
            }
        },
        total     => 100,
        max_score => 0,
        facets    => bool(1),
        suggest   => bool(1),
        steps     => [
            buffer_size => 0,
            next        => [1],
            buffer_size => 49,
            next_100    => [99],
            eof         => 1,
        ]
    );

}

test_scroll(
    "Finish",
    {},
    total     => 100,
    max_score => 1,
    steps     => [
        eof         => '',
        next        => [1],
        finish      => 1,
        eof         => 1,
        buffer_size => 0,
        next        => [0]

    ]
);

done_testing;
$es->indices->delete( index => 'test' );

#===================================
sub test_scroll {
#===================================
    my ( $title, $params, %tests ) = @_;
    subtest $title => sub {
        isa_ok my $s = Elasticsearch::Scroll->new( es => $es, %$params ),
            'Elasticsearch::Scroll', $title;

        is $s->total,             $tests{total},     "$title - total";
        cmp_deeply $s->max_score, $tests{max_score}, "$title - max_score";
        cmp_deeply $s->facets,    $tests{facets},    "$title - facets";
        cmp_deeply $s->suggest,   $tests{suggest},   "$title - suggest";

        my $i     = 1;
        my @steps = @{ $tests{steps} };
        while ( my $name = shift @steps ) {
            my $expect = shift @steps;
            my ( $method, $result, @p );
            if ( $name =~ /next(?:_(\d+))?/ ) {
                $method = 'next';
                @p      = $1;
            }
            else {
                $method = $name;
            }

            if ( ref $expect eq 'ARRAY' ) {
                my @result = $s->$method(@p);
                $result = 0 + @result;
                $expect = $expect->[0];
            }
            else {
                $result = $s->$method(@p);
            }

            is $result, $expect, "$title - Step $i: $name";
            $i++;
        }
        }
}

