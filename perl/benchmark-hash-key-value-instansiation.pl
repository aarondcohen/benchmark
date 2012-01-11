use strict;
use Benchmark qw{:all};

my $count = shift @ARGV || 10000;

=head

Conclusions:
 - autovivification has a slight speed edge
 - looping across the objects to key on a value is the real bottleneck

=cut

#my @arr = map { [map { rand(100) } (1 .. 23)] } (1 .. 23);
my @arr = map { [map { rand(100) } (1 .. 347)] } (1 .. 23);
#my @arr = map { [map { rand(100) } (1 .. 1009)] } (1 .. 23);

my $id = sub { $_[0] };

my $counter = 0;
sub get_next{ $arr[ $counter++ % @arr ] }
sub get_rand{ $arr[ int(@arr * rand) ] }

=head

perl benchmark-hash-key-value-instansiation.pl 10000

          Rate     map element autoviv
map     1236/s      --     -3%     -7%
element 1269/s      3%      --     -4%
autoviv 1326/s      7%      5%      --

=cut

cmpthese($count, {
	'autoviv' => sub { my $lhs = get_next(); my %set; @set{ map { $id->($_) } @$lhs } = @$lhs },
	'element' => sub { my %set; $set{$id->($_)} = $_ for @{get_next()} },
	'map'     => sub { my %set = map { ($id->($_) => $_) } @{get_next()} },
});



