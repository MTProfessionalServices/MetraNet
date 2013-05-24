# ------------------------------------------------------------------------
# This script will compare the query tags in the two file names passed in
# and will spit out the differences
# ------------------------------------------------------------------------
use strict;
require XML::Simple;
use Data::Dumper;

# ------------------------------------------------------------------------
# command line options
# ------------------------------------------------------------------------
if (@ARGV != 2) {
		die ("Usage: mtdiffsqloracle.pl <sqlfilename> <oraclefilename>\n");
}

use Win32::OLE qw(in with);

my $sqlserverfile = "";
my $oraclefile = "";

$sqlserverfile = @ARGV[0];
$oraclefile = @ARGV[1];

my $mtconfig = Win32::OLE->new('MetraTech.MTConfig.1');
my $propset = $mtconfig->ReadConfiguration($sqlserverfile, 0);
$sqlserverfile = "$ENV{TEMP}/diffsqlserver.xml";
$propset->Write($sqlserverfile);

$propset = $mtconfig->ReadConfiguration($oraclefile, 0);
$oraclefile = "$ENV{TEMP}/difforacle.xml";
$propset->Write($oraclefile);

my %hashSQLServerQueryTags;
my %hashOracleQueryTags;
my %hashSQLServerQueryTagsNotFoundInOracle;
my %hashSQLServerQueryTagsFoundInOracle;

# ------------------------------------------------------------------------
# program start
# ------------------------------------------------------------------------
print "Generating hash of sql server query tags in $sqlserverfile...\n";
GenerateHashOfSQLServerQueryTags();

print "Generating hash of oracle query tags in $oraclefile...\n";
GenerateHashOfOracleQueryTags();

print "Comparing the two hashs...\n";
CompareHashes();

#print "Tags found in both places...\n";
#PrintTagsFoundInBothPlaces();

print "Tags missing in oracle...\n";
PrintTagsNotFoundInOracle();

#print "Identical queries...\n";
#PrintIdenticalQueries();

# ------------------------------------------------------------------------
# generate a hash of SQL server query tags
# ------------------------------------------------------------------------
sub GenerateHashOfSQLServerQueryTags()
{
  my $xs = new XML::Simple(keyattr=>"query_tag");
	my $queries = $xs->XMLin ($sqlserverfile);
	#print Dumper (%{$queries});
	%hashSQLServerQueryTags = %{$queries->{mtconfigdata}->{query}};
}

# ------------------------------------------------------------------------
# generate a hash of Oracle query tags
# ------------------------------------------------------------------------
sub GenerateHashOfOracleQueryTags()
{
  my $xs = new XML::Simple(keyattr=>"query_tag");
	my $queries = $xs->XMLin ($oraclefile);
	#print Dumper (%{$queries});
	%hashOracleQueryTags = %{$queries->{mtconfigdata}->{query}};
}

# ------------------------------------------------------------------------
# generate a hash of Oracle query tags
# ------------------------------------------------------------------------
sub CompareHashes()
{
	foreach (keys %hashSQLServerQueryTags) 
	{
		#print "Starting with $_ \n";
		if ($hashOracleQueryTags{$_})
		{
			#print "Found $_ found in Oracle query file\n";
			$hashSQLServerQueryTagsFoundInOracle{$_} = $_;
		}
		else 
		{
			#print "Not found $_ in Oracle query file: $hashOracleQueryTags{$_}\n";
			$hashSQLServerQueryTagsNotFoundInOracle{$_} = $_;
		}
	}

	print "Comparison operation completed\n";
}


# ------------------------------------------------------------------------
# generate a hash of Oracle query tags
# ------------------------------------------------------------------------
sub PrintTagsFoundInBothPlaces()
{
	foreach (keys %hashSQLServerQueryTagsFoundInOracle) 
	{
		print "$_ \n";
	}
}

# ------------------------------------------------------------------------
# determine identical queries
# ------------------------------------------------------------------------
sub PrintIdenticalQueries
{
	my $count = 0;
	foreach (keys %hashSQLServerQueryTagsFoundInOracle) 
	{
		if ($hashSQLServerQueryTags{$_}->{query_string}
		 eq $hashOracleQueryTags{$_}->{query_string})
		{
			print "$_\n";
			$count++;
#			print "===================================\n";
#			print "$_\n";
#			print "$hashSQLServerQueryTags{$_}\n";
#			print "$hashOracleQueryTags{$_}\n";
		}
		else
		{
#			print "===NE ================================\n";
#			print "$_\n";
#			print "$hashSQLServerQueryTags{$_}\n";
#			print "$hashOracleQueryTags{$_}\n";
		}
	}

	my $total = keys %hashSQLServerQueryTagsFoundInOracle;
	my $percent = ($count / $total) * 100.0;
	print "$count of $total are identical ($percent%)\n";

	foreach (keys %hashSQLServerQueryTagsFoundInOracle) 
	{
		if ($hashSQLServerQueryTags{$_} eq $hashOracleQueryTags{$_})
		{
			print "    <query>\n";
      print "      <query_tag>$_</query_tag>\n";
      print "      <query_string>\n";
			print "        <![CDATA[\n";
			print "          $hashSQLServerQueryTags{$_}\n";
			print "        ]]>\n";
			print "      </query_string>\n";
      print "      <num_params>0</num_params>\n";
			print "    </query>\n";
		}
	}

}


# ------------------------------------------------------------------------
# generate a hash of Oracle query tags
# ------------------------------------------------------------------------
sub PrintTagsNotFoundInOracle()
{
	foreach (keys %hashSQLServerQueryTagsNotFoundInOracle) 
	{
		print "$_ \n";
	}
}

__END__
