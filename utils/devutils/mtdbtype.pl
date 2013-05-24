#
# switch a configuration to use Oracle instead of SQL server
#

use strict;

use Getopt::Long;
use Pod::Usage;

use Win32::TieRegistry;


my $server = $ENV{COMPUTERNAME};


$Win32::TieRegistry::Registry->Delimiter("/");

my $extensionDir = $Win32::TieRegistry::Registry->{"LMachine/SOFTWARE/MetraTech/Install//InstallDir"} . "/extensions";
my $configDir = $Win32::TieRegistry::Registry->{"LMachine/SOFTWARE/MetraTech/NetMeter//ConfigDir"};

my $dataSource = "";
my $defaultDataSource = "$server" . "_ORACLE";

my $username = "";
my $defaultUsername = "nmdbo";
my $password = "";
my $defaultPassword = "nmdbo";
my $dbname = "";
my $defaultDBName = "NetMeter";
my $servername = "";
my $defaultServername = "";

my $mappingFile = "$configDir\\Queries\\DBInstall\\queryadaptermapping.txt";

sub FindFiles($$$)
{
	my ($root, $pattern, $files) = @_;

	local (*DIR_HANDLE);
	opendir(DIR_HANDLE, $root) || die "can't opendir $root: $!";

	ENTRY: foreach (readdir(DIR_HANDLE))
	{
		next ENTRY if ($_ eq "." || $_ eq "..");

		my $path = "$root\\$_";


		if (/$pattern$/i)
		{
			push @$files, $path;
		}

		if (-d $path)
		{
			FindFiles($path, $pattern, $files);
		}
	}
	closedir(DIR_HANDLE);
}


#
# verify a query adapter file by making sure the sql server, oracle,
# and common query files exist
#

sub VerifyQueryAdapterMappings()
{
	my @files;

#	push @files, "s:\\config\\Queries\\PCPropQueryBuilder\\QueryAdapter.xml";

	FindFiles($configDir, "QueryAdapter.xml", \@files);
	FindFiles($extensionDir, "QueryAdapter.xml", \@files);

	foreach my $queryAdapter (@files)
	{
#		print "adapter $queryAdapter\n";
		open (QUERYFILE, "$queryAdapter") or die "Cannot open file $queryAdapter";
		my $queryFile;
		LINE: while (<QUERYFILE>)
		{
			if (/<sql_server_query_file>(.*)<\/sql_server_query_file>/ && not /<!--/)
			{
				$queryFile = $1;
#				print "    SQL server: $1\n";
			}
			elsif (/<oracle_query_file>(.*)<\/oracle_query_file>/ && not /<!--/)
			{
				$queryFile = $1;
#				print "    Oracle: $1\n";
			}
			elsif (/<common_query_file>(.*)<\/common_query_file>/ && not /<!--/)
			{
				$queryFile = $1;
#				print "    Common: $1\n";
			}
			else
			{
#				print "NO MATCH: $_\n";
				next LINE;
			}
			my $fullname = $queryAdapter;
			$fullname =~ s/\\QueryAdapter.xml$/\\/i;
			$fullname .= "\\$queryFile";

#			print "  verifying $fullname\n";
			if (not -e $fullname)
			{
				print "$queryAdapter references $fullname\n";
			}
		}
		close(QUERYFILE);
	}
}

#
# generate a list of mappings for each query adapter file for
# oracle and sql server
#

