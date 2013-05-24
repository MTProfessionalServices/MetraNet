
##################################################################################
#DetermineVBFile
##################################################################################


sub DetermineVBFile($) {
	my ($makefile) = @_;
	my $VBFile = 0;
	open(MAKEINC,$makefile) or die "Failed to $makefile";
	while(<MAKEINC>) {
		if(/VB_PROJNAME/) {
			$VBFile = 1;
		}
	}
	close MAKEINC;
	return $VBFile;
}


##################################################################################
#CreateVBMakefile
##################################################################################

sub CreateVBMakefile($$$$$) {
	my ($TargetName,$MAKEFILE,$makefile,$projectDir,$DebugString) = @_;

	open(MAKEINC,$makefile) or die "Failed to $makefile";
	while(<MAKEINC>) {
		if(/VB_PROJNAME/) {
			$VbpFile = $_;
			# Get rid of VB_PROJNAME, the :=, and the trailing space
			$VbpFile =~ s/^VB_PROJNAME.*?:=.*? //g;
			chomp $VbpFile;
		}
		if(/VB_EXENAME/) {
			$VbExeName = $_;
			$VbExeName =~ s/^VB_EXENAME.*?:=.*? //g;
			chomp $VbExeName;
		}
	}
	close MAKEINC;

	# step 1: generate the .depend file
	$BuildString = "perl $ENV{ROOTDIR}\\build\\tools\\makeVBDepend.perl $projectDir $VbpFile $DebugString";
	system($BuildString);
	# step 2: include the .depend file
	$OutDir = $makefile;
	$OutDir =~ s/\\make.inc//g;
	$OutDir =~ s/\Q$ENV{ROOTDIR}//g;
	$OutDir = "$ENV{MTOUTDIR}\\$DebugString" . $OutDir;
	`mkdir $OutDir`;
	print $MAKEFILE "include $OutDir\\.depend\n";
	# step 3: add a target that depends on the .depend rule
	print $MAKEFILE "$TargetName : \$(BINDIR)/$VbExeName\n";
	print $MAKEFILE "clean:\n\t\$(RM) $OutDir\\*.* \$(BINDIR)/$VbExeName\n";
}

##################################################################################
#CreateCMakefile
##################################################################################

sub CreateCMakefile($$$) {
	my($Template,$TargetName,$MAKEFILE) = @_;

	open (TEMPLATE,$Template) or die "Failed to open $Template\n";
	
	print MAKEFILE "include $MakeFileName\n";

	while(<TEMPLATE>) {
		s/\@\@TAGNAME\@\@/$TargetName/g;
		print $MAKEFILE $_;
	}

	print $MAKEFILE "\n\nclean: \$(CLEAN_TARGETS)\n\n";
	close TEMPLATE;


}


# get a couple of environment variables
$RootDir = $ENV{ROOTDIR} or die "Failed to get ROOTDIR environment variable";
$TempDir = $ENV{TEMP} or die "Failed to get TEMP environent variable";
$OutDir = $ENV{MTOUTDIR} or die "Failed to get OUTDIR environment variable";
$Debug = "";
$Debug = $ENV{DEBUG};

if($Debug == "" || $Debug == "0") {
	$OutDir .= "\\release";
}
else {
	$OutDir .= "\\debug";
}


$RootDir = substr($RootDir,2);
$RootDir .= "\\";

# the template rules file
$Template = "$ENV{ROOTDIR}/makefile.rules";


# Step 1: get the current directory

chomp($CurDir = `pwd`);

# if the output of pwd is something like //E/foo/bar, remove the first three
# characters
if($CurDir =~ /\/\//) {
	$CurDir = substr($CurDir,3);
}

# if the output of pwd is something like /cygdrive/e/dev/Development/Core/msix,
# remove /cygdrive/e
$CurDir =~ s/^(\/cygdrive\/)?[A-Za-z]\//\//;

# if the output of pwd is something like /e/dev/Development/Core/msix,
# remove /e
#$CurDir =~ s/\/[A-Za-z]\//\//;

# remove the cygnus root dir (might be different)
#$CurDir =~ s/(?i)\Q\/dev//g;
#$CurDir =~ s/(?i)\Q\$CYGWINROOTDIR//g;

