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
'* These functions upgrade MetraTech Platform database from V3.0.1 to V3.5
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
Const ASSEMBLY_PATH				= "RMP\Assemblies\"

Const VBHide					= 0

'*** Elements of DB Schema used to determine the current installed state of the database ***
Const kDatabaseKeyTable_Core	= "t_usage_cycle"	'*** Key table for core DB (ver 1.3) ***
Const kDatabaseKeyTable_20		= "t_ep_map"		'*** Key table for version 2.0 ***
Const kDatabaseKeyTable_PS		= "t_payment_audit"	'*** Key table for Payment Server
Const kDatabaseKeyPrefix_Audio	= "t_pv_audio"		'*** Key table PREFIX for AudioConf Prod Views ***
Const kDatabaseKeyPrefix_MPS	= "t_pv_Static"		'*** Key table PREFIX for MPS Prod Views ***
Const kDatabaseKeyPrefix_PS		= "t_pv_ps"			'*** Key table PREFIX for Pay Svr Prod Views ***
Const kDatabaseKeyPrefix_PCSAMPLE	= "t_pv_song"	'*** Key table PREFIX for PCSample Prod Views ***
Const kDatabaseKeyTable_21	= "t_audit_events"	'*** Key table for version 2.1 ***
Const kDatabaseKeyTable_22	= "t_batch_status"	'*** Key table for version 2.2 ***
Const kDatabaseKeyTable_30	= "t_account_ancestor"	'*** Key table for version 3.0 ***
Const kDatabaseKeyTable_301	= "t_sys_upgrade"  	'*** Key table for version 3.0.1 ***

'*** MetraTech database status values ***
Const kDBState_INVALID			= "X"				'*** DB Status invalid value
Const kDBState_NO_DATABASE      = "0"               '*** No db information 
Const kDBState_DBMS_OK          = "1"               '*** DBMS found, correct version
Const kDBState_DB_CREATED       = "2"               '*** Created, no schema 
Const kDBState_DB_13_PRESENT    = "3"               '*** Created, schema present, may be ver 1.3
Const kDBState_DB_20_PRESENT    = "4"               '*** Created, schema verified to be ver 2.0
Const kDBState_DB_PV_PRESENT    = "5"               '*** Created, ProductView schema verified 
Const kDBState_DB_21_PRESENT	= "6"		    '*** Created, schema verified to be ver 2.1
Const kDBState_DB_22_PRESENT	= "7"		    '*** Created, schema verified to be ver 2.2
Const kDBState_DB_30_PRESENT	= "8"		    '*** Created, schema verified to be ver 3.0
Const kDBState_DB_301_PRESENT   = "9"		    '*** Created, schema verified to be ver 3.0.1

dim strInstallDir
dim strAdminID
dim strAdminPwd
dim strDBName
dim strDBHostName
dim nPV_PaySvr_Status

Main

Public Function Main() ' As Boolean
	dim numargs, arg
	dim DBStatus

	numargs = 0
	nPV_PaySvr_Status = kDBState_NO_DATABASE

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
	'UpgradeDatabaseSQL
	DBStatus = FindStatusOfDatabase()
	wscript.echo "Status found is: " & DBStatus
	if (DBStatus = kDBState_DB_301_PRESENT) then
		' call the upgrade database function to upgrade from 3.0.1 to 3.5
		UpgradeDatabaseSQLFromV301
	elseif (DBStatus = kDBState_DB_21_PRESENT) then
		UpgradeDatabaseSQLFromV211
	else 
	 	Wscript.echo "Database status is such that upgrade cannot proceed."
	end if 
End Function

'************************************************************************************************

Sub PrintUsage()
	wscript.echo "Usage: cscript UpgradeDatabaseSchema.vbs -servername databaseServer -salogon databaseAdminstratorLogon -sapassword databaseAdministratorPassword -dbname databaseName"
End Sub

'************************************************************************************************

