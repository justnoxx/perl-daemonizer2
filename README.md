perl-daemonizer2
================

## What is this

This is perl module for easy daemonization of perl scripts on Linux systems only.

## Why it was created?

Proc::Daemon is cool module, that provides many useful stuff, but it heavy, because it compatible and universal.
This module is not so universal, it works fine under linux only, so it easy, fast and powerful.
It has not any external dependencies(POSIX and Carp are standard perl modules).

Disro named D2, Because D1(it was internal) was ugly, shitty, complicated, and not ready to be public, so I decided completely rewrite it.

## Installation
Do as root:

    perl Makefile.PL
    make
    make install

## Usage
### Importing
For complete examples see eg folder.
At first you need import module(D2).
    use D2;

### Methods

At now D2 support next methods:

#### new
New method - constructor for D2 object.
There are none required params, so it can be called as
    
    my $d2 = D2->new();

Possible params:

*pidfile* - absolute path to pidfile of daemon. If it can't be accessed or created D2 will croak in new() call.

*as_username* - username, behalf of daemonization will started. If impossible, D2 will croak in new() call. Also supports username:usergroup syntax.

*as_uid* - see *as_username*, but uses uid as param(0 for root, for example). as\_uid and as\_username can't be present at once.

*debug* - 1 or 0, default 0. If enabled, STDIN, STDOUT, STDERR will not be send to /dev/null.

*SIG* - hashref of signal handlers. Usage example see in eg folder.


New accepts hash and hashref. Example:

    my $d2 = D2->new(
        pidfile     =>  '/var/run/mydaemon.pid',
        as_username =>  'root',
    );

#### daemonize
After new() call you can daemonize.
Use daemonize without params.

    $d2->daemonize();

See complete examples in eg folder.

