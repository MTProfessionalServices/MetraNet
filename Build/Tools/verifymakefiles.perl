
$filelist = "$ENV{ROOTDIR}/makefilelist.txt";

open(FILEHANDLE,$filelist) or die "Failed to open $filelist";


while(<FILEHANDLE>) {

    my $MakeInc = $_;
    chomp($MakeInc);

    open(TEMPHANDLE,$_) or die "Failed to open file $_\n";
    while(<TEMPHANDLE>) {
	if(/^RELATIVEDIR \:\= (.+)/) {
	   $dir = $1;
	   break;
	}
    }

    close(TEMPHANDLE);

    my $realDir = $MakeInc;
    $realDir =~ s/\/make.inc//;
    $realDir =~ s/\//\\/g;
    if ($realDir ne $dir)
    {
	print "$realDir != $dir\n";
	rename ($MakeInc, "$MakeInc.old") or die "can't rename $MakeInc: $!";

	open(OUTPUT, ">$MakeInc") or die "Failed to open file $_";

	open(INPUT, "$MakeInc.old") or die "Failed to open file $_";

	while(<INPUT>) {
	    if(/^RELATIVEDIR \:\= /) {
		print OUTPUT "RELATIVEDIR := $realDir\n";
	    }
	    else
	    {
		print OUTPUT $_;
	    }
	}
	close OUTPUT;
	close INPUT;
	break;
    }
}

close FILEHANDLE;
