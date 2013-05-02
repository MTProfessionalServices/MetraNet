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

dim i
dim rc
i=0

for each rc in ac.GetReasonCodes()
  i=i+1
  wscript.echo("Reason Code " & i & ": " & rc.Name)
  dim objLocalized
  set objLocalized = rc.DisplayNames
 
  dim objLanguage
  for each objLanguage in objLocalized
    'wscript.echo "objLanguage is a [" & typename(objLanguage) & "]"
    wscript.echo "Language :" & objLanguage.LanguageCode & " = " & objLanguage.Value
  next	
Next


