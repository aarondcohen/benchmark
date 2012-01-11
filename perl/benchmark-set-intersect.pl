use strict;
use Benchmark qw{:all};

my $count = shift @ARGV || 10000;

#my @arr = map { [map { rand(100) } (1 .. 23)] } (1 .. 23);
#my @arr = map { [map { rand(100) } (1 .. 347)] } (1 .. 23);
my @arr = map { [map { rand(100) } (1 .. 1009)] } (1 .. 23);

=head

perl benchmark-set-intersect.pl 10000

                        Rate intersection_slice intersection_counter intersection_subtract intersection_slice2 intersection_delete intersection_grep
intersection_slice     716/s                 --                 -10%                  -20%                -42%                -43%              -69%
intersection_counter   797/s                11%                   --                  -11%                -36%                -36%              -65%
intersection_subtract  894/s                25%                  12%                    --                -28%                -29%              -61%
intersection_slice2   1238/s                73%                  55%                   38%                  --                 -1%              -46%
intersection_delete   1250/s                74%                  57%                   40%                  1%                  --              -45%
intersection_grep     2288/s               219%                 187%                  156%                 85%                 83%                --

                              Rate intersection_counter intersection_delete intersection_subtract_multi intersection_grep_multi
intersection_counter         335/s                   --                -45%                        -50%                    -95%
intersection_delete          609/s                  82%                  --                        -10%                    -91%
intersection_subtract_multi  676/s                 102%                 11%                          --                    -90%
intersection_grep_multi     6944/s                1974%               1041%                        927%                      --

                              Rate intersection_delete_fn intersection_grep_defined_fn intersection_grep_exists_fn
intersection_delete_fn       239/s                     --                         -54%                        -54%
intersection_grep_defined_fn 514/s                   115%                           --                         -1%
intersection_grep_exists_fn  521/s                   118%                           1%                          --


#TODO: Why the drop off?
perl benchmark-set-intersect.pl 10000

                               Rate intersection_delete_fn intersection_grep_exists_fn intersection_grep_defined_fn intersection_grep_exists_fn3 intersection_grep_exists_fn2
intersection_delete_fn       91.9/s                     --                        -57%                         -58%                         -60%                         -60%
intersection_grep_exists_fn   214/s                   133%                          --                          -1%                          -6%                          -6%
intersection_grep_defined_fn  217/s                   136%                          1%                           --                          -5%                          -5%
intersection_grep_exists_fn3  228/s                   148%                          6%                           5%                           --                          -0%
intersection_grep_exists_fn2  228/s                   148%                          6%                           5%                           0%                           --

=cut

sub subtract(@) {
  my %set;
	my $lhs = shift;
  undef @set{@$lhs} if @$lhs;
	do { delete @set{@$_} if @$_ } for @_;
  return keys %set;
}

my $id = sub { $_[0] };

my $counter = 0;
sub get_next(){ $arr[ $counter++ % @arr ] }
sub get_rand(){ $arr[ int(@arr * rand) ] }

############################################

sub intersection_counter {
	my $size = @_;
	my %hash;
	do { ++$hash{$_} for @$_ } for (@_);
	return grep { $hash{$_} == $size } keys %hash;
}

sub intersection_delete(@) {
	my $first = shift;

	do { return unless @$_ } for @_;

	my (%set, %other_set);

	undef @set{@$first};

	for (@_) {
		undef @other_set{@$_};
		delete @set{grep { ! exists $other_set{$_} } keys %set};
		#return unless keys %set;
		%other_set = ();
	}

	return keys %set;
}

sub intersection_delete_fn(&@) {
	my $func = shift;
	my $first = shift;

	do { return unless @$_ } for @_;

	my (%set, %other_set);

	@set{ map { $func->($_) } @$first } = @$first;

	for (@_) {
		undef @other_set{map { $func->($_) } @$_};
		delete @set{grep { ! exists $other_set{$_} } keys %set};
		#return unless keys %set;
		%other_set = ();
	}

	return values %set;
}

sub intersection_grep {
	my %set;
	undef @set{@{$_[0]}};
	return grep { exists $set{$_} } @{$_[1]};
}

sub intersection_grep_defined_fn(&@) {
	my $func = shift;
	my $lhs = shift;

	return unless $lhs && @$lhs;

	my @int;
	my %set;
	@set{ map { $func->($_) } @$lhs } = @$lhs;

	for (@_) {
		@int = grep { defined } @set{ map { $func->($_) } @$_ };
		return unless @int;
		undef %set;
		@set{ map { $func->($_) } @int } = @int;
	}
	return keys %set;
}

