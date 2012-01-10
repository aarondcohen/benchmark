#!/usr/bin/perl -w

=head

perl test-string-traversal.pl -c 10000000 -l 5
           Rate  split substr
split  665336/s     --   -13%
substr 765697/s    15%     --

perl test-string-traversal.pl -c 1000000 -l 10
           Rate  split substr
split  383142/s     --   -20%
substr 476190/s    24%     --

perl test-string-traversal.pl -c 1000000 -l 100
          Rate  split substr
split  44170/s     --   -24%
substr 58106/s    32%     --

perl test-string-traversal.pl -c 10000000 -l 10
           Rate  split substr
split  361925/s     --   -25%
substr 483559/s    34%     --

perl test-string-traversal.pl -c 10000000 -l 20
           Rate  split substr
split  210305/s     --   -22%
substr 269251/s    28%     --

perl test-string-traversal.pl -c 1000000 -l 100
           Rate capture   match   split  substr
capture 25432/s      --     -0%    -44%    -57%
match   25491/s      0%      --    -44%    -57%
split   45269/s     78%     78%      --    -23%
substr  58685/s    131%    130%     30%      --


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

my $save;
Benchmark::cmpthese($comparisons, {
	'capture' => sub { while ($str =~ /(.)/g) { $save = $1; } },
	'match'   => sub { while ($str =~ /./g) { $save = substr $str, pos($str), 1; } },
	'split'   => sub { for (split //, $str) { $save = $_; } },
	'substr'  => sub {
		my $end = length $str;
		for (my $pos=0; $pos < $end; ++$pos) {
			$save = substr $str, $pos, 1;
		}
	},
});
