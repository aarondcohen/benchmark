use Benchmark qw{:all};

my @arr = (1 .. 10003);

=head
perl benchmark-array-clear.pl
                             Rate clear_map_undef clear_assign_undef_assign clear_empty_assign clear_assign_undef_resize clear_undef_resize clear_undef_assign clear_empty_resize
clear_map_undef            1678/s              --                      -78%               -78%                      -78%               -80%               -80%               -90%
clear_assign_undef_assign  7576/s            352%                        --                -0%                       -1%                -9%               -10%               -54%
clear_empty_assign         7576/s            352%                        0%                 --                       -1%                -9%               -10%               -54%
clear_assign_undef_resize  7634/s            355%                        1%                 1%                        --                -8%                -9%               -53%
clear_undef_resize         8333/s            397%                       10%                10%                        9%                 --                -1%               -49%
clear_undef_assign         8403/s            401%                       11%                11%                       10%                 1%                 --               -49%
clear_empty_resize        16393/s            877%                      116%               116%                      115%                97%                95%                 --

=cut

sub clear_empty_assign        { my $size = @_; @_ = (); undef $_[$size - 1]; @_}
sub clear_empty_resize        { my $size = @_; @_ = (); $#_ = $size - 1; @_}
sub clear_map_undef           { map { undef } @_ }
sub clear_assign_undef_assign { my $size = @_; @_ = undef; undef $_[$size - 1]; @_}
sub clear_assign_undef_resize { my $size = @_; @_ = undef; $#_ = $size - 1; @_}
sub clear_undef_assign        { my $size = @_; undef @_; undef $_[$size - 1]; @_}
sub clear_undef_resize        { my $size = @_; undef @_; $#_ = $size - 1; @_}

do {
	my @res;

	for my $func_name (qw{
		clear_empty_assign
		clear_empty_resize
		clear_map_undef
		clear_assign_undef_assign
		clear_assign_undef_resize
		clear_undef_assign
		clear_undef_resize
	}) {
		@res = &$func_name(@arr);
		printf "%-25s size: %d side_effects: %d empty:%d\n", $func_name, scalar @res, ! defined $arr[0], ! defined $res[0];
	}
};

cmpthese(10000, {
	clear_empty_assign        => sub { clear_empty_assign(@arr) },
	clear_empty_resize        => sub { clear_empty_resize(@arr) },
	clear_map_undef           => sub { clear_map_undef(@arr) },
	clear_assign_undef_assign => sub { clear_assign_undef_assign(@arr) },
	clear_assign_undef_resize => sub { clear_assign_undef_resize(@arr) },
	clear_undef_assign        => sub { clear_undef_assign(@arr) },
	clear_undef_resize        => sub { clear_undef_resize(@arr) },
});

