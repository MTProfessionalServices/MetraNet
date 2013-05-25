VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Languages"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' ****************************************************************************
' CLASS         :
' AUTHOR        : F.Torres
' CREATION DATE : 08/20/2000
' VERSION       : 1.0
' DESCRIPTION   :
'
'
'
'
' *****************************************************************************
Option Explicit

Private mCol As Collection
Public Id As String


Public Property Get Item(vntKey As Variant) As Language
Attribute Item.VB_UserMemId = 0




   On Error GoTo ErrMgr
   If IsNumeric(vntKey) Then
        Set Item = mCol(vntKey)
   Else
        Set Item = mCol(UCase(vntKey))
   End If
   Exit Property
ErrMgr:
   Set Item = Nothing
End Property

Public Sub Remove(vntKey As Variant)

    On Error GoTo ErrMgr
    mCol.Remove vntKey
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Property Get Count() As Long

    On Error GoTo ErrMgr
    Count = mCol.Count
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4




    On Error GoTo ErrMgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    Set mCol = New Collection
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Clear
    Set mCol = Nothing
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Sub Clear()

    On Error GoTo ErrMgr

    Do While Count > 0
        Remove 1
    Loop
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Function Add(Optional varId As Variant) As Language

    On Error GoTo ErrMgr
    
    
    Dim objLanguage As Language
    Set objLanguage = New Language
    
    If (IsMissing(varId)) Then
        mCol.Add objLanguage
    Else
        mCol.Add objLanguage, UCase("" & varId)
    End If
    
    Set Add = objLanguage
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function

Public Function ToString() As String

    On Error Goto ErrMgr ' @VbAddCode.ErrorHandler 

    Dim clsNode As Language
    Dim strS As String
    For Each clsNode In Me
        strS = strS & clsNode.ToString() & vbCrLf
    Next
    ToString = strS

    Exit FUNCTION ' @VbAddCode.ErrorHandler
    ErrMgr: ' @VbAddCode.ErrorHandler
TRACE MTMSIX_ERROR_1033 & GetVBErrorString(), "MSIXLanguages.cls", "ToString", LOG_ERROR' @VbAddCode.ErrorHandler
End Function


Public Property Get Name() As String

    On Error Goto ErrMgr ' @VbAddCode.ErrorHandler 

    Name = Id

    Exit PROPERTY ' @VbAddCode.ErrorHandler
    ErrMgr: ' @VbAddCode.ErrorHandler
TRACE MTMSIX_ERROR_1033 & GetVBErrorString(), "MSIXLanguages.cls", "Name", LOG_ERROR' @VbAddCode.ErrorHandler
End Property

Public Property Let Name(ByVal vNewValue As String)

    On Error Goto ErrMgr ' @VbAddCode.ErrorHandler 

    Id = vNewValue

    Exit PROPERTY ' @VbAddCode.ErrorHandler
    ErrMgr: ' @VbAddCode.ErrorHandler
TRACE MTMSIX_ERROR_1033 & GetVBErrorString(), "MSIXLanguages.cls", "Name", LOG_ERROR' @VbAddCode.ErrorHandler
End Property
