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
dim rcpitype
Set rcpitype = pc.GetPriceableItemTypeByName("Flat Rate Recurring Charge")
dim rctemplate

set rctemplate= rcpitype.GetTemplates()(1)

if rctemplate.GetAdjustments().Count = 0 then
  for each ajtype in rcpitype.AdjustmentTypes
    wscript.echo ajType.ID & " " & rctemplate.ID
    Set aj = rctemplate.CreateAdjustment(ajtype.ID)
aj.AddExistingReasonCode(ac.getReasonCodeByName("Bankruptcy"))
  Next
  rctemplate.Save()
End if
