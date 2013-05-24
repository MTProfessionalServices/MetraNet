Option explicit

Const PCDATE_TYPE_ABSOLUTE = 1


'TestReader
'TestRateScheduleWriter
TestRSReader

Sub DumpParamTable(table)
    wscript.echo "Name: " & Table.Name & "  ID: " & Table.ID
    Dim conditions, actions, item
    wscript.echo "-- conditions --"
    Set conditions = Table.ConditionMetaData
    For Each item in conditions
        wscript.echo item.PropertyName
    Next

    wscript.echo "-- actions--"
    Set actions = Table.ActionMetaData
    For Each item in actions
        wscript.echo item.PropertyName
    Next

End sub

Sub TestReader
    Dim catalog
    Set catalog = CreateObject("MetraTech.MTProductCatalog")
    Dim table
    Set table = catalog.GetParamTableDefinitionByName("metratech.com/rateconn")
'    Set table = catalog.GetParamTableDefinition(20460)

    DumpParamTable table
End sub

Sub TestRateScheduleWriter
    Dim schedule
    Set schedule = CreateObject("MetraTech.MTRateSchedule")

    Dim catalog
    Set catalog = CreateObject("MetraTech.MTProductCatalog")
    Dim table
    Set table = catalog.GetParamTableDefinitionByName("metratech.com/rateconn")

    Dim pricelist
    set pricelist = CreateObject("MetraTech.MTPriceList")

    pricelist.ID = 12022

    schedule.PriceList = pricelist
    schedule.ParameterTable = table
    schedule.Description = "sample rate schedule"

    Dim effective
    Set effective = schedule.EffectiveDate
    effective.StartDateType = PCDATE_TYPE_ABSOLUTE
    effective.EndDateType = PCDATE_TYPE_ABSOLUTE
    effective.StartDate = #4/2/2001#

    Dim rules
    Set rules = schedule.RuleSet
    rules.Read("s:\test\productcatalog\rules1.xml")

    
    DumpParamTable table

    schedule.SaveRules

    wscript.echo "schedule ID = " & schedule.ID
    wscript.echo "effective date ID = " & effective.ID

'    Dim writer
'    Set writer = CreateObject("MetraTech.MTRuleSetWriter")
'    writer.CreateWithID schedule.ID, table, rules
End sub


Sub TestTable
    Dim Table
    Set Table = CreateObject("MetraTech.MTParamTableDefinition")

    Dim cond
    Set cond = Table.AddConditionMetaData
    cond.PropertyName = "Derek"

    Set cond = Table.AddConditionMetaData
    cond.PropertyName = "Young"

    Set cond = Table.AddConditionMetaData
    cond.PropertyName = "cool"

    Dim coll
    Set coll = Table.ConditionMetaData


    Dim item
    For Each item in coll
        wscript.echo item.PropertyName
    Next
End Sub


Sub TestRSReader
    Dim reader
    Set reader = CreateObject("MetraTech.MTRateScheduleReader")
    Dim rs
    Set rs = reader.Find(15792)

    wscript.echo rs.Description

    Dim table
    Set table = rs.ParameterTable
    DumpParamTable Table

    Dim rules
    Set rules = rs.RuleSet

    
    Dim propset
    Set propset = rules.WriteToSet
    Dim buffer
    buffer = propset.WriteToBuffer

    wscript.echo buffer
End Sub
