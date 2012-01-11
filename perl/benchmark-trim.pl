use Benchmark qw{:all};

my $count = shift @ARGV || 100000;

=head

Conclusions:
 - left_right_sim is the clear winner
 - a single pass is prefered
 - reversing the string is a reasonable approach to apply transforms to the back
 - it is always better to match front before back
 - number and position of match sites int he query string does not seem to affect results
 - mutation order is important

=cut

=head

perl benchmark-trim.pl 300000

                        Rate right_reverse_right right_left_sep left_right_sep left_reverse_left right_left_sim left_right_sim
right_reverse_right   8230/s                  --           -10%           -77%              -89%           -92%           -94%
right_left_sep        9096/s                 11%             --           -74%              -88%           -91%           -93%
left_right_sep       35629/s                333%           292%             --              -52%           -66%           -72%
left_reverse_left    74813/s                809%           722%           110%                --           -29%           -42%
right_left_sim      104895/s               1174%          1053%           194%               40%             --           -19%
left_right_sim      129310/s               1471%          1322%           263%               73%            23%             --

=cut

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