$CurDir =~ s/\//\\/g;

#print "cur dir: $CurDir\n";

# calculate the generated makefile name
$GenMakefileName = $CurDir;
$GenMakefileName =~ s/^(?i)\Q$RootDir//g;
$GenMakefileName =~ s/^(?i)\Q$CYGWINROOTDIR//g;

# Directory to create
$FullOutputDir = $OutDir . "\\" . $GenMakefileName;

$GenMakefileName =~ s/\\/_/g;
$GenMakefileName = $TempDir . "\\" . $GenMakefileName . "_make.inc";
#print "$GenMakefileName\n";

# get the make.inc name
$MakeFileName = $CurDir . "\\make.inc";
$MakeFileName =~ s/^(?i)\Q$RootDir//g;
$MakeFileName = $ENV{ROOTDIR} . "\\" . $MakeFileName;
#print "$MakeFileName\n";

if (!stat($MakeFileName)) 
{
 print "$MakeFileName does not exist.\n";
 exit;
}

# step 2: see if the generated make file allready exists

if(stat($GenMakefileName)) {

	$MustGenerateFile = 0;

	$LastModifyTime = (stat($GenMakefileName))[9];

	# if it exists, check to see if it is older than the make.inc.  
	# If it is older, generate the new file

	$ModifyTime	= (stat($MakeFileName))[9];

	if($LastModifyTime < $ModifyTime	) {
		#print "make.inc is newer than generated makefile\n";
		$MustGenerateFile = 1;
	}

	# check if the template file is newer
	if($MustGenerateFile == 0) {

		$TemplateTime = (stat($Template))[9];
		if($LastModifyTime < $TemplateTime) {
			#print "Makefile.rules is newer\n";
			$MustGenerateFile = 1;
		}
	}


}
else {
	$MustGenerateFile = 1;
}

$TargetName = $CurDir;
if($RootDir ne "\\") {
	$TargetName =~ s/\Q$RootDir//g;
}
else {
	$TargetName = substr($TargetName,1);

}
$TargetName =~ s/\\/_/g;
chomp $TargetName;

$LocalPath = $MakeFileName;
$LocalPath =~ s/\\make.inc$//g;

if($MustGenerateFile == 1) {

	print "Generating makefile...\n";


	open(MAKEFILE,"> $GenMakefileName") or die "Failed to open $GenMakefileName";
	$timestr = localtime(time());
	print MAKEFILE "############################################################\n#Generated on $timestr\n";
	print MAKEFILE "#Do not edit.  Really.  Keep those grubby meat-hooks away from the keyboard!\n";
	print MAKEFILE "#############################################################\n\n\n";

	print MAKEFILE "# ------------\n";
	print MAKEFILE "include \$(ROOTDIR)\\makefile.settings\n";
	print MAKEFILE "include \$(ROOTDIR)\\makefile.dirs\n";
	print MAKEFILE "include \$(ROOTDIR)\\Makefile.aliases\n";

$pathfragment = $CurDir;
$pathfragment =~ s/^(?i)\Q$RootDir//g;

#	print MAKEFILE "include $OutDir\\$pathfragment\\.depend\n";



	if(DetermineVBFile($MakeFileName)) {
		if($ENV{DEBUG} == "1") {
			$DebugString = "debug";
		}
		else {
			$DebugString = "release";
		}

		CreateVBMakefile($TargetName,MAKEFILE,$MakeFileName,$LocalPath,$DebugString);
	}
	else {
		CreateCMakefile($Template,$TargetName,MAKEFILE);
	}
	print MAKEFILE "include \$(ROOTDIR)\\makefile.after\n";

	close MAKEFILE;

}


# step 5: execute the build

$SystemStr = "make -r -k -f $GenMakefileName "; # NO_DEPENDENCIES=1 ";

if($#ARGV < 0) {
	$SystemStr .= $TargetName;
}
else {
	$SystemStr .= "@ARGV";
}

#print "$SystemStr\n";
# create the output directory
mkdir($FullOutputDir,0700);
system $SystemStr;
