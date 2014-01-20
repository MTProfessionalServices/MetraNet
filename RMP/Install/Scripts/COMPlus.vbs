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
'* Name:        COMPlus.vbs
'* Created By:  Chris Messman / Derek Young / Simon Morton
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

'*** Constants
Const COMAdminAccessChecksApplicationLevel          = 0 
Const COMAdminAccessChecksApplicationComponentLevel = 1 

Const COMAdminActivationInproc       = 0 
Const COMAdminActivationLocal        = 1 

Const COMAdminTransactionIgnored     = 0 
Const COMAdminTransactionNone        = 1 
Const COMAdminTransactionSupported   = 2 
Const COMAdminTransactionRequired    = 3 
const COMAdminTransactionRequiresNew = 4 

Const COMAdminTxIsolationLevelAny  = 0

Const APP_NAME = "MetraNet"
Const APP_DESC = "MetraNet COM+ Application"

Const MIN_TIMEOUT = 600

'*** File Name Constants ***
Const SERVDEF_GENDLL        = "MetraTech.DomainModel.ServiceDefinitions.Generated.dll"
Const SERVDEF_GENPDB        = "MetraTech.DomainModel.ServiceDefinitions.Generated.pdb"


'*** Global Variables
Dim goBinFileColl
Dim gsTLBDir
Dim gbUIInstall

'*** Main
Function Main()
  'Command line invocation

  If Not SetCustomActionData("") Then Exit Function

  WriteLog ">>>> Uninstalling COM+ Applications..."
  If RemoveComPlusApps() <> kRetVal_SUCCESS Then Exit Function

  WriteLog ">>>> Installing COM+ Applications..."
  If InstallComPlusApps() <> kRetVal_SUCCESS Then Exit Function

  WriteLog "<<<< COM+ Applications Successfully Installed."
End Function

'*******************************************************************************
Function InstallCOMPlusApps()
  On Error Resume Next
  InstallCOMPlusApps = kRetVal_ABORT
  EnterAction "InstallCOMPlusApps"
  
  If Not GetParameters()          Then Exit Function
  If Not RemoveApplication()      Then Exit Function
  If Not SetTimeout()             Then Exit Function
  If Not InstallApplication()     Then Exit Function  
  If Not RegisterAssemblies(True) Then Exit Function

  ExitAction "InstallCOMPlusApps"
  InstallCOMPlusApps = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
Function RemoveCOMPlusApps()
  
  Dim sServerDefGenDLLPath
  Dim sServerDefGenPDBPath
  
  On Error Resume Next
  RemoveCOMPlusApps = kRetVal_ABORT
  EnterAction "RemoveCOMPlusApps"
  
  If Not GetParameters()           Then Exit Function
  If Not RegisterAssemblies(False) Then Exit Function
  If Not RemoveApplication()       Then Exit Function

  sServerDefGenDLLPath = MakeBinPath(SERVDEF_GENDLL)
  sServerDefGenPDBPath = MakeBinPath(SERVDEF_GENPDB)

  WriteLog "     Deleting ServiceDef Generated Dll and PDB files"

  DeleteFile(sServerDefGenDLLPath)
  DeleteFile(sServerDefGenPDBPath)

  ExitAction "RemoveCOMPlusApps"
  RemoveCOMPlusApps = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get parameters from InstallShield
