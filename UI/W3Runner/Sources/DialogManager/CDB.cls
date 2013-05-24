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
Attribute VB_Exposed = False

Const adUseServer = 2
Const adUseClient = 3

Const adOpenKeyset = 1
Const adOpenStatic = 3
Const adLockReadOnly = 1
Const adLockBatchOptimistic = 4

Const adCmdText = 1


  Public Connection, DefaultTimeOut, Command

  Public Server, Database, Login, PassWord, ConnectionString, MDBFileName

  Private m_booOpened

  Private Function TRACE(s)
   ''If(IsW3RunnerRunning())Then
   '' Page.TRACE s,w3rSQL
   ''End If
   Debug.Print s
  End Function

  Public Function OpenDB() As Boolean

    TRACE GetConnectionString()
    Set Connection = CreateObject("ADODB.Connection")
    
    Connection.Open GetConnectionString()
    'Connection.open strMDBFile
    m_booOpened = True
    OpenDB = True
  End Function

  Public Function CloseDB()
    If (m_booOpened) Then
      Connection.Close
      m_booOpened = False
    End If
    Set Connection = Nothing
    Set Command = Nothing
  End Function

  Public Function GetConnectionString()

    If (Len(ConnectionString)) Then
      GetConnectionString = ConnectionString
    ElseIf Len(Me.MDBFileName) Then
        GetConnectionString = "DRIVER={Microsoft Access Driver (*.mdb)};DBQ=" & MDBFileName
    Else
      GetConnectionString = "driver={SQL Server};" & "server=" & Server & ";" & "uid=" & Login & ";" & "pwd=" & PassWord & ";" & "database=" & Database & ";"
    End If
  End Function

  Private Sub Class_Initialize()
   Server = "."     ' Current machine
   DefaultTimeOut = 30
   m_booOpened = False
  End Sub

  Private Sub Class_Terminate()
     CloseDB
  End Sub

  Public Function NewRecordset()
    Set NewRecordset = CreateObject("ADODB.Recordset")
  End Function

  Private Function SetRecordsetPropertiesAsDeconnected(r) ' As Boolean

    r.CursorLocation = adUseClient
    r.CursorType = adOpenStatic
    r.LockType = adLockReadOnly    ' adLockBatchOptimistic
    SetRecordsetPropertiesAsDeconnected = True
  End Function

  Public Function GetValue(strSQL, strColumnName) ' As Variant
   Dim objRecordset
   Set objRecordset = SqlRun(strSQL, NewRecordset())
   If (Not objRecordset Is Nothing) Then
    If (Not objRecordset.BOF) Then
      GetValue = objRecordset.fields(strColumnName).Value
    End If
   End If
  End Function

  Public Function SqlRun(strSQL, OptionalRecordSet) ' As Variant

    SqlRun = False

    On Error GoTo ErrMgr
    TRACE strSQL

    Connection.CommandTimeout = DefaultTimeOut

    If (Not IsEmpty(OptionalRecordSet)) Then

      SetRecordsetPropertiesAsDeconnected OptionalRecordSet
      OptionalRecordSet.Open strSQL, Connection, OptionalRecordSet.CursorType, OptionalRecordSet.LockType
      Set OptionalRecordSet.ActiveConnection = Nothing
      Set SqlRun = OptionalRecordSet
    Else
      Set Command = CreateObject("ADODB.Command")         ' Init the ado command object
      Set Command.ActiveConnection = Connection
      Command.CommandType = adCmdText
      Command.CommandText = strSQL
      Command.Execute
      SqlRun = True
    End If
    Exit Function
ErrMgr:
    MsgBox GetVBErrorString()
  End Function
