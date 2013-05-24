
my $quiet = 1;

# get current time
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
	localtime(time);

my @days = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
my $day = $days[$wday];


my $temp = $ENV{TEMP};
my $localFile = "$ENV{ROOTDIR}\\makefilelist.txt";

my $buildVersion = "V3.6";


# Argon doesn't build v3.6 yet
# CheckArgon();

my $datestr = sprintf("%02d%02d%04d", $mon + 1, $mday, $year + 1900);
if (CheckShogun($datestr) == -1)
{
    # check up to 3 builds earlier if the current build is not yet available
    # TODO: this doesn't wrap around months, years...
    print("\nchecking for earlier builds...\n\n");
    for (my $i = 1; $i <= 3; $i++)
    {
	$datestr = sprintf("%02d%02d%04d", $mon + 1, $mday - $i, $year + 1900);
	if (CheckShogun($datestr) != -1)
	{
	    last;
	}
    }
}


sub CheckShogun
{
    my $buildDate = pop(@_);

    #\\Shogun\Builds\V3.5\10312002\Development
    my $buildMachineFile = "\\\\Shogun\\Builds\\$buildVersion\\$buildDate\\Development\\Source\\makefilelist.txt";
    unlink "$temp\\makefilelistshogun.txt";
    `COPY $buildMachineFile $temp\\makefilelistshogun.txt`;
    if (-e "$temp\\makefilelistshogun.txt" and -s "$temp\\makefilelistshogun.txt")
    {
	$differences = `diff $temp\\makefilelistshogun.txt $localFile`;

	$differences =~ s/[0-9]+a[0-9]+/EXTRA/g;
	$differences =~ s/[0-9]+d[0-9]+/MISSING/g;

	if ($differences ne "")
	{
		print "-- directories compared to shogun --\n";
		print "$differences\n";
		return 1;
	}
	else
	{
		if (not $quiet)
		{
			printf("no differences compared to shogun\n");
		}
		return 0;
	}
    }
    else
    {
	print("shogun makefilelist not currently available:\n     $buildMachineFile\n");
	return -1;
    }
}

sub CheckArgon
{
    #\\Argon\Builds\V3.5\Thu\Development\makefilelist.txt
    my $buildMachineFile = "\\\\Argon\\Builds\\$buildVersion\\$day\\Development\\makefilelist.txt";
    unlink "$temp\\makefilelistargon.txt";
    `COPY $buildMachineFile $temp\\makefilelistargon.txt`;

    # exists and non zero size
    if (-e "$temp\\makefilelistargon.txt" and -s "$temp\\makefilelistargon.txt")
    {
	my $differences = `diff $temp\\makefilelistargon.txt $localFile`;
	
	$differences =~ s/[0-9]+a[0-9]+/EXTRA/g;
	$differences =~ s/[0-9]+d[0-9]+/MISSING/g;
	
	if ($differences ne "")
	{
	    print "-- directories compared to argon --\n";
	    print "$differences\n";
	}
	else
	{
	    if (not $quiet)
	    {
		printf("no differences compared to argon\n");
	    }
	}
    }
    else
    {
	print("argon makefilelist not currently available:\n     $buildMachineFile\n");
    }
}
