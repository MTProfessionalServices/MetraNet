#!perl -w
use strict;

use File::Find;

find (\&checkMakeDotInc, "S:");

exit;

sub checkMakeDotInc
{
  return unless /^make.inc$/i;
  die "This shouldn't happen" unless $File::Find::name =~ /^S:\/(.*)\/make.inc/i;
  my $actual_rel_dir = $1;

  open FILE, $_ or die "Can't open $File::Find::name";
  while (<FILE>) {
    next unless /^\s*RELATIVEDIR\s*:=\s*(.*)\s*$/;
    (my $rel_dir = $1) =~ s/\\/\//g;
    if ( $rel_dir ne $actual_rel_dir ) {
      print "$File::Find::name: $_\n";
    }
    last;
  }
  close FILE;
}
