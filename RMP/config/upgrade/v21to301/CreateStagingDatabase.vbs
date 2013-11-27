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
'* This function creates a staging database for every RMP installation.
'******************************************************************************************

Option Explicit

'*** Global Constants ***

'*** Allowable return values for msi script functions ***
Const kRetVal_SUCCESS	        = 1                '*** GOOD RESULT -- continue processing
Const kRetVal_USEREXIT          = 2                '*** Forced exit from install process -- rolls back
Const kRetVal_ABORT             = 3                '*** Abort the install process -- rolls back
Const kRetVal_SUSPEND           = 4                '*** ??? throws an exception -- not used here
Const kRetVal_SKIPTOEND         = 5                '*** Skips to end of install process -- no roll back

'*** File System Object (fso) Open Arguments ***
Const ForReading	= 1
Const ForWriting	= 2
Const ForAppending	= 8	

'*** Path Constants ***
Const INSTALL_LOG				= "\MetraTech_Install.log"


'*** Database Constants ***


Const kDBBackupDir				= "\BACKUP"
Const kDBBackupDataDeviceExt	= ".backup"
Const kDBTimeoutValue			= 1000       'DB operations timeout in milliseconds


Const kSQL_DBO_DATAPATHINFO				= "select filename from sysfiles where fileid=1"
Const kSQL_DBO_LOGPATHINFO				= "select filename from sysfiles where fileid=2"

Dim strInstallDir
Dim strAdminID
Dim strAdminPwd
Dim strDBName
Dim strDBMSHost
Dim strUserID
Dim strUserPwd


Main

Public Function Main() ' As Boolean
	dim numargs, arg
	
	wscript.echo wscript.arguments.length
	if wscript.arguments.length <> 12 then
		printusage
		exit function
	end if
	while numargs < wscript.arguments.length
		arg = LCase(wscript.arguments(numargs))
		wscript.echo arg
	
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
				strDBMSHost = wscript.arguments(numargs)
				
			case "-dboname"
				numargs = numargs + 1
				if numargs >= wscript.arguments.length then
					PrintUsage
					Exit Function
				end if
				strUserID = wscript.arguments(numargs)

			case "-dbopassword"
				wscript.echo "got herer"
				numargs = numargs + 1
				if numargs >= wscript.arguments.length then
					PrintUsage
					Exit Function
				end if
				strUserPwd = wscript.arguments(numargs)

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
	wscript.echo "		Database Server Name: " & strDBMSHost
	wscript.echo "		Database Name: " & strDBName
	wscript.echo "		Database Administrator Logon: " & strAdminID
	wscript.echo "		Database Administrator Password: " & strAdminPwd
	wscript.echo "		Database User Name: " & strUserID
	wscript.echo "		Database User Password: " & strUserPwd
	
	'Call the upgrade
	CreateStagingDB
	
End Function


Sub PrintUsage()
	wscript.echo "Usage: cscript CreateStagingDatabase.vbs -servername databaseServer -salogon databaseAdminstratorLogon -sapassword databaseAdministratorPassword -dbname databaseName -dboName databaseUserName -dboPassword databaseUserPassword"
End Sub

