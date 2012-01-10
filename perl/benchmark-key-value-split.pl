use strict;
use Benchmark qw{:all};

my %hash = map { (chr($_) => $_) } (0 .. 255);

cmpthese(10000, {
  while => sub { my (@keys, @values); while(my ($key, $value) = each %hash) { push @keys, $key; push @values, $value;} },
  values => sub { my (@keys, @values); my @keys = keys %hash; my @values = values %hash; },
  slice => sub { my (@keys, @values); my @keys = keys %hash; my @values = @hash{@keys}; },
})

