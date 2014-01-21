'*******************************************************************************
'* Copyright 2003 by MetraTech Corporation
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
'* Name:        BillingServer.vbs
'* Created By:  Noah Cushing
'* Description: Contains functions to install and uninstall the billing server
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
Const SERVICE_NAME = "BillingServer"

'*** Main
Function Main
  'Command line invocation

  If Not SetCustomActionData("") Then Exit Function

  WriteLog ">>>> Uninstalling BillingServer Service..."
  If UninstallBillingServer() <> kRetVal_SUCCESS Then Exit Function
  
  WriteLog ">>>> Installing BillingServer Service..."
  If InstallBillingServer() <> kRetVal_SUCCESS Then Exit Function

  WriteLog "<<<< BillingServer Service Successfully Installed!"
End Function
'*******************************************************************************


'*******************************************************************************
'*** Install BillingServer service
'*******************************************************************************
Function InstallBillingServer()
  Dim bInstalled

  InstallBillingServer = kRetVal_ABORT
  On Error Resume Next

  EnterAction "InstallBillingServer"
  
  If Not InitializeArguments() Then Exit Function

  If Not CheckServiceInstalled (bInstalled, SERVICE_NAME) Then Exit Function

  If bInstalled Then
    WriteLog "     " & SERVICE_NAME & " already installed, attempting to remove"
    If Not InstallBillingServerService (False) Then Exit Function
  End If

  If Not InstallBillingServerService (True) Then Exit Function

  ExitAction "InstallBillingServer"

  InstallBillingServer = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Uninstall BillingServer service
'*******************************************************************************
Function UninstallBillingServer()
  Dim bInstalled

  UninstallBillingServer = kRetVal_ABORT
  On Error Resume Next

  EnterAction "UninstallBillingServer"
  
  If Not InitializeArguments() Then Exit Function

  If Not CheckServiceInstalled (bInstalled, SERVICE_NAME) Then Exit Function

  If Not bInstalled Then
    WriteLog "     " & SERVICE_NAME & " service not found, nothing to remove"

  Else
    If Not InstallBillingServerService (False) Then Exit Function
  End If

  ExitAction "UninstallBillingServer"

  UninstallBillingServer = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Install or uninstall billingserver service
'*******************************************************************************

Function InstallBillingServerService(bInstall)
  Dim sCommand
  Dim sOptions
  Dim sVerbed
  Dim sVerbing
  Dim sDotNetPath
  Dim sLogFile

  InstallBillingServerService = false
  On Error Resume Next

  if ( bInstall ) then
    sOptions = ""
    sVerbed = "installed"
    sVerbing = "installing"
  else
    sOptions = "/U "
    sVerbed = "uninstalled"
    sVerbing = "uninstalling"
  end if

  If Not GetDotNetPath(sDotNetPath) Then Exit Function

  'Prepare command string
  sCommand = MakePath(sDotNetPath, "installutil.exe " & sOptions & MakeBinPath("MTservices.exe"))

  sLogFile = MakeBinPath("MTServices.InstallLog")

  'Execute the command
  If Not ExecuteCommand(sCommand) Then
    If goFso.FileExists(sLogFile) Then
      AppendFileToLog(sLogFile)
    End If
    WriteLog "<*** Error " & sVerbing & " MTServices.exe"
    Exit Function
  End If

  If Not DeleteFile(sLogFile) Then Exit Function

  WriteLog "     " & SERVICE_NAME & " Service successfully " & sVerbed
  
  InstallBillingServerService = True
End Function
'*******************************************************************************
