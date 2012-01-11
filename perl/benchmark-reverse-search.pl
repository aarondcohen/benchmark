use Benchmark qw{:all};

my $count = shift @ARGV || 100000;

=head

Conclusions:
 - a tight anchor at the front will outperform a wildcard
 - reversing a string and captures to optimize the regex is worth considering

=cut

=head

perl benchmark-reverse-search.pl 100000
           Rate   regex reverse
regex   30120/s      --    -43%
reverse 52632/s     75%      --

=cut

my $str = 'adgasdgasdga';
my @strs = (
'~/home/aaron',
'/root/daytime/',
'troubles-in-paradise',
'more/trouble',
'even/more/',
'/',
'tried/and/true/hello.mhtml',
'd.mhtml',
'.hi'
);

cmpthese($count, {
	regex => sub { for (@strs) { my ($x1, $x2) = $_ =~ m#^(.*?)/?([^/]*)$# } },
	reverse => sub { for (@strs) {
		my ($x1, $x2) = reverse($_) =~ m#^([^/\\]*)[/\\]?(.*)$#;
		$x1 = reverse $x1;
		$x2 = reverse $x2;
	} },
})

