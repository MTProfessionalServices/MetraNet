
option explicit
Const TC = """C:\Program Files\Compuware\PCShared\TCDev.exe"""
Const out = "e:\scratch"
Const cscript = "c:\winnt\system32\cscript.exe"
const testdb = "t:\Development\Core\MTProductCatalog"

dim shell
set shell = WScript.CreateObject("WScript.Shell")


dim scripts
scripts = Array( "AggregateCharge.wsf", "Collection.wsf", "Counter.vbs", "Cycle.wsf", "Discount.wsf", "FilterPriceableItemDump.wsf", "NonRecurringCharge.wsf", "ParamTable.wsf", "PCTimeSpan.wsf", "PriceableItem.wsf", "PriceableItemDump.wsf", "PriceableItemType.wsf", "PriceableItemTypeDump.wsf", "PriceList.wsf", "PriceListMapping.wsf", "ProductOffering.wsf", "ProductOfferingDump.wsf", "Properties.wsf", "RateSchedule.wsf", "RecurringCharge.wsf", "RuleSet.wsf", "SimpleSetup.wsf", "Subscriptions.vbs")

dim script, i
for i = LBound(scripts) to UBound(scripts)
    script = scripts(i)
    UpdateCoverage script
Next

sub UpdateCoverage(script)
    dim cmd
    cmd = TC & " /B /G " & out & "\merge.tcm" & " /S " & out & "\" & script & ".tcs " & cscript & " """ & testdb & "\" & script & """" & " 2>&1 >> e:\scratch\cov.txt"
    wscript.echo cmd
    shell.Run cmd, 1, true
end sub


