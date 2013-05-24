
use strict;

#
# figure out often included files
#



my $outdir = $ENV{MTOUTDIR};
my $rootdir = $ENV{ROOTDIR};


my $filelist = "$rootdir/makefilelist.txt";
my $dependencyMapFileTemp = "dependencymaptemp.txt";
my $dependencyMapFile = "dependencymap.txt";
my $linkerDependencyMapFile = "linkerdependencymap.txt";

my %dependencyMap = ();


my $indent = 0;
sub AddAllTargets($$$$)
{
	my ($target, $targets, $visited, $printit) = @_;

	$indent += 2;

	$$visited{$target} = $target;

	if ($dependencyMap{$target})
	{
		# it has dependencies
		my @depends = @{$dependencyMap{$target}};

		foreach (@depends)
		{
			if ($printit)
			{
				print " " x $indent;
				print "$_\n";
			}
			$$targets{$_} = $_;

			if (!$$visited{$_})
			{
				AddAllTargets($_, $targets, $visited, $printit);
			}
		}
	}
	$indent -= 2;
}

sub Calculate()
{
	my @counts;

	foreach my $file (keys %dependencyMap)
	{
		my %targets;
		my %visited;

		$indent = 0;
		AddAllTargets($file, \%targets, \%visited, 0);

		my @all = keys %targets;
		my $count = $#all + 1;

		my @objects = grep(/.obj$/, @all);
		my $objCount = $#objects + 1;

		my @headers = grep(/.h$/, @all);
		my $headerCount = $#headers + 1;

		my @record = ($count, $objCount, $headerCount, $file);
		push @counts, [ @record ];
		#print "$objCount\t$headerCount\t$file\n";
	}

	# sort descending by total count
	@counts = sort { @$b[0] <=> @$a[0] } @counts;

	foreach my $record (@counts)
	{
		my ($count, $objCount, $headerCount, $file) = @$record;
		print "$count\t$objCount\t$headerCount\t$file\n";
	}

# $nums[$b] <=> $nums[$a]


}

sub PrintRelations($)
{
	my ($file) = @_;

	my %targets;
	my %visited;

	print "$file\n";
	$indent = 0;
	AddAllTargets($file, \%targets, \%visited, 1);


	my $count = 0;

	print "\nfile = $file {\n";

	foreach (keys %targets)
	{
		print("  $_\n");
	}
	print "}\n";


	my @objects = grep(/.obj$/, keys %targets);
	$count = $#objects + 1;

	print "\n file $file has $count objects depending on it {\n";
	foreach (@objects)
	{
		print("  $_\n");
	}
	print "}\n";

	my @headers = grep(/.h$/, keys %targets);
	$count = $#headers + 1;

	print "\n file $file has $count headers depending on it {\n";
	foreach (@headers)
	{
		print("  $_\n");
	}
	print "}\n";
}

