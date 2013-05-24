Option Explicit

Sub MTMsg(strMsg)
  WScript.Echo strMsg ' Informational Message
End Sub

Sub MTErr(strMsg)
  WScript.Echo "[Error] " & strMsg ' Error Message
End Sub

'*******************************************************************************
'*** Include file processing (simplified version -- do not change)
'*******************************************************************************
Function MTInclude(strFile)
  MTInclude = False
  Dim objFso, objFile
  Set objFso  = CreateObject("Scripting.FileSystemObject")
  If objFso.FileExists(strFile) Then
    Set objFile = objFso.OpenTextFile(strFile)
    On Error Resume Next
    ExecuteGlobal objFile.ReadAll()
    If Err.Number <> 0 Then
      MTErr "Processing Include file : '" & strFile & "'"
      MTErr Err.Number & " " & Err.Description
    End If
    On Error GoTo 0
    MTInclude = True
    objFile.Close
    Set objFile = Nothing
  Else
    MTErr "Include file missing : '" & strFile & "'"
  End If
  Set objFso  = Nothing
End Function

'*******************************************************************************
'*** Main processing
'*******************************************************************************
WScript.Quit( Main() )
'*******************************************************************************

Function Main()
  Main = -1
  If Not MTInclude(".\Common.vbs") Then
    Exit Function
  End If

  Const strBBxServiceName = "BBxService"
  Const strServiceStateStopped = "Stopped"
  Const strTEMP = "TEMP"
  Dim bOK

  ' Retrieve Arguments
  Dim objArgs
  Dim strOption, strServiceStateRequired
  Set objArgs = WScript.Arguments
  If objArgs.Count = 1 Then
    strOption = UCase(objArgs(0))
  End If
  Set objArgs = Nothing

  ' Validate Arguments
  Select Case strOption
    Case "LIST"    strServiceStateRequired = ""
    Case "DELETE"  strServiceStateRequired = strServiceStateStopped
    Case Else
      MTErr "Expected a valid Option argument : " & strOption
      Exit Function
  End Select

  Dim strServiceState, nServicePID
  If Not MTGetServiceState(strBBxServiceName, strServiceState, nServicePID) Then
    MTErr "Cannot access service : "  & strBBxServiceName
    Exit Function
  End If

  If strServiceStateRequired = "" Then
    MTMsg strBBxServiceName & " state  = " & strServiceState
  ElseIf strServiceState <> strServiceStateRequired Then
    MTErr "Service " & strBBxServiceName & " must be in a " & _
           strServiceStateRequired & " state"
    MTErr strBBxServiceName & " state  = " & strServiceState
    Exit Function
  End If

  ' Build the path to where the session files live
  Dim strTEMPValue, strComputerName, strSessionPath
  bOK = MTGetSystemEnviromentVariable(strTEMP, strTEMPValue)
  bOK = MTGetComputerName(strComputerName)
  bOK = MTGetExpandedPath(strTEMPValue & "\" & strComputerName, strSessionPath)
  MTMsg "System TEMP Value = " & strTEMPValue
  MTMsg "ComputerName      = " & strComputerName
  MTMsg "Session File Path = " & strSessionPath
  MTMsg "Option selected   = " & strOption
  MTMsg ""

  ' Build Where Clause for CIM_DataFile and Win32_Directory
  Dim strWhere
  bOK = MTGetFolderWhereClause(strSessionPath, strWhere)

  ' Process all the session files
  Dim objWMIService, colVar, objVar
  Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

  ' Process all the files first
  Set colVar = objWMIService.ExecQuery _
      ("Select * from CIM_DataFile" & strWhere )
  For Each objVar in colVar
    Select Case strOption
      Case "LIST"
        MTMsg "Listing  File.....: " & objVar.Name
      Case "DELETE"
        MTMsg "Deleting File.....: " & objVar.Name
        objVar.Delete()
    End Select
  Next

  ' Process all the folders
  Set colVar = objWMIService.ExecQuery _
      ("Select * from Win32_Directory" & strWhere )
  For Each objVar in colVar
    Select Case strOption
      Case "LIST"
        MTMsg "Listing  Folder...: " & objVar.Name
      Case "DELETE"
        MTMsg "Deleting Folder...: " & objVar.Name
        objVar.Delete()
    End Select
  Next

  Main = 0

  ' Cleanup
  Set objVar = Nothing
  Set colVar = Nothing
  Set objWMIService = Nothing

  ' Returning 0 indicates that BBxService was in the appropriate state
  ' and any existing files and folders were processed.
End Function

