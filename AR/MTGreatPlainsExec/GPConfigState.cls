VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "GPConfigState"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'Multiple Operating Company Support - There is no longer just one connection string
'Public BOConnectionString As String
Public XSLPath As String
Public OutGoingIdentifier As String
Public MoveBalancePrefix As String
Public MoveBalanceSeperator As String
Public eConnectObjectName As String

Private oConnectionStringDict As New Dictionary

Function GetConnectionString(sNamespace As String) As String
    GetConnectionString = oConnectionStringDict.Item(LCase(sNamespace))
End Function

Sub SetConnectionString(sNamespace As String, sConnectionString As String)
    oConnectionStringDict.Add LCase(sNamespace), sConnectionString
End Sub

Function ConnectionStringCount() As Integer
    ConnectionStringCount = oConnectionStringDict.Count()
End Function

Function GetNamespaceString(index As Integer) As String
    GetNamespaceString = oConnectionStringDict.Keys(index)
End Function
