=head2
Simple but powerful daemon tools
Name: D2 is Daemon2.
Use that module instead of Daemonize.pm.
Previous version of daemon was ugly.
Daemonize.pm deprecated from now(27.08.2013 22:26)
=cut
package D2;
use strict;
use warnings;
use POSIX;
use Carp;
our $VERSION = 0.02;

# simple constructor
sub new {
    my $class = shift;
    my $params;
    if (ref $_[0] eq 'HASH') {
        $params = shift;
    }
    else {
        my %p = @_;
        $params = \%p;
    }
    my $self = {};
    bless $self, $class;
    $self->init($params);
    return $self;
}
sub init {
    my ($self, $params) = @_;
    $self->{PARENT_ENV} = \%ENV;
    if ($params->{as_username} && exists $params->{as_userid}) {
        croak 'cant serve username and userid at once';
    }
    if ($params->{as_username}) {
        $self->check_as_username($params->{as_username});
        $self->{as_username} = $params->{as_username};
    }
    if (exists $params->{as_userid}) {
        $self->check_as_userid($params->{as_userid});
        $self->{as_userid} = $params->{as_userid};
    }
    if ($self->{need_setuid}) {
        setuid($self->{setuid})
    }
    if ($params->{pidfile}) {
        $self->check_pidfile($params->{pidfile}) or croak 'Error pidfile';
        $self->{pidfile} = $params->{pidfile};
        $self->{pid} = 1;
    }
    if ($params->{forward_env} && ref $params->{forward_env} eq 'ARRAY') {
        $self->{forward_env} = $params->{forward_env};
    }
    if ($params->{set_env} && ref $params->{set_env} eq 'HASH') {
        $self->{set_env} = $params->{set_env};
    }
    if ($params->{debug}) {
        $self->{outputs_enabled} = 1;
    }
    $self->{initialized} = 1;
    return 1;
}
sub check_pidfile {
    my ($self, $pid) = @_;
    if (!-e($pid)) {
        open PID, ">>", $pid or croak qq/Can't create new pid file $pid/;
    }
    else {
        if (!-w($pid) || !-r($pid)) {
            carp qq/Can't read or write pid file $pid/;
            return 0;
        }
    }
    return 1;
}
sub check_as_username {
    my ($self, $name) = @_;
    my $wantuid = getpwnam($name);
    $self->check_as_userid($wantuid);
}
sub check_as_userid {
    my ($self, $userid) = @_;
    my $current_userid = $<;
    setuid($userid) or croak qq/Can't setuid $userid. User with that uid does not exists or permission denied/;
    setuid($current_userid);
    $self->{setuid} = $userid;
    $self->{need_setuid} = 1;
}
sub read_pid {
    my $self = shift;
    my $file = $self->{pidfile};
    open PID, $file or croak q/Can't read pid file/ . $file;
    my $content = join '', <PID>;
    close PID;
    return $content;
}
sub write_pid {
    my $self = shift;
    my $pid = $$;
    my $file = $self->{pidfile};
    open PID, '>', $file or croak q/Can't open pid file/;
    print PID $pid or croak q/Can't write pid file/;
    close PID;
    return 1;
}
sub check_pid {
    my $self = shift;
    my $file = $self->{pidfile};
    my $pid = $self->read_pid();
    if ($pid eq '') {
        return 1;
    }
    if (kill (0, $pid) == 1) {
        return 0;
    }
    return 1;
}
sub daemonize {
    my $self = shift;
    unless ($self->{initialized}) {
        croak 'cant call daemonize';
    }
    if ($self->{pid}) {
        croak "Already Alive" unless $self->check_pid();
    }
    chdir '/'                   or croak "Can't chdir to /: $!";
    unless($self->{outputs_enabled}) {
        open STDIN, '/dev/null'     or croak "Can't read /dev/null: $!";
        open STDOUT, '>>/dev/null'  or croak "Can't write to /dev/null: $!";
        open STDERR, '>>/dev/null'  or croak "Can't write to /dev/null: $!";
    }
    defined(my $pid = fork)     or croak "Can't fork: $!";
    exit if $pid;
    if ($self->{pid}) {
        $self->write_pid();
    }
    setsid                      or croak "Can't start a new session: $!";
    umask 0;
    if ($self->{forward_env}) {
        foreach my $env_key (@{$self->{forward_env}}) {
            $ENV{$env_key} = $self->{PARENT_ENV}->{$env_key};
        }
    }
    if ($self->{set_env}) {
        foreach my $env_key (keys %{$self->{set_env}}) {
            $ENV{$env_key} = $self->{set_env}->{$env_key};
        }
    }
    return $$;
}

1;