Function UpgradeDatabaseSQLFromV301
	dim WshShell, strFilename, strArguements, intstatus, fso
	dim strInFile
	dim strOutFile
	dim objHookHandler


	err.Clear


	Set fso = CreateObject("Scripting.FileSystemObject")
	if err then
		writelog("database install failed. Could not create fso object")
		UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function     		
	end if
	
	Set WshShell = CreateObject("Wscript.Shell")
	if err then
		writelog("database install failed. Could not create Shell object")
		UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function     	
	end if
	     	
	writelog("*** Upgrading Core Database from v3.0.1 ... ***")

	writelog("*** Update Database Schema...***")	
	strFilename = strInstallDir & SHAREDEXEC_PATH & "installutiltest.exe"
	strArguements = " -InstExtDbTables " & strInstallDir & "rmp\config\upgrade\v301to35 querytags.xml"
	writelog (strfilename & strArguements)

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)

	if (intstatus <> 0) then
		writelog("database upgrade, running schema upgrade failed. Look at mtlog.txt for more details")
		exit Function
	End If	

	writelog("*** procedure,functions views ... ***")
	strInFile = strInstallDir & "RMP\Config\Upgrade\v301to35\Procedure.sql"
	strOutFile = strInstallDir & "RMP\Config\Upgrade\v301to35\Procedure.txt"
	strFilename = "osql.exe"
	strArguements = " -S " & strDBHostName & " -d " & strDBName & " -U " & strAdminID & " -P " & """" & strAdminPwd & """" & " -i " & strInFile & " -o " & strOutFile
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
				
	if (intstatus <> 0) then
		writelog("database upgrade, error in altering tables. Look at mtlog.txt for more details")
	End If	        
        
	writelog("*** update invoice ... ***")      
   	intstatus = UpgradeInvoice
	if (intstatus <> 0) then
		writelog("database upgrade, invoice upgrade failed")
		'NewUpgradeDatabaseSQL = kRetVal_ABORT
		exit Function
	End If	
	
	writelog("*** update po ... ***")
	intstatus = CreateNonSharedPricelists
	if (intstatus <> 0) then
		writelog("database upgrade, creating nonshared pricelists failed")
		'NewUpgradeDatabaseSQL = kRetVal_ABORT
		exit Function
	End If	

	writelog("*** update prod view ... ***")
	intstatus = Populateprodview
	if (intstatus <> 0) then
		writelog("database upgrade, populating prod view failed")
	End If	

	writelog ("*** Running product views... ***")

'       	If Not AddProductViews() Then Exit Function
        If Not RunHook("Setting up auditing","MetraHook.DeployProductView","")            Then Exit Function


	writelog ("*** Running descload... ***")
	strFileName =  strInstallDir & PRESSERVER_PATH & "descload.exe"
	strArguements = ""
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in running descload. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If

	writelog ("*** Creating Intervals... ***")
	strFileName = strInstallDir & ASSEMBLY_PATH & "usm.exe"
	strArguements = " -create"
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating usage intervals. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQL = kRetVal_ABORT
		exit Function
	End If	

	writelog("setting up auditing...")
        If Not RunHook("Setting up auditing"                ,"MetraHook.AuditHook","")            Then Exit Function
	writelog("setting up extended property tables...")
        If Not RunHook("Setting up extended property tables","MetraHook.ExTableHook","")          Then Exit Function
	writelog("setting up counters..")
        If Not RunHook("Setting up counter types"           ,"MetraHook.MTCounterTypeHook","")    Then Exit Function
	writelog("setting up parameter tables...")
        If Not RunHook("Setting up parameter tables"        ,"MetraHook.ParamTableHook","")       Then Exit Function
	writelog("setting up adjustment..")
        If Not RunHook("Setting up Adjustments"        ,"MetraTech.Adjustments.Hooks.AdjustmentHook","")     Then Exit Function
	writelog("setting up refresh..")
        If Not RunHook("Setting up Adjustments"        ,"MetraHook.ConfigRefresh","")     Then Exit Function
	writelog("setting up priceable item...")
        If Not RunHook("Setting up priceable item types"    ,"PriceableItemHook.AddPiType","")    Then Exit Function        
	writelog("setting up capability...")
        If Not RunHook("Setting up capability types"        ,"MetraHook.MTCapabilityHook","")     Then Exit Function
	writelog("setting up security...")
        If Not RunSecuredHook("Setting up Security Policies","MetraHook.MTSecurityPolicyHook","") Then Exit Function
	writelog("setting up usageserver...")
        If Not RunSecuredHook("Setting up Usage Server","MetraTech.UsageServer.Hook","") Then Exit Function

  END FUNCTION
	

