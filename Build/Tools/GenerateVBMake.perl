

if($ARGV[0] eq "") {
	print("Not enough arguments.  You must specify a VB project file with a full path.\n");
	exit;
}


$FileName = $ARGV[0];
$ExeName;

$ShortFileName = substr($FileName,rindex($FileName,"\\")+1);

$RelativePath = $FileName;
$RelativePath =~ s/\Q$ENV{ROOTDIR}//g;
$RelativePath =~ s/\Q$ShortFileName//g;
$RelativePath =~ s/^\\//g;
chop $RelativePath;



open(FILENAME,$FileName) or die "Failed to open $FileName\n";
@RefList;
$RefCounter=0;

while(<FILENAME>) {
	if(/^(?i)ExeName32/) {
		s/^.*?\"//g;
		chop; chop;
		#print "Exe name is $_\n";
		$ExeName = $_;

	}
}
close(FILENAME);


if($ExeName eq "") {
	$ExeName = $ShortFileName;
	$ExeName =~ s/(?i)\.vbp/\.exe/g;
}

	# generate make file

	$timestr = localtime(time());
	$GenerationStr = "############################################################\n#Generated on $timestr\n#############################################################\n\n\n";

	$MakeFile = "> make.inc";
	open(MAKEFILE,$MakeFile) or die "Failed to open $MakeFile\n";


 print MAKEFILE $GenerationStr;
	print MAKEFILE "RELATIVEDIR := $RelativePath\n\n";
	print MAKEFILE "\n\n";
	print MAKEFILE "VB_EXENAME := $ExeName\n";
	print MAKEFILE "VB_PROJNAME := $ShortFileName\n";

close(MAKEFILE);