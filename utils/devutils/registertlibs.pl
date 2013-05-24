#
# install the payment server tables
#

use strict;
use File::Find;



my $debugrelease;
if (not $ENV{DEBUG} or $ENV{DEBUG} eq "1")
{
	$debugrelease = "debug";
}
else
{
	$debugrelease = "release";
}

my $outbase = "$ENV{MTOUTDIR}/$debugrelease";

# NOTE: this stuff generated from find2perl
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

File::Find::find({wanted => \&wanted}, $outbase);

sub wanted
{
	$_ = $File::Find::name;
	if ((/\.tlb$/ || /\.dll$/) && -s $_ > 0)
	{
		system("regtlib.exe $_");
	}
}


