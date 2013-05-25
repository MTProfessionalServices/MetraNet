
'#define MTPROGID_ASSIGNACTION       "MTAssignmentAction.MTAssignmentAction.1"
'#define MTPROGID_CONDITIONSET       "MTConditionSet.MTConditionSet.1"
'#define MTPROGID_SIMPLECOND         "MTSimpleCondition.MTSimpleCondition.1"
'#define MTPROGID_MTACTIONSET        "MTActionSet.MTActionSet.1"

Const PROP_TYPE_UNKNOWN = 0
Const PROP_TYPE_DEFAULT = 1
Const PROP_TYPE_INTEGER = 2
Const PROP_TYPE_DOUBLE = 3
Const PROP_TYPE_STRING = 4
Const PROP_TYPE_DATETIME = 5
Const PROP_TYPE_TIME = 6
Const PROP_TYPE_BOOLEAN = 7
Const PROP_TYPE_SET = 8
Const PROP_TYPE_OPAQUE = 9
Const PROP_TYPE_ENUM = 10
Const PROP_TYPE_DECIMAL = 11

' create the ruleset

Set ruleset = CreateObject("MTRuleSet.MTRuleSet.1")

Set rule = CreateObject("MTRule.MTRule.1")

Set actions = CreateObject("MTActionSet.MTActionSet.1")
Set action = CreateObject("MTAssignmentAction.MTAssignmentAction.1")
action.PropertyName = "Rate"
action.PropertyValue = 0.50
action.PropertyType = DOUBLE

actions.Add(action)

action.PropertyName = "ChargeType"
action.PropertyValue = 10
action.PropertyType = 

