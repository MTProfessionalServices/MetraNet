
option explicit 

on error resume next

Const kTariffConfigPath			= "RMP\config\Queries\DBInstall\PopulateTariff"
Const kTariffConfigFile			= "tariff_install.xml"

Const kV20SecConfigPath                 = "RMP\config\Queries\DBInstall\v20\SP"
const kV20SecConfigFileOracle		= "MTDBobjects_v20_oracle_SP.xml"

Const strInstallDir = "c:\metratech\"
Const kCoreExtensionDir			= "Core"
Const kOracle                           = 1


dim objInstallConfig, strCoreProdViewPath, objProductView, fso, objDir, Day_O_The_Month, nIndex
dim strAcctName,strAcctPwd, strAcctNameSpace, strAcctLanguage, nAcctID, objAccountView, nDBMSType


wscript.echo "-- Creating InstallConfigObj --"
set objInstallConfig = CreateObject("InstallConfig.InstallConfigObj")
if err then
	wscript.echo "ERROR: " & err.description	
end if

if objInstallConfig is nothing then
	wscript.echo "Object is nothing"
end if

wscript.echo "-- Initializing Oracle DB Operations --"
objInstallConfig.InitializeDBOperations_Oracle "system", "manager", "NetMeter", "nemiga_oracle", "nmdbo", "nmdbo", 1000
if err then
	wscript.echo "ERROR: " & err.description	
end if

wscript.echo "-- Initializing Core DB Schema --"
objInstallConfig.InstallCoreDBSchema
if err then
	wscript.echo "ERROR: " & err.description	
end if

wscript.echo "-- Installing DB Extension Tables --"
objInstallConfig.InstallDBExtensionTables "d:\development\config\Queries\DBInstall\v20", "MTDBobjects_v20_oracle.xml"
if err then
	wscript.echo "ERROR: " & err.description	
end if

wscript.echo "-- Install Description Table --"
objInstallConfig.InstallDescriptionTable
if err then
	wscript.echo "ERROR: " & err.description	
end if

wscript.echo " ----- Create the tariff extension table  ----"
objInstallConfig.InstallDBExtensionTables strInstallDir & kTariffConfigPath, kTariffConfigFile
if err then
	wscript.echo "ERROR: " & err.description	
end if


wscript.echo " ----- Add/Delete Product Views -----"
strCoreProdViewPath = strInstallDir & "RMP\Extensions\" & kCoreExtensionDir & "\config\productview\"

wscript.echo "----- Creating MTProductViewOps object ----"
Set objProductView = CreateObject("MTProductView.MTProductViewOps")
If err Then
	wscript.echo "ERROR: " & err.description	
end if
	
Set fso = CreateObject("Scripting.FileSystemObject")
If err Then
	wscript.echo "ERROR: " & err.description	
end if
	
wscript.echo " ---- Iterating Product Views for " & strExtProdViewPath "
Set objDir = fso.GetFolder(strExtProdViewPath)
	
DoProductViewAction strExtProdViewPath, objDir, "Add", objProductView, fso

wscript.echo "-- Set object to nothing --"
set objProductView = Nothing
set fso = Nothing
set objDir = Nothing


wscript .echo "  ----Set up test accounts ---"
Day_O_The_Month = 30
		
strAcctName = "demo"
strAcctPwd = "demo123"
strAcctNameSpace = "mt"
strAcctLanguage = "US"
		
wscript.echo " -----Creating test account for: " & strAcctName & " : " & strAcctPwd & " : " & _
		strAcctNameSpace & " : " & strAcctLanguage & " : " & Day_O_The_Month --- "
				
objInstallConfig.AddDBAccount strAcctName, strAcctPwd, strAcctNameSpace, strAcctLanguage, Day_O_The_Month
If err Then
	wscript.echo "ERROR: " & err.description	
end if

strAcctName = "hanzel"
strAcctPwd = "h"
strAcctNameSpace = "mt"
strAcctLanguage = "DE"
		
wscript.echo " -----Creating test account for: " & strAcctName & " : " & strAcctPwd & " : " & _
		strAcctNameSpace & " : " & strAcctLanguage & " : " & Day_O_The_Month --- "
				
objInstallConfig.AddDBAccount strAcctName, strAcctPwd, strAcctNameSpace, strAcctLanguage, Day_O_The_Month
If err Then
	wscript.echo "ERROR: " & err.description	
end if


strAcctName = "csr1"
strAcctPwd = "csr123"
strAcctNameSpace = "csr"
strAcctLanguage = "US"
		
wscript.echo " -----Creating test account for: " & strAcctName & " : " & strAcctPwd & " : " & _
		strAcctNameSpace & " : " & strAcctLanguage & " : " & Day_O_The_Month --- "
				