# generate a file that contains
#    target: dependency
# for each dependency in the whole system
sub GenerateDependencyFile()
{
	my $filelist = "$rootdir/makefilelist.txt";
	open(MAKEFILELIST, $filelist) or die "Failed to open $filelist";

	open(DEPENDENCYLISTTEMP, ">$dependencyMapFileTemp")
    or die "Failed to open $dependencyMapFile";


	my %dfilemap;

	while(<MAKEFILELIST>)
	{
    my $MakeInc = $_;

    my $dependFile = $MakeInc;
    $dependFile =~ s/make\.inc/\.depend/;
    chomp($dependFile);

    $_ = $outdir . "\\" . "debug\\" . $dependFile;
    if (open(TEMPHANDLE,$_))
    {
			# or die "Failed to open file $_\n";
			LINE: while(<TEMPHANDLE>)
			{
				my $line = $_;
				if (/(^[A-Za-z].+): (.+)/)
				{
					my $target = $1;
					chomp($target);
					my $depString = $2;
					#print("$target\n");

					my @depends = split(' ', $depString);

				  #i:\out\debug\Pipeline\include\stopevent.d: e:\dev\Development\Pipeline\include\stopevent.h i:\out\debug\include\observedevent.d
					if ($#depends >= 0)
					{
						if ("$target $depends[0]" =~ /^.+(\w+).d .+\1.h$/)
						{
							# lowercase them
							$target = lc $target;
							$depends[0] = lc $target;
							# store the mapping so we can replace it later
							$dfilemap{$target} = $depends[0];

							#print "===== $line\n";

							# convert a line like this:
							#    i:\foo\stopevent.d: e:\foo\stopevent.h i:\out\debug\include\observedevent.d
							# to this
							#    e:\foo\stopevent.h: i:\out\debug\include\observedevent.d
							$target = shift (@depends);

							#print "------$target: @depends\n";
						}
						elsif ("$target $depends[0]" =~ /^.+(\w+).d .+\1.idl$/)
						{
							# lowercase them
							$target = lc $target;
							$depends[0] = lc $target;
							# store the mapping so we can replace it later
							$dfilemap{$target} = $depends[0];

							#print "===== $line\n";

							# convert a line like this:
							#    i:\foo\stopevent.d: e:\foo\stopevent.h i:\out\debug\include\observedevent.d
							# to this
							#    e:\foo\stopevent.h: i:\out\debug\include\observedevent.d
							$target = shift (@depends);

							#print "------$target: @depends\n";
						}

					}

					# skip this line if it's now empty, like
					#    e:\foo\stopevent.h:
					next LINE if ($#depends == -1);

					next LINE if ($target =~ /.rc$/ || $target =~ /.tlb$/);

					next LINE if ($target =~ /.d$/ && $#depends >= 1);
#					if ($target =~ /.d$/ && $#depends >= 1)
#					{
#						print "$line\n";
#					}

					# lowercase target to avoid sensitivity problems
					$target = lc $target;
					foreach my $depend (@depends)
					{
						# lowercase dependency to avoid sensitivity problems
						$depend = lc $depend;

						# something depending on a .d in this context is really depending on the .h..
						#$depend =~ s/.d$/.h/;
						print DEPENDENCYLISTTEMP "$target: $depend\n";
					}

					#push (test, "a");
				}
			}
			close(TEMPHANDLE);
			$_  = $dependFile;
    }
	}

	close MAKEFILELIST;
	close DEPENDENCYLISTTEMP;


	#
	# now post process, replacing .d files with the correct .h files
	#
	open(DEPENDENCYLISTTEMP, "$dependencyMapFileTemp")
    or die "Failed to open $dependencyMapFileTemp";

	open(DEPENDENCYLIST, ">$dependencyMapFile")
    or die "Failed to open $dependencyMapFile";

	while(<DEPENDENCYLISTTEMP>)
	{
		if (/(^.+): (.+)/)
		{
			my $target = $1;
			my $depend = $2;

			# map the targets and dependencies
			if ($dfilemap{$target})
			{
				$target = $dfilemap{$target};
			}

			if ($dfilemap{$depend})
			{
				$depend = $dfilemap{$depend};
			}

			#if ($target =~ /.d$/)
			#{
			#	print "UNMAPPED TARGET $target\n";
			#}

			#if ($depend =~ /.d$/)
			#{
			#	print "UNMAPPED DEPEND $depend\n";
			#}

			print DEPENDENCYLIST "$target: $depend\n";
		}
	}
	close(DEPENDENCYLIST);
	close(DEPENDENCYLISTTEMP);
}

# generate a file that contains
#    target: dependency
# for each target in the whole system
sub GenerateLinkerDependencyFile()
{
	my $filelist = "$rootdir/makefilelist.txt";
	open(MAKEFILELIST, $filelist) or die "Failed to open $filelist";

#	open(DEPENDENCYLIST, ">$linkerDependencyMapFile")
#    or die "Failed to open $linkerDependencyMapFile";


	my %dfilemap;

	my %libCount;
	while(<MAKEFILELIST>)
	{
    my $MakeInc = $_;

#		print "--> $MakeInc\n";
		open(MAKEINC, "$rootdir/$_") or die "Cannot open file $_";

		my $line = "";
		my $relativeDir = "";
	LINE:
		while(<MAKEINC>)
		{
			if (/\\$/)
			{
				# leave off the last character and go to the next line
				$line = $line . substr($_, 0, -2);
				next LINE;
			}
			else
			{
				$line = $line . $_;
			}

			$_ = $line;

			# we have a whole line now
			if (/^RELATIVEDIR\s*:=\s*(.+)$/)
			{
				$relativeDir = $1;
				chomp($relativeDir);
			}
			elsif (/^EXTRA_LIBS\s*:=\s*(.+)$/)
			{
				my $libString = $1;
				chomp($libString);
				my @libs = split(' ', $libString);

#				print "$relativeDir: ";
				foreach (@libs)
				{
#					print $_ . " ";

					$libCount{$_}++;
#					if (!$libCount{$_})
#					{
#						$libCount{$_} = 1;
#					}
#					else
#					{
#						%libCount{$_} += 1;
#					}

				}
#				print "\n";
			}

			$line = "";

    }
		close(MAKEINC);
	}

	close MAKEFILELIST;

	print "-" x 40 . "\n";


	my @counts;

	foreach (keys %libCount)
	{
		my $count = $libCount{$_};

		push @counts, [$count, $_];
	}

	# sort descending by total count
#	my ($a, $b);
	@counts = sort { @$b[0] <=> @$a[0] } @counts;

	foreach my $record (@counts)
	{
		my ($count, $lib) = @$record;
		print "$count\t$lib\n";
	}


	foreach (keys(%libCount))
	{
	}
}

my $generateLinkerDependencyFile = 1;
my $generateDependencyFile = 1;

if ($generateDependencyFile)
{
	print "Generating header dependencies\n";
  GenerateDependencyFile();
}

if ($generateLinkerDependencyFile)
{
	print "Generating object dependencies\n";
	GenerateLinkerDependencyFile();
}

#
# go through the direct dependencies and store them in a map
#
open(DEPENDENCYLIST, "$dependencyMapFile")
    or die "Failed to open $dependencyMapFile";

while(<DEPENDENCYLIST>)
{
	if (/(^.+): (.+)/)
	{
		my $target = $1;
		my $depend = $2;

		if (!$dependencyMap{$depend})
		{
	    $dependencyMap{$depend} = ();
		}
		push @{$dependencyMap{$depend}}, $target;
	}
}
close(DEPENDENCYLIST);


#my $file = "e:\\dev\\development\\sdk\\include\\mtsdk.h";
#PrintRelations($file);

Calculate();


__END__



print "---- Direct dependencies ----\n";

foreach my $key (keys %dependencyMap)
{
	print "\n$key {\n";

	my @depends = @{$dependencyMap{$key}};
	foreach my $dependency (@depends)
	{
		print("  $dependency\n");
	}
	print "}\n";
}

print "---- All dependencies ----\n";


if (0)
{
foreach $key (keys %dependencyMap)
{
    my %targets = {};
    my %visited = {};
    AddAllTargets($key, \$targets, \$visited);

    print "\nkey = $key\n{";

    foreach (keys %targets)
    {
	print(" _ $\n");
    }
    print "}\n";


if (0)
{
    @depends = @{$dependencyMap{$key}};

    print "\nkey = $key {";
    foreach (@depends)
    {
	
	print("  $_\n");
    }
    print "}\n";
}
}
}




		# don't update dependencies with foo.d: foo.h
#		if (!($target =~ /\.d$/) && !($target =~ /\.tlb$/) && !($target =~ /\.rc$/))
		if (!($target =~ /\.tlb$/) && !($target =~ /\.rc$/))
		{
		    $target =~ s/\.obj$/\.cpp/;
		    @depends = split(' ', $depString);
		    foreach (@depends)
		    {
			$depend = $_;
			# replace foo.d with foo.h
			#$depend =~ s/\.d$/\.h/;

			# don't add .cpps in
			if (!($depend =~ /.cpp$/))
			{
			    if (!$dependencyMap{$depend})
			    {
				$dependencyMap{$depend} = ();
			    }
			    push @{$dependencyMap{$depend}}, $target;
			}
		    }
		}
