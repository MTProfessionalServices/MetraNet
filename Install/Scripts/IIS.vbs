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
'* Name:        IIS.vbs
'* Created By:  Alfred Flanagan, Simon Morton
'* Description: Installation and Uninstallation of IIS Virtual Directories
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
Const CONFIG_PATH     = "Config"
Const VALIDATION_PATH = "Config\validation"
Const ROOT_PATH       = "UI\Root"
Const MDM_PATH        = "UI\mdm"
Const MCM_PATH        = "UI\mcm"
Const MAM_PATH        = "UI\mam"
Const MOM_PATH        = "UI\mom"
Const MPTE_PATH       = "UI\mpte"
Const METRAVIEW_PATH  = "Extensions\MetraView\Sites\MetraView"
Const METRAVIEW_HELP_PATH  = "Extensions\MetraView\Sites\MetraViewHelp"

'*** Global Variables
Dim goIISRoot

'*** Main
Function Main()
  'Command line invocation
  WriteLog ">>>> Uninstalling Virtual Directories..."
  If Not SetCustomActionData("RMP,WS,Listener,UI,MAM,MOM,MPS,MCM") Then Exit Function
  If ModifyVirDirs() <> kRetVal_SUCCESS Then Exit Function

  WriteLog ">>>> Installing Virtual Directories..."
  If Not SetCustomActionData("RMP,WS,Listener,UI,MAM,MOM,MPS,MCM") Then Exit Function
  If ModifyVirDirs() <> kRetVal_SUCCESS Then Exit Function

  WriteLog "<<<< Virtual Directories Successfully Installed."

  StartService "w3svc"
End Function
'*******************************************************************************


'*******************************************************************************
'*** Modify Virtual Directories
'*******************************************************************************
Function ModifyVirDirs ()
  Dim sFeaturesToRemove
  Dim sFeaturesToAdd
  Dim sErrMsg
  Dim bIISInstalled
  Dim bIISAdminEnabled
  Dim bW3SvcEnabled

  On Error Resume Next
  ModifyVirDirs = kRetVal_ABORT
  EnterAction "ModifyVirDirs"

  If Not InitializeArguments() Then Exit Function

  If Not GetArgument (sFeaturesToAdd,    2, False)   Then Exit Function
  If Not GetArgument (sFeaturesToRemove, 3, False)   Then Exit Function

  If Not CheckServiceInstalled (bIISInstalled, "w3svc") Then Exit Function 

  If bIISInstalled Then
    If Not CheckServiceEnabled (bIISAdminEnabled, "iisadmin") Then Exit Function 
    If Not CheckServiceEnabled (bW3SvcEnabled,    "w3svc") Then Exit Function 

    If bIISAdminEnabled And bW3SvcEnabled Then
      If Not StopService   ("iisadmin", "/y")          Then Exit Function

      If Not GetIISObject  (goIISRoot, "W3SVC/1/Root") Then Exit Function

      If Not RemoveVirDirs (sFeaturesToRemove)         Then Exit Function
      If Not AddVirDirs    (sFeaturesToAdd)            Then Exit Function

    Else
      WriteLog "     IIS service is not enabled; skipping IIS configuration"
    End If

  Else
    WriteLog "     IIS service is not installed; skipping IIS configuration"
  End If
  
  ExitAction "ModifyVirDirs"
  ModifyVirDirs = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get ASP.NET virtual directory location
'*** If we find a file called source_location.txt in the given directory, use its
'*** contents as the relative path to the actual location (dev environment only)
'*******************************************************************************
Function GetASPNETVirDirLoc (ByRef sPath, sRelPath)
  Dim sLocationFilePath

  GetASPNETVirDirLoc = False

  sPath = MakeRMPPath(sRelPath)
  sLocationFilePath = MakePath(sPath,"source_location.txt")
  If FileExists(sLocationFilePath) Then
    Dim sNewRelPath
    If Not SlurpFile (sNewRelPath, sLocationFilePath) Then Exit Function
   
    sPath = RemoveParentPathRefs(MakePath(sPath,sNewRelPath))

    If Not DirExists(sPath) Then
      WriteLog "***> Error: path " & sPath & " does not exist"
      sPath = Nothing
      Exit Function
    End If
  End If

  WriteLog "     ASP.NET virtual directory located at " & sPath
  GetASPNETVirDirLoc = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Add Virtual Directories
