#!/usr/bin/perl -w

use strict;
use Benchmark ();
use Getopt::Long ();

my $comparisons = 1000;
Getopt::Long::GetOptions(
	'count=i'  => \$comparisons,
);

my $str1 = 'a' x 10;
my $str2 = 'a' x 10000;

my $save;
Benchmark::cmpthese($comparisons, {
	short => sub { $save = length $str1; },
	long  => sub { $save = length $str2; },
});

=head

perl test-string-length.pl -c 1000000
(warning: too few iterations for a reliable count)
(warning: too few iterations for a reliable count)
Rate  long short
long  16666667/s    --  -33%
short 25000000/s   50%    --

perl test-string-length.pl -c 10000000
Rate  long short
long  21739130/s    --   -9%
short 23809524/s   10%    --

perl test-string-length.pl -c 100000000
Rate  long short
long  22779043/s    --   -2%
short 23148148/s    2%    --

=cut