Function UpgradeDatabaseSQLFromV211
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
		UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function     		
	end if
	
	Set WshShell = CreateObject("Wscript.Shell")
	if err then
		writelog("database install failed. Could not create Shell object")
		UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function     	
	end if
	     	
	writelog("*** Upgrading Core Database from v2.1.1 ... ***")
	
	writelog("*** Altering Table ... ***")
	strInFile = strInstallDir & "RMP\Config\Upgrade\v21to301\pcinterval.sql"
	strOutFile = strInstallDir & "RMP\Config\Upgrade\v21to301\pcinterval.txt"
	strFilename = "osql.exe"
	strArguements = " -S " & strDBHostName & " -d " & strDBName & " -U " & strAdminID & " -P " & """" & strAdminPwd & """" & " -i " & strInFile & " -o " & strOutFile
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating pc intervals. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If	

	writelog ("*** Creating Intervals... ***")
	strFileName = strInstallDir & PRESSERVER_PATH & "UsageServerMaintenance.exe"
	strArguements = " -createpc"
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating usage intervals. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If	

	'Run installutiltest with upgrade scripts.
	writelog("*** Update Database Schema...***")	
	strFilename = strInstallDir & SHAREDEXEC_PATH & "installutiltest.exe"
	strArguements = " -InstExtDbTables " & strInstallDir & "RMP\Config\Upgrade\v21to301 querytags.xml"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)

	if (intstatus <> 0) then
		writelog("database upgrade, running schema upgrade failed. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If	
	
	writelog("*** Creating Stored Procedures... ***")
	strInFile = strInstallDir & "RMP\Config\Upgrade\v21to301\proc.sql"
	strOutFile = strInstallDir & "RMP\Config\Upgrade\v21to301\proc.txt"
	strFilename = "osql.exe"
	strArguements = " -S " & strDBHostName & " -d " & strDBName & " -U " & strAdminID & " -P " & """" & strAdminPwd & """" & " -i " & strInFile & " -o " & strOutFile

	Writelog ("strArguements: " & strArguements)
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, creating stored procedures failed. Look at mtlog.txt for more details")
		'don't check for error right now.
		'UpgradeDatabase_SQL = kRetVal_ABORT
		exit Function
	End If

	writelog ( "*** Running the BitemporalSprocs Hook... ***")
        Set objHookHandler = CreateObject("MTHookHandler.MTHookHandler")
	If (err) Then
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		writelog ("ERROR: " & err.description)
		Exit Function
	End If

        objHookHandler.RunHookWithProgid "MetraHook.MTBitemporalSprocsHook", ""
	If (err) Then
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		'objHookHandler = Nothing
		writelog ("ERROR: " & err.description)
		writelog ("Database upgrade, running MTBitemporalSprocsHook failed.  Look at mtlog.txt for more details")
		Exit Function
	End If	
	
	writelog ("*** Creating Intervals... ***")
	strFileName = strInstallDir & PRESSERVER_PATH & "UsageServerMaintenance.exe"
	strArguements = " -create"
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating usage intervals. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If	
	
	writelog ("*** Adding Account Hierarchy Related Accounts... ***")
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u su -p su123 -n system_user -l US -AccountType CSR -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating su account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If

	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u jcsr -p csr123 -n system_user -l US -AccountType CSR -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating jcsr account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If
	

	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u scsr -p csr123 -n system_user -l US -AccountType CSR -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating scsr account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If	
	
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u anonymous -p anonymous123 -n auth -l US -AccountType SYS -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating anonymous account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If	
	
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u csr_folder -p csr123 -n auth -l US -AccountType CSR -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating csr_folder account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If
	
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u mps_folder -p mps123 -n auth -l US -AccountType SUB -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating mps_folder account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If
	
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u mcm_folder -p mcm123 -n auth -l US -AccountType MCM -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating mcm_folder account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If
	
	strFilename = strInstallDir & PRESSERVER_PATH & "AddDefaultAccounts.exe"
	strArguements = " -u mom_folder -p mom123 -n auth -l US -AccountType MOM -dom 30"

	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating mom_folder account. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If
	
	
	accID = GetAccountID("su", strDBName, strDBHostName, strAdminID, strAdminPwd)
	if (accID = -1) then
		writelog("database upgrade, error in getting su account ID. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function	
	End if
	
	intstatus = LoadInternalAccountData(accID, "GMT", "N")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		exit Function
	End If	
	
	intstatus = LoadInternalAccountData(accID + 1, "GMT", "N")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		exit Function
	End If
	
	intstatus = LoadInternalAccountData(accID + 2, "GMT", "N")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		exit Function
	End If	

	intstatus = LoadInternalAccountData(accID + 3, "EST", "N")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		exit Function
	End If	

	intstatus = LoadInternalAccountData(accID + 4, "GMT", "Y")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		exit Function
	End If	

	intstatus = LoadInternalAccountData(accID + 5, "EST", "Y")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		exit Function
	End If	

	intstatus = LoadInternalAccountData(accID + 6, "EST", "Y")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		exit Function
	End If	

	intstatus = LoadInternalAccountData(accID + 7, "EST", "Y")
	if (intstatus <> 0) then
		writelog("Error in adding internal account information. Look at mtlog.txt for more details")
		'InstallDatabase_SQL = kRetVal_ABORT
		exit Function
	End If	
	
	'Run descload
	writelog ("*** Running descload... ***")
	strFileName = strInstallDir & PRESSERVER_PATH & "descload.exe"
	strArguements = ""
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, error in running descload. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If
	
	'running contact.sql
	writelog ("*** Updating t_contact table... ***")
	strInFile = strInstallDir & "RMP\Config\Upgrade\v21to301\contact.sql"
	strOutFile = strInstallDir & "RMP\Config\Upgrade\v21to301\contact.txt"
	strFilename = "osql.exe"
	strArguements = " -S " & strDBHostName & " -d " & strDBName & " -U " & strAdminID & " -P " & """" & strAdminPwd & """" & " -i " & strInFile & " -o " & strOutFile

	Writelog ("strArguements: " & strArguements)
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("database upgrade, creating stored procedures failed. Look at mtlog.txt for more details")
		'don't check for error right now.
		'UpgradeDatabase_SQL = kRetVal_ABORT
		exit Function
	End If
	
	writelog ("*** Adding Product View... ***")

	strFilename = strInstallDir & PRESSERVER_PATH & "AddProductView.exe"
	strArguements = " -a create -l metratech.com/groupdiscount_temp.msixdef"

  	intstatus = WshShell.Run(strfilename & strArguements,VBHide, True)
	
	If (intstatus <> 0) Then
		writelog("database upgrade, error in creating new product view. Look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	End If
	

	
	writelog ("*** Running Hooks... ***")
	intstatus = ExecHooks(strInstallDir)

	if (intstatus <> 0) then
		writelog("database upgrade, Executing hooks failed. look at mtlog.txt for more details")
		'UpgradeDatabaseSQLFromV211 = kRetVal_ABORT
		exit Function
	end if

	'running security.sql
	writelog ("*** Updating Security Tables ... ***")
	strInFile = strInstallDir & "RMP\Config\Upgrade\v21to301\security.sql"
	strOutFile = strInstallDir & "RMP\Config\Upgrade\v21to301\security.txt"
	strFilename = "osql.exe"
	strArguements = " -S " & strDBHostName & " -d " & strDBName & " -U " & strAdminID & " -P " & """" & strAdminPwd & """" & " -i " & 	strInFile & " -o " & strOutFile

	Writelog ("strArguements: " & strArguements)
	
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	
	if (intstatus <> 0) then
		writelog("updating auth table failed")
		'don't check for error right now.
		'UpgradeDatabase_SQL = kRetVal_ABORT
		exit Function
	End If
	
	Writelog ("*** Finished Upgrading Core Database... ***")


	End Function
	

Function Populateprodview
	Dim objOps
	Set objOps = CreateObject("MTProductView.MTProductViewOps")
 	Call objOps.UpgradeProductViews30To35()
	Populateprodview=0	
END FUNCTION


FUNCTION CreateNonSharedPriceLists
    dim pc, pl, po_coll, po, iterator_po, po_rowset
  
    Set pc = CreateObject("Metratech.MTProductCatalog")
    Set po_rowset = pc.FindProductOfferingsAsRowset()
  
    while not po_rowset.EOF
      Set po = pc.GetProductOffering(po_rowset.Value("id_prop"))      
      Set pl = pc.CreatePriceList
      pl.Name = Mid("Nonshared PL for:" & po.Name, 1, 256)
      pl.Description = pl.Name
     	pl.CurrencyCode = GetPOCurrency(po, strDBName, strDBHostName, strAdminID, strAdminPwd)
      'pl.CurrencyCode = po.GetCurrencyCode
      pl.Type = 2 'Type 2 means this is a nonshared pricelist
      pl.Save()
      po.NonSharedPriceListID = pl.ID
      po.Save
      po_rowset.MoveNext
    wend
		CreateNonSharedPriceLists = 0
  END FUNCTION

Function UpgradeInvoice()

  ' read ConfigInvoice.xml
    Dim rcd
    Dim fso
    Set rcd = CreateObject("MetraTech.Rcd.1")
    rcd.Init
    
    Dim filePath
    filePath = rcd.ConfigDir & "UsageServer\Adapters\ConfigInvoice.xml"
     
    set fso = createobject("Scripting.FileSystemObject")
    if NOT (fso.FileExists(filePath)) then
	UpgradeInvoice = 0
    else
    Dim xmlDoc
    Dim loaded
    Set xmlDoc = CreateObject("MSXML2.DOMDocument.4.0")
     
    loaded = xmlDoc.Load(filePath)
    If Not loaded Then
       	Err.Raise -1, "", "could not load " + filePath
    End If
      
    Dim invoice_prefix, invoice_suffix, invoice_digits, invoice_number, invoice_due_date_offset
    invoice_prefix = xmlDoc.selectSingleNode("//invoice_prefix").Text
    invoice_suffix = xmlDoc.selectSingleNode("//invoice_suffix").Text
    invoice_digits = xmlDoc.selectSingleNode("//invoice_digits").Text
    invoice_number = xmlDoc.selectSingleNode("//invoice_number").Text
    invoice_due_date_offset = xmlDoc.selectSingleNode("//invoice_due_date_offset").Text

    ' update table
    Dim rs
    Set rs = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rs.Init ("queries\\database")
    rs.SetQueryString "insert into t_invoice_namespace (namespace, invoice_prefix, invoice_suffix, invoice_num_digits, invoice_due_date_offset, id_invoice_num_last) values('mt', '" & _
     invoice_prefix & "', '" & invoice_suffix & "'," & invoice_digits & "," & invoice_due_date_offset & "," & invoice_number & ")"
    rs.Execute
		UpgradeInvoice = 0
    end if
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

Function FindStatusOfDatabase()
	Dim strErrMsg
	
	Dim strDBStatus
	Dim strConnectString
	

	WriteLog("---> Entering FindStatusOfDatabase()")
			
	
	strConnectString = "PROVIDER=MSDASQL; DRIVER={SQL Server}; " & _
					"SERVER=" & strDBHostName & "; " & _ 
					"UID=" & strAdminID & "; " & _
					"PWD=" & strAdminPwd & "; " & _
					"DATABASE=" & strDBName		'*** Use the Master DB ***


	

	WriteLog("     Validating MetratTech Database (Connection String = " & strConnectString & ")")
	strDBStatus = ValidateDataBase_SQLServer(strConnectString, strDBName)
	WriteLog("     DBMS Status: " & strDBStatus) 
	If (strDBStatus = kDBState_INVALID) Then
		wscript.echo "Error encountered while validating database; See log files"
		WriteLog("---> Exiting FindStatusOfDatabase()")
		Exit Function
	End If
	
	FindStatusofDatabase = strDBStatus	
	WriteLog("---> Exiting FindStatusOfDatabase()")
End Function

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

Function ValidateDataBase_SQLServer(sConnectString, sDatabase)
	Dim objConn
	Dim objCatalog
	Dim tblItem
	Dim nDBStatus
	Dim nPV_AudioConf_Status
	Dim nPV_MPS_Status
	Dim nPV_PCSample_Status
	
	WriteLog("---> Entering ValidateDataBase_SQLServer()")
	nDBStatus = kDBState_DBMS_OK
	
	nPV_AudioConf_Status = kDBState_NO_DATABASE
	nPV_MPS_Status = kDBState_NO_DATABASE
	nPV_PaySvr_Status = kDBState_NO_DATABASE
	nPV_PCSample_Status = kDBState_NO_DATABASE
	
	ValidateDataBase_SQLServer = nDBStatus	 '*** Assume DBMS valid if this funct is called ***
	
	Set objConn = CreateObject("ADODB.Connection")
	If (Err) Then
		wscript.echo "Error while validating Database existence -- See log file."
		WriteLog("---> Exiting ValidateDataBase_SQLServer()")
		ValidateDataBase_SQLServer = kDBState_INVALID
		Exit Function
	End If
	
	'WriteLog("     Opening database connection with connection string: " & sConnectString)
	objConn.Open(sConnectString)
	If Err.Number <> 0 Then
		If Err.Number = -2147467259 Then		'*** Can't find the database -- must create ***
			WriteLog("     Specified database (" & sDatabase & ") not found -- proceed to collect creation parameters")
			Set objConn = Nothing
			Exit Function
		End If
		
		If Err.Number = -2147217843 Then		'*** Can't log on to the database ***
			wscript.echo"Specified credentials not valid -- See log file."
			'*** Allow following error check to handle this ***
		End If
			
		If (CheckErrors("ValidateDataBase_SQLServer::Opening ADO Connection")) Then
			wscript.echo"Error while validating Database existence -- See log file."
			WriteLog("---> Exiting ValidateDataBase_SQLServer()")
			Set objConn = Nothing
			ValidateDataBase_SQLServer = kDBState_INVALID
			Exit Function
		End If
	End If
	
	WriteLog("     Database connection successfully established")
			
	'*** The database is at least created -- check further for schema ***
	nDBStatus = kDBState_DB_CREATED 
		
	'*** Use ADOX to check the state of the database schema ***
	WriteLog("     Beginning to verify state of database schema")
	Set objCatalog = CreateObject("ADOX.Catalog")
	If (Err) Then
		wscript.echo "Error while validating Database existence -- See log file."
		WriteLog("---> Exiting ValidateDataBase_SQLServer()")
		Set objConn = Nothing
		ValidateDataBase_SQLServer = kDBState_INVALID
		Exit Function
	End If
	
	objCatalog.ActiveConnection = objConn
	If (Err) Then
		wscript.echo "Error while validating Database existence -- See log file."
		WriteLog("---> Exiting ValidateDataBase_SQLServer()")
		Set objCatalog = Nothing
		Set objConn = Nothing
		ValidateDataBase_SQLServer = kDBState_INVALID
		Exit Function
	End If

	WriteLog("     Scanning ADOX Table Collection for database ... Count=" & objCatalog.Tables.Count)
	For Each tblItem in objCatalog.Tables
		'***  Check the core database schema ***
		If (nDBStatus < kDBState_DB_13_PRESENT) Then
			If (tblItem.Name = kDatabaseKeyTable_Core) Then	
				nDBStatus = kDBState_DB_13_PRESENT   '*** Core DB (maybe ver 1.3) exists ***
				WriteLog("     Core database schema (ver 1.3) found: " & tblItem.Name)
			End If
		End If
		
		'*** Keep looking for a ver 2.0 table ***
		If (nDBStatus < kDBState_DB_20_PRESENT) Then
			If (tblItem.Name = kDatabaseKeyTable_20) Then	
				nDBStatus = kDBState_DB_20_PRESENT  '*** Core DB version 2.0 exists ***
				WriteLog("     Core database schema (ver 2.0) found: " & tblItem.Name)
			End If
		End If

		'*** Check status of AudioConf product views ***
		If (nPV_AudioConf_Status < kDBState_DB_PV_PRESENT) Then
			If (InStr(tblItem.Name, kDatabaseKeyPrefix_Audio) > 0) Then
				nPV_AudioConf_Status = kDBState_DB_PV_PRESENT
				WriteLog("     AudioConferencing product view database schema found: " & tblItem.Name)
			End If
		End If
			
		'*** Check status of MPS product views ***
		If (nPV_MPS_Status < kDBState_DB_PV_PRESENT) Then
			If (InStr(tblItem.Name, kDatabaseKeyPrefix_MPS) > 0) Then
				nPV_MPS_Status = kDBState_DB_PV_PRESENT
				WriteLog("     MPS product view database schema found: " & tblItem.Name)
			End If
		End If
			
		'*** Check the Payment Server schema and Product View schema ***
		'*** Look for a ver 2.0 Payment Server table ***
		If (nPV_PaySvr_Status < kDBState_DB_20_PRESENT) Then
			If (tblItem.Name = kDatabaseKeyTable_PS) Then	
				nPV_PaySvr_Status = kDBState_DB_20_PRESENT  '*** Payment Server DB version 2.0 exists ***
				WriteLog("     Payment Server database schema found: " & tblItem.Name)
			End If
		End If
			
		'*** Check status of Payment Server product views ***
		If (nPV_PaySvr_Status < kDBState_DB_PV_PRESENT) Then
			If (InStr(tblItem.Name, kDatabaseKeyPrefix_PS) > 0) Then
				nPV_PaySvr_Status = kDBState_DB_PV_PRESENT
				WriteLog("     Payment Server product view database schema found: " & tblItem.Name)
			End If
		End If

		'*** Check status of PCSample product views ***
		If (nPV_PCSample_Status < kDBState_DB_PV_PRESENT) Then
			If (InStr(tblItem.Name, kDatabaseKeyPrefix_PCSAMPLE) > 0) Then
				nPV_PCSample_Status = kDBState_DB_PV_PRESENT
				WriteLog("     PCSample product view database schema found: " & tblItem.Name)
			End If
		End If
		'*** Keep looking for a ver 2.1 table ***
		If (nDBStatus < kDBState_DB_21_PRESENT) Then
			if (tblItem.Name = kDatabaseKeyTable_21) Then
				nDBStatus = kDBState_DB_21_PRESENT '*** version v2.1 exists ***
				WriteLog("	Core database schema (ver 2.1) found: " & tblItem.Name)
			End If
		End if
		
		'*** Keep looking for a ver 2.2 table ***
		If (nDBStatus < kDBState_DB_22_PRESENT) Then
			if (tblItem.Name = kDatabaseKeyTable_22) Then
				nDBStatus = kDBState_DB_22_PRESENT '*** version v2.2 exists ***
				WriteLog("	Core database schema (ver 2.2) found: " & tblItem.Name)
			End If
		End if
		
		If (nDBStatus < kDBState_DB_30_PRESENT) Then
			if (tblItem.Name = kDatabaseKeyTable_30) Then
				nDBStatus = kDBState_DB_30_PRESENT '*** version v3.0 exists ***
				WriteLog("	Core database schema (ver 3.0) found: " & tblItem.Name)
			End If
		End if

		If (nDBStatus < kDBState_DB_301_PRESENT) Then
			if (tblItem.Name = kDatabaseKeyTable_301) Then
				nDBStatus = kDBState_DB_301_PRESENT '*** version v3.0.1 exists ***
				WriteLog("	Core database schema (ver 3.0.1) found: " & tblItem.Name)
			End If
		End if	
	Next
	
	WriteLog("     Scanning database schema completed")

		
	ValidateDataBase_SQLServer = nDBStatus	'*** Return Core status as retval ***
	
	Set objCatalog = Nothing
	Set objConn = Nothing
	
	WriteLog("---> Exiting ValidateDataBase_SQLServer()")
End Function

  PRIVATE FUNCTION NewObject(strProgID) ' As Boolean
  
      On Error Resume Next
      
      Set NewObject = Nothing 
      Set NewObject = CreateObject(strProgID)
      If Err.Number<>0 Then 
      
          CheckError("CreateObject(" & strProgID & ")")
      End If 
  END FUNCTION

PRIVATE FUNCTION RunSecuredHook(strTitle,strPROGID, strParameter)

    RunSecuredHook = FALSE

    Dim aHookHandler, strAction
   
    ' login as the super user
    ' NOTE: it's assumed the su password hasn't changed yet
    Dim objLoginContext, objSessionContext
    Set objLoginContext = CreateObject("Metratech.MTLoginContext")
    Set objSessionContext = objLoginContext.Login("su", "system_user", "su123")

    Set aHookHandler = NewObject("MTHookHandler.MTHookHandler.1")

    aHookHandler.SessionContext = objSessionContext
    strAction = "Run Hook " & strPROGID & " " & strParameter

    aHookHandler.RunHookWithProgid strPROGID,strParameter

    RunSecuredHook = TRUE

  END FUNCTION

  PRIVATE FUNCTION RunHook(strTitle,strPROGID, strParameter)

    RunHook = FALSE

    Dim aHookHandler, strAction

    Set aHookHandler = NewObject("MTHookHandler.MTHookHandler.1")

    strAction = "Run Hook " & strPROGID & " " & strParameter
    aHookHandler.RunHookWithProgid strPROGID,strParameter
    RunHook = TRUE

  END FUNCTION

   PRIVATE FUNCTION AddProductViews()
   
      AddProductViews = FALSE
      Dim ADDPRODUCTVIEW_CREATE_ALL_COMMMAND_LINE
      ADDPRODUCTVIEW_CREATE_ALL_COMMMAND_LINE = strInstallDir & PRESSERVER_PATH & "AddProductView.exe" & " -a create -l all"        
      AddProductViews = TRUE
      
  END FUNCTION

'************************************************************************************************

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

Function GetPOCurrency (id_po, strDBName, strDBHostName, strAdminID, strAdminPwd)

'assume failure
GetPOCurrency = -1

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

strSQLCommand = "SELECT DISTINCT nm_currency_code FROM " & strDBName & "..t_pl_map a," & strDBName & "..t_pricelist b WHERE a.id_pricelist = b.id_pricelist AND id_po = " & id_po

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
   WriteLog "Empty record set, no " & id_po & " present"
else
   do until objRcdSet.EOF
      returnVal = objRcdSet("nm_currency_code")
      objRcdSet.MoveNext
   loop
end if        

Set objConn = Nothing
Set objCmd = Nothing
Set objRcdSet = Nothing
GetPOCurrency = returnVal

End Function

'******************************************************************************************
