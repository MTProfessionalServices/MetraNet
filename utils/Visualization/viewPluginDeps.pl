#!perl -w
use XML::Simple;
use File::Basename;
use Data::Dumper;

my $usage = "Usage: $0 <path to stage.xml>\n";

my $stage_xml = shift or die $usage;
if ( $stage_xml !~ /[:\/\\]/ ) {
  $stage_xml = "./$stage_xml";
}
die "File $stage_xml not found or not readable.\n" unless -r $stage_xml;

my $source_xs = new XML::Simple(keyattr    => ['processor'],
                                forcearray => ['dependson','dependency']);

my $xmlconfig = $source_xs->XMLin ($stage_xml)
  or die "Error parsing file $stage_xml.\n";

#print Dumper(%{$xmlconfig});

my $name = $xmlconfig->{stage}->{name}
  or die "Path /xmlconfig/stage/name not found in $stage_xml.\n";

my $dependencies = $xmlconfig->{stage}->{dependencies};
my $dependency   = $dependencies->{dependency};

die "Neither of the paths /xmlconfig/stage/dependencies or /xmlconfig/stage/dependencies/dependency were found in $stage_xml.\n"
  unless defined($dependencies) or defined($dependency);

my $dot_file = "$name.dot";

open DOT, ">$dot_file" or die "Error opening $dot_file for write.\n";

print DOT "digraph \"stage dependencies\" {\n";

print DOT "  \"$name\" [ style=filled, shape=rectangle, color=navy, fontsize=\"18\", fontcolor=white ];\n\n";

if ( defined($dependencies) ) {
  foreach (@{$dependencies->{dependson}}) {
    print DOT "  \"$name\" -> \"$_\"\n";
  }
}

if ( defined($dependency) ) {
  foreach $processor ( keys %{$dependency} ) {
    foreach (@{$dependency->{$processor}->{dependson}}) {
      print DOT "  \"$processor\" -> \"$_\"\n";
    }
  }
}

print DOT "}\n";

close DOT;

if ( system ("dotty $dot_file") ) {
  die "Error executing dotty.  Make sure GraphViz is installed and in your path.  Output in $dot_file\n"
}

exit;
