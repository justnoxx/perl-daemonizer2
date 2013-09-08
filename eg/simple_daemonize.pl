#!perl
use strict;
use D2;
my $d2 = D2->new();
$d2->daemonize();
# infinite loop, just for test
while(1){};
