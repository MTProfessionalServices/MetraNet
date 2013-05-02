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

dim instance
Set instance = calltemplate.CreateInstance()

for each aj in calltemplate.GetAdjustments()
    wscript.echo "Call template aj template " & aj.DisplayName
Next

for each aj in instance.GetAdjustments()
    wscript.echo  "Call instance aj instance " & aj.DisplayName
Next
