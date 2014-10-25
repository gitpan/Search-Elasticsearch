package Elasticsearch::Cxn::LWP;
{
  $Elasticsearch::Cxn::LWP::VERSION = '0.76';
}

use Moo;
with 'Elasticsearch::Role::Cxn::HTTP';

use LWP::UserAgent();
use HTTP::Headers();
use HTTP::Request();

use namespace::clean;

#===================================
sub perform_request {
#===================================
    my ( $self, $params ) = @_;
    my $uri    = $self->build_uri($params);
    my $method = $params->{method};

    my $request = HTTP::Request->new(
        $method => $uri,
        [   'Content-Type' => $params->{mime_type},
            %{ $self->default_headers },
        ],
        $params->{data}
    );

    my $ua = $self->handle;
    my $timeout = $params->{timeout} || $self->request_timeout;
    if ( $timeout ne $ua->timeout ) {
        $ua->conn_cache->drop;
        $ua->timeout($timeout);
    }
    my $response = $ua->request($request);

    return $self->process_response(
        $params,                                 # request
        $response->code,                         # code
        $response->message,                      # msg
        $response->content,                      # body
        $response->header('content-encoding')    # encoding,
    );
}

#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];

    return
          /read timeout/                           ? 'Timeout'
        : /write failed: Connection reset by peer/ ? 'ContentLength'
        : /Can't connect|Server closed connection/ ? 'Cxn'
        :                                            'Request';
}

#===================================
sub _build_handle {
#===================================
    my $self = shift;
    my %args = (
        keep_alive => 1,
        parse_head => 0
    );
    if ( $self->is_https ) {
        $args{ssl_opts} = { verify_hostname => 0 };
    }
    return LWP::UserAgent->new( %args, %{ $self->handle_args } );
}

1;

# ABSTRACT: A Cxn implementation which uses LWP

__END__

=pod

=head1 NAME

Elasticsearch::Cxn::LWP - A Cxn implementation which uses LWP

=head1 VERSION

version 0.76

=head1 DESCRIPTION

Provides the default HTTP Cxn class and is based on L<LWP>.
The LWP backend uses pure Perl and persistent connections.

This class does L<Elasticsearch::Role::Cxn::HTTP>, whose documentation
provides more information.

=head1 SEE ALSO

=over

=item * L<Elasticsearch::Role::Cxn::HTTP>

=item * L<Elasticsearch::Cxn::HTTPTiny>

=item * L<Elasticsearch::Cxn::NetCurl>

=back

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Elasticsearch BV.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