'*******************************************************************************
Function AddVirDirs (sFeatures)
  Dim sBatchPath
  Dim sRerunPath
  Dim sAccHierPath
  Dim sImageHandlerPath
  Dim sSuggestPath
  Dim sMetraNetPath
  Dim sMetraNetHelp
  Dim sResPath
  
  On Error Resume Next
  WriteLog "----> Features: " & sFeatures
    
  AddVirDirs = False
  EnterFunction "AddVirDirs"

  If sFeatures <> "" Then
    If Not GetASPNETVirDirLoc (sBatchPath,        "WebServices\Batch")            Then Exit Function
    If Not GetASPNETVirDirLoc (sRerunPath,        "WebServices\BillingRerun")     Then Exit Function
    If Not GetASPNETVirDirLoc (sAccHierPath,      "WebServices\AccountHierarchy") Then Exit Function
    If Not GetASPNETVirDirLoc (sMetraNetPath,     "UI\MetraNet")                  Then Exit Function
    If Not GetASPNETVirDirLoc (sMetraNetHelp,     "UI\MetraNetHelp")              Then Exit Function    
    If Not GetASPNETVirDirLoc (sImageHandlerPath, "UI\ImageHandler")              Then Exit Function
    If Not GetASPNETVirDirLoc (sSuggestPath,      "UI\Suggest")                   Then Exit Function
    If Not GetASPNETVirDirLoc (sResPath,          "UI\Res")                       Then Exit Function

  
    If IsIISFeatureSelected("RMP", sFeatures) Then
      If Not UpdateASPNETVersion() Then Exit Function
      If Not EnableGzipCompression() Then Exit Function
      If Not InstallWebServiceExtensions() Then Exit Function
      If Not CreateAppPool("MetraNetSystemAppPool",0) Then Exit Function
      If Not CreateAppPool("MetraNetUserAppPool",2) Then Exit Function
    End If
    
    If IsIISFeatureSelected("Listener", sFeatures) Then
      If Not CreateExeVirDir ("msix", GetBinDir()) Then Exit Function
  
      'Batch web service
      If Not CreateStdVirDir ("Batch", sBatchPath) Then Exit Function
    End If
  
    If IsIISFeatureSelected("UI", sFeatures) Then
      'Set site default URL 
      If Not SetRootPath(MakeRMPPath(ROOT_PATH)) Then Exit Function
  
      'Create Virtual Directories
      If Not CreateStdVirDir ("MetraNet", sMetraNetPath) Then Exit Function
      If Not CreateExeVirDir ("MetraNetHelp", sMetraNetHelp) Then Exit Function
      If Not CreateStdVirDir ("mdm", MakeRMPPath(MDM_PATH)) Then Exit Function
      If Not CreateStdVirDir ("mpte", MakeRMPPath(MPTE_PATH)) Then Exit Function
      If Not CreateStdVirDir ("mcm", MakeRMPPath(MCM_PATH)) Then Exit Function
      If Not CreateStdVirDir ("mam", MakeRMPPath(MAM_PATH)) Then Exit Function
      If Not CreateStdVirDir ("AccountHierarchy", sAccHierPath) Then Exit Function
      If Not CreateStdVirDir ("ImageHandler", sImageHandlerPath) Then Exit Function
      If Not CreateStdVirDir ("Suggest", sSuggestPath) Then Exit Function
      If Not CreateStdVirDir ("Res", sResPath) Then Exit Function
      If Not CreateStdVirDir ("mom", MakeRMPPath(MOM_PATH)) Then Exit Function
      If Not CreateStdVirDir ("BillingRerun", sRerunPath) Then Exit Function
      If Not CreateStdVirDir ("MetraView", MakeRMPPath(METRAVIEW_PATH)) Then Exit Function
      If Not CreateStdVirDir ("MetraViewHelp", MakeRMPPath(METRAVIEW_HELP_PATH)) Then Exit Function      
      If Not CreateStdVirDir ("validation", MakeRMPPath(VALIDATION_PATH)) Then Exit Function
    End If

  Else
    WriteLog "     Nothing to do!"
  End If
  
  ExitFunction "AddVirDirs"
  AddVirDirs = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Remove Virtual Directories
