


my @variables = ("INCLUDE", "LIB", "MAKE_MODE", "MSDevDir",
								 "OUTDIR", "Path", "PATHEXT", "ROOTDIR",
								 "StarTeam", "StarTeamApp", "STLicense", "TEMP");


my $rootDir = $ENV{ROOTDIR} or die "Failed to get ROODIR environment variable";

my $setupEnvFile = "$rootDir/Build/Tools/builddirserver.bat";
open (SETUPENV, ">$setupEnvFile") or die "Unable to open $setupEnvFile";
#print SETUPENV "\@echo off\n";
foreach my $var (@variables)
{
	print SETUPENV "set $var=$ENV{$var}\n";
}


# append builddir
my $buildDirFile = "$rootDir/Build/Tools/builddir.bat";
open(FILEHANDLE,"$buildDirFile") or die "Failed to open $buildDirFile";

while (<FILEHANDLE>)
{
	print SETUPENV;
}
close(FILEHANDLE);

close (SETUPENV);

print "environment recorded to file $setupEnvFile\n";
