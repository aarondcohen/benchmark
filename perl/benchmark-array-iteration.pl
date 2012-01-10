use Benchmark qw{:all};

my @arr = (1 .. 10003);

=head

perl benchmark-array-iteration.pl 
                       Rate map_range for_index for_index_cache_size for_range for_baseline map_baseline
map_range             628/s        --      -15%                 -31%      -32%         -58%         -62%
for_index             738/s       18%        --                 -18%      -20%         -51%         -55%
for_index_cache_size  903/s       44%       22%                   --       -3%         -40%         -45%
for_range             927/s       48%       26%                   3%        --         -38%         -43%
for_baseline         1495/s      138%      103%                  65%       61%           --          -9%
map_baseline         1634/s      160%      121%                  81%       76%           9%           --

=cut

sub for_baseline         { for (@_) { $_ } }
sub for_index            { for (my $i=0; $i<@_; ++$i) { $_[$i] } }
sub for_index_cache_size { for (my ($i,$len) = (0, scalar @_); $i<$len; ++$i) { $_[$i] } }
sub for_range            { for (0 .. $#_) { $_[$_] } }
sub map_baseline         { map { $_ } @_ }
sub map_range            { map { $_[$_] } (0 .. $#_) }

=head

perl benchmark-array-iteration.pl 
                       Rate map_range for_index for_index_cache_size for_range for_baseline map_baseline
map_range             522/s        --       -8%                 -20%      -21%         -44%         -52%
for_index             566/s        8%        --                 -14%      -14%         -39%         -48%
for_index_cache_size  655/s       26%       16%                   --       -0%         -30%         -39%
for_range             657/s       26%       16%                   0%        --         -30%         -39%
for_baseline          933/s       79%       65%                  42%       42%           --         -14%
map_baseline         1081/s      107%       91%                  65%       64%          16%           --

=cut

=head
sub for_baseline         { my $total=0; for (@_) { $total += $_ }; $total }
sub for_index            { my $total=0; for (my $i=0; $i<@_; ++$i) { $total += $_[$i] }; $total }
sub for_index_cache_size { my $total=0; for (my ($i,$len) = (0, scalar @_); $i<$len; ++$i) { $total += $_[$i] }; $total }
sub for_range            { my $total=0; for (0 .. $#_) { $total += $_[$_] }; $total }
sub map_baseline         { my $total=0; map { $total += $_ } @_; $total }
sub map_range            { my $total=0; map { $total += $_[$_] } (0 .. $#_); $total }

do {
	local $\ ="\n";
	local $| = 1;

	print 'for_baseline total: '         . for_baseline(@arr);
	print 'for_index total: '            . for_index(@arr);
	print 'for_index_cache_size total: ' . for_index_cache_size(@arr);
	print 'for_range total: '            . for_range(@arr);
	print 'map_baseline total: '         . map_baseline(@arr);
	print 'map_range total: '            . map_range(@arr);
};
=cut

cmpthese(10000, {
 for_baseline         => sub { for_baseline(@arr) },
 for_index            => sub { for_index(@arr) },
 for_index_cache_size => sub { for_index_cache_size(@arr) },
 for_range            => sub { for_range(@arr) },
 map_baseline         => sub { map_baseline(@arr) },
 map_range            => sub { map_range(@arr) },
});