sub GenerateQueryAdapterMappings()
{
	my @masterQueriesListFiles;
	FindFiles($configDir, "MasterQueriesList.xml", \@masterQueriesListFiles);
	FindFiles($extensionDir, "MasterQueriesList.xml", \@masterQueriesListFiles);

	# find the correct oracle mappings
	my %oracleMapping;
	my %sqlMapping;

	my $isOracle = 1;

	foreach my $queryList (@masterQueriesListFiles)
	{
		open (INPUT, "$queryList") or die "Failed to open file $queryList";

		my $directory;
		while (<INPUT>)
		{
			if (/dbtype="SQLServer"/)
			{
				$isOracle = 0;
			}
			elsif (/<directory>(.+)<\/directory>/)
			{
				$directory = $1;
			}
			elsif (/<QueriesFile>(.+)<\/QueriesFile>/)
			{
				my $queryFile = $1;

				my $fullFile = $directory;
				if ($fullFile =~ /^config/)
				{
					# file is in the config directory
					$fullFile =~ s/^config/$configDir/;
				}
				elsif ($fullFile =~ /^extensions/)
				{
					# file is in the extensions directory
					$fullFile =~ s/^extensions/$extensionDir/;
				}
				else
				{
					die "invalid query file directory found: $fullFile\n";
				}

				$fullFile .= "\\QueryAdapter.xml";

				$fullFile = lc($fullFile);

				if ($isOracle)
				{
					$oracleMapping{$fullFile} = $queryFile;
				}
				else
				{
					$sqlMapping{$fullFile} = $queryFile;
				}
			}
		}
	}

	close (INPUT);

	# find the correct SQL server mappings (they should be the ones in the
	# files as they stand
#	my %sqlMapping;
#
#	my @files;
#	FindFiles($configDir, "QueryAdapter.xml", \@files);
#	FindFiles($extensionDir, "QueryAdapter.xml", \@files);
#
#	foreach my $queryAdapter (@files)
#	{
#		open (QUERYFILE, "$queryAdapter") or die "Cannot open file $queryAdapter";
#		my $queryFile;
#		while (<QUERYFILE>)
#		{
#			if (/<query_file>(.*)<\/query_file>/)
#			{
#				$queryFile = $1;
#			}
#		}
#		close(QUERYFILE);
#
#		$queryAdapter = lc($queryAdapter);
#		$sqlMapping{$queryAdapter} = $queryFile;
#	}


	open (MAPPINGFILE, ">$mappingFile") or die "Unable to open mapping file $mappingFile\n";

	# the SQL mappings exist for each file (since they were retrieved from the files).
	# the Oracle mappings are a subset.
	
	foreach (keys %sqlMapping)
	{
		my $oracle = $oracleMapping{$_};
		my $sql = $sqlMapping{$_};
		if (!defined($oracle))
		{ $oracle = $sql; }

		if (!($oracle eq $sql))
		{ print MAPPINGFILE "$_==$oracle==$sql\n"; }
	}
	close (MAPPINGFILE);
}

sub ReadQueryAdapterMappings($$)
{
	my ($type, $mappings) = @_;

	open (MAPPINGFILE, "$mappingFile") or die "Unable to open mapping file $mappingFile\n";

	while (<MAPPINGFILE>)
	{
		/(.+)==(.+)==(.+)/ or die "invalid line in mappings file: $_";
		my $file = $1;
		my $oracle = $2;
		my $sql = $3;

		if ($type eq "oracle")
		{
			$$mappings{$file} = $oracle;
#			print "$file => $oracle\n";
		}
		else
		{
			$$mappings{$file} = $sql;
#			print "$file => $sql\n";
		}
	}

	close (MAPPINGFILE);
}


#
# change queryadapter files
#
sub ChangeQueryAdapterFiles($)
{
	my ($mappings) = @_;

	foreach my $queryAdapter (keys %$mappings)
	{
		my $queryFile = $$mappings{$queryAdapter};

		if ($queryFile)
		{
			# update the file with the new info
			rename ($queryAdapter, "$queryAdapter.old") or die "can't rename $queryAdapter: $!";

			open (OUTPUT, ">$queryAdapter") or die "Failed to open file $queryAdapter";

			open (INPUT, "$queryAdapter.old") or die "Failed to open file $queryAdapter.old";

			while (<INPUT>)
			{
				s/<query_file>.*<\/query_file>/<query_file>$queryFile<\/query_file>/;
				print OUTPUT $_;
			}

			close (INPUT);
			close (OUTPUT);

			print "Updated file: $queryAdapter\n";
		}
		else
		{
			print "Could NOT update file: $queryAdapter\n";
		}
	}
}