objInstallConfig.AddDBAccount strAcctName, strAcctPwd, strAcctNameSpace, strAcctLanguage, Day_O_The_Month
If err Then
	wscript.echo "ERROR: " & err.description	
end if

strAcctName = "ops"
strAcctPwd = "ops123"
strAcctNameSpace = "ops"
strAcctLanguage = "US"
		
wscript.echo " -----Creating test account for: " & strAcctName & " : " & strAcctPwd & " : " & _
		strAcctNameSpace & " : " & strAcctLanguage & " : " & Day_O_The_Month --- "
				
objInstallConfig.AddDBAccount strAcctName, strAcctPwd, strAcctNameSpace, strAcctLanguage, Day_O_The_Month
If err Then
	wscript.echo "ERROR: " & err.description	
end if


strAcctName = "rm"
strAcctPwd = "rm123"
strAcctNameSpace = "rate"
strAcctLanguage = "US"
		
wscript.echo " -----Creating test account for: " & strAcctName & " : " & strAcctPwd & " : " & _
		strAcctNameSpace & " : " & strAcctLanguage & " : " & Day_O_The_Month --- "
				
objInstallConfig.AddDBAccount strAcctName, strAcctPwd, strAcctNameSpace, strAcctLanguage, Day_O_The_Month
If err Then
	wscript.echo "ERROR: " & err.description	
end if
wscript.echo "Successful Execution"

strAcctName = "mcm1"
strAcctPwd = "mcm123"
strAcctNameSpace = "mcm"
strAcctLanguage = "US"
		
wscript.echo " -----Creating test account for: " & strAcctName & " : " & strAcctPwd & " : " & _
		strAcctNameSpace & " : " & strAcctLanguage & " : " & Day_O_The_Month --- "
				
objInstallConfig.AddDBAccount strAcctName, strAcctPwd, strAcctNameSpace, strAcctLanguage, Day_O_The_Month
If err Then
	wscript.echo "ERROR: " & err.description	
end if



wscript.echo " -------Adding account mappings ------"
strAcctName = "GL123"
strAcctNameSpace = "metratech.com/external"
nAcctID = 123
	
wscript.echo "-------- Creating account mapping for " & strAcctName & " : " & strAcctNameSpace & " : " & nAcctID ---- "
objInstallConfig.AddDBAccountMappings strAcctName, strAcctNameSpace, nAcctID
If err Then
	wscript.echo "ERROR: " & err.description	
end if


wscript.echo " ----- Installing Account Views -----"

wscript.echo " ------ Creating MTAccountServer object for Internal ----"
Set objAccountView = CreateObject("MTAccount.MTAccountServer")
If err Then
	wscript.echo "ERROR: " & err.description	
end if
objAccountView.Initialize "internal"
objAccountView.Install
If err Then
	wscript.echo "ERROR: " & err.description	
end if
set objAccountView = Nothing

wscript.echo " ------ Creating MTAccountServer object for LDAP ----"
Set objAccountView = CreateObject("MTAccount.MTAccountServer")
If err Then
	wscript.echo "ERROR: " & err.description	
end if
objAccountView.Initialize "LDAP"
objAccountView.Install
If err Then
	wscript.echo "ERROR: " & err.description	
end if
set objAccountView = Nothing


wscript " ----- populate account view entry ---- "
if PopulateAccountViewEntry(123) then
   wscript.echo "----- successfully added account view entry for demo account -----"
else
   wscript.echo "------failed to add account view entry for demo account ------"
end if

if PopulateAccountViewEntry(124) then
   wscript.echo "----- successfully added account view entry for account 124 -----"
else
   wscript.echo "------failed to add account view entry for account 124 ------"
end if

if PopulateAccountViewEntry(125) then
   wscript.echo "----- successfully added account view entry for account 125 -----"
else
   wscript.echo "------failed to add account view entry for account 125 ------"
end if

if PopulateAccountViewEntry(126) then
   wscript.echo "----- successfully added account view entry for account 126 -----"
else
   wscript.echo "------failed to add account view entry for account 126 ------"
end if

if PopulateAccountViewEntry(127) then
   wscript.echo "----- successfully added account view entry for account 127 -----"
else
   wscript.echo "------failed to add account view entry for account 127 ------"
end if


if PopulateAccountViewEntry(128) then
   wscript.echo "----- successfully added account view entry for account 128 -----"
else
   wscript.echo "------failed to add account view entry for account 128 ------"
end if

if PopulateAccountViewEntry(129) then
   wscript.echo "----- successfully added account view entry for account 129 -----"
else
   wscript.echo "------failed to add account view entry for account 129 ------"
end if


'now for the new stuff
nDBMSType = kOracle 'for testing
if (nDBMSType = kOracle) Then
  objInstallConfig.InstallDBExtensionTables strInstallDir & kV20SecConfigPath, kV20SecConfigFileOracle
  if (err)
	wscript.echo "ERROR: " & err.description	
  end if
  wscript.echo "----- Printing out the params sent to InstallDBExtensionTables: ----"
  wscript.echo strInstallDir & kV20SecConfigPath
  wscript.echo kV20SecConfigFileOracle
