'******************************************************************************************
'*
'* Copyright 2000 by MetraTech Corporation
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corporation MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corporation,
'* and USER agrees to preserve the same.
'*
'* Created By:  Anagha Rangarajan
'* These functions upgrade MetraTech Platform database from V2.1.1 to V3.0.1
'*
'******************************************************************************************

option Explicit

'*** Global Constants ***
Const kRetVal_SUCCESS			= 1
Const kRetVal_USEREXIT			= 2
Const kRetVal_ABORT				= 3
Const kRetVal_SUSPEND			= 4
Const kRetVal_SKIPTOEND			= 5

'*** File System Object (fso) Open Arguments ***
Const ForReading				= 1
Const ForWriting				= 2
Const ForAppending				= 8	

Const TEMP_PATH					= "c:\temp\"
Const INSTALL_LOG				= "\MetraTech_Install.log"
Const PRESSERVER_PATH				= "RMP\PresentationServer\bin\"
Const SHAREDEXEC_PATH				= "RMP\SharedExecutables\"

Const VBHide					= 0



dim strInstallDir
dim strAdminID
dim strAdminPwd
dim strDBName
dim strDBHostName

Main

Public Function Main() ' As Boolean
	dim numargs, arg
	
	numargs = 0

	if wscript.arguments.length <> 8 then
		printusage
		exit function
	end if
	while numargs < wscript.arguments.length
		arg = LCase(wscript.arguments(numargs))
	
	
		Select Case arg
			
				
			case  "-dbname"
				numargs = numargs + 1
				if numargs >= wscript.arguments.length then
					PrintUsage
					Exit Function
				end if
				strDBName = wscript.arguments(numargs)
			
	
			case "-salogon"
				numargs = numargs + 1
				if numargs >= wscript.arguments.length then
					PrintUsage
					Exit Function
				end if
	
				strAdminID = wscript.arguments(numargs)
				
     			case "-sapassword"
				numargs = numargs + 1
				if numargs >= wscript.arguments.length then
					PrintUsage
					Exit Function
				end if
				strAdminPwd = wscript.arguments(numargs)
				
	
			case "-servername"
				numargs = numargs + 1
				if numargs >= wscript.arguments.length then
					PrintUsage
					Exit Function
				end if
				strDBHostName = wscript.arguments(numargs)
				

        		case Else 
        			PrintUsage
        			Exit Function
        			       

		end Select
		numargs = numargs + 1
	wend
	'Get the installation directory
	strInstallDir = GetInstallDir()
	if (strInstallDir="") then
		wscript.echo "Could not locate the metratech installation directory.  Cannot proceed with upgrade ..."
		exit Function
	end if
	
	wscript.echo " Using parameters: "
	wscript.echo "		Installation Folder: " & strInstallDir
	wscript.echo "		Database Server Name: " & strDBHostName
	wscript.echo "		Database Name: " & strDBName
	wscript.echo "		Database Administrator Logon: " & strAdminID
	wscript.echo "		Database Administrator Password: " & strAdminPwd
	
	'Call the upgrade
	UpgradeDatabaseSQL
	
End Function


Sub PrintUsage()
	wscript.echo "Usage: cscript UpgradeDatabaseSchema.vbs -servername databaseServer -salogon databaseAdminstratorLogon -sapassword databaseAdministratorPassword -dbname databaseName"
End Sub

