#!perl -w
#
# Name:        syncDirs.pl
# Author:      Simon Morton
# Description: Scan local Development tree and optionally delete any directories
#              that are not found in a saved hash map of the development tree.
#
# Options:     -i  build and persist the hash map (called by nightly build scripts after checkout)
#              -v  be a little bit more verbose
#
use strict;
require 5.6.1;
use Getopt::Std;
use Cwd;
use File::Basename;
use File::Find;
use File::Path;
use Storable;

my %opts;
getopts('iv', \%opts);
my $init    = $opts{i}; # build and persist the hash
my $verbose = $opts{v};

# whirly progress thingy
my $progress_count = 0;
my $progress_increment = 0;
my @progress_indicator = ("-",">","|","<");

# try to figure out where Development root is

(my $my_dir = dirname $0) =~ s/\\/\//g;

print "I live in $my_dir\n" if $verbose;

if ( $my_dir =~ /^S:\/(.*)$/i ) {
  my $rel_dir = $1;
  my $s_mapped_to;
  foreach (`subst`) {
    next unless /^S:\\: => (.*)$/;
    $s_mapped_to = $1;
    last;
  }
  die "Can't figure out where S: is mapped" unless defined($s_mapped_to);
  ($my_dir = "$s_mapped_to/$rel_dir") =~ s/\\/\//g;
  print "but I think I really live in $my_dir\n" if $verbose;
}

die "Error: path $my_dir not deep enough\n" unless $my_dir =~ /^(.*)(\/[^\/]+){3}$/;

my $dev_root = $1;
chdir $dev_root or die "Error chdiring into $dev_root";

# We made it!

print "Found Development root at $dev_root\n";

my $tree;
my $found;
  
$| = 1; # enable autoflush

if ( $init ) {
  $tree = {};

} else {
  my $read_path  = "\\\\krypton\\Builds\\Tree.dat";
  print "Loading Tree from $read_path...";
  $tree = retrieve ($read_path) or die "Error retrieving tree from $read_path";
  print "Done\n";
  $found = {};
}

# walk the local development tree

find ({wanted => \&visit, no_chdir => 1}, ".");

if ( $init ) {
  my $write_path = $ENV{BUILDROOT}."\\Tree.dat";   # only krypton can update the master
  print "Storing Tree to $write_path...";
  store $tree, $write_path or die "Error storing tree to $write_path";
  print "Done\n";

} else {
  print "Scanning Tree...Done\n";

  if ( keys %{$found} ) {
    # build delete list, removing any directories with an ancestor also to be deleted
    my @delete;
    foreach (sort keys %{$found}) {
      if ( $#delete < 0 or                       # delete list is empty
           index($_,$delete[$#delete]) != 0 ) {  # previous folder is an ancestor of current
        push @delete, $_;
      }
    }
    print "The following directories appear to no longer exist:\n";
    foreach (@delete) {
      print "  $_\n";
    }

    print "Would you like to delete them? (y/n)[n]: ";

    if ( <STDIN> =~ /^y/i ) {
      print "Are you sure? (y/n)[n]: ";

      if ( <STDIN> =~ /^y/i ) {
        foreach (@delete) {
          progress("Deleting directories...",1);
          rmtree $_ or die "Error: Can't remove $_\n";
        }
        print "Deleting directories...Done";

      } else {
        print "Bailing.  That was a close one.\n\n";
        print "I didn't want to create an extra boolean variable to record whether\n";
        print "you actually deleted the folders so you will have to run me again and\n";
        print "say no the first time if you want me to save a batch file for you.\n";
      }

    } else {
      (my $bat_path = "$my_dir/delete_dirs.bat") =~ s/\//\\/g;
      open BAT, ">$bat_path" or die "Can't open $bat_path for writing\n";
      foreach (@delete) {
        (my $full_path = "$dev_root\\$_") =~ s/\//\\/g;
        print BAT "rm -rf \"$full_path\"\n"; 
      }
      close BAT;
      print "Batch file created in case you change your mind:\n";
      print "$bat_path\n";
    }

  } else {
    print "All directories found appear to be valid.  Looks like you are good to go!\n";
  }
}

exit;

sub visit
{
  if ( -d $_ and /^\.\/(.*)$/ ) {
    my $rel_path = lc($1);

    if ( $init ) {
      # add this dir to the hash 
      $tree->{$rel_path} = 1;

    } else {
      # add this dir to the found list if not in the hash 
      $found->{$rel_path} = 1 unless defined($tree->{$rel_path});
      progress("Scanning Tree...",20);
    }
  }
}

sub progress
{
  my $message = shift;
  my $increment = shift;
  if ( ++$progress_increment >= $increment ) {
    $progress_count++;
    print "$message$progress_indicator[$progress_count%4]\r";
    $progress_increment = 0;
  }
}
