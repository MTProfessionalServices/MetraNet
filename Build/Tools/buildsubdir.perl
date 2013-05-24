
	$WorkingDir = `"pwd"`;
	$WorkingDir =~ s/\//\\/g;
	chomp $WorkingDir;

	$FailedToOpen = 1;

	open(MYDEPENDFILE,".mydepend") or $FailedToOpen = 0;

	if($FailedToOpen == 1) {
		$List = <MYDEPENDFILE>;
		@ListOfMakeFiles = split(' ',$List);

		foreach my $i (@ListOfMakeFiles) {
			$i = $WorkingDir . "\\" . $i;
		}

	}
	else {
		@ListOfMakeFiles = `"dir /s /b make.inc"`;
	}
	close(MYDEPENDFILE);



$RootDir = $ENV{ROOTDIR} . "\\";

foreach my $i (@ListOfMakeFiles) {

	$TestUtility = 0;
	open(MAKEFILE,$i) or die "failed to open $i";
	while(<MAKEFILE>) {
		if(/TEST_UTILITY/) {
			$TestUtility = 1;
		}
	}
	close(MAKEFILE);

	if(!$TestUtility) {
		$SubDir = $i;
		chomp $SubDir;
		$SubDir =~ s/(?i)\\make.inc//g;
		chdir($SubDir) or die "Failed to change to $SubDir directory.\n";


		system("perl $ENV{ROOTDIR}\\build\\tools\\GenIndividual.perl @ARGV");
	}
}


