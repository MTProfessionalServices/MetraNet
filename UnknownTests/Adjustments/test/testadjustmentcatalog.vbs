dim ac
Dim pc
Dim ajtype
Dim pitype

Set ac = CreateObject("MetraTech.Adjustments.AdjustmentCatalog")
Set pc = CreateObject("MetraTech.MTProductCatalog")

Set pitype = pc.GetPriceableItemTypeByName("AudioConfConn")
Dim login
Set login = CreateObject("Metratech.MTLoginContext")
Dim ctx
set ctx = login.Login("su", "system_user", "su123")

ac.Initialize(ctx)
pc.SetSessionContext(ctx)

Set ajtypes = ac.GetAdjustmentTypes(pitype.ID)
wscript.echo ajtypes.Count

for each ajtype in ajtypes

  for each prop in ajtype.Properties
    wscript.echo prop.Name & ": " & prop.Value
  Next

Next