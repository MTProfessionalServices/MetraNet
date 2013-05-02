dim ac
dim pc
Dim aj
dim callaj
dim connaj


Set ac = CreateObject("MetraTech.Adjustments.AdjustmentCatalog")
Set pc = CreateObject("MetraTech.MTProductCatalog")
Dim login
Set login = CreateObject("Metratech.MTLoginContext")
Dim ctx
set ctx = login.Login("su", "system_user", "su123")

ac.Initialize(ctx)
pc.SetSessionContext(ctx)

'add all available reason codes to all adjustment templates
Set callpitype = pc.GetPriceableItemTypeByName("AudioConfCall")
Set connpitype = pc.GetPriceableItemTypeByName("AudioConfConn")
dim calltemplate
dim conntemplate

set calltemplate = callpitype.GetTemplates()(1)
set conntemplate = connpitype.GetTemplates()(1)

  

for each rc in ac.GetReasonCodes()
  for each callaj in calltemplate.GetAdjustments()
    callaj.AddExistingReasonCode(rc)
  next
  for each connaj in conntemplate.GetAdjustments()
    connaj.AddExistingReasonCode(rc)
  next
Next


calltemplate.Save()
conntemplate.Save()


dim ajrc
for each rc in ac.GetReasonCodes()
  for each callaj in calltemplate.GetAdjustments()
    wscript.echo callaj.GetApplicableReasonCodes().Count
    for each ajrc in callaj.GetApplicableReasonCodes()
      wscript.echo ajrc.DisplayName
    Next
  next
  for each connaj in conntemplate.GetAdjustments()
    for each ajrc in connaj.GetApplicableReasonCodes()
      wscript.echo ajrc.DisplayName
    Next
  next
Next


