'*******************************************************************************
'*
'* Copyright 2000-2005 by MetraTech Corp.
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corp. MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corp. MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corp.,
'* and USER agrees to preserve the same.
'*
'* Name:        Common.vbs
'* Created By:  Alfred Flanagan (ResourceChecking.vbs) / Simon Morton
'* Description: Common utility functions and validation functions
'*
'*******************************************************************************

Option Explicit

'*** Product information
Const PRODUCT_NAME        = "MetraNet"
Const PRODUCT_VERSION     = "8.1.0"

'*** Global Constants
Const kRetVal_SUCCESS     = 1
Const kRetVal_USEREXIT    = 2
Const kRetVal_ABORT       = 3
Const kRetVal_SUSPEND     = 4
Const kRetVal_SKIPTOEND   = 5

'*** File System Object (fso) Open Arguments
Const kForReading         = 1
Const kForWriting         = 2
Const kForAppending       = 8  

'*** Database Constants
Const kDBType_None        = "0"
Const kDBType_SQL         = "1"
Const kDBType_Oracle      = "2"

Const kDBState_NO_DBMS    = "0"  '*** No valid DBMS found
Const kDBState_DBMS_OK    = "1"  '*** DBMS found, correct version
Const kDBState_DB_EXISTS  = "2"  '*** Database exists, schema not current
Const kDBState_DB_CURRENT = "9"  '*** Database exists, schema verified as current

Const kDBUser_NotExist    = 0
Const kDBUser_Exist       = 1
Const kDBUser_OtherDB     = 2

'*** Registry Constants
Const REG_METRATECH       = "HKLM\SOFTWARE\MetraTech"
Const REG_OS_VERSION      = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\CurrentVersion"
Const REG_OS_SERVICE_PK   = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\CSDVersion"
Const REG_OS_LANGUAGE     = "HKEY_USERS\.DEFAULT\Control Panel\International\sLanguage"
Const REG_IE_VERSION      = "HKLM\SOFTWARE\Microsoft\Internet Explorer\Version"
Const REG_MSMQ            = "HKLM\SOFTWARE\Microsoft\MSMQ\Setup\msmq_Core"
Const REG_ENHANCED_SECURITY = _
  "HKLM\SOFTWARE\Microsoft\Cryptography\Defaults\Provider\Microsoft Enhanced Cryptographic Provider v1.0\Image Path"
Const REG_CRYSTAL_ENT2013   = "HKLM\SOFTWARE\SAP BusinessObjects\Suite XI 4.0\Enterprise\Auth Plugins\secEnterprise\Version"
Const REG_CRYSTAL_ENTVER	= "14.0"
Const REG_RMP_DIR         = "HKLM\SOFTWARE\MetraTech\Install\InstallDir"
Const HKEY_LOCAL_MACHINE  = &H80000002

'*** Language constants
Const LANG_ENGLISH_US     = "ENU"

'*** Version Constants
Const VER_OS              = "5.2"
Const VER_OS_SP_ONE       = "Service Pack 1"
Const VER_OS_SP_TWO       = "Service Pack 2"
Const VER_OS_SP_THREE     = "Service Pack 3"
Const VER_OS_SP_FOUR      = "Service Pack 4"
Const VER_IE              = "6.0.3790.1830"

'MSSQL Version minimum requirements
Const VER_SQL_MAJOR       = 10 ' supports MSSQL 2008 and higher 
Const VER_SQL_MINOR       = 0
Const VER_SQL_BUILD       = 1399

Const VER_ORACLE_DBMS     = "10.1.0.3.0"

'*** Install Feature Constants
Const RMP_FEATURE         = "RMP"
Const MCM_FEATURE         = "MCM"
Const MPS_FEATURE         = "MPS"
Const MPM_FEATURE         = "MPM"
Const MAM_FEATURE         = "MAM"
Const MOM_FEATURE         = "MOM"
Const PS_FEATURE          = "PS"
Const RPT_FEATURE         = "Reporting"

'*** Global Variables
Dim goWsh
Dim goEnv
Dim goFso
Dim goDict

Dim gsLogFile
Dim gsInstallParams
Dim gsUninstallParams
Dim gsDotNetPath

'*** Main
Set goWsh  = CreateObject("Wscript.Shell")
Set goEnv  = goWsh.Environment("PROCESS")
Set goFso  = CreateObject("Scripting.FileSystemObject")
Set goDict = CreateObject("Scripting.Dictionary")

gsLogFile         = MakePath(goEnv("SYSTEMDRIVE"),PRODUCT_NAME & "_Install.log")

'*******************************************************************************
'*** I N S T A L L S H I E L D   E N T R Y   P O I N T S
'*******************************************************************************


'*******************************************************************************
'*** Load properties from the file specified in the MT_PROPERTY_FILE property.
'*******************************************************************************
'Test
'LoadProperties
Function LoadProperties()
  Dim sPropFilePath
  Dim oPropFile
  Dim sRawLine
  Dim sLine
  Dim sPropName
  Dim sPropValue
  Dim nIndex

  LoadProperties = kRetVal_ABORT
  On Error Resume Next

  EnterAction "LoadProperties"

  sPropFilePath = GetProperty("MT_PROPERTY_FILE_PATH")

  Set oPropFile = goFso.OpenTextFile(sPropFilePath, kForReading)
  If CheckErrors("opening file " & sPropFilePath & " for reading") Then Exit Function

  Do While Not oPropFile.AtEndOfStream
    sRawLine = oPropFile.ReadLine
    sLine = Replace(sRawLine, CHR(9), " ")  'Replace tabs with spaces for Trim funct
    nIndex = InStr(sLine,"#")               'Only take chars to the left of comments
    If nIndex = 0 Then
      nIndex = InStr(sLine,"'")             'Support ' as comment delimiter for backwards compatibility
    End If
    If nIndex = 0 Then
      sLine = Trim(sLine)
    Else
      sLine = Trim(Left(sLine, nIndex-1))
    End If

    If Len(sLine) > 0 Then
      nIndex = InStr(sLine,"=")
      If nIndex = 0 Then nIndex = InStr(sLine,"~")   'Support ~ as delimiter for backwards compatibility
      If nIndex < 2 Then
        WriteLog "<*** Error: parsing file " & sPropFilePath & ", delimiter ('=' or '~') not found"
        WriteLog "<*** Line: <" & sRawLine & ">"
        Exit Function
      End If
 
      sPropName  = Trim(Left(sLine,nIndex-1))
      sPropValue = Trim(Right(sLine,Len(sLine)-nIndex))

      SetProperty sPropName,sPropValue
    End If
  Loop

  oPropFile.Close()
  Set oPropFile = Nothing

  ExitAction "LoadProperties"

  LoadProperties = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Display MT properties
'Test
'Debug_GetAndLogProperties
'*******************************************************************************
Function Debug_GetAndLogProperties()

  Debug_GetAndLogProperties = kRetVal_ABORT
  On Error Resume Next

  EnterAction "Debug_GetAndLogProperties"

  GetProperty "ProgressType1"
  GetProperty "_IsMaintenance"

  GetProperty "ADDLOCAL"
  GetProperty "REINSTALL"
  GetProperty "REMOVE"
  GetProperty "INSTALLDIR"

  GetProperty "MT_DBMS_TYPE"
  GetProperty "MT_DBMS_COMPUTERNAME"
  GetProperty "MT_ADMIN_LOGIN_ID"
  GetProperty "_MT_ADMIN_LOGIN_PWD"

  GetProperty "MT_INIT_CONFIG_USER_ID"
  GetProperty "_MT_INIT_CONFIG_USER_PWD1"
  GetProperty "_MT_INIT_CONFIG_USER_PWD2"

  GetProperty "MT_DATABASE_NAME"
  GetProperty "MT_DATABASE_DATAFILE"
  GetProperty "MT_DATABASE_DATA_SIZE"
  GetProperty "MT_DATABASE_LOGFILE"
  GetProperty "MT_DATABASE_LOG_SIZE"
  GetProperty "MT_STAGING_DB_NAME"
  GetProperty "MT_STAGING_DB_DATAFILE"
  GetProperty "MT_STAGING_DB_DATA_SIZE"
  GetProperty "MT_STAGING_DB_LOGFILE"
  GetProperty "MT_STAGING_DB_LOG_SIZE"
  GetProperty "MT_DB_PARTITIONING_TYPE"
  GetProperty "MT_DB_PARTITIONING_PATHS"
  GetProperty "MT_DB_STATUS"

  GetProperty "_MT_CRYPTO_PWD1"
  GetProperty "_MT_CRYPTO_PWD2"
  GetProperty "_MT_CRYPTO_METRAVIEW_TICKET1"
  GetProperty "_MT_CRYPTO_METRAVIEW_TICKET2"

  GetProperty "MT_PAYSVR_COMPUTER_NAME"
  GetProperty "MT_PAYSVR_VERISIGN_ID"
  GetProperty "_MT_PAYSVR_VERISIGN_PWD1"
  GetProperty "_MT_PAYSVR_VERISIGN_PWD2"

  GetProperty "MT_RPT_APS_SERVER_NAME"
  GetProperty "MT_RPT_APS_SERVER_LOGIN"
  GetProperty "_MT_RPT_APS_SERVER_PWD1"
  GetProperty "_MT_RPT_APS_SERVER_PWD2"
  GetProperty "MT_RPT_DB_DATA_DIR"
  GetProperty "MT_RPT_DB_DATA_SIZE"

  GetProperty "MT_GP_SERVERNAME"
  GetProperty "MT_GP_INIT_DBNAME"
  GetProperty "_MT_GP_PWD1"
  GetProperty "_MT_GP_PWD2"

  GetProperty "MT_Ctrl_Seq_UI_or_Exec"
  GetProperty "MT_Ctrl_UI_Or_Silent"
  GetProperty "MT_Ctrl_Abort_Or_Continue"

  GetProperty "MT_PROPERTY_FILE_PATH"
  GetProperty "MT_PARAMS_OK"

  ExitAction "Debug_GetAndLogProperties"

  Debug_GetAndLogProperties = kRetVal_SUCCESS
End Function
'*******************************************************************************


'******************************************************************************************
'*** Add error message to a string
'******************************************************************************************
Function AddErrorMsg(sErrMsg,ByVal sNewMsg)
  sErrMsg = sErrMsg & "     " & sNewMsg & CHR(10)
End Function
'*******************************************************************************


'******************************************************************************************
'*** Check that a property is present (non-blank)
'******************************************************************************************
Function CheckPropertyPresent(sPropName,sPropDesc,ByRef sErrMsg,ByRef sResult)
  CheckPropertyPresent = True
  If Len(GetProperty(sPropName)) = 0 Then
    sErrMsg = sErrMsg & "     " & sPropDesc & " is missing;" & CHR(10)
    sResult = "No"
    CheckPropertyPresent = False
  End If
End Function
'******************************************************************************************


'******************************************************************************************
'*** Check that a property is numeric and non-zero
'******************************************************************************************
Function CheckPropertyNonZero(sPropName,sPropDesc,ByRef sErrMsg,ByRef sResult)
  If CheckPropertyPresent(sPropName, sPropDesc, sErrMsg, sResult) Then
    If Not IsNumeric(GetProperty(sPropName)) Then
      sErrMsg = sErrMsg & "     " & sPropDesc & " is not numeric;" & CHR(10)
      sResult = "No"
    Elseif GetProperty(sPropName) <= 0 Then
      sErrMsg = sErrMsg & "     " & sPropDesc & " must be greater than 0;" & CHR(10)
      sResult = "No"
    End If
  End If
End Function
'******************************************************************************************


'******************************************************************************************
'*** Check that a property is numeric and within the given range
'******************************************************************************************
Function CheckPropertyInRange(sPropName,sPropDesc, nMin, nMax, ByRef sErrMsg,ByRef sResult)
  If CheckPropertyPresent(sPropName, sPropDesc, sErrMsg, sResult) Then
    Dim sValue
    sValue = GetProperty(sPropName)

    If Not IsNumeric(sValue) Then
      sErrMsg = sErrMsg & "     " & sPropDesc & " is not numeric;" & CHR(10)
      sResult = "No"

    Else 
      Dim nValue
      nValue = CLng(sValue)

      If nValue < nMin Or nValue > nMax Then
        sErrMsg = sErrMsg & "     " & sPropDesc & " must be in the range " & nMin & "-" & nMax & ";" & CHR(10)
        sResult = "No"
      End If
    End If
  End If
End Function
'******************************************************************************************


'******************************************************************************************
'*** Check that a property is a file path
'******************************************************************************************
Function CheckPropertyIsAPath(sPropName,sPropDesc,ByRef sErrMsg,ByRef sResult)
  If CheckPropertyPresent(sPropName, sPropDesc, sErrMsg, sResult) Then
    Dim sValue
    sValue = GetProperty(sPropName)

    If InStr(sValue,":") = 0 Or InStr(sValue,"\") = 0 Then
      sErrMsg = sErrMsg & "     " & sPropDesc & " is not a valid file path;" & CHR(10)
      sResult = "No"
    End If
  End If
End Function
'******************************************************************************************


'******************************************************************************************
'*** Check that a value is a valid file path
'******************************************************************************************
Function CheckPathValue(sValue,ByRef sErrMsg,ByRef sResult)
  On Error Resume Next
  If Not goFso.FolderExists(sValue) Then
    MakeDir(sValue)
    If CheckErrors("Unable to create folder '" & sValue & "'.") Then
      sErrMsg = sErrMsg & "     '" & sValue & "' - unable to create folder" & CHR(10)
      sResult = "No"
    End If
  End If
End Function
'******************************************************************************************


'******************************************************************************************
'*** Creates whole folder tree
'******************************************************************************************
Function MakeDir (strPath)
	Dim strParentPath
	strParentPath = goFso.GetParentFolderName(strPath)

	If Not goFso.FolderExists(strParentPath) Then MakeDir strParentPath
	If Not goFso.FolderExists(strPath) Then goFso.CreateFolder strPath
	
	MakeDir = goFso.FolderExists(strPath)
End Function
'******************************************************************************************


'******************************************************************************************
'*** Check that two properties are equal
'******************************************************************************************
Function CheckPropertiesEqual(sPropName1,sPropDesc1,sPropName2,sPropDesc2,ByRef sErrMsg,ByRef sResult)
  If CheckPropertyPresent(sPropName1, sPropDesc1, sErrMsg, sResult) And _
     CheckPropertyPresent(sPropName2, sPropDesc2, sErrMsg, sResult) Then
    If GetProperty(sPropName1) <> GetProperty(sPropName2) Then
      sErrMsg = sErrMsg & "     " & sPropDesc1 & " and " & sPropDesc2 & " are not the same;" & CHR(10)
      sResult = "No"
    End If
  End If
End Function
'******************************************************************************************


'******************************************************************************************
'*** Check that two properties are not equal
'******************************************************************************************
Function CheckPropertiesNotEqual(sPropName1,sPropDesc1,sPropName2,sPropDesc2,ByRef sErrMsg,ByRef sResult)
  If CheckPropertyPresent(sPropName1, sPropDesc1, sErrMsg, sResult) And _
     CheckPropertyPresent(sPropName2, sPropDesc2, sErrMsg, sResult) Then
    If GetProperty(sPropName1) = GetProperty(sPropName2) Then
      sErrMsg = sErrMsg & "     " & sPropDesc1 & " and " & sPropDesc2 & " are the same;" & CHR(10)
      sResult = "No"
    End If
  End If
End Function
'******************************************************************************************


'******************************************************************************************
'*** Check that a property length is less than or equal to some limit
'******************************************************************************************
Function CheckPropertyLength(sPropName,sPropDesc,nMaxLen,ByRef sErrMsg,ByRef sResult)
  If CheckPropertyPresent(sPropName, sPropDesc, sErrMsg, sResult) Then
    If Len(GetProperty(sPropName)) > nMaxLen Then
      sErrMsg = sErrMsg & "     " & sPropDesc & " is longer than the maximum length of " & _
                nMaxLen & " characters;" & CHR(10)
      sResult = "No"
    End If
  End If
End Function
'******************************************************************************************

'*******************************************************************************
'*** Validate Default Crypto Parameters
'*******************************************************************************
Function Validate_Def_Crypto_Params()
	dim sResult
	dim sErrMsg
	
	Validate_Def_Crypto_Params = kRetVal_ABORT
	EnterAction "Validate_Def_Crypto_Params"
	
	sResult = "Yes"
	sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)
	
	CheckPropertyPresent "_MT_CRYPTO_DEF_PAYINST_KEY", "Payment Instrument", sErrMsg, sResult
	CheckPropertyPresent "_MT_CRYPTO_DEF_DB_PWD_KEY", "Database Password", sErrMsg, sResult
	CheckPropertyPresent "_MT_CRYPTO_DEF_TICKETING_KEY", "Ticketing", sErrMsg, sResult
	CheckPropertyPresent "_MT_CRYPTO_DEF_SVCDEF_PROP_KEY", "Service Definition Property", sErrMsg, sResult
	CheckPropertyPresent "_MT_CRYPTO_DEF_QUERYSTR_KEY", "Query String", sErrMsg, sResult
	CheckPropertyPresent "_MT_CRYPTO_DEF_PWDHASH_KEY", "Password Hash", sErrMsg, sResult
	CheckPropertyPresent "_MT_CRYPTO_DEF_PAYMETHOD_HASH_KEY", "Payment Method Hash", sErrMsg, sResult
	CheckPropertyPresent "_MT_CRYPTO_DEF_WORLDPAY_KEY", "World Pay Password", sErrMsg, sResult
	
	'CheckPropertiesEqual "MT_CRYPTO_DEF_PAYINST_KEY", "Payment Instrument", _
	'						"MT_CRYPTO_DEF_PAYINST_CNFRM", "Repeat Payment Instrument", sErrMsg, sResult
	'CheckPropertiesEqual "MT_CRYPTO_DEF_DB_PWD_KEY", "Database Password", _
	'						"MT_CRYPTO_DEF_DB_PWD_CNFRM", "Repeat Database Password", sErrMsg, eResult
	'CheckPropertiesEqual "MT_CRYPTO_DEF_TICKETING_KEY", "Ticketing", _
	'						"MT_CRYPTO_DEF_TICKETING_CNFRM", "Repeat Ticketing", sErrMsg, sResult
	'CheckPropertiesEqual "MT_CRYPTO_DEF_SVCDEF_PROP_KEY", "Service Definition Property", _
	'						"MT_CRYPTO_DEF_SVCDEF_PROP_CNFRM", "Repeat Service Definition Property", sErrMsg, sResult
	'CheckPropertiesEqual "MT_CRYPTO_DEF_QUERYSTR_KEY", "Query String", _
	'						"MT_CRYPTO_DEF_QUERYSTR_CNFRM", "Repeat Query String", sErrMsg, sResult
	'CheckPropertiesEqual "MT_CRYPTO_DEF_PWDHASH_KEY", "Password Hash", _
	'						"MT_CRYPTO_DEF_PWDHASH_CNFRM", "Repeat Password Hash", sErrMsg, sResult
	'CheckPropertiesEqual "MT_CRYPTO_DEF_PAYMETHOD_HASH_KEY", "Payment Method Hash", _
	'						"MT_CRYPTO_DEF_PAYMETHOD_HASH_CNFRM", "Repeat Payment Method Hash", sErrMsg, sResult
							
	CheckResults sResult, sErrMsg
	
	ExitAction "Validate_Def_Crypto_Params"
	Validate_Def_Crypto_Params = kRetVal_SUCCESS
End Function

'******************************************************************************************
'*** Validate Crypto RSA Config Parameters
'******************************************************************************************
Function Validate_Crypto_RSAConfig_Params()
	dim sResult
	dim sErrMsg
	
	Validate_Crypto_RSAConfig_Params = kRetVal_ABORT
	EnterAction "Validate_Crypto_RSAConfig_Params"
	
	sResult = "Yes"
	sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)
	
	CheckPropertyPresent "MT_CRYPTO_RSA_SERVER", "KMS Server", sErrMsg, sResult
	CheckPropertyPresent "MT_CRYPTO_RSA_CLIENT_CERT", "Client Certificate", sErrMsg, sResult
	CheckpropertyPresent "MT_CRYPTO_RSA_CLIENT_CERT_PWD", "Client Certificate Password", sErrMsg, sResult
	CheckPropertyPresent "MT_CRYPTO_RSA_TICKETING", "Ticketing Key", sErrMsg, sResult
	
	CheckPropertiesEqual "MT_CRYPTO_RSA_TICKETING", "Ticketing Key", _
							"MT_CRYPTO_RSA_TICKETING_CNFRM", "Repeat Ticketing Key", sErrMsg, sResult

	CheckResults sResult, sErrMsg
	ExitAction "Validate_Crypto_RSAConfig_Params"
	Validate_Crypto_RSAConfig_Params = kRetVal_SUCCESS
End Function

'******************************************************************************************
'*** Validate Crypto RSA KeyClass Params
'******************************************************************************************
Function Validate_Crypto_RSAKeyClass_Params()
	dim sResult
	dim sErrMsg
	
	Validate_Crypto_RSAKeyClass_Params = kRetVal_ABORT
	EnterAction "Validate_Crypro_RSAKeyClass_Params"
	
	sResult = "Yes"
	sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)
	
	CheckPropertyPresent "MT_CRYPTO_RSA_PAYINST", "Payment Instrument", sErrMsg, sResult
	CheckPropertyPresent "MT_CRYPTO_RSA_DB_PWD", "Database Password", sErrMsg, sResult
	CheckPropertyPresent "MT_CRYPTO_RSA_SVCDEF_PROP", "Service Definition Property", sErrMsg, sResult
	CheckPropertyPresent "MT_CRYPTO_RSA_QUERYSTR", "Query String", sErrMsg, sResult
	CheckPropertyPresent "MT_CRYPTO_RSA_PWDHASH", "Password Hash", sErrMsg, sResult
	CheckPropertyPresent "MT_CRYPTO_RSA_PAYMETHOD_HASH", "Payment Method Hash", sErrMsg, sResult
	CheckPropertyPresent "MT_CRYPTO_RSA_WORLDPAY", "World Pay Password", sErrMsg, sResult
	
	CheckResults sResult, sErrMsg
	ExitAction "Validate_Crypto_RSAKeyClass_Params"
	Validate_Crypto_RSAKeyClass_Params = kRetVal_SUCCESS
End Function

