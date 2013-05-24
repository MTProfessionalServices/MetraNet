'******************************************************************************************
'*
'* Copyright 2006 by MetraTech Corp.
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
'* Name:        Registry.vbs
'* Created By:  Simon Morton
'* Description: Registry configuration functions
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

'*** Constants
Const HKLM                = &H80000002
Const REG_MT_ROOT         = "SOFTWARE\MetraTech"
Const REG_MT_METRANET     = "SOFTWARE\MetraTech\MetraNet"
Const REG_MT_METRACONNECT = "SOFTWARE\MetraTech\MetraConnect"

'for backwards-compatibility
Const REG_MT_NETMETER     = "SOFTWARE\MetraTech\NetMeter"
Const REG_MT_INSTALL      = "SOFTWARE\MetraTech\install"

'*** Main
Function Main
  WriteLog ">>>> Uninstalling Registry Keys..."
  If Not SetCustomActionData ("") Then Exit Function
  If UninstallRegistryKeys() <> kRetVal_SUCCESS Then Exit Function

  WriteLog ">>>> Installing Registry Keys..."
  If Not SetCustomActionData ("6.0.1;99992006") Then Exit Function
  If InstallRegistryKeys() <> kRetVal_SUCCESS Then Exit Function

  WriteLog "<<<< Registry Keys Successfully Installed."
End Function

'*******************************************************************************
Function InstallRegistryKeys()
  Dim oReg
  Dim sVersion
  Dim sBuildNumber
 
  InstallRegistryKeys = kRetVal_ABORT
  On Error Resume Next

  EnterAction "InstallRegistryKeys"

  If Not InitializeArguments() Then Exit Function

  If Not GetArgument (sVersion,     2, True)  Then Exit Function
  If Not GetArgument (sBuildNumber, 3, True)  Then Exit Function

  WriteLog "     Installing Registry Keys..."

  'Create MetraNet key and values
  If Not AddRegistryKey   (oReg, HKLM, REG_MT_METRANET)                                             Then Exit Function
  If Not SetRegistryValue (oReg, HKLM, REG_MT_METRANET, "Version",       sVersion)                  Then Exit Function
  If Not SetRegistryValue (oReg, HKLM, REG_MT_METRANET, "Build",         sBuildNumber)              Then Exit Function
  If Not SetRegistryValue (oReg, HKLM, REG_MT_METRANET, "InstallDir",    GetRMPDir())               Then Exit Function
  If Not SetRegistryValue (oReg, HKLM, REG_MT_METRANET, "ConfigDir",     MakeRMPPath("Config"))     Then Exit Function
  If Not SetRegistryValue (oReg, HKLM, REG_MT_METRANET, "ExtensionsDir", MakeRMPPath("Extensions")) Then Exit Function

  'Create MetraConnect key and values
  If Not AddRegistryKey   (oReg, HKLM, REG_MT_METRACONNECT)                                     Then Exit Function
  If Not SetRegistryValue (oReg, HKLM, REG_MT_METRACONNECT, "Version",            sVersion)     Then Exit Function
  If Not SetRegistryValue (oReg, HKLM, REG_MT_METRACONNECT, "Build",              sBuildNumber) Then Exit Function
  If Not SetRegistryValue (oReg, HKLM, REG_MT_METRACONNECT, "DisableCompression", 0)            Then Exit Function

  'For backwards-compatibility
  WriteLog "     Installing Old-Style (pre-5.0) Registry Keys..."
  If Not AddRegistryKey   (oReg, HKLM, REG_MT_NETMETER)                                             Then Exit Function
  If Not SetRegistryValue (oReg, HKLM, REG_MT_NETMETER, "ConfigDir",     MakeRMPPath("Config"))     Then Exit Function
  If Not AddRegistryKey   (oReg, HKLM, REG_MT_INSTALL)                                              Then Exit Function
  If Not SetRegistryValue (oReg, HKLM, REG_MT_INSTALL,  "InstallDir",    GetRMPDir())               Then Exit Function

  ExitAction "InstallRegistryKeys"
  InstallRegistryKeys = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
Function UninstallRegistryKeys()
  Dim oReg
 
  UninstallRegistryKeys = kRetVal_ABORT
  On Error Resume Next

  EnterAction "UninstallRegistryKeys"

  If Not InitializeArguments() Then Exit Function

  WriteLog "     Uninstalling Registry Keys..."

  If Not DeleteRegistryKey(oReg,HKLM,REG_MT_ROOT) Then Exit Function
 
  Set oReg = Nothing

  ExitAction "UninstallRegistryKeys"
  UninstallRegistryKeys = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Get Registry Provider
'*******************************************************************************
Function GetRegProvider(ByRef oReg)
  GetRegProvider = False
  On Error Resume Next

  If IsEmpty(oReg) Then
    Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
    If CheckErrors("getting StdRegProv object") Then Exit Function
  End If

  GetRegProvider = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Add registry key
'*******************************************************************************
Function AddRegistryKey(ByRef oReg, iHive, sKey)
  AddRegistryKey = False
  On Error Resume Next

  If Not GetRegProvider(oReg) Then Exit Function

  WriteLog "     Creating key " & sKey
  If oReg.CreateKey(iHive, sKey) <> 0 Then
    WriteLog "<*** Error creating key"
    Exit Function
  End If

  AddRegistryKey = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Set registry string value
'*******************************************************************************
Function SetRegistryValue(ByRef oReg, iHive, sKey, sValueName, vValue)
  Dim iRC

  SetRegistryValue = False
  On Error Resume Next

  If Not GetRegProvider(oReg) Then Exit Function

  WriteLog "     Setting value " & MakePath(sKey,sValueName) & " to " & vValue

  If LCase(TypeName(vValue)) = "string" Then
    iRC = oReg.SetStringValue(iHive,sKey,sValueName,vValue)

  Elseif LCase(TypeName(vValue)) = "integer" Then
    iRC = oReg.SetDWORDValue(iHive,sKey,sValueName,vValue)

  Else
    WriteLog "<*** Error: invalid type: " & TypeName(vValue)
    Exit Function
  End If

  If CheckErrors("setting registry value") Then Exit Function

  If iRC <> 0 Then
    WriteLog "<*** Error setting registry value"
    Exit Function
  End If

  SetRegistryValue = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Recursively delete registry key
'*******************************************************************************
Function DeleteRegistryKey(ByRef oReg, iHive, sKey)
  Dim asSubKeys

  DeleteRegistryKey = False
  On Error Resume Next

  If Not GetRegProvider(oReg) Then Exit Function

  If oReg.EnumKey(iHive, sKey, asSubKeys) = 0 Then
    'Key exists

    If IsArray(asSubKeys) Then
      'Key has subkeys

      Dim sSubKey
      For Each sSubKey In asSubKeys
        If Not DeleteRegistryKey(oReg,iHive,MakePath(sKey,sSubKey)) Then Exit Function
      Next
    End If

    WriteLog "     Deleting key " & sKey
    If oReg.DeleteKey(iHive,sKey) <> 0 Then
      WriteLog "<*** Error deleting key"
      Exit Function
    End If

  Else
    'Key does not exist

    WriteLog "     Key " & sKey & " not found"
  End If

  DeleteRegistryKey = True
End Function
'*******************************************************************************
