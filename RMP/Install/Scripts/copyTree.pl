#!/usr/bin/perl
#------------------------------------------------------------------------------
# Script:      copyTree.pl
# Description: Copy an entire directory tree
# Author:      Simon Morton
#------------------------------------------------------------------------------
use Getopt::Std;
use File::Path;
use File::Copy;
use File::Basename;
use File::Find;
push @INC, dirname($0); # munge the include path so we can find libraries

getopts('vts');
my $verbose  = $opt_v;
my $summary  = $opt_s;
my $testmode = $opt_t;

my $src = shift or die Usage();
my $dst = (shift or ".");
my @exclude = @ARGV; # remaining arguments are patterns to exclude

if ( $verbose or $summary ) { 
  foreach (@exclude) {
    print "Excluding files and folders like $_\n";
  }
}

die "Directory $src not found\n" unless -d $src ;

my $ndirs = 0;
my $nfiles = 0;

find ({wanted => \&found, no_chdir => 1}, $src);

if ( $verbose or $summary ) { 
  print "$nfiles file".($nfiles==1?"":"s")." copied\n";
  print "$ndirs director".($ndirs==1?"y":"ies")." created\n";
}

exit;

sub found
{
  my ($srcpath, $dstpath) = ($_, $_);
  die "$srcpath not in $src\n"
    unless substr ($dstpath, 0, length $src, $dst) eq $src;

  if ( @exclude ) {
    # apply exclusion list
    foreach (@exclude) {
      if (basename($srcpath) =~ /$_/i) {
        print "Excluding $srcpath\n" if $verbose;
        return;
      }
    }
    if ( !-d dirname($dstpath) ) {
      print "Excluding $srcpath\n" if $verbose;
      return;
    }
  }

  if ( -d $srcpath ) {
    if ( !-d $dstpath ) {
      print "Creating $dstpath\n" if $verbose;
      if ( !$testmode ) {
        mkpath $dstpath
          or die "Error creating $dstpath\n";
      }
      $ndirs++;
    }
  } else { 
    print "Copying $srcpath to $dstpath\n" if $verbose; 
    if ( !$testmode ) {
      copy ($srcpath, $dstpath)
        or die "Error copying $srcpath to $dstpath\n";
    }
    if ( ++$nfiles%100 == 0 and $summary and !$verbose ) {
      print "$nfiles files copied\r";
    }
  }
}

sub Usage
{
  my $usage = << "EOF";

Usage: $0 [-vt] <src> [<dst>]

Copies the directory tree rooted at <src> to <dst>

Options:
 -v  verbose mode
 -t  test mode
EOF
  $usage;
}
