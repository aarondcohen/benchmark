use strict;
use Benchmark qw{:all};

my %hash1 = map {($_ => rand(1000))} (1 .. 347);
my %hash2 = map {(2 * $_ => rand(1000))} (1 .. 347);

cmpthese(100000, {
  new   => sub { my %hash = %hash1; %hash = (%hash, %hash2); %hash },
  each  => sub { my %hash = %hash1; while (my ($k, $v) = each %hash2) { $hash{$k} = $v }; %hash },
  array => sub { my %hash = %hash1; @hash{keys %hash2} = values %hash2; %hash },
})


