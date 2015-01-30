'*******************************************************************************
'*
'* Copyright 2000-2005 by MetraTech Corporation
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
'* Name:        Database.vbs
'* Created By:  Anagha Rangarajan, Simon Morton
'* Description: Installation and removal of core MetraNet database
'*
'*******************************************************************************

Option Explicit

'*******************************************************************************
'*** Include file processing (do not change)
'*******************************************************************************
Function Include(sFileName)
  Dim sCustActData
  Dim sIncludeDir
  Dim sIncludePath

  Include = False

  Dim oFso
  Set oFso  = CreateObject("Scripting.FileSystemObject")

  On Error Resume Next
  sCustActData = Session.Property("CustomActionData")
  If err.Number = 0 Then
    On Error Goto 0
    'we are being called from the installer; get install dir from CustomActionData and derive include dir
    Dim nEnd
    nEnd = InStr(sCustActData,";")
    If nEnd = 0 Then nEnd = Len(sCustActData)+1
    sIncludeDir = Left(sCustActData,nEnd-1) & "install\scripts"

  Else
    On Error Goto 0
      Dim oWsh, oEnv
      Set oWsh = CreateObject("Wscript.Shell")
      Set oEnv = oWsh.Environment("PROCESS")

    If oEnv("ROOTDIR") <> "" Then
      'ROOTDIR is defined, we are in development environment; derive include dir accordingly
      sIncludeDir = oEnv("ROOTDIR") & "\install\scripts"

    Else
      'Last chance: include file must be in my current directory
      sIncludeDir = "."
    End If

      Set oWsh = Nothing
      Set oEnv = Nothing
    End If

  sIncludePath = sIncludeDir & "\" & sFileName
  If Not oFso.FileExists(sIncludePath) Then
    wscript.echo "     Error: Include file " & sIncludePath & " does not exist"
    Set oFso = Nothing
    Exit Function
  End If

  Dim oFile
  Set oFile = oFso.OpenTextFile(sIncludePath)
  ExecuteGlobal oFile.ReadAll()
  oFile.Close
  Set oFso  = Nothing
  Set oFile = Nothing

  Include = True
End Function

If Include("Common.vbs") Then
  If Not IsISActive() Then
    'Command line invocation
    Main()
  End If
End If
'*******************************************************************************

'*** Constant Values
Const QUERY_PATH        = "Config\queries\dbinstall\"
Const SERVERACCESS_PATH = "Config\ServerAccess\"
Const METRA_AR_EXTENSION_PATH = "Extensions\AccountsReceivableClient\"
Const XMLFILE_SERVERS   = "servers.xml"

Const METRA_DEF_EXTENSION_PATH = "Extensions\DataExport\Config\UsageServer\"
Const XMLFILE_DEFRECURRINGEVENT   = "recurring_events.xml"

Const kDBTimeout        = 1000     'DB operations timeout in milliseconds

'*** Global Variables
Dim gsDBName
Dim gsDBServer
Dim gsDBType
Dim gsAdminID
Dim gsAdminPwd
Dim gsUserID
Dim gsUserPwd
Dim ghCmdLineArgs
Dim gobjConHold
Dim gsAccTmplType

'*** Main
Function Main()
  Dim defArgs

  SetProperty "MT_Ctrl_UI_Or_Silent",      "UI"
  SetProperty "MT_Ctrl_Seq_UI_or_Exec",    "UI"
  SetProperty "MT_Ctrl_Abort_Or_Continue", "Continue"

  '[mh] need to do the args before this and SetUtilityFunction
  ' [mh] these first 2 lines were moved here from 
  ' convenience collection for command line args
  stop
  set ghCmdLineArgs = NamedArgsToHash

  if ghCmdLineArgs.Exists("skipwarning") Then SetUtilityFunction true
  
  If Not WhereAmI() Then Exit Function
  
  defArgs = GetDefaultArgs()
  If Not SetCustomActionData(defArgs) Then Exit Function

  WriteLog ">>>> Uninstalling Database..."
  If UninstallDatabase() <> kRetVal_SUCCESS Then Exit Function

  'quit if just an uninstall
  if ghCmdLineArgs.Exists("uninstall") then wscript.quit
  
  WriteLog ">>>> Installing Database..."
  Set gobjConHold = Nothing
  If InstallDatabase() <> kRetVal_SUCCESS Then 
    If NOT (gobjConHold is Nothing) Then
      ' Close Held Open OLEDB Connection
      gobjConHold.Close
      Set gobjConHold = Nothing
	End If
    Exit Function
  End If

  WriteLog "<<<< Database Successfully Installed."
End Function


