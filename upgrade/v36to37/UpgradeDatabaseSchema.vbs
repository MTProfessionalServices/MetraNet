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
'* These functions upgrade MetraTech Platform database from V3.6 to V3.7
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

'*** MetraTech database status values ***
Const kDBState_INVALID			= "X"				'*** DB Status invalid value
Const kDBState_NO_DATABASE      = "0"               '*** No db information 
Const kDBState_DBMS_OK          = "1"               '*** DBMS found, correct version
Const kDBState_DB_CREATED       = "2"               '*** Created, no schema 
Const kDBState_DB_36_PRESENT		= "3.6"

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
	if (DBStatus = kDBState_DB_36_PRESENT) then
		' call the upgrade database function to upgrade from 3.6 to 3.7
		UpgradeDatabaseSQLFromV36
	else 
	 	Wscript.echo "Database status is such that upgrade cannot proceed."
	end if 
End Function

'************************************************************************************************

Sub PrintUsage()
	wscript.echo "Usage: cscript UpgradeDatabaseSchema.vbs -servername databaseServer -salogon databaseAdminstratorLogon -sapassword databaseAdministratorPassword -dbname databaseName"
End Sub

'************************************************************************************************

Function UpgradeDatabaseSQLFromV36
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
	     	
	writelog("*** Upgrading Core Database from v3.6 ... ***")

	writelog("*** Update Database Schema...***")	
	strInFile = strInstallDir & "RMP\Config\Upgrade\v36to37\v36to37.sql"
	strOutFile = strInstallDir & "RMP\Config\Upgrade\v36to37\v36to37.txt"
	strFilename = "osql.exe"
	strArguements = " -l 3000 -S " & strDBHostName & " -d " & strDBName & " -U " & strAdminID & " -P " & """" & strAdminPwd & """" & " -i " & strInFile & " -o " & strOutFile
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	if (intstatus <> 0) then
		writelog("database upgrade, running schema upgrade failed. Look at mtlog.txt for more details")
		exit Function
	End If	

	writelog("*** procedure,functions views ... ***")
	strInFile = strInstallDir & "RMP\Config\Upgrade\v36to37\Procedure.sql"
	strOutFile = strInstallDir & "RMP\Config\Upgrade\v36to37\Procedure.txt"
	strFilename = "osql.exe"
	strArguements = " -l 3000 -S " & strDBHostName & " -d " & strDBName & " -U " & strAdminID & " -P " & """" & strAdminPwd & """" & " -i " & strInFile & " -o " & strOutFile
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
				
	if (intstatus <> 0) then
		writelog("database upgrade, error in creating procedures. Look at mtlog.txt for more details")
	End If	        

	writelog("*** Update Payment Server Schema...***")	
	strInFile = strInstallDir & "RMP\Config\Upgrade\v36to37\payment.sql"
	strOutFile = strInstallDir & "RMP\Config\Upgrade\v36to37\payment.txt"
	strFilename = "osql.exe"
	strArguements = " -l 3000 -S " & strDBHostName & " -d " & strDBName & " -U " & strAdminID & " -P " & """" & strAdminPwd & """" & " -i " & strInFile & " -o " & strOutFile
	intstatus = WshShell.Run(strfilename & strArguements,VBHide, true)
	if (intstatus <> 0) then
		writelog("payment server upgrade, running payment server schema upgrade failed. Look at mtlog.txt for more details")
		exit Function
	End If	
	
	writelog("setting up database properties...")
	If Not RunSecuredHook("Setting up metranet properties"    ,"MetraTech.Product.Hooks.DatabaseProperties","")    Then Exit Function        
	        
	writelog("*** Upgraded Core Database from v3.6 to v3.7 successfully ... ***")

	END FUNCTION
	
	
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
	Dim objCmd
	Dim strSQLCommand
	Dim objRcdSet
	Dim returnVal
	
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

	objConn.CommandTimeout = 600
	
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

strSQLCommand = "select top 1 target_db_version from " & strDBName & "..t_sys_upgrade order by upgrade_id desc"

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

If objRcdSet.RecordCount=0 Then
			ValidateDataBase_SQLServer = "0"
		Else
      returnVal = objRcdSet.fields("target_db_version").value
      ValidateDataBase_SQLServer = returnVal
End If

	WriteLog("     Scanning database schema completed")
	'ValidateDataBase_SQLServer = nDBStatus	'*** Return Core status as retval ***
	
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
  
