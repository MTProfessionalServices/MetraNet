#!perl -w
use strict;
#
# Copy web service binaries
#
use File::Copy;
  
my $src_dir = shift or die Usage();
my $dst_dir = shift or die Usage();

my $refresh_bat = "$src_dir\\bin\\refresh.bat";

open RB, $refresh_bat or die "Error opening $refresh_bat\n";
while (<RB>) {
  next unless /\\bin\\(.+\.dll)$/;
	print "$dst_dir\\bin\\$1\n";
	copy $1,"$dst_dir\\bin"
	  or die "Error copying file $1 to $dst_dir\\bin\n";
}
close RB;

exit;

sub Usage
{
my $usage = <<"EOF";

Usage: $0 <srcdir> <bindir> <dstdir>
EOF
  $usage;
}
