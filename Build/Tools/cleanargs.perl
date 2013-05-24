

my $cmdline = "";
my $first = 1;

foreach my $arg (@ARGV)
{
    $_ = $arg;
    if (/^[^\/].*[\\\/].+[\\\/]/)
    {
	# turn / to \
	$arg =~ s/\//\\/g;
	# turn // to /
	#s/\/\//\//g;
	# turn \\ to \
	#s/\\\\/\\/g;
	#$_ = "FOO";
    }

    # turn \\ to \
    $arg =~ s/\\\\/\\/g;

    if ($first)
    {
	$first = 0;
    }
    else
    {
	$cmdline .= " ";
    }

    $cmdline .= $arg;
}


#print "------ [[$cmdline]]\n";
my $rc = 0xffff & system $cmdline;
exit $rc >> 8;
