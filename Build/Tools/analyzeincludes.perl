
#
# figure out often included files
#


sub DumpIncludes
{
    ($file) = @_;

    open(FILEHANDLE,"< $file") or die "Failed to open $file";

    while (<FILEHANDLE>)
    {
	if (/^\#include\s+[<\"](.+)[\">]/)
	{
	    my $includefile = $1;
	    print "$includefile: $file\n";
	}
    }
    close(FILEHANDLE);
}


#my $dir;

#if ($#ARGV >= 0)
#{
#    $dir = $ARGV[0];
#}
#else
#{
#    die "Dir name argument required";
#}

while (<STDIN>)
{
    my $filename = $_;
    #print "Analyzing file: $filename\n";
    chop($filename);
    DumpIncludes($filename);
}


#opendir(DIR,$dir) or die "failed to open directory";
#my @FullList = grep {/(?i)\.h$/} readdir(DIR);
#foreach my $filename (@FullList)
#{
#    DumpIncludes($filename);
#}
