use Benchmark qw{:all};

my $count = shift @ARGV || 100000;

my $str = 'adgasdgasdga';
my @strs = (
	(' ' x 100) . $str . (' ' x 100),
	(' ' x   0) . $str . (' ' x 100),
	(' ' x 100) . $str . (' ' x   0),
	(' ' x  50) . $str . (' ' x  50),
	(' ' x 100) . $str . (' ' x  50),
	(' ' x  50) . $str . (' ' x 100),
	(' ' x   1) . $str . (' ' x   0),
	(' ' x   0) . $str . (' ' x   1),
	(' ' x   1) . $str . (' ' x   1),
	(' ' x   0) . $str . (' ' x   0),
);

cmpthese($count, {
	left_right_sep      => sub { map { my $copy = $_; $copy =~ s/^\s*//; $copy =~ s/\s*$// } @strs },
	right_left_sep      => sub { map { my $copy = $_; $copy =~ s/\s*$//; $copy =~ s/^\s*// } @strs },
	left_reverse_left   => sub { map { my $copy = $_; $copy =~ s/^\s*//; $copy = reverse $copy; $copy =~ s/^\s*//; reverse $copy } @strs },
	right_reverse_right => sub { map { my $copy = $_; $copy =~ s/\s*$//; $copy = reverse $copy; $copy =~ s/\s*$//; reverse $copy } @strs },
	left_right_sim      => sub { map { my $copy = $_; $copy =~ s/^\s*|\s*$// } @strs },
	right_left_sim      => sub { map { my $copy = $_; $copy =~ s/\s*$|^\s*// } @strs },
})