'*******************************************************************************
Function RemoveVirDirs (sFeatures)

  On Error Resume Next
  RemoveVirDirs = False
  EnterFunction "RemoveVirDirs"

  WriteLog "----> Features: " & sFeatures
  If sFeatures <> "" Then
      If Not DeleteVirtualDir ("mcm") Then Exit Function
      If Not DeleteVirtualDir ("validation") Then Exit Function
      If Not DeleteVirtualDir ("mam") Then Exit Function
      If Not DeleteVirtualDir ("AccountHierarchy") Then Exit Function
      If Not DeleteVirtualDir ("ImageHandler") Then Exit Function
      If Not DeleteVirtualDir ("Suggest") Then Exit Function
      If Not DeleteVirtualDir ("Res") Then Exit Function
      If Not DeleteVirtualDir ("mom") Then Exit Function
      If Not DeleteVirtualDir ("BillingRerun") Then Exit Function
      If Not DeleteVirtualDir ("MetraView") Then Exit Function
      If Not DeleteVirtualDir ("MetraViewHelp") Then Exit Function
      If Not SetRootPath(goEnv("SYSTEMDRIVE") & "\Inetpub\wwwroot") Then Exit Function
      If Not DeleteVirtualDir ("mdm") Then Exit Function
      If Not DeleteVirtualDir ("mpte") Then Exit Function
      If Not DeleteVirtualDir ("MetraNet") Then Exit Function
      If Not DeleteVirtualDir ("MetraNetHelp") Then Exit Function
      If Not DeleteVirtualDir ("msix") Then Exit Function
      If Not DeleteVirtualDir ("Batch") Then Exit Function
      If Not DeleteAppPool("MetraNetSystemAppPool") Then Exit Function
      If Not DeleteAppPool("MetraNetUserAppPool") Then Exit Function
      If Not RemoveWebServiceExtensions() Then Exit Function

  Else
    WriteLog "     Nothing to do!"
  End If

  ExitFunction "RemoveVirDirs"
  RemoveVirDirs = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Create a redirect
'*******************************************************************************
Function SetRootPath (sPath)
  SetRootPath = False
  On Error Resume Next

  WriteLog "     Setting root web server path to " & sPath
  goIISRoot.Path = sPath
  goIISRoot.SetInfo
  If CheckErrors("setting root web server path") Then Exit Function

  SetRootPath = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Create a redirect
'*******************************************************************************
Function CreateRedirect (sName, sRedirect)
  CreateRedirect = CreateVirtualDir (sName, "", 0, 0, 0, 0, sRedirect)
End Function
'*******************************************************************************


'*******************************************************************************
'*** Create a standard virtual directory (No Execute, Pooled)
'*******************************************************************************
Function CreateStdVirDir (sName, sPath)
  CreateStdVirDir = CreateVirtualDir (sName, sPath, 0, 0, 2, 0, "")
End Function
'*******************************************************************************


'*******************************************************************************
'*** Create an executable virtual directory (Execute, Pooled, 4MB ReadAhead)
'*******************************************************************************
Function CreateExeVirDir (sName, sPath)
  CreateExeVirDir = CreateVirtualDir (sName, sPath, 0, 1, 2, 4*1024*1024, "")
End Function
'*******************************************************************************


'*******************************************************************************
'*** Create an in-process virtual directory (No Execute, In Process)
'*******************************************************************************
Function CreateInProcVirDir (sName, sPath)
  CreateInProcVirDir = CreateVirtualDir (sName, sPath, 0, 0, 0, 0, "")
End Function
'*******************************************************************************


