use strict;
use Benchmark qw{:all};

#my @arr = map { [map { rand(100) } (1 .. 23)] } (1 .. 23);
my @arr = map { [map { rand(100) } (1 .. 347)] } (1 .. 23);
#my @arr = map { [map { rand(100) } (1 .. 1009)] } (1 .. 23);

my $id = sub { $_[0] };

my $counter = 0;
sub get_next{ $arr[ $counter++ % @arr ] }
sub get_rand{ $arr[ int(@arr * rand) ] }

cmpthese(10000, {
	'autoviv' => sub { my $lhs = get_next(); my %set; @set{ map { $id->($_) } @$lhs } = @$lhs },
	'element' => sub { my %set; $set{$id->($_)} = $_ for @{get_next()} },
	'map'     => sub { my %set = map { ($id->($_) => $_) } @{get_next()} },
});



