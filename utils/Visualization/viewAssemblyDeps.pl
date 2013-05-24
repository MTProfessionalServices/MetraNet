#!perl -w
use strict;
use File::Find;
use Getopt::Std;

my %opt;
getopts('v', \%opt);
my $verbose = $opt{v};

my %dep;

my $dir = (shift or "S:\\MetraTech");
print "Starting at $dir\n" if $verbose;

find (\&visit, $dir);

if ( keys %dep ) {
  my $dot_file = "dependencies.dot";

  open DOT, ">$dot_file" or die "Error opening $dot_file for writing.\n";
  print DOT "digraph \"assembly dependencies\" {\n";
  foreach (sort keys %dep) {
    print DOT "  $_;\n";
  }
  print DOT "}\n";
  close DOT;

  if ( system ("dotty $dot_file") ) {
    print "Error executing dotty.  Make sure GraphViz is installed and in your path.  Output in $dot_file\n";
  }

} else {
  print "Bummer, I couldn't find any dependencies.  Better luck next time.\n";
}

exit;

sub visit
{
  return unless /^make\.inc$/i;
  
  my $file_name = $_;
  my $file_path = $File::Find::name;

  # we are already CD'ed to the directory

  print "Processing $file_path\n" if $verbose;

  open IN, $file_name or die "Unable to open $file_path for reading";

  my $assembly;
  my @depends_on;

  while (<IN>) {
    my $line = $_;
    # slurp in any continuation lines
    while ($line =~ /^(.*)\\$/ and my $next_line = <IN>) {
      $line = $1.$next_line;
    }
    if ( $line =~ /^ASSEMBLIES\s*:=\s*(.*)$/i ) {
      @depends_on = split(/\s+/, $1);
    }
    if ( $line =~ /^CSHARPDLL\s*:=\s*([^\s]*)\s*/i ) {
      $assembly = $1.".dll";
    }
  }

  close IN;

  if ( defined($assembly) and $assembly =~ /^MetraTech\./i and @depends_on > 0 ) {
    print "$assembly depends on:\n" if $verbose;
    foreach (@depends_on) {
      next unless /^MetraTech\./i;
      my $dependency = "\"$_\" -> \"$assembly\"";
      if ( defined($dep{$dependency}) and $dep{$dependency} ne $file_path ) {
        print "Warning: Dependency $dependency found both in $dep{$dependency} and $file_path\n"
      }
      $dep{$dependency} = $file_path;
      print "  $_\n" if $verbose;
    }
  }
}