'*******************************************************************************
'*** Create a virtual directory
'*******************************************************************************
Function CreateVirtualDir (sName, sPath, nAuth, nAccess, nIsolation, nReadAhead, sRedirect)
  Dim oDir

  CreateVirtualDir = False
  On Error Resume Next

  'Check to see if the virtual directory already exists
  Set oDir = goIISRoot.GetObject("IISWebVirtualDir", sName)
  ' This will return error -2147024893 if it doesn't exist
  If Err.Number = -2147024893 Then
    err.Clear

    Set oDir = goIISRoot.Create("IISWebVirtualDir", sName)
    goIISRoot.SetInfo
    If CheckErrors("creating virtual directory " & sName) Then Exit Function

    oDir.AppFriendlyName = sName

    If sRedirect = "" Then
      oDir.Path = sPath
      oDir.AccessScript = True

      'set basic authentication if required
      If nAuth = 1 Then
        oDir.AuthBasic = True
        oDir.Authanonymous = False
      End If

      'give execute permission if required
      If nAccess = 1 Then
        oDir.AccessExecute = True
      End If

      oDir.AppCreate False

      'Use old IIS5 isolation level to determine which application pool to use
      If nIsolation = 0 Then
        oDir.AppPoolID = "MetraNetSystemAppPool"
      Else
        oDir.AppPoolID = "MetraNetUserAppPool"
      End If

      If nReadAhead > 0 Then
        oDir.UploadReadAheadSize = nReadAhead
      End If

      'Only enable compression on non-Execute, non-InProc virtual directories
      If nAccess = 0 and nIsolation = 2 Then
        oDir.DoDynamicCompression = 1
        oDir.DoStaticCompression  = 0
      End If

      oDir.SetInfo

      If CheckErrors("configuring virtual directory " & sName) Then Exit Function

      WriteLog "     Created Virtual Directory " & sName & " (" & sPath & ")"

      'Hack for ImageHandler vdir
      If sName = "ImageHandler" Then
        If Not AddImgHdlrScriptMaps(oDir) Then Exit Function
      End If

    Else
      oDir.HttpRedirect = "/" & sRedirect & ", CHILD_ONLY"
      oDir.SetInfo

      If CheckErrors("setting HTTP Redirect for " & sName) Then Exit Function

      WriteLog "     Created HTTP Redirect     " & sName & " ==> " & sRedirect
    End If

  ' Sometimes it returns -2147463160 when the virtual drectory already exists
  Else
    If Err.Number <> -2147463160 Then
      If CheckErrors("getting virtual directory " & sName) Then Exit Function
    End If
    err.Clear

    WriteLog "     Virtual Directory " & sName & " already exists"
  End If

  Set oDir = Nothing

  CreateVirtualDir = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Create an application pool
'*******************************************************************************
Function CreateAppPool (sName, nIDType) 'nIDType: 0=LocalSystem, 2=NetworkService 3=IWAM user
  Dim oAppPools
  Dim oPool

  CreateAppPool = False
  On Error Resume Next

  If Not GetIISObject(oAppPools,"W3SVC/AppPools") Then Exit Function

  'Check to see if the application pool already exists
  Set oPool = oAppPools.GetObject("IISApplicationPool", sName)
  ' This will return error -2147024893 if it doesn't exist
  If Err.Number = -2147024893 Then
    Err.Clear
    Set oPool = oAppPools.Create("IISApplicationPool", sName)
    If CheckErrors("creating application pool " & sName) Then Exit Function

    WriteLog "     Created Application Pool " & sName

  Else
    WriteLog "     Application Pool " & sName & " already exists"
  End If

  oPool.AppPoolIdentityType          = nIDType
  oPool.PeriodicRestartMemory        = 0
  oPool.PeriodicRestartPrivateMemory = 0
  oPool.PeriodicRestartRequests      = 0
  oPool.PeriodicRestartSchedule      = ""
  oPool.PeriodicRestartTime          = 0
  oPool.IdleTimeout                  = 0
  oPool.SetInfo
  If CheckErrors("setting application pool parameters") Then Exit Function

  CreateAppPool = True
End Function
'*******************************************************************************


'*******************************************************************************
Function CreateFolder (ByRef sPath, sFolder)
  Dim oIis
  Dim oNewIis
  Dim sNewPath

  CreateFolder = False
  On Error Resume Next

  sNewPath = sPath & "/" & sFolder

  'Check if folder already exists
  Set oIis = GetObject(sNewPath)
  ' This will return error -2147024893 if it doesn't exist
  If Err.Number = -2147024893 Then
    err.Clear
    Set oIis = GetObject(sPath)
    If CheckErrors("getting object " & sPath) Then Exit Function

    Set oNewIis = oIis.Create ("IisWebDirectory", sFolder)
    oNewIis.SetInfo
    If CheckErrors("creating folder " & sFolder ) Then Exit Function

    WriteLog "     Created Web Folder        " & sNewPath

  Else
    If Err.Number <> -2147463160 Then
      If CheckErrors("getting web folder " & sNewPath) Then Exit Function
    End If
    err.Clear

    WriteLog "     Web Folder " & sNewPath & " already exists"
  End If

  sPath = sNewPath
  CreateFolder = True

