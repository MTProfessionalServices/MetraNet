
@ListOfMakeFiles = `"dir /s /b make.inc"`;

$RootDir = $ENV{ROOTDIR};

# append a backslash if necessary
if (not $RootDir =~ m/\\$/)
{
	$RootDir .= "\\";
}

$MakefileList = "> $ENV{ROOTDIR}\\$ARGV[0]";

open(MAKEFILELIST,$MakefileList) or die "failed to open $MakefileList\n";

foreach my $i (@ListOfMakeFiles) {
	$SubDir = $i;
	$SubDir =~ s/(?i)\Q$RootDir//g;
	$SubDir =~ s/\\/\//g;
	if (not $SubDir =~ m/^RECYCLER/)
	{
		print MAKEFILELIST $SubDir;
	}
}

close(MAKEFILELIST);