'******************************************************************************************
'*** Validate Crypto parameters
'Test
'SetProperty "_MT_CRYPTO_PWD1", "mtkey"
'SetProperty "_MT_CRYPTO_PWD2", "mtkeyx"
'Validate_RMP_Crypto_Params
'******************************************************************************************
Function Validate_RMP_Crypto_Params()
  Dim sResult
  Dim sErrMsg

  Validate_RMP_Crypto_Params = kRetVal_ABORT
  EnterAction "Validate_RMP_Crypto_Params"

  sResult = "Yes"
  sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)

  CheckPropertiesEqual "_MT_CRYPTO_PWD1", "Encryption Password", _
                       "_MT_CRYPTO_PWD2", "Repeat Encryption Password", sErrMsg, sResult

  CheckResults sResult, sErrMsg

  ExitAction "Validate_RMP_Crypto_Params"
  Validate_RMP_Crypto_Params = kRetVal_SUCCESS
End Function
'*******************************************************************************


'******************************************************************************************
'*** Validate Payment Server parameters
'******************************************************************************************
Function Validate_PaySvr_Params()
  Dim sResult
  Dim sErrMsg

  Validate_PaySvr_Params = kRetVal_ABORT
  EnterAction "Validate_PaySvr_Crypto_Params"

  sResult = "Yes"
  sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)

  CheckPropertyPresent "MT_PAYSVR_VERISIGN_ID",   "VeriSign ID",              sErrMsg, sResult
  CheckPropertiesEqual "_MT_PAYSVR_VERISIGN_PWD1", "VeriSign Password", _
                       "_MT_PAYSVR_VERISIGN_PWD2", "Repeat VeriSign Password", sErrMsg, sResult

  CheckResults sResult, sErrMsg

  ExitAction "Validate_PaySvr_Crypto_Params"
  Validate_PaySvr_Params = kRetVal_SUCCESS
End Function
'******************************************************************************************


'******************************************************************************************
'*** Validate MetraView Crypto parameters
'Test
'SetProperty "_MT_CRYPTO_METRAVIEW_TICKET1", "mtkey"
'SetProperty "_MT_CRYPTO_METRAVIEW_TICKET2", "mtkeyx"
'Validate_MPS_Crypto_Params
'******************************************************************************************
Function Validate_MPS_Crypto_Params()
  Dim sResult
  Dim sErrMsg

  Validate_MPS_Crypto_Params = kRetVal_ABORT
  EnterAction "Validate_MPS_Crypto_Params"

  sResult = "Yes"
  sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)

  CheckPropertiesEqual "_MT_CRYPTO_METRAVIEW_TICKET1", "MetraView Ticket", _
                       "_MT_CRYPTO_METRAVIEW_TICKET2", "Repeat MetraView Ticket", sErrMsg, sResult

  CheckResults sResult, sErrMsg

  ExitAction "Validate_MPS_Crypto_Params"
  Validate_MPS_Crypto_Params = kRetVal_SUCCESS
End Function
'******************************************************************************************


'******************************************************************************************
'*** Validate Database parameters
'******************************************************************************************
Function Validate_DB_CreateParams()
  Dim sResult
  Dim sErrMsg
  
  Validate_DB_CreateParams = kRetVal_ABORT
  EnterAction "Validate_DB_CreateParams"

  sResult = "Yes"
  sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)

'  CheckPropertyIsAPath "MT_DATABASE_DATAFILE",  "Database data file path", sErrMsg, sResult
  CheckPropertyNonZero "MT_DATABASE_DATA_SIZE", "Database data file size", sErrMsg, sResult
'  CheckPropertyIsAPath "MT_DATABASE_LOGFILE",   "Database log file path",  sErrMsg, sResult
  CheckPropertyNonZero "MT_DATABASE_LOG_SIZE",  "Database log file size",  sErrMsg, sResult
  
  If IsSqlServer() Then
  	
    Dim sPartitionPaths
    Dim sPartitionPathsArray
    Dim sPath
    
    sPartitionPaths = GetProperty("MT_DB_PARTITIONING_PATHS")
    sPartitionPathsArray = Split(sPartitionPaths,",")
    For Each sPath in sPartitionPathsArray
      CheckPathValue sPath, sErrMsg, sResult
    Next
    
    If sResult = "No" Then
      sErrMsg = sErrMsg & CHR(10) & "Please, check that valid path was entered" & CHR(10) 
	  sErrMsg = sErrMsg & "Ensure you have permissions for creation" & CHR(10) 
	  sErrMsg = sErrMsg & "Ensure Partitioning Device Paths are delimited by ','" & CHR(10)
	End If
  
  End If 
  
  if GetProperty("MT_PORTAL_SERVER_TYPE") <> 1 Then
	if GetProperty("MT_NO_PARTITION") <> 1 Then
		If CheckPropertyPresent("MT_DB_PARTITIONING_TYPE", "Database partitioning type", sErrMsg, sResult) Then
			If Not IsNumeric(GetProperty("MT_DB_PARTITIONING_TYPE")) Then
				sErrMsg = sErrMsg & "     Database partitioning type is not numeric;" & CHR(10)
				sResult = "No"
			Elseif GetProperty("MT_DB_PARTITIONING_TYPE") <= 0 Then
				sErrMsg = sErrMsg & "     Database partitioning can not be OFF for this server configuration;" & CHR(10)
				sResult = "No"
			End If
		End If
		'Changed for CORE-5214
	   'CheckPropertyNonZero "MT_DB_PARTITIONING_TYPE",  "Database partitioning type",  sErrMsg, sResult
	End If  
  End If

  CheckResults sResult, sErrMsg

  ExitAction "Validate_DB_CreateParams"
  Validate_DB_CreateParams = kRetVal_SUCCESS
End Function
'******************************************************************************************


'******************************************************************************************
'*** Validate Staging Database parameters
'Test
'Validate_StagingDB_Params()
'******************************************************************************************
Function Validate_StagingDB_Params()
  Dim sResult
  Dim sErrMsg

  Validate_StagingDB_Params = kRetVal_ABORT
  EnterAction "Validate_StagingDB_Params"

  CheckResults sResult, sErrMsg
  sResult = "Yes"
  sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)

'  CheckPropertyIsAPath "MT_STAGING_DB_DATAFILE", "Staging Database data file path", sErrMsg, sResult
'  CheckPropertyIsAPath "MT_STAGING_DB_LOGFILE",  "Staging Database log file path",  sErrMsg, sResult

  CheckResults sResult, sErrMsg

  ExitAction "Validate_StagingDB_Params"
  Validate_StagingDB_Params = kRetVal_SUCCESS
End Function
'******************************************************************************************