End Function
'*******************************************************************************


'*******************************************************************************
Function CreateApplication (sPath, sAppName)
  Dim oIis

  CreateApplication = False
  On Error Resume Next

  Set oIis = GetObject(sPath)
  If CheckErrors("getting object " & sPath ) Then Exit Function

  oIis.AppFriendlyName = sAppName
  oIis.AppCreate False
  oIis.SetInfo
  If CheckErrors("creating application " & sAppName ) Then Exit Function

  WriteLog "     Created Application       " & sPath

  CreateApplication = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Delete Virtual Directory
'*******************************************************************************
Function DeleteVirtualDir (sName)
  Dim oDir

  DeleteVirtualDir = False
  On Error Resume Next

  Set oDir = goIISRoot.GetObject("IisWebVirtualDir", sName)
  If Err.Number = -2147024893 Then
    'if the virtual directory does not exist, don't try to remove it
    Writelog "     Virtual Directory " & sName & " does not exist, continuing"
    Err.Clear

  Else
    'FIXME why does this error code get returned sometimes and why is it OK?
    If Err.Number <> -2147463160 Then
      If CheckErrors("getting virtual directory object") Then Exit Function
    End If
    Err.Clear

    goIISRoot.delete "IisWebVirtualDir", sName
    If CheckErrors("deleting virtual directory " & sName) Then Exit Function

    goIISRoot.SetInfo
    If CheckErrors("setting info on IIS object") Then Exit Function

    If Not RemoveCOMPlusApp("IIS-{Default Web Site//Root/" & sName & "}") Then Exit Function

    Writelog "     Deleted Virtual Directory " & sName
  End If

  DeleteVirtualDir = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Delete Application Pool
'*******************************************************************************
Function DeleteAppPool (sName)
  Dim oAppPools
  Dim oPool

  DeleteAppPool = False
  On Error Resume Next

  If Not GetIISObject(oAppPools,"W3SVC/AppPools") Then Exit Function

  Set oPool = oAppPools.GetObject("IISApplicationPool",sName)
  If Err.Number = -2147024893 Then
    'if the virtual directory does not exist, don't try to remove it
    Writelog "     Application Pool " & sName & " does not exist, continuing"
    Err.Clear

  Else
    'FIXME why does this error code get returned sometimes and why is it OK?
    If Err.Number <> -2147463160 Then
      If CheckErrors("getting application pool object") Then Exit Function
    End If
    Err.Clear

    oAppPools.delete "IISApplicationPool", sName
    oAppPools.SetInfo
    If CheckErrors("deleting application pool " & sName) Then Exit Function

    Writelog "     Deleted Application Pool " & sName
  End If

  DeleteAppPool = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Install Web Service Extensions