'*******************************************************************************
Function InstallDatabase()
  Dim sCmd
  Dim sDBStatus
  Dim sDBMSType
  Dim sDataFile
  Dim sLogFile
  Dim sDataSize
  Dim sLogSize
  Dim sStgDBName
  Dim sStgDataFile
  Dim sStgLogFile
  Dim sPartitionType
  Dim sPartitionPaths
  Dim sServerType
  Dim sSimTime
  Dim sDBDriver

  Dim bInstallCoreDB
  Dim bDBExists

  Dim oInstallConfig
  Dim oMetraTimeControl
  Dim oMetraTimeClient

  Dim strConHold, strConHoldMasked

  InstallDatabase = kRetVal_ABORT
  On Error Resume Next

  gsAccTmplType = ""
  
  EnterAction "InstallDatabase"

  '*** Retrieve and validate arguments

  If Not InitializeArguments() Then Exit Function

  If Not GetArgument (sDBStatus,   2,  True)  Then Exit Function
  If Not GetArgument (sDBMSType,   3,  True)  Then Exit Function

  If Not SetDBType(sDBMSType) then 
    WriteLog "<*** Error: Invalid DBMS type (" & sDBMSType & ").  Only SQL Server and Oracle are supported."
    Exit Function
  End If
  
  If sDBStatus = kDBState_NO_DBMS Then
    NotifyUser "No DBMS has been detected; unable to proceed with database installation."
    WriteLog "<*** Aborting installation"
    Exit Function

  Elseif sDBStatus = kDBState_DBMS_OK Then
    WriteLog "     DBMS has been detected and meets requirements; proceeding with installation."
    bInstallCoreDB = True

  ElseIf sDBStatus = kDBState_DB_EXISTS Then
    NotifyUser "Database exists but current schema not detected; unable to proceed with installation."
    WriteLog "<*** Aborting installation"
    Exit Function

  ElseIf sDBStatus = kDBState_DB_CURRENT Then
    WriteLog "     Current database schema detected; core database will not be installed."
    bInstallCoreDB = False

  Else
    WriteLog "<*** Error: Invalid database status (" & sDBStatus & ")."
    WriteLog "<*** Aborting installation"
    Exit Function
  End If

  If Not GetArgument (gsAdminID,       4,  True)  Then Exit Function
  If Not GetArgument (gsAdminPwd,      5,  False) Then Exit Function
  If Not GetArgument (gsDBName,        6,  True)  Then Exit Function
  If Not GetArgument (gsDBServer,      7,  True)  Then Exit Function
  If Not GetArgument (gsUserID,        8,  True)  Then Exit Function
  If Not GetArgument (gsUserPwd,       9,  True)  Then Exit Function
  If Not GetArgument (sStgDBName,      10, True)  Then Exit Function
  If Not GetArgument (sDataFile,       11, True)  Then Exit Function
  CheckPath (sDataFile)
  If Not GetArgument (sDataSize,       12, True)  Then Exit Function
  If Not GetArgument (sLogFile,        13, IsSqlServer)  Then Exit Function
  CheckPath (sLogFile)
  If Not GetArgument (sLogSize,        14, IsSqlServer)  Then Exit Function
  If Not GetArgument (sStgDataFile,    15, True)  Then Exit Function
  CheckPath (sStgDataFile)
  If Not GetArgument (sStgLogFile,     16, IsSqlServer)  Then Exit Function
  CheckPath (sStgLogFile)
  If Not GetArgument (sPartitionType,  17, True)  Then Exit Function
  If Not GetArgument (sPartitionPaths, 18, False) Then Exit Function
  If Not GetArgument (sServerType,     19, True)  Then Exit Function
  If Not GetArgument (sSimTime,        20, False) Then Exit Function
  If Not GetArgument (gsAccTmplType,   22, False) Then Exit Function
  If IsOracle() Then
    If Not GetArgument (sDBDriver,     21, True) Then Exit Function
    SetDBDriver(sDBDriver)
  End If

  Dim nPartitionType
  nPartitionType = CInt(sPartitionType)
  If nPartitionType < 0 Or nPartitionType > 4 Then
    WriteLog "<*** Error: invalid value for partitioning type: " & nPartitionType
    Exit Function
  End If

  '*** XML file configuration

  Dim oXmlDoc

  '*** Configure servers.xml  
  if not UpdateServersXml(gsDBServer, gsDBName, GetDBDriver, _
        GetDBTypeName, gsUserID, gsUserPwd, sStgDBName) then exit function

  '*** Install core database

  If bInstallCoreDB Then

    '*** Configure partitioning, if requested

    If nPartitionType <> 0 Then
      Dim sUsageServerXml
      Dim sPartitionTag
      Dim sPartitionEnable
      Dim asPartitionPaths
      DIm sPath
      
      sUsageServerXml = MakeRMPPath("config\UsageServer\usageserver.xml")
      sPartitionTag   = "/xmlconfig/Partitions"

      If Not LoadXMLDoc (oXMLDoc, sUsageServerXml) Then Exit Function

      If Not SetXMLTag (oXMLDoc, sPartitionTag & "/Enable", "True") Then Exit Function

      If nPartitionType = 1 Then
        sPartitionType   = "Quarterly"
      Elseif nPartitionType = 2 Then
        sPartitionType   = "Monthly"
      Elseif nPartitionType = 3 Then
        sPartitionType   = "Semi-Monthly"
      Elseif nPartitionType = 4 Then
        sPartitionType   = "Weekly"
      End If

      If Not SetXMLTag (oXMLDoc, sPartitionTag & "/Type",     sPartitionType) Then Exit Function
      If Not SetXMLTag (oXMLDoc, sPartitionTag & "/DataSize", sDataSize) Then Exit Function
      If Not SetXMLTag (oXMLDoc, sPartitionTag & "/LogSize",  sLogSize) Then Exit Function
	  If Not SetXMLTag (oXMLDoc, sPartitionTag & "/StoragePaths",  "") Then Exit Function

      asPartitionPaths = Split(sPartitionPaths,",")
      For Each sPath in asPartitionPaths
        If Not AddXMLTag (oXMLDoc, sPartitionTag & "/StoragePaths", "Path", sPath) Then Exit Function
      Next

      If Not SaveXMLDoc (oXMLDoc, sUsageServerXml) Then Exit Function
    End If

    '*** Set MetraTime, if requested

    If sServerType = "0" And sSimTime <> "" Then
      WriteLog "     Setting simulated time"

      set oMetraTimeControl = CreateObject("MetraTech.MetraTimeControl")
      If CheckErrors("creating MetraTimeControl object") Then Exit Function

      set oMetraTimeClient = CreateObject("MetraTech.MetraTimeClient")
      If CheckErrors("creating MetraTimeClient object") Then Exit Function

      oMetraTimeControl.SetSimulatedOLETime(CDate(sSimTime))
      If CheckErrors("setting MetraTime") Then Exit Function

      WriteLog "     Simulated Time has been set to " & oMetraTimeClient.GetMTOLETime()
    End If

    '*** Install core database

    If Not InstallDB (gsDBName, sDataFile, sDataSize, sLogFile, sLogSize, "0", "PreSync", "NONE", "Grants") Then Exit Function
    If Not UpgradeSchema(gsDBName, "NetMeter", "PreSync") Then Exit Function
	
	If Not InsertMeterPartitionInfo() Then Exit Function

  End If

  '*** Install staging database
  If Not DatabaseExists(bDBExists, sStgDBName, gsDBServer, gsAdminID, gsAdminPwd) Then Exit Function

  If Not bDBExists Then
    If Not InstallDB (sStgDBName, sStgDataFile, sDataSize, sStgLogFile, sLogSize, "1",  "PreSync", "NONE", "Grants") Then Exit Function
    If Not UpgradeSchema(sStgDBName, "NetMeterStage", "PreSync") Then Exit Function
  Else
    WriteLog "     Staging Database " & sStgDBName & " already exists, skipping"
  End If

  '*** Install schema into core database

 If bInstallCoreDB Then

   ' Hold open OLEDB connection to keep connection pool from going to 0 and destructing the pool
   Set gobjConHold = CreateObject("ADODB.Connection")
   strConHold =  GetConnStr (gsDBName, gsDBServer, gsUserID, gsUserPwd, strConHoldMasked)
   gobjConHold.Open strConHold

   WriteLog "     Creating Usage Cycles..."
   If Not ExecuteCommand (MakeBinPath("usm.exe -createcycles")) Then Exit Function
   If Not RunHook        ("Bitemporal Sprocs",   "MetraHook.MTBitemporalSprocsHook") Then Exit Function
   WriteLog "     Adding description table"
   'FIXME can't we just run the DeployLocale Hook here?
   If Not ExecuteCommand (MakeBinPath("descload.exe")) Then Exit Function
   If Not RunHook        ("Service Definition",      "MetraTech.Product.Hooks.ServiceDefHook")  Then Exit Function
   If Not RunHook        ("Account Types and Views", "MetraTech.Product.Hooks.AccountTypeHook") Then Exit Function
   If Not RunHook        ("Domain Model Account Types and Views", "MetraTech.DomainModel.Hooks.DomainModelHook") Then Exit Function
   WriteLog "     Creating Reference Intervals"
   If Not ExecuteCommand (MakeBinPath("usm.exe -createref")) Then Exit Function
   WriteLog "     Adding Product Views"
   If Not ExecuteCommand (MakeBinPath("AddProductView.exe -a create -l all")) Then Exit Function
   'If Not RunHook        ("Capability",          "MetraHook.MTCapabilityHook")                    Then Exit Function
   If Not RunHook        ("Capability",         "MetraTech.Security.Hooks.CapabilityHook")       Then Exit Function
  
   If Not UpgradeSchema(gsDBName, "NetMeter", "PostSync") Then Exit Function

   WriteLog "     Adding Sample Accounts"
   If Not AddAccount     (123, "demo",       "demo123",      "mt",          "US", "IndependentAccount", "31", "0", "MPS") Then Exit Function
   If Not AddAccount     (124, "hanzel",     "h",            "mt",          "DE", "IndependentAccount", "31", "0", "MPS") Then Exit Function
   If Not AddAccount     (125, "csr1",       "csr123",       "system_user", "US", "SYSTEMACCOUNT", "31", "1", "CSR") Then Exit Function
   If Not AddAccount     (126, "ops",        "ops123",       "system_user", "US", "SYSTEMACCOUNT", "31", "0", "MOM") Then Exit Function
   If Not AddAccount     (127, "mcm1",       "mcm123",       "system_user", "US", "SYSTEMACCOUNT", "31", "0", "MCM") Then Exit Function
   If Not AddAccount     (128, "rm",         "rm123",        "rate",        "US", "INDEPENDENTACCOUNT", "31", "0", "MPS") Then Exit Function
   If Not AddAccount     (129, "su",         "su123",        "system_user", "US", "SYSTEMACCOUNT", "31", "1", "CSR") Then Exit Function
   If Not AddAccount     (130, "jcsr",       "csr123",       "system_user", "US", "SYSTEMACCOUNT", "31", "1", "CSR") Then Exit Function
   If Not AddAccount     (131, "scsr",       "csr123",       "system_user", "US", "SYSTEMACCOUNT", "31", "1", "CSR") Then Exit Function
   If Not AddAccount     (132, "anonymous",  "anonymous123", "auth",        "US", "SYSTEMACCOUNT", "31", "1", "CSR") Then Exit Function
   If Not AddAccount     (133, "csr_folder", "csr123",       "auth",        "US", "SYSTEMACCOUNT", "31", "1", "CSR") Then Exit Function
   If Not AddAccount     (134, "mps_folder", "mps123",       "auth",        "US", "INDEPENDENTACCOUNT", "31", "1", "CSR") Then Exit Function
   If Not AddAccount     (135, "mcm_folder", "mcm123",       "auth",        "US", "SYSTEMACCOUNT", "31", "1", "CSR") Then Exit Function
   If Not AddAccount     (136, "mom_folder", "mom123",       "auth",        "US", "SYSTEMACCOUNT", "31", "1", "CSR") Then Exit Function
   If Not AddAccount     (137, "Admin",          "Admin123",     "system_user", "US", "SYSTEMACCOUNT", "31", "1", "CSR") Then Exit Function
   If Not AddAccount     (138, "MetraViewAdmin", "MetraViewAdmin123",     "mt", "US", "IndependentAccount", "31", "0", "MPS") Then Exit Function

   WriteLog "     Adding Account Mapping for demo account"
   If Not AddAccountMapping ("GL123", "metratech.com/external", 123) Then Exit Function

   If Not RunHook        ("Product View",        "MetraHook.DeployProductView.1")                 Then Exit Function
   If Not RunHook        ("Materialized View",   "MetraTech.Product.Hooks.MaterializedViewHook")  Then Exit Function
   If Not RunHook        ("Auditing",            "MetraHook.AuditHook")                           Then Exit Function

   If Not InstallDB (gsDBName, sDataFile, sDataSize, sLogFile, sLogSize, "0", "OnDemand", "__BOOTSTRAP_SU__", "") Then Exit Function

   If Not RunSecuredHook ("Security Policy",     "MetraHook.MTSecurityPolicyHook")                Then Exit Function
   If Not RunHook        ("Parameter Table",     "MetraHook.ParamTableHook")                      Then Exit Function
   If Not RunHook        ("Counter Type",        "MetraHook.MTCounterTypeHook")                   Then Exit Function
   If Not RunHook        ("Extended Property",   "MetraHook.ExTableHook")                         Then Exit Function
   If Not RunHook        ("Adjustments",         "MetraTech.Adjustments.Hooks.AdjustmentHook")    Then Exit Function
   If Not RunHook        ("PI Type",             "MetraTech.Product.Hooks.PriceableItemTypeHook") Then Exit Function
   If Not RunSecuredHook ("Usage Server",        "MetraTech.UsageServer.Hook")                    Then Exit Function
   If Not RunHook        ("Tax Framework",       "MetraTech.Tax.Framework.Hooks.VendorParamsHook") Then Exit Function
   If Not RunSecuredHook ("DB Properties",       "MetraTech.Product.Hooks.DatabaseProperties")    Then Exit Function
   If Not RunHook        ("BusinessEntity",      "MetraTech.BusinessEntity.Hook.BusinessEntityHook") Then Exit Function
   '## Commented out ExpressionEngine, due to it was excluded from the build
   'If Not RunHook        ("Expression Engine Metadata",      "MetraTech.ExpressionEngine.Metadata.Hook.MetadataHook")    Then Exit Function

   WriteLog "     Creating Usage Intervals and Partitions (if enabled)"
   If Not ExecuteCommand (MakeBinPath("usm.exe -create")) Then Exit Function
   
   ' Import MetraView Dashboard configuration
   If Not CreateMetraViewDashboard() Then Exit Function

   ' Import System User Reports Dashboard configuration
   If Not CreateSystemUserReportsDashboard() Then Exit Function


   ' Import Machine Roles configuration
   If Not CreateMachineRoles() Then Exit Function

   ' Close Held Open OLEDB Connection
   gobjConHold.Close
   Set gobjConHold = Nothing

 End If

 If Not SetAccountTemplateType(gsAccTmplType) Then Exit Function

  ExitAction "InstallDatabase"
  InstallDatabase = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Create a single database (core or staging)
