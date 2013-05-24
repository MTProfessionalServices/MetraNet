#
# findMissingDeps.pl
#
# parses make.log and pulls out missing dependencies found by makedepend.perl
#

$buildLog = @ARGV[0];
chomp $buildLog;
if (length($buildLog) == 0)
{
    die "Please specify a make.log file to parse!\n";
}

open(LOG, $buildLog) || die "Cannot open $buildLog: $!";

my %files;

while (<LOG>)
{
    if (/^WARNING: Dependency \'(.*?)\'/)
    {
	$files{$1} = 1;
    }
}

print join("\n", sort(keys(%files)));
