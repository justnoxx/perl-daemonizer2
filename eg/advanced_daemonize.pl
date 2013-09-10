#!perl
use strict;
use POSIX;
use D2;
my $d2 = D2->new(
    pidfile         =>  '/var/run/mydaemon.pid',
    as_uid          =>  'root:root',
    debug           =>  1
);
$d2->daemonize();
while(1) {};