'*******************************************************************************
Function InstallDB(sDBName, sDataFile, sDataSize, sLogFile, sLogSize, sStaging, sInstallTime, sQueryTag, sMaxInstallSet)
  Dim sCmd
  Dim sDataDevName
  Dim sLogDevName
  Dim sDataDir
  Dim sBackupDir
  Dim sDataBUFile
  Dim sLogBUFile
  
  InstallDB = False
  
  WriteLog "     Installing database: " & sDBName

  if IsSqlServer then
    sDataDevName = sDBName & "_Data"
    sLogDevName  = sDBName & "_Log"

    sDataDir = goFso.GetParentFolderName(sDataFile)
    If LCase(goFso.GetBaseName(sDataDir)) = "data" Then
      sBackupDir = Replace(sDataDir,"Data","BACKUP")
    Else
      sBackupDir = sDataDir
    End If

    sDataBUFile  = MakePath(sBackupDir, sDataDevName & ".backup")
    sLogBUFile   = MakePath(sBackupDir, sLogDevName  & ".backup")

    sCmd = MakeBinPath("databaseinstaller.exe -installwithoutdropdb -dbtype SQLServer") & _
          " -InstallTime "  & sInstallTime & " -IsStaging "    & sStaging     & _
          " -salogon "      & gsAdminID    & " -sapassword ""{0}""" & _
          " -dbname "       & sDBName      & " -servername "        & gsDBServer  & _
          " -dbologon "     & gsUserID     & " -dbopassword {1}" & _
          " -datadevname "  & sDataDevName & " -datadevloc """      & sDataFile   & """" & _
          " -datadevsize "  & sDataSize    & " -datadumpdevfile """ & sDataBUFile & """" & _
          " -logdevname "   & sLogDevName  & " -logdevloc """       & sLogFile    & """" & _
          " -logdevsize "   & sLogSize     & " -logdumpdevfile """  & sLogBUFile  & """" & _
          " -timeoutvalue " & kDBTimeout   & " -querytag " & sQueryTag

  elseif IsOracle then

    sCmd = MakeBinPath("databaseinstaller.exe -dbtype oracle") & _
          " -InstallTime "  & sInstallTime & _
          " -IsStaging "    & sStaging     & " -datasource "        & gsDBServer  & _
          " -salogon "      & gsAdminID    & " -sapassword ""{0}""" & _
          " -dbname "       & sDBName      & " -servername "        & "localhost"  & _
          " -dbologon "     & sDBName      & " -dbopassword {1}" & _
          " -datadevloc """ & sDataFile    & """" & _
          " -datadevsize "  & sDataSize    & _
          " -timeoutvalue " & kDBTimeout   & " -querytag " & sQueryTag

  end if

  If Len(sMaxInstallSet) > 0 Then
    sCmd = sCmd & " -maxinstallset " & sMaxInstallSet
  End If

  If Not ExecuteCommandWithPasswords(sCmd,array(gsAdminPwd,gsUserPwd)) Then Exit Function

  WriteLog "     Database successfully installed"

  InstallDB = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Run schema upgrade tool to populate empty database
'*******************************************************************************
Function UpgradeSchema(sDBName, sServerType, sInstallTime)
  Dim sCmd

  UpgradeSchema = False

  WriteLog "     Upgrading schema: " & sDBName

  sCmd = MakeBinPath("SchemaUpgrade.exe") & " -ServerType " & sServerType & " -CoreAccounts 0"

  If Len(sInstallTime) > 0 Then
    sCmd = sCmd & " -InstallTime " & sInstallTime
  End If

  If Not ExecuteCommand(sCmd) Then Exit Function

  WriteLog "     Schema successfully upgraded"

  UpgradeSchema = True
End Function
'*******************************************************************************


'*******************************************************************************
Function SynchronizeExtensions()
  SynchronizeExtensions = False
  WriteLog "     Synchronizing Extensions..."

  'FIXME should read this list from hooks.xml

  If Not RunHook        ("Localization",       "MetraHook.DeployLocale.1")                      Then Exit Function

  If Not RunHook        ("Product View",       "MetraHook.DeployProductView.1")                 Then Exit Function
  If Not RunHook        ("Service Definition", "MetraTech.Product.Hooks.ServiceDefHook")        Then Exit Function
  If Not RunHook        ("Auditing",           "MetraHook.AuditHook")                           Then Exit Function
  If Not RunHook        ("Materialized View",  "MetraTech.Product.Hooks.MaterializedViewHook")  Then Exit Function
                                                                                                 
  If Not RunHook        ("Extended Property",  "MetraHook.ExTableHook")                         Then Exit Function
  If Not RunHook        ("Parameter Table",    "MetraHook.ParamTableHook")                      Then Exit Function
  If Not RunHook        ("Counter Type",       "MetraHook.MTCounterTypeHook")                   Then Exit Function
  If Not RunHook        ("Adjustments",        "MetraTech.Adjustments.Hooks.AdjustmentHook")    Then Exit Function
  If Not RunHook        ("PI Type",            "MetraTech.Product.Hooks.PriceableItemTypeHook") Then Exit Function

  'If Not RunHook        ("Capability",         "MetraHook.MTCapabilityHook")                    Then Exit Function
  If Not RunHook        ("Capability",         "MetraTech.Security.Hooks.CapabilityHook")       Then Exit Function
  If Not RunSecuredHook ("Security Policy",    "MetraHook.MTSecurityPolicyHook")                Then Exit Function

  If Not RunSecuredHook ("Usage Server",       "MetraTech.UsageServer.Hook")                    Then Exit Function

  If Not RunHook        ("Tax Framework",      "MetraTech.Tax.Framework.Hooks.VendorParamsHook") Then Exit Function

  If Not RunSecuredHook ("DB Properties",      "MetraTech.Product.Hooks.DatabaseProperties")    Then Exit Function
  
  '## Commented out ExpressionEngine, due to it was excluded from the build
  'If Not RunHook ("Expression Engine Metadata",      "MetraTech.ExpressionEngine.Metadata.Hook.MetadataHook")    Then Exit Function

  SynchronizeExtensions = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
Function InstallOrDeleteProductViews()
  InstallOrDeleteProductViews = kRetVal_ABORT

  EnterAction "InstallOrDeleteProductViews()"

  If Not SynchronizeExtensions() Then Exit Function

  ExitAction "InstallOrDeleteProductViews()"

  InstallOrDeleteProductViews = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
Function UninstallDatabase()
  Dim sCmd
  Dim sDBStatus
  Dim sDBMSType
  Dim sStgDBName
  Dim bDBExists
  Dim aDBNames
  Dim sDBName

  On Error Resume Next
  UninstallDatabase = kRetVal_ABORT

  EnterAction "UninstallDatabase()"
                                              
  If Not InitializeArguments() Then Exit Function
  
  If Not GetArgument (sDBStatus,  2,  True)  Then Exit Function
  If Not GetArgument (sDBMSType,  3,  True)  Then Exit Function

  If Not SetDBType(sDBMSType) then 
    WriteLog "<*** Error: Invalid DBMS type (" & sDBMSType & ").  Only SQL Server and Oracle are supported."
    Exit Function
  End If

  If Not GetArgument (gsAdminID,  4,  True)  Then Exit Function
  If Not GetArgument (gsAdminPwd, 5,  False) Then Exit Function
  If Not GetArgument (gsDBName,   6,  False) Then Exit Function
  If Not GetArgument (gsDBServer, 7,  True)  Then Exit Function
  If Not GetArgument (gsUserID,   8,  True)  Then Exit Function
  If Not GetArgument (gsUserPwd,  9,  True)  Then Exit Function
  If Not GetArgument (sStgDBName,10,  False)  Then Exit Function

  '*** Remove staging database
  If Not DatabaseExists(bDBExists, sStgDBName, gsDBServer, gsAdminID, gsAdminPwd) Then Exit Function
  If bDBExists Then
    If Not DropDB (sStgDBName, 1) Then Exit Function

  Else
    WriteLog "     Staging database '" & sStgDBName & "' not found, proceeding with uninstall anyway."  
  End If 

  If gsDBName <> "" Then

    '*** Get a list of all remaining databases owned by the same user
    If Not GetDBsOwnedBy (aDBNames, gsUserID, sStgDBName, gsDBServer, gsAdminID, gsAdminPwd) Then Exit Function

    '*** Drop remaining non-core databases
    For Each sDBName in aDBNames
      If LCase(sDBName) <> LCase(gsDBName) Then
        If Not DropDB (sDBName, 0) Then Exit Function
      End If
    Next

    '*** g. cieplik CR 15542 2/14/08 Remove gsDBName database and gsUserID (if it exists)
    If Not DatabaseExists(bDBExists, gsDBName, gsDBServer, gsAdminID, gsAdminPwd) Then Exit Function
    If bDBExists Then
    '*** Drop the core database
    If Not DropDB (gsDBName, 0) Then Exit Function

    '*** Drop the database user
    If Not DropLogin (gsUserID) Then Exit Function
    else
        WriteLog "     The core database '" & gsDBName & "' not found, proceeding with uninstall anyway."  
    end if 

    WriteLog "     All databases removed successfully"
      
  End If ' gsDBName <> ""

  ExitAction "UninstallDatabase"

  UninstallDatabase = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
Function DropOracleDB(sDBName, sStaging)
  Dim sCmd

  Dim sDataFile
  Dim sDataSize
  Dim sLogFile
  Dim sLogSize
  Dim sInstallTime
  Dim sQueryTag

  sInstallTime = "PreSync"
  sDataFile = ""
  sDataSize = ""
  sLogFile = ""
  sLogSize = ""
  sQueryTag = "NONE"

  DropOracleDB = False

  'kill user connections first
  If Not KillDBUserConnections (sDBName, gsDBServer, gsAdminID, gsAdminPwd) Then
    WriteLog "     Couldn't clear hung connections to " & gsDBServer
    Exit Function
  End If 
    
  sCmd = MakeBinPath("databaseinstaller.exe -uninstallonly -dbtype oracle") & _
          " -InstallTime "  & sInstallTime & _
          " -IsStaging "    & sStaging     & " -datasource "        & gsDBServer  & _
          " -salogon "      & gsAdminID    & " -sapassword ""{0}""" & _
          " -dbname "       & sDBName      & " -servername "        & "localhost"  & _
          " -dbologon "     & sDBName      & " -dbopassword {1}" & _
          " -datadevloc """ & sDataFile    & """" & _
          " -datadevsize """  & sDataSize  & """" & _
          " -timeoutvalue " & kDBTimeout   & " -querytag " & sQueryTag

  If Not ExecuteCommandWithPasswords(sCmd,array(gsAdminPwd,gsUserPwd)) Then Exit Function

  DropOracleDB = True
End Function
'*******************************************************************************


'*******************************************************************************
Function DropSQLServerDB (sDBName)
  Dim oRcdSet

  DropSQLServerDB = False

  If Not ExecuteQuery(oRcdSet, "drop database " & sDBName, "master", gsDBServer, gsAdminID, gsAdminPWD) Then
    WriteLog "<*** Error deleting database '" & sDBName & "'"
    Exit Function
  End If

  DropSQLServerDB = True
End Function
'*******************************************************************************


'*******************************************************************************
'Test
'SetProperty "MT_DBMS_TYPE", "1"
'gsDBServer = "localhost"
'gsAdminID  = "sa"
'gsAdminPwd = "MetraTech1"
'DropSQLServerLogin "nmdbo"
Function DropSQLServerLogin (sUserID)
  Dim oRcdSet

  DropSQLServerLogin = False

  If Not ExecuteQuery(oRcdSet, "EXEC sp_droplogin '" & sUserID & "'", "master", gsDBServer, gsAdminID, gsAdminPwd) Then
    WriteLog "<*** Error dropping SQL Server login '" & sUserID & "'"
    Exit Function
  End If

  WriteLog "     Login '" & sUserID & "' successfully dropped"

  DropSQLServerLogin = True
End Function
'*******************************************************************************


'*******************************************************************************
'Drop a database
'*******************************************************************************
Function DropDB (ByVal sDBName, sStaging)
  DropDB = False

  If IsOracle() Then
    If Not DropOracleDB(sDBName, sStaging) Then Exit Function
  Else
    If Not DropSQLServerDB(sDBName) Then Exit Function
  End If

  WriteLog "     Database '" & sDBName & "' successfully dropped"

  DropDB = True
End Function
'*******************************************************************************


'*******************************************************************************
'Drop a database login
'*******************************************************************************
Function DropLogin (ByVal sUserID)
  If IsOracle() Then
    DropLogin = True
  Else
    DropLogin = DropSQLServerLogin(sUserID)
  End If
End Function
'*******************************************************************************

'*******************************************************************************
' Check to see if QueryManagement is enabled.
'*******************************************************************************
Function IsQMEnabled()

  Dim sRMPDir
  sRMPDir = GetRMPDir()

  WriteLog "     Checking to see if QueryManagement is enabled: "

  If Len(""&sRMPDir) = 0 Then
    sRMPDir = MakePath(GetProperty("INSTALLDIR"), "RMP")
  Else
    WriteLog "     Retrieving database parameters from: " & sServersPath
  End If

  sQMConfigFileWithPath = MakePath(sRMPDir, "config\QueryManagement\QueryManagement.xml")
  
  If Not LoadXMLDoc(sQMConfigFileWithPath, sServersPath) Then Exit Function

  sNetMeterTag = "/xmlconfig/server[servertype='NetMeter']"
  If Not GetXMLTag(oXMLDoc,sNetMeterTag & "/databasetype", sDBTypeName)   Then Exit Function

END Function
'*******************************************************************************

'*******************************************************************************
Function InstallSchema(sName, sQueryFolder)
  Dim sCmd
  Dim sMTDBobjects

  InstallSchema = False
  On Error Resume Next
  
  WriteLog "     Installing " & sName & " Schema"
  
  ' this should probably be determined by the contents 
  ' of the queryadapter.xml file
  sMTDBobjects = " MTDBobjects"
  if IsOracle then sMTDBobjects = sMTDBobjects & "_Oracle"
  sMTDBobjects = sMTDBobjects & ".xml"
  
  sCmd = MakeBinPath("installutiltest.exe -InstExtDbTables ") & _
         MakeRMPPath(QUERY_PATH & sQueryFolder & sMTDBobjects)

  'If Not ExecuteCommand(sCmd) Then Exit Function

  InstallSchema = True
End Function
'*******************************************************************************
 
 
'*******************************************************************************
Function CreateAccountExtensions()
  Dim oAcctAdapter

  CreateAccountExtensions = False
  On Error Resume Next

  WriteLog "     Creating Account Extensions"
  set oAcctAdapter = CreateObject("MTAccount.MTAccountServer.1")
  If CheckErrors("creating AccountServer object") Then Exit Function

  If Not CreateAccountExtension(oAcctAdapter, "Internal") Then 
    set oAcctAdapter = Nothing
    Exit Function
  End If

  If Not CreateAccountExtension(oAcctAdapter, "LDAP") Then 
    set oAcctAdapter = Nothing
    Exit Function
  End If

  set oAcctAdapter = Nothing

  CreateAccountExtensions = True
End Function
'*******************************************************************************
 

         
'*******************************************************************************
Function CreateMetraViewDashboard()
  Dim sCmd
  CreateMetraViewDashboard = False
  On Error Resume Next

  WriteLog "     Creating MetraView Dashboard..."
  WriteLog "     Running " & sCmd
  'sCmd = MakeRMPPath("extensions\MetraView\Sites\MetraView\Config\BusinessEntityExport\import.bat")
  sCmd = MakeBinPath("BMEImportExport.exe imp -E Core.UI.Site extensions\metraview\sites\metraview\config\businessentityexport")
         
  If Not ExecuteCommand(sCmd) Then Exit Function

  CreateMetraViewDashboard = True
End Function
'*******************************************************************************

 

         
'*******************************************************************************
Function CreateSystemUserReportsDashboard()
  Dim sCmd
  CreateSystemUserReportsDashboard = False
  On Error Resume Next

  WriteLog "     Creating System User Reports Dashboard..."
  WriteLog "     Running " & sCmd
  'sCmd = MakeRMPPath("Extensions\Reporting\BusinessEntity\BusinessEntityExport\import.bat")
  sCmd = MakeBinPath("BMEImportExport.exe imp -I -E MetraTech.SystemConfig.Reports.Report Extensions\SystemConfig\BusinessEntity\BusinessEntityExport")
         
  If Not ExecuteCommand(sCmd) Then Exit Function

  CreateSystemUserReportsDashboard = True
End Function
'*******************************************************************************

'*******************************************************************************
Function CreateMachineRoles()
  Dim sCmd
  CreateMachineRoles = False
  On Error Resume Next

  WriteLog "     Creating Machine Roles..."
  WriteLog "     Running " & sCmd
  sCmd = MakeBinPath("BMEImportExport.exe imp -E Core.MR.* config\ServerAccess\MachineRoles")
         
  If Not ExecuteCommand(sCmd) Then Exit Function

  CreateMachineRoles = True
End Function
'*******************************************************************************

 
'*******************************************************************************
Function CreateAccountExtension(oAcctAdapter, sName)

  CreateAccountExtension = False
  On Error Resume Next

  WriteLog "     Creating " & sName & " account extension"

  oAcctAdapter.initialize(sName)
  If CheckErrors("initializing " & sName & " adapter") Then Exit Function

  oAcctAdapter.install
  If CheckErrors("installing " & sName & " adapter") Then Exit Function

  CreateAccountExtension = True
End Function
'*******************************************************************************
 
 
'*******************************************************************************
Function AddAccount(nAcctID,sUserName,sPassword,sNamespace,sLanguage,sAcctType,sDayOfMonth,bIsFolder,sLoginApp)
  Dim sCmd
  Dim sLogCmd 'Prevent Password Logging

  On Error Resume Next
  AddAccount = False

  sCmd = MakeBinPath("AddDefaultAccounts.exe -u " & sUserName & " -p " & sPassword & " -n " & sNamespace & _
         " -l " & sLanguage & " -AccountType " & sAcctType & " -dom " & sDayOfMonth & " -LoginApp " & sLoginApp) 
  sLogCmd = MakeBinPath("AddDefaultAccounts.exe -u " & sUserName & " -p " & "sPassword" & " -n " & sNamespace & _
         " -l " & sLanguage & " -AccountType " & sAcctType & " -dom " & sDayOfMonth & " -LoginApp " & sLoginApp) 
  'Output should look like this:
  'Adding user with Login <demo> and password <demo123> and namespace <mt>
  'Account Creation successful, account ID is 123
  'SUCCESS: Adding of account succeeded
  'If Not ExecuteCommand(sCmd) Then Exit Function
  If Not ExecuteCommandCommon(sCmd,sLogCmd) Then Exit Function
  If Not LoadInternalAccountData (nAcctID, sAcctType, bIsFolder) Then Exit Function

  AddAccount = True
End Function
'*******************************************************************************
 
 
'*******************************************************************************
Function AddAccountMapping(sUserName,sNamespace,nAcctID)
  Dim sCmd

  On Error Resume Next
  AddAccountMapping = False

  WriteLog "     Adding Account Mapping for account " & nAcctID

  sCmd = MakeBinPath("AddAccountMappings.exe -u " & sUserName & " -n " & sNamespace & " -a " & nAcctID)
  If Not ExecuteCommand(sCmd) Then Exit Function
  
  AddAccountMapping = True
End Function
'*******************************************************************************
 
 
'*******************************************************************************
Function LoadInternalAccountData(nAcctID,sAcctType,bIsFolder)
  Dim oAcctAdapter
  Dim oAcctPropColl

  LoadInternalAccountData = False
  On Error Resume Next

  set oAcctAdapter = CreateObject("MTAccount.MTAccountServer.1")
  If CheckErrors("creating AccountServer object") Then
    oAcctAdapter = Nothing
    Exit Function      
  End If
  
  oAcctAdapter.initialize("Internal")
  If CheckErrors("initializing internal account adapter") Then
    oAcctAdapter = Nothing
    Exit Function
  End If
  
  set oAcctPropColl = CreateObject("MTAccount.MTAccountPropertyCollection.1")
  If CheckErrors("creating PropertyCollection object") Then
    oAcctAdapter = Nothing
    Exit Function      
  End If
      
  If Not SetInternalAccountProperties (oAcctPropColl, nAcctID, sAcctType, bIsFolder) Then
    oAcctAdapter = Nothing
    oAcctPropColl = Nothing
    Exit Function      
  End If

  oAcctAdapter.AddData "Internal", oAcctPropColl
  If CheckErrors("adding internal account information") Then
    oAcctAdapter = Nothing
    oAcctPropColl = Nothing
    Exit Function
  End If
  
  oAcctAdapter = Nothing
  oAcctPropColl = Nothing

  Writelog "     Added internal account information for id " & nAcctID
  LoadInternalAccountData = True
End Function
'*******************************************************************************
 
 
'*******************************************************************************
Function SetInternalAccountProperties (ByRef oAPC, nAcctID, sAcctType, bIsFolder)

  SetInternalAccountProperties = False
  On Error Resume Next
  
  oAPC.Add "id_acc",            CLng(nAcctID)  ' not sure why the CLng but will leave it for now
  oAPC.Add "taxexempt",         "1"
  oAPC.Add "SecurityAnswer",    "None"
  oAPC.Add "StatusReasonOther", "No other reason"
  oAPC.Add "TaxExemptID",       "1234567"
  oAPC.Add "currency",          "USD"
  oAPC.Add "folder",            CStr(bIsFolder)
  oAPC.Add "billable",          "1"

  If UCASE(sAcctType) <> "SYSTEMACCOUNT" Then
    If Not SetEnumProp(oAPC,"timezoneID","Global/TimezoneID/(GMT-05:00) Eastern Time (US & Canada)") Then Exit Function
  Else
    If Not SetEnumProp(oAPC,"timezoneID","Global/TimezoneID/(GMT) Monrovia, Casablanca") Then Exit Function
  End If

  If Not SetMTEnumProp(oAPC,"PaymentMethod",    "accountcreation/PaymentMethod/CashOrCheck")      Then Exit Function
  If Not SetMTEnumProp(oAPC,"AccountStatus",    "accountcreation/AccountStatus/Active")           Then Exit Function
  If Not SetMTEnumProp(oAPC,"SecurityQuestion", "accountcreation/SecurityQuestion/Pin")           Then Exit Function
  If Not SetMTEnumProp(oAPC,"InvoiceMethod",    "accountcreation/InvoiceMethod/None")             Then Exit Function
  If Not SetMTEnumProp(oAPC,"UsageCycleType",   "BillingCycle/UsageCycleType/Monthly")            Then Exit Function
  If Not SetMTEnumProp(oAPC,"StatusReason",     "accountcreation/StatusReason/AccountTerminated") Then Exit Function
  If Not SetEnumProp  (oAPC,"Language",         "Global/LanguageCode/US")                         Then Exit Function

  SetInternalAccountProperties = True
End Function
'*******************************************************************************


'*******************************************************************************
Function SetMTEnumProp (ByRef oAcctPropColl, sName, sEnum)
  SetMTEnumProp = SetEnumProp (oAcctPropColl, sName, "metratech.com/" & sEnum)
End Function
'*******************************************************************************


'*******************************************************************************
Function SetEnumProp (ByRef oAcctPropColl, sName, sEnum)
  Dim oNameID
  Dim sValue

  SetEnumProp = False
  On Error Resume Next

  set oNameID = CreateObject("MetraPipeline.MTNameID.1")
  If CheckErrors("creating NameID object") Then Exit Function

  sValue = oNameID.GetNameID(sEnum)
  If CheckErrors("looking up enum ID") Then
    oNameID = Nothing
    Exit Function
  End If

  oAcctPropColl.Add sName, CLng(sValue)
  If CheckErrors("adding enum property") Then
    oNameID = Nothing
    Exit Function
  End If
  
  SetEnumProp = True
End Function
'*******************************************************************************

'******************************************************************************************
'*** Updates config/serveraccess/servers.xml with database options
'******************************************************************************************
function UpdateServersXml(sDBServer, sDBName, sDBDriver, sDBTypeName, sUserID, sUserPwd, sStgDBName)
  Dim sServersXml
  Dim sNetMeterTag
  Dim sNetMeterStgTag
  Dim oXMLDoc
  Dim dbName
  
  UpdateServersXml = false

' First update the main Servers.xml file
  sServersXml = MakeRMPPath(SERVERACCESS_PATH & XMLFILE_SERVERS)
  If Not LoadXMLDoc (oXMLDoc, sServersXml) Then Exit Function
  
  dbName = sDBName
  If IsOracle then dbName = sUserID

  sNetMeterTag = "/xmlconfig/server[servertype='NetMeter']"
  If Not SetXMLTag (oXMLDoc, sNetMeterTag & "/servername",       sDBServer)   Then Exit Function
  If Not SetXMLTag (oXMLDoc, sNetMeterTag & "/databasename",     dbName)      Then Exit Function
  If Not SetXMLTag (oXMLDoc, sNetMeterTag & "/databasedriver",   sDBDriver)   Then Exit Function
  If Not SetXMLTag (oXMLDoc, sNetMeterTag & "/databasetype",     sDBTypeName) Then Exit Function
  If Not SetXMLTag (oXMLDoc, sNetMeterTag & "/username",         sUserID)     Then Exit Function
  If Not SetXMLTagPassword (oXMLDoc, sNetMeterTag & "/password", sUserPwd)    Then Exit Function

  sNetMeterStgTag = "/xmlconfig/server[servertype='NetMeterStage']"
  If Not SetXMLTag (oXMLDoc, sNetMeterStgTag & "/databasename", sStgDBName) Then Exit Function

  If Not SaveXMLDoc (oXMLDoc, sServersXml) Then Exit Function

' Second, update the MetraAR entry, if it exists
  sServersXml = MakeRMPPath(METRA_AR_EXTENSION_PATH & SERVERACCESS_PATH & XMLFILE_SERVERS)

  Dim oFso
  Set oFso  = CreateObject("Scripting.FileSystemObject")

  if oFso.FileExists(sServersXml) then
      WriteLog "Updating MetraAR" 

      If Not LoadXMLDoc (oXMLDoc, sServersXml) Then Exit Function

      sNetMeterTag = "/xmlconfig/server[servertype='MetraAR']"
      If Not SetXMLTag (oXMLDoc, sNetMeterTag & "/servername",       sDBServer)   Then Exit Function
      If Not SetXMLTag (oXMLDoc, sNetMeterTag & "/databasename",     dbName)      Then Exit Function
      If Not SetXMLTag (oXMLDoc, sNetMeterTag & "/databasedriver",   sDBDriver)   Then Exit Function
      If Not SetXMLTag (oXMLDoc, sNetMeterTag & "/databasetype",     sDBTypeName) Then Exit Function
      If Not SetXMLTag (oXMLDoc, sNetMeterTag & "/username",         sUserID)     Then Exit Function
      If Not SetXMLTagPassword (oXMLDoc, sNetMeterTag & "/password", sUserPwd)    Then Exit Function

      If Not SaveXMLDoc (oXMLDoc, sServersXml) Then Exit Function
  end if

  UpdateServersXml = true
end function
'******************************************************************************************

'******************************************************************************************
'*** Returns default args based on script's single arg  (sqlserver|oracle)  default: sqlserver
'******************************************************************************************
Function GetDefaultArgs
  dim dbtype
  dim sArgs, hArgs, arg, ok
   
  GetDefaultArgs = ""

'  ' convenience collection for command line args
  '[mh] moved to main
'  set ghCmdLineArgs = NamedArgsToHash

  ' use servers.xml if /reinstall argument is set
  if ghCmdLineArgs.Exists("reinstall") then
    GetDBParamsFromConfigFile()
    dbtype = GetProperty("MT_DBMS_TYPE")
    ghCmdLineArgs.Item("dbserver")  = GetProperty("MT_DBMS_COMPUTERNAME")
    ghCmdLineArgs.Item("dbname")    = GetProperty("MT_DATABASE_NAME")
    ghCmdLineArgs.Item("stgdbname") = GetProperty("MT_STAGING_DB_NAME")
    ghCmdLineArgs.Item("userid")    = GetProperty("MT_INIT_CONFIG_USER_ID")
    ghCmdLineArgs.Item("userpwd")   = GetProperty("MT_INIT_CONFIG_USER_PWD1")

  ' convert dbtype command line arg to internal value
  elseif ghCmdLineArgs.Exists("dbtype") then
    dbtype = DBTypeCode(ghCmdLineArgs.Item("dbtype"))

  ' default is SQL server
  else
    dbtype = kDBType_SQL
  end if
  ghCmdLineArgs.Item("dbtype") = dbtype

  ' set dbtype early so we can use common.vbs funcs
  If Not SetDBType(dbtype) then
    wscript.echo "The database type [" & ghCmdLineArgs.Item("dbtype") & "] is not supported."
    wscript.quit
  end if

  ' get default arguments based on dbtype
  if dbtype = kDBType_SQL then
    set hArgs = DefaultSqlServerArgs
  elseif dbtype = kDBType_Oracle then
    set hArgs = DefaultOracleArgs
  end if
  
  ' validate command line args.
  ' valid args are all those in Default*Args and...
  '       /?          -- help
  '       /uninstall  -- uninstall only
  ok = true
  for each arg in ghCmdLineArgs
    if arg <> "?" and arg <> "uninstall" and not hArgs.Exists(arg) then
      wscript.echo "Invalid arg: /" & arg & ":" & ghCmdLineArgs(arg)
      ok = false
    end if
  next
  if not ok then wscript.quit

  ' overlay the default args with the command line options
  ' need these to calculate the derived options
  OverlayHash hArgs, ghCmdLineArgs

  ' get derived options
  
  ' derive args dependent on other args
  DeriveDependentArgs hArgs
  
  ' using common.vbs funcs query the database for probable data file locations
  SetDevicePathArgs hArgs, hArgs("dbname"), hArgs("stgdbname"), hArgs("dbserver"), _
      hArgs("adminid"), hArgs("adminpwd")

  ' again, overlay the default args with the command line options
  ' command line args *always* have the last word.  (at least for now)
  OverlayHash hArgs, ghCmdLineArgs

  ' show the effective args
  wscript.echo
  ShowHash hArgs, "Resolved Args:"
  
  ' quit if user wanted help
  if ghCmdLineArgs.Exists("?") then wscript.quit
 
  ' update servers.xml to match effective args
  UpdateServersXml hArgs("dbserver"), hArgs("dbname"), GetDBDriver, GetDBTypeName, _
                   hArgs("userid"), hArgs("userpwd"), hArgs("stgdbname")
 
  ' convert to semi-sep value string
  sArgs = HashToValString(hArgs)
  GetDefaultArgs = sArgs
End Function
'******************************************************************************************

'****************************************************************************
' Gets device paths from database
'****************************************************************************
function SetDevicePathArgs(hArgs, sDBName, sStgDBName, sDBServer, sAdminUid, sAdminPwd)

  dim ok
  
  SetDevicePathArgs = false

  if not SetDatabaseDevicePaths(sDBName, sStgDBName, sDBServer, sAdminUid, sAdminPwd) then exit function

  ' copy props into command args
  hArgs("datafile") = goDict("MT_DATABASE_DATAFILE")
  hArgs("logfile") = goDict("MT_DATABASE_LOGFILE")
  hArgs("stgdatafile") = goDict("MT_STAGING_DB_DATAFILE")
  hArgs("stglogfile") = goDict("MT_STAGING_DB_LOGFILE")
  hArgs("partitionpaths") = goDict("MT_DB_PARTITIONING_PATHS")
            
  SetDevicePathArgs = true

end function

'******************************************************************************************
'*** Overlays argument hash with cmd line args hash 
'******************************************************************************************
function DeriveDependentArgs(hArgs)
  dim key, pair
  dim userid, stgdbname, dbtype
  dim wshnetwork
  
  dbtype = hArgs.Item("dbtype")

  if dbtype = kDBType_Oracle and not hArgs.Exists("userid") then
    ' should we warn user that userid is required if dbtype is oracle?
  end if

  ' special cases for developer convienience.
  
  ' derive necessarily unique args from the userid.
  ' done first so they're overridden if explicitly specified.
  if dbtype = kDBType_Oracle and hArgs.Exists("userid") then
    userid = hArgs.Item("userid")
    
    ' set user password and database based on given userid
    hArgs.Item("userpwd") = "+" & userid
    hArgs.Item("dbname") = userid

    ' set stage database name based on userid and local host name
    set wshnetwork = wscript.createobject("wscript.network")
    hArgs.Item("stgdbname") = CleanOracleName(userid & "_" & wshnetwork.computername)
  end if
  
  ' assume database status is current(9) when just uninstalling
  if hArgs.Exists("uninstall") then
    hArgs.Item("dbstatus") = "9"
  end if

end function  
'******************************************************************************************

'******************************************************************************************
'*** Overlays argument hash with cmd line args hash 
'******************************************************************************************
function OverlayHash(h, o)
  dim k
  
  ' no overylay given? skip it...
  if isempty(o) then exit function
  if o.Count < 1 then exit function

  ' overlay hash  
  for each k in o.Keys
    h.Item(k) = o.Item(k)
  next 

end function  
'******************************************************************************************

'******************************************************************************************
'*** Return default hash of Sql Server args
'******************************************************************************************
function DefaultSqlServerArgs
  dim args
  set args = createobject("scripting.dictionary")
  set DefaultSqlServerArgs = args

  args.add "installdir", ""
  args.add "rmppath", ""
  args.add "dbstatus", "1"
  args.add "dbtype", kDBType_SQL
  args.add "adminid", "sa"
  args.add "adminpwd", "MetraTech1"
  args.add "dbname", "NetMeter"
  args.add "dbserver", "localhost"
  args.add "userid", "nmdbo"
  args.add "userpwd", "MetraTech1"
  args.add "stgdbname", "NetMeterStage"
  args.add "datafile", "c:\Program Files\Microsoft SQL Server\MSSQL\Data\NetMeter_Data.mdf"
  args.add "datasize", "100"
  args.add "logfile", "c:\Program Files\Microsoft SQL Server\MSSQL\Data\NetMeter_Log.ldf"
  args.add "logsize", "25"
  args.add "stgdatafile", "c:\Program Files\Microsoft SQL Server\MSSQL\Data\NetMeterStage_Data.mdf"
  args.add "stglogfile", "c:\Program Files\Microsoft SQL Server\MSSQL\Data\NetMeterStage_Log.ldf"
  args.add "partitiontype", "0"
  args.add "partitionpaths", "c:\Program Files\Microsoft SQL Server\MSSQL\Data"
  args.add "servertype", "2"
  args.add "simtime", ""
  args.add "acctmpltype", "0"
  args.add "skipwarning", ""
end function
'******************************************************************************************

'******************************************************************************************
'*** Return default hash of Oracle args
'******************************************************************************************
function DefaultOracleArgs
  dim args, net
  set args = createobject("scripting.dictionary")
  set net = wscript.createobject("wscript.network")

  set DefaultOracleArgs = args
  
  args.add "installdir", ""
  args.add "rmppath", ""
  args.add "dbstatus", "1"
  args.add "dbtype", kDBType_Oracle
  args.add "adminid", "system"
  args.add "adminpwd", "sys"  ' prob. should chg oracle's system pwd to MetraTech1
  args.add "dbname", "NetMeter"
  args.add "dbserver", "sol"
  args.add "userid", ucase(net.username) '"nmdbo"
  args.add "userpwd", net.username '"nmdbo"
  args.add "stgdbname", ucase(CleanOracleName(net.username & "_" & net.computername))
  args.add "datafile", "/u01/app/oracle/oradata/netmeter/nmdbo.dbf"
  args.add "datasize", "50"
  args.add "logfile", ""
  args.add "logsize", "25"
  args.add "stgdatafile", "/u01/app/oracle/oradata/netmeter/nmdbostage.dbf"
  args.add "stglogfile", ""
  args.add "partitiontype", "0"
  args.add "partitionpaths", "/u01/app/oracle/oradata/netmeter"
  args.add "servertype", "2"
  args.add "simtime", ""
  args.add "dbdriver", "{Oracle in OraHome}"
  args.add "acctmpltype", "0"
  args.add "skipwarning", ""
end function
'******************************************************************************************


'******************************************************************************************
'*** Turns a hash of named args into its string representation "a;b;..;z"
'******************************************************************************************
function HashToValString(hArgs)
  dim sArgs
  dim sNames
  dim name, val
  dim re
  
  ' construct arg string from a hash with these keys in this order
  ' omit installdir and rmppath "installdir;rmppath;"
  sNames = "dbstatus;dbtype;adminid;adminpwd;dbname;dbserver;userid;userpwd;" _
      & "stgdbname;datafile;datasize;logfile;logsize;stgdatafile;stglogfile;" _
      & "partitiontype;partitionpaths;servertype;simtime;dbdriver;acctmpltype;uninstall"
  
  sArgs = ""
  for each name in split(sNames, ";")
    if hArgs.Exists(name) then val = hArgs.Item(name) else val = ""
    sArgs = sArgs & val & ";"
  next
  
  ' drop trailing semicolon
  set re = new regexp
  re.Pattern = ";$"
  sArgs = trim(re.Replace(sArgs, ""))

  HashToValString = sArgs
  
end function
'******************************************************************************************

'******************************************************************************************
'  Translates invalid characters into underscores to create a valid
'  Oracle name. The valid Oracle characters are: [a-z0-9_#$].
'******************************************************************************************
function CleanOracleName(name)
  dim re
  
  set re = new regexp
  re.pattern = "[^a-z0-9_#$]"
  re.ignorecase = true
  re.global = true

  CleanOracleName = re.replace(name, "_")
  
end function
'******************************************************************************************

'******************************************************************************************
Function RunSqlPLus(gsAdminID,gsAdminPwd,gsDBServer,gsDBName, strQueryTag)
On Error Resume Next

dim WshShell
dim fso   
dim sCmd
dim objStream
dim sOutPutFileName
dim sAdminID
CONST TristateFalse = 0
sAdminID = "sys"
dim sXMLFile, sTagName, sElementValue
dim sQuery
  

sXMLFile = "config\queries\dbinstall\Queries_oracle.xml"
sTagName = strQueryTag ' "//query[query_tag='__GRANT_DBMS_LOCK_PRIVILEGE__']/query_string"
sElementValue = ""

If Not GetXMLTagFromFile (sXMLFile, sTagName, sElementValue) Then 
    writelog("Error reading XML file ") & sXMLFile
    Exit Function
end if

sQuery = Replace(trim(sElementValue), "%%DBO_LOGON%%", ucase(gsDBName)) 
' convert tabs to spaces first
sQuery = Replace(sQuery, vbTab, " ")
' convert all CRLFs to spaces
sQuery = Replace(sQuery, vbCrLf, " ")
' Find and replace any occurences of multiple spaces
 Do While (InStr(sQuery, "  "))
        ' if true, the string still contains double spaces,
        ' replace with single space
        sQuery = Replace(sQuery, "  ", " ")
 Loop
 ' Remove any leading or training spaces and return
 ' result
sQuery = Trim(sQuery)

if strQueryTag = "//query[query_tag='__GRANT_DBMS_LOCK_PRIVILEGE__']/query_string" then
  sOutPutFileName = goEnv("TEMP") & "\GrantDbmsLock.sql"
else
  sOutPutFileName = goEnv("TEMP") & "\GrantDBA2Pending.sql"
end if


Set fso = CreateObject("Scripting.FileSystemObject")
if err then
	writelog("Could not create fso object")
	exit Function     		
end if
	
Set WshShell = CreateObject("Wscript.Shell")
if err then
	writelog(" Could not create Shell object")
	exit Function     	
end if
    
set objStream = fso.CreateTextFile(sOutPutFileName, True,TristateFalse)	
if err then
    writelog(" Could not create OutPutfile")
	exit Function     	
end if

with objStream
     .WriteLine sQuery
     .WriteLine "EXIT"        
     .close
end with
    
' Syntax is: sqlplus.exe "sys/pwd@tns_alias AS SYSDBA" @scriptname.sql      
sCmd = "sqlplus.exe """ & sAdminID & "/{0}@" & gsDBServer & " AS SYSDBA""" & " @" & sOutPutFileName
		
