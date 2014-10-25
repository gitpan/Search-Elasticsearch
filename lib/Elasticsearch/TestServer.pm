package Elasticsearch::TestServer;
{
  $Elasticsearch::TestServer::VERSION = '0.75';
}

use Moo;
use Elasticsearch();
use POSIX 'setsid';
use File::Temp();
use IO::Socket();
use HTTP::Tiny;

use Elasticsearch::Util qw(parse_params throw);
use namespace::clean;

has 'es_home'   => ( is => 'ro', required => 1 );
has 'instances' => ( is => 'ro', default  => 1 );
has 'http_port' => ( is => 'ro', default  => 9600 );
has 'es_port'   => ( is => 'ro', default  => 9700 );
has 'pids'      => ( is => 'ro', default  => sub { [] }, clearer => 1 );
has 'dir'       => ( is => 'ro', clearer  => 1 );

#===================================
sub start {
#===================================
    my $self = shift;

    my $home = $self->es_home
        or throw( 'Param', "Missing required param <es_home>" );
    my $instances = $self->instances;
    my $port      = $self->http_port;
    my $es_port   = $self->es_port;
    my @http      = map { $port++ } ( 1 .. $instances );
    my @transport = map { $es_port++ } ( 1 .. $instances );

    $self->_check_ports( @http, @transport );

    my $old_SIGINT = $SIG{INT};
    $SIG{INT} = sub {
        $self->shutdown;
        if ( ref $old_SIGINT eq 'CODE' ) {
            return $old_SIGINT->();
        }
        exit(1);
    };

    my $dir = File::Temp->newdir();
    for ( 0 .. $instances - 1 ) {
        print "Starting node: http://127.0.0.1:$http[$_]\n";
        $self->_start_node( $dir, $transport[$_], $http[$_] );
    }

    $self->_check_nodes(@http);
    return [ map {"http://127.0.0.1:$_"} @http ];
}

#===================================
sub _check_ports {
#===================================
    my $self = shift;
    for my $port (@_) {
        next unless IO::Socket::INET->new("127.0.0.1:$port");
        throw( 'Param',
                  "There is already a service running on 127.0.0.1:$port. "
                . "Please shut it down before starting the test server" );
    }
}

#===================================
sub _check_nodes {
#===================================
    my $self = shift;
    my $http = HTTP::Tiny->new;
    for my $node (@_) {
        print "Checking node: http://127.0.0.1:$node\n";
        my $i = 20;
        while (1) {
            last
                if $http->head("http://127.0.0.1:$node/")->{status} == 200;
            throw( 'Cxn', "Couldn't connect to http://127.0.0.1:$node" )
                unless $i--;
            sleep 1;
        }

    }
}

#===================================
sub _start_node {
#===================================
    my ( $self, $dir, $transport, $http ) = @_;

    my $pid_file = File::Temp->new;
    my @config = $self->_command_line( $pid_file, $dir, $transport, $http );

    my $int_caught = 0;
    {
        local $SIG{INT} = sub { $int_caught++; };
        defined( my $pid = fork )
            or throw( 'Internal', "Couldn't fork a new process: $!" );
        if ( $pid == 0 ) {
            throw( 'Internal', "Can't start a new session: $!" )
                if setsid == -1;
            exec(@config);
        }
        else {
            for ( 1 .. 5 ) {
                last if -s $pid_file->filename();
                sleep 1;
            }
            open my $pid_fh, '<', $pid_file->filename;
            my $pid = <$pid_fh>;
            throw( 'Internal', "ES is running, but no PID found" )
                unless $pid;
            chomp $pid;
            push @{ $self->{pids} }, $pid;
        }
    }
    $SIG{INT}->('INT') if $int_caught;
}

#===================================
sub shutdown {
#===================================
    my $self = shift;
    local $?;

    my $pids = $self->pids;
    $self->clear_pids;
    return unless @$pids;

    kill 9, @$pids;
    $self->clear_dir;
}

#===================================
sub _command_line {
#===================================
    my ( $self, $pid_file, $dir, $transport, $http ) = @_;

    return (
        $self->es_home . '/bin/elasticsearch',
        '-p',
        $pid_file->filename,
        map {"-Des.$_"} (
            'path.data=' . $dir,
            'network.host=127.0.0.1',
            'cluster.name=es_test',
            'discovery.zen.ping.multicast.enabled=false',
            'discovery.zen.ping_timeout=1s',
            'discovery.zen.ping.unicast.hosts=127.0.0.1:' . $self->es_port,
            'transport.tcp.port=' . $transport,
            'http.port=' . $http,
        )
    );
}

#===================================
sub DEMOLISH { shift->shutdown }
#===================================

1;

# ABSTRACT: A helper class to launch Elasticsearch nodes

__END__

=pod

=head1 NAME

Elasticsearch::TestServer - A helper class to launch Elasticsearch nodes

=head1 VERSION

version 0.75

=head1 SYNOPSIS

    use Elasticsearch;
    use Elasticsearch::TestServer;

    my $server = Elasticsearch::TestServer->new(
        es_home   => '/path/to/elasticsearch',
    );

    my $nodes = $server->start;
    my $es    = Elasticsearch->new( nodes => $nodes );
    # run tests
    $server->shutdown;

=head1 DESCRIPTION

The L<Elasticsearch::TestServer> class can be used to launch one or more
instances of Elasticsearch for testing purposes.  The nodes will
be shutdown automatically.

=head1 METHODS

=head2 C<new()>

    my $server = Elasticsearch::TestServer->new(
        es_home   => '/path/to/elasticsearch',
        instances => 1,
        http_port => 9600,
        es_port   => 9700,
    );

Params:

=over

=item * C<es_home>

Required. Must point to the Elasticsearch home directory, which contains
C<./bin/elasticsearch>.

=item * C<instances>

The number of nodes to start. Defaults to 1

=item * C<http_port>

The port to use for HTTP. If multiple instances are started, the C<http_port>
will be incremented for each subsequent instance. Defaults to 9600.

=item * C<es_port>

The port to use for Elasticsearch's internal transport. If multiple instances
are started, the C<es_port> will be incremented for each subsequent instance.
Defaults to 9700

=back

=head1 C<start()>

    $nodes = $server->start;

Starts the required instances and returns an array ref containing the IP
and port of each node, suitable for passing to L<Elasticsearch/new()>:

    $es = Elasticsearch->new( nodes => $nodes );

=head1 C<shutdown()>

    $server->shutdown;

Kills the running instances.  This will be called automatically when
C<$server> goes out of scope or if the program receives a C<SIGINT>.

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Elasticsearch BV.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