#
# change dbaccess files
#
sub ChangeDBAccessFiles($$)
{
	my ($dbtype, $dbaccessFiles) = @_;

	foreach my $dbaccess (@$dbaccessFiles)
	{
		open (INPUT, "$dbaccess") or die "Failed to open file $dbaccess";
		my $fileType;
		while (<INPUT>)
		{
			if (/<dbtype>\{SQL Server\}<\/dbtype>/)
			{
				$fileType = "sql";
			}
			elsif (/<dbtype>\{Oracle\}<\/dbtype>/)
			{ 
				$fileType = "oracle";
			}
		}
		close (INPUT);

		if (!$fileType)
		{
			print ("ERROR: $dbaccess has unidentified database type!\n");
		}
		elsif ($fileType ne $dbtype)
		{
			# update the file with the new info
			rename ($dbaccess, "$dbaccess.old") or die "can't rename $dbaccess: $!";

			open (INPUT, "$dbaccess.old") or die "Failed to open file $dbaccess.old";
			open (OUTPUT, ">$dbaccess") or die "Failed to open file $dbaccess";

			while (<INPUT>)
			{
				s/<dbusername>.+<\/dbusername>/<dbusername>$username<\/dbusername>/;
				s/<dbpassword>.+<\/dbpassword>/<dbpassword>$password<\/dbpassword>/;
				s/<dbname>.+<\/dbname>/<dbname>$dbname<\/dbname>/;

				if ($dbtype eq "oracle")
				{
					s/<dbaccess_type>ADO<\/dbaccess_type>/<dbaccess_type>ADO-DSN<\/dbaccess_type>/;
					s/<dbaccess_type>OLEDB<\/dbaccess_type>/<dbaccess_type>OLEDB-DSN<\/dbaccess_type>/;
					s/<dbtype>\{SQL Server\}<\/dbtype>/<dbtype>\{Oracle\}<\/dbtype>/;
					s/<provider>SQLOLEDB<\/provider>/<provider>MSDASQL<\/provider>/;

					# remove servername, print all other tags
					if (!/<servername>.*<\/servername>/)
					{
						print OUTPUT $_;
					}

					if (/<dbpassword>/)
					{
						print OUTPUT "    <datasource>$dataSource</datasource>\n";
					}


#		if (/<dbname>/)
#		{
#			print OUTPUT "    <dbtype>{Oracle}</dbtype>\n";
#		}
				}
				elsif ($dbtype eq "sql")
				{
					s/<dbaccess_type>ADO-DSN<\/dbaccess_type>/<dbaccess_type>ADO<\/dbaccess_type>/;
					s/<dbaccess_type>OLEDB-DSN<\/dbaccess_type>/<dbaccess_type>OLEDB<\/dbaccess_type>/;
					s/<dbtype>\{Oracle\}<\/dbtype>/<dbtype>\{SQL Server\}<\/dbtype>/;
					s/<provider>MSDASQL<\/provider>/<provider>SQLOLEDB<\/provider>/;

					# remove data source tags
					if (!/<datasource>.*<\/datasource>/)
					{
						print OUTPUT $_;					
					}

					# if servername is set, add the servername
					if ($servername && /<dbpassword>/)
					{
						print OUTPUT "    <servername>$servername</servername>\n";
					}
				}
			}

			close (INPUT);
			close (OUTPUT);
			print "Updated file: $dbaccess\n";
		}
	}
}

#
# command line options
#
my $dbtype = "";

my $sql = "";
my $oracle = "";

my $help = "";
my $man = "";

my $verify = "";

my %overrides = ();

my $result = GetOptions ("sql" => \$sql,
												 "oracle" => \$oracle,
												 "help" => \$help,
												 "man" => \$man,
												 "servername=s" => \$servername,
												 "datasource=s" => \$dataSource,
												 "username=s" => \$username,
												 "password=s" => \$password,
												 "dbname=s" => \$dbname,
												 "verify" => \$verify)
	or pod2usage(2);

pod2usage(1) if $help;

pod2usage(-exitstatus => 0, -verbose => 2) if $man;

if ($sql)
{ $dbtype = "sql"; }
elsif ($oracle)
{ $dbtype = "oracle"; }
elsif ($verify)
{
	VerifyQueryAdapterMappings();
	print "verification complete\n";
	exit;
}
else
{
	pod2usage(1);
}

if (!$dataSource)
{ $dataSource = $defaultDataSource; }

if (!$username)
{ $username = $defaultUsername; }

if (!$password)
{ $password = $defaultPassword; }

if (!$dbname)
{ $dbname = $defaultDBName; }

if (!$servername)
{ $servername = $defaultServername; }


if (not -e $mappingFile)
{
	print "Generating mappings for Oracle/SQL changes (done once)\n";
	GenerateQueryAdapterMappings();
}


__END__

if (not -e $mappingFile)
{
	die "unable to create mappings file $mappingFile\n";
}

print "Changing database type to $dbtype...\n";
print "Reading mappings for Oracle/SQL changes...\n";
my %mappings;
ReadQueryAdapterMappings($dbtype, \%mappings);


#
# change dbaccess files
#
my @dbaccessFiles;
FindFiles($configDir, "dbaccess.xml", \@dbaccessFiles);
FindFiles($extensionDir, "dbaccess.xml", \@dbaccessFiles);
ChangeDBAccessFiles($dbtype, \@dbaccessFiles);

#
# change queryadapter files
#

ChangeQueryAdapterFiles(\%mappings);




__END__


=head1 NAME

mtdbtype - Changes database type or location.

=head1 SYNOPSIS

mydbtype [options]

=head1 OPTIONS

=over 8

=item B<-sql>

Switches connection to SQL Server.

=item B<-oracle>

Switches connection to Oracle.

=item B<-datasource>

Oracle datasource name (works only with -oracle option).

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-verify>

Does some verification of queryadapter.xml files.

=back

=head1 DESCRIPTION

B<mtdbtype> Changes database type or location.

=cut