If Not ExecuteCommandWithPasswords(sCmd,array(gsAdminPwd)) Then 
	writelog("Error executing SQLPlus script : " & sOutPutFileName)
    Exit Function
end if
  
RunSqlPLus = true
end function
'******************************************************************************************

'*******************************************************************************
'*** Test whether a directory exist or not. Create it if it does not exist.
'*******************************************************************************
Function CheckPath(sInstallDir)
  Dim sFileName
  Dim fso, f, sDirName2
  Dim sDirName
  Dim nPos
  
  sFileName = goFso.GetExtensionName(sInstallDir)
  
  If sFileName <> "" Then
    nPos = InStrRev(sInstallDir,"\")
	If nPos <> 0 Then
		sDirName2 = Left(sInstallDir,nPos-1)
	Else
		sDirName2 = ""
	End If
  Else 
    sDirName2 = sInstallDir  
  End If 
  
    
  If (goFso.FolderExists(sDirName2)) Then
      writelog "  Directory Exists:" & sDirName2 

  Else
      writelog " Directory DOES NOT Exist:" & sDirName2 & "  Will be created by installer."
	  Set f = goFso.CreateFolder(sDirName2)
    End If 
  End Function
'*******************************************************************************

'*******************************************************************************
Function SetAccountTemplateType(sAccountTemplateType)
	SetAccountTemplateType = false
	If sAccountTemplateType = "" Then
		sAccountTemplateType = "0"
	End If
	If IsOracle then
		If Not SetAccountTemplateTypeOracle(sAccountTemplateType) Then
			WriteLog "<*** Error inserting account template inheritance type"
			Exit Function
		End If
	Else
		Dim oRcdSet
		If Not ExecuteQuery(oRcdSet, "DELETE FROM t_acc_tmpl_types; INSERT INTO t_acc_tmpl_types(Id,all_types) VALUES(1,0" & sAccountTemplateType & ")", gsDBName, gsDBServer, gsAdminID, gsAdminPwd) Then
			WriteLog "<*** Error inserting account template inheritance type"
			Exit Function
		End If

		WriteLog "     Account template inheritance type successfully inserted"
	End If
	SetAccountTemplateType = true
End Function
'*******************************************************************************
'*******************************************************************************
Function SetAccountTemplateTypeOracle(sAccountTemplateType)
 On Error Resume Next
 SetAccountTemplateTypeOracle = false

 dim sCmd
 dim sFileName

 Dim sCustActData
 Dim sIncludeDir
 sIncludeDir = "."
 On Error Resume Next
 sCustActData = Session.Property("CustomActionData")
 If err.Number = 0 Then
  On Error Goto 0
  'we are being called from the installer; get install dir from CustomActionData and derive include dir
  Dim nEnd
  nEnd = InStr(sCustActData,";")
  If nEnd = 0 Then nEnd = Len(sCustActData)+1
  sIncludeDir = Left(sCustActData,nEnd-1) & "install\scripts"
 Else
  On Error Goto 0
   Dim oWsh, oEnv
   Set oWsh = CreateObject("Wscript.Shell")
   Set oEnv = oWsh.Environment("PROCESS")

   If oEnv("ROOTDIR") <> "" Then
    'ROOTDIR is defined, we are in development environment; derive include dir accordingly
    sIncludeDir = oEnv("ROOTDIR") & "\install\scripts"
   Else
    'Last chance: include file must be in my current directory
    sIncludeDir = "."
   End If

   Set oWsh = Nothing
   Set oEnv = Nothing
 End If
 sFileName = sIncludeDir & "\acctmpltype.sql"
 Dim oFso
 Set oFso  = CreateObject("Scripting.FileSystemObject")
 If Not oFso.FileExists(sFileName) Then
  wscript.echo "     Error: File " & sFileName & " does not exist"
  Set oFso = Nothing
  Exit Function
 End If
 sCmd = "sqlplus " & gsUserID & "/{0}@" & gsDBServer & " @" & sFileName & " " & sAccountTemplateType

 If Not ExecuteCommandWithPasswords(sCmd,array(gsUserPwd)) Then 
  writelog("Error executing SQLPlus script : " & sFileName)
  Exit Function
 end if
   
 SetAccountTemplateTypeOracle = true
End Function
'*******************************************************************************


'*******************************************************************************
'*** Inserting Meter Partition Info
'*******************************************************************************
Function InsertMeterPartitionInfo()
	InsertMeterPartitionInfo = False

	Dim oRcdSet
	Dim sSqlStmt

	If IsSqlServer Then
		sSqlStmt = "EXEC prtn_insert_meter_partition_info @id_partition = 1"
	ElseIf IsOracle Then
		sSqlStmt = "BEGIN prtn_insert_meter_part_info(id_partition =>1); END;"
	End If
  
	If Not ExecuteQuery(oRcdSet, sSqlStmt, gsDBName, gsDBServer, gsUserID, gsUserPwd) Then
		WriteLog "<*** Error on execution 'prtn_insert_meter_partition_info' SP"
		Exit Function
	End If

	InsertMeterPartitionInfo = True
End Function
'*******************************************************************************
