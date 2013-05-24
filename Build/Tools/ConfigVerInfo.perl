

open(MAKEFILE,"make.inc") or die "failed to open make.inc";

$ComName = 0;
$DllName = 0;
$NoRCFile = 0;

while(<MAKEFILE>) {
	if(/^COMNAME.*?:=/) {
		$ComName = $_;
		$ComName =~ s/^COMNAME.*?:=//g;
		$Project = $ComName;
	}
	elsif(/^DLLNAME.*?:=/) {
		$DllName = $_;
		$DllName =~ s/^DLLNAME.*?:=//g;
		$Project = $DllName;
	}
	elsif(/^NO_RCFILE.*?=/ || /^NO_RCFILE.*?:=/) {
		$NoRCFile = 1;
	}
}

close(MAKEFILE);

if(!$ComName && !$DllName) {
	print("No versionable object found.... exiting.\n");
	exit;
}
chomp $Project;
print "Working on the $Project project...\n";


open (VERSIONFILE,"> $Project\_version.h") or die "Fail to open version header file";
$timestr = localtime(time());
$GenerationStr = "//\n//Generated on $timestr\n//\n";

print VERSIONFILE "$GenerationStr\n";
print VERSIONFILE "#define MT_USERDEFINE_DESCRIPTION \"$Project\\0\"\n";
print VERSIONFILE "#define MT_USERDEFINE_INTERNALNAME \"$Target\\0\"\n";
print VERSIONFILE "#define MT_USERDEFINEORIGFILENAME MT_USERDEFINE_INTERNALNAME\n";
print VERSIONFILE "#define MT_USERDEFINEPRODUCTNAME MT_USERDEFINE_DESCRIPTION\n";
print VERSIONFILE "#define MT_USERDEF_PROJECTNAME MT_USERDEFINE_DESCRIPTION\n";
print VERSIONFILE "#define IDS_PROJNAME 100";

close(VERSIONFILE);


if($ComName || $DllName) {
  $RcNameStr = "dir /b *.rc";
  $RcName = `"$RcNameStr"`;
  chop $RcName;

  system "sed -f $ENV{ROOTDIR}\\build\\tools\\rcreplace.sed $RcName > temp_sed_output";
  system "copy temp_sed_output $RcName";
  system "del temp_sed_output";
}
