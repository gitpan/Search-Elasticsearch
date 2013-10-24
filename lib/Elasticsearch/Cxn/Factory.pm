package Elasticsearch::Cxn::Factory;
{
  $Elasticsearch::Cxn::Factory::VERSION = '0.75';
}

use Moo;
use Elasticsearch::Util qw(parse_params load_plugin);
use namespace::clean;

has 'cxn_class'          => ( is => 'ro', required => 1 );
has '_factory'           => ( is => 'ro', required => 1 );
has 'default_host'       => ( is => 'ro', required => 1 );
has 'max_content_length' => ( is => 'rw', default  => 104_857_600 );

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my %args = (%$params);
    delete $args{nodes};

    my $cxn_class = load_plugin( 'Cxn', delete $args{cxn} );
    $params->{_factory} = sub {
        my ( $self, $node ) = @_;
        $cxn_class->new(
            %args,
            node               => $node,
            max_content_length => $self->max_content_length
        );
    };
    $params->{default_host} = $cxn_class->default_host;
    $params->{cxn_args}     = \%args;
    $params->{cxn_class}    = $cxn_class;
    return $params;
}

#===================================
sub new_cxn { shift->_factory->(@_) }
#===================================

1;

=pod

=head1 NAME

Elasticsearch::Cxn::Factory - Used by CxnPools to create new Cxn instances.

=head1 VERSION

version 0.75

=head1 DESCRIPTION

This class is used by the L<Elasticsearch::Role::CxnPool> implementations
to create new L<Elasticsearch::Role::Cxn>-based instances. It holds on
to all the configuration options passed to L<Elasticsearhch/new()> so
that new Cxns can use them.

It contains no user serviceable parts.

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Elasticsearch BV.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

__END__

# ABSTRACT: Used by CxnPools to create new Cxn instances.

