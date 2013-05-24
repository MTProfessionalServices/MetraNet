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
' ---------------------------------------------------------------------------------------------------------------------------
'
' Copyright 2002 by W3Runner.com.
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND W3Runner.com. MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, W3Runner.com. Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with W3Runner.com.,
' and USER agrees to preserve the same.
'
'
' ---------------------------------------------------------------------------------------------------------------------------
'
' NAME        : CDB
' DESCRIPTION : This class supplies a quick and simple access to an SQL Server through ADO. By default the class will
'               connect to a Microsoft SQL Server, but you can also connect to another ADO compatible database by setting
'               yourself the connection string. All the ADO Recordset returned are deconnected.
' SAMPLE      : At the end of the file.
'
' ----------------------------------------------------------------------------------------------------------------------------

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

  Private Function IsW3RunnerRunning()
   Dim obj
   On Error Resume Next
   Set obj = Page
   IsW3RunnerRunning = Err.Number = 0
   Err.Clear
  End Function

  ' ---------------------------------------------------------------------------------------------------------------------------------------
  ' FUNCTION   : OpenDB
  ' PARAMETERS  :
  ' DESCRIPTION  : Open the database connection according the parameters Server, Database
  '         Login and PassWord or according the parameter ConnectionString
  ' RETURNS    :
  Public Function OpenDB()

    If IsW3RunnerRunning() Then W3Runner.TRACE GetConnectionString(), w3rSQL
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
    ElseIf Len(Me.MDBFileName) Then
        GetConnectionString = "DRIVER={Microsoft Access Driver (*.mdb)};DBQ=" & MDBFileName
    Else
      GetConnectionString = "driver={SQL Server};" & "server=" & Server & ";" & "uid=" & Login & ";" & "pwd=" & PassWord & ";" & "database=" & Database & ";"
    End If
  End Function

  Private Sub Class_Initialize()
    Server = "."                 ' Current machine
    DefaultTimeOut = 30
    m_booOpened = False
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
  Public Function SqlRun(strSQL, OptionalRecordSet As Object) ' As Variant

    SqlRun = False

    If IsW3RunnerRunning() Then W3Runner.TRACE strSQL, w3rSQL

    Connection.CommandTimeout = DefaultTimeOut

    If (IsValidObject(OptionalRecordSet)) Then

      SetRecordsetPropertiesAsDeconnected OptionalRecordSet
      On Error Resume Next
      OptionalRecordSet.Open strSQL, Connection, OptionalRecordSet.CursorType, OptionalRecordSet.LockType
      If (Err.Number) Then
        Set SqlRun = Nothing ' The Error is not cleared and therefore the caller can use it.
      Else
        'Set Rst.ActiveConnection = Nothing
        Set SqlRun = OptionalRecordSet
      End If
    Else
      Set Command = CreateObject("ADODB.Command") ' Init the ado command object
      Set Command.ActiveConnection = Connection
      Command.CommandType = adCmdText
      Command.CommandText = strSQL
      On Error Resume Next
      Command.Execute
      SqlRun = CBool(Err.Number = 0) ' The Error is not cleared and therefore the caller can use it.
    End If
  End Function

  Public Function CheckValue(strSQL, arrFieldsValues)

    Dim objRST, strFieldName, strFieldValue, v, i

    CheckValue = False
    Set objRST = SqlRun(strSQL, NewRecordset())

    If IsValidObject(objRST) Then

       For i = 0 To UBound(arrFieldsValues) Step 2

          If IsNull(arrFieldsValues(i + 1)) Then ' NULL Support

             If W3Runner.FAILED(IsNull(objRST.Fields(arrFieldsValues(i)).Value), "CDB.CheckValue failed field " & arrFieldsValues(i)) Then Exit Function
          Else
            ' Compare as text - do not ignore the case
             If W3Runner.FAILED("" & objRST.Fields(arrFieldsValues(i)).Value = "" & arrFieldsValues(i + 1), "CDB.CheckValue failed field " & arrFieldsValues(i)) Then Exit Function
          End If
       Next
       CheckValue = True
    End If
  End Function


'STOP
'PUBLIC DB
'Set DB = New CDB
'DB.Server = "."
'DB.Database="MyDatabase"
'DB.Login = ""
'DB.PAssWord = ""
'DB.OpenDB
'Dim objAccounts
'Set objAccounts = DB.SQLRun("select * from t_account", DB.NewRecordset())
'DB.CloseDB





