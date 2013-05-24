
use strict;
use File::Find ();

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

my $rootdir = $ENV{ROOTDIR};

my %currentDirectories;
my %oldDirectories;

my $directoryFile = "e:\\scratch\\files.txt";

sub GetCurrectDirectories
{
	# retrieve the currect list of directories
	File::Find::find({wanted => \&wanted}, "$rootdir/config");


#	my @sortedDirectories = sort @directories;

#	foreach my $dir (@sortedDirectories)
#	{
#		$dir =~ s/$rootdir//;
#		if ($dir)
#		{
#			print "$dir\n";
#		}
#	}
}

sub wanted
{
	# if it's a directory
	if (-d $_)
	{
		$currentDirectories{$File::Find::name} = $File::Find::name;
	}
}


sub ReadDirectoryList
{
	open (DIRECTORYFILE, "$directoryFile") or die "Cannot open $directoryFile";

	while (<DIRECTORYFILE>)
	{
		%oldDirectories{$_} = $_;
	}

	close (DIRECTORYFILE);
}

sub WriteDirectoryList()
{
	open (DIRECTORYFILE, ">$directoryFile") or die "Cannot open $directoryFile";

	foreach my $dir (keys $currentDirectories)
	{
		print DIRECTORYFILE, $_
	}
}

sub CompareDirectories()
{
	GetCurrentDirectories();
	ReadDirectoryList();

	# anything in the current list not in the old list is new
	foreach (keys %currentDirectories)
	{
		if (not $oldDirectories{$_})
		{
			print "NEW: $_\n";
		}
	}

	# anything in the old list not in the new list was removed
	foreach (keys %oldDirectories)
	{
		if (not $currentDirectories{$_})
		{
			print "DELETED: $_\n";
		}
	}
}

