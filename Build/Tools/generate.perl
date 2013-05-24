
$filelist = "$ENV{ROOTDIR}/makefilelist.txt";
$makefile = "> $ENV{ROOTDIR}/makefile.inc";
$Template = "$ENV{ROOTDIR}/makefile.rules";

open(FILEHANDLE,$filelist) or die "Failed to open $filelist";
open(MAKEFILE,$makefile) or die "Failed to open $makefile";

print MAKEFILE "# Generated makefile - Do not edit!\n";

while(<FILEHANDLE>) {

	my $IncludeFile = $_;

	my $TestFile = 0;
	open(TEMPHANDLE,$_) or die "Failed to open file $_\n";
	while(<TEMPHANDLE>) {
		if(/^.*(?i)TEST_UTILITY.*?\=.*?1/) {
			#print "Testfile found\n";
			$TestFile = 1;
		}
	}
	close(TEMPHANDLE);
	$_  = $IncludeFile;

	if($TestFile == 0) {
		print MAKEFILE "# ------------\n";
		print MAKEFILE "include $_\n";

		open (TEMPLATE,$Template) or die "Failed to open $Template\n";
		
		s/^\.\///g;
		s/\/make.inc$//g;
		s/\//_/g;
		chomp;
		my $replace = $_;

		while(<TEMPLATE>) {
			s/\@\@TAGNAME\@\@/$replace/g;
			print MAKEFILE $_;
		}
		close TEMPLATE;
	}

}
close MAKEFILE;
close FILEHANDLE;
