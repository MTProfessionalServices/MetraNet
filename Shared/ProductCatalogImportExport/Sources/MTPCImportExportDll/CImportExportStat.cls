VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CImportExportStat"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit


'Public Enum CIMPORTEXPORT_STAT_TYPE
'    CIMPORTEXPORT_STAT_TYPE_NONE = 0
'    CIMPORTEXPORT_STAT_TYPE_NEW_OBJECT = 1
'    CIMPORTEXPORT_STAT_TYPE_RE_USED_OBJECT = 1
'End Enum

'Public StatType         As CIMPORTEXPORT_STAT_TYPE
Public ObjectType       As String
Public CreationCounter  As Long
Public ReUsedCounter    As Long

Private m_objCreationNames   As New Collection
Private m_objReUsedNames    As New Collection

Public Function AddCreationName(ByVal strName As String) As Boolean

    On Error Resume Next
    If Len(strName) = 0 Then
'        Debug.Assert 0
        strName = "undefined-name"
    End If
    m_objCreationNames.Add UCase$(strName), UCase$(strName)
    Err.Clear
    AddCreationName = True
End Function

Public Function GetCreationNamesAsString() As String

    Dim v As Variant
    Dim s As String
    
    For Each v In m_objCreationNames
        s = s & v & ","
    Next
    GetCreationNamesAsString = "(" & Mid(s, 1, Len(s) - 1) & ")"
End Function


Public Function AddReUsedName(ByVal strName As String) As Boolean

    On Error Resume Next
    
    m_objReUsedNames.Add UCase$(strName), UCase$(strName)
    Err.Clear
    AddReUsedName = True
End Function

Public Function GetReUsedNamesAsString() As String

    Dim v As Variant
    Dim s As String
    
    For Each v In m_objReUsedNames
        s = s & v & ","
    Next
    GetReUsedNamesAsString = "(" & Mid(s, 1, Len(s) - 1) & ")"
End Function