Function UpgradeDatabaseSQL
	dim WshShell, strFileName, strArguements, intstatus, acc_adapter, fso
	
	dim strInFile
	dim strOutFile
	
	dim objHookHandler
	dim accID
	
	'Parameters expected are: installdir, admin login, admin password, database name, database server name
	
	
	'On Error Resume Next
	err.Clear

	
	Set fso = CreateObject("Scripting.FileSystemObject")
	if err then
		writelog("database install failed. Could not create fso object")
		UpgradeDatabaseSQL = kRetVal_ABORT
		exit Function     		
	end if
	
	Set WshShell = CreateObject("Wscript.Shell")
	if err then
		writelog("database install failed. Could not create Shell object")
		UpgradeDatabaseSQL = kRetVal_ABORT
		exit Function     	
	end if
	     	
	writelog("*** Upgrading Core Database... ***")
	
	writelog("*** Altering Table ... ***")
	strInFile = strInstallDir & "RMP\Config\Upgrade\V21to301\pcinterval.sql"
	strOutFile = strInstallDir & "RMP\Config\Upgrade\V21to301\pcinterval.txt"
	strFilename = "osql.exe"
	strArguements = " -S " & strDBHostName & " -d " & strDBName & " -U " & strAdminID & " -P " & """" & strAdminPwd & """" & " -i " & strInFile & " -o " & strOutFile

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, alter pc_interval failed. Look at mtlog.txt for more details")
		'don't check for error right now.
		'UpgradeDatabase_SQL = kRetVal_ABORT
		'exit Function
	End If

	writelog ("*** Creating Intervals... ***")
	strFileName = strInstallDir & PRESSERVER_PATH & "UsageServerMaintenance.exe"
	strArguements = " -createpc"
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating usage intervals. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If	

	'Run installutiltest with upgrade scripts.
	
	strFilename = strInstallDir & SHAREDEXEC_PATH & "installutiltest.exe"
	strArguements = " -InstExtDbTables " & strInstallDir & "rmp\config\upgrade\V21to301 querytags.xml"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)

	if (intstatus <> 0) then
		writelog("database upgrade, running schema upgrade failed. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If	
	
	writelog("*** Creating Stored Procedures... ***")
	strInFile = strInstallDir & "RMP\Config\Upgrade\V21to301\proc.sql"
	strOutFile = strInstallDir & "RMP\Config\Upgrade\V21to301\proc.txt"
	strFilename = "osql.exe"
	strArguements = " -S " & strDBHostName & " -d " & strDBName & " -U " & strAdminID & " -P " & """" & strAdminPwd & """" & " -i " & strInFile & " -o " & strOutFile

	Writelog ("strArguements: " & strArguements)
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, creating stored procedures failed. Look at mtlog.txt for more details")
		'don't check for error right now.
		'UpgradeDatabase_SQL = kRetVal_ABORT
		'exit Function
	End If

	writelog ( "*** Running the BitemporalSprocs Hook... ***")
        Set objHookHandler = CreateObject("MTHookHandler.MTHookHandler")
	If (err) Then
		'UpgradeDatabaseSQL = kRetVal_ABORT
		writelog ("ERROR: " & err.description)
		'Exit Function
	End If

        objHookHandler.RunHookWithProgid "MetraHook.MTBitemporalSprocsHook", ""
	If (err) Then
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'objHookHandler = Nothing
		writelog ("ERROR: " & err.description)
		writelog ("Database upgrade, running MTBitemporalSprocsHook failed.  Look at mtlog.txt for more details")
		'Exit Function
	End If	
	
	writelog ("*** Creating Intervals... ***")
	strFileName = strInstallDir & PRESSERVER_PATH & "UsageServerMaintenance.exe"
	strArguements = " -create"
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating usage intervals. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If	
	
	writelog ("*** Adding Account Hierarchy Related Accounts... ***")
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u su -p su123 -n system_user -l US -AccountType CSR -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating su account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If

	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u jcsr -p csr123 -n system_user -l US -AccountType CSR -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating jcsr account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If
	

	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u scsr -p csr123 -n system_user -l US -AccountType CSR -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating scsr account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If	
	
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u anonymous -p anonymous123 -n auth -l US -AccountType SYS -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating anonymous account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If	
	
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u csr_folder -p csr123 -n auth -l US -AccountType CSR -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating csr_folder account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If
	
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u mps_folder -p mps123 -n auth -l US -AccountType SUB -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating mps_folder account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If
	
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u mcm_folder -p mcm123 -n auth -l US -AccountType MCM -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating mcm_folder account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If
	
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u mom_folder -p mom123 -n auth -l US -AccountType MOM -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating mom_folder account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If
	
	
	accID = GetAccountID("su", strDBName, strDBHostName, strAdminID, strAdminPwd)
	if (accID = -1) then
		writelog("database upgrade, error in getting su account ID. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function	
	End if
	
	intstatus = LoadInternalAccountData(accID, "GMT", "N")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		'exit Function
	End If	
	
	intstatus = LoadInternalAccountData(accID + 1, "GMT", "N")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		'exit Function
	End If
	
	intstatus = LoadInternalAccountData(accID + 2, "GMT", "N")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		'exit Function
	End If	

	intstatus = LoadInternalAccountData(accID + 3, "EST", "N")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		'exit Function
	End If	

	intstatus = LoadInternalAccountData(accID + 4, "GMT", "Y")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		'exit Function
	End If	

	intstatus = LoadInternalAccountData(accID + 5, "EST", "Y")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		'exit Function
	End If	

	intstatus = LoadInternalAccountData(accID + 6, "EST", "Y")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		'exit Function
	End If	

	intstatus = LoadInternalAccountData(accID + 7, "EST", "Y")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		'exit Function
	End If	
	
	'Run descload
	writelog ("*** Running descload... ***")
	strFileName = strInstallDir & PRESSERVER_PATH & "descload.exe"
	strArguements = ""
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in running descload. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If
	
	'running contact.sql
	writelog ("*** Updating t_contact table... ***")
	strInFile = strInstallDir & "RMP\Config\Upgrade\V21to301\contact.sql"
	strOutFile = strInstallDir & "RMP\Config\Upgrade\V21to301\contact.txt"
	strFilename = "osql.exe"
	strArguements = " -S " & strDBHostName & " -d " & strDBName & " -U " & strAdminID & " -P " & """" & strAdminPwd & """" & " -i " & strInFile & " -o " & strOutFile

	Writelog ("strArguements: " & strArguements)
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, creating stored procedures failed. Look at mtlog.txt for more details")
		'don't check for error right now.
		'UpgradeDatabase_SQL = kRetVal_ABORT
		'exit Function
	End If
	
	strFilename = strInstallDir & PRESSERVER_PATH & "AddProductView.exe"
	strArguements = " -a create -l metratech.com/groupdiscount_temp.msixdef"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating new product view. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	End If
	
	
	writelog ("*** Running Hooks... ***")
	intstatus = ExecHooks(strInstallDir)

	if (intstatus <> 0) then
		writelog("database upgrade, Executing hooks failed. look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		'exit Function
	end if
	
	Writelog ("*** Finished Upgrading Core Database... ***")

	

	End Function
	
	
	
	'*****************************************************************************************
	
	
	
	Function WriteLog(sText)
		Dim fso, WshShell, WshEnv
		Dim LogFile, sysdrive, filename
	
	
	        Set WshShell = CreateObject("Wscript.Shell")
		
	
	        Set WshEnv = WshShell.Environment("PROCESS")
	
	
	        sysdrive = WshEnv("SYSTEMDRIVE")
	        filename = sysdrive & INSTALL_LOG
	           
		
		Set fso = CreateObject("Scripting.FileSystemObject")
		Set LogFile = fso.OpenTextFile(filename, ForAppending, True)
	
		If (sText = "@Init") Then
			LogFile.WriteLine()
			LogFile.WriteLine()
			LogFile.WriteLine("******************************************** " & Date & " : " & Time & _
							  " ********************************************")
	  
	                
		Else
			LogFile.WriteLine(Date & " : " & Time & " : " & sText)
			wscript.echo sText
		End If
		
		LogFile.Close()
		Set LogFile = Nothing
		Set fso = Nothing
	End Function
	'*****************************************************************************************
	

 
Function LoadInternalAccountData(intAccountID, strTimeZone, isFolder)

Dim aNameID, tzID, acc_adapter, acc_prop_coll
Dim acctype, accstatus, secq, invmethod, uctype, langcode, tariffid, taxexempt, paymethod, streason

	'assume success
	LoadInternalAccountData = 0
	
	On Error Resume Next

	err.clear
	set aNameID = CreateObject("MetraPipeline.MTNameID.1")
	if err then
    		WriteLog("ERROR:" & err.description )
    		LoadInternalAccountData = -1
    		Exit Function
	end if

	if (UCASE(strTimeZone) <> "GMT") Then
		tzid = aNameID.GetNameID("Global/TimezoneID/(GMT-05:00) Eastern Time (US & Canada)")
	else
		tzid = aNameID.GetNameID("Global/TimezoneID/(GMT) Monrovia, Casablanca")
	end if
	
	
	if err then
    		WriteLog("ERROR:" & err.description )
    		LoadInternalAccountData = -1
    		Exit Function
	end if


	set acc_adapter = CreateObject("MTAccount.MTAccountServer.1")
	if err then
   		WriteLog("ERROR:" & err.description )
    		LoadInternalAccountData = -1
    		Exit Function    	
	end if
	
	acc_adapter.initialize("Internal")
	if err then
   		WriteLog("ERROR:" & err.description )
    		LoadInternalAccountData = -1
    		Exit Function
	end if
	
	set acc_prop_coll = CreateObject("MTAccount.MTAccountPropertyCollection.1")
	If Err Then
   		WriteLog("ERROR:" & err.description )
    		LoadInternalAccountData = -1
    		Exit Function
    	end if
    	
	acctype = aNameID.GetNameID("metratech.com/accountcreation/AccountType/Bill-To")
	
	accstatus = aNameID.GetNameID("metratech.com/accountcreation/AccountStatus/Active")
	
	secq = aNameID.GetNameID("metratech.com/accountcreation/SecurityQuestion/Pin")
	
	invmethod = aNameID.GetNameID("metratech.com/accountcreation/InvoiceMethod/None")
	
	uctype = aNameID.GetNameID("metratech.com/BillingCycle/UsageCycleType/Monthly")
	
	langcode = aNameID.GetNameID("Global/LanguageCode/US")
	
	tariffid = aNameID.GetNameID("metratech.com/tariffs/TariffID/Default")
	
	taxexempt = "Y"
	
	paymethod = aNameID.GetNameID("metratech.com/accountcreation/PaymentMethod/CashOrCheck")

	streason = aNameID.GetNameID("metratech.com/accountcreation/StatusReason/AccountTerminated")

	if err then
   		WriteLog("ERROR:" & err.description )
    		LoadInternalAccountData = -1
    		Exit Function
	end if
	
	acc_prop_coll.Add "id_acc", clng(intAccountID)
	acc_prop_coll.Add "tariffID", clng(tariffID)
	acc_prop_coll.Add "taxexempt", cstr(taxexempt)
	acc_prop_coll.Add "timezoneID", clng(tzID)
	acc_prop_coll.Add "PaymentMethod", clng(paymethod)
	acc_prop_coll.Add "AccountStatus", clng(accstatus)
	acc_prop_coll.Add "SecurityQuestion", clng(secq)
	acc_prop_coll.Add "InvoiceMethod", clng(invmethod)
	acc_prop_coll.Add "UsageCycleType", clng(uctype)
	acc_prop_coll.Add "Language", clng(langcode)
	acc_prop_coll.Add "SecurityAnswer", "None"
	acc_prop_coll.Add "StatusReasonOther", "No other reason"
	acc_prop_coll.Add "TaxExemptID", "1234567"
	acc_prop_coll.Add "StatusReason", clng(streason)
	acc_prop_coll.Add "currency", "USD"
	acc_prop_coll.Add "folder",cstr(isFolder)
	acc_prop_coll.Add "billable","Y"

	if err then
   		WriteLog("ERROR:" & err.description )
    		LoadInternalAccountData = -1
    		Exit Function
	end if
	
	acc_adapter.AddData "Internal", acc_prop_coll
	
	if err then
   		WriteLog("ERROR:" & err.description )
    		LoadInternalAccountData = -1
    		Exit Function
	end if
	
	Writelog("Added interal account information for account id: " & intAccountID)
End Function



'*****************************************************************************************

Function ExecHooks(strInstallDir)
' assume success
	ExecHooks = 0
	
	Dim objHookHandler
	Dim strFileName, strArguements
	Dim intStatus
	Dim MyShell
	
	On Error Resume Next
	
        Set objHookHandler = CreateObject("MTHookHandler.MTHookHandler")
	If (err) Then
		ExecHooks = -1
		WriteLog("ERROR: " & err.description)
		Exit Function
	End If


        WriteLog("*** Setting up auditing... ***")
        objHookHandler.RunHookWithProgid "MetraHook.AuditHook", ""
	If (err) Then
		ExecHooks = -1
		Set objHookHandler = Nothing
		WriteLog("ERROR: " & err.description)
		Exit Function
	End If
	
	'WriteLog("*** Running the addproductview hook... ***")
	'objHookHandler.RunHookWithProgid "MetraHook.DeployProductView.1", ""
	'If (err) Then
	'	ExecHooks = -1
	'	Set objHookHandler = Nothing
	'	WriteLog("ERROR: " & err.description)
	'	Exit Function
	'End If

        WriteLog("*** Setting up capability types... ***")
        objHookHandler.RunHookWithProgid "MetraHook.MTCapabilityHook", ""
	If (err) Then
		ExecHooks = -1
		Set objHookHandler = Nothing
		WriteLog("ERROR: " & err.description)
		Exit Function
	End If

	WriteLog("*** Boostraping super user security policies... ***")
	
	Dim objLoginContext, objSessionContext
	
	Set objLoginContext = CreateObject("Metratech.MTLoginContext")
        Set objSessionContext = objLoginContext.Login("su", "system_user", "su123")
        
	Set MyShell = CreateObject("Wscript.Shell")
     	if err then
		writelog("database install failed. Could not create Shell object")
		ExecHooks = -1
		Set objHookHandler = Nothing
		WriteLog("ERROR: " & err.description)
		Exit Function
     	end if
     	
        strFilename = strInstallDir & SHAREDEXEC_PATH & "installutiltest.exe"
	strArguements = " -InstExtDbTables " & strInstallDir & "rmp\config\queries\dbinstall\Auth\Bootstrap MTDBobjects.xml"

	intstatus = MyShell.Run(strfilename & strArguements,VBHide, true)
		
	if (intstatus <> 0) then
		ExecHooks = -1
		Set objHookHandler = Nothing
		MyShell = Nothing
		WriteLog("ERROR: Bootstrapping Super user security policy")
		Exit Function
	End If	
	
	
        WriteLog("*** Setting up Security Policies... ***")
        intstatus = RunSecuredHook("MetraHook.MTSecurityPolicyHook")
	If (intstatus <> 0) Then
		ExecHooks = -1
		Set objHookHandler = Nothing
		WriteLog("ERROR: Executing security hook")
		Exit Function
	End If	
	
    	WriteLog("*** Setting up parameter tables... ***")
        objHookHandler.RunHookWithProgid "MetraHook.ParamTableHook", False
	If (err) Then
		ExecHooks = -1
		Set objHookHandler = Nothing
		WriteLog("ERROR: " & err.description)
		Exit Function
	End If
	
        WriteLog("*** Setting up counter types... ***")
        objHookHandler.RunHookWithProgid "MetraHook.MTCounterTypeHook", ""
	If (err) Then
		ExecHooks = -1
		Set objHookHandler = Nothing
		WriteLog("ERROR: " & err.description)
		Exit Function
	End If

        WriteLog("*** Setting up extended property tables... ***")
        objHookHandler.RunHookWithProgid "MetraHook.ExTableHook", False
	If (err) Then
		ExecHooks = -1
		Set objHookHandler = Nothing
		WriteLog("ERROR: " & err.description)
		Exit Function
	End If


        WriteLog("*** Setting up priceable item types... ***")
        objHookHandler.RunHookWithProgid "PriceableItemHook.AddPiType", ""
	If (err) Then
		ExecHooks = -1
		Set objHookHandler = Nothing
		WriteLog("ERROR: " & err.description)
		Exit Function
	End If

	WriteLog("*** Completed running of Hooks... ***")

End Function
'*****************************************************************************************

Function RunSecuredHook(strPROGID)

    RunSecuredHook = 0  'assume success

    Dim aHookHandler

    Dim objLoginContext, objSessionContext

    On Error Resume Next
    
    Set objLoginContext = CreateObject("Metratech.MTLoginContext")
    If (err) Then
    	RunSecuredHook = -1
    	Set aHookHandler = Nothing
    	WriteLog("ERROR: " & err.description)
    	Exit Function
    End If
    

    ' login as the super user
    ' NOTE: it's assumed the su password hasn't changed yet
    Set objSessionContext = objLoginContext.Login("su", "system_user", "su123")
    If (err) Then
    	RunSecuredHook = -1
    	Set aHookHandler = Nothing
    	WriteLog("ERROR: " & err.description)
    	Exit Function
    End If
    

    Set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
    If (err) Then
    	RunSecuredHook = -1
    	Set aHookHandler = Nothing
    	WriteLog("ERROR: " & err.description)
    	Exit Function
    End If

    aHookHandler.SessionContext = objSessionContext
    
    aHookHandler.RunHookWithProgid strPROGID,""
    If (err) Then
    	RunSecuredHook = -1
    	Set aHookHandler = Nothing
    	WriteLog("ERROR: " & err.description)
    	Exit Function
    End If

    Set objLoginContext = Nothing
    Set objSessionContext = Nothing
    Set aHookHandler = Nothing
	
End Function

'*****************************************************************************************


Function GetAccountID (strAccName, strDBName, strDBHostName, strAdminID, strAdminPwd)

'assume failure
GetAccountID = -1

Dim strConnectString
Dim returnVal
Dim objConn
Dim objCmd
Dim objRcdSet
Dim strSQLCommand

On Error Resume Next

strConnectString = "PROVIDER=MSDASQL; DRIVER={SQL Server}; " & _
					"SERVER=" & strDBHostName & "; " & _ 
					"UID=" & strAdminID & "; " & _
					"PWD=" & strAdminPwd & "; " & _
					"DATABASE=" & strDBName
					
'writelog (strConnectString)

Set objConn = CreateObject("ADODB.Connection")
If (err) Then
   WriteLog("ERROR: " & err.description)
   Exit Function
End If

objConn.Open(strConnectString)
If (err) Then
   WriteLog("ERROR: " & err.description)
   Set objConn = Nothing
   Exit Function
End If

Set objCmd = CreateObject("ADODB.Command")
If (err) Then
   WriteLog("ERROR: " & err.description)
   Set objConn = Nothing
   Exit Function
End If

Set objCmd.ActiveConnection = objConn
If (err) Then
   WriteLog("ERROR: " & err.description)
   Set objConn = Nothing
   Set objCmd = Nothing
   Exit Function
End If

strSQLCommand = "select id_acc from " & strDBName & "..t_account_mapper where nm_login='" & strAccName & "'"


WriteLog strSQLCommand
objCmd.CommandText = strSQLCommand
objCmd.CommandType = 1

Set objRcdSet = objCmd.Execute
If (err) Then
   WriteLog("ERROR: " & err.description)
   Set objConn = Nothing
   Set objCmd = Nothing
   Set objRcdSet = Nothing
   Exit Function
End If

if objRcdSet.EOF AND objRcdSet.BOF Then
   WriteLog "Empty record set, no " & strAccName & " user present"
else
   do until objRcdSet.EOF
      returnVal = objRcdSet("id_acc")
      objRcdSet.MoveNext
   loop
end if        

Set objConn = Nothing
Set objCmd = Nothing
Set objRcdSet = Nothing
GetAccountID = returnVal

End Function


Function GetInstallDir()

	Dim strValue
	Dim position
	Dim WshShell
	
	
	GetInstallDir = ""

        Set WshShell = CreateObject("WScript.Shell")
	
	strValue = WshShell.RegRead("HKLM\SOFTWARE\MetraTech\install\InstallDir")
	If (strValue = "") then
		Exit Function
	
	Else
		
		strValue = UCASE(strValue)
		position = Instr(1, strValue, "RMP")
		if position > 0 then
			strValue = mid(strValue, 1, position-1)
		end if 
		GetInstallDir = strValue
        End If 		

End Function