'*******************************************************************************
'*** Validate Oracle driver
'Test
'Dim sErrMsg
'Dim sResult
'SetProperty "MT_DB_DRIVER", "{Oracle in OraClient10g_home1}"
'CheckOracleDriver sErrMsg, sResult
'*******************************************************************************
Function CheckOracleDriver(sErrMsg, sResult)
  Dim sDriver
  Dim oReg
  Dim asSubKeys
  Dim sSubKey
  Dim sOraHomeName
  Dim oRegExp

  sDriver = GetProperty("MT_DB_DRIVER")

  If TestRegExp(sDriver, "\{Oracle +in +.+\}") Then
    Dim iPos
    iPos = InStrRev(sDriver," ") + 1
    sOraHomeName = Mid(sDriver,iPos,Len(sDriver)-iPos)

    'Get list of sub keys under HKLM\SOFTWARE\ORACLE
    Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
    If CheckErrors("creating StdRegProv object") Then Exit Function

    oReg.EnumKey HKEY_LOCAL_MACHINE, "SOFTWARE\ORACLE", asSubKeys
    If Not CheckErrors("getting subkeys belonging to HKLM\SOFTWARE\ORACLE") And IsArray(asSubKeys) Then

      For Each sSubKey In asSubKeys
        If UCase(Left(sSubKey,4)) = "KEY_" Then
          Dim sValue
          oReg.GetStringValue HKEY_LOCAL_MACHINE, "SOFTWARE\ORACLE\" & sSubKey, "ORACLE_HOME_NAME", sValue
          If Not CheckErrors("reading value ORACLE_HOME_NAME from key HKLM\SOFTWARE\ORACLE\" & sSubKey) Then
            If sValue = sOraHomeName Then
              Set oReg = Nothing
              Set oRegExp = Nothing
              Exit Function
            End If  
          End If  
        End If
      Next

      sErrMsg = "Oracle home """ & sOraHomeName & """ was not found in system registry."
      sResult = "No"

    Else
      sErrMsg = "Oracle client was not found in system registry."
      sResult = "No"
    End If

    Set oReg = Nothing

  Else
    sErrMsg = "Badly formed Oracle driver string; should be ""{Oracle in <Oracle home name>}""."
    sResult = "No"
  End If

  Set oRegExp = Nothing
End Function
'******************************************************************************************


'******************************************************************************************
'*** Validate Database Admin Login parameters
'******************************************************************************************
'Test
'SetProperty "MT_DBMS_TYPE", "2"
'SetProperty "MT_ADMIN_LOGIN_ID", "Sys"
'SetProperty "MT_DB_DRIVER", "{Oracle in OraClient10g_home1x}"
'Validate_DB_LoginParams
Function Validate_DB_LoginParams()
  Dim sResult
  Dim sErrMsg

  Validate_DB_LoginParams = kRetVal_ABORT
  EnterAction "Validate_DB_LoginParams"

  sResult = "Yes"
  CheckPropertyPresent "MT_ADMIN_LOGIN_ID", "Admin Login ID", sErrMsg, sResult
  CheckResults sResult, sErrMsg

  If GetProperty("MT_DBMS_TYPE") = "2" Then
    'CR14230: don't allow user to connect as SYS
    If LCase(GetProperty("MT_ADMIN_LOGIN_ID")) = "sys" Then 
      sResult = "No"
      CheckResults sResult, "The MetraNet database cannot be installed or uninstalled by the SYS user; Please use SYSTEM instead."
    End If

    If IsFeatureRequested("Database") And Not IsFeatureInstalled("Database") Then
      'CR14357: make sure that Oracle home specified in driver string actually exists
      CheckOracleDriver sErrMsg, sResult
      CheckResults sResult, sErrMsg
    End If
  End If

  ExitAction "Validate_DB_LoginParams"
  Validate_DB_LoginParams = kRetVal_SUCCESS
End Function
'*******************************************************************************


'******************************************************************************************
'*** Validate Great Plains parameters
'******************************************************************************************
Function Validate_GreatPlains_Params()
  Dim sResult
  Dim sErrMsg

  Validate_GreatPlains_Params = kRetVal_ABORT
  EnterAction "Validate_GreatPlains_Params"

  sResult = "Yes"
  sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)

  CheckPropertyPresent "MT_GP_SERVERNAME",  "Great Plains server name",     sErrMsg, sResult
  CheckPropertyPresent "MT_GP_INIT_DBNAME", "Great Plains database name",   sErrMsg, sResult
  CheckPropertiesEqual "_MT_GP_PWD1",        "Great Plains password", _
                       "_MT_GP_PWD2",        "Repeat Great Plains password", sErrMsg, sResult

  CheckResults sResult, sErrMsg

  ExitAction "Validate_GreatPlains_Params"
  Validate_GreatPlains_Params = kRetVal_SUCCESS
End Function
'******************************************************************************************


'******************************************************************************************
'*** Validate MetraPay Client parameters
'******************************************************************************************
Function Validate_PaymentSvrClient_Params()
  Dim sResult
  Dim sErrMsg

  Validate_PaymentSvrClient_Params = kRetVal_ABORT
  EnterAction "Validate_PaymentSvrClient_Params"

  sResult = "Yes"
  sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)

  CheckPropertyPresent "MT_PAYSVR_COMPUTER_NAME", "MetraPay server name", sErrMsg, sResult

  If CheckResults(sResult, sErrMsg) Then
    'parameter is OK, but notify the user if the MetraPay server can't be pinged
    Dim sMetraPaySvr

    sMetraPaySvr = GetProperty("MT_PAYSVR_COMPUTER_NAME")
    If sResult = "Yes" and Not PingHost(sMetraPaySvr) Then
      NotifyUser "WARNING:  Host " & sMetraPaySvr & " cannot be found on the network." & CHR(10) & CHR(10) & _
                 "Please makes sure that this server is available before attempting to use MetraPay."
    End If
  End If

  ExitAction "Validate_PaymentSvrClient_Params"
  Validate_PaymentSvrClient_Params = kRetVal_SUCCESS
End Function
'******************************************************************************************


'*******************************************************************************
'*** Create dialog sequence
'*******************************************************************************
'Test
'CreateDialogSequence
'*******************************************************************************
Function CreateDialogSequence()
  Dim sSequence

  CreateDialogSequence = False
  On Error Resume Next

  sSequence = "BEGIN"

  If IsFeatureRequested("RMP") Then       sSequence = sSequence & ",MT_ServerType,MT_Crypto"

  If IsFeatureRequested("Database") Then  sSequence = sSequence & ",MT_DBMSType,MT_DBUser,MT_DBCreate"

'  If IsFeatureRequested("PS") Or _
'     IsFeatureRequested("PSClient") Then  sSequence = sSequence & ",MT_PaySvr"

  If IsFeatureRequested("Reporting") Then sSequence = sSequence & ",MT_Reporting"

  If IsFeatureRequested("GPSupport") Then sSequence = sSequence & ",MT_GreatPlains"

  sSequence = sSequence & ",END"

  SetProperty "MT_DIALOG_SEQUENCE", sSequence

  CreateDialogSequence = True
End Function
'******************************************************************************************


'*******************************************************************************
'*** Set previous and next dialog properties
'*******************************************************************************
'Test
'SetDialogSequence("BEGIN")
'SetDialogSequence("MT_DBMSType")
'SetDialogSequence("END")
'*******************************************************************************
Function SetDialogSequence(sDialog)
  Dim asDialogs
  Dim sNextDialog
  Dim sPrevDialog
  Dim i

  SetDialogSequence = False

  sNextDialog = ""
  sPrevDialog = ""

  asDialogs = Split(GetProperty("MT_DIALOG_SEQUENCE"),",")

  For i = 0 To Ubound(asDialogs)
    If asDialogs(i) = sDialog Then
      If i > 0                 Then sPrevDialog = asDialogs(i-1)
      If i < UBound(asDialogs) Then sNextDialog = asDialogs(i+1)
      SetProperty "MT_PREV_DIALOG", sPrevDialog
      SetProperty "MT_NEXT_DIALOG", sNextDialog
      SetDialogSequence = True
      Exit Function
    End If
  Next 
End Function
'******************************************************************************************


'*******************************************************************************
'*** Return kRetVal_SUCCESS or kRetVal_ABORT based on a boolean value
'*******************************************************************************
'Test
'AbortIfNot(True)
'*******************************************************************************
Function AbortIfNot(bSuccess)
  If bSuccess Then
    AbortIfNot = kRetVal_SUCCESS
  Else
    AbortIfNot = kRetVal_ABORT
  End If
End Function
'******************************************************************************************


'*******************************************************************************
'*** Functions to set previous and next dialog properties for each dialog
'*******************************************************************************
Function SetDlgSeqBegin()
  SetDlgSeqBegin       = AbortIfNot(SetDialogSequence("BEGIN"))
End Function

Function SetDlgSeqServerType()
  SetDlgSeqServerType  = AbortIfNot(SetDialogSequence("MT_ServerType"))
End Function

Function SetDlgSeqCrypto()
  SetDlgSeqCrypto      = AbortIfNot(SetDialogSequence("MT_Crypto"))
End Function

Function SetDlgSeqPaySvr()
  SetDlgSeqPaySvr      = AbortIfNot(SetDialogSequence("MT_PaySvr"))
End Function

Function SetDlgSeqDBMSType()
  SetDlgSeqDBMSType    = AbortIfNot(SetDialogSequence("MT_DBMSType"))
End Function

Function SetDlgSeqDBUser()
  SetDlgSeqDBUser      = AbortIfNot(SetDialogSequence("MT_DBUser"))
End Function

Function SetDlgSeqDBCreate()
  SetDlgSeqDBCreate    = AbortIfNot(SetDialogSequence("MT_DBCreate"))
End Function

Function SetDlgSeqReporting()
  SetDlgSeqReporting   = AbortIfNot(SetDialogSequence("MT_Reporting"))
End Function

Function SetDlgSeqGreatPlains()
  SetDlgSeqGreatPlains = AbortIfNot(SetDialogSequence("MT_GreatPlains"))
End Function

Function SetDlgSeqEnd()
  SetDlgSeqEnd         = AbortIfNot(SetDialogSequence("END"))
End Function
'******************************************************************************************


'*******************************************************************************
'*** Validate System Resources
'*******************************************************************************
'Test
'SetProperty "INSTALLDIR", "V:\"
'SetProperty "MT_Ctrl_UI_Or_Silent", "UI"
'ResourceCheck
'*******************************************************************************
Function ResourceCheck()
  Dim sErrMsg
  Dim sResult
  Dim sInstallDir
  Dim sMsg
  Dim bPreReqOK
  
  ResourceCheck = kRetVal_ABORT
  On Error Resume Next
  EnterAction "ResourceCheck"

  sInstallDir    = GetProperty("INSTALLDIR")

  'set MT_CONFIG_DIR and MT_EXTENSIONS_DIR based on INSTALLDIR

  SetProperty "MT_CONFIG_DIR",     sInstallDir & "RMP\Config"
  SetProperty "MT_EXTENSIONS_DIR", sInstallDir & "RMP\Extensions"

  'if database installed and not selected for removal, get and verify database params (features being added might need them)

  If IsFeatureInstalled("Database") Then
    If Not GetDBParamsFromConfigFile() Then 
      NotifyUser "Unable to read database connection parameters from configuration file." & _
                 CHR(10) & CHR(10) & "Aborting installation ..."
      SetProperty "MT_Ctrl_Abort_Or_Continue", "Abort"
      WriteLog "<*** Aborting installation"
      Exit Function
    End If
    Dim sDBServer
    Dim sDBName
    Dim sStgDBName
    Dim sDBOUser
    Dim sDBOPwd
    sDBServer  = GetProperty("MT_DBMS_COMPUTERNAME")
    sDBName    = GetProperty("MT_DATABASE_NAME")
    sStgDBName = GetProperty("MT_STAGING_DB_NAME")
    sDBOUser   = GetProperty("MT_INIT_CONFIG_USER_ID")
    sDBOPwd    = GetProperty("_MT_INIT_CONFIG_USER_PWD1")
    If Not SetDatabaseDevicePaths(sDBName, sStgDBName, sDBServer, sDBOUser, sDBOPwd) Then
      NotifyUser "Unable to retrieve storage parameters from database." & _
                 CHR(10) & CHR(10) & "Aborting installation ..."
      SetProperty "MT_Ctrl_Abort_Or_Continue", "Abort"
      WriteLog "<*** Aborting installation"
      Exit Function
    End If
  End If

'  If Not IsProductInstalled() Then
'
'    'Check if other MetraTech product already installed
'  
'    Dim oReg
'    Dim asSubKeys
'
'    Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
'    If CheckErrors("creating StdRegProv object") Then Exit Function
'
'    oReg.EnumKey HKEY_LOCAL_MACHINE, "SOFTWARE\MetraTech", asSubKeys
'    If Not CheckErrors("") And IsArray(asSubKeys) Then
'      NotifyUser "MetraTech products are already installed on this system.  " & CHR(10) & CHR(10) & _
'                 "Please remove any other MetraTech products before attempting to install " & PRODUCT_NAME & "." & _
'                 CHR(10) & CHR(10) & "Aborting installation ..."
'      SetProperty "MT_Ctrl_Abort_Or_Continue", "Abort"
'      WriteLog "<*** Aborting installation"
'      Exit Function
'    End If
'  End If

  sErrMsg = "The following installation prerequisites were not met:" & CHR(10)
  sErrMsg = sErrMsg & "" & CHR(10)
  sResult = "Yes"

'#############################################################
'### MANDATORY REQUIREMENTS - ABORT INSTALL IF NOT PRESENT ###
'#############################################################
  
  WriteLog ""
  WriteLog "     Checking mandatory installation prerequisites"


  '************************
  '*** Operating system ***
  '************************

  bPreReqOK = False
  
  Dim sOsVersion
  Dim sNiceMsg
  sOsVersion = goWsh.RegRead(REG_OS_VERSION)
  If CheckErrors("") Then
    sMsg = "Could not read Windows version from the registry"

  Else
    sMsg = "Windows version (" & sOsVersion & ") "
    If StrComp(sOsVersion, VER_OS,1) >= 0 Then
      sMsg = sMsg & "meets"
      bPreReqOK = True
    Else
      sMsg = sMsg & "does not meet"
      sNiceMsg = "The Windows Server 2003 Operating System is not installed (see Step 1 in the Installation Notes)"
    End If
    sMsg = sMsg & " minimum requirement (" & VER_OS & ")"
  End If

  CheckPrereq bPreReqOK, sMsg, sResult, sErrMsg, sNiceMsg
  
  '*************************************
  '*** Operating system Service Pack ***
  '***      (Windows 2000 only)      ***
  '*************************************

  If sOsVersion = VER_OS Then
    bPreReqOK = False
  
    Dim sSvcPack
    sSvcPack = goWsh.RegRead(REG_OS_SERVICE_PK)
    If CheckErrors("") Then
      sMsg = "Could not read Service Pack number from the registry"

    Else
      Dim sMinReqmt
      sMinReqmt = " minimum requirement (" & VER_OS_SP_TWO & ")"
      sMsg = "Service Pack (" & sSvcPack & ") "
      'SP2 or higher
      If sSvcPack <> "" And _
         sSvcPack <> VER_OS_SP_ONE Then
'         sSvcPack <> VER_OS_SP_TWO And _
'         sSvcPack <> VER_OS_SP_THREE Then
        sMsg = sMsg & "meets" & sMinReqmt
        bPreReqOK = True
      Else
        sMsg = sMsg & "does not meet" & sMinReqmt & " (see Step 1 in the Installation Notes)"
      End if
    End If

    CheckPrereq bPreReqOK, sMsg, sResult, sErrMsg, ""
  End If
  
  '*********************************
  '*** Internet Explorer Version ***
  '*********************************

  bPreReqOK = False

  Dim sIEVersion
  sIEVersion = goWsh.RegRead(REG_IE_VERSION)
  If CheckErrors("") Then
    sMsg = "Could not read Internet Explorer version from the registry"
  
  Else
    sMsg = "Internet Explorer version (" & sIEVersion & ") "
    If StrComp(sIEVersion,VER_IE,1) >= 0 Then
      sMsg = sMsg & "meets"
      bPreReqOK = True
    Else
      sMsg = sMsg & "does not meet"
    End If
    sMsg = sMsg & " minimum requirement (" & VER_IE & ")"
  End IF

  CheckPrereq bPreReqOK, sMsg, sResult, sErrMsg, ""
  
  '**********************
  '***      MSMQ      ***
  '**********************

  bPreReqOK = False

  sMsg = "MSMQ is "
  goWsh.RegRead(REG_MSMQ)
  If CheckErrors("") Then
    sMsg = sMsg & "not installed (see Step 2 in the Installation Notes)"
  Else
    sMsg = sMsg & "installed"
    bPreReqOK = True
  End If

  CheckPrereq bPreReqOK, sMsg, sResult, sErrMsg, ""
  
  '**********************
  '***     MSXML4     ***
  '**********************

  Dim oMSXML4

  bPreReqOK = False

  sMsg = "MSXML4 is "
  Set oMSXML4 = CreateObject("MSXML2.DOMDocument.4.0")
  If CheckErrors("") Then
    sMsg = sMsg & "not installed (see Step 8 in the Installation Notes)"
  Else
    sMsg = sMsg & "installed"
    bPreReqOK = True
    Set oMSXML4 = Nothing
  End If

  CheckPrereq bPreReqOK, sMsg, sResult, sErrMsg, ""


  '**********************
  '*** .NET Framework ***
  '**********************

  bPreReqOK = False
   
  Dim sDotNetPath
  if IsDotNetFrameworkInstalled(sDotNetPath, sMsg) Then
    bPreReqOK = True
  End If

  CheckPrereq bPreReqOK, sMsg, sResult, sErrMsg, ""
  
  '*************************************
  '*** IIS Installed
  '*************************************

  If IsAnyFeatureRequested("UI,MAM,MOM,MCM,MPM,MPS,WS,Listener,PS") Then
  bPreReqOK = False

  Dim oIISRoot
    Dim sIIS

    sIIS = "Internet Information Services (IIS)"

  If Not GetIISObject(oIISRoot,"W3SVC/1/Root") Then
      sMsg = sIIS & " is not installed (see Step 2 in the Installation Notes)"

  Else
    Dim oIISInfo
    Dim nIISVersion

    If Not GetIISObject(oIISInfo,"W3SVC/Info") Then Exit Function

    nIISVersion = oIISInfo.MajorIISVersionNumber
    If CheckErrors("") Or nIISversion < 6 Then
        sMsg = sIIS & " Version 6 is not installed (see Step 2 in the Installation Notes)"

    Else
        Dim bIISAdminEnabled
        Dim bW3SvcEnabled
        If Not CheckServiceEnabled(bIISAdminEnabled,"iisadmin") Then Exit Function
        If Not CheckServiceEnabled(bW3SvcEnabled,   "w3svc")    Then Exit Function

        If bIISAdminEnabled And bW3SvcEnabled Then
          sMsg = sIIS & " Version " & nIISVersion & " is installed"
      bPreReqOK = True

        Else
          sMsg = ""
          If Not bIISAdminEnabled Then
            sMsg = sMsg & "IIS Admin Service (iisadmin) is disabled"
          End If
          If Not bW3SvcEnabled Then
            If sMsg <> "" Then sMsg = sMsg & "." & CHR(10)
            sMsg = sMsg & "World Wide Web Publishing Service (w3svc) is disabled"
          End If
        End If
    End If
  End If

  CheckPrereq bPreReqOK, sMsg, sResult, sErrMsg, ""
  End If
  
  '*********************************
  '*** TEMP folder writable      ***
  '*********************************

  bPreReqOK = False

  Dim sTmpDir

  sTmpDir = goEnv("TEMP")

  If Len(""&sTmpDir) > 0 Then  
    sMsg = "TEMP directory (" & sTmpDir & ") "

    If DirWritable(sTmpDir, sMsg) Then
      bPreReqOK = True
    End If

  Else
    sMsg = "TEMP environment variable is not defined"
  End If

  CheckPrereq bPreReqOK, sMsg, sResult, sErrMsg, ""
  
  '*********************************
  '*** 128 BIT ENHANCED SECURITY ***
  '*********************************

  bPreReqOK = False

  sMsg =  "128-bit enhanced security is "
  goWsh.RegRead(REG_ENHANCED_SECURITY)
  If CheckErrors("") Then
    sMsg = sMsg & "not installed"
  Else
    sMsg = sMsg & "installed"
    bPreReqOK = True
  End if
  
  CheckPrereq bPreReqOK, sMsg, sResult, sErrMsg, ""

  '-----------------------------------------------------------------------------
  ' Check if US-English OS is installed
  '-----------------------------------------------------------------------------

  bPreReqOK = False

  Dim sLanguage
  sLanguage = goWsh.RegRead(REG_OS_LANGUAGE)
  If CheckErrors("") then
    sMsg = "Unable to detect which language version of Windows is installed"
  Else
    If sLanguage <> LANG_ENGLISH_US then
      sMsg = "The language (" & sLanguage & ") of this Windows installation is not supported"
    Else
      sMsg = "English (U.S.) Language (" & sLanguage & ") version of Windows detected"
      bPreReqOK = True
    End if
  End if

  CheckPrereq bPreReqOK, sMsg, sResult, sErrMsg, ""
  
  '-----------------------------------------------------------------------------
  'Abort with error message if any mandatory requirements have not been met
  '-----------------------------------------------------------------------------
  
  SetProperty "MT_PARAMS_OK", sResult
  If (sResult = "No") Then
    sErrMsg = sErrMsg & CHR(10)
    sErrMsg = sErrMsg & _
      "You must ensure that all prerequisites are met in order to proceed.  " & _
      CHR(10) & CHR(10) & GetInstallInfoMsg() & CHR(10) & CHR(10) & "Aborting installation ..."
  
    NotifyUser(sErrMsg)

    SetProperty "MT_Ctrl_Abort_Or_Continue", "Abort"
    WriteLog "<*** Aborting installation"
    Exit Function
  End If
  
  
'##############################################################################
'### OPTIONAL REQUIREMENTS - NOTIFY USER IF NOT PRESENT - DON'T FORCE ABORT ###
'##############################################################################  
  
  WriteLog ""
  WriteLog "     Checking other installation conditions"
  
  If IsFeatureRequested("RMP") Then

    '-----------------------------------------------------------------------------
    ' Check to see if there is a pre-existing MetraTech folder
    '-----------------------------------------------------------------------------

    bPreReqOK = False

    sErrMsg = "WARNING:  "
    sMsg = "Folder " & sInstallDir & " "
    If goFso.FolderExists(sInstallDir) then
      sMsg = sMsg & "already exists"
    Else
      sMsg = sMsg & "does not exist"
      bPreReqOK = True
    End if
  
    If Not CheckPrereq(bPreReqOK, sMsg, sResult, sErrMsg, "") Then
      sErrMsg = sErrMsg & CHR(10) & "Please remove it and then click OK to proceed with installation."
      NotifyUser(sErrMsg)
    End If

  End if

  If IsFeatureRequested("Reporting") Then

    bPreReqOK = False
    sErrMsg = "WARNING:  "
    sMsg = "Crystal Report 2013 Client components are "

    Dim crVer
    'Check for Crystal XI SDK
    crVer = goWsh.RegRead(REG_CRYSTAL_ENT2013)
    If ((CheckErrors("finding Crystal in registry")) Or (crVer <> REG_CRYSTAL_ENTVER)) Then
      sMsg = sMsg & "not installed"
    Else
      sMsg = sMsg & "installed"
      bPreReqOK = True
    End If

    If Not CheckPrereq(bPreReqOK, sMsg, sResult, sErrMsg, "") Then
      sErrMsg = sErrMsg & CHR(10) & _
        "Please install the Crystal Report 2013 Client before attempting to use the Reporting feature (see MetraTech Installation Guide)"
      NotifyUser(sErrMsg)
    End If

  End If

  'create dialog sequence file
  If Not CreateDialogSequence() Then Exit Function

  ExitAction "ResourceCheck"
  ResourceCheck = kRetVal_SUCCESS
    
End Function
'*******************************************************************************


'*******************************************************************************
'*** Validate portal parameters
'Test
'ValidatePortalParams
'*******************************************************************************
Function ValidatePortalParams()
  Dim sResult
  Dim sErrMsg

  ValidatePortalParams = kRetVal_ABORT
  On Error Resume Next

  EnterAction "ValidatePortalParams"

  sResult = "Yes"
  sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)

  CheckPropertyPresent "MT_PORTAL_TITLE",       "Default Page Title", sErrMsg, sResult
  CheckPropertyPresent "MT_PORTAL_SERVER_DESC", "Server Description", sErrMsg, sResult
  CheckPropertyInRange "MT_PORTAL_SERVER_TYPE", "Server Type", 0, 3,  sErrMsg, sResult

  CheckResults sResult, sErrMsg

  ExitAction "ValidatePortalParams"

  ValidatePortalParams = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Validate primary pipeline server name
'Test
'ValidatePrimaryPipelineServer
'*******************************************************************************
Function ValidatePrimaryPipelineServer()
  Dim sResult
  Dim sErrMsg
  Dim sPPServer

  ValidatePrimaryPipelineServer = kRetVal_ABORT
  On Error Resume Next

  EnterAction "ValidatePrimaryPipelineServer"

  If IsFeatureRequested("Listener") Then
    SetProperty "MT_PRIMARY_PIPELINE_SERVER", GetHostName()

  Else
    sResult = "Yes"
    sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)

    CheckPropertyPresent "MT_PRIMARY_PIPELINE_SERVER", "Primary Pipeline Server name", sErrMsg, sResult
    If CheckResults(sResult, sErrMsg) Then
      sPPServer = GetProperty("MT_PRIMARY_PIPELINE_SERVER")
      If HostIsMe(sPPServer) Then
        NotifyUser "This server cannot be the primary pipeline server because the Listener has not been selected " & _
                   "for installation." & CHR(10)
        SetProperty "MT_PARAMS_OK", "No"

      Else
        If Not PingHost(sPPServer) Then
          NotifyUser "WARNING:  Host " & sPPServer & " cannot be found on the network." & CHR(10) & CHR(10) & _
                     "Please makes sure that this server is available before attempting to use the pipeline."
        End If
      End If
    End If
  End If

  ExitAction "ValidatePrimaryPipelineServer"

  ValidatePrimaryPipelineServer = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Validate Simulated Time parameter
'Test
'SetProperty "MT_SIMULATED_TIME", "1999/06/01"
'ValidateSimulatedTime
'*******************************************************************************
Function ValidateSimulatedTime
  Dim sSimTime

  ValidateSimulatedTime = kRetVal_ABORT
  On Error Resume Next
  EnterAction "ValidateSimulatedTime"

  sSimTime = GetProperty("MT_SIMULATED_TIME")
  If Len("" & sSimTime) > 0 Then
    Dim dSimTime
    dSimTime = CDate(sSimTime)

    If CheckErrors("validating simulated time: " & sSimTime) Then
      NotifyUser "Invalid simulated time: " & sSimTime
      SetProperty "MT_PARAMS_OK", "No"

    Elseif Year(dSimTime) < 2000 Then
      NotifyUser "Simulated time may not be earlier than the year 2000"
      SetProperty "MT_PARAMS_OK", "No"

    Else
      WriteLog "     " & dSimTime & " is a valid date/time value"
      SetProperty "MT_PARAMS_OK", "Yes"
    End If
  End If

  ExitAction "ValidateSimulatedTime"
  ValidateSimulatedTime = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Validate Reporting Parameters
'*******************************************************************************
'Test
'SetProperty "MT_RPT_APS_SERVER_NAME",  "rpt_server"
'SetProperty "MT_RPT_APS_SERVER_LOGIN", "rpt_login"
'SetProperty "MT_RPT_APS_SERVER_PWD1",  "rpt_password"
'SetProperty "MT_RPT_APS_SERVER_PWD2",  "rpt_password"
'SetProperty "MT_RPT_DB_DATA_DIR",      "c:\temp"
'SetProperty "MT_RPT_DB_DATA_SIZE",     "10"
'ValidateReportingParams
'*******************************************************************************
Function ValidateReportingParams()
  Dim sResult
  Dim sErrMsg

  ValidateReportingParams = kRetVal_ABORT
  On Error Resume Next

  EnterAction "ValidateReportingParams"
  sResult = "Yes"
  sErrMsg = "ERROR:  The following parameters are incorrect or missing:" & CHR(10) & CHR(10)

  CheckPropertyPresent "MT_RPT_APS_SERVER_NAME",  "APS Server name",                 sErrMsg, sResult
  CheckPropertyPresent "MT_RPT_APS_SERVER_LOGIN", "APS Server login",                sErrMsg, sResult
  CheckPropertiesEqual "_MT_RPT_APS_SERVER_PWD1",  "APS Server password", _
                       "_MT_RPT_APS_SERVER_PWD2",  "Repeat APS Server password",      sErrMsg, sResult
  If IsSqlServer() Then
    CheckPropertyIsAPath "MT_RPT_DB_DATA_DIR",    "Datamart Data File directory",    sErrMsg, sResult
  End If
  CheckPropertyNonZero "MT_RPT_DB_DATA_SIZE",     "Datamart Initial Data File size", sErrMsg, sResult

  CheckResults sResult, sErrMsg

  ExitAction "ValidateReportingParams"
  ValidateReportingParams = kRetVal_SUCCESS
End Function
'*******************************************************************************


'******************************************************************************************
'*** Abort install if MT_Ctrl_Abort_Or_Continue property is set to Abort
'******************************************************************************************
Function ContinueOrAbort()
  ContinueOrAbort = kRetVal_ABORT

  EnterAction "ContinueOrAbort"

  If GetProperty("MT_Ctrl_Abort_Or_Continue") = "Abort" Then
    WriteLog "<*** Errors in property values have been found and logged by validation scripts."
    WriteLog "<*** Exiting installation process."
    Exit Function
  End If

  ExitAction "ContinueOrAbort"

  ContinueOrAbort = kRetVal_SUCCESS
End Function
'******************************************************************************************


'******************************************************************************************
'*** Confirm user wants to remove the platform
'Test
'VerifyRemoveAll
'******************************************************************************************
Function VerifyRemoveAll()
  Dim nReturn
  Dim asFeatures
  Dim sFeature

  VerifyRemoveAll = kRetVal_ABORT

  EnterAction "VerifyRemoveAll"

  asFeatures = array("RMP","UI","MAM","MOM","MPS","MCM","MPM","PS","PSClient","Database")

  For Each sFeature in asFeatures
    GetFeatureCurrentState sFeature, -1
    GetFeatureRequestState sFeature, -1
  Next

  'CR14525 Set default administrator login based on DBtype
  'If file is not readable or contains an invalid DBMS type we will catch this later on
  If GetDBParamsFromConfigFile() Then
    If GetProperty("MT_DBMS_TYPE") = kDBType_Oracle Then
      SetProperty "MT_ADMIN_LOGIN_ID", "system"
    Else
      SetProperty "MT_ADMIN_LOGIN_ID", "sa"
    End If
  End If

  ExitAction "VerifyRemoveAll"

  VerifyRemoveAll = kRetVal_SUCCESS
End Function
'******************************************************************************************


'******************************************************************************************
'*** Reset previously set DBMS type property
'******************************************************************************************
Function Reset_DBMS_Type()
  Reset_DBMS_Type = kRetVal_ABORT

  EnterAction "Reset_DBMS_Type"

  'Why did we do this?  SetProperty "MT_DBMS_TYPE",            "1"
  SetProperty "MT_PAYSVR_COMPUTER_NAME", "localhost"

  ExitAction "Reset_DBMS_Type"

  Reset_DBMS_Type = kRetVal_SUCCESS
End Function
'******************************************************************************************


'*******************************************************************************
'*** Validate DBMS Type
'Test
'ValidateDBMSType
'*******************************************************************************
Function ValidateDBMSType
  ValidateDBMSType = kRetVal_ABORT  

  On Error Resume Next
  EnterAction "ValidateDBMSType"

  If Not DBTypeSupport() Then
    NotifyUser "Error in install package.  Please contact MetraTech Support."
    Exit Function
  End If

  Dim sParamsOK
  sParamsOK = "Yes"

  
  'FIXME Need to check for Oracle client

  SetProperty "MT_PARAMS_OK", sParamsOK
  
  ExitAction "ValidateDBMSType"

  ValidateDBMSType = kRetVal_SUCCESS  
End Function
'*******************************************************************************


'******************************************************************************************
'*** Validate Database parameters
'Test
'Validate_DB_Params
'******************************************************************************************
Function Validate_DB_Params()
  Dim sResult
  Dim sErrMsg

  Validate_DB_Params = kRetVal_ABORT
  EnterAction "Validate_DB_Params"

  sResult = "Yes"
  sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)

  CheckPropertyPresent "MT_DBMS_COMPUTERNAME", "Database server name", sErrMsg, sResult
  CheckPropertyPresent "MT_ADMIN_LOGIN_ID",    "Admin Login ID",       sErrMsg, sResult

  If CheckResults(sResult, sErrMsg) Then
    'Properties OK, now verify server login and version
    Dim sDBServer
    Dim sAdminUid
    Dim sAdminPwd

    sDBServer = GetProperty("MT_DBMS_COMPUTERNAME")
    sAdminUid = GetProperty("MT_ADMIN_LOGIN_ID")
    sAdminPwd = GetProperty("_MT_ADMIN_LOGIN_PWD")

    If Not ValidateDBMS(sDBServer, sAdminUid, sAdminPwd, True) Then
      SetProperty "MT_PARAMS_OK", "No"

    ElseIf Not HostIsMe(sDBServer) Then
      'Installing a database remotely, better give the DTC configuration warning
      SetProperty "MT_DATABASE_REMOTE", "1"
	  Dim sDTCMsg
      sDTCMsg = "WARNING: You have selected a remote database server." & _
                CHR(10) & CHR(10) & _
                "Microsoft's Distributed Transaction Coordinator (DTC) must be properly configured" & _
                " both on the local machine and on the database server before proceeding." & _
                " Please refer to the Configure DTC-Related Settings topic in the " & PRODUCT_NAME & " Installation Guide." & _
                "(Download from https://extranet.metratech.com.) " & _
                CHR(10) & CHR(10) & _
                "IMPORTANT: This installation WILL NOT SUCCEED unless DTC is configured correctly."
      If Not AskUserOKCancel(sDTCMsg) Then
        SetProperty "MT_PARAMS_OK", "No"
      End If
    End If
  End If

  ExitAction "Validate_DB_Params"
  Validate_DB_Params = kRetVal_SUCCESS
End Function
'******************************************************************************************


'******************************************************************************************
'*** Suggest database names (if not already set by silent install)
'Test
'SuggestDBNames
'******************************************************************************************
Function SuggestDBNames()
  Dim sDBServer
  Dim sDBName
  Dim sDBUser
  Dim sStgDBName
  Dim bIsPS

  EnterAction "SuggestDBNames"

  If IsSilentInstall() Then
    sDBName    = GetProperty("MT_DATABASE_NAME")
    sStgDBName = GetProperty("MT_STAGING_DB_NAME")
    sDBUser    = GetProperty("MT_INIT_CONFIG_USER_ID")
  Else
    sDBName    = ""
    sStgDBName = ""
    sDBUser    = ""
  End If

  sDBServer = LCase(GetProperty("MT_DBMS_COMPUTERNAME"))

  bIsPS = False
  If sDBServer <> "localhost" And sDBServer <> "127.0.0.1" And sDBServer <> LCase(GetHostName()) Then
    If GetFeatureRequestState("PS",3) > 2 Or GetFeatureCurrentState("PS",3) > 2 Then
      bIsPS = True
    End If
  End If 

  'Suggest NetPay/npdbo if this is seems to be a payment server, NetMeter/nmdbo otherwise

' CORE-231: For Oracle, installer set NetPay as the name of the default MetraNet Core database - mjp
'  If sDBName = "" Then
'    If bIsPS Then
'      sDBName = "NetPay"
'    Else
'      sDBName = "NetMeter"
'    End If

  If sDBName = "" Then
       sDBName = "NetMeter"
	
       SetProperty "MT_DATABASE_NAME", sDBName
  End If

  If sDBUser = "" Then
    If bIsPS Then
      sDBUser = "npdbo"
    Else
      sDBUser = "nmdbo"
    End If

    SetProperty "MT_INIT_CONFIG_USER_ID", sDBUser
  End If

  If sStgDBName = "" Then
    sStgDBName = GenStagingDBName (sDBName)

    SetProperty "MT_STAGING_DB_NAME", sStgDBName
  End If

  ExitAction "SuggestDBNames"
  
  SuggestDBNames = kRetVal_SUCCESS
End Function
'******************************************************************************************


'******************************************************************************************
'*** Validate Database User Login parameters
'Test
'SetProperty "MT_DATABASE_NAME",        "NetMeter"
'SetProperty "MT_STAGING_DB_NAME",      "NetMeter"
'SetProperty "MT_INIT_CONFIG_USER_ID",  "nmdbo"
'SetProperty "_MT_INIT_CONFIG_USER_PWD1","MetraTech1"
'SetProperty "_MT_INIT_CONFIG_USER_PWD2","MetraTech2"
'Validate_DB_UserLoginParams
'******************************************************************************************
Function Validate_DB_UserLoginParams()
  Dim sResult
  Dim sErrMsg

  Validate_DB_UserLoginParams = kRetVal_ABORT
  EnterAction "Validate_DB_UserLoginParams"

  sResult = "Yes"
  sErrMsg = "The following parameters are incorrect or missing:" & CHR(10)

  CheckPropertyLength  "MT_DATABASE_NAME",         "Core Database name",    28, sErrMsg, sResult
  CheckPropertyLength  "MT_STAGING_DB_NAME",       "Staging Database name", 28, sErrMsg, sResult
  CheckPropertiesNotEqual "MT_DATABASE_NAME",      "Core Database name", _
                          "MT_STAGING_DB_NAME",    "Staging Database name",     sErrMsg, sResult
  CheckPropertyPresent "MT_INIT_CONFIG_USER_ID",   "DBO Login ID",              sErrMsg, sResult
  CheckPropertiesEqual "_MT_INIT_CONFIG_USER_PWD1", "DBO Login Password", _
                       "_MT_INIT_CONFIG_USER_PWD2", "Repeat DBO Login Password", sErrMsg, sResult

  CheckResults sResult, sErrMsg

  ExitAction "Validate_DB_UserLoginParams"
  Validate_DB_UserLoginParams = kRetVal_SUCCESS
End Function
'******************************************************************************************


'*******************************************************************************
'*** Validate DBO User
'Test
'SetProperty "MT_ADMIN_LOGIN_ID",       "sa"
'SetProperty "_MT_ADMIN_LOGIN_PWD",      "MetraTech1"
'SetProperty "MT_DATABASE_NAME",        "NetMeter"
'SetProperty "MT_DBMS_COMPUTERNAME",    "localhost"
'SetProperty "MT_INIT_CONFIG_USER_ID",  "nmdbo"
'SetProperty "_MT_INIT_CONFIG_USER_PWD1","MetraTech1"
'ValidateDBOUser
'*******************************************************************************
Function ValidateDBOUser
  Dim sAdminUid
  Dim sAdminPwd
  Dim sDBName
  Dim sDBServer
  Dim sDBOUser
  Dim sDBOPwd
  Dim nUserExists

  ValidateDBOUser = kRetVal_ABORT  
  On Error Resume Next

  EnterAction "ValidateDBOUser"
 
  sAdminUid = GetProperty("MT_ADMIN_LOGIN_ID")
  sAdminPwd = GetProperty("_MT_ADMIN_LOGIN_PWD")
  sDBName   = GetProperty("MT_DATABASE_NAME")
  sDBServer = GetProperty("MT_DBMS_COMPUTERNAME")   
  sDBOUser  = GetProperty("MT_INIT_CONFIG_USER_ID")
  sDBOPwd   = GetProperty("_MT_INIT_CONFIG_USER_PWD1")    

  If Not CheckDBUserExists (nUserExists, sDBServer, sDBName, sAdminUid, sAdminPwd, sDBOUser) Then
    NotifyUser "Unable to verify existence of user '" & sDBOUser & "'." & CHR(10) & CHR(10) & _
               "Please verify database parameters and check the install log for more information."
    Exit Function
  End If
  
  If nUserExists = kDBUser_Exist Then
    Dim bConnOK
    If Not CheckDBConnection (bConnOK, sDBServer, sDBName, sDBOUser, sDBOPwd) Then Exit Function
    If Not bConnOK Then
      NotifyUser "Unable to connect to database '" & sDBName & "' as user '" & sDBOUser & "' using the password entered." & _
                 CHR(10) & CHR(10) & "Please verify the password and try again."
      SetProperty "MT_PARAMS_OK", "No"

    Else
      SetProperty "MT_PARAMS_OK", "Yes"
    End If

  Elseif nUserExists = kDBUser_OtherDB Then
    NotifyUser "User '" & sDBOUser & "' exists but is associated with another database." & CHR(10) & CHR(10) & _
               "Please verify database parameters and try again."
    SetProperty "MT_PARAMS_OK", "No"

  Else
    SetProperty "MT_PARAMS_OK", "Yes"
  End if

  ExitAction "ValidateDBOUser"

  ValidateDBOUser = kRetVal_SUCCESS  
End Function
'*******************************************************************************


'******************************************************************************************
'*** Get database parameters from servers.xml file
'******************************************************************************************
'Test
'GetDBParamsFromConfigFile
'******************************************************************************************
Function GetDBParamsFromConfigFile()
  Dim sServersPath
  Dim sNetMeterTag
  Dim sNetMeterStageTag
  Dim sDBTypeName
  Dim sDBType
  Dim sDBServer
  Dim sDBName
  Dim sStagingDBName
  Dim sDBUser
  Dim sDBPwd
  Dim oXMLDoc

  GetDBParamsFromConfigFile = False
  On Error Resume Next

  EnterFunction "GetDBParamsFromConfigFile"

  Dim sRMPDir
  sRMPDir = GetRMPDir()
  If Len(""&sRMPDir) = 0 Then
    sRMPDir = MakePath(GetProperty("INSTALLDIR"), "RMP")
  End If
  sServersPath = MakePath(sRMPDir, "config\ServerAccess\servers.xml")
  WriteLog "     Retrieving database parameters from: " & sServersPath

  If Not LoadXMLDoc(oXMLDoc,sServersPath) Then Exit Function

  sNetMeterTag = "/xmlconfig/server[servertype='NetMeter']"
  If Not GetXMLTag(oXMLDoc,sNetMeterTag & "/databasetype", sDBTypeName)   Then Exit Function

  sDBType = DBTypeCode(sDBTypeName)
  If Not DBTypeSupported(sDBType) Then
    WriteLog "<*** Error: Invalid DBMS type: " & sDBTypeName
    Exit Function
  End If

  If Not GetXMLTag(oXMLDoc,sNetMeterTag & "/servername",   sDBServer) Then Exit Function
  If Not GetXMLTag(oXMLDoc,sNetMeterTag & "/databasename", sDBName)   Then Exit Function
  If Not GetXMLTag(oXMLDoc,sNetMeterTag & "/username",     sDBUser)   Then Exit Function
  If Not GetXMLTag(oXMLDoc,sNetMeterTag & "/password",     sDBPwd)    Then Exit Function

  sNetMeterStageTag = "/xmlconfig/server[servertype='NetMeterStage']"
  If Not GetXMLTag(oXMLDoc,sNetMeterStageTag & "/databasename", sStagingDBName) Then Exit Function

  SetProperty "MT_DBMS_TYPE",             sDBType
  SetProperty "MT_INIT_CONFIG_USER_ID",   sDBUser
  SetProperty "MT_DATABASE_NAME",         sDBName
  SetProperty "MT_STAGING_DB_NAME",       sStagingDBName
  SetProperty "MT_DBMS_COMPUTERNAME",     sDBServer
  SetProperty "_MT_INIT_CONFIG_USER_PWD1", sDBPwd
  SetProperty "_MT_INIT_CONFIG_USER_PWD2", sDBPwd
  
  ExitFunction "GetDBParamsFromConfigFile"

  GetDBParamsFromConfigFile = True
End Function
'******************************************************************************************


'*******************************************************************************
'*** Validate MDAC version
'*******************************************************************************
Function ValidateMDACVersion()
  Dim sMDACVersion

  ValidateMDACVersion = kRetVal_ABORT
  On Error Resume Next

  EnterAction "ValidateMDACVersion"

  If Not GetMDACVersion(sMDACVersion) Then Exit Function
  Writelog "     MDAC Version: " & sMDACVersion
  'FIXME we are not checking anything here

  SetProperty "MT_PARAMS_OK", "Yes"

  ExitAction "ValidateMDACVersion"

  ValidateMDACVersion = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Validate version of DBMS (SQL Server or Oracle)
'*******************************************************************************
Function ValidateDBMSVersion(sVerStr)

  if isOracle then
    ValidateDBMSVersion = ValidateOracleVersion(sVerStr)
  else
    ValidateDBMSVersion = ValidateSqlServerVersion(sVerStr)
  end if

end function
'*******************************************************************************

'*******************************************************************************
'*** Validate version of DBMS (Oracle)
'Test
'ValidateOracleVersion "10.1.0.3.0"
'*******************************************************************************
Function ValidateOracleVersion(sVerStr)
  Dim aMinVer 
  Dim aVer
  Dim bValid
  Dim verNum, i, v
  Dim checkVer, minVer

  ValidateOracleVersion = False

  EnterFunction "ValidateOracleVersion"
  
  ' parse dotted version string into arrays
  aMinVer = split(VER_ORACLE_DBMS, ".")
  aVer = split(sVerStr,".")

  ' quit if nothing became of version string
  if ubound(aVer) < 0 then
    NotifyUser "Unable to determine the version of the specified Oracle DBMS.  " _
              & "Please consult your system administrator. " _
              & vbcrlf & "Version string is: (" & sVerStr & ")" 
    WriteLog "<*** Error parsing version string (nothing to parse)"
    WriteLog "<*** Version string is: (" & sVerStr & ")"
    Exit Function
  end if

  ' quit if version array has non numerics
  for each verNum in aVer
    If not isnumeric(vernum) Then
      NotifyUser "Unable to determine the version of the specified Oracle DBMS.  " _
               & "Please consult your system administrator. " _
               & vbcrlf & "Version string is: (" & sVerStr & ")" 
      WriteLog "<*** Error parsing version string (non numerics)"
      WriteLog "<*** Version string is: (" & sVerStr & ")"
      Exit Function
    End If
  next 

  ' normalize for string compare
  for each v in aMinVer
    minVer = minVer & space(5-len(v)) & v
  next

  ' normalize for string compare
  for each v in aVer
    checkVer = checkVer & space(5-len(v)) & v
  next
  
  if checkVer < minVer then
    NotifyUser "The version of of the specified Oracle DBMS (" & sVerStr & _
               ") does not meet the minimum requirement (" & VER_ORACLE_DBMS & ")."
    WriteLog "<*** Error: Oracle version (" & sVerStr & ") does not meet minimum requirement (" & VER_ORACLE_DBMS & ")"
    WriteLog "<*** " & sVerStr
    Exit Function
  End If

  WriteLog "     Oracle version (" & sVerStr & ") meets minimum requirement (" & VER_ORACLE_DBMS & ")"

  ExitFunction "ValidateOracleVersion"

  ValidateOracleVersion = True
  
end function
'*******************************************************************************

'*******************************************************************************
'*** Validate version of DBMS (SQL Server)
'Test
'ValidateSqlServerVersion "Microsoft SQL Server  2000 - 8.00.860 (Intel X86)   Dec 17 2002 14:22:05" & _
'"   Copyright (c) 1988-2003 Microsoft Corporation  Standard Edition on Windows NT 5.2 (Build 3790: ) "
'*******************************************************************************
Function ValidateSqlServerVersion(sVerStr)
  Dim asTokens
  Dim sToken
  Dim anVersion(3)
  Dim sVersion
  Dim sMinVersion
  Dim bVersionFound

  ValidateSqlServerVersion = False

  EnterFunction "ValidateSqlServerVersion"

  'We will try to be as loose as possible in parsing out the SQL Server version so as to hopefully avoid issues
  'with future service packs.  The first blank-delimited token in the string consisting only of digits and two or
  'more '.'s will be assumed to be the SQL Server version number. 

  sMinVersion = VER_SQL_MAJOR & "." & VER_SQL_MINOR & "." & VER_SQL_BUILD

  bVersionFound = False
  asTokens = Split(sVerStr," ")
  For Each sToken in asTokens
    If InStr(sToken,".") <> 0 Then
      Dim asVersion

      asVersion = Split(sToken,".")
      If UBound(asVersion) >= 2 Then
        Dim i

        bVersionFound = True
        sVersion = sToken
          
        For i = 0 to 2
          If IsNumeric(asVersion(i)) Then
            anVersion(i) = CLng(asVersion(i))
          Else
            bVersionFound = False
            Exit For
          End If
        Next

        If bVersionFound Then
          Exit For
        End If
      End If
    End If
  Next

  If Not bVersionFound Then
    NotifyUser "Unable to determine the version of the specified SQL Server DBMS.  Please consult your system administrator." 
    WriteLog "<*** Error parsing version string"
    WriteLog "<*** " & sVerStr
    Exit Function
  End If

  If anVersion(0) < VER_SQL_MAJOR Or _
    (anVersion(0) = VER_SQL_MAJOR And (anVersion(1) < VER_SQL_MINOR Or _
                                       anVersion(1) = VER_SQL_MINOR And anVersion(2) < VER_SQL_BUILD)) Then
    NotifyUser "The version of of the specified SQL Server DBMS (" & sVersion & _
               ") does not meet the minimum requirement (" & sMinVersion & ")."
    WriteLog "<*** Error: SQL Server version (" & sVersion & ") does not meet minimum requirement (" & sMinVersion & ")"
    WriteLog "<*** " & sVerStr
    Exit Function
  End If

  WriteLog "     SQL Server version (" & sVersion & ") meets minimum requirement (" & sMinVersion & ")"

  ExitFunction "ValidateSqlServerVersion"

  ValidateSqlServerVersion = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Validate DBMS (SQL Server & Oracle)
'Test
'ValidateDBMS "cobalt", "sa", "MetraTech1", True
'ValidateDBMS "sol", "system", "sys", True
'*******************************************************************************
Function ValidateDBMS(sDBServer, sAdminUid, sAdminPwd, bCheckVersion)
  Dim oRcdSet
  Dim sVerStr
  Dim sVersion
  Dim sVerQuery
  Dim sDBName

  ValidateDBMS = False
  On Error Resume Next

  ' debug code removethis
  bcheckversion = true

  EnterFunction "ValidateDBMS"

  if isOracle then
    sVerQuery = "select version from v$instance"
    sDBName = sAdminUid
  else
    sVerQuery = "select @@version version"
    sDBName = "master"
  end if
  
  If Not ExecuteQuery (oRcdSet, sVerQuery, sDBName, sDBServer, sAdminUid, sAdminPwd) Then
    NotifyUser "Unable to connect to database server '" & sDBServer & _
               "' using the given credentials.  Please verify server name, login, and password and try again." 
    WriteLog "<*** Error retrieving DBMS version from database"
    Exit Function
  End If

  If bCheckVersion Then
    If oRcdSet.EOF Then
      NotifyUser "Unable to determine version of database server '" & sDBServer & _
                 "' using the given credentials.  Please verify server name, login, and password and try again." 
      WriteLog "<*** Error retrieving DBMS version from database"
      Exit Function
    End If
 
    sVerStr = oRcdSet("version")

    If Not ValidateDBMSVersion(sVerStr) Then Exit Function

  End If

  ExitFunction "ValidateDBMS"

  ValidateDBMS = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Validate database state
'Test
'Dim sDBState
'Dim bSuccess
'sDBSTate = kDBState_DBMS_OK
'bSuccess = ValidateDatabase(sDBState, "NetMeter1", "localhost", "sa", "MetraTech1", True)
'If bSuccess Then
'  WriteLog "     Succeeded, Status = " & sDBState
'Else
'  WriteLog "     Failed"
'End If
'*******************************************************************************
Function ValidateDatabase(ByRef sDBState, sDBName, sDBServer, sAdminUid, sAdminPwd, bNotify)
  Dim bDBExists
  Dim oRcdSet

  ValidateDatabase = False

  EnterFunction "ValidateDatabase"

  If Not DatabaseExists(bDBExists, sDBName, sDBServer, sAdminUid, sAdminPwd) Then
    If bNotify Then
      NotifyUser "Unable to determine whether database '" & sDBName & "' exists on server '" & sDBServer & _
                 "'.  Please consult your system administrator." 
    End If
    WriteLog "<*** Error determining existence of database '" & sDBName & "'"
    Exit Function
  End If

  If bDBExists Then
    sDBState = kDBState_DB_EXISTS

    Dim sVersionQuery
    Dim sVersion

    if isOracle then
      sVersionQuery = "select target_db_version version from " & sDBName & ".t_sys_upgrade " _
                    & "where upgrade_id = (select max(upgrade_id) from " & sDBName & ".t_sys_upgrade)"
    else 
      sVersionQuery = "select top 1 target_db_version version from t_sys_upgrade " _
                    & "order by upgrade_id desc"
    end if

    If ExecuteQuery (oRcdSet, sVersionQuery, sDBName, sDBServer, sAdminUid, sAdminPwd) Then
      If Not oRcdSet.EOF Then
        sVersion = oRcdSet("version")
      End If
    End If

    Dim sDatabaseOnServer
    sDatabaseOnServer = "'" & sDBName & "' on server '" & sDBServer & "'"

    If IsEmpty(sVersion) Then
      If bNotify Then
        NotifyUser "Unable to determine schema version of database " & sDatabaseOnServer & _
                   ".  Please consult your system administrator." 
      End If
      WriteLog "<*** Error determining database schema version"
      Exit Function
    End If

    If sVersion = PRODUCT_VERSION Then
      WriteLog "     Found current database schema."
      sDBState = kDBState_DB_CURRENT

    Else
      If bNotify Then
        NotifyUser "Database " & sDatabaseOnServer & " exists but contains " & sVersion & _
                   " schema.  This installation package can only be installed in conjunction with an existing " & _
                   PRODUCT_VERSION & " database."
      End If
      WriteLog "<*** Error: schema version does not meet requirements"
      Exit Function
    End If
  End If

  ExitFunction "ValidateDatabase"

  ValidateDatabase = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Validate optional schema against feature request states
'Test
'ValidateOptionalSchema "NetMeter", "localhost", "sa", "MetraTech1"
'*******************************************************************************
Function ValidateOptionalSchema(sDBName, sDBServer, sAdminUid, sAdminPwd)
  Dim asFeature
  Dim asFeatureLong
  Dim asTable
  Dim bConflict
  Dim sErrMsg
  Dim i

  ValidateOptionalSchema = False

  EnterFunction "ValidateOptionalSchema"


  asFeature     = Array("PS","PSClient")
  asFeatureLong = Array(GetProperty("MT_PS_APP_NAME") & " Server", _
                        GetProperty("MT_PS_APP_NAME"))
  asTable       = Array("t_ps_payment_instrument", _
                        "t_ps_payment_instrument")

  WriteLog "     Checking for optional schema"
  sErrMsg = "The following conflicts have been detected:" & CHR(10) & CHR(10) 

  bConflict = False

  For i = 0 To UBound(asFeature)
    Dim bPresentInDB
    If Not TableExists(bPresentInDB, asTable(i), sDBName, sDBServer, sAdminUID, sAdminPwd) Then Exit Function

    Dim bInstalledOrRequested
    If GetFeatureRequestState(asFeature(i),3) = 3 Or GetFeatureCurrentState(asFeature(i),3) = 3 Then
      bInstalledOrRequested = True
    Else
      bInstalledOrRequested = False
    End If

    If bPresentInDB And Not bInstalledOrRequested Then
      sErrMsg = sErrMsg & "Feature '" & asFeatureLong(i) & _
                "' is present in the database but has not been selected for installation;" & CHR(10) 
      bConflict = True

    Elseif Not bPresentInDB And bInstalledOrRequested Then
      sErrMsg = sErrMsg & "Feature '" & asFeatureLong(i) & _
                "' has been selected for installation but is not present in the database;" & CHR(10) 
      bConflict = True
    End If
  Next 

  If bConflict Then
    sErrMsg = sErrMsg & CHR(10) & "Please review the features you have selected and try again."
    NotifyUser sErrMsg
    Exit Function
  End If

  ExitFunction "ValidateOptionalSchema"

  ValidateOptionalSchema = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get device path properties from the database and set IS properties
'Test
'SetDatabaseDevicePaths "NetMeter", "NetMeterStage", "localhost", "nmdbo", "nmdbo"
'*******************************************************************************
Function SetDatabaseDevicePaths(sDBName, sStgDBName, sDBServer, sAdminUid, sAdminPwd)
  Dim oRcdSet
  Dim sMasterDevPath
  Dim sMasterDevDir
  Dim sDBDataFile
  Dim sDBLogFile
  Dim sStgDBDataFile
  Dim sStgDBLogFile
  dim sQuery
  dim sPathSep

  SetDatabaseDevicePaths = False

  EnterFunction "SetDatabaseDevicePaths"
  
  if isOracle then 
    sPathSep = "/"
    sQuery = "select file_name from dba_data_files where tablespace_name = 'SYSTEM'"

    If ExecuteQuery (oRcdSet, sQuery, sDBName, sDBServer, sAdminUid, sAdminPwd) Then
      If Not oRcdSet.EOF Then
        sMasterDevPath = oRcdSet("file_name")
      End If
    End If

  else
    sPathSep = "\"

    If ExecuteSProc (oRcdSet, "sp_helpfile", "master", sDBServer, sAdminUid, sAdminPwd) Then
      Do Until oRcdSet.EOF
        If Trim(oRcdSet("name")) = "master" Then
          sMasterDevPath = Trim(oRcdSet("filename"))
        End If
        oRcdSet.MoveNext
      Loop
    End If
  
  End if

  If IsEmpty(sMasterDevPath) Then
    NotifyUser "Unable to determine master device path for database server '" & sDBServer & _
               "'.  Please consult your system administrator." 
    WriteLog "<*** Error determining master device path"
    Exit Function
  End If

  sMasterDevDir = goFso.GetParentFolderName(sMasterDevPath) 

  ' data files
  if not isOracle then
	sDBDataFile    = sMasterDevDir & sPathSep & sDBName    & "_Data.mdf" 
	sStgDBDataFile = sMasterDevDir & sPathSep & sStgDBName & "_Data.mdf"
  else
	' data files (set for oracle)
	sDBDataFile    = sMasterDevDir & sPathSep & sDBName    & "_Data.dbf" 
	sStgDBDataFile = sMasterDevDir & sPathSep & sStgDBName & "_Data.dbf"
  end if

  ' log files (not set for oracle)
  if not isOracle then
    sDBLogFile     = sMasterDevDir & sPathSep & sDBName    & "_Log.ldf" 
    sStgDBLogFile  = sMasterDevDir & sPathSep & sStgDBName & "_Log.ldf" 
  end if
 

  If IsSilentInstall() Then
    SetPropIfNotSet "MT_DATABASE_DATAFILE",     sDBDataFile
    SetPropIfNotSet "MT_DATABASE_LOGFILE",      sDBLogFile
    SetPropIfNotSet "MT_STAGING_DB_DATAFILE",   sStgDBDataFile
    SetPropIfNotSet "MT_STAGING_DB_LOGFILE",    sStgDBLogFile 
    SetPropIfNotSet "MT_DB_PARTITIONING_PATHS", sMasterDevDir
    SetPropIfNotSet "MT_RPT_DB_DATA_DIR",       sMasterDevDir
  Else
    SetProperty     "MT_DATABASE_DATAFILE",     sDBDataFile
    SetProperty     "MT_DATABASE_LOGFILE",      sDBLogFile
    SetProperty     "MT_STAGING_DB_DATAFILE",   sStgDBDataFile
    SetProperty     "MT_STAGING_DB_LOGFILE",    sStgDBLogFile 
    SetProperty     "MT_DB_PARTITIONING_PATHS", sMasterDevDir
    SetProperty     "MT_RPT_DB_DATA_DIR",       sMasterDevDir
  End If

  ExitFunction "SetDatabaseDevicePaths"

  SetDatabaseDevicePaths = True
End Function
'******************************************************************************************


'*******************************************************************************
'*** Get database owner
'Test
'Dim sDBOwner
'If GetDatabaseOwner (sDBOwner, "NetMeter", "localhost", "sa", "MetraTech1") Then
'  WriteLog "     Owner = " & sDBOwner
'End If
'*******************************************************************************
Function GetDatabaseOwner(sDBOwner, sDBName, sDBServer, sAdminUid, sAdminPwd)
  Dim oRcdSet
  Dim sQuery

  GetDatabaseOwner = False

  EnterFunction "GetDatabaseOwner"

  if isOracle then
    ' somehow it doesn't seem right
    sDBOwner = sDBName
  else

    sQuery = "select msl.name owner" & _
              " from sysusers su" & _
                  " inner join master..syslogins msl" & _
                    " on su.sid = msl.sid" & _
              " where su.name = 'dbo'"

    If ExecuteQuery (oRcdSet, sQuery, sDBName, sDBServer, sAdminUid, sAdminPwd) Then
      If Not oRcdSet.EOF Then
        sDBOwner = oRcdSet("owner")
      End If
    End If

    If IsEmpty(sDBOwner) Then
      NotifyUser "Unable to determine the owner of database '" & sDBName & "' on server '" & sDBServer & _
                "'." & CHR(10) & CHR(10) & "Please consult your system administrator." 
      WriteLog "<*** Error determining database owner"
      Exit Function
    End If

  end if ' isOracle

  ExitFunction "GetDatabaseOwner"

  GetDatabaseOwner = True
End Function
'******************************************************************************************


'*******************************************************************************
'*** Prepare to install core database
'*******************************************************************************
'Test
'SetProperty "MT_DBMS_TYPE",             "1"
'SetProperty "MT_DBMS_COMPUTERNAME",     "localhost"
'SetProperty "MT_DATABASE_NAME",         "NetMeter"
'SetProperty "MT_STAGING_DB_NAME",       "NetMeter_Stage"
'SetProperty "MT_ADMIN_LOGIN_ID",        "sa"
'SetProperty "_MT_ADMIN_LOGIN_PWD",       "MetraTech1"
'SetProperty "MT_INIT_CONFIG_USER_ID",   "nmdbo"
'SetProperty "_MT_INIT_CONFIG_USER_PWD1", "foo"
'PrepareToInstallDB
'
'Input properties:
'  MT_Ctrl_UI_Or_Silent
'  MT_DBMS_COMPUTERNAME
'  MT_DATABASE_NAME
'  MT_STAGING_DB_NAME
'  MT_ADMIN_LOGIN_ID
'  MT_ADMIN_LOGIN_PWD
'
'Input/Output properties:
'  MT_DATABASE_DATAFILE
'  MT_DATABASE_DATA_SIZE
'  MT_DATABASE_LOGFILE
'  MT_DATABASE_LOG_SIZE
'  (set to defaults in UI install, should already be defined in Silent install) 
'
'Output properties:
'  MT_DB_STATUS
'  MT_PARAMS_OK
' 
'*******************************************************************************
Function PrepareToInstallDB()
  Dim sDBState
  Dim sParamsOK
  Dim sDBServer
  Dim sDBName
  Dim sStgDBName
  Dim sAdminUid
  Dim sAdminPwd
  Dim sDBOUser
  Dim sDBOwner

  PrepareToInstallDB = kRetVal_ABORT

  EnterAction "PrepareToInstallDB"

  SetProperty "MT_PARAMS_OK", "No"

  '*** Get properties collected by MSI so far

  sDBServer  = GetProperty("MT_DBMS_COMPUTERNAME")
  sDBName    = GetProperty("MT_DATABASE_NAME")
  sStgDBName = GetProperty("MT_STAGING_DB_NAME")
  sAdminUid  = GetProperty("MT_ADMIN_LOGIN_ID")
  sAdminPwd  = GetProperty("_MT_ADMIN_LOGIN_PWD")
  sDBOUser   = GetProperty("MT_INIT_CONFIG_USER_ID")
    
  If sDBServer = "" or sDBName = "" or sStgDBName = "" or sAdminUid = "" Then
    WriteLog "<*** Error: one or more required properties are missing"
    NotifyUser "Error in install package;  please contact MetraTech Support."
    Exit Function
  End If

  sParamsOK = "No"
  
  sDBState = kDBState_DBMS_OK  'we wouldn't be here otherwise

  '*** Validate Database

  If ValidateDatabase(sDBState, sDBName, sDBServer, sAdminUid, sAdminPwd, True) Then

    '*** Get the default database device location if not already provided by the user
    If Not SetDatabaseDevicePaths(sDBName, sStgDBName, sDBServer, sAdminUid, sAdminPwd) Then Exit Function

    If sDBState = kDBState_DB_CURRENT Then
      Dim sQuestion
      If HostIsMe(sDBServer) Then
        sQuestion = "Database '" & sDBName & "' already exists on this server." & CHR(10) & CHR(10) & _
                    "WARNING: You probably don't want to use this database!!" & CHR(10) & CHR(10) & _
                    "Only click 'Yes' if you are really sure you want to use it. " & _
                    "Otherwise click 'No' and drop the database and user manually."
      Else
        sQuestion = "Database '" & sDBName & "' on server '" & sDBServer & _
                    "' exists and appears to be a valid " & PRODUCT_VERSION & " database." & CHR(10) & CHR(10) & _
                    "Would you like to install an additional " & PRODUCT_NAME & " server using this database?"
      End If
      If AskUser(sQuestion) Then
        '*** Make sure features being requested match database
        If Not ValidateOptionalSchema(sDBName, sDBServer, sAdminUid, sAdminPwd) Then
          sParamsOK = "No"

        '*** Get owner of existing database and set the MT_INIT_CONFIG_USER_ID property
        Elseif Not GetDatabaseOwner(sDBOwner, sDBName, sDBServer, sAdminUid, sAdminPwd) Then
          sParamsOK = "No"

        '*** Make sure user-entered database owner matches the actual owner
        Else
          If sDBOUser <> sDBOwner Then
            NotifyUser "The database owner entered (" & sDBOUSer & ") does not match the actual owner of the '" & sDBName & _
                       "' database (" & sDBOwner & ")." & CHR(10) & CHR(10) & "Please enter the correct database owner."
            sParamsOK = "No"

        Else
          sParamsOK = "Yes"
        End If
      End If

      Else
        sParamsOK = "No"
      End If

    Else 
      sParamsOK = "Yes"
    End If
  End If

  SetProperty "MT_DB_STATUS", sDBState
  SetProperty "MT_PARAMS_OK", sParamsOK

  ExitAction "PrepareToInstallDB"

  PrepareToInstallDB = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Prepare to uninstall core database
'*******************************************************************************
'Test
'SetProperty "INSTALLDIR",         "V:"
'SetProperty "MT_ADMIN_LOGIN_ID",  "sa"
'SetProperty "_MT_ADMIN_LOGIN_PWD", "MetraTech1"
'PrepareToUninstallDB
'
'Input properties:
'  MT_ADMIN_LOGIN_ID
'  MT_ADMIN_LOGIN_PWD
'
'Output properties:
'  MT_DBMS_TYPE
'  MT_DATABASE_NAME
'  MT_DBMS_COMPUTERNAME
'  MT_INIT_CONFIG_USER_ID
'  MT_INIT_CONFIG_USER_PWD1
'  MT_INIT_CONFIG_USER_PWD2
'  MT_DB_STATUS
'  MT_PARAMS_OK
' 
'*******************************************************************************
Function PrepareToUninstallDB()
  Dim sDBState
  Dim sParamsOK
  Dim sDBServer
  Dim sDBName
  Dim sAdminUid
  Dim sAdminPwd

  PrepareToUninstallDB = kRetVal_ABORT
  On Error Resume Next

  EnterAction "PrepareToUninstallDB"

  SetProperty "MT_PARAMS_OK", "No"

  '*** Get properties collected by MSI so far
  sAdminUid = GetProperty("MT_ADMIN_LOGIN_ID")
  sAdminPwd = GetProperty("_MT_ADMIN_LOGIN_PWD")
    
  If sAdminUid = "" Then ' password could legitimately be blank
    WriteLog "<*** Error: one or more required properties are missing"
    NotifyUser "Error in install package;  please contact MetraTech Support."
    Exit Function
  End If

  sDBState  = kDBState_NO_DBMS

  Dim sQuestion

  If GetDBParamsFromConfigFile() Then
    sDBServer = GetProperty ("MT_DBMS_COMPUTERNAME")
    sDBName   = GetProperty ("MT_DATABASE_NAME")

    If ValidateDBMS(sDBServer, sAdminUid, sAdminPwd, False) Then
      sDBState = kDBState_DBMS_OK

      ValidateDatabase sDBState, sDBName, sDBServer, sAdminUid, sAdminPwd, False

      Dim bProceed

      If sDBState = kDBState_DB_CURRENT Then
        bProceed = True

      Else
        sQuestion = "Database '" & sDBName & "' either does not exist or is not a valid " & PRODUCT_VERSION & " database." & _
                     CHR(10) & CHR(10) & "Proceed with uninstall anyway?"
        bProceed = AskUser(sQuestion)
      End If

      If bProceed Then
        Dim asDBs
        Dim sDBOUser
        Dim sStagingDB

        sDBOUser   = GetProperty("MT_INIT_CONFIG_USER_ID")
        sStagingDB = GetProperty("MT_STAGING_DB_NAME")
        If Not GetDBsOwnedBy(asDBs, sDBOUser, sStagingDB, sDBServer, sAdminUid, sAdminPwd) Then Exit Function

        If UBound(asDBs) >= 0 Then

          sQuestion = "The following databases on server '" & sDBServer & "' are related to this " & PRODUCT_NAME & " instance:" & CHR(10)

          Dim i
          Dim bStgDBFound
          
          bStgDBFound = False
          For i = 0 to UBound(asDBs)
            sQuestion = sQuestion & CHR(10) & "     " & asDBs(i)
            if LCase(asDBs(i)) = LCase(sStagingDB) Then bStgDBFound = True
          Next

          sQuestion = sQuestion & CHR(10) & CHR(10) & _
                      "Answer 'Yes' to drop all of these databases and their associated login(s)." & _
                      CHR(10) & CHR(10) & "Answer 'No' to "
          If bStgDBFound Then
            sQuestion = sQuestion & "drop only the staging database for this server (" & sStagingDB & ")."
          Else
            sQuestion = sQuestion & "continue uninstalling " & PRODUCT_NAME & " without dropping any databases."
          End If

          Dim sAnswer

          sAnswer = AskUser3(sQuestion)

          If sAnswer = "No" Then
            SetProperty "MT_DATABASE_NAME", ""
          End If

          If sAnswer = "Cancel" Then
            sParamsOK = "No"
          Else
            sParamsOK = "Yes"
          End If

        Else
          sQuestion = "Unable to locate any databases related to this " & PRODUCT_NAME & " instance." & CHR(10) & CHR(10) & _
                      "Proceed with uninstall anyway?"
          If AskUser(sQuestion) Then
      	    SetProperty "MT_DATABASE_NAME", ""
            SetProperty "MT_STAGING_DB_NAME", ""
            sParamsOK = "Yes"
          Else
            sParamsOK = "No"
          End If
        End If

      Else
        sParamsOK = "No"
      End If

    Else
      sParamsOK = "No"
    End If

  Else
    sQuestion = "Unable to retrieve database information from configuration file." & CHR(10) & CHR(10) & _
                "Proceed with uninstall without removing " & PRODUCT_NAME & " database?"

    If AskUser(sQuestion) Then
      SetProperty "MT_DATABASE_NAME", ""
      SetProperty "MT_STAGING_DB_NAME", ""
      sParamsOK = "Yes"
    Else
      sParamsOK = "No"
    End If
  End If

  SetProperty "MT_DB_STATUS", sDBState
  SetProperty "MT_PARAMS_OK", sParamsOK

  ExitAction "PrepareToUninstallDB"

  PrepareToUninstallDB = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Stop the pipeline service
'*******************************************************************************
Function StopPipeline()
  StopPipeline = kRetVal_ABORT  
  On Error Resume Next

  EnterAction "StopPipeline"
 
  If Not StopService ("pipeline", "") Then
    WriteLog "     Error stopping pipeline, continuing with uninstall anyway"
  End If

  ExitAction "StopPipeline"

  StopPipeline = kRetVal_SUCCESS  
End Function
'*******************************************************************************


'*******************************************************************************
'*** Write an entry into the log to mark the beginning of an install session.
'*** Also determine if the installation exposes a UI or runs silently.
'*******************************************************************************
Function InitialLogMsg()
  InitialLogMsg = kRetVal_ABORT 
  On Error Resume Next

  WriteLog ""
  WriteLog ""
  WriteLog "***********************************************************************************************************"
  WriteLog ">>>> Starting " & PRODUCT_NAME & " " & PRODUCT_VERSION & " Install"

  If (GetUILevel() = 1 Or GetUILevel() = 2) Then  '*** No UI
    SetProperty "MT_Ctrl_UI_Or_Silent", "Silent"
  End If

  WriteLog "     Installer.UILevel = " & GetUILevel()
  WriteLog "     MT_Ctrl_UI_Or_Silent = " & GetProperty("MT_Ctrl_UI_Or_Silent")

  '*** The processes launched by these buttons will bypass our collection of needed param.
  WriteLog "     Disabling the Remove and Repair buttons from the Control Panel Add/Remove Programs applet"
  SetProperty "ARPNOREMOVE", "1"
  SetProperty "ARPNOREPAIR", "1"

  InitialLogMsg = kRetVal_SUCCESS 
End Function
'*******************************************************************************


'*******************************************************************************
'*** Writes a final entry into the log
'*******************************************************************************
Function FinalLogMsg()
  FinalLogMsg = kRetVal_ABORT 
  On Error Resume Next

  WriteLog "<<<< " & PRODUCT_NAME & " " & PRODUCT_VERSION & " Install Complete"
  WriteLog "***********************************************************************************************************"

  FinalLogMsg = kRetVal_SUCCESS 
End Function
'*******************************************************************************


'*******************************************************************************
'*** G E N E R A L   S U P P O R T   F U N C T I O N S 
'*******************************************************************************


'*******************************************************************************
'*** Validate feature X is requested or installed if Y is requested
'*******************************************************************************
Function ValidatePrereq(sFeatX, sFeatY, sFeatureX, sFeatureY, ByRef sErrMsg, ByRef sResult)
  ValidatePrereq = False
  On Error Resume Next

  If IsFeatureRequested(sFeatY) and Not (IsFeatureRequested(sFeatX) or IsFeatureInstalled(sFeatX)) Then
    sErrMsg = sErrMsg & "     " & sFeatureY & " selected but " & sFeatureX & " not available;" & CHR(10)
    sResult = "No"
  End If
  If CheckErrors("validating feature states for " & sFeatX & " and " & sFeatY) Then Exit Function

  ValidatePrereq = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get Message Box title
'*******************************************************************************
Function GetMsgBoxTitle()
  GetMsgBoxTitle = PRODUCT_NAME & " " & PRODUCT_VERSION & " - InstallShield Wizard"
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get installation informational message
'*******************************************************************************
Function GetInstallInfoMsg()
  GetInstallInfoMsg = "Please refer to the " & PRODUCT_NAME & " " & PRODUCT_VERSION & _
                      " Installation Notes or Installation Guide for more details."
End Function
'*******************************************************************************


'*******************************************************************************
'*** Displays a message box if a UI is currently available.
'*******************************************************************************
Function NotifyUser(sMsg)

  If GetProperty("MT_Ctrl_UI_Or_Silent") = "UI" Then
    MsgBox sMsg, 0, GetMsgBoxTitle()
  End If
  WriteLog "     " & sMsg

End Function
'*******************************************************************************


'*******************************************************************************
'*** Ask user a Yes or No question if a UI is currently available.
'*** Assumes Yes if no UI available.
'*******************************************************************************
Function AskUser(sMsg)
  AskUser = True
  
  WriteLog "     " & sMsg
  If GetProperty("MT_Ctrl_Seq_UI_or_Exec") = "UI" Then

    If MsgBox(sMsg, 4, GetMsgBoxTitle()) <> 6 Then
      AskUser = False
    End If

  Else
    WriteLog "     No UI available, assuming Yes"
  End If

End Function
'*******************************************************************************


'*******************************************************************************
'*** Ask user an OK/Cancel question if a UI is currently available.
'*** Assumes Yes if no UI available.
'*******************************************************************************
Function AskUserOKCancel(sMsg)
  AskUserOKCancel = False
  
  WriteLog "     " & sMsg
  If GetProperty("MT_Ctrl_Seq_UI_or_Exec") = "UI" Then

    If MsgBox(sMsg, 1, GetMsgBoxTitle()) = 1 Then
      AskUserOKCancel = True
    End If

  Else
    WriteLog "    No UI available, assuming OK"
  End If

End Function
'*******************************************************************************


'*******************************************************************************
'*** Ask user a Yes/No/Cancel question if a UI is currently available.
'*** Assumes Yes if no UI available.
'*******************************************************************************
Function AskUser3(sMsg)
  AskUser3 = "Yes"
  
  WriteLog "     " & sMsg
  If GetProperty("MT_Ctrl_Seq_UI_or_Exec") = "UI" Then
    Dim nResponse

    nResponse = MsgBox(sMsg, 3, GetMsgBoxTitle())

    If nResponse = 7 Then
      AskUser3 = "No"

    Elseif nResponse <> 6 Then
      AskUser3 = "Cancel"
    End If

  Else
    WriteLog "    No UI available, assuming Yes"
  End If

End Function
'*******************************************************************************


'*******************************************************************************
'*** Test whether a directory is a .NET Framework directory
'*******************************************************************************
Function GetDotNetRoot(sDotNetRoot)
  GetDotNetRoot = False

  sDotNetRoot = goWsh.RegRead(REG_NET_FRAMEWORK)
  'Trim trailing \
  If Right(sDotNetRoot,1) = "\" Then sDotNetRoot = Left(sDotNetRoot,Len(sDotNetRoot)-1)

  If Not CheckErrors("") Then GetDotNetRoot = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Test whether a directory is a .NET Framework directory
'*******************************************************************************
Function IsADotNetPath(sFolderPath)
  Dim sDotNetRoot

  IsADotNetPath = False

  If GetDotNetRoot(sDotNetRoot) Then
    If DirName(sFolderPath) = sDotNetRoot And goFso.FolderExists(sFolderPath) Then
      IsADotNetPath = True
    End If
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** Test whether a folder is a valid .NET Framework directory
'*******************************************************************************
Function IsAValidDotNetPath(sFolderPath)
  IsAValidDotNetPath = False

  If IsADotNetPath(sFolderPath) Then
    If goFso.FileExists(sPath & "\regasm.exe") and _
       goFso.FileExists(sPath & "\installutil.exe") Then
      IsAValidDotNetPath = True
    End If
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** Find and validate .NET Framework path
'*******************************************************************************
Const REG_NET_FRAMEWORK = "HKLM\SOFTWARE\Microsoft\.NETFramework\InstallRoot"
Const VER_DOT_NET       = "v4.0.30319"

Function IsDotNetFrameworkInstalled(ByRef sDotNetPath, ByRef sMsg)
  Dim sDotNetRoot

  On Error Resume Next
  IsDotNetFrameworkInstalled = False

  If Not GetDotNetRoot(sDotNetRoot) Then
    sMsg = ".NET Framework was not found"
    Exit Function
  End If

  Dim sDotNetV20
  sDotNetV20 = MakePath(sDotNetRoot, VER_DOT_NET)

  sMsg = ".NET Framework v4.0 (" & sDotNetV20 & ") "

  If IsAValidDotNetPath(sDotNetV20) Then
    sMsg = sMsg & "was found"

  Else
    sMsg = sMsg & "was not found"
    Exit Function
  End IF
  
  sDotNetPath = sDotNetV20

  IsDotNetFrameworkInstalled = True
End Function
'*******************************************************************************


'*******************************************************************************
Function GetDotNetPath(ByRef sDotNetPath)
  Dim sErrMsg

  GetDotNetPath = False

  If IsEmpty(gsDotNetPath) Then
    If Not IsDotNetFrameworkInstalled(gsDotNetPath,sErrMsg) Then
      WriteLog "<*** Error: " & sErrMsg
      Exit Function
    End If
  End If

  sDotNetPath = gsDotNetPath

  GetDotNetPath = True
End Function
'*******************************************************************************

'*******************************************************************************
'*** Checks the outcome of each function and displays or logs any exceptions.
'*******************************************************************************
Function CheckPrereq(bPreReqOK, sMsg, ByRef sResult, ByRef sErrMsg, sNiceMsg)

  If bPreReqOK Then
    WriteLog " [X] " & sMsg
  Else
    WriteLog " [ ] " & sMsg
    If Len(sNiceMsg) > 0 Then sMsg = sNiceMsg
    sErrMsg = sErrMsg & sMsg & "." & CHR(10)    
    sResult ="No"
  End If

  CheckPrereq = bPreReqOK
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check sResult and notify the user 
'*******************************************************************************
Function CheckResults(sResult, sErrMsg)
  CheckResults = False
  If sResult = "No" Then
    NotifyUser(sErrMsg)
    If IsSilentInstall() Then
      SetProperty "MT_Ctrl_Abort_Or_Continue", "Abort"
    End If
  Else
    CheckResults = True
  End If
  SetProperty "MT_PARAMS_OK", sResult
End Function
'*******************************************************************************


'*******************************************************************************
'*** Return true if feature is to be installed based on feature request state
'*******************************************************************************
Function IsFeatureRequested(sFeature)
  If GetFeatureRequestState(sFeature,3) = 3 Then
    IsFeatureRequested = True
  Else
    IsFeatureRequested = False
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** Return true if feature is to be installed based on feature request state
'*******************************************************************************
Function IsAnyFeatureRequested(sFeatures)
  Dim asFeatures
  Dim sFeature

  asFeatures = Split(sFeatures,",")
  For Each sFeature in asFeatures
    If GetFeatureRequestState(sFeature,3) = 3 Then
      IsAnyFeatureRequested = True
      Exit Function
    End If
  Next

  IsAnyFeatureRequested = False
End Function
'*******************************************************************************


'*******************************************************************************
'*** Return true if feature is already installed based on feature current state
'*******************************************************************************
Function IsFeatureInstalled(sFeature)
  If GetFeatureCurrentState(sFeature,2) = 3 Then
    IsFeatureInstalled = True
  Else
    IsFeatureInstalled = False
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** If error occurred, logs message and returns TRUE, else returns FALSE
'*******************************************************************************
Function CheckErrors(sText)
  CheckErrors = False
  If Err.Number <> 0 Then
    If Len(sText) > 0 Then
      Dim sMsg
      sMsg = "<*** [" & Err.Source & "] (" & Err.Number & ") " & Err.Description
      WriteLog "<*** Error " & sText
      WriteLog sMsg
    End If
    Err.Clear
    CheckErrors = True
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** Write a message to the log file
'*******************************************************************************
Function WriteLog(sText)
  Dim oLogFile

  Set oLogFile = goFso.OpenTextFile(gsLogFile, kForAppending, True)

  If InStr(sText,CHR(10)) = 0 Then
    WriteLine oLogFile, sText

  Else
    Dim asLines
    Dim sLine
    asLines = Split(sText,CHR(10))
    For Each sLine in asLines
      WriteLine oLogFile, sLine
    Next
  End If

  oLogFile.Close()
  Set oLogFile = Nothing
End Function
'*******************************************************************************


'*******************************************************************************
'*** Write one line to a file, echoing to console if not in IS
'*******************************************************************************
Function WriteLine(oFile,sText)

  oFile.WriteLine FormatTimeStamp(Now) & " " & sText

  If not IsISActive() Then
    wscript.echo sText
  End If

End Function
'*******************************************************************************


'*******************************************************************************
'*** Format date/time string
'*******************************************************************************

'Cache the formatted timestamp and only regenerate when second changes
'(there is a bug if successive calls are an exact multiple of 24 hours apart)
Dim gnLastTime
Dim gsTimeStamp

Function FormatTimeStamp(dDateTime)
  Dim nThisTime

  nThisTime = CLng(Timer)
  If nThisTime <> gnLastTime Then
    gsTimeStamp = Right("0"&Month(dDateTime),2) & "/" & _
                  Right("0"&Day(dDateTime),2)   & "/" & _
                  Right(Year(dDateTime),2)      & " " & _
                  FormatDateTime(dDateTime,4)   & ":" & _
                  Right("0"&Second(dDateTime),2)
    gnLastTime = nThisTime
  End If

  FormatTimeStamp = gsTimeStamp
End Function
'*******************************************************************************


'*******************************************************************************
'*** Write a message to a file (limited to %SYSTEMDRIVE% for now)
'*******************************************************************************
Function WriteFile(sFilePath,sText)
  Dim oFile

  On Error Resume Next
  WriteFile = False

  Set oFile = goFso.OpenTextFile(sFilePath, kForAppending, True)
  If CheckErrors("opening " & sFilePath & " for append") Then Exit Function

  oFile.WriteLine sText
  If CheckErrors("appending to " & sFilePath) Then Exit Function

  oFile.Close()
  Set oFile = Nothing

  WriteFile = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Trace on entering a function
'*******************************************************************************
Function EnterFunction(sFunc)
  WriteLog "---> Entering " & sFunc & "()"
End Function
'*******************************************************************************


'*******************************************************************************
'*** Trace on exiting a function
'*******************************************************************************
Function ExitFunction(sFunc)
  WriteLog "<--- Exiting " & sFunc & "()"
End Function
'*******************************************************************************


'*******************************************************************************
'*** Trace on entering a custom action
'*******************************************************************************
Function EnterAction(sAction)
  WriteLog "===> Entering " & sAction
End Function
'*******************************************************************************


'*******************************************************************************
'*** Trace on exiting a custom action
'*******************************************************************************
Function ExitAction(sAction)
  WriteLog "<=== Exiting " & sAction
End Function
'*******************************************************************************


'*******************************************************************************
'*** Execute the specified command with log string specified separately
'*******************************************************************************
Function ExecuteCommandCommon(sRunCmd,sLogCmd)
  Dim nRetVal
  Dim sOutputFile

  On Error Resume Next
  ExecuteCommandCommon = False

  sOutputFile = goEnv("TEMP") & "\MTInstallOutput.txt"
  If goFso.FileExists(sOutputFile) Then
    goFso.DeleteFile sOutputFile, True
    if CheckErrors("deleting pre-existing output file") Then Exit Function
  End If

  WriteLog "     > " & sLogCmd
  nRetVal = goWsh.Run("cmd.exe /c " & sRunCmd & " > """ & sOutputFile & """",0,True)
  If CheckErrors("executing command") Then Exit Function

  If nRetVal <> 0 Then
    If Not AppendFileToLog(sOutputFile) Then Exit Function
    WriteLog "<*** Error (" & nRetVal & ") executing command"
    Exit Function
  End If

  ExecuteCommandCommon = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Execute the specified command
'*******************************************************************************
Function ExecuteCommand(sCmd)
  ExecuteCommand = ExecuteCommandCommon(sCmd,sCmd)
End Function
'*******************************************************************************


'*******************************************************************************
'*** Substitute passwords {0}, (1}, etc, with values from an array
'*******************************************************************************
Function SubstitutePasswords(ByVal sString, ByVal asPasswords, sStringClear, sStringMasked)
  SubstitutePasswords = False

  If Not IsArray(asPasswords) Then
    WriteLog "<*** Error: SubstitutePasswords called with non-array argument!"
    Exit Function
  End If

  sStringClear  = sString
  sStringMasked = sString

  Dim i
  For i = 0 to UBound(asPasswords)
    Dim sParam
    sParam = "{" & i & "}"
    If InStr(sString,sParam) Then
      sStringClear  = Replace(sStringClear,sParam,asPasswords(i))
      sStringMasked = Replace(sStringMasked,sParam,SuppressPassword(asPasswords(i)))
    Else
      WriteLog "<*** Error: parameter " & sParam & " not found in string """ & sString & """"
      Exit Function
    End If
  Next

  SubstitutePasswords = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Execute the specified command with passwords masked
'*******************************************************************************
'Test
'ExecuteCommandWithPasswords "echo {0} {1}",array("foo","bar")
Function ExecuteCommandWithPasswords(sCmd,asPasswords)
  Dim sCmdClear
  Dim sCmdMasked

  On Error Resume Next
  ExecuteCommandWithPasswords = False

  If Not SubstitutePasswords (sCmd, asPasswords, sCmdClear, sCmdMasked) Then Exit Function

  ExecuteCommandWithPasswords = ExecuteCommandCommon(sCmdClear,sCmdMasked)
End Function
'*******************************************************************************


'*******************************************************************************
Function AppendFileToLog(sFileName)
  Dim oFile
  Dim sText

  AppendFileToLog = False
  On Error Resume Next

  Set oFile = goFso.OpenTextFile(sFileName,kForReading)
  If CheckErrors("opening output file") Then Exit Function
  Do While oFile.AtEndOfStream <> True
    sText = oFile.ReadLine
    If CheckErrors("reading from output file") Then
      oFile.Close
      Set oFile = Nothing
      Exit Function
    End If
    WriteLog "     : " & sText
  Loop
  oFile.Close
  Set oFile = Nothing

  AppendFileToLog = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Start a service
'*******************************************************************************
Function StartService(sService)
  Dim nRetVal

  StartService = False
  On Error Resume Next

  nRetVal = goWsh.Run("net start " & sService,0, True)
  If CheckErrors("starting " & sService & " service") Then Exit Function

  If nRetVal = 0 Then
    WriteLog "     " & sService & " service has been started"

  Elseif nRetVal = 2 Then
    WriteLog "     " & sService & " service may already be running"

  Else
    WriteLog "<*** Error " & nRetVal & " starting " & sService & " service"
    Exit Function
  End If

  StartService = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Stop a service
'*******************************************************************************
Function StopService(sService,sArgs)
  Dim nRetVal
  Dim sCmd

  StopService = False
  On Error Resume Next

  sCmd = "net stop " & sService
  If sArgs <> "" Then
    sCmd = sCmd & " " & sArgs
  End If
  nRetVal = goWsh.Run(sCmd,0,True)
  If CheckErrors("stopping " & sService & " service") Then Exit Function

  If nRetVal = 0 Then
    WriteLog "     " & sService & " service has been stopped"

  Elseif nRetVal = 2 Then
    WriteLog "     " & sService & " service may already be stopped"

  Else
    WriteLog "<*** Error " & nRetVal & " stopping " & sService & " service"
    Exit Function
  End If

  StopService = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get Win32 Service object
'*******************************************************************************
Function GetServiceObject(oService, ByVal sServiceName)
  On Error Resume Next
  GetServiceObject = False

  Set oService = GetObject("winmgmts:Win32_Service.Name='" & sServiceName & "'")
  If CheckErrors("getting Win32 Service object for " & sServiceName) Then Exit Function

  GetServiceObject = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check if a service is already installed
'*******************************************************************************
'Test
'Dim bInstalled
'CheckServiceInstalled bInstalled, "billingserver"
'If bInstalled Then
'  WriteLog "Installed"
'End If
'*******************************************************************************
Function CheckServiceInstalled(bInstalled, ByVal sServiceName)
  Dim oService

  On Error Resume Next
  CheckServiceInstalled = False

  If GetServiceObject(oService,sServiceName) Then
    bInstalled = True
    Set oService = Nothing

  Else
  bInstalled = False
    End If

  CheckServiceInstalled = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check if a service is enabled
'*******************************************************************************
'Test
'Dim bEnabled
'CheckServiceEnabled bEnabled, "billingserver"
'If bEnabled Then
'  WriteLog "Enabled"
'End If
'*******************************************************************************
Function CheckServiceEnabled(bEnabled, ByVal sServiceName)
  Dim oService

  On Error Resume Next
  CheckServiceEnabled = False

  If GetServiceObject(oService,sServiceName) Then

    If oService.StartMode <> "Disabled" Then
      bEnabled = True

    Else
      bEnabled = False
    End If

  Else
    bEnabled = False
  End If

  CheckServiceEnabled = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get IIS Metabase object
'*******************************************************************************
Function GetIISObject(ByRef oValue, sPath)
  GetIISObject = False
  On Error Resume Next

  WriteLog "     Getting metabase object " & sPath
  Set oValue = GetObject("IIS://localhost/" & sPath)
  If CheckErrors("getting metabase object " & sPath) Then Exit Function

  GetIISObject = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** I N S T A L L S H I E L D   W R A P P E R   F U N C T I O N S
'*******************************************************************************


'*******************************************************************************
'*** Returns true if we are running in the InstallShield environment
'*******************************************************************************
Dim gbISActive

Function IsISActive()
  On Error Resume Next

  If IsEmpty(gbISActive) Then
    Dim oSession
    Set oSession = Session
    If err.number = 0 Then
      gbISActive = True
      oSession = Nothing
    Else
      gbISActive = False
      err.clear
    End If
  End If

  IsISActive = gbISActive
End Function
'*******************************************************************************


'*******************************************************************************
'*** Accessor functions for Session properties
'Test
'SetProperty "Foo", "Bar"
'WriteLog "     Foo is " & GetProperty("Foo")
'SetProperty "Foo", "Baz"
'WriteLog "     Foo is " & GetProperty("Foo")
'*******************************************************************************

'*******************************************************************************
'*** Get a property from the Session if we are running in the
'*** InstallShield environment or return the default otherwise
'*** No-logging version
'*******************************************************************************
Function GetPropertyNoLog(sName)
  Dim sValue
  If IsISActive() Then
    sValue = Session.Property(sName)
  Elseif goDict.Exists(sName) Then
    sValue = goDict(sName)
  Else
    sValue = ""
  End If
  GetPropertyNoLog = Trim(sValue)
End Function
'*******************************************************************************

'Test suppression of password properties
'SetProperty "MT_FOO","Bar"
'SetProperty "_MT_BAR", "Foo"
'GetProperty "_MT_FOO"
'GetProperty "MT_BAR"

'*******************************************************************************
'*** Suppress password
'*******************************************************************************
Function SuppressPassword(sPwd)
  SuppressPassword = Left("****************************************************************",Len(sPwd))
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check if property should be suppressed or not
'*******************************************************************************
Function CheckPassword(ByVal sName, sActualName, bIsPassword)
  If Left(sName,4) = "_MT_" Then
    sActualName = Mid(sName,2)
    bIsPassword = True
  Else
    SActualName = sName
    bIsPassword = False
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** Suppress property value if it is a password
'*******************************************************************************
Function SuppressIfPassword(ByVal sValue, ByVal bIsPassword)
  If bIsPassword Then
    SuppressIfPassword = SuppressPassword(sValue)
  Else
    SuppressIfPassword = sValue
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get a property from the Session if we are running in the
'*** InstallShield environment or return the default otherwise
'*******************************************************************************
Function GetProperty(sTempName)
  Dim sName
  Dim sValue
  Dim bIsPassword

  CheckPassword sTempName, sName, bIsPassword
  sValue = GetPropertyNoLog(sName)
  WriteLog "     Getting Property " & sName & ": " & SuppressIfPassword(sValue, bIsPassword)
  GetProperty = sValue
End Function
'*******************************************************************************

'*******************************************************************************
'*** Set a property in the Session if we are running in the
'*** InstallShield environment or just log the value otherwise
'*******************************************************************************
Function SetProperty(sTempName, value)
  Dim sName
  Dim bIsPassword

  CheckPassword sTempName, sName, bIsPassword

  If IsISActive() Then
    Session.Property(sName) = value
  Elseif goDict.Exists(sName) Then
    goDict(sName) = value
  Else
    goDict.Add sName, value
  End If
  WriteLog "     Setting Property " & sName & ": " & SuppressIfPassword(value, bIsPassword)
End Function
'*******************************************************************************


'*******************************************************************************
'*** Set a property if it is not already set
'*******************************************************************************
Function SetPropIfNotSet(sName, value)
  If GetProperty(sName) = "" Then
    SetProperty sName, value
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get a feature's request state from the Session if we are running in the
'*** InstallShield environment or return the default otherwise
'*******************************************************************************
Function GetFeatureRequestState(sName, nDefault)
  Dim nState
  If IsISActive() Then
    nState = Session.FeatureRequestState(sName)
  Else
    nState = nDefault
  End If
  WriteLog "     Getting Feature Request State " & sName & " : " & nState
  GetFeatureRequestState = nState
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get a feature's current state from the Session if we are running in the
'*** InstallShield environment or return the default otherwise
'*******************************************************************************
Function GetFeatureCurrentState(sName, nDefault)
  Dim nState
  If IsISActive() Then
    nState = Session.FeatureCurrentState(sName)
  Else
    nState = nDefault
  End If
  WriteLog "     Getting Feature Current State " & sName & " : " & nState
  GetFeatureCurrentState = nState
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get the installer UI level
'*******************************************************************************
Function GetUILevel()
  Dim nUILevel
  If IsISActive() Then
    nUILevel = Installer.UILevel
  Else
    nUILevel = 3
  End If
  GetUILevel = nUILevel
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check if install is silent
'*******************************************************************************
Function IsSilentInstall()
  If GetProperty("MT_Ctrl_UI_Or_Silent") = "Silent" Then
    IsSilentInstall = True
  Else
    IsSilentInstall = False
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** A R G U M E N T - H A N D L I N G   F U N C T I O N S
'*******************************************************************************

Dim gasArguments

'*******************************************************************************
'*** Find real path based on drive mapping, registry key, or environment variable
'*******************************************************************************
Function FindDir(ByRef sPath, sDrive, sRegKey, sEnvVar)
  FindDir = False
  On Error Resume Next

  Dim sTmpPath
  sTmpPath = ""

  If sDrive <> "" Then
    sTmpPath = UCase(sDrive) & ":\"

    If DirExists(sTmpPath) Then
      WriteLog "     " & sDrive & " drive found"

      If Not ReplaceSubstDrives(sTmpPath) Then
        WriteLog "<*** Error trying to determine drive mappings"
        Exit Function
      End If 

      If Len(sTmpPath) = 3 Then
        WriteLog "     No drive mapping found, assuming " & sDrive & " is a real drive"
      Else
        WriteLog "     " & sDrive & " drive seems to be mapped to " & sTmpPath
      End If

    Else
      WriteLog "     " & sDrive & " drive not found"
      sTmpPath = ""
    End If
  End If

  If sTmpPath = "" And sRegKey <> "" Then
    WriteLog "     Checking registry key: " & sRegKey
    sTmpPath = goWsh.RegRead(sRegKey)
    If Not CheckErrors("reading registry key """ & sRegKey & """") Then 
      WriteLog "     Path """ & sTmpPath & """ retrieved from registry"
    End If
  End If

  If sTmpPath = "" And sEnvVar <> "" Then
    WriteLog "     Checking environment variable: " & sEnvVar
    sTmpPath = goEnv(sEnvVar)
    If CheckErrors("reading environment variable """ & sEnvVar & """") Then Exit Function
    WriteLog "     Path """ & sTmpPath & """ retrieved from environment"
  End If

  If sTmpPath <> "" Then
    If Right(sTmpPath,1) <> "\" Then
      sTmpPath = sTmpPath & "\"
    End If

    If Not DirExists(sTmpPath) Then
      WriteLog "<*** Error: " & sTmpPath & " does not exist"
      Exit Function
    End If

  Else
    WriteLog "<*** Error: unable to determine path"
    Exit Function
  End If

  sPath = sTmpPath
  FindDir = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Load, parse, and validate custom action arguments
'*******************************************************************************
'Test
'SetProperty "CustomActionData","foo;+bar;baz"
'InitializeArguments
'Dim i
'For i = 0 To UBound(gasArguments)
'  WriteLog "       " & i & ": " & gasArguments(i)
'Next
'*******************************************************************************
Function InitializeArguments()
  Dim i

  InitializeArguments = False

  'get argument string from session, or use default if in test mode
  gasArguments = Split(GetPropertyNoLog("CustomActionData"),";")
  If UBound(gasArguments) < 1 Then
    WriteLog "<*** Error: Too few arguments; at least 2 required"
    Exit Function
  End If

  'log arguments (and trim extra blanks)
  WriteLog "     Arguments parsed from CustomActionData:"
  For i = 0 To UBound(gasArguments)
    gasArguments(i) = Trim(gasArguments(i))

    'remove trailing slashes from RMP and Bin dirs
    If i < 2 And Right(gasArguments(i),1) = "\" Then
      gasArguments(i) = Left(gasArguments(i),Len(gasArguments(i))-1)
    End If

    'suppress logging of arguments prefixed with a +
    Dim sLogValue

    If Left(gasArguments(i),1) = "+" Then
      gasArguments(i) = Mid(gasArguments(i),2)
      sLogValue = SuppressPassword(gasArguments(i))

    Else
      sLogValue = gasArguments(i)
    End If

    WriteLog "      " & Right(" "&i,2) & ": " & sLogValue
  Next

  'verify that first two arguments are RMP and Bin paths respectively
  If Not DirExists(MakeRMPPath("Config")) Then Exit Function
  If Not FileExists(MakeBinPath("pipeline.exe")) Then Exit Function

  InitializeArguments = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get argument by index
'*******************************************************************************
Function GetArgument(ByRef sValue, nIndex, bRequired)
  GetArgument = False

  If IsEmpty(gasArguments) Then
    WriteLog "<*** Error: InitializeArguments() has not been called"
    Exit Function
  End If

  If nIndex > Ubound(gasArguments) Then
    sValue = ""
  Else
    sValue = gasArguments(nIndex)
  End If

  If bRequired And Len(sValue) = 0 Then
    WriteLog "<*** Error: Argument " & nIndex & " is required"
    Exit Function
  End If

  GetArgument = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get RMP Directory Path
'*******************************************************************************
Function GetRMPDir()
  If IsEmpty(gasArguments) Then
    GetRMPDir = gsRMPDir
  Else
    GetRMPDir = gasArguments(0)
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get Bin Directory Path
'*******************************************************************************
Function GetBinDir()
  If IsEmpty(gasArguments) Then
    GetBinDir = gsBinDir
  Else
    GetBinDir = gasArguments(1)
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** Database Driver 
'*** Do not access gsDBDriver directly; always use SetDBDriver or GetDBDriver
'*******************************************************************************
Dim gsDBDriver

'*******************************************************************************
'*** Set Database Driver 
'*******************************************************************************
Function SetDBDriver(sDBDriver)
  gsDBDriver = sDBDriver
End Function

'*******************************************************************************
'*** Get Database Driver 
'*******************************************************************************
Function GetDBDriver()
  If IsOracle() Then
    If IsEmpty(gsDBDriver) Then
      GetDBDriver = GetProperty("MT_DB_DRIVER")
    Else
      GetDBDriver = gsDBDriver
    End If
  Else
    GetDBDriver = "{SQL Server}"
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** Set utility function flag
'*** This suppresses the warning when running on an already-installed system
'*******************************************************************************
Dim gbUtilityFunction
gbUtilityFunction = False

Function SetUtilityFunction(bValue)
  gbUtilityFunction = bValue
End Function
'*******************************************************************************


'*******************************************************************************
'*** Find out where we are
'*******************************************************************************
'Test
'WhereAmI
Dim gsRMPDir
Dim gsBinDir
Dim gbProductInstalled

Function WhereAmI()
  Dim sOutDir

  On Error Resume Next
  WhereAmI = False

  If IsEmpty(gsRMPDir) Then

    If Not FindDir (gsRMPDir, "R", REG_RMP_DIR, "RMPDIR") Then Exit Function
    WriteLog "     Using RMP Path: " & gsRMPDir

    If DirExists (MakePath(gsRMPDir, "Install\Scripts")) Then
      WriteLog "     " & PRODUCT_NAME & " appears to be installed"
    
      If Not gbUtilityFunction Then
        'warn the user about potential data loss
        Dim sMsg
        sMsg = PRODUCT_NAME & " appears to be installed on this machine.  Critical data could be lost." _
               & CHR(10) & CHR(10) & "Are you sure you want to proceed?"

        If MsgBox(sMsg, 4, "Warning") <> 6 Then Exit Function
      End If

      gsBinDir  = MakePath(gsRMPDir, "Bin\")
      gbProductInstalled = True

    Else
      WriteLog "     " & PRODUCT_NAME & " does not appear to be installed"

      If Not FindDir (sOutDir, "O", "", "MTOUTDIR") Then Exit Function

      ' g. cieplik CR 15542 2/15/08 the env DEBUG is 0 or 1
      If goEnv("DEBUG") = "1" Then
        gsBinDir = MakePath(sOutDir,"debug\bin\")
      Else
        gsBinDir = MakePath(sOutDir,"release\bin\")
      End If
      gbProductInstalled = False
    End If

    WriteLog "     Using Bin Path: " & gsBinDir

  End If

  WhereAmI = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check if product is installed
'*******************************************************************************

Function IsProductInstalled()
  If IsISActive() Then
    IsProductInstalled = IsFeatureInstalled("RMP")
  Else
    IsProductInstalled = gbProductInstalled
  End If
End Function
'*******************************************************************************


'*******************************************************************************
'*** Set CustomActionData property in non-InstallShield environment
'*******************************************************************************

Function SetCustomActionData(sProperties)
  Dim sCustActData

  On Error Resume Next
  SetCustomActionData = False

  If Not WhereAmI() Then Exit Function

  sCustActData = gsRMPDir & ";" & gsBinDir
  If sProperties <> "" Then
    sCustActData = sCustActData & ";" & sProperties
  End If

  SetProperty "CustomActionData", sCustActData

  SetCustomActionData = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** R E G U L A R   E X P R E S S I O N - R E L A T E D   F U N C T I O N S
'*******************************************************************************


'*******************************************************************************
'*** Create regular expression object
'*******************************************************************************
Function CreateRegExp(sPattern)
  Dim oRegExp

  Set oRegExp = CreateObject("VBScript.RegExp")
  oRegExp.Pattern    = sPattern
  oRegExp.IgnoreCase = True
  oRegExp.Global     = False

  Set CreateRegExp = oRegExp
End Function
'*******************************************************************************


'*******************************************************************************
'*** Test regular expression
'*******************************************************************************
Function TestRegExp(sString,sPattern)
  Dim oRegExp
  Dim bMatch

  Set oRegExp = CreateRegExp(sPattern)

  bMatch = oRegExp.Test(sString)

  Set oRegExp = Nothing

  TestRegExp = bMatch
End Function
'*******************************************************************************


'*******************************************************************************
'*** Execute regular expression DOESN'T WORK!!! leaving it for now
'*******************************************************************************
'Test
'Dim asMatches
'If ExecRegExp("foo:bar","(\s+)\:(\s+)",asMatches) = 2 Then
'  WriteLog "     0: " & asMatches(0)
'  WriteLog "     1: " & asMatches(1)
'End If
'*******************************************************************************
Function ExecRegExp(sString,sPattern,asMatches)
  Dim oRegExp
  Dim oMatches

  ExecRegExp = 0

  Set oRegExp = CreateRegExp(sPattern)

  Set oMatches = oRegExp.Execute(sString)

  If oMatches.Count > 0 Then
    Dim oMatch
    For Each oMatch In oMatches
      AddToArray asMatches, oMatch.Value
    Next 
    ExecRegExp = oMatches.Count
  End If

  Set oRegExp  = Nothing
  Set oMatches = Nothing
End Function
'*******************************************************************************


'*******************************************************************************
'*** Replace regular expression
'*******************************************************************************
Function ReplaceRegExp(sString,sPattern,sReplacement)
  Dim oRegExp
  Dim sResult

  Set oRegExp = CreateRegExp(sPattern)

  sResult = oRegExp.Replace(sString,sReplacement)

  Set oRegExp = Nothing

  ReplaceRegExp = sResult
End Function
'*******************************************************************************


'*******************************************************************************
'*** F I L E S Y S T E M - R E L A T E D   F U N C T I O N S
'*******************************************************************************


'*******************************************************************************
'*** Construct a path given a directory and a file name
'*******************************************************************************
Function MakePath(sDir,sFile)
  Dim sSep
  If Right(sDir,1) = "\" Then
    sSep = ""
  Else
    sSep = "\"
  End If
  MakePath = sDir & sSep & sFile
End Function
'*******************************************************************************


'*******************************************************************************
'*** Construct the path to a file relative to the Bin directory
'*******************************************************************************
Function MakeBinPath(sFile)
  MakeBinPath = MakePath(GetBinDir(), sFile)
End Function
'*******************************************************************************


'*******************************************************************************
'*** Construct the path to a file relative to the RMP directory
'*******************************************************************************
Function MakeRMPPath(sFile)
  MakeRMPPath = MakePath(GetRMPDir(), sFile)
End Function
'*******************************************************************************


'*******************************************************************************
'*** Remove Parent Path references (..)
'*******************************************************************************
Function RemoveParentPathRefs (sPath)
  Dim oRegExp
  Dim sNewPath
  Dim sPattern

  sNewPath = sPath
  sPattern = "\\\w+\\\.\.\\"

  Do While TestRegExp(sNewPath,sPattern)
    sNewPath = ReplaceRegExp(sNewPath,sPattern,"\")
  Loop

  RemoveParentPathRefs = sNewPath
End Function
'*******************************************************************************


'*******************************************************************************
'*** Test for existence of a file
'*******************************************************************************
Function FileExists(sFile)
  FileExists = False
  If Not goFso.FileExists(sFile) Then
    WriteLog "     File " & sFile & " not found"
    Exit Function
  End If
  FileExists = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Test for existence of a directory
'*******************************************************************************
Function DirExists(sDir)
  DirExists = False
  If Not goFso.FolderExists(sDir) Then
    WriteLog "     Directory " & sDir & " not found"
    Exit Function
  End If
  DirExists = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Test that directory is writable and append details to message
'*******************************************************************************
Function DirWritable(sDir,ByRef sMsg)
  Dim sFilePath
  Dim oFile

  DirWritable = False
  On Error Resume Next

  If Not goFso.FolderExists(sDir) Then
    sMsg = sMsg & "does not exist"
    Exit Function
  End If

  sFilePath = MakePath(sDir,"MTTest.txt")
  Set oFile = goFso.OpenTextFile(sFilePath, kForWriting, True)
  If CheckErrors("") Then
    sMsg = sMsg & "is not writable"
    Exit Function
  End If

  oFile.WriteLine "test"
  If CheckErrors("") Then
    sMsg = sMsg & "is not writable"
    Exit Function
  End If

  oFile.Close

  goFso.DeleteFile sFilePath, True
  If CheckErrors("") Then
    sMsg = sMsg & "is not writable"
    Exit Function
  End If

  sMsg = sMsg & "exists and is writable"

  DirWritable = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Delete file, if it exists
'*******************************************************************************
Function DeleteFile(sFile)
  DeleteFile = False
  On Error Resume Next
  If goFso.FileExists(sFile) Then
    goFso.DeleteFile sFile, True
    If CheckErrors("deleting file " & sFile) Then Exit Function
  End If
  DeleteFile = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get list of subfolders of a folder
'*******************************************************************************
Function GetSubFolders(ByRef aFolderNames, sFolder)
  Dim oFolder
  Dim oSubFolder
  GetSubFolders = False
  On Error Resume Next
  	
  Set oFolder = goFso.GetFolder(sFolder)
  If CheckErrors("getting folder " & sFolder) Then Exit Function
 
 ' CORE-3799: recursion fixed for targets with multiple subfolders	
  For Each oSubFolder in oFolder.SubFolders
	' point folder object at the current folder
	Set oFolder = goFso.GetFolder(oSubFolder.Path)
	
	ReDim Preserve aFolderNames(ubound(aFolderNames)+1)
	' return full path
	aFolderNames(ubound(aFolderNames)) = oFolder.Path & "\" 
	
	' recurse
	GetSubFolders aFolderNames, oFolder.Path
  Next
  
  GetSubFolders = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get base name of a file
'Test
'WriteLog BaseName("C:\temp\foo.txt")
'*******************************************************************************
Function BaseName(sFile)
  Dim sBaseName
  Dim nPos
  nPos = InStrRev(sFile,"\")
  If nPos <> 0 Then
    sBaseName = Right(sFile,Len(sFile)-nPos)
  Else
    sBaseName = sFile
  End If
  BaseName = sBaseName
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get directory name of a file
'Test
'WriteLog DirName("C:\temp\foo.txt")
'*******************************************************************************
Function DirName(sFile)
  Dim sDirName
  Dim nPos
  nPos = InStrRev(sFile,"\")
  If nPos <> 0 Then
    sDirName = Left(sFile,nPos-1)
  Else
    sDirName = ""
  End If
  DirName = sDirName
End Function
'*******************************************************************************


'*******************************************************************************
'*** Grep a file for a particular string
'*******************************************************************************
Function Grep(sFile,sText)
  Dim oFile
  Dim sLine

  Grep = False

  Set oFile = goFso.OpenTextFile(sFile,kForReading)
  If CheckErrors("opening file " & sFile) Then Exit Function
  Do While oFile.AtEndOfStream <> True
    sLine = oFile.ReadLine
    If InStr(LCase(sLine),LCase(sText)) > 0 Then
      oFile.Close
      Set oFile = Nothing
      Grep = True
      Exit Function
    End If
  Loop
  oFile.Close
  Set oFile = Nothing
End Function
'*******************************************************************************


'*******************************************************************************
'*** Add to an array
'*******************************************************************************
Function AddToArray(aArray, ByVal vItem)
  AddToArray = False

  If TypeName(aArray) <> "Variant()" Then
    WriteLog "<*** Error: variable is not an array"
    Exit Function
  End If

  Redim Preserve aArray(UBound(aArray)+1)
  aArray(UBound(aArray)) = vItem

  AddToArray = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Slurp a file into a string
'*******************************************************************************
Function SlurpFile(ByRef vLines,sFile)
  Dim oFile
  Dim sLine
  Dim bArray

  SlurpFile = False
  If TypeName(vLines) = "Variant()" Then
    bArray = True
  Else
    bArray = False
    vLines = ""
  End If

  Set oFile = goFso.OpenTextFile(sFile,kForReading)
  If CheckErrors("opening file " & sFile) Then Exit Function
  Do While Not oFile.AtEndOfStream
    sLine = oFile.ReadLine
    If bArray Then
      If Not AddToArray(vLines,sLine) Then
        oFile.Close
        Set oFile = Nothing
        Exit Function
      End If
    Else
      If vLines = "" Then
        vLines = sLine
      Else
        vLines = vLines & CHR(10) & sLine
      End If
  End If
  Loop
  oFile.Close
  Set oFile = Nothing

  SlurpFile = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Replace substed drives with the real thing
'*******************************************************************************
Function ReplaceSubstDrives(ByRef sText)
  Dim oTextStream
  Dim sFilePath
  Dim sSubstDrives
  Dim asSubstDrives

  ReplaceSubstDrives = False
  On Error Resume Next

  If Not IsISActive() Then
    sFilePath = goEnv("TEMP") & "\subst.txt"

    goWsh.Run "cmd.exe /c subst > " & sFilePath, 0, True
    If CheckErrors("running subst command") Then Exit Function

    Set oTextStream = goFso.OpenTextFile(sFilePath, kForReading)
    If CheckErrors("opening subst output file") Then Exit Function

    sSubstDrives = oTextStream.ReadAll
    If CheckErrors("reading subst output file") Then Exit Function

    oTextStream.Close 

    goFso.DeleteFile sFilePath, True
    If CheckErrors("deleting subst output file") Then Exit Function

    asSubstDrives = Split(sSubstDrives, vbCRLF)

    Dim i
    For i=0 to UBound(asSubstDrives)
      Dim sDrive
      Dim sPath
      sDrive = Left(asSubstDrives(i),2)
      If sDrive = "R:" or sDrive = "O:" or sDrive = "S:" Then
        sPath = Right(asSubstDrives(i),Len(asSubstDrives(i))-8)
        'WriteLog "     Replacing " & sDrive & " with " & sPath
        sText = Replace(sText,sDrive,sPath)
      End If
    Next

  End If

  ReplaceSubstDrives = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** X M L - R E L A T E D   F U N C T I O N S
'*******************************************************************************

Dim sLastFileLoaded

'*******************************************************************************
'*** Load an XML file into a DOM object
'*******************************************************************************
Function LoadXMLDoc (ByRef oXMLDoc, sFile)
  LoadXMLDoc = False
  On Error Resume Next

  If Not FileExists(sFile) Then Exit Function

  WriteLog "     Loading XML file " & sFile
  sLastFileLoaded = sFile

  Set oXMLDoc = CreateObject("MSXML2.DOMDocument.4.0")
  If CheckErrors("creating XML DOM object") Then Exit Function

  oXMLDoc.async              = False
  oXMLDoc.validateOnParse    = False
  oXMLDoc.preserveWhiteSpace = True
  oXMLDoc.resolveExternals   = False

  oXMLDoc.Load(sFile)
  If CheckErrors("loading XML file " & sFile) Then
    Set oXMLDoc = Nothing
    Exit Function
  End If

  If oXMLDoc.parseError.errorCode <> 0 Then
    WriteLog "<*** Error parsing file: " & oXMLDoc.parseError.reason & _
             "                         line " & oXMLDoc.parseError.line & ", column " & oXMLDoc.parseError.linepos
    Set oXMLDoc = Nothing
    Exit Function
  End If

  LoadXMLDoc = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Save a DOM object to an XML file
'*******************************************************************************
Function SaveXMLDoc (ByRef oXMLDoc, sFile)
  SaveXMLDoc = False
  On Error Resume Next

  oXMLDoc.Save(sFile)
  If CheckErrors("saving XML file " & sFile) Then
    Set oXMLDoc = Nothing
    Exit Function
  End If

  If sFile = sLastFileLoaded Then
    WriteLog "     Saved"
  Else
    WriteLog "     Saved XML file " & sFile
  End If

  Set oXMLDoc = Nothing
  SaveXMLDoc = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Modify a tag in an XML document
'*******************************************************************************
Function SetXMLTag (oXMLDoc, ByVal sTagName, ByVal sElementValue)
  SetXMLTag = SetXMLTagCommon (oXMLDoc, sTagName, sElementValue, False)
End Function
'*******************************************************************************


'*******************************************************************************
'*** Modify a tag in an XML document
'*******************************************************************************
Function SetXMLTagPassword (oXMLDoc, ByVal sTagName, ByVal sElementValue)
  SetXMLTagPassword = SetXMLTagCommon (oXMLDoc, sTagName, sElementValue, True)
End Function
'*******************************************************************************


'*******************************************************************************
'*** Modify a tag in an XML document without logging the value
'*******************************************************************************
Function SetXMLTagCommon (oXMLDoc, ByVal sTagName, ByVal sElementValue, ByVal bIsPassword)
  Dim oXMLNode
  Dim oXMLEncryptedAttr

  SetXMLTagCommon = False
  On Error Resume Next

  Set oXMLNode = oXMLDoc.SelectSingleNode(sTagName)
  If CheckErrors("getting tag " & sTagName) Then Exit Function
  If oXMLNode Is Nothing Then
    WriteLog "<*** Error: Tag " & sTagName & " not found"
    Exit Function
  End If

  'encrypt value if encrypted attribute is true
  If IsEncrypted(oXMLNode) Then
    If Not EncryptString(sElementValue, sElementValue) Then Exit Function
  End If

  oXMLNode.text = sElementValue
  If Not CheckErrors("setting tag " & sTagName & " to """ & SuppressIfPassword(sElementValue,bIsPassword) & """") Then
    WriteLog "     => Node " & sTagName & " set to """ & SuppressIfPassword(sElementValue,bIsPassword) & """"
    SetXMLTagCommon = True
  End If

  Set oXMLNode = Nothing
End Function
'*******************************************************************************


'*******************************************************************************
'*** Add a tag to an XML document
'*******************************************************************************
Function AddXMLTag (ByRef oXMLDoc, sParentTagName, sTagName, sElementValue)
  Dim oXMLNode
  Dim oNewNode

  AddXMLTag = False
  On Error Resume Next

  Set oXMLNode = oXMLDoc.SelectSingleNode(sParentTagName)
  If CheckErrors("getting tag " & sParentTagName) Then Exit Function
  If oXMLNode Is Nothing Then
    WriteLog "<*** Error: Tag " & sParentTagName & " not found"
    Exit Function
  End If

  Set oNewNode = oXMLDoc.createElement(sTagName)
  If CheckErrors("creating new element") Then Exit Function

  oNewNode.text = sElementValue

  oXMLNode.appendChild(oNewNode)
  If CheckErrors("appending child node") Then Exit Function

  WriteLog "     => Node " & sTagName & " set to """ & sElementValue & """ and added to node " & sParentTagName

  Set oXMLNode = Nothing
  Set oNewNode = Nothing

  AddXMLTag = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get the value of a tag from an XML document
'*******************************************************************************
Function GetXMLTag (oXMLDoc, sTagName, ByRef sElementValue)
  Dim oXMLNode

  GetXMLTag = False
  On Error Resume Next

  Set oXMLNode = oXMLDoc.SelectSingleNode(sTagName)
  If CheckErrors("getting tag " & sTagName) Then Exit Function
  If oXMLNode Is Nothing Then
    WriteLog "<*** Error: Node " & sTagName & " not found"
    Exit Function
  End If

  If IsEncrypted(oXMLNode) Then
    If Not DecryptString(sElementValue, oXMLNode.text) Then Exit Function
  Else
  sElementValue = oXMLNode.text
  End If

  GetXMLTag = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get the value of a tag from an XML file
'*******************************************************************************
Function GetXMLTagFromFile (sXMLFile, sTagName, ByRef sElementValue)
  Dim sXMLPath
  DIm oXMLDoc

  GetXMLTagFromFile = False

  sXMLPath = MakeRMPPath(sXMLFile)

  If Not FileExists(sXMLPath) Then Exit Function
  If Not LoadXMLDoc(oXMLDoc, sXMLPath) Then Exit Function
  If Not GetXMLTag(oXMLDoc, sTagName, sElementValue) Then Exit Function

  GetXMLTagFromFile = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Encrypt string using CryptoManager and DatabasePassword key class
'*******************************************************************************
Function EncryptString(ByRef sEncryptedString, sString)
  Dim oSecureStore

  EncryptString = False
  On Error Resume Next

  Dim cryptoManager
  Set cryptoManager = CreateObject("MetraTech.Security.Crypto.CryptoManager")
  If CheckErrors("creating MetraTech.Security.Crypto.CryptoManager object") Then Exit Function

  'WriteLog "     Encrypting string: " & sString
  ' 1 = CryptKeyClass.DatabasePassword
  sEncryptedString = cryptoManager.Encrypt(1, sString)
  If CheckErrors("encrypting string") Then Exit Function

  'WriteLog "     Encrypted result:  " & sEncryptedString

  Set cryptoManager = Nothing
  EncryptString = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Decrypt string using COMSecureStore object
'*******************************************************************************
Function DecryptString(ByRef sString, sEncryptedString)
  Dim oSecureStore

  DecryptString = False
  On Error Resume Next

  Set oSecureStore = CreateObject("COMSecureStore.GetProtectedProperty")
  If CheckErrors("creating COMSecureStore object") Then Exit Function

  'WriteLog "     Encrypting string: " & sString

  sString = oSecureStore.DecryptString(sEncryptedString)
  If CheckErrors("decrypting string") Then Exit Function

  'WriteLog "     Encrypted result:  " & sEncryptedString

  Set oSecureStore = Nothing
  DecryptString = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check whether given XML DOM node has an encrypted attribute set to true
'*******************************************************************************
Function IsEncrypted(oXMLNode)
  Dim oEncryptedAttr

  IsEncrypted = False

  Set oEncryptedAttr = oXMLNode.selectSingleNode("@encrypted")

  If oEncryptedAttr is Nothing then Exit Function

  If LCase(oEncryptedAttr.text) <> "true" then Exit Function

  IsEncrypted = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Set encrypted attribute to true on specified XML DOM node
'*******************************************************************************
Function EncryptNode(oXMLDOMFile,oXMLDOMNode)
  Dim oEncryptedAttr
  Dim sEncryptedString

  EncryptNode = False

  If Not EncryptString(sEncryptedString, oXMLDOMNode.text) Then Exit Function

  Set oEncryptedAttr = oXMLDOMNode.selectSingleNode("@encrypted")

  If oEncryptedAttr is Nothing then
    Set oEncryptedAttr = oXMLDOMFile.createAttribute("encrypted")
  Else
    Set oEncryptedAttr = oXMLDOMNode.attributes.removeNamedItem("encrypted")
  End if

  oEncryptedAttr.text = "true"
  oXMLDOMNode.attributes.setNamedItem(oEncryptedAttr)

  oXMLDOMNode.text = sEncryptedString

  EncryptNode = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** H O O K - R E L A T E D   F U N C T I O N S
'*******************************************************************************


'*******************************************************************************
Function RunAnyHook(sName,sProgID,bSecured)
  Dim oHookHandler
  Dim sSecured

  RunAnyHook = False
  On Error Resume Next

  Set oHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
  If CheckErrors("creating hook handler") Then
    Set oHookHandler = Nothing
    Exit Function
  End If
  sSecured = ""

  If bSecured Then
    Dim oLoginContext
    Dim oSessionContext

    Set oLoginContext = CreateObject("Metratech.MTLoginContext")
    If CheckErrors("creating login context") Then Exit Function

    ' login as the super user
    ' NOTE: it's assumed the su password hasn't changed yet
    Set oSessionContext = oLoginContext.Login("su", "system_user", "su123")
    If CheckErrors("logging in as SuperUser") Then
      oLoginContext = Nothing
      Exit Function
    End If

    oHookHandler.SessionContext = oSessionContext
    sSecured = ",**SECURE**"
  End If

  WriteLog "     Running " & sName & " Hook (" & sProgID & sSecured & ")"
  oHookHandler.RunHookWithProgid sProgID,""
  If CheckErrors("running hook") Then
    Set oHookHandler = Nothing
    Exit Function
  End If

  Set oHookHandler = Nothing
  RunAnyHook = True
End Function
'*******************************************************************************


'*******************************************************************************
Function RunHook(sName,sProgID)
  RunHook = RunAnyHook(sName,sProgID,False)
End Function
'*******************************************************************************


'*******************************************************************************
Function RunSecuredHook(sName,sProgID)
  RunSecuredHook = RunAnyHook(sName,sProgID,True)
End Function
'*******************************************************************************


'*******************************************************************************
'*** D A T A B A S E - R E L A T E D   F U N C T I O N S
'*******************************************************************************

Dim gsLastConnStr

'*******************************************************************************
'*** Create a connection string
'*******************************************************************************
Function GetConnStr (ByVal sDBName, ByVal sDBServer, ByVal sUid, ByVal sPwd, sConnStrMasked)
  Dim sConnStr
  Dim sConnStrClear

  If IsSqlServer Then
    sConnStr = "PROVIDER=MSDASQL" & _
               ";DRIVER="   & GetDBDriver & _
               ";SERVER="   & sDBServer & _
               ";UID="      & sUid & _
               ";PWD={0}"   & _
               ";DATABASE=" & sDBName
  Elseif IsOracle Then               
    sConnStr = "Provider=OraOLEDB.Oracle" & _
               ";Data Source=" & sDBServer & _
               ";User ID="     & sUid & _
               ";Password={0}"
  End If

  SubstitutePasswords sConnStr, array(sPwd), sConnStrClear, sConnStrMasked

  GetConnStr = sConnStrClear
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check if a database exists
'*******************************************************************************
Function DatabaseExists(ByRef bExists, sDBName, sDBServer, sAdminUid, sAdminPwd)
  Dim sQuery
  Dim oRcdSet

  DatabaseExists = False
  On Error Resume Next

  If isSQLServer Then
    sQuery = "select name from sysdatabases where name = '" & sDBName & "'"
  Elseif isOracle Then
    sQuery = "select username from all_users where username = upper('" & sDBName & "')"
  Else
    WriteLog "<*** Error: invalid database type"
    Exit Function
  End if

  If Not ExecuteQuery (oRcdSet, sQuery, "master", sDBServer, sAdminUid, sAdminPwd) Then Exit Function

  If oRcdSet.EOF Then
    WriteLog "     Specified database (" & sDBName & ") not found."
    bExists = False
  Else
    WriteLog "     Specified database (" & sDBName & ") found."
    bExists = True
  End If

  DatabaseExists = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check if a table exists
'*******************************************************************************
Function TableExists(ByRef bExists, sTableName, sDBName, sDBServer, sAdminUid, sAdminPwd)
  Dim sQuery
  Dim oRcdSet

  TableExists = False
  On Error Resume Next

  if isOracle then
    sQuery = "select object_name from all_objects " _
           & "where owner = upper('"& sDBName &"')" _
           & "  and object_name = upper('"& sTableName &"')" _
           & "  and object_type in ('TABLE', 'VIEW')"
  else
    sQuery = "select id from dbo.sysobjects where id = object_id(N'[" & sTableName & _
            "]') and (OBJECTPROPERTY(id, N'IsUserTable') = 1 or OBJECTPROPERTY(id, N'IsView') = 1)"
  end if
  
  If Not ExecuteQuery (oRcdSet, sQuery, sDBName, sDBServer, sAdminUid, sAdminPwd) Then Exit Function

  If oRcdSet.EOF Then
    WriteLog "     Specified table (" & sTableName & ") not found."
    bExists = False
  Else
    WriteLog "     Specified table (" & sTableName & ") found."
    bExists = True
  End If

  TableExists = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check if a product view exists
'*******************************************************************************
Function ProdViewExists(ByRef bExists, sPVName, sDBName, sDBServer, sAdminUid, sAdminPwd)
  Dim sQuery
  Dim oRcdSet

  ProdViewExists = False
  On Error Resume Next

  sQuery = "select id_prod_view from t_prod_view where nm_name='" & sPVName & "'"

  If Not ExecuteQuery (oRcdSet, sQuery, sDBName, sDBServer, sAdminUid, sAdminPwd) Then Exit Function

  If oRcdSet.EOF Then
    WriteLog "     Specified product view (" & sPVName & ") not found."
    bExists = False
  Else
    WriteLog "     Specified product view (" & sPVName & ") found."
    bExists = True
  End If

  ProdViewExists = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get list of databases owned by a user
'*******************************************************************************
'Test
'Dim aDBNames
'Dim sDBName
'SetProperty "MT_DBMS_TYPE", "2"
'GetDBsOwnedBy aDBNames, "MERCURY", "MERCURY_Stage", "sol", "system", "sys"
'For Each sDBName in aDBNames
'  WriteLog "     " & sDBName
'Next

Function GetDBsOwnedBy (aDBNames, ByVal sUid, ByVal sStgDBName, ByVal sDBServer, ByVal sAdminUid, ByVal sAdminPwd)
  Dim sQuery
  Dim oRcdSet

  GetDBsOwnedBy = False
  On Error Resume Next

  Redim aDBNames(-1)

  If isOracle Then
    'hack to make this behave the same as for SQL server

    'add main database and staging database to the list, if they exist
    Dim bDBExists
    Dim bTBLExists

    If Not DatabaseExists(bDBExists, sStgDBName, sDBServer, sAdminUid, sAdminPwd) Then Exit Function
    If bDBExists Then AddToArray aDBNames, sStgDBName

    If Not DatabaseExists(bDBExists, sUid, sDBServer, sAdminUid, sAdminPwd) Then Exit Function
    If bDBExists Then
      AddToArray aDBNames, sUid

      If Not TableExists(bTBLExists, "t_ReportingDBLog", sUid, sDBServer, sAdminUid, sAdminPwd) Then Exit Function

      'add all reporting DBs (only if core database exists, and t_ReportingDBLog was created)
      If bTBLExists Then
        sQuery = "select NameOfReportingDB name from " & sUid & ".t_ReportingDBLog"
        If Not ExecuteQuery (oRcdSet, sQuery, sUid, sDBServer, sAdminUid, sAdminPwd) Then Exit Function
      End If
    End If

  Else
    'return the actual databases owned by user sUid 
    sQuery = "select sdb.name name " & _
               "from sysdatabases sdb " & _
                    "inner join syslogins sl on sl.sid = sdb.sid " & _
               "where sl.name = '" & sUid & "'"
    If Not ExecuteQuery (oRcdSet, sQuery, "master", sDBServer, sAdminUid, sAdminPwd) Then Exit Function
  End If

  If Not IsEmpty(oRcdSet) Then
    Do until oRcdSet.EOF
      AddToArray aDBNames, oRcdSet("name")
      oRcdSet.MoveNext
    Loop

    Set oRcdSet = Nothing
  End If

  GetDBsOwnedBy = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Returns true is a user is connected to a database
'*** If sAdminUid = sUid then this will always return true.
'*******************************************************************************
Function IsDBUserConnected (sUid, sDBServer, sAdminUid, sAdminPwd)
  Dim sQuery
  Dim oRcdSet

  On Error Resume Next

  if isOracle then
    sQuery = "select sid, serial# from v$session " & _
             "where username like upper('" & sUid & "%')"
  else 
    sQuery = "/* need to define mssql query */"
  end if
  
  If Not ExecuteQuery (oRcdSet, sQuery, "master", sDBServer, sAdminUid, sAdminPwd) Then Exit Function

  Do until oRcdSet.EOF
    'print orcdset("sid") & ", " & orcdset("serial#")
    IsDBUserConnected = true
    exit function
  Loop

  IsDBUserConnected = false
End Function
'*******************************************************************************


'*******************************************************************************
'*** Kills all user sessions at the specified database
'*** It's unknown if sAdminUid = sUid = seppuku.
'*******************************************************************************
Function KillDBUserConnections (sUid, sDBServer, sAdminUid, sAdminPwd)
  Dim sQuery
  Dim oRcdSet
  Dim gotAll : gotAll = true

  On Error Resume Next

  if isOracle then 'alter system kill session  '983, 9103'
    sQuery = _
      "select 'alter system DISCONNECT session ''' || sid || ', ' || serial# ||''' IMMEDIATE' as cmd " & _
      "from v$session " & _
      "where username like upper('" & sUid & "%')"
  else 
    sQuery = "/* need to define mssql query */"
  end if
  
  If Not ExecuteQuery (oRcdSet, sQuery, "master", sDBServer, sAdminUid, sAdminPwd) Then Exit Function

  Do until oRcdSet.EOF
    sQuery = orcdset("cmd")
    'print sQuery
    
    dim rc
    If Not ExecuteQuery (rc, sQuery, "master", sDBServer, sAdminUid, sAdminPwd) Then 
      gotAll = false
    End If
    
    oRcdSet.MoveNext

  Loop

  KillDBUserConnections = gotAll
End Function
'*******************************************************************************


'*******************************************************************************
'*** Execute a query and return a recordset object
'*******************************************************************************
Function ExecuteQuery (ByRef oRcdSet, sSQLCommand, sDBName, sDBServer, sUid, sPwd)
  ExecuteQuery = ExecuteSQL (oRcdSet, sSQLCommand, 1, sDBName, sDBServer, sUid, sPwd)
End Function
'*******************************************************************************


'*******************************************************************************
'*** Execute a SProc and return a recordset object
'*******************************************************************************
Function ExecuteSProc (ByRef oRcdSet, sSQLCommand, sDBName, sDBServer, sUid, sPwd)
  ExecuteSProc = ExecuteSQL (oRcdSet, sSQLCommand, 4, sDBName, sDBServer, sUid, sPwd)
End Function
'*******************************************************************************


'*******************************************************************************
'*** Execute some SQL and return a recordset object
'*******************************************************************************
Function ExecuteSQL (ByRef oRcdSet, sSQLCommand, nCmdType, sDBName, sDBServer, sUid, sPwd)
  Dim sConnStr
  Dim sConnStrMasked
  Dim oConn
  Dim oCmd

  ExecuteSQL = False
  On Error Resume Next
  
  sConnStr =  GetConnStr (sDBName, sDBServer, sUid, sPwd, sConnStrMasked)

  If IsEmpty(gsLastConnStr) Or sConnStr <> gsLastConnStr Then
    WriteLog "     Connection String: " & sConnStrMasked
    gsLastConnStr = sConnStr
  End If

  Set oConn = CreateObject("ADODB.Connection")
  If CheckErrors("creating ADODB.Connection") Then Exit Function

  oConn.Open(sConnStr)
  If CheckErrors("opening ADODB.Connection") Then
    Set oConn = Nothing
    Exit Function
  End If

  Set oCmd = CreateObject("ADODB.Command")
  If CheckErrors("opening ADODB.Command") Then
    Set oConn = Nothing
    Exit Function
  End If

  Set oCmd.ActiveConnection = oConn
  If CheckErrors("setting Active Connection") Then
    Set oConn = Nothing
    Set oCmd  = Nothing
    Exit Function
  End If

  WriteLog "     Executing Command: " & sSQLCommand

  oCmd.CommandText = sSQLCommand
  oCmd.CommandType = nCmdType
  Set oRcdSet = oCmd.Execute
  If CheckErrors("executing SQL command") Then
    Set oConn = Nothing
    Set oCmd  = Nothing
    Exit Function
  End If

  If oRcdSet is Nothing Then
    WriteLog "<*** Error: Null recordset returned"
    Set oConn = Nothing
    Set oCmd  = Nothing
    Exit Function
  End If

  Set oConn = Nothing
  Set oCmd  = Nothing

  ExecuteSQL = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check connection to database using given parameters
'*******************************************************************************
'Test
'Dim bConnOK
'CheckDBConnection bConnOK, "localhost", "NetMeter", "nmdbo", "nmdbo1"
'If bConnOK Then WriteLog "     Connection OK!"
'*******************************************************************************
Function CheckDBConnection (ByRef bOK, sDBServer, sDBName, sDBUser, sDBPwd)
  Dim oRcdSet
  Dim sQuery

  CheckDBConnection = False

  if isOracle then
    sQuery = "select 1 from dual"
  else
    sQuery = "select 1"
  end if

  If ExecuteQuery (oRcdSet, sQuery, sDBName, sDBServer, sDBUser, sDBPwd) Then
    bOK = True
  Else
    bOK = False
    Set oRcdSet = Nothing
  End If

  CheckDBConnection = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check that DBO user exists and is associated with the right database
'*** Return values for nExists: 0 - does not exist
'***                            1 - exists and associated with this database
'***                            2 - exists but associated with another database
'*******************************************************************************
Function CheckDBUserExists (ByRef nExists, sDBServer, sDBName, sAdminUid, sAdminPwd, sUid)
  Dim sQuery
  Dim oRcdSet
  dim sDBName2

  CheckDBUserExists = False
  On Error Resume Next

  if isOracle then
    sQuery = "select username as dbname from all_users where username = '" _
           & ucase(sUid) & "'"
    sDBName2 = sUid
  else
    sQuery = "select dbname from syslogins where name='" & sUid & "'"
    sDBName2 = "master"
  end if
  
  If Not ExecuteQuery (oRcdSet, sQuery, sDBName2, sDBServer, sAdminUid, sAdminPwd) Then Exit Function

  nExists = kDBUser_NotExist
  If Not (oRcdSet.EOF AND oRcdSet.BOF) Then
    Do Until oRcdSet.EOF
      Dim sName
      sName = oRcdSet("dbname")
      If LCase(sName) = LCase(sDBName) Then
        nExists = kDBUser_Exist
        WriteLog "     User '" & sUid & "' exists and is associated with database '" & sDBName & "'"
      Else
        nExists = kDBUser_OtherDB
        WriteLog "     User '" & sUid & "' exists but is associated with database '" & sName & "'"
      End If
      oRcdSet.MoveNext
    Loop
  Else
    WriteLog "     User '" & sUid & "' was not found on database server '" & sDBServer & "'"
  End If

  oRcdSet.Close
  Set oRcdSet = Nothing

  CheckDBUserExists = True
End Function
'*****************************************************************************************

Const DRIVER_FILE_NAME = "SQLSRV32.dll"
Const SYSTEM_FOLDER    = 1

'*****************************************************************************************
'*** Get MDAC version
'*****************************************************************************************
Function GetMDACVersion(ByRef sMDACVersion)
  GetMDACVersion = False
  On Error Resume Next

  Dim sFolderName
  Dim sFileName

  sFolderName = goFso.GetSpecialFolder(SYSTEM_FOLDER)
  If CheckErrors("getting System folder") Then Exit Function

  sFileName   = sFolderName & "\" & DRIVER_FILE_NAME

  If GoFso.fileExists(sFileName) Then
    sMDACVersion = goFso.GetFileVersion(sFileName)

  Else
    WriteLog "<*** Error locating file: " & sFileName
    Exit Function
  End If

  GetMDACVersion = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Generate staging database name
'*******************************************************************************
Function GenStagingDBName (sDBName)
  Dim sComputerName
  Dim sStagingDBName

  sComputerName = GetHostName()

  'database names cannot contain "-"s
  if InStr(sComputerName, "-") > 0 Then
    'take out the the - from the name
    sComputerName = Replace(sComputerName, "-", "_")
  end if

  'Max length for a database name is 28 (http://eng/cr/?12425)
  sStagingDBName = Left(sDBName,27-Len(sComputerName)) & "_" & sComputerName

  GenStagingDBName = sStagingDBName
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get the name of this computer
'*******************************************************************************
Function GetHostName ()
  Dim oNetwork
  Dim sComputerName

  Set oNetwork = CreateObject("WScript.Network")
  sComputerName = oNetwork.ComputerName
  Set oNetwork = Nothing

  GetHostName = sComputerName
End Function
'*******************************************************************************


'*******************************************************************************
'*** Ping another computer on the network
'*******************************************************************************
Function PingHost (sHostName)
  PingHost = False
  If Not ExecuteCommand("ping -n 1 " & sHostName) Then Exit Function
  PingHost = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Check whether a given machine name is this machine
'*******************************************************************************
Function HostIsMe (sHostName)
  Dim sLCHostName

  sLCHostName = LCase(sHostName)
  If sLCHostName <> "localhost" And sLCHostName <> "127.0.0.1" And sLCHostName <> LCase(GetHostName()) Then
    HostIsMe = False
  Else
    HostIsMe = True
  End If
End Function
'*******************************************************************************


'*******************************************************************************
Function RemoveCOMPlusApp(ByVal sName) 'As Boolean
  Dim oCatalog ' As COMAdmin.COMAdminCatalog
  Dim oAppColl ' As COMAdmin.COMAdminCatalogCollection
  Dim oApp     ' As COMAdmin.COMAdminCatalogObject
  Dim i

  On Error Resume Next
  RemoveCOMPlusApp = False

  Set oCatalog = CreateObject("COMAdmin.COMAdminCatalog")
  If CheckErrors("creating object COMAdminCatalog") Then Exit Function

  Set oAppColl = oCatalog.GetCollection("Applications")
  oAppColl.Populate
  If CheckErrors("getting application collection") Then Exit Function

  i = oAppColl.Count - 1
  While i >= 0
    Set oApp = oAppColl.Item(i)
    If oApp.Name = sName Then
      WriteLog "     Removing Application: " & sName
      oAppColl.Item(i).Value("Deleteable") = true
    End If
    i = i - 1
  Wend
  oAppColl.SaveChanges
  If CheckErrors("saving application collection") Then Exit function

  i = oAppColl.Count - 1
  While i >= 0
    Set oApp = oAppColl.Item(i)
    If oApp.Name = sName Then
      WriteLog "     Removing Application: " & sName
      oAppColl.Item(i).Value("Deleteable") = true
      oAppColl.SaveChanges

      oAppColl.Remove i
      If CheckErrors("removing application") Then Exit function
    End If
    i = i - 1
  Wend

  oAppColl.SaveChanges
  If CheckErrors("saving application collection") Then Exit function

  Set oAppColl = Nothing
  Set oCatalog = Nothing

  RemoveCOMPlusApp = True
End Function
'*******************************************************************************

'*******************************************************************************
'*** Convert dbtype name string into dbtype codes
'*******************************************************************************
function DBTypeCode(dbtypename)
  ' convert dbtype string from command line 
  ' into internal dbtype code
  select case lcase(dbtypename)

    ' oracle type names
    case "oracle"       DBTypeCode = kDBType_Oracle
    case "{oracle}"     DBTypeCode = kDBType_Oracle

    ' sql server type names
    case "sqlserver"    DBTypeCode = kDBType_SQL
    case "mssql"        DBTypeCode = kDBType_SQL
    case "{sql server}" DBTypeCode = kDBType_SQL

    ' no database none
    case "none"         DBTypeCode = kDBType_None
    case "no"           DBTypeCode = kDBType_None
    case "nada"         DBTypeCode = kDBType_None
    case "nein"         DBTypeCode = kDBType_None
    case "nee"          DBTypeCode = kDBType_None

    ' it's nop otherwise
    case else           DBTypeCode = dbtypename

  end select

end function

'*******************************************************************************
'*** Check if current database type is supported
'*******************************************************************************
Function DBTypeSupport
  DBTypeSupport = (IsSqlServer or IsOracle)
End Function
'*******************************************************************************

'*******************************************************************************
'*** Check if database type passed as argument is supported
'*******************************************************************************
Function DBTypeSupported(sDBType)
  DBTypeSupported = (sDBType = kDBType_SQL) or (sDBType = kDBType_Oracle)
End Function
'*******************************************************************************

'*******************************************************************************
'*** True if the database type is oracle
'*******************************************************************************
Function IsOracle
  IsOracle = (GetDBType() = kDBType_Oracle)
End Function
'*******************************************************************************

'*******************************************************************************
'*** True if the database type is oracle
'*******************************************************************************
Function IsSqlServer
  IsSqlServer = (GetDBType() = kDBType_SQL)
End Function
'*******************************************************************************

'*******************************************************************************
'*** Database type
'*** Do not access gsDBType directly; always use SetDBType or GetDBType
'*******************************************************************************
Dim gsDBType

'*******************************************************************************
'*** Sets the database type and returns true if the type is supported
'*******************************************************************************
Function SetDBType(sDBType)
  gsDBType = sDBType
  SetDBType = DBTypeSupport
End Function
'*******************************************************************************

'*******************************************************************************
'*** Gets the database type
'*******************************************************************************
Function GetDBType()
  If IsEmpty(gsDBType) Then
    GetDBType = GetProperty("MT_DBMS_TYPE")
  Else
    GetDBType = gsDBType
  End If
End Function
'*******************************************************************************

'*******************************************************************************
'*** Returns datbase type name 
'*******************************************************************************
Function GetDBTypeName
  if IsSqlServer then
    GetDBTypeName = "{Sql Server}"
  elseif IsOracle then
    GetDBTypeName = "{Oracle}"
  end if
End Function
'*******************************************************************************

'******************************************************************************************
'*** Displays all elements of a array with index, one per line
'******************************************************************************************
function ShowArray(arr, info)
  dim nIndex
  
  WriteLog "     " & info & ":"
  For nIndex = 0 To UBound(arr)
    arr(nIndex) = Trim(arr(nIndex))
    WriteLog "      " & Right(" "&nIndex,2) & ": " & arr(nIndex)
  Next

end function
'******************************************************************************************

'******************************************************************************************
'*** Displays all elements of a hash, one per line
'******************************************************************************************
function ShowHash(h, info)
  dim k, v, fw
  dim secured
  
  secured = array("userpwd", "adminpwd")

  WriteLog "> " & info 
  if isempty(h) then exit function
  
  ' find size of largest key for formatting
  fw = 0
  for each k in h.keys
    if len(k) > fw then fw = len(k)
    'print v & " len is " & len(v) & " fw is " & fw
  next
  
  ' print each key-value pair
  for each k in h.keys
    if isempty(h(k)) then h(k) = ""
    v = h(k)
    if left(v,1) = "+" then v = SuppressPassword(Mid(v,2))
    if ubound(filter(secured, lcase(k))) = 0 then v = SuppressPassword(v)
    WriteLog "   " & k & space((fw)-len(k)) & ": " & v
  next

  wscript.echo

end function


'******************************************************************************************
'*** Puts wscript.arguments.named into a hash
'******************************************************************************************
'Test
'Dim oArgs
'Set oArgs = NamedArgsToHash()
Function NamedArgsToHash()
  Dim oHash, sName, aNamed

  Set oHash = CreateObject("scripting.dictionary")
  Set aNamed = wscript.arguments.named

  For Each sName In aNamed
    oHash.Add sName, aNamed(sName)
  Next

  Set NamedArgsToHash = oHash
End Function
'******************************************************************************************

'******************************************************************************************
'*** Helper funcs for lazy programmers when 7 extra keystrokes is just too much
'******************************************************************************************
function print(s)
  wscript.echo s
end function

function die(s)
  print s
  quit
end function

function quit
  wscript.quit
end function

'******************************************************************************************


'*******************************************************************************
'*** BILL SOFT - R E L A T E D   F U N C T I O N S
'*******************************************************************************


'*******************************************************************************

'*******************************************************************************
Function InstallBillSoft()
  
  Dim sCmd
  Dim sMsg
  Dim sUIorSilent
  Dim gbUIInstall
  
  InstallBillSoft = kRetVal_ABORT
  EnterAction "InstallBillSoft"
      
  If Not InitializeArguments() Then Exit Function
  WriteLog "<*** Passed Arguments BillSoft."
 
  If Not GetArgument (sUIorSilent,   2,  True)  Then Exit Function
  WriteLog "<*** Passed UI Cehck for BillSoft." 
  
  If LCase(sUIorSilent) = "ui" Then
    gbUIInstall = True
  Else
    gbUIInstall = False
  End If
    
  WriteLog "Running BillSoftInstallation Helper "
  sMsg =  "BillSoft installation could not be detected. Please install BillSoft EZTax and set the appropriate values in the BillSoft.xml configuration file." 
  sCmd = MakeBinPath("BillSoftInstallationHelper.exe /RMP=") & GetRMPDir()
  If Not ExecuteCommand (sCmd) Then 
	  If gbUIInstall Then ' only if installing using the UI
		MsgBox sMsg, 0, GetMsgBoxTitle()
	  End If

      WriteLog "<*** Warning Running BillSoft Helper."
  End If
   

  ExitAction "InstallBillSoft"
  InstallBillSoft = kRetVal_SUCCESS
End Function
'*******************************************************************************
