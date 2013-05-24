#! C:Perlinperl.exe -w
    eval 'exec C:Perlinperl.exe -S $0 ${1+"$@"}'
        if 0; #$running_under_some_shell

use strict;
use File::Find ();

# Set the variable $File::Find::dont_use_nlink if you're using AFS,
# since AFS cheats.

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;


# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, 'o:/debug/');
exit;


sub wanted {
	if (/\.tlb$/ && -s $_)
	{
		print "found $File::Find::name\n";
	}
}

