use Benchmark qw{:all};

my @arr = (1 .. 10003);

my $asize = @arr;
my @arr_size = (undef, $asize, undef);

sub access_backward { $arr_size[-2] }
sub access_forward  { $arr_size[1] }
sub cached          { $asize }
sub last_index      { $#_ + 1 }
sub size            { scalar @_ }

cmpthese(100000, {
	access_backward => sub { access_backward(@arr) },
	access_forward  => sub { access_forward(@arr) },
	cached          => sub { cached(@arr) },
	last_index      => sub { last_index(@arr) },
	size            => sub { size(@arr) },
});

