use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
do 'LogCallback.pl';
our $format;

isa_ok my $e = Elasticsearch->new( nodes => 'https://foo.bar:444/some/path' ),
    'Elasticsearch::Client::Direct',
    'Client';

isa_ok my $l = $e->logger, 'Elasticsearch::Logger::LogAny', 'Logger';
isa_ok my $c = $e->transport->cxn_pool->cxns->[0],
    'Elasticsearch::Cxn::HTTPTiny';

ok $l->trace_comment("The quick fox\njumped"), 'Comment';

is $format, <<"COMMENT", 'Comment - format';
# *** The quick fox
# *** jumped
COMMENT

done_testing;

