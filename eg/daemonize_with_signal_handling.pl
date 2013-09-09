#!perl
use strict;
use D2;
my $d2 = D2->new(
    SIG     =>  {
        INT     =>  \&intcatcher,
        TERM    =>  sub {print 'termitating...'; exit 1;},
    },
    debug   =>  1,
);
$d2->daemonize();
while (1) {};
sub intcatcher {
    print 'Someone send me a INT signal. Exiting';
    exit 1;
}
