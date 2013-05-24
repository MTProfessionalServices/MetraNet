
use strict;


my $remoteRootDir = $ENV{REMOTEROOTDIR};
my $builddirserver = "$remoteRootDir\\Build\\Tools\\builddirserver.bat";

# get a couple of environment variables
my $rootDir = $ENV{ROOTDIR} or die "Failed to get ROODIR environment variable";
my $debug = "";
$debug = $ENV{DEBUG};

if (!$debug || $debug eq "0")
{
	$debug = 0;
}
else
{
	$debug = 1;
}

#
# get the current working directory
#
my $curDir;
chomp($curDir = `pwd`);

#
# strip off the rootdir prefix
#
chdir $rootDir;

my $realRootDir;
chomp($realRootDir = `pwd`);

# remove the initial root dir and first slash
$curDir =~ s/$realRootDir\///;

$curDir =~ s!/!\\!g;

my $command;
if ($debug)
{
	$command = "rsh fusion $builddirserver $curDir 1\n";
}
else
{
	$command = "rsh fusion $builddirserver $curDir 0\n";
}

system $command;
