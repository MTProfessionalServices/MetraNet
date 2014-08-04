#!/usr/bin/perl
#------------------------------------------------------------------------------
# Script:      removeTree.pl
# Description: Remove directory tree
# Author:      Simon Morton
#------------------------------------------------------------------------------
use Getopt::Std;
use File::Path;

getopts('v');
$verbose = $opt_v;

my $dir = shift or die Usage();

if ( -d $dir ) {
  print "Removing $dir\n" if $verbose;
  my $nfiles = 0;
  my $ntries = 2;

  # FIXME why does it sometimes take more than one try?
  while ( -d $dir and $ntries-- > 0 ) {
    $nfiles += rmtree($dir, $verbose, 1);
  }
  print "$nfiles files removed\n" if $verbose;
  die "ERROR: Failed to completely remove $dir\n" if -d $dir;

} else {
  print "$dir doesn't exist; nothing to remove\n" if $verbose;
}

exit;


sub Usage
{
  my $usage = <<"EOF";
Usage: $0 <dir>

Removes the directory tree rooted at <dir>.

EOF
  $usage;
}