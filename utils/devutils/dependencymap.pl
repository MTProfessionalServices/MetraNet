@ListOfMakeFiles = `"dir /s /b $ENV{MTOUTDIR}\\.depend"`;

$direct = "> $ENV{ROOTDIR}\\direct.txt";
$reverse = "> $ENV{ROOTDIR}\\reverse.txt";
$indirect = "> $ENV{ROOTDIR}\\indirect.txt";

open(DIRECT, $direct) or die "failed to open $direct";
open(INDIRECT, $indirect) or die "failed to open $direct";
open(REVERSE, $reverse) or die "failed to open $reverse";

foreach my $depend (@ListOfMakeFiles)
{
	open(GREPFILE, $depend) or die "unable to open $depend";
	while(<GREPFILE>)
	{
		if (/\# (.+): (.+)/)
		{
			print DIRECT "$_";
			print REVERSE "$2: $1\n";
		}
	}
}

close(DIRECT);
close(INDIRECT);
close(REVERSE);
