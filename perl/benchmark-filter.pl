use Benchmark qw{:all};

my $count = shift @ARGV || 100000;
my @arr = map { $_ % 3 ? $_ : undef } 1 .. 1003;

=head

perl benchmark-filter.pl 100000

                   Rate filter_for_next filter_for_if    filter_map  filter_grep
filter_for_next  6173/s              --           -0%          -46%         -59%
filter_for_if    6173/s              0%            --          -46%         -59%
filter_map      11364/s             84%           84%            --         -24%
filter_grep     14925/s            142%          142%           31%           --

=cut

=head
sub filter_for_if   { my @results = (); for (@_) { push @results, $_ if defined $_ }; @results }
sub filter_for_next { my @results = (); for (@_) { next unless defined $_; push @results, $_ }; @results }
sub filter_grep     { grep { defined $_ } @_ }
sub filter_map      { map { defined $_ ? $_ : () } @_ }
=cut

=head

perl benchmark-filter.pl 100000

                  Rate filter_for_if filter_for_next   filter_grep    filter_map
filter_for_if   4990/s            --             -2%          -36%          -43%
filter_for_next 5076/s            2%              --          -35%          -42%
filter_grep     7776/s           56%             53%            --          -11%
filter_map      8764/s           76%             73%           13%            --

perl benchmark-filter.pl 100000

									Rate filter_for_next filter_for_if   filter_grep    filter_map
filter_for_next 5208/s              --           -6%          -33%          -41%
filter_for_if   5513/s              6%            --          -29%          -37%
filter_grep     7776/s             49%           41%            --          -12%
filter_map      8803/s             69%           60%           13%            --

=cut

sub filter_for_if   { my @results = (); for (@_) { push @results, $_ + 1 if defined $_ }; @results }
sub filter_for_next { my @results = (); for (@_) { next unless defined $_; push @results, $_ + 1}; @results }
sub filter_grep     { map { $_ + 1 } grep { defined $_ } @_ }
sub filter_map      { map { defined $_ ? $_ + 1: () } @_ }

for my $func_name (qw{
	filter_for_if
	filter_for_next
	filter_grep
	filter_map
}) {
	my @results = &$func_name(@arr);
	printf "%-15s size: %d defined: %d\n", $func_name, scalar @results, ! grep { ! defined $_ } @arr;
}

cmpthese($count, {
	filter_for_if   => sub { filter_for_if(@arr) },
	filter_for_next => sub { filter_for_next(@arr) },
	filter_grep     => sub { filter_grep(@arr) },
	filter_map      => sub { filter_map(@arr) },
});
