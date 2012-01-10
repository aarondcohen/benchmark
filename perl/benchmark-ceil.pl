use Benchmark qw{:all};

my $num = 314617573;
my $den = 2894;

cmpthese(10000000, {
	ceil_mod        => sub { int($num / $den) + ($num % $den > 0) },
	ceil_trunc      => sub { my $res = $num / $den; int($res) + (int($res) != $res) },
	ceil_trunc_save => sub { my $res = $num / $den; my $trunc = int($res); $trunc + ($trunc != $res) },
});

