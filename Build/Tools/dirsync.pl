#
# dirsync.pl
#
# Removes folders from the local machine that
# have recently been removed from StarTeam.
#
# tgebhardt@metratech.com 9/8/2003

use File::Path;

my $temp = $ENV{TEMP};

# checks for required drive letters
if (not (chdir "s:\\"))
{
    warn "Missing required drive mapping - S:\\ to development\\Source";
    exit;
}
if (not (chdir "r:\\"))
{
    warn "Missing required drive mapping - R:\\ to development\\RMP";
    exit;
}
if (not (chdir "t:\\"))
{
    warn "Missing required drive mapping - T:\\ to development\\Tests Database";
    exit;
}

# gets the current datetime
my @t = localtime time;
$date = sprintf "%02u-%02u-%02u-%02u%02u%02u", $t[4] + 1, $t[3], $t[5] % 100, $t[2], $t[1], $t[0];

# reads in the list of files that were removed from StarTeam
my $datafile = "$ENV{ROOTDIR}\\build\\tools\\removedfolders.txt";
open (FILE, "$datafile") || die "Cannot open data file: '$datafile'!";
@folders = <FILE>;
close (FILE);
chomp @folders;

# removes the extra folders
print "Removing folders from your system that have been removed from StarTeam:\n";
my $count = 0;
foreach $folder (@folders)
{
    # removes trailing whitespace from folder
    $folder =~ s/\s+$//; 

    if (-e $folder)
    {
	print "  $folder\n";

	# makes a backup of the folder to be removed as a precaution
	($drive, $backupName) = $folder =~ /(.*?):(.*)/;
	#print "Performing xcopy \"$folder\" \"$temp\\dirsync\\$date\\$drive\\$backupName\" /i /s /v";
	$rc = `xcopy \"$folder\" \"$temp\\dirsync\\$date\\$drive\\$backupName\" /i /s /v`;
	if ($rc =~ /(\d+) File\(s\) copied/)
	{
	    # check to make sure the copy actually succeeded
	    if ($1 <= 0)
	    {
		# zero files were copied - was the directory empty or did the copy fail?
		opendir DIR, $folder || die "Cannot open directory $folder for reading!\n";
		my @files = readdir DIR;
		closedir DIR;

		if (@files > 2)
		{
		    print "xcopy result: $rc\n";
		    die "Could not make backup copy of folder!";
		}
	    }
	}
	else
	{
	    print "xcopy result: $rc\n";
	    die "Could not make backup copy of folder!";
	}

	# removes the folder (and subfolders)
	$rc = `rd /S /Q \"$folder\"`;
	if (-e $folder)
	{
	    print "rd result: $rc\n";
	    die "Could not remove folder: '$folder'!";
	}
	$count++;
    }
}

print "$count folders were removed from your system.\n";
