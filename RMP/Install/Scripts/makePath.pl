#!perl
#------------------------------------------------------------------------------
# Script:      makePath.pl
# Description: Make directory path
# Author:      Simon Morton
#------------------------------------------------------------------------------
use Getopt::Std;
use File::Path;

getopts('v');
$verbose = $opt_v;

my $dir = shift or die Usage();

if ( !-d $dir ) {
  print "Creating $dir\n" if $verbose;
  eval { mkpath($dir) };
  if ($@) {
    print "Couldn't create $dir: $@";
    exit -1;
  }

} else {
  print "$dir already exists; nothing to create\n" if $verbose;
}

exit;


sub Usage
{
  my $usage = <<"EOF";
Usage: $0 <dir>

Creates a directory and all intermediate directories in the path, if needed.

EOF
  $usage;
}
