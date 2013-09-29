package Elasticsearch::Role::Serializer;
{
  $Elasticsearch::Role::Serializer::VERSION = '0.72';
}

use Moo::Role;

requires qw(encode decode encode_pretty encode_bulk mime_type);

1;

# ABSTRACT: An interface for Serializer modules

__END__

=pod

=head1 NAME

Elasticsearch::Role::Serializer - An interface for Serializer modules

=head1 VERSION

version 0.72

=head1 DESCRIPTION

There is no code in this module. It defines an inteface for
Serializer implementations, and requires the following methods:

=over

=item *

C<encode()>

=item *

C<encode_pretty()>

=item *

C<encode_bulk()>

=item *

C<decode()>

=item *

C<mime_type()>

=back

See L<Elasticsearch::Serializer::JSON> for more.

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Elasticsearch BV.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
