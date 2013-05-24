
my $varName = $ARGV[0];
my $val = $ENV{$varName};

#print "val: $val\n";

my @vals = split(";", $val);
foreach (@vals)
{
	print "$_\n";
}
