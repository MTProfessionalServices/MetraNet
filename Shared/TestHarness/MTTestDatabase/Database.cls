VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Database"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Dsn                  As String
Public Login                As String
Public Pw                   As String
Public DBName               As String
Public ServerName           As String
Public Connection           As ADODB.Connection     ' The ref to the connection

Public DefaultTimeOut       As Long
Public ConnectionType       As eDBA_CONNECTION_TYPE
Public ServerType           As eDBA_SERVER
Public SecurityType         As eDBA_CONNECTION_SECURITY
Private booConnectionOpened As Boolean
Private AdoCom              As New ADODB.Command

#If DAO Then
    Private DaoDb               As DAO.Database
#End If

Public Enum eDBA_CONNECTION_SECURITY
    eDBA_SECURITY_DEFAULT = 0
    eDBA_SECURITY_TRUSTED_CONNECTION = 1
    eDBA_SECURITY_SQL_CONNECTION = 2
    eDBA_SECURITY_LOGIN = 4
End Enum

Public Enum eDBA_CONNECTION_TYPE
    eDBA_CONNECTION_EMPTY = 0
    eDBA_CONNECTION_DAO = 1
    eDBA_CONNECTION_ADO = 2
    eDBA_CONNECTION_ODBC = 4
End Enum

Public Enum eDBA_SERVER
    eDBA_SERVER_EMPTY = 0
    eDBA_SERVER_MS_ACCESS = 1
    eDBA_SERVER_MS_SQL_65 = 2
    eDBA_SERVER_MS_SQL_70 = 4
    eDBA_SERVER_MS_SYBASE = 8
End Enum
Public Function CloseConnection() As Boolean

    On Error GoTo ErrMgr
    
    If (booConnectionOpened) Then
        If (IsDAO) Then
            #If DAO Then
            DaoDb.Close
            #End If
        Else
            Connection.Close
            Set Connection = Nothing
        End If
        booConnectionOpened = False
    End If
    CloseConnection = True
    Exit Function
ErrMgr:
    
End Function
 

Public Property Get ConnectionString() As String

    On Error GoTo ErrMgr


    Dim s As String
    If (Dsn = "") Then
        s = "driver={SQL Server};" & "server=" & ServerName & ";" & "uid=" & Login & ";" & "pwd=" & Pw & ";" & "database=" & DBName & ";"
    Else
        s = "DSN=" & Dsn & ";" & "uid=" & Login & ";" & "pwd=" & Pw & ";"
    End If
    ConnectionString = s

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Database", "ConnectionString"
End Property

Public Function OpenConnection(Optional strIniFileName As String) As Boolean
    
    On Error GoTo ErrMgr
    
    Dim booTrustedCon As Boolean
        
    If (Not booConnectionOpened) Then
    
        If (IsFlag(SecurityType, eDBA_SECURITY_LOGIN)) Then
        
            Dim strLogin        As String
            Dim strPw           As String
            Dim strServerName   As String
            Dim strDBName       As String
            
            #If FRMLOGIN Then
            If (Not frmDataBaseAccessLogin.Run(strLogin, strPw, strServerName, strDBName, booTrustedCon, strIniFileName)) Then
                Exit Function
            End If
            #End If
            
            Me.Login = strLogin
            Me.Pw = strPw
            Me.ServerName = strServerName
            Me.DBName = strDBName
            
            If (booTrustedCon) Then
                AddFlag SecurityType, eDBA_SECURITY_TRUSTED_CONNECTION
                RemoveFlag SecurityType, eDBA_SECURITY_SQL_CONNECTION
            End If
        End If
    
        If (IsDAO()) Then
            #If DAO Then
            Set DaoDb = DAO.OpenDatabase(DBName)
            #End If
        Else
        
            Set Connection = New ADODB.Connection
            
            If (IsFlag(ServerType, eDBA_SERVER_MS_SQL_70)) Then
                
                ' Set connection properties.
                Connection.ConnectionTimeout = Me.DefaultTimeOut
                Connection.Provider = "sqloledb"
                Connection.Properties("Data Source").Value = ServerName
                Connection.Properties("Initial Catalog").Value = DBName
                
                ' Decision code for login authorization type: WinNT or SQL Server.
                If (IsFlag(SecurityType, eDBA_SECURITY_TRUSTED_CONNECTION)) Then
                    Connection.Properties("Integrated Security").Value = "SSPI"
                Else
                    Connection.Properties("User ID").Value = Me.Login
                    Connection.Properties("Password").Value = Me.Pw
                End If
                Connection.Open
            Else
                ' Regular ADO connection
                TRACE "About to open ADO connection Connection.Open ConnectionString", "CDataBaseAccess.cls", "OpenConnection"
                Connection.Open ConnectionString
            End If
        End If
    End If
    booConnectionOpened = True
    OpenConnection = True
    Exit Function
