
Option explicit
'WriteRuleSet
ReadRuleSet

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

Sub WriteRuleSet
    wscript.echo "-- Testing assignment creation --"
    Dim assignment
    set assignment = CreateObject("MTAssignmentAction.MTAssignmentAction.1")
    assignment.PropertyName = "ActionProp"
    assignment.PropertyValue = 1.23
    wscript.echo "setting type to " & PROP_TYPE_DOUBLE
    assignment.PropertyType = PROP_TYPE_DOUBLE

    wscript.echo "-- action set creation --"
    Dim actionSet
    set actionSet = CreateObject("MTActionSet.MTActionSet.1")
    actionSet.Add(assignment)

    'Dim myaction
    'Set myaction = actionSet.Item("ACTIONPROP")
    'wscript.echo myaction.PropertyName


    wscript.echo "-- condition creation --"
    Dim cond
    set cond = CreateObject("MTSimpleCondition.MTSimpleCondition.1")
    cond.PropertyName = "ConditionProp"
    cond.Value = 100
    cond.Test = "equals"
    cond.ValueType = PROP_TYPE_INTEGER

    Dim cond2
    set cond2 = CreateObject("MTSimpleCondition.MTSimpleCondition.1")
    cond2.PropertyName = "ConditionProp2"
    cond2.Value = 101
    cond2.Test = "equals"
    cond2.ValueType = PROP_TYPE_INTEGER

    Dim cond3
    set cond3 = CreateObject("MTSimpleCondition.MTSimpleCondition.1")
    cond3.PropertyName = "ConditionProp3"
    cond3.Value = 101
    cond3.Test = "equals"
    cond3.ValueType = PROP_TYPE_INTEGER

    Dim cond4
    set cond4 = CreateObject("MTSimpleCondition.MTSimpleCondition.1")
    cond4.PropertyName = "ConditionProp4"
    cond4.Value = 101
    cond4.Test = "equals"
    cond4.ValueType = PROP_TYPE_INTEGER


    wscript.echo "-- conditionset creation --"
    Dim conditionSet
    set conditionSet = CreateObject("MTConditionSet.MTConditionSet.1")
    conditionSet.Add(cond)
    conditionSet.Add(cond2)
    conditionSet.Add(cond3)
    conditionSet.Add(cond4)


    'Dim mycondition
    'Set mycondition = conditionSet.Item("CONDITIONPROP2")
    'wscript.echo mycondition.PropertyName

    wscript.echo " ---> count = " & conditionSet.Count

    for each cond in conditionSet
        wscript.echo "========== Name = " & cond.PropertyName
    next

    wscript.echo "-- rule creation --"
    Dim rule
    set rule = CreateObject("MTRule.MTRule.1")
    rule.Actions = actionSet
    rule.Conditions = conditionSet

    wscript.echo "-- ruleset creation --"
    Dim ruleset
    set ruleset = CreateObject("MTRuleSet.MTRuleSet.1")
    ruleset.Add(rule)
    ruleset.DefaultActions = actionSet

    wscript.echo "-- writing --"
    ruleset.Write("e:\scratch\rulewrite.xml")
End sub




Sub ReadRuleSet
    wscript.echo "-- Testing rule set --"
    Dim ruleset
    set ruleset = CreateObject("MTRuleSet.MTRuleSet.1")
    ruleset.Read("e:\scratch\rulewrite.xml")



    wscript.echo " Rules-->"
    Dim rule
    for each rule in ruleset
        wscript.echo " Actions-->"
        Dim actions, action
        set actions = rule.Actions
        for each action in actions
            wscript.echo "  Property name: " & action.PropertyName
            wscript.echo "  Property value: " & action.PropertyValue
        next
        wscript.echo " Conditions-->"
        Dim conditions, condition
        set conditions = rule.Conditions
        for each condition in conditions
            wscript.echo "  Property name: " & condition.PropertyName
            wscript.echo "  Test: " & condition.Test
            wscript.echo "  Value: " & condition.Value
        next
    next
    wscript.echo " Default Actions-->"
    wscript.echo "-- Testing action set --"
    Dim actionset
    set actionset = ruleset.DefaultActions
    If Not actionset Is Nothing then
        for each action in actionset
            wscript.echo " Property name: " & action.PropertyName
            wscript.echo " Property value: " & action.PropertyValue
        Next
    End If


    wscript.echo "-- Writing rule set --"
    ruleset.Write("e:\scratch\rule3out.xml")
End sub

    ' wscript.echo "-- Testing assignment action object(s) --"
' set action = CreateObject("MTAssignmentAction.MTAssignmentAction.1")
' action.PropertyValue = 1.23
' action.PropertyName = "Test1"
' wscript.echo "Property name: " & action.PropertyName
' wscript.echo "Property value: " & action.PropertyValue



' wscript.echo "-- Testing simple condition object(s) --"
' set condition = CreateObject("MTSimpleCondition.MTSimpleCondition.1")
' wscript.echo "Property name: " & condition.PropertyName
' wscript.echo "Test: " & condition.Test
' wscript.echo "Value: " & condition.Value


' wscript.echo "-- Testing action set --"
' set actionset = CreateObject("MTActionSet.MTActionSet.1")

' for each action in actionset
'       wscript.echo " Property name: " & action.PropertyName
'       wscript.echo " Property value: " & action.PropertyValue
' next


' wscript.echo "-- Testing rule --"
' set rule = CreateObject("MTRule.MTRule.1")

' wscript.echo " Actions-->"
' set actions = rule.Actions
' for each action in actions
'       wscript.echo "  Property name: " & action.PropertyName
'       wscript.echo "  Property value: " & action.PropertyValue
' next

' wscript.echo " Conditions-->"
' set conditions = rule.Conditions
' for each condition in conditions
'       wscript.echo "  Property name: " & condition.PropertyName
'       wscript.echo "  Test: " & condition.Test
'       wscript.echo "  Value: " & condition.Value
' next



' wscript.echo "-- Testing rule set --"
' set ruleset = CreateObject("MTRuleSet.MTRuleSet.1")

' wscript.echo " Rules-->"

' for each rule in ruleset
'       wscript.echo " Actions-->"
'       set actions = rule.Actions
'       for each action in actions
'               wscript.echo "  Property name: " & action.PropertyName
'               wscript.echo "  Property value: " & action.PropertyValue
'       next

'       wscript.echo " Conditions-->"
'       set conditions = rule.Conditions
'       for each condition in conditions
'               wscript.echo "  Property name: " & condition.PropertyName
'               wscript.echo "  Test: " & condition.Test
'               wscript.echo "  Value: " & condition.Value
'       next
' next






