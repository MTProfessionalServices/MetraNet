
use strict;

use Win32::OLE;


my @languages = ("US", "DE", "CN");
#my @languages = ("US");


# list of product view exceptions (those that don't need to
# be localized)

my %exceptions;

if ($#ARGV == 0)
{
	my $exceptionFileName = $ARGV[0];

	open(FILEHANDLE, $exceptionFileName) or die "Failed to open $exceptionFileName";

	while(<FILEHANDLE>)
	{
		chomp();
		# lowercase
		tr/A-Z/a-z/;

		$exceptions{$_} = $_;
	}
}

#
# create the RCD
#

my $rcd = Win32::OLE->new("MetraTech.Rcd.1")
	or die ("CreateObject: ", Win32::OLE->LastError());

$rcd->Init(); # or die ("RCD::Init: ", Win32::OLE->LastError());

#
# create the locale config object
#
my $localeConfig = Win32::OLE->new("Metratech.LocaleConfig.1")
	or die ("CreateObject: ", Win32::OLE->LastError());

$localeConfig->Initialize(); # || die ("LocaleConfig::Initialize: ", Win32::OLE->LastError());


#    or die ("LocaleConfig::LoadLanguage:", Win32::OLE->LastError());


#my $localizedCollection = $localeConfig->{LocalizedCollection}
#    or die("LocaleConfig::GetLocalizedCollection", Win32::OLE->LastError());

#
# create the config reader
#
my $mtconfig = Win32::OLE->new("MetraTech.MTConfig.1")
	or die ("CreateObject: ", Win32::OLE->LastError());

#
# add fully qualified names to a list, given the path to
# a product view file
#
sub AddFQNs($$)
{
	my ($fqnRef, $fileName) = @_;

	# read the product view
	my $topSet = $mtconfig->ReadConfiguration($fileName, -1)
		or die "Unable to read file: $fileName";

	# read the product view name
	my $name = $topSet->NextStringWithName("name");

	print "  considering $name\n";

	my $lowerName = $name;
	$lowerName =~ tr/A-Z/a-z/;

	if ($exceptions{$lowerName})
	{
		print "  IGNORING $name\n";
		return;
	}

	# add the product view name itself to the list
	push @{$fqnRef}, $name;


	# read all the ptype values
	for (my $ptype = $topSet->NextSetWithName("ptype"); $ptype;
			 $ptype = $topSet->NextSetWithName("ptype"))
	{
		my $dn = $ptype->NextStringWithName("dn");

		# construct the fully qualified name
		my $fqn = "$name/$dn";

		# add this one to the list
		push @{$fqnRef}, $fqn;
	}
}


#print "Checking language: $lang\n";

my $path = "config\\productview\\*.msixdef";

my $fileList = $rcd->RunQuery($path, -1);

# read all the fully qualified names
my @fqns;

print "Reading product view files...\n";
foreach my $file (in $fileList) {
	AddFQNs(\@fqns, $file);
}

my @unlocalized;


print "--- Unlocalized fully qualified names ---\n";

my $errors = 0;
foreach my $lang (@languages)
{
	print "...Loading language $lang...\n";
	$localeConfig->LoadLanguage($lang);
	if (Win32::OLE->LastError())
	{
		die ("LocaleConfig::LoadLanguage:", Win32::OLE->LastError());
	}


	foreach my $fqn (@fqns)
	{
		my $localized;
		$localized = $localeConfig->GetLocalizedString($fqn, $lang);
		if (Win32::OLE->LastError())
		{
			die ("LocaleConfig::LoadLanguage:", Win32::OLE->LastError());
		}

		if (!$localized)
		{
#	    print "VALUE = $localized\n";
	    push @unlocalized, $fqn;
	    print "$lang $fqn\n";
	    $errors++;
		}
#	else
#	{
#	    print ("--> $lang $fqn $localized\n");
#	}
	}
}



#foreach my $fqn (@unlocalized)
#{
#    print ("  $fqn\n");
#}

print "Done: $errors unlocalized strings.\n";