endif 

wscript.echo "----- final database configuration done -----"
wscript.echo " ----- After this is install product catalog schema and add pc intervals for usage server ---"

set objInstallConfig = Nothing

' --------------- Install Oracle Stuff -----------------------------'








Function DoProductViewAction (strPath, objDirPath, strAction, objProductView, fso)
	Dim SubDirs
	Dim Files
	Dim Item
	Dim strRelativePath

	Set Files = objDirPath.Files

	For Each Item in Files
		If (fso.GetExtensionName(Item.Path) = "msixdef") Then
			strRelativePath = Trim(Right(Item.Path, (Len(Item.Path) - Len(strPath))))

			If (strAction = "Add") Then
				objProductView.AddProductView(strRelativePath)
			Else
				objProductView.DropProductView(strRelativePath)
			End If
		End If
	Next
	
	Set SubDirs = objDirPath.SubFolders
	If (SubDirs.count = 0) Then
		Exit Function
	Else
		For Each Item in SubDirs
			DoProductViewAction strPath, Item, strAction, objProductView, fso
		Next
	End If
End Function






Function PopulateAccountViewEntry (ByVal nAccountID)
	Dim objAccountView 
	Dim objPropCollection 
	Dim objNameID
	Dim Timezone

	On Error Resume Next


	PopulateAccountViewEntry = TRUE	'*** Assume success ***
  
	Set objAccountView = CreateObject("MTAccount.MTAccountServer")
        If err Then
	   wscript.echo "ERROR: " & err.description	
        end if
	
	objAccountView.Initialize "Internal"
        If err Then
	   wscript.echo "ERROR: " & err.description	
        end if
	
	Set objPropCollection = CreateObject("MTAccount.MTAccountPropertyCollection")
        If err Then
	   wscript.echo "ERROR: " & err.description	
        end if
	
	Set objNameID = CreateObject("MetraPipeline.MTNameID")
        If err Then
                wscript.echo "ERROR: " & err.description	
		Set objAccountView = Nothing
		Set objPropCollection = Nothing
		PopulateAccountViewEntry = False
		Exit Function
	End If

       'If the accountview is being added for the csr account, account_id 125, then set the time
       'zone id to GMT

        If (nAccountID = 125) Then
          Timezone = objNameID.GetNameID("Global/TimeZoneID/(GMT) Monrovia, Casablanca")
        else
          Timezone = objNameID.GetNameID("Global/TimezoneID/(GMT-05:00) Eastern Time (US & Canada)")
        End If

	objPropCollection.Add "id_acc", CLng(nAccountID)                          
	objPropCollection.Add "tariffID", objNameID.GetNameID("metratech.com/Tariffs/TariffID/Default")
	objPropCollection.Add "taxexempt", "Y"
	objPropCollection.Add "geocode", 220170140
	objPropCollection.Add "timezoneID", CLng(Timezone)
	objPropCollection.Add "PaymentMethod", objNameID.GetNameID("metratech.com/accountcreation/PaymentMethod/CashOrCheck")
	objPropCollection.Add "AccountStatus", objNameID.GetNameID("metratech.com/accountcreation/AccountStatus/Active")
	objPropCollection.Add "SecurityQuestion", objNameID.GetNameID("metratech.com/accountcreation/SecurityQuestion/Pin")
	objPropCollection.Add "InvoiceMethod", objNameID.GetNameID("metratech.com/accountcreation/InvoiceMethod/None")
	objPropCollection.Add "UsageCycleType", objNameID.GetNameID("metratech.com/BillingCycle/UsageCycleType/Monthly") 
	objPropCollection.Add "SecurityAnswer", "None"
	objPropCollection.Add "StatusReasonOther", "No other reason"
	objPropCollection.Add "TaxExemptID", "1235467"
	objPropCollection.Add "StatusReason", objNameID.GetNameID("metratech.com/accountcreation/StatusReason/AccountTerminated")
	objPropCollection.Add "Language", objNameID.GetNameID("Global/LanguageCode/US")
	objPropCollection.Add "Currency", "USD"
        If err Then
		Set objAccountView = Nothing
		Set objPropCollection = Nothing
		Set objNameID = Nothing
		PopulateAccountViewEntry = False
		Exit Function
	End If
	
	objAccountView.AddData "Internal", objPropCollection
	If err Then
		Set objAccountView = Nothing
		Set objPropCollection = Nothing
		Set objNameID = Nothing
		PopulateAccountViewEntry = False
		Exit Function
	End If
	
	Set objAccountView = Nothing
	Set objNameID = Nothing
	Set objPropCollection = Nothing

End Function