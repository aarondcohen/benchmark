#!/usr/bin/perl -w

=head

perl test-string-head-tail.pl -c 10000000 -l 5
            Rate substr  split
substr 1572327/s     --   -22%
split  2028398/s    29%     --

perl test-string-head-tail.pl -c 10000000 -l 10
            Rate substr  split
substr 1562500/s     --   -22%
split  1996008/s    28%     --

perl test-string-head-tail.pl -c 10000000 -l 20
            Rate substr  split
substr 1620746/s     --   -24%
split  2118644/s    31%     --

perl test-string-head-tail.pl -c 10000000 -l 100
            Rate substr  split
substr 1449275/s     --   -16%
split  1721170/s    19%     --

perl test-string-head-tail.pl -c 10000000 -l 1000
            Rate substr  split
substr 1047120/s     --   -12%
split  1196172/s    14%     --

perl test-string-head-tail.pl -c 10000000 -l 10000
           Rate substr  split
substr 243487/s     --   -30%
split  346620/s    42%     --

=cut

use strict;
use Benchmark ();
use Getopt::Long ();

my $comparisons = 1000;
my $length = 100;
Getopt::Long::GetOptions(
	'count=i'  => \$comparisons,
	'length=i' => \$length,
);

my $str = 'a' x $length;

Benchmark::cmpthese($comparisons, {
	split  => sub { my ($head, $tail) = split(//, $str, 2) },
	substr => sub { my ($head, $tail) = (substr($str, 0, 1), substr($str, 1)) },
});