'*******************************************************************************
'Test
'GetIISObject goIISRoot, "W3SVC/1/Root"
'InstallWebServiceExtensions
Function InstallWebServiceExtensions()
  InstallWebServiceExtensions = False
  On Error Resume Next

  WriteLog "     Installing Web Service Extensions..."

  goIISRoot.AspEnableParentPaths       = 1
  goIISRoot.AspMaxRequestEntityAllowed = 4194304
  goIISRoot.SetInfo
  If CheckErrors("configuring IIS Root parameters") Then Exit Function

  Dim oW3s
  If Not GetIISObject(oW3s,"W3SVC") Then Exit Function

  ' Disable IIS5 compatibility mode
  oW3s.IIs5IsolationModeEnabled = 0
  oW3s.SetInfo
  If CheckErrors("disabling IIS5 process isolation mode") Then Exit Function

  Dim aWebSvcExts
  aWebSvcExts = oW3s.WebSvcExtRestrictionList
  If CheckErrors("getting web service extension restriction list") Then Exit Function

  Dim sWinDir
  Dim sDotNetPath
  Dim sListenerPath
  Dim sGzipPath
  Dim sASPPath
  Dim sASPNetPath
  Dim sASPNetVersion
  Dim bListenerFound
  Dim bGzipFound
  Dim bASPFound
  Dim bASPNetFound

  If Not GetDotNetPath(sDotNetPath) Then Exit Function

  sWinDir        = goEnv("WINDIR")
  sGzipPath      = MakePath(sWinDir, "system32\inetsrv\gzip.dll")
  sListenerPath  = MakeBinPath("listener.dll")
  sASPPath       = MakePath(sWinDir, "system32\inetsrv\asp.dll")
  sASPNetPath    = MakePath(sDotNetPath, "aspnet_isapi.dll")
  sASPNetVersion = BaseName(sDotNetPath)

  bListenerFound = False
  bGzipFound     = False
  bASPFound      = False
  bASPNetFound   = False

  Dim sLine
  Dim bUpdateList
  bUpdateList = False

  Dim i
  For i = 0 To UBound(aWebSvcExts)
    Dim bUpdate
    Dim aFields
    bUpdate = False
    aFields = Split(aWebSvcExts(i),",")

    If UBound(aFields) >= 4 Then
      If aFields(4) = "Active Server Pages" Then
        bASPFound = True
        If aFields(0) = "0" Or LCase(aFields(1)) <> LCase(sASPPath) Then
          aFields(0) = "1"
          aFields(1) = sASPPath
          aFields(2) = "0"
          aFields(3) = "ASP"
          bUpdate = True
        End If

      Elseif aFields(4) = "HTTP Compression" Then
        bGzipFound = True
        If aFields(0) = "0" Or LCase(aFields(1)) <> LCase(sGzipPath) Then
          aFields(0) = "1"
          aFields(1) = sGzipPath
          aFields(2) = "1"
          bUpdate = True
        End If

      Elseif aFields(4) = "MetraNet Listener" Then
        bListenerFound = True
        If aFields(0) = "0" Or LCase(aFields(1)) <> LCase(sListenerPath) Then
          aFields(0) = "1"
          aFields(1) = sListenerPath
          aFields(2) = "1"
          bUpdate = True
        End If

      Elseif UCase(aFields(4)) = UCase("ASP.NET " & sASPNetVersion) Then
        bASPNetFound = True
        If aFields(0) = "0" Then
          aFields(0) = "1"
          bUpdate = True
        End If
      End If
    End If

    If bUpdate Then
      Dim iField
      sLine = aFields(0)
      For iField = 1 to UBound(aFields)
        sLine = sLine & "," & aFields(iField)
      Next
      aWebSvcExts(i) = sLine
      WriteLog "     Updating Web Service Extension: " & sLine
      bUpdateList = True
    End If
  Next

  If Not bASPFound Then
    Redim Preserve aWebSvcExts(UBound(aWebSvcExts)+1)
    sLine = "1," & sASPPath & ",0,ASP,Active Server Pages"
    aWebSvcExts(UBound(aWebSvcExts)) = sLine
    WriteLog "     Adding Web Service Extension: " & sLine
    bUpdateList = True
  End If

  If Not bASPNetFound Then
    Redim Preserve aWebSvcExts(UBound(aWebSvcExts)+1)
    sLine = "1," & sASPNetPath & ",0,ASP.NET " & sASPNetVersion & ",ASP.NET " & sASPNetVersion
    aWebSvcExts(UBound(aWebSvcExts)) = sLine
    WriteLog "     Adding Web Service Extension: " & sLine
    bUpdateList = True
  End If

  If Not bGzipFound Then
    Redim Preserve aWebSvcExts(UBound(aWebSvcExts)+1)
    sLine = "1," & sGzipPath & ",1,,HTTP Compression"
    aWebSvcExts(UBound(aWebSvcExts)) = sLine
    WriteLog "     Adding Web Service Extension: " & sLine
    bUpdateList = True
  End If

  If Not bListenerFound Then
    Redim Preserve aWebSvcExts(UBound(aWebSvcExts)+1)
    sLine = "1," & sListenerPath & ",1,,MetraNet Listener"
    aWebSvcExts(UBound(aWebSvcExts)) = sLine
    WriteLog "     Adding Web Service Extension: " & sLine
    bUpdateList = True
  End If

  If bUpdateList Then
    WriteLog "     Synchronizing with metabase"
    oW3s.WebSvcExtRestrictionList = aWebSvcExts
    oW3s.SetInfo
    If CheckErrors("updating web service extension restriction list`") Then Exit Function
  Else
    WriteLog "     No changes required"
  End If

  InstallWebServiceExtensions = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** UpdateASPNETVersion