'*******************************************************************************
Function GetParameters()
  Dim oFolder
  Dim sUIorSilent

  On Error Resume Next
  GetParameters = False

  If Not InitializeArguments() Then Exit Function
  If Not GetArgument (sUIorSilent,   2,  False)  Then Exit Function

  If LCase(sUIorSilent) = "ui" Then
    gbUIInstall = True
  Else
    gbUIInstall = False
  End If

  Set oFolder       = goFso.GetFolder(GetBinDir())
  Set goBinFileColl = oFolder.files
  If CheckErrors ("retrieving binary file collection") Then Exit Function

  'TLBs live in Bin dir unless a parallel Include dir exists (dev env only)
  gsTLBDir = GetBinDir()
  If TestRegExp(gsTLBDir,"\\Bin\\?$") Then
    Dim sIncDir
    sIncDir = ReplaceRegExp(gsTLBDir,"\\Bin\\?$", "\Include\")
    If DirExists(sIncDir) Then
      gsTLBDir = sIncDir
    End If
  End If
  WriteLog "     Looking for TLBs in " & gsTLBDir

  GetParameters = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Install C Runtime Library redistributable
'*******************************************************************************
'Test
'gsBinDir = "S:\Thirdparty\Microsoft\VisualStudio.NET\release"
'InstallCRuntime
Function InstallCRuntime ()
  Dim sCRTRedistPath

  InstallCRuntime = False

  If gbUIInstall Then ' only if installing using the UI
    sCRTRedistPath = MakeBinPath("vcredist_x86.exe")
    If FileExists(sCRTRedistPath) Then
      If Not ExecuteCommand(sCRTRedistPath) Then Exit Function
    End If

  End If
 
  InstallCRuntime = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Set COM+ timeout if it is less than the minimum
'*******************************************************************************
Function SetTimeout ()
  Dim oCatalog ' As COMAdmin.COMAdminCatalog
  Dim oLocalCompColl
  Dim oLocalCompItem
  Dim oTxCtx
  Dim nCurrentTimeout    

  On Error Resume Next
  SetTimeout = False
  EnterFunction "SetTimeout"    
  
  'Set up the transaction context
  Set oTxCtx = CreateObject("TxCtx.TransactionContext")
  If CheckErrors ("creating TxCtx.TransactionContext") Then Exit Function
  
  'Get catalog 
  Set oCatalog = oTxCtx.CreateInstance("COMAdmin.COMAdminCatalog")
  If CheckErrors ("creating COMAdmin.COMAdminCatalog") Then Exit Function
    
  'Increase transaction timeout if needed
  Set oLocalCompColl = oCatalog.GetCollection("LocalComputer")
  If CheckErrors ("getting LocalComputer collection") Then Exit Function
    
  oLocalCompColl.Populate
    
  Set oLocalCompItem = oLocalCompColl.Item(0)
  
  nCurrentTimeout = oLocalCompItem.Value("TransactionTimeout")

  'We want to increase the timeout if it is less than the minimum but not 0 (infinite)
  If nCurrentTimeout > 0 And nCurrentTimeout < MIN_TIMEOUT then
    WriteLog "     Increasing transaction timeout from " & nCurrentTimeout & " to " & MIN_TIMEOUT & " seconds."

    oLocalCompItem.Value("TransactionTimeout") = MIN_TIMEOUT
    oLocalCompColl.SaveChanges
    oTxCtx.Commit
    If CheckErrors ("committing changes to COM+ application " & APP_NAME) Then Exit Function

    'Restart MSDTC so that new timeout takes effect immediately (give it a couple of seconds to stop and start)
    If Not StopService("msdtc", "") Then Exit Function
    wscript.sleep 2000
    If Not StartService("msdtc") Then Exit Function
    wscript.sleep 2000

  Else
    WriteLog "     No need to increase transaction timeout;  timeout is already " &  nCurrentTimeout & " seconds."
    oTxCtx.Abort
    If CheckErrors ("aborting COM+ transaction") Then Exit Function
  End If

  ExitFunction "SetTimeout"
  SetTimeout = True
End Function
'*******************************************************************************


'*******************************************************************************
'This function selects all files containing Exec.dll in its name and installs
'it as a com plus application.  In addition, it installs priceableitemhook.dll
'as a complus app.
'*******************************************************************************
Function InstallApplication ()
  Dim oCatalog ' As COMAdmin.COMAdminCatalog
  Dim oAppColl ' As COMAdmin.COMAdminCatalogCollection
  Dim oApp     ' As COMAdmin.COMAdminCatalogObject
  Dim oTxCtx
  Dim oFile

  On Error Resume Next
  InstallApplication = False
  EnterFunction "InstallApplication"    

  WriteLog "     Installing COM+ application " & APP_NAME
  
  'Set up the transaction context
  Set oTxCtx = CreateObject("TxCtx.TransactionContext")
  If CheckErrors ("Creating Object TxCtx.TransactionContext") Then Exit Function
  
  'Get catalog 
  Set oCatalog = oTxCtx.CreateInstance("COMAdmin.COMAdminCatalog")
  If CheckErrors ("Creating Object COMAdmin.COMAdminCatalog") Then Exit Function
    
  'Add new library application

  Set oAppColl = oCatalog.GetCollection("Applications")
  Set oApp     = oAppColl.Add
    
  oApp.Value("Name")                           = APP_NAME
  oApp.Value("Description")                    = APP_DESC
  oApp.Value("ApplicationAccessChecksEnabled") = False
  oApp.Value("AccessChecksLevel")              = COMAdminAccessChecksApplicationComponentLevel
  oApp.Value("Activation")                     = COMAdminActivationInProc
  oAppColl.SaveChanges
  If CheckErrors ("adding COM+ application " & APP_NAME) Then Exit Function

  WriteLog "     Installing COM+ components..."

  For Each oFile in goBinFileColl
    If (Right(oFile.Name,8) = "Exec.dll" And oFile.Name <> "MTGreatPlainsExec.dll") _
       Or oFile.Name = "MTAuditDBWriter.dll" Or oFile.Name = "ComPlusWrapper.dll"  _
       Or oFile.Name = "MetraTech.AR.eConnectShim.dll" Then
      WriteLog "     Installing " & oFile.Name
      oCatalog.InstallComponent APP_NAME, MakeBinPath(oFile.Name), "", ""
      If CheckErrors ("installing component " & oFile.Name) Then Exit Function
    End If
  Next

  WriteLog "     Importing COM+ components from registered COM objects..."

  Dim asProgIDs
  Dim sProgID
  asProgIDs = array("MTGreatPlainsExec.MTGreatPlainsReader", _
                    "MTGreatPlainsExec.MTGreatPlainsWriter") ', _
                    'XXXXXXXXXXXXXXXXX"Byot.ByotServerEx")
                   
  For Each sProgID in asProgIDs
    WriteLog "     Importing " & sProgID
    oCatalog.ImportComponent APP_NAME, sProgID
    If CheckErrors ("importing component " & sProgID) Then Exit Function
  Next 

  If Not SetTransactionProps (oAppColl, oApp) Then Exit Function
  
  WriteLog "     Committing changes"
  oTxCtx.Commit
  If CheckErrors ("committing changes") Then Exit Function

  'C# Functionality
      
  WriteLog "     Installing C# Serviced Components"

  For Each oFile in goBinFileColl
    If IsAnAssembly (oFile.Name) Then
      'Only register serviced component if TLB file is found
      If FileExists(MakePath(gsTLBDir,GetTLBFile(oFile.Name))) Then
        If Not RegisterCSharpComponents(oFile.Name) Then Exit Function
      End If
    End If
  Next

  ExitFunction "InstallApplication"  
  InstallApplication = True
End Function
'*******************************************************************************


'*******************************************************************************
Function RegisterCSharpComponents(sDllName) 'As Boolean
  Dim sCmd

  sCmd = MakeBinPath("RegisterServicedComponents.exe /file:")  & MakeBinPath(sDllName) & _
                                                   " /app:"    & APP_NAME & _
                                                   " /tlbdir:" & gsTLBDir
  RegisterCSharpComponents = ExecuteCommand(sCmd)
End Function
'*******************************************************************************


'*******************************************************************************
Function SetTransactionProps(oAppColl, oApp)
  Dim oCompColl 
  Dim oComp
  
  On Error Resume Next
  SetTransactionProps = False
  EnterFunction "SetTransactionProps"
  
  Set oCompColl = oAppColl.GetCollection("Components", oApp.Key)
  If CheckErrors ("getting collection") Then Exit Function
  
  oCompColl.Populate
  
  WriteLog "     Setting COM+ Component Transaction properties.."
  For Each oComp in oCompColl
    'except For DDL writer, since Oracle does
    'not support Txns around DDL statements

    If InStr(oComp.Name, "DDLWriter") Then
      WriteLog "     " & oComp.Name & " [ignored]"
      oComp.Value("Transaction") = COMAdminTransactionIgnored

    Elseif InStr(oComp.Name, "FailureAuditDBWriter") Then
      WriteLog "     " & oComp.Name & " [requires new]"
      oComp.Value("Transaction") = COMAdminTransactionRequiresNew

    Elseif oComp.Name = "MTPCImportExportExec.CImportWriter" Then
      WriteLog "     " & oComp.Name & " [required] [timeout=0]"
      oComp.Value("Transaction") = COMAdminTransactionRequired
      oComp.Value("ComponentTransactionTimeoutEnabled") = True
      oComp.Value("ComponentTransactionTimeout")        = 0

    Elseif InStr(oComp.Name, "Writer") Or _
           oComp.Name = "ComplusWrapper.ExecVBScript" Then
      WriteLog "     " & oComp.Name & " [required]"
      oComp.Value("Transaction") = COMAdminTransactionRequired

    ElseIf InStr(oComp.Name, "Reader") Then
      WriteLog "     " & oComp.Name & " [supported]"
      oComp.Value("Transaction") = COMAdminTransactionSupported
    End If
    
    oComp.Value("TxIsolationLevel") = COMAdminTxIsolationLevelAny
  Next
  
  oCompColl.SaveChanges
  If CheckErrors ("saving changes") Then Exit Function
        
  ExitFunction "SetTransactionProps"
  SetTransactionProps = True
End Function
'*******************************************************************************


'*******************************************************************************
Function RemoveApplication() 'As Boolean
  Dim oCatalog ' As COMAdmin.COMAdminCatalog
  Dim oAppColl ' As COMAdmin.COMAdminCatalogCollection
  Dim oApp     ' As COMAdmin.COMAdminCatalogObject
  Dim nIndex

  On Error Resume Next
  RemoveApplication = False
  
  WriteLog "     Uninstalling COM+ Application: " & APP_NAME

  Set oCatalog = CreateObject("COMAdmin.COMAdminCatalog")
  If CheckErrors("creating object COMAdminCatalog") Then Exit Function
  
  Set oAppColl = oCatalog.GetCollection("Applications")
  oAppColl.Populate
  If CheckErrors("getting application collection") Then Exit Function

  ' iterate through applications looking for AppName
  nIndex = 0
  While nIndex < oAppColl.Count
    Set oApp = oAppColl.Item(nIndex)
    If oApp.Name = APP_NAME Then
      WriteLog "     Removing Application: " & APP_NAME
      oAppColl.Remove nIndex
      oAppColl.SaveChanges
      If CheckErrors("Saving Applications Collection") Then Exit function
      'look for more matches starting from beginning
      nIndex = -1
    End If
    nIndex = nIndex + 1
  wend

  RemoveApplication = True
End Function
'*******************************************************************************


'*******************************************************************************
FUNCTION IsAnAssembly (sFileName)

  If LCase(sFileName) = "metratech.metraar.services.test.dll" Then
    IsAnAssembly = False
    Exit Function
  End If 

  If LCase(Left(sFileName,10)) = "metratech." And _
	 LCase(Left(sFileName,13)) <> "metratech.ice" And _
     LCase(Mid(sFileName,11,15)) <> "domainmodel.dll" And _
     LCase(Mid(sFileName,11,7)) <> "custom." And _
     LCase(Right(sFileName,4)) = ".dll" And _
     LCase(Mid(sFileName,11,Len("ActivityServices."))) <> "activityservices." And _
     LCase(Right(sFileName, Len("clientproxies.dll"))) <> "clientproxies.dll" And _
     LCase(Right(sFileName, Len("proxyactivities.dll"))) <> "proxyactivities.dll" Then
    IsAnAssembly = True
  Else
    IsAnAssembly = False
  End If

End Function
'*******************************************************************************

'*******************************************************************************
FUNCTION GetTLBFile (sFileName)
  'Assuming IsAnAssembly(sFileName) is True

  GetTLBFile = Left(sFileName,Len(sFileName)-3) & "tlb"

End Function
'*******************************************************************************

'*******************************************************************************
FUNCTION RegisterAssemblies (bRegister)
  Dim sCmd
  Dim sOptions
  Dim sAction
  Dim oFile
  Dim sDotNetPath

  RegisterAssemblies = False

  If bRegister then
    sAction  = "Registering"
    sOptions = "/codebase "
  Else
    sAction  = "Unregistering"
    sOptions = "/u "
  End If

  WriteLog "     " & sAction & " assemblies for COM Interop"

  If Not GetDotNetPath(sDotNetPath) Then Exit Function

  For Each oFile in goBinFileColl
    If IsAnAssembly(oFile.Name) Then
      sCmd = MakePath(sDotNetPath, "regasm.exe ") & sOptions & MakeBinPath(oFile.Name)
      If Not ExecuteCommand (sCmd) Then Exit Function
    End If
  Next

  RegisterAssemblies = True
End Function
'*******************************************************************************
