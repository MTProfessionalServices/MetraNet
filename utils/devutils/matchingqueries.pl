
use strict;

my $querylist = $ARGV[0];
my $queryfile = $ARGV[1];

open(QUERYLIST, $querylist) or die "Failed to open $querylist";

my @taglist;
my $tagindex = 0;
while(<QUERYLIST>)
{
	chomp();
	$taglist[$tagindex++] = $_;
}

close (QUERYLIST);

open(QUERYFILE, $queryfile) or die "Failed to open $queryfile";

while (<QUERYFILE>)
{
	my $tag;
	foreach $tag (@taglist)
	{
		if (/$tag/)
		{
			print "$tag\n";
		}
	}
}

close (QUERYFILE);
