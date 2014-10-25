package Elasticsearch::Role::CxnPool;
{
  $Elasticsearch::Role::CxnPool::VERSION = '0.04';
}

use Moo::Role;
use Elasticsearch::Util qw(parse_params);
use namespace::autoclean;

use List::Util qw(shuffle);
use IO::Select();
use Time::HiRes qw(time sleep);
use Elasticsearch::Util qw(to_list);

requires qw(next_cxn schedule_check);

has 'cxn_factory'     => ( is => 'ro',  required => 1 );
has 'logger'          => ( is => 'ro',  required => 1 );
has 'serializer'      => ( is => 'ro',  required => 1 );
has 'current_cxn_num' => ( is => 'rwp', default  => 0 );
has 'cxns'            => ( is => 'rw',  default  => sub { [] } );
has 'seed_nodes'      => ( is => 'ro',  required => 1 );
has 'retries'         => ( is => 'rw',  default  => 0 );
has 'randomize_cxns'  => ( is => 'ro',  default  => 1 );

#===================================
around BUILDARGS => sub {
#===================================
    my $orig   = shift;
    my $params = $orig->(@_);
    my @seed   = grep {$_} to_list( delete $params->{nodes} || ('') );

    @seed = $params->{cxn_factory}->default_host
        unless @seed;
    $params->{seed_nodes} = \@seed;
    return $params;
};

#===================================
sub next_cxn_num {
#===================================
    my $self = shift;
    my $cxns = $self->cxns;
    return unless @$cxns;
    my $current = $self->current_cxn_num;
    $self->_set_current_cxn_num( ( $current + 1 ) % @$cxns );
    return $current;
}

#===================================
sub set_cxns {
#===================================
    my $self    = shift;
    my $factory = $self->cxn_factory;
    my @cxns    = map { $factory->new_cxn($_) } @_;
    @cxns = shuffle @cxns if $self->randomize_cxns;
    $self->cxns( \@cxns );
    $self->_set_current_cxn_num(0);

    $self->logger->infof( "Current cxns: %s",
        [ map { $_->stringify } @cxns ] );

    return;
}

#===================================
sub request_ok {
#===================================
    my ( $self, $cxn ) = @_;
    $cxn->mark_live;
    $self->reset_retries;
}

#===================================
sub request_failed {
#===================================
    my ( $self, $cxn, $error ) = @_;

    if ( $error->is( 'Cxn', 'Timeout' ) ) {
        $cxn->mark_dead if $self->should_mark_dead($error);
        $self->schedule_check;

        if ( $self->should_retry($error) ) {
            my $retries = $self->retries( $self->retries + 1 );
            return 1 if $retries < $self->_max_retries;
        }
    }
    else {
        $cxn->mark_live if $cxn;
    }
    $self->reset_retries;
    return 0;
}

#===================================
sub should_retry {
#===================================
    my ( $self, $error ) = @_;
    return $error->is('Cxn');
}

#===================================
sub should_mark_dead {
#===================================
    my ( $self, $error ) = @_;
    return $error->is('Cxn');
}

#===================================
sub cxns_str {
#===================================
    my $self = shift;
    join ", ", map { $_->stringify } @{ $self->cxns };
}

#===================================
sub cxns_seeds_str {
#===================================
    my $self = shift;
    join ", ", ( map { $_->stringify } @{ $self->cxns } ),
        @{ $self->seed_nodes };
}

#===================================
sub reset_retries { shift->retries(0) }
sub _max_retries  {2}
#===================================

1;

=pod

=head1 NAME

Elasticsearch::Role::CxnPool - Provides common functionality to the CxnPool implementations

=head1 VERSION

version 0.04

=head1 DESCRIPTION

See the CxnPool implementations:

=over

=item *

L<Elasticsearch::CxnPool::Static>

=item *

L<Elasticsearch::CxnPool::Sniff>

=item *

L<Elasticsearch::CxnPool::Static::NoPing>

=back

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Elasticsearch BV.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

__END__

#ABSTRACT: Provides common functionality to the CxnPool implementations