ErrMgr:
    Dim strError As String
    strError = CStr(Err.Number) & " " & Err.Description & " " & Err.Source
    TRACE strError, "CDataBaseAccess.cls", "OpenConnection"
    Err.Raise Err.Number, Err.Source, Err.Description
End Function
Public Function Init(eConnectionType As eDBA_CONNECTION_TYPE, eServerType As eDBA_SERVER, eSecurityType As eDBA_CONNECTION_SECURITY, Optional strDBName As String, Optional strLogin As String, Optional strPw As String, Optional strDSN As String, Optional strServer As String) As Boolean

    On Error GoTo ErrMgr


    ConnectionType = eConnectionType
    ServerType = eServerType
    SecurityType = eSecurityType
    ServerName = strServer
    Dsn = strDSN
    Login = strLogin
    Pw = strPw
    DBName = strDBName
    Init = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Database", "Init"
End Function


Private Function SetRecordsetProperties(r As Variant, Optional booConnected As Boolean = False, Optional booReadOnly As Boolean = True) As Boolean

    On Error GoTo ErrMgr


    If (booConnected) Then
        ' Server Connected Mode
        r.CursorLocation = adUseServer
        r.CursorType = adOpenKeyset
        r.LockType = IIf(booReadOnly, adLockReadOnly, adLockBatchOptimistic)
    Else
        ' Server Deconnected Mode
        r.CursorLocation = adUseClient
        r.CursorType = adOpenStatic
        r.LockType = IIf(booReadOnly, adLockReadOnly, adLockBatchOptimistic)
    End If
    SetRecordsetProperties = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Database", "SetRecordsetProperties"
End Function

Public Function SqlRun(strSQL As String, Optional Rst As Variant, Optional lngRecordAffected As Long, Optional booConnected As Boolean = False, Optional booReadOnly As Boolean = True) As Boolean

    'TRACE "SQL=" & strSQL, "CDataBaseAccess.cls", "SqlRun()"
    
  '  On Error GoTo ErrMgr
    If (IsDAO) Then
        #If DAO Then
            If (Not IsMissing(Rst)) Then
                Set Rst = DaoDb.OpenRecordset(strSQL, dbOpenSnapshot)
                lngRecordAffected = DaoDb.RecordsAffected
            Else
                DaoDb.Execute strSQL
                lngRecordAffected = DaoDb.RecordsAffected
            End If
        #End If
    Else
        Connection.CommandTimeout = DefaultTimeOut
        
        If (Not IsMissing(Rst)) Then
            SetRecordsetProperties Rst, booConnected, booReadOnly
            Rst.Open strSQL, Connection, Rst.CursorType, Rst.LockType  ' get the current connection
            'Set Rst.ActiveConnection = Nothing
        Else
            ' Init the ado command object
            Set AdoCom.ActiveConnection = Connection
            AdoCom.CommandType = adCmdText
            AdoCom.CommandText = strSQL
            AdoCom.Execute lngRecordAffected
        End If
    End If
    SqlRun = True
    Exit Function
'ErrMgr:
 '   Err.Raise Err.Number, Err.Source, Err.Description
End Function
Public Function BeginTrans() As Boolean
    On Error GoTo ErrMgr
    If (IsDAO) Then
        #If DAO Then
            DAO.BeginTrans
        #End If
    Else
        Connection.BeginTrans
    End If
    BeginTrans = True
    Exit Function
ErrMgr:
    
End Function

Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    DefaultTimeOut = 60

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Database", "Class_Initialize"
End Sub

Public Function CommitTrans() As Boolean
    On Error GoTo ErrMgr
    If (IsDAO) Then
        #If DAO Then
            DAO.CommitTrans
        #End If
    Else
        Connection.CommitTrans
    End If
    
    CommitTrans = True
    Exit Function
ErrMgr:
    
End Function

Private Function IsFlag(lngValue As Long, lngFlag As Long) As Boolean

    On Error GoTo ErrMgr

    IsFlag = CBool((lngValue And lngFlag) = lngFlag)

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Database", "IsFlag"
End Function


Public Function RollBackTrans() As Boolean
    On Error GoTo ErrMgr
    If (IsDAO) Then
        #If DAO Then
            DAO.Rollback
        #End If
    Else
        Connection.RollBackTrans
    End If
    RollBackTrans = True
    Exit Function
ErrMgr:
    
