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

dim rc
set rc=ac.CreateReasonCode()

rc.Name = "Test Script " & Now()
rc.DisplayName = rc.Name & " {US}"

 	dim objLanguage
	for each objLanguage in rc.DisplayNames
  		'wscript.echo "objLanguage is a [" & typename(objLanguage) & "]"
  		'wscript.echo "Language :" & objLanguage.LanguageCode & " = " & objLanguage.Value
		rc.DisplayNames.SetMapping objLanguage.LanguageCode, rc.Name & " {" & objLanguage.LanguageCode & "}"
	next

rc.Save

rc.DisplayNames.SetMapping "DE", "German Display Was Updated"

rc.Save

wscript.echo "The new reason code has an ID of " & rc.ID