'Test
'UpdateASPNETVersion()
'*******************************************************************************
Function UpdateASPNETVersion()
  Dim sDotNetPath
  Dim oW3s
  Dim asScriptMaps
  Dim bFoundValidPath
  Dim bFoundInvalidPath
  Dim i

  UpdateASPNETVersion = False

  On Error Resume Next

  If Not GetDotNetPath(sDotNetPath) Then Exit Function

  bFoundValidPath = False
  bFoundInvalidPath = False

  'Not sure how to reliably determine whether we need to install ASP.NET 2.0 so, for now do it every time 

'  WriteLog "     Checking IIS/ASP.NET version..."

'  If Not GetIISObject(oW3s,"W3SVC") Then Exit Function

'  asScriptMaps = oW3s.ScriptMaps
'  If CheckErrors("getting script maps") Then Exit Function

'  For i = 0 To UBound(asScriptMaps)
'    Dim asFields
'    Dim sDirPath
'    asFields = Split(asScriptMaps(i),",")
'    sDirPath = DirName(asFields(1))
'    If IsADotNetPath(sDirPath) Then
'      If sDirPath = sDotNetPath Then
'        bFoundValidPath = True
'      Else
'        bFoundInvalidPath = True
'      End If
'    End If
'  Next

  If bFoundInvalidPath Or Not bFoundValidPath Then
    WriteLog "     Installing ASP.NET" 
    If Not ExecuteCommand(sDotNetPath & "\aspnet_regiis.exe -i") Then Exit Function 

  Else
    WriteLog "     Correct version of ASP.NET (" & sDotNetPath & ") appears to be installed, no change necessary" 
  End If

  UpdateASPNETVersion = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Remove Web Service Extensions
'*******************************************************************************
Function RemoveWebServiceExtensions()
  Dim oW3s
  Dim aWebSvcExts

  RemoveWebServiceExtensions = False
  On Error Resume Next

  WriteLog "     Removing Web Service Extensions..."

  If Not GetIISObject(oW3s,"W3SVC") Then Exit Function

  aWebSvcExts = oW3s.WebSvcExtRestrictionList
  If CheckErrors("getting web service extension restriction list") Then Exit Function

  Dim i
  Dim iFound

  For i = 0 To UBound(aWebSvcExts)
    Dim aFields
    aFields = Split(aWebSvcExts(i),",")

    If UBound(aFields) >= 4 Then
      If aFields(4) = "MetraNet Listener" Or aFields(4) = "MetraTech Listener" Then
        iFound = i
        Exit For
      End If
    End If
  Next

  If Not IsEmpty(iFound) Then 
    WriteLog "     Removing MetraNet Listener Web Service Extension"
    For i = iFound To UBound(aWebSvcExts)-1
      aWebSvcExts(i) = aWebSvcExts(i+1)
    Next
    Redim Preserve aWebSvcExts(UBound(aWebSvcExts)-1)

    WriteLog "     Synchronizing with metabase"
    oW3s.WebSvcExtRestrictionList = aWebSvcExts
    oW3s.SetInfo
    If CheckErrors("updating web service extension restriction list`") Then Exit Function

  Else
    WriteLog "     MetraNet Listener Web Service Extension not found; nothing to do!"
  End If

  RemoveWebServiceExtensions = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Enable zip compression for the hierarchy control (IIS 6 only)
