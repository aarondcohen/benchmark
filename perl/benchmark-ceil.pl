use Benchmark qw{:all};
use POSIX ();

my $count = shift @ARGV || 10000000;

my $num = 314617573;
my $den = 2894;

=head
Conclusion:
 - don't roll your own ceiling
 - but if you must, div and mod on the stack wins
=cut


=head

perl benchmark-ceil.pl 50000000

                     Rate ceil_mod_save ceil_trunc_save ceil_trunc ceil_mod posix_ceil
ceil_mod_save   1151543/s            --            -42%       -43%     -46%       -60%
ceil_trunc_save 1986492/s           73%              --        -2%      -7%       -31%
ceil_trunc      2021019/s           76%              2%         --      -6%       -29%
ceil_mod        2139495/s           86%              8%         6%       --       -25%
posix_ceil      2858776/s          148%             44%        41%      34%         --

=cut


sub ceil_mod        { int($_[0] / $_[1]) + ($_[0] % $_[1] > 0) }
sub ceil_mod_save   { my ($n, $d) = @_; int($n / $d) + ($n % $d > 0) }
sub ceil_trunc      { my $res = $_[0] / $_[1]; int($res) + (int($res) != $res) }
sub ceil_trunc_save { my $res = $_[0] / $_[1]; my $trunc = int($res); $trunc + ($trunc != $res) }
sub posix_ceil      { POSIX::ceil($_[0]/$_[1]) }

for my $func_name (qw{
	ceil_mod
	ceil_mod_save
	ceil_trunc
	ceil_trunc_save
	posix_ceil
}) {
	my $res = &$func_name($num, $den);
	printf "%-15s value: %f\n", $func_name, $res;
}

cmpthese($count, {
	ceil_mod        => sub { ceil_mod($num, $den) },
	ceil_mod_save   => sub { ceil_mod_save($num, $den) },
	ceil_trunc      => sub { ceil_trunc($num, $den) },
	ceil_trunc_save => sub { ceil_trunc_save($num, $den) },
	posix_ceil      => sub { posix_ceil($num, $den) },
});

