
# -------------------------------------------------------
# Check that the user has supplied the correct number of command line arguments
# -------------------------------------------------------

if($#ARGV < 0) {
  die "Usage: $ENV{PROG_NAME} project_file \nExample: $ENV{PROG_NAME} D:\\temp\\test.vbp \n";
}


# -------------------------------------------------------
# Prepare the arguments
# -------------------------------------------------------

$strProjectFile = $ARGV[0];
$strVersionFile = $ENV{ROOTDIR} . "\\include\\MTTreeRev.h";
$intMajor       = "";
$intMinor       = "";
$intRevision    = "";
$strTempFile    = $ENV{TEMP} . "\\tempfile.vbp";



# -------------------------------------------------------
# Retrieve the version numbers from the version file
# -------------------------------------------------------
open (INPUT, $strVersionFile) or die "failed to open version file: $strVersionFile";
while(<INPUT>)
{
	if (/(#define MT_MAJOR_VERSION\s+)([0-9]+)/)
	{
		$intMajor = $2;
	}

	if (/(#define MT_MINOR_VERSION\s+)([0-9]+)/)
	{
		$intMinor = $2;
	}

	if (/(#define MT_REVISION\s+)([0-9]+)/)
	{
		$intRevision = $2;
	}
}
close(INPUT);


# -------------------------------------------------------
# Open the project file
# Open a temporary output file
# -------------------------------------------------------

open (INPUT, $strProjectFile) or die "failed to open project file: $strProjectFile";
open (OUTPUT, ">$strTempFile") or die "failed to open temporary output file: $strTempFile";

# -------------------------------------------------------
# Replace the version numbers with the input given
# -------------------------------------------------------
while (<INPUT>)
{
   s/MajorVer=.+/MajorVer=$intMajor/;
   s/MinorVer=.+/MinorVer=$intMinor/;
   s/RevisionVer=.+/RevisionVer=$intRevision/;
   print OUTPUT;
}

close(INPUT);
close(OUTPUT);

unlink $strProjectFile or die "failed to delete file $strProjectFile : $!";
rename $strTempFile, $strProjectFile  or die "failed to rename file $strProjectFile : $!"; 


