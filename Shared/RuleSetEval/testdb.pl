#!perl -w

use strict;

use Win32::OLE;
use Win32::OLE::Variant;

my $PROP_TYPE_UNKNOWN = 0;
my $PROP_TYPE_DEFAULT = 1;
my $PROP_TYPE_INTEGER = 2;
my $PROP_TYPE_DOUBLE = 3;
my $PROP_TYPE_STRING = 4;
my $PROP_TYPE_DATETIME = 5;
my $PROP_TYPE_TIME = 6;
my $PROP_TYPE_BOOLEAN = 7;
my $PROP_TYPE_SET = 8;
my $PROP_TYPE_OPAQUE = 9;
my $PROP_TYPE_ENUM = 10;
my $PROP_TYPE_DECIMAL = 11;


#####################################################

#
# create the rule set evaluator
#
my $eval = Win32::OLE->new("MetraTech.MTRuleSetEvaluator.1");
$eval->ConfigureFromDB(3);

undef $eval;


__END__
my $pipelineControl = Win32::OLE->new("MetraPipeline.MTPipeline.1");
my $nameID = Win32::OLE->new("MetraPipeline.MTNameID.1");

my $durationID = $nameID->GetNameID("Duration");
my $rateID = $nameID->GetNameID("Rate");
my $surchargeStepID = $nameID->GetNameID("SurchargeStep");

my $sessServer = $pipelineControl->{SessionServer};


my $session = $sessServer->GetSession(0);


my $duration;
my $rate;
my $surchargeStep;

#
# set some properties and retreive the results
#
$session->SetLongProperty($durationID, 100);

if ($eval->Match($session))
{
	print "actions were executed\n";
}
else
{
	print "no actions were executed\n";
}

$duration = $session->GetLongProperty($durationID);

$rate = $session->GetDoubleProperty($rateID);
$surchargeStep = $session->GetLongProperty($surchargeStepID);


print "duration = $duration  rate = $rate  surcharge step = $surchargeStep\n";


#
# set some properties and retreive the results
#
$session->SetLongProperty($durationID, 10);

if ($eval->Match($session))
{
	print "actions were executed\n";
}
else
{
	print "no actions were executed\n";
}

$duration = $session->GetLongProperty($durationID);

$rate = $session->GetDoubleProperty($rateID);
$surchargeStep = $session->GetLongProperty($surchargeStepID);


print "duration = $duration  rate = $rate  surcharge step = $surchargeStep\n";



#
# cleanup these two in the correct order
#

undef $session;
undef $sessServer;


