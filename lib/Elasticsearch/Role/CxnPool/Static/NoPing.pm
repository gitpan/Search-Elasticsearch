package Elasticsearch::Role::CxnPool::Static::NoPing;
$Elasticsearch::Role::CxnPool::Static::NoPing::VERSION = '1.04';
use Moo::Role;
with 'Elasticsearch::Role::CxnPool';
requires 'next_cxn';
use namespace::clean;

has 'max_retries' => ( is => 'lazy' );
has '_dead_cxns' => ( is => 'ro', default => sub { [] } );

#===================================
sub _build_max_retries { @{ shift->cxns } - 1 }
sub _max_retries       { shift->max_retries + 1 }
#===================================

#===================================
sub BUILD {
#===================================
    my $self = shift;
    $self->set_cxns( @{ $self->seed_nodes } );
}

#===================================
sub should_mark_dead {
#===================================
    my ( $self, $error ) = @_;
    return $error->is( 'Cxn', 'Timeout' );
}

#===================================
after 'reset_retries' => sub {
#===================================
    my $self = shift;
    @{ $self->_dead_cxns } = ();

};

#===================================
sub schedule_check { }
#===================================

1;

# ABSTRACT: A CxnPool for connecting to a remote cluster without the ability to ping.

__END__

=pod

=encoding UTF-8

=head1 NAME

Elasticsearch::Role::CxnPool::Static::NoPing - A CxnPool for connecting to a remote cluster without the ability to ping.

=head1 VERSION

version 1.04

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Elasticsearch BV.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