Function CreateStagingDB

    	Dim objInstallConfig 
    	Dim fso
    	Dim objNetwork


	Dim strDataDevicePath
	Dim nDataDeviceSize
	Dim strLogDevicePath
	Dim nLogDeviceSize
	
	Dim strMachineName
	Dim strStagingDBName
		
	Dim tmpstr, tmppath, strStagingDataDevicePath
	Dim strDataDeviceName
	Dim strLogDeviceName
	Dim strDataBackupPath
	Dim strLogBackupPath
	Dim strBackupPath
	Dim nOffset
	Dim nTimeout
	
	nDataDeviceSize = 100
	nLogDeviceSize = 25

	On Error Resume Next

	WriteLog("---> Entering CreateStagingDatabase()")
	CreateStagingDB = kRetVal_SUCCESS		'*** Assume success ***
	

	nTimeout = kDBTimeoutValue
		

	
	WriteLog ("Creating installconfig object")
	
	Set objInstallConfig = CreateObject("InstallConfig.InstallConfigObj")
	If (CheckErrors("CreateStagingDatabase::Creating InstallConfig object")) Then
		CreateStagingDB = kRetVal_ABORT
		WriteLog("---> Exiting CreateStagingDatabase()")
		Exit Function
		End If
	
	WriteLog ("Creating File system object")
	
	Set fso = CreateObject("Scripting.FileSystemObject")
	If (CheckErrors("CreateStagingDatabase::Creating File System object")) Then
		CreateStagingDB = kRetVal_ABORT
		WriteLog("---> Exiting CreateStagingDatabase()")
		Exit Function
	End If
	
	'set the name of the staging database
		
	WriteLog ("Creating Network object")
	
	set objNetwork = CreateObject("WScript.Network")
	if (CheckErrors("CreateStagingDatabase::Creating Wscript.Network object")) Then
		CreateStagingDB = kRetVal_ABORT
		WriteLog("---> Exiting CreateStagingDatabase()")
			Exit Function
	End If
	
	strMachineName = objNetwork.ComputerName
	
	'the machine name should not have a "-" in it
		if (instr(strMachineName, "-")> 0) Then
		'take out the the - from the name
		strMachineName = Replace (strMachineName, "-", "")
		writelog ("Changed Machine Name to : " & strMachineName)
			
	End if
	
		strStagingDBName = strDBName & "Stage_" & strMachineName
		WriteLog("--->Staging DatabaseName: " & strStagingDBName)
		set objNetwork = Nothing
		
	'*** Create the data file path for the staging database
	strDataDevicePath = GetDatafilePath(strDBMSHost, strDBName, strAdminID, strAdminPwd, 1)
	strLogDevicePath = GetDatafilePath(strDBMSHost, strDBName, strAdminID, strAdminPwd, 2)
	if (strDataDevicePath = "" OR strLogDevicePath = "")Then
		WriteLog("--->Could not find the location of the data and/or log files for the main database")
		CreateStagingDB = kRetVal_ABORT
		WriteLog("--->Exiting CreateStaginDatabase()")
		Exit Function
	End If
	
	nOffset = InStrRev(strDataDevicePath, strDBName)
	If (nOffset > 0) Then
		tmppath = fso.GetParentFolderName(strDataDevicePath)
		tmpstr = Replace(strDataDevicePath, strDBName, strStagingDBName, nOffset, 1)
		strStagingDataDevicePath = tmppath & "\" & tmpstr
		WriteLog("     Device path for staging database is: " & strStagingDataDevicePath)
		strDataDevicePath = strStagingDataDevicePath
	End If
		
			'*** Make the db backup path from the db data path ***
	If (strDataDevicePath <> "") Then
		strBackupPath = strDataDevicePath 
		nOffset = InStrRev(strBackupPath, "\")
		strBackupPath = Trim(Left(strBackupPath, nOffset-1))
		nOffset = InStrRev(strBackupPath, "\")
		strBackupPath = Trim(Left(strBackupPath, nOffset-1))
		strBackupPath = strBackupPath & kDBBackupDir
		WriteLog("     DB Backup path created from DB data path: " & strBackupPath)
	End If
		
	If (strDataDevicePath <> "") Then
		strDataDeviceName = fso.GetBaseName(strDataDevicePath)
		strDataBackupPath = strBackupPath & "\" & strDataDeviceName & kDBBackupDataDeviceExt
	Else
		strDataDeviceName = ""
		strDataBackupPath = ""
	End If
	
	'*** Create the log file path for the staging database ***
	nOffset = InStrRev(strLogDevicePath, strDBName)
	IF (nOffset > 0) Then
		tmppath = fso.GetParentFolderName(strLogDevicePath)
		tmpstr = Replace(strLogDevicePath, strDBName, strStagingDBName, nOffset, 1)
		strLogDevicePath = tmppath & "\" & tmpstr
		WriteLog("	Log Device Path for the staging database is: " & strLogDevicePath)
	End if			
	If (strLogDevicePath <> "") Then
		strLogDeviceName  = fso.GetBaseName(strLogDevicePath)
		strLogBackupPath = strBackupPath & "\" & strLogDeviceName & kDBBackupDataDeviceExt
	Else
		strLogDeviceName = ""
		strLogBackupPath = ""
	End If
	
	Set fso = Nothing
	
	WriteLog("     InitializeDBOperations: Calling InitializeDBOperations_SQL ...")
	objInstallConfig.InitializeDBOperations_SQL strAdminID, strAdminPwd, strStagingDBName, strDBMSHost, _
						strUserID, strUserPwd, strDataDeviceName, strDataDevicePath, nDataDeviceSize, _
						strLogDeviceName, strLogDevicePath, nLogDeviceSize, _
						strDataBackupPath, strLogBackupPath, nTimeout, 1
	
	If (CheckErrors("CreateStagingDB: objInstallConfig.InitializeDBOperations_SQL()")) Then
			CreateStagingDB = kRetVal_ABORT
		WriteLog("---> Exiting CreateStagingDB()")
		Exit Function
	End If
	
	WriteLog("     InitializeDBOperations: InitializeDBOperations_SQL successful ...")
	WriteLog("     Finished initializing database operations for a SQL Server DBMS...")
	
	objInstallConfig.InstallDatabase_WithoutDropDB 
	If (CheckErrors("CreateStagingDB: objInstallConfig.InstallDatabase()")) Then
		CreateStagingDB = kRetVal_ABORT
		WriteLog("---> Exiting CreateStaginDB()")
		Exit Function
	End If
	WriteLog("	Finished creating staging database...")
	Set objInstallConfig = Nothing
End Function


'******************************************************************************************
'*** GetDatafilePath
'******************************************************************************************

Function GetDatafilePath(strDBMSHost, strDBName, strAdminID, strAdminPwd, noption)
	
	Dim strConnectString
	Dim objConn
	Dim objCmd
	Dim objRcdSet
   	Dim strSQLCommand
   	Dim strtmpstring
   	Dim tmpstring
   	
   	WriteLog("---> Entering GetDatafilePath")
   	GetDatafilePath = ""
   	
   	strConnectString = "PROVIDER=MSDASQL; DRIVER={SQL Server}; " & _
					"SERVER=" & strDBMSHost & "; " & _ 
					"UID=" & strAdminID & "; " & _
					"PWD=" & strAdminPwd & "; " & _
					"DATABASE=" & strDBName
	
	Set objConn = CreateObject("ADODB.Connection")
	If (CheckErrors("GetDatafilePath::Creating ADO Connection Object")) Then
	   WriteLog("Error while validating DBMS -- See log file.")
	   WriteLog("---> Exiting GetDatafilePath()")
	   Exit Function
	End If
	
	'WriteLog strConnectString
	
	'On Error Resume Next
	objConn.Open(strConnectString)
	        
	 
	If Err.Number <> 0 Then
		If Err.Number = -2147467259 Then		'*** Can't find SQL Server ***
		  WriteLog ("Specified SQL Server (" & strDBMSHost & ") not found -- See log file.")
		End If
			
		If Err.Number = -2147217843 Then		'*** Can't log on to SQL Server ***
		  WriteLog("Specified credentials not valid -- See log file.")
		End If
				
		If (CheckErrors("GetDatafilePath::Opening ADO Connection")) Then
		  WriteLog("Error while connecting to DBMS -- See log file.")
		  WriteLog("---> Exiting GetDatafilePath()")
		  Set objConn = Nothing
		  Exit Function
		End If
	End If
	
	Set objCmd = CreateObject("ADODB.Command")
	If (CheckErrors("GetDatafilePath::Creating ADO Command Object")) Then
	   WriteLog("Error while creating command object -- See log file.")
	   WriteLog("---> Exiting GetDatafilePath()")
	   Set objConn = Nothing
	   Exit Function
	End If
	 	
		
	Set objCmd.ActiveConnection = objConn
	If (CheckErrors("GetDatafilePath::Setting ActiveConnection Property")) Then
	   WriteLog("Error while setting Active connection  -- See log file.")
	   WriteLog("---> Exiting GetDatafilePath()")
	   Set objCmd = Nothing
	   Set objConn = Nothing
	   Exit Function
	End If
	
	If noption = 1 Then
		strSQLCommand = kSQL_DBO_DATAPATHINFO
		WriteLog("	   " & strSQLCommand)
	else
		strSQLCommand = kSQL_DBO_LOGPATHINFO
		WriteLog("	   " & strSQLCommand)
	End If	
	
	objCmd.CommandText = strSQLCommand  'get the database associated with this user
	objCmd.CommandType = 1     'adCmdText
	WriteLog("     Attempting to find datafile path ...")
	
	Set objRcdSet = objCmd.Execute
	If (CheckErrors("GetDatafilePath::Executing command")) Then
	  WriteLog("Error while getting the datafile path  -- See log file.")
	  WriteLog("---> Exiting GetDatafilePath()")
	  objRcdSet.Close
	  Set objRcdSet = Nothing
	  Set objCmd = Nothing
	  Set objConn = Nothing
	  Exit Function
	End If
   	tmpstring = objRcdSet("filename")
   	
   	GetDatafilePath = trim(tmpstring)
   	Set objRcdSet = Nothing
   	Set objCmd = Nothing
   	Set objConn = Nothing

End Function

'***************************************************************************************************


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

'***************************************************************************************************


'supporting functions
'******************************************************************************************
'*** If error occured, logs message and returns TRUE, else returns FALSE ***
'******************************************************************************************
Function CheckErrors(sText)
	If (Err.Number <> 0) Then
		 '*** Log the error only if caller supplies text, otherwise caller was just
		 '*** using this to test the results of an operation.
		If (sText <> "") Then  
			WriteLog(sText & " : Err.Number=" & Err.Number & " : Err.Desc=" & Err.Description)
		End If
		CheckErrors = True
		Err.Number = 0
	Else
		CheckErrors = False
	End If
End Function
'*****************************************************************************************





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
