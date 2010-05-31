#!/usr/bin/perl -w

# The parser assumes the format produced by César's unfolder!

@work = ();
%mtab = ();
read_unfolding($ARGV[0]);
find_initial_marking();
while ($#work >= 0) {
	$mark = shift @work;
	process($mark);
}

my $i = 0;
for my $m (sort (keys %mtab)) {
	print join (" ", split (/#/, $m)), "\n";
	$i++;
}
print STDERR " -- $i markings\n";
exit 0;

sub find_initial_marking {
	my @co = ();
	if ($init{"autodetect"}) {
		for my $c (@conds) {
			$init{$c} = 1 unless $indeg{$c};
		}
		delete $init{"autodetect"};
	}
	@co = keys %init;
	my $cmark = join("#",@co);
	my $pmark = join("#",sort(map {$label{$_}} @co));
	push @work,($cmark);
	$mtab{$pmark} = "";
	#print "Initial marking: $pmark\n";
}

sub process {
	my ($ocmark) = @_;
	my @oco = split(/#/,$ocmark);
	my %i = %indeg;
	my @fire = ();
	my %marked = ();

	#print join(" ",sort(map {$label{$_}} @oco))."\n";

	for my $c (@oco) {
		$marked{$c} = "";
		#print "Exploring $c, out is $out{$c}\n";
		next unless defined($out{$c});
		for my $e (split(/#/,$out{$c})) {
			$i{$e}--;
			if ($i{$e} == 0 && ! $cutoff{$e}) { push @fire, ($e); }
		}
	}

	for my $t (@fire) {
		my %nmarked = %marked;
		for my $c (split(/#/,$in{$t})) {
			delete $nmarked{$c};
		}
		for my $c (split(/#/,$out{$t})) {
			$nmarked{$c} = "";
		}
		my @nco = keys %nmarked;
		my $pmark = join("#",sort(map {$label{$_}} @nco));
		#print "  From ", join (" ", sort (map {$label{$_}} @oco)), " firing $t ($label{$t}) to @nco ($pmark)\n";
		next if defined($mtab{$pmark});
		$mtab{$pmark} = "";
		my $cmark = join("#",@nco);
		push @work,($cmark);
	}
}

sub error {
	my ($msg) = @_;
	print STDERR "$msg\n";
	exit 1;
}

sub read_unfolding {
	my ($file) = @_;
	%hco = ();
	%in = ();
	%out = ();
	%indeg = ();
	%init = ();
	open FD,$file;
	while (<FD>) {
		$init{"autodetect"} = 1 if /\* autodetect initial marking \*/;
		next if /\be0\b/;
		if (/^\s*([cp]\d*)\s*->\s*([et]\d*)/) {
			my ($co,$ev) = ($1,$2);
			$hco{$co} = "";
			$indeg{$ev}++;
			$out{$co} .= "#$ev";
			#print "file $file edge p>t $1 > $2\n";
			$in{$ev} .= "#$co" unless /arrowhead=none/;
		}
		if (/^\s*([et]\d*)\s*->\s*([cp]\d*);/) {
			my ($ev,$co) = ($1,$2);
			$hco{$co} = "";
			$indeg{$co}++;
			$out{$ev} .= "#$co";
			$in{$co} .= "#$ev";
			#print "file $file edge t>p $1 > $2\n";
		}
		if (/^\s*([cp]\d*)\s*.label="([^ :"]*)/) {
			my $c = $1;
			$hco{$1} = "";
			$label{$1} = $2;
			#print "file $file p $1 label $2\n";
			$init{$c} = 1 if (/\* initial \*/);
		}
		if (/^\s*([et]\d*)\s*.label="([^ :"]*)/) {
			$label{$1} = $2;
			#print "file $file t $1 label $2\n";
		}
		if (/^\s*(e\d*)\s.*shape=Msquare/) {
			$cutoff{$1} = 1;
			#print "file $file t $1 is a cutoff\n";
		}
	}
	close FD;
	@conds = keys %hco;
	for (keys %out) { $out{$_} = substr($out{$_},1); }
	for (keys %in) { $in{$_} = substr($in{$_},1); }
	for (keys %cont) { $cont{$_} = substr($cont{$_},1); }
	$cnr = @conds;
	@kl = keys %label;
	$enr = @kl - $cnr;
	print STDERR "Net at '$file';  $enr transitions/events, $cnr " .
			"places/conditions";
	print STDERR " (autodetecting initial marking)" if $init{"autodetect"};
	print STDERR "\n";
}