'*******************************************************************************
Function EnableGzipCompression()
  Dim asCommands
  Dim sAdsutil
  
  EnableGzipCompression = true
  exit function
   
  EnableGzipCompression = True
  exit function
  
  EnableGzipCompression = False
  On Error Resume Next

  WriteLog "     Enabling Gzip Compression..."

  Dim oCompDeflate
  If Not GetIISObject(oCompDeflate,"W3SVC/Filters/Compression/DEFLATE") Then Exit Function
  oCompDeflate.HcCompressionDll          = goEnv("WINDIR") & "\system32\inetsrv\gzip.dll"
  oCompDeflate.HcCreateFlags             = 0
  oCompDeflate.HcDoDynamicCompression    = 1
  oCompDeflate.HcDoOnDemandCompression   = 1
  oCompDeflate.HcDoStaticCompression     = 1
  oCompDeflate.HcDynamicCompressionLevel = 9
  oCompDeflate.HcFileExtensions          = Array("htm","html","txt","js","xml","css")
  oCompDeflate.HcOnDemandCompLevel       = 9
  oCompDeflate.HcPriority                = 1
  oCompDeflate.HcScriptFileExtensions    = Array("asp","aspx","asmx")
  oCompDeflate.SetInfo
  If CheckErrors("updating Filters/Compression/DEFLATE object") Then Exit Function
  Set oCompDeflate = Nothing

  Dim oCompGzip
  If Not GetIISObject(oCompGzip,"W3SVC/Filters/Compression/GZIP") Then Exit Function
  oCompGzip.HcCompressionDll          = goEnv("WINDIR") & "\system32\inetsrv\gzip.dll"
  oCompGzip.HcCreateFlags             = 1
  oCompGzip.HcDoDynamicCompression    = 1
  oCompGzip.HcDoOnDemandCompression   = 1
  oCompGzip.HcDoStaticCompression     = 1
  oCompGzip.HcDynamicCompressionLevel = 9
  oCompGzip.HcFileExtensions          = Array("htm","html","txt","js","xml","css")
  oCompGzip.HcOnDemandCompLevel       = 9
  oCompGzip.HcPriority                = 1
  oCompGzip.HcScriptFileExtensions    = Array("asp","aspx","asmx")
  oCompGzip.SetInfo
  If CheckErrors("updating Filters/Compression/GZIP object") Then Exit Function
  Set oCompGzip = Nothing

  Dim oCompParams
  If Not GetIISObject(oCompParams,"W3SVC/Filters/Compression/Parameters") Then Exit Function
  oCompParams.HcCacheControlHeader      = "max-age=86400"
  oCompParams.HcCompressionBufferSize   = 102400
  oCompParams.HcCompressionDirectory    = goEnv("WINDIR") & "\IIS Temporary Compressed Files"
  oCompParams.HcDoDiskSpaceLimiting     = 0
  oCompParams.HcDoDynamicCompression    = 0
  oCompParams.HcDoOnDemandCompression   = 1
  oCompParams.HcDoStaticCompression     = 0
  oCompParams.HcExpiresHeader           = "Wed, 01 Jan 1997 12:00:00 GMT"
  oCompParams.HcFilesDeletedPerDiskFree = 256
  oCompParams.HcIoBufferSize            = 102400
  oCompParams.HcMaxDiskSpaceUsage       = 0
  oCompParams.HcMaxQueueLength          = 1000
  oCompParams.HcMinFileSizeForComp      = 1
  oCompParams.HcNoCompressionForHttp10  = 0
  oCompParams.HcNoCompressionForProxies = 0
  oCompParams.HcNoCompressionForRange   = 0
  oCompParams.HcSendCacheHeaders        = 0
  oCompParams.SetInfo
  If CheckErrors("updating Filters/Compression/Parameters object") Then Exit Function
  Set oCompParams = Nothing

  EnableGzipCompression = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Add script mappings for ImageHandler virt dir
'*******************************************************************************
Function AddImgHdlrScriptMaps(oDir)
  Dim sDotNetPath

  AddImgHdlrScriptMaps = False
  On Error Resume Next

  WriteLog "     Setting script maps for ImageHandler virtual directory"

  If Not GetDotNetPath(sDotNetPath) Then Exit Function

  oDir.ScriptMaps = array(".asax," & sDotNetPath & "\aspnet_isapi.dll,5,GET,HEAD,POST,DEBUG", _
                          ".aspx," & sDotNetPath & "\aspnet_isapi.dll,5,GET,HEAD,POST,DEBUG", _
                          ".resx," & sDotNetPath & "\aspnet_isapi.dll,5,GET,HEAD,POST,DEBUG", _
                          ".gif,"  & sDotNetPath & "\aspnet_isapi.dll,1") 'Uncheck "Verify File Exists"
  oDir.SetInfo

  If CheckErrors("setting script maps") Then Exit Function
  
  AddImgHdlrScriptMaps = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Return true if feature is to be installed based on custom data string
'*******************************************************************************
Function IsIISFeatureSelected(sFeature,sFeatures)
  Dim sSelectedUC
  Dim sFeatureUC

  IsIISFeatureSelected = False
  On Error Resume Next

  sSelectedUC = "," & UCase(Replace(sFeatures," ","")) & ","
  sFeatureUC = "," & UCase(Replace(sFeature," ","")) & ","

  If InStr(sSelectedUC, sFeatureUC) > 0 or InStr(sSelectedUC, ",ALL,") > 0 Then
    IsIISFeatureSelected = True
  End If
End Function
'*******************************************************************************
