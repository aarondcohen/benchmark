use strict;
use Benchmark qw{:all};
use List::MoreUtils ();

my $count = shift @ARGV || 10000;

=head

Conclusions:
 - hash autovivification via undef is a clear winner (faster and less memory)
 - it is a surprise that undef in a for-loop is faster than List::MoreUtils's XS implementation
 - test this benchmark in other environments to see if the results hold
 - assigning to the results of a map has repeatedly been a poor performer

=cut

#my @arr = map { [map { rand(100) } (1 .. 23)] } (1 .. 23);
#my @arr = map { [map { rand(100) } (1 .. 347)] } (1 .. 23);
my @arr = map { [map { rand(100) } (1 .. 1009)] } (1 .. 23);

my $counter = 0;
sub get_next{ $arr[ $counter++ % @arr ] }

#print 'Is testing against XS: ', List::MoreUtils::_XScompiled(), "\n";

cmpthese(10000, {
  hash_coerce => sub { my %hash; undef @hash{@{get_next()}}; return keys %hash },
  hash_map    => sub { my %hash = map { ($_ => undef) } @{get_next()}; return keys %hash },
  hash_for    => sub { my %hash; undef $hash{$_} for @{get_next()}; return keys %hash },
  list_uniq   => sub { List::MoreUtils::uniq(@{get_next()}) },
});

=head

perl benchmark-set-uniq.pl 10000

               Rate    hash_map   list_uniq    hash_for hash_coerce
hash_map    1337/s          --        -40%        -53%        -63%
list_uniq   2242/s         68%          --        -22%        -38%
hash_for    2857/s        114%         27%          --        -21%
hash_coerce 3623/s        171%         62%         27%          --

=cut
