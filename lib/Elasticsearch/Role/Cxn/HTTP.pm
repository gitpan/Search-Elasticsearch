package Elasticsearch::Role::Cxn::HTTP;
{
  $Elasticsearch::Role::Cxn::HTTP::VERSION = '0.74';
}

use Moo::Role;
with 'Elasticsearch::Role::Cxn';
use URI();
use Elasticsearch::Util qw(parse_params throw);
use namespace::clean;

has 'scheme'             => ( is => 'ro' );
has 'is_https'           => ( is => 'ro' );
has 'userinfo'           => ( is => 'ro' );
has 'max_content_length' => ( is => 'ro' );
has 'default_headers'    => ( is => 'ro' );
has 'handle'             => ( is => 'lazy' );

#===================================
sub protocol     {'http'}
sub default_host {'http://localhost:9200'}
sub stringify    { shift->uri . '' }
#===================================

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);

    my $node = $params->{node}
        || { host => 'localhost', port => '9200' };

    unless ( ref $node eq 'HASH' ) {
        unless ( $node =~ m{^http(s)?://} ) {
            $node = ( $params->{use_https} ? 'https://' : 'http://' ) . $node;
        }
        if ( $params->{port} && $node !~ m{//[^/]+:\d+} ) {
            $node =~ s{(//[^/]+)}{$1:$params->{port}};
        }
        my $uri = URI->new($node);
        $node = {
            scheme   => $uri->scheme,
            host     => $uri->host,
            port     => $uri->port,
            path     => $uri->path,
            userinfo => $uri->userinfo
        };
    }

    my $host = $node->{host} || 'localhost';
    my $userinfo = $node->{userinfo} || $params->{userinfo} || '';
    my $scheme
        = $node->{scheme} || ( $params->{use_https} ? 'https' : 'http' );
    my $port
        = $node->{port}
        || $params->{port}
        || ( $scheme eq 'http' ? 80 : 443 );
    my $path = $node->{path} || $params->{path_prefix} || '';
    $path =~ s{^/?}{/}g;
    $path =~ s{/+$}{};

    my %default_headers = %{ $params->{default_headers} || {} };

    if ($userinfo) {
        require MIME::Base64;
        my $auth = MIME::Base64::encode_base64($userinfo);
        chomp $auth;
        $default_headers{Authorization} = "Basic $auth";
    }

    if ( $params->{deflate} ) {
        $default_headers{'Accept-Encoding'} = "deflate";
    }

    $params->{scheme}          = $scheme;
    $params->{is_http}         = $scheme eq 'https';
    $params->{host}            = $host;
    $params->{port}            = $port;
    $params->{path}            = $path;
    $params->{userinfo}        = $userinfo;
    $params->{uri}             = URI->new("$scheme://$host:$port$path");
    $params->{default_headers} = \%default_headers;

    return $params;

}

#===================================
sub build_uri {
#===================================
    my ( $self, $params ) = @_;
    my $uri = $self->uri->clone;
    $uri->path( $uri->path . $params->{path} );
    $uri->query_form( $params->{qs} );
    return $uri;
}

#===================================
before 'perform_request' => sub {
#===================================
    my ( $self, $params ) = @_;
    return unless defined $params->{data};

    my $max = $self->max_content_length
        or return;

    return if length( $params->{data} ) < $max;

    $self->logger->throw_error( 'ContentLength',
        "Body is longer than max_content_length ($max)",
    );
};

#===================================
around 'process_response' => sub {
#===================================
    my ( $orig, $self, $params, $code, $msg, $body, $encoding ) = @_;

    $body = $self->inflate($body)
        if $encoding && $encoding eq 'deflate';

    $orig->( $self, $params, $code, $msg, $body );
};

#===================================
sub inflate {
#===================================
    my $self    = shift;
    my $content = shift;

    my $output;
    require IO::Uncompress::Inflate;
    no warnings 'once';

    IO::Uncompress::Inflate::inflate( \$content, \$output, Transparent => 0 )
        or throw( 'Request',
        "Couldn't inflate response: $IO::Uncompress::Inflate::InflateError" );

    return $output;
}

1;

# ABSTRACT: Provides common functionality to HTTP Cxn implementations

__END__

=pod

=head1 NAME

Elasticsearch::Role::Cxn::HTTP - Provides common functionality to HTTP Cxn implementations

=head1 VERSION

version 0.74

=head1 DESCRIPTION

L<Elasticsearch::Role::Cxn::HTTP> provides common functionality to the Cxn
implementations which use the HTTP protocol. Cxn instances are created by a
L<Elasticsearch::Role::CxnPool> implentation, using the
L<Elasticsearch::Cxn::Factory> class.

This class does L<Elasticsearch::Role::Cxn>.

=head1 CONFIGURATION

The configuration options are as follows:

=head2 C<node>

A single C<node> is passed to C<new()> by the L<Elasticsearch::Cxn::Factory>
class.  It can either be a URI or a hash containing each part.  For instance:

    node => 'localhost';                    # equiv of 'http://localhost:80'
    node => 'localhost:9200';               # equiv of 'http://localhost:9200'
    node => 'http://localhost:9200';

    node => 'https://localhost';            # equiv of 'https://localhost:443'
    node => 'localhost/path';               # equiv of 'http://localhost:80/path'


    node => 'http://user:pass@localhost';   # equiv of 'http://localhost:80'
                                            # with userinfo => 'user:pass'

Alternatively, a C<node> can be specified as a hash:

    {
        scheme      => 'http',
        host        => 'search.domain.com',
        port        => '9200',
        path        => '/path',
        userinfo    => 'user:pass'
    }

Similarly, default values can be specified with C<port>, C<path_prefix>,
C<userinfo> and C<use_https>:

    $e = Elasticsearch->new(
        port        => 9201,
        path_prefix => '/path',
        userinfo    => 'user:pass',
        use_https   => 1,
        nodes       => [ 'search1', 'search2' ]
    )

=head2 C<max_content_length>

By default, Elasticsearch nodes accept a maximum post body of 100MB or
C<104_857_600> bytes. This client enforces that limit.  The limit can
be customised with the C<max_content_length> parameter (specified in bytes).

If you're using the L<Elasticsearch::CxnPool::Sniff> module, then the
C<max_content_length> will be automatically retrieved from the live cluster,
unless you specify a custom C<max_content_length>:

    # max_content_length retrieved from cluster
    $e = Elasticsearch->new(
        cxn_pool => 'Sniff'
    );

    # max_content_length fixed at 10,000 bytes
    $e = Elasticsearch->new(
        cxn_pool           => 'Sniff',
        max_content_length => 10_000
    );

=head2 C<deflate>

This client can request compressed responses from Elasticsearch by
enabling the C<http.compression> config setting in
L<Elasticsearch|http://www.elasticsearch.org/guide/reference/modules/http/>
and setting C<deflate> to C<true>:

    $e = Elasticsearch->new(
        deflate => 1
    );

=head1 METHODS

None of the methods listed below are useful to the user. They are
documented for those who are writing alternative implementations only.

=head2 C<scheme()>

    $scheme = $cxn->scheme;

Returns the scheme of the connection, ie C<http> or C<https>.

=head2 C<is_https()>

    $bool = $cxn->is_https;

Returns C<true> or C<false> depending on whether the C</scheme()> is C<https>
or not.

=head2 C<userinfo()>

    $userinfo = $cxn->userinfo

Returns the username and password of the cxn, if any, eg C<"user:pass">.
If C<userinfo> is provided, then a Basic Authorization header is added
to each request.

=head2 C<default_headers()>

    $headers = $cxn->default_headers

The default headers that are passed with each request.  This includes
the C<Accept-Encoding> header if C</deflate> is true, and the C<Authorization>
header if C</userinfo> has a value.

=head2 C<max_content_length()>

    $int = $cxn->max_content_length;

Returns the maximum length in bytes that the HTTP body can have.

=head2 C<build_uri()>

    $uri = $cxn->build_uri({ path => '/_search', qs => { size => 10 }});

Returns the HTTP URI to use for a particular request, combining the passed
in C<path> parameter with any defined C<path_prefix>, and adding the
query-string parameters.

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Elasticsearch BV.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
