package ElasticSearch::ScrolledSearch;
{
  $ElasticSearch::ScrolledSearch::VERSION = '0.45';
}

use strict;
use warnings FATAL => 'all', NONFATAL => 'redefine';

use ElasticSearch::Util qw(parse_params);

=head1 NAME

ElasticSearch::ScrolledSearch - Description

=head1 SYNOPSIS

    $scroller = $es->scrolled_search($search_params);
  OR
    $scroller = ElasticSearch::ScrolledSearch($es,$search_params);

    while (my $result = $scroller->next) {
        # do something
    }

    $total = $scroller->total;
    $bool  = $scroller->eof
    $score = $scroller->max_score;

=head1 DESCRIPTION

C<ElasticSearch::ScrolledSearch> is a convenience iterator for scrolled
searches. It accepts the standard search parameters that would be passed
to L<ElasticSearch/"search()">. The C<scroll> parameter defaults to C<1m>.

    $scroller = $es->scrolled_search(
                    query  => {match_all=>{}},
                    scroll => '5m'               # keep the scroll request
                                                 # live for 5 minutes
                );

=head1 METHODS

=head2 C<new()>

    $scroller = $es->scrolled_search($search_params);
  OR
    $scroller = ElasticSearch::ScrolledSearch($es,$search_params);

=cut

#===================================
sub new {
#===================================
    my $class = shift;
    my ( $es, $params ) = parse_params(@_);

    my $scroll = $params->{scroll} ||= '1m';
    my $method = $params->{q} ? 'searchqs' : 'search';

    my $results = $es->$method($params);
    $results = $results->recv
        if ref $results ne 'HASH' and $results->isa('AnyEvent::CondVar');
    my $self = {
        _es        => $es,
        _scroll_id => $results->{_scroll_id},
        _scroll    => $scroll,
        _total     => $results->{hits}{total},
        _buffer    => $results->{hits}{hits},
        _max_score => $results->{hits}{max_score},
        _eof       => 0,
    };
    return bless( $self, $class );
}

=head2 next()

    @results = $scroller->next()
    @results = $scroller->next($no_of_results);

Returns the next result, or the next C<$no_of_results> or an empty list when
no more results are available.

An error is thrown if the C<scroll> has already expired.

=cut

#===================================
sub next {
#===================================
    my $self = shift;
    my $size = shift || 1;
    while ( @{ $self->{_buffer} } < $size && !$self->{_eof} ) {
        $self->_get_next;
    }
    return splice @{ $self->{_buffer} }, 0, $size;
}

#===================================
sub _get_next {
#===================================
    my $self = shift;
    return if $self->{_eof};
    my $results = $self->{_es}->scroll(
        scroll    => $self->{_scroll},
        scroll_id => $self->{_scroll_id}
    );
    $results = $results->recv
        if ref $results ne 'HASH' and $results->isa('AnyEvent::CondVar');
    my @hits = @{ $results->{hits}{hits} };
    $self->{_eof}++ if @hits == 0;
    $self->{_scroll_id} = $results->{_scroll_id};
    push @{ $self->{_buffer} }, @hits;
}

=head2 total()

    $total = $scroller->total

The total number of hits

=head2 max_score()

    $score = $scroller->max_score

The C<max_score> returned from the first search request (if available).

=head2 eof()

    $bool = $scroller->eof

Returns C<true> if no more results are available. Note: if no results
match the search, then C<eof()> could be C<false> but the first call
to C<next()> will return zero results.

=cut

#===================================
sub total     { shift->{_total} }
sub max_score { shift->{_max_score} }
sub eof       { shift->{_eof} }
#===================================

=head1 SEE ALSO

L<ElasticSearch/"scrolled_search()">, L<ElasticSearch/"search()"> and
L<ElasticSearch/"scroll()">

=head1 BUGS

None known

=head1 AUTHOR

Clinton Gormley, E<lt>clinton@traveljury.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Clinton Gormley

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut

1
