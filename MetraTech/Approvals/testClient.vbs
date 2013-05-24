Dim objLoginContext, objSessionContext
Set objLoginContext = CreateObject("Metratech.MTLoginContext")
Set objSessionContext = objLoginContext.Login("su", "system_user", "su123")

'On Error Resume Next

'set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
'aHookHandler.SessionContext = objSessionContext
'call aHookHandler.RunHookWithProgid("MetraTech.BusinessEntity.Hook.BusinessEntityHook","")

dim objApprovals
set objApprovals= CreateObject("MetraTech.Approvals.SimplifiedClient")

objApprovals.SessionContext = objSessionContext
wscript.echo "Has Pending Changes:" & objApprovals.HasPendingChange("RateUpdate", "Rudi")
wscript.echo "Approvals Enabled [RateUpdate]:" & objApprovals.ApprovalsEnabled("RateUpdate")
wscript.echo "Approvals Allows Multiple Pending Changes [RateUpdate]:" & objApprovals.ApprovalAllowsMoreThanOnePendingChange("RateUpdate")

dim changeDetails
changeDetails = objApprovals.GetChangeDetails(475)
wscript.echo "Change Details For Change:" & changeDetails

wscript.echo ""
wscript.echo "Change Details Helper"
wscript.echo "====================="

dim objChangeDetailsHelper
set objChangeDetailsHelper = CreateObject("MetraTech.Approvals.ChangeDetailsHelper")

objChangeDetailsHelper("UpdatedValue") = "rudi"

wscript.echo "Property is " & objChangeDetailsHelper("UpdatedValue")
wscript.echo "Serialized is " & objChangeDetailsHelper.ToBuffer


objChangeDetailsHelper.FromBuffer(changeDetails)
wscript.echo "Rate Schedule Id:" & objChangeDetailsHelper("RateScheduleId")
