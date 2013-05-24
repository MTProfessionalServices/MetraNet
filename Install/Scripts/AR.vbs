'******************************************************************************************
'*
'* Copyright 2003-2005 by MetraTech Corporation
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
'* Name:        AR.vbs
'* Created By:  Alon Zeev Becker / Simon Morton
'* Description: AR Installation functions
'*
'******************************************************************************************

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

'*** Main
Function Main
  WriteLog ">>>> Uninstalling Great Plains..."
  If Not SetCustomActionData ("") Then Exit Function
  If UninstallGreatPlains() <> kRetVal_SUCCESS Then Exit Function

  WriteLog ">>>> Installing Great Plains..."
  If Not SetCustomActionData ("gpserver;gpdatabase;gpuser;gppassword") Then Exit Function
  If InstallGreatPlains() <> kRetVal_SUCCESS Then Exit Function

  WriteLog "<<<< Great Plains Successfully Installed."
End Function

'*******************************************************************************
Function InstallGreatPlains()
  Dim sCmd
  Dim sGPServerName
  Dim sGPDBName
  Dim sGPAdminUser
  Dim sGPPassword
    
  InstallGreatPlains = kRetVal_ABORT
  On Error Resume Next

  WriteLog "===> Entering InstallGreatPlains()"

  If Not InitializeArguments() Then Exit Function

  If Not GetArgument (sGPServerName, 2, True)  Then Exit Function
  If Not GetArgument (sGPDBName,     3, True)  Then Exit Function
  If Not GetArgument (sGPAdminUser,  4, True)  Then Exit Function
  If Not GetArgument (sGPPassword,   5, False) Then Exit Function

  WriteLog "     Installing Great Plains Server"

  sCmd = MakeBinPath("ARSetup.exe -E -GPServerName " & sGPServerName & " -GPDatabaseName " & sGPDBName & _
                                   " -GPUserName "   & sGPAdminUser  & " -GPPassword """   & sGPPassword & """")
  If Not ExecuteCommand(sCmd) Then Exit Function
                                                                                     
  WriteLog "<=== Exiting InstallGreatPlains()"

  InstallGreatPlains = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
Function UninstallGreatPlains()
  UninstallGreatPlains = kRetVal_ABORT
  On Error Resume Next

  WriteLog "===> Entering UninstallGreatPlains()"

  If Not InitializeArguments() Then Exit Function

  WriteLog "     Uninstalling Great Plains Server"

  If Not ExecuteCommand(MakeBinPath("ARSetup.exe -D")) Then Exit Function

  WriteLog "<=== Exiting UninstallGreatPlains()"

  UninstallGreatPlains = kRetVal_SUCCESS
End Function
'*******************************************************************************
