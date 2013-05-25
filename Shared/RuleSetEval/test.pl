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
# initialize a rule set
#
my $ruleset = Win32::OLE->new("MTRuleSet.MTRuleSet.1");

my $rule = Win32::OLE->new("MTRule.MTRule.1");

my $actions;
my $action = Win32::OLE->new("MTAssignmentAction.MTAssignmentAction.1");

my $conditions;
my $condition = Win32::OLE->new("MTSimpleCondition.MTSimpleCondition.1");

#
# first rule
#

# actions
$actions = Win32::OLE->new("MTActionSet.MTActionSet.1");
$action->{PropertyName} = "Rate";
$action->{PropertyValue} = 0.50;
$action->{PropertyType} = $PROP_TYPE_DOUBLE;
$actions->Add($action);

$action->{PropertyName} = "SurchargeStep";
$action->{PropertyValue} = 10;
$action->{PropertyType} = $PROP_TYPE_INTEGER;
$actions->Add($action);

# conditions
$conditions = Win32::OLE->new("MTConditionSet.MTConditionSet.1");
$condition->{PropertyName} = "Duration";
$condition->{Test} = "less_than";
$condition->{Value} = 20;
$condition->{ValueType} = $PROP_TYPE_INTEGER;
$conditions->Add($condition);

$rule->LetProperty("Conditions", $conditions);
$rule->LetProperty("Actions", $actions);
#$rule->{Conditions} = $conditions;
#$rule->{Actions} = $actions;

$ruleset->Add($rule);

#
# second rule
#

# actions
$actions = Win32::OLE->new("MTActionSet.MTActionSet.1");
$action->{PropertyName} = "Rate";
$action->{PropertyValue} = 0.80;
$action->{PropertyType} = $PROP_TYPE_DOUBLE;
$actions->Add($action);

$action->{PropertyName} = "SurchargeStep";
$action->{PropertyValue} = 20;
$action->{PropertyType} = $PROP_TYPE_INTEGER;
$actions->Add($action);

# conditions
$conditions = Win32::OLE->new("MTConditionSet.MTConditionSet.1");
$condition->{PropertyName} = "Duration";
$condition->{Test} = "less_than";
$condition->{Value} = 50;
#$condition->{Test} = "greater_equal";
#$condition->{Value} = 20;

$condition->{ValueType} = $PROP_TYPE_INTEGER;
$conditions->Add($condition);

$rule->LetProperty("Conditions", $conditions);
$rule->LetProperty("Actions", $actions);
#$rule->{Conditions} = $conditions;
#$rule->{Actions} = $actions;
$ruleset->Add($rule);


#
# default actions
#
$actions = Win32::OLE->new("MTActionSet.MTActionSet.1");
$action->{PropertyName} = "Rate";
$action->{PropertyValue} = 0.00;
$action->{PropertyType} = $PROP_TYPE_DOUBLE;
$actions->Add($action);

$action->{PropertyName} = "SurchargeStep";
$action->{PropertyValue} = 0;
$action->{PropertyType} = $PROP_TYPE_INTEGER;
$actions->Add($action);
#$ruleset->LetProperty("DefaultActions", $actions);


$ruleset->Write("c:\\scratch\\ruleset.xml");


#
# create the rule set evaluator
#
my $eval = Win32::OLE->new("MetraTech.MTRuleSetEvaluator.1");
$eval->Configure($ruleset);

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


