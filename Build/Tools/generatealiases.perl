
$filelist = "$ENV{ROOTDIR}/makefilelist.txt";
$Template = "$ENV{ROOTDIR}/makefile.rules";

open(FILEHANDLE,$filelist) or die "Failed to open $filelist";


sub MakeTag
{
    my $filename = shift(@_);
    $_ = $filename;
    chomp;
    s/\/make.inc$//g;
    s/\//_/g;
}

my @com_objects = ();
my @dlls = ();
my @exes = ();
my @vbs = ();
my @plugins = ();
my @assemblies = ();

while(<FILEHANDLE>) {

    my $MakeInc = $_;

    my $TestFile = 0;

    my $comObject = 0;
    my $dll = 0;
    my $exe = 0;
    my $vb = 0;
    my $plugin = 0;
    my $assembly = 0;

    open(TEMPHANDLE,$_) or die "Failed to open file $_\n";
    while(<TEMPHANDLE>) {
	if(/^RELATIVEDIR \:\= plugins/) {
	    $plugin = 1;
	}
	elsif(/^COMNAME/) {
	    $comObject = 1;
	}
	elsif (/^EXENAME/) {
	    $exe = 1;
	}
	elsif (/^DLLNAME/) {
	    $dll = 1;
	}
	elsif (/^VB_EXENAME/) {
	    $vb = 1;
	}
	elsif (/^VB_EXENAME/) {
	    $vb = 1;
	}
	elsif (/^CSHARPDLL/) {
	    $assembly = 1;
	}
	elsif (/^CSHARPEXE/) {
	    $assembly = 1;
	}
	elsif (/^MANAGED/) {
	    $assembly = 1;
	}
	elsif(/^.*(?i)TEST_UTILITY.*?\=.*?1/) {
	    $TestFile = 1;
	}
    }
    close(TEMPHANDLE);
    $_  = $MakeInc;
    
    MakeTag($_);

    if (!$TestFile)
    {
	if ($comObject)
	{
	    push(@com_objects, $_);
	}
	elsif($dll && !$plugin && !$assembly)
	{
	    push(@dlls, $_);
	}
	elsif($dll && $plugin)
	{
	    push(@plugins, $_);
	}
	elsif($exe && !$assembly)
	{
	    push(@exes, $_);
	}
	elsif($vb)
	{
	    push(@vbs, $_);
	}
	elsif($assembly)
	{
	    push(@assemblies, $_);
	}

    }
}

#
# generate the file
#

print "com_objects:  \\\n";
foreach (@com_objects)
{
    print "    $_   \\\n";
}

print "\n\ndlls:  \\\n";
foreach (@dlls)
{
    print "    $_   \\\n";
}

print "\n\nexes:  \\\n";
foreach (@exes)
{
    print "    $_   \\\n";
}

print "\n\nvb_projects:  \\\n";
foreach (@vbs)
{
    print "    $_   \\\n";
}

print "\n\nplugins:  \\\n";
foreach (@plugins)
{
    print "    $_   \\\n";
}

print "\n\nassemblies:  \\\n";
foreach (@assemblies)
{
    print "    $_   \\\n";
}

close FILEHANDLE;