End Function

Public Function IsDAO() As Boolean

    On Error GoTo ErrMgr

    IsDAO = IsFlag(ConnectionType, eDBA_CONNECTION_DAO)

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Database", "IsDAO"
End Function

Public Function IsADO() As Boolean

    On Error GoTo ErrMgr

    IsADO = IsFlag(ConnectionType, eDBA_CONNECTION_ADO)

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Database", "IsADO"
End Function

Private Function AddFlag(lngValue As Long, lngBit As Long) As Boolean
    On Error GoTo ErrMgr
    If (Not IsFlag(lngValue, lngBit)) Then
        lngValue = lngValue + lngBit
    End If
    AddFlag = True
    Exit Function
ErrMgr:
    Debug.Assert 0
End Function

Private Function RemoveFlag(lngValue As Long, lngBit As Long) As Boolean
    On Error GoTo ErrMgr
    If (IsFlag(lngValue, lngBit)) Then
        lngValue = lngValue - lngBit
    End If
    RemoveFlag = True
    Exit Function
ErrMgr:
    Debug.Assert 0
End Function


Public Function RecordSetToString(objR As ADODB.Recordset) As String

    On Error GoTo ErrMgr


    Dim strS As String
    Dim i    As Long

    If (objR.BOF()) Then Exit Function
    objR.MoveFirst
    Do While Not objR.EOF()
        For i = 0 To objR.Fields.Count - 1
            strS = strS & objR.Fields(i).Name & "=" & objR.Fields(i).Value & "; "
        Next
        objR.MoveNext
        strS = strS & vbCrLf
    Loop
    objR.MoveFirst
    RecordSetToString = strS

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Database", "RecordSetToString"
End Function

Public Function OpenMTDefaultDataBase(strConfigDir As String) As Boolean

    On Error GoTo ErrMgr
     
    Dim objQueryAdapter     As Object ' QUERYADAPTERLib.MTQueryAdapter ' Searhc in ref window for QueryAdapter Type Lib...
    Dim objError            As New CError
    
    Dim booRetVal           As Boolean
    
    Set objQueryAdapter = CreateObject("MetraTech.MTQueryAdapter.1")
    
    objQueryAdapter.Init "database"
    
    With objQueryAdapter
    
        If .GetAccessType = "ADO-DSN" Or .GetAccessType = "ADO" Then
        
            Init eDBA_CONNECTION_ADO, eDBA_SERVER_EMPTY, eDBA_SECURITY_DEFAULT, .GetDBName, .GetUserName, .GetPassword, .GetDataSource, .GetServerName
        Else
            TRACE "Unable to connect to the database.  Invalid access type: " & objQueryAdapter.GetAccessType & " ConnectionString=" & ConnectionString(), "Subcriber.cls", "OpenDB"
            Exit Function
        End If
    End With
    TRACE "OpenMTDefaultDataBase.ConnectionString=" & Me.ConnectionString
    booRetVal = OpenConnection()
    TRACE "OpenMTDefaultDataBase() " & IIf(booRetVal, "SUCCEED", "FAILED")
    OpenMTDefaultDataBase = booRetVal
    Exit Function
ErrMgr:
    objError.Save Err.Number, Err.Description, Err.Source, , "Subcriber.cls", "OpenDB"
    TRACE objError.ToString, , , LOG_ERROR
    objError.Raise
End Function


Public Function RecordSetToSQLView(objR As ADODB.Recordset) As String

    On Error GoTo ErrMgr


    Dim strS    As String
    Dim strSS   As String
    Dim i       As Long

    If (objR.BOF()) Then Exit Function
    objR.MoveFirst
    
    Do While Not objR.EOF()
        For i = 0 To objR.Fields.Count - 1
            strS = strS & MakeString(objR.Fields(i).Value, objR.Fields(i).DefinedSize) & " "
        Next
        objR.MoveNext
        strS = strS & vbCrLf
    Loop
    objR.MoveFirst
    For i = 0 To objR.Fields.Count - 1
        strSS = strSS & MakeString(objR.Fields(i).Name, MaxLong(objR.Fields(i).DefinedSize, 10)) & " "
    Next
    strS = strSS & vbCrLf & String(1024, "-") & vbCrLf & strS
    
    
    
    RecordSetToSQLView = strS

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Database", "RecordSetToSQLView"
End Function



Private Function MaxLong(lngA As Long, lngB As Long) As Long

    On Error GoTo ErrMgr

    If (lngA > lngB) Then
        MaxLong = lngA
    Else
        MaxLong = lngB
    End If

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Database", "MaxLong"
End Function

