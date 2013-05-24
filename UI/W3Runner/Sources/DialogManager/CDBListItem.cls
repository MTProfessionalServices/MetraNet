VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CDBListItem"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public ID       As Long
Public Name     As String
Public COMMENT  As String
Public Attributes As String

' -- Dialog Manager Interface --
Public TableName As String
Public PropertiesList As String
Public RequiredPropertiesList As String

' -- Dialog Manager Interface --
Public Function IsFK(strName As String) As Boolean
    IsFK = False
End Function

' -- Dialog Manager Interface --
Public Function FKListName(strName As String) As String

End Function

' -- Dialog Manager Interface --
Public Function LoadByID() As Boolean

    Dim objDM As New CDialogManager
    objDM.Initialize Nothing, Me, TableName
    LoadByID = objDM.LoadInstance(ID)
    
End Function

' -- Dialog Manager Interface --
Public Function Save() As Boolean

    Dim objDM As New CDialogManager
    objDM.Initialize Nothing, Me, TableName
    Save = objDM.SaveInstance(ID)
End Function

' -- Dialog Manager Interface --
Public Function Delete() As Boolean
    
    Dim objDM As New CDialogManager
    objDM.Initialize Nothing, Me, TableName
    Delete = objDM.DeleteInstance(ID)
End Function


Private Sub Class_Initialize()

    PropertiesList = "name,Comment,Attributes"
    RequiredPropertiesList = "name"
End Sub

Public Function Clear() As Boolean

    Dim objDM As New CDialogManager
    objDM.Initialize Nothing, Me, TableName
    objDM.ClearInstance
    Clear = True
    
End Function


Public Function ToString() As String

End Function
