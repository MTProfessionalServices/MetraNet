'*******************************************************************************
'*** MTGetServiceState
'*******************************************************************************
Function MTGetServiceState(strServiceName, ByRef strServiceState, ByRef nServicePID)
  MTGetServiceState = False
  Dim objWMIService, objService
  Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

  ' The service may not be installed
  On Error Resume Next
  Set objService = _
      objWMIService.Get("Win32_Service.Name='" & strServiceName & "'")
  If Err.Number = 0 Then
    strServiceState = objService.State
    nServicePID = objService.ProcessId
    MTGetServiceState = True
  End If
  On Error GoTo 0

  Set objService = Nothing
  Set objWMIService = Nothing
End Function

'*******************************************************************************
'*** MTGetSystemEnviromentVariable
'*******************************************************************************
Function MTGetSystemEnviromentVariable(strName, ByRef strValue)
  MTGetSystemEnviromentVariable = False
  Dim objWMIService, colVar, objVar
  Dim strWhere
  Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

  ' Get the System Environment Variable
  strWhere = " WHERE SystemVariable = 'True' and Name = '" & strName & "' "
  Set colVar = objWMIService.ExecQuery( _
      "Select * from Win32_Environment" & strWhere )
  For Each objVar in colVar
    strValue = objVar.VariableValue
    MTGetSystemEnviromentVariable = True
  Next

  Set objVar = Nothing
  Set colVar = Nothing
  Set objWMIService = Nothing
End Function

'*******************************************************************************
'*** MTGetExpandedPath
'*******************************************************************************
Function MTGetExpandedPath(strPath, ByRef strExpandedPath)
  MTGetExpandedPath = False
  Dim objShell
  Set objShell = WScript.CreateObject("WScript.Shell")
  strExpandedPath = objShell.ExpandEnvironmentStrings(strPath)
  MTGetExpandedPath = True
  Set objShell = Nothing
End Function


'*******************************************************************************
'*** MTGetComputerName
'*******************************************************************************
Function MTGetComputerName(ByRef strComputerName)
  MTGetComputerName = False
  Dim objWMIService, colVar, objVar

  Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
  Set colVar = objWMIService.ExecQuery( _
      "Select * from Win32_ComputerSystem" )
  For Each objVar in colVar
    strComputerName = objVar.Name
    MTGetComputerName = True
  Next

  Set objVar = Nothing
  Set colVar = Nothing
  Set objWMIService = Nothing
End Function

'*******************************************************************************
'*** MTGetFolderWhereClause
'*******************************************************************************
Function MTGetFolderWhereClause(strPath, ByRef strWhere)
  MTGetFolderWhereClause = False
  Dim strDriveVal, strPathVal
  If (Len(strPath) >= 3) And (Mid(strPath,2,1) = ":") Then
    If Mid(strPath,Len(strPath),1) <> "\" Then
      strPath = strPath & "\"
    End If
    strDriveVal = LCase(Mid(strPath,1,2))
    strPathVal  = LCase(Replace(Mid(strPath,3),"\","\\"))
    strWhere = " WHERE Drive = '" & strDriveVal & "' AND Path = '" & strPathVal & "' "
    MTGetFolderWhereClause = True
  End If
End Function

'*******************************************************************************
'*** MTTestCommon
'*******************************************************************************
Sub MTTestCommon()
  Dim bSuccess
  Dim strServiceName, strServiceState, nServicePID
  Dim strName, strValue
  Dim strPath, strExpandedPath
  Dim strComputerName
  Dim strWhere
  strServiceName = "MSDTC"
  bSuccess = MTGetServiceState(strServiceName, strServiceState, nServicePID)
  strName = "TEMP"
  bSuccess = MTGetSystemEnviromentVariable(strName, strValue)
  strPath = strValue
  bSuccess = MTGetExpandedPath(strPath, strExpandedPath)
  bSuccess = MTGetComputerName(strComputerName)
  bSuccess = MTGetFolderWhereClause(strExpandedPath, strWhere)
End Sub


REM Uncomment to test this Include file
REM MTTestCommon()