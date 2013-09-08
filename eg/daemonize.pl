#!perl
use strict;
use warnings;
use D2;

my $d2 = D2->new(
    pidfile         =>  '/var/run/mydaemon.pid',
    as_username     =>  'root'
);

$d2->daemonize();
while(1){};
