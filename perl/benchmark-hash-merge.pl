use strict;
use Benchmark qw{:all};

my $count = shift @ARGV || 100000;

=head

Conclusions:
 - autovivification is both the fastest and wouldn't require an extra hash
 - iteration for merge is way more verbose with no gain in speed or space used

=cut

=head

perl benchmark-hash-merge.pl 50000

                         Rate merge_iteration merge_assignment merge_autovivification
merge_iteration        2258/s              --             -34%                   -39%
merge_assignment       3432/s             52%               --                    -8%
merge_autovivification 3720/s             65%               8%                     --

=cut

my %hash1 = map {($_ => rand(1000))} (1 .. 347);
my %hash2 = map {(2 * $_ => rand(1000))} (1 .. 347);

sub merge_assignment       { my %hash = (%{$_[0]}, %{$_[1]}); %hash }
sub merge_autovivification { my %hash = %{$_[0]}; @hash{keys %{$_[1]}} = values %{$_[1]}; %hash }
sub merge_iteration        { my %hash = %{$_[0]}; while (my ($k, $v) = each %{$_[1]}) { $hash{$k} = $v }; %hash}

cmpthese($count, {
	merge_assignment       => sub { merge_assignment(\%hash1, \%hash2) },
	merge_autovivification => sub { merge_autovivification(\%hash1, \%hash2) },
	merge_iteration        => sub { merge_iteration(\%hash1, \%hash2) },
})


