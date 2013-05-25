VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CComDllInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
    
Private m_objTLI             As Object ' New TLI.TLIApplication
Private m_objtliTypeLibInfo  As Object ' TLI.TypeLibInfo

Public FileName         As String

Public Function Initialize(strFileName As String) As Boolean

    Dim objTextFile As New cTextFile
    
    If (objTextFile.ExistFile(strFileName)) Then
        FileName = strFileName
        Initialize = LoadCOMInfo()
    End If
End Function

Public Function LoadCOMInfo() As Boolean

    If m_objtliTypeLibInfo Is Nothing Then
        Set m_objtliTypeLibInfo = m_objTLI.TypeLibInfoFromFile(FileName)
    End If
End Function

Public Property Get GUID() As Variant
    GUID = m_objtliTypeLibInfo.GUID
End Property

Public Property Get ProgID() As Variant
    ProgID = m_objtliTypeLibInfo.Name
End Property

Public Property Get Interface(lngIndex As Long) As Variant

    Dim coClas      As Object ' CoClassInfo

    Set coClas = m_objtliTypeLibInfo.CoClasses(lngIndex)
    Interface = coClas.Name
End Property


Public Function InterfacesCount() As Long

    InterfacesCount = m_objtliTypeLibInfo.Interfaces.Count
End Function

Private Sub Class_Initialize()
    Set m_objTLI = CreateObject("TLI.TLIApplication")
End Sub
