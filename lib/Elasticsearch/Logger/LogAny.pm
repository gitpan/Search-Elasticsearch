package Elasticsearch::Logger::LogAny;
{
  $Elasticsearch::Logger::LogAny::VERSION = '0.70';
}

use Moo;
with 'Elasticsearch::Role::Logger';
use Elasticsearch::Util qw(parse_params to_list);
use namespace::autoclean;

use Log::Any();
use Log::Any::Adapter();

#===================================
sub _build_log_handle {
#===================================
    my $self = shift;
    if ( my @args = to_list( $self->log_to ) ) {
        Log::Any::Adapter->set( { category => $self->log_as }, @args );
    }
    Log::Any->get_logger( category => $self->log_as );
}

#===================================
sub _build_trace_handle {
#===================================
    my $self = shift;
    if ( my @args = to_list( $self->trace_to ) ) {
        Log::Any::Adapter->set( { category => $self->trace_as }, @args );
    }
    Log::Any->get_logger( category => $self->trace_as );
}

1;

# ABSTRACT: A Log::Any-based Logger implemenation

__END__

=pod

=head1 NAME

Elasticsearch::Logger::LogAny - A Log::Any-based Logger implemenation

=head1 VERSION

version 0.70

=head1 DESCRIPTION

L<Elasticsearch::Logger::LogAny> provides event logging and the tracing
of request/response conversations with Elasticsearch nodes via the
L<Log::Any> module.

I<Logging> refers to log events, such as node failures, pings, sniffs, etc,
and should be enabled for monitoring purposes.

I<Tracing> refers to the actual HTTP requests and responses sent
to Elasticsearch nodes.  Tracing can be enabled for debugging purposes,
or for generating a pretty-printed C<curl> script which can be used for
reporting problems.

=head1 CONFIGURATION

Logging and tracing can be enabled using L<Log::Any::Adapter>, or by
passing options to L<Elasticsearch/new()>.

=head2 USING LOG::ANY::ADAPTER

Send all logging and tracing to C<STDERR>:

    use Log::Any::Adapter qw(Stderr);
    use Elasticsearch;
    my $e = Elasticsearch->new;

Send logging to a file, and tracing to Stderr:

    use Log::Any::Adapter();
    Log::Any::Adapter->set(
        { category => 'elasticsearch.event' },
        'File',
        '/path/to/file.log'
    );
    Log::Any::Adapter->set(
        { category => 'elasticsearch.trace' },
        'Stderr'
    );

    use Elasticsearch;
    my $e = Elasticsearch->new;

=head2 USING C<log_to> AND C<trace_to>

Send all logging and tracing to C<STDERR>:

    use Elasticsearch;
    my $e = Elasticsearch->new(
        log_to   => 'Stderr',
        trace_to => 'Stderr'
    );

Send logging to a file, and tracing to Stderr:

    use Elasticsearch;
    my $e = Elasticsearch->new(
        log_to   => ['File', '/path/to/file.log'],
        trace_to => 'Stderr'
    );

See L<Log::Any::Adapter> for more.

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Elasticsearch BV.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