sub intersection_grep_exists_fn(&@) {
	my $func = shift;
	my $lhs = shift;

	return unless $lhs && @$lhs;

	my %set;
	@set{ map { $func->($_) } @$lhs } = @$lhs;

	for (@_) {
		my @int = grep { exists $set{$func->($_)} } @$_;
		return unless @int;
		undef %set;
		@set{ map { $func->($_) } @int } = @int;
	}
	return keys %set;
}

sub intersection_grep_exists_fn2(&@) {
	my $func = shift;
	my $lhs = shift;

	return unless $lhs && @$lhs;

	my %set;
	@set{ map { $func->($_) } @$lhs } = @$lhs;

	for (@_) {
		my @int = map {
			my $val = $func->($_);
			exists $set{$val} ? ($val => $_) : ()
		} @$_;
		return unless @int;
		%set = @int;
	}
	return keys %set;
}

sub intersection_grep_exists_fn3(&@) {
	my $func = shift;
	my $lhs = shift;

	return unless $lhs && @$lhs;

	my %set;
	@set{ map { $func->($_) } @$lhs } = @$lhs;

	for (@_) {
		%set = map {
			my $val = $func->($_);
			exists $set{$val} ? ($val => $_) : ()
		} @$_;
		return unless keys %set;
	}
	return keys %set;
}

sub intersection_grep_multi {
	my %set;
	undef @set{shift @_};
	for (@_) {
		my @int = grep { exists $set{$_} } @$_;
		return unless @int;
		undef %set;
		undef @set{@int};
	}
	return keys %set;
}

#Notes:
# - uses map assignment which has been show to be a bad pattern
# - uses 2-stage filter
sub intersection_slice {
	my %set = map { ($_ => \$_) } @{$_[0]};
	return map { $$_ } grep { defined } @set{@{$_[1]}};
}

sub intersection_slice2 {
	my %set;
	@set{@{$_[0]}} = \(@{$_[0]});
	return map { defined $_ ? $$_ : () } @set{@{$_[1]}};
}

sub intersection_subtract {
	my @only_a = subtract(@_);
	return subtract($_[0], \@only_a);
}

sub intersection_subtract_multi {
	my $lhs = shift;
	do {
		my @lhs_only = subtract($lhs, $_);
		my @int = subtract($lhs, \@lhs_only);
		$lhs = \@int;
	} for (@_);
	return @$lhs;
}

=head

cmpthese($count, {
	intersection_counter  => sub { intersection_counter(get_next, get_rand) },
	intersection_delete   => sub { intersection_delete(get_next, get_rand) },
	intersection_grep     => sub { intersection_grep(get_next, get_rand) },
	intersection_slice    => sub { intersection_slice(get_next, get_rand) },
	intersection_slice2   => sub { intersection_slice2(get_next, get_rand) },
	intersection_subtract => sub { intersection_subtract(get_next, get_rand) },
});

cmpthese($count, {
	intersection_counter        => sub { intersection_counter(get_next, get_rand, get_rand, get_rand, get_rand) },
	intersection_delete         => sub { intersection_delete(get_next, get_rand, get_rand, get_rand, get_rand) },
	intersection_grep_multi     => sub { intersection_grep_multi(get_next, get_rand, get_rand, get_rand, get_rand) },
	intersection_subtract_multi => sub { intersection_subtract_multi(get_next, get_rand, get_rand, get_rand, get_rand) },
});

=cut

cmpthese($count, {
	intersection_delete_fn       => sub { &intersection_delete_fn($id, get_next, get_rand, get_rand, get_rand, get_rand) },
	intersection_grep_defined_fn => sub { &intersection_grep_defined_fn($id, get_next, get_rand, get_rand, get_rand, get_rand) },
	intersection_grep_exists_fn  => sub { &intersection_grep_exists_fn($id, get_next, get_rand, get_rand, get_rand, get_rand) },
	intersection_grep_exists_fn2 => sub { &intersection_grep_exists_fn2($id, get_next, get_rand, get_rand, get_rand, get_rand) },
	intersection_grep_exists_fn3 => sub { &intersection_grep_exists_fn3($id, get_next, get_rand, get_rand, get_rand, get_rand) },
});
