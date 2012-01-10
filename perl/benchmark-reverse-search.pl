use Benchmark qw{:all};

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

cmpthese(100000, {
	regex => sub { for (@strs) { my ($x1, $x2) = $_ =~ m#^(.*?)/?([^/]*)$# } },
	reverse => sub { for (@strs) {
		my ($x1, $x2) = reverse($_) =~ m#^([^/\\]*)[/\\]?(.*)$#;
		$x1 = reverse $x1;
		$x2 = reverse $x2;
	} },
})

