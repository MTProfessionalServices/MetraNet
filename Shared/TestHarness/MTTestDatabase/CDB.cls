VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CDB"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit


Public Connection, DefaultTimeOut, Command

Public Server, Database, Login, PassWord, ConnectionString

Public TraceOn

Private m_booOpened

Private Function IsW3RunnerRunning()
   IsW3RunnerRunning = False
   
End Function

Private Function TRACE(s)

  If TraceOn Then
      If IsW3RunnerRunning() Then
          'W3Runner.TRACE s
      Else
          'Test.TRACE s
      End If
  End If
End Function

Private Function TRACEERROR(s)
  If IsW3RunnerRunning() Then
          'W3Runner.TRACE s, w3rERROR
      Else
          'Test.TRACE "[ERROR]" & s
      End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : OpenDB
' PARAMETERS  :
' DESCRIPTION  : Open the database connection according the parameters Server, Database
'         Login and PassWord or according the parameter ConnectionString
' RETURNS    :
Public Function OpenDB()

  TRACE GetConnectionString()

  Set Connection = CreateObject("ADODB.Connection")
  Connection.Open GetConnectionString()
  m_booOpened = True
  OpenDB = True
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : CloseDB
' PARAMETERS  :
' DESCRIPTION  : Close the database connection.
' RETURNS    :
Public Function CloseDB()
  If (m_booOpened) Then
    Connection.Close
    m_booOpened = False
  End If
  Set Connection = Nothing
  Set Command = Nothing
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : GetConnectionString
' PARAMETERS  :
' DESCRIPTION  : Returns the connection string.
' RETURNS    :
Public Function GetConnectionString()

  If (Len(ConnectionString)) Then
    GetConnectionString = ConnectionString
  Else
    GetConnectionString = "driver={SQL Server};" & "server=" & Server & ";" & "uid=" & Login & ";" & "pwd=" & PassWord & ";" & "database=" & Database & ";"
  End If
End Function

Private Sub Class_Initialize()
  Server = "."                            ' Current machine
  DefaultTimeOut = 30
  m_booOpened = False
  TraceOn = False
End Sub

Private Sub Class_Terminate()
  CloseDB
End Sub

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : NewRecordset
' PARAMETERS  :
' DESCRIPTION  : Returns a new instance of an ADO Recordset
' RETURNS    :
Public Function NewRecordset()
  Set NewRecordset = CreateObject("ADODB.Recordset")
End Function

Private Function SetRecordsetPropertiesAsDeconnected(r) ' As Boolean

  r.CursorLocation = adUseClient
  r.CursorType = adOpenStatic
  r.LockType = adLockReadOnly
  SetRecordsetPropertiesAsDeconnected = True
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : SqlRun
' PARAMETERS  :
' DESCRIPTION  : Execute the SQL query strSQL. If the query does not return an recordset the parameter OptionalRecordset
'         must be set to Empty else it must contains a valid ADO Recordset.
' RETURNS    : The function returns TRUE if the query succeed else FALSE.
Public Function SqlRun(strSQL, OptionalRecordSet) ' As Variant

  SqlRun = False

  TRACE strSQL

  Connection.CommandTimeout = DefaultTimeOut

  If Not IsEmpty(OptionalRecordSet) Then

    SetRecordsetPropertiesAsDeconnected OptionalRecordSet
    On Error Resume Next
    OptionalRecordSet.Open strSQL, Connection, OptionalRecordSet.CursorType, OptionalRecordSet.LockType
    If (Err.Number) Then
      If Err.Number Then TRACEERROR "SQL RUNTIME ERROR:" & Err.Number & " " & Err.Description & " " & Err.Source
      Set SqlRun = Nothing ' The Error is not cleared and therefore the caller can use it.
    Else
      'Set Rst.ActiveConnection = Nothing
      Set SqlRun = OptionalRecordSet
    End If
  Else
    Set Command = CreateObject("ADODB.Command") ' Init the ado command object
    Set Command.ActiveConnection = Connection
    Command.CommandTimeout = DefaultTimeOut

    Command.CommandType = adCmdText
    Command.CommandText = strSQL
    On Error Resume Next
    Command.Execute
    SqlRun = CBool(Err.Number = 0) ' The Error is not cleared and therefore the caller can use it.
    If Err.Number Then MsgBox "SQL RUNTIME ERROR:" & Err.Number & " " & Err.Description & " " & Err.Source & vbNewLine & "SQL:" & strSQL, vbCritical

  End If
End Function

Public Function SqlRunFile(strFileName, PreProcessArray) ' As Variant
'
'  Dim strSQL, arrSQLs, i
'
'  SqlRunFile = False
'
'  Dim t As New cTextFile
'
'  strSQL = t.LoadFile(strFileName)
'  strSQL = PreProcess(strSQL, PreProcessArray)
'  arrSQLs = Split(strSQL, "GO" & vbNewLine)
'  i = 1
'
'  For Each strSQL In arrSQLs
'
'      If Test.FAILED(PremiereQA.MeteringDB.SqlRun(strSQL, Empty), "SqlRunFile:Part(" & i & ")") Then Exit Function
'      i = i + 1
'  Next
'  SqlRunFile = True
End Function

