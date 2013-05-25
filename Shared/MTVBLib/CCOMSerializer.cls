VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CCOMSerializer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Enum CCOMSerializer_TYPE
    CCOMSerializer_TYPE_CSV = 1
    CCOMSerializer_TYPE_XML = 2
End Enum

Public PropertiesCSVList As String
Public InternalSeparator As String

Public Property Get Serialize(Optional ByVal objObj As Variant) As String
    
    Dim arrProperties As Variant
    Dim varProperty   As Variant
    Dim strCode       As String
    
    arrProperties = Split(PropertiesCSVList, ",")
    For Each varProperty In arrProperties
    
        strCode = strCode & varProperty & InternalSeparator & CallByName(objObj, varProperty, VbGet) & InternalSeparator
    Next
    If Len(strCode) Then strCode = Mid(strCode, 1, Len(strCode) - 1)
    Serialize = strCode
    
End Property

Public Property Let Serialize(Optional ByVal objObj As Variant, ByVal strCode As String)

    Dim arrSerial As Variant
    Dim i             As Long
    
    
    arrSerial = Split(strCode, InternalSeparator)
    
    For i = 0 To UBound(arrSerial) Step 2
    
        VBA.CallByName objObj, CStr(arrSerial(i)), VbLet, "" & arrSerial(i + 1)
    Next
    
End Property

Private Sub Class_Initialize()
    InternalSeparator = Chr(1)
End Sub
