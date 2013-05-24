
my $ROOTDIR=$ENV{ROOTDIR};
my $OUTDIR=$ENV{MTOUTDIR};

if ($#ARGV >= 0)
{
    $vbp = $ARGV[0];
    if ($#ARGV >= 1)
    {
	$quiet = $ARGV[1];
    }
}
else
{
    print "verifyvbrefs vbp-path\n";
    exit 1;
}

# allow args to be in any order
if ($vbp eq "-q")
{
    $vbp = $quiet;
    $quiet = "-q";
}

# if -q, then don't print anything
if ($quiet ne "-q")
{
    $quiet = 0;
}

open(FILEHANDLE,$vbp) or die "Failed to open $filelist";

$findtypelib="$ROOTDIR\\build\\Tools\\findtypelib.exe";

while(<FILEHANDLE>)
{
    #Reference=*\G{00020430-0000-0000-C000-000000000046}#2.0#0#C:\WINNT\System32\STDOLE2.TLB#OLE Automation
    #Reference=*\G{9796164C-6E37-11D4-A642-00C04F579C39}#1.0#0#..\..\..\..\..\Builds\debug\bin\RCD.dll#MetraTech Runtime Configuration Dispenser Type Library
    #Reference=*\G{420B2830-E718-11CF-893D-00A0C9054228}#1.0#0#C:\WINNT\System32\scrrun.dll#Microsoft Scripting Runtime
    #Reference=*\G{D63E0CE2-A0A2-11D0-9C02-00C04FC99C8E}#2.0#0#C:\WINNT\System32\msxml.dll#Microsoft XML, version 2.0

    if (/$Reference=\*\\G(\{.+\})\#([\dA-Za-z]+)\.([\dA-Za-z]+)\#.+\#.+\#(.+)/)
    {
	#print ("Reference: $1 $2 $3 $4\n");

	my ($guid, $major, $minor, $desc) = ($1, $2, $3, $4);
	$result = `$findtypelib $guid $major $minor`;
	chomp($result);

	if (!($result =~ /Failed:/) && length($result) > 0)
	{
	    if (not $quiet)
	    {
		print ("Found: $result ($desc)\n");
	    }
	}
	else
	{
	    print STDERR ("INVALID VB REFERENCE: '$vbp': $desc: $result\n");
	    exit 1;
	}
    }
}

exit 0;
