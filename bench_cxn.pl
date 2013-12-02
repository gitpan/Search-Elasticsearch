#!/usr/bin/env perl

use strict;
use warnings;
use Benchmark qw(timeit cmpthese timesum :hireswallclock);
use Elasticsearch;
use v5.16;

my $Times = 2;
my $Total = 50000;
my $Doc   = '{"foo":"' . ( 'x' x 1) . '"}';
my $es;

say "Warming up";
cxn('NetCurl');
reset_es();
#index_docs();
#get_docs();
#reset_es();

my ( %reads, %writes );
for ( 1 .. $Times ) {
    say "Run $_:";
    for my $cxn ( 'NetCurl') {
        say " * $cxn";
        cxn($cxn);
        my $t = timeit( 1, sub { index_docs() } );
        $writes{$cxn} = $writes{$cxn} ? timesum( $writes{$cxn}, $t ) : $t;
#        sleep 2;
        $t = timeit( 1, sub { get_docs() } );
        $reads{$cxn} = $reads{$cxn} ? timesum( $reads{$cxn}, $t ) : $t;
        reset_es();
 #       sleep 2;
    }
}
say "";
say "Write:";
cmpthese( \%writes );
say "";
say "Read:";
cmpthese( \%reads );

#===================================
sub cxn {
#===================================
    $es = Elasticsearch->new( cxn => shift(), request_timeout => 15);
}

#===================================
sub reset_es {
#===================================
    $es->indices->delete( index => 'test', ignore => 404 );
    $es->indices->create(
        index => 'test',
        body  => { mappings => { test => { enabled => 0 } } }
    );
    $es->cluster->health( wait_for_status => 'yellow' );
}

#===================================
sub index_docs {
#===================================
    for ( 1 .. $Total ) {
        $es->index( index => 'test', type => 'test', id => $_, body => $Doc );
    }
}

#===================================
sub get_docs {
#===================================
    for ( 1 .. $Total ) {
        $es->get( index => 'test', type => 'test', id => $_ );
    }
}

