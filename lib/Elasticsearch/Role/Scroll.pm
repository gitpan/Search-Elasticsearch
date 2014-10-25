package Elasticsearch::Role::Scroll;
$Elasticsearch::Role::Scroll::VERSION = '1.01';
use Moo::Role;
requires 'finish';
use Elasticsearch::Util qw(parse_params throw);
use Scalar::Util qw(weaken blessed);
use namespace::clean;

has 'es' => ( is => 'ro', required => 1 );
has 'scroll'        => ( is => 'ro' );
has 'total'         => ( is => 'rwp' );
has 'max_score'     => ( is => 'rwp' );
has 'facets'        => ( is => 'rwp' );
has 'suggest'       => ( is => 'rwp' );
has 'took'          => ( is => 'rwp' );
has 'total_took'    => ( is => 'rwp' );
has 'search_params' => ( is => 'ro' );
has 'is_finished'   => ( is => 'rwp', default => '' );
has '_scroll_id'    => ( is => 'rwp', clearer => 1, predicate => 1 );

#===================================
sub finish {
#===================================
    my $self = shift;
    return if $self->is_finished;
    $self->_set_is_finished(1);

    my $scroll_id = $self->_scroll_id or return;
    $self->_clear_scroll_id;
    eval { $self->es->clear_scroll( scroll_id => $scroll_id ) };
}

#===================================
sub DEMOLISH {
#===================================
    my $self = shift or return;
    $self->finish;
}

1;

# ABSTRACT: Provides common functionality to L<Elasticseach::Scroll> and L<Elasticsearch::Async::Scroll>

__END__

=pod

=encoding UTF-8

=head1 NAME

Elasticsearch::Role::Scroll - Provides common functionality to L<Elasticseach::Scroll> and L<Elasticsearch::Async::Scroll>

=head1 VERSION

version 1.01

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Elasticsearch BV.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
