VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAccountTemplateProperties"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mCol                    As Collection

Public Sub Remove(vntKey As Variant)
    On Error GoTo ErrMgr
    
    If IsNumeric(vntKey) Then
         mCol.Remove vntKey
    Else
        mCol.Remove UCase(vntKey)
    End If
    Exit Sub
ErrMgr:
'    Debug.Print Err.Description: Debug.Assert False
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

Public Function Add(ByVal strName As String, ByVal varValue As String) As MTAccountTemplateProperty

    On Error GoTo ErrMgr
    Dim s As String
      
    Dim clsV As MTAccountTemplateProperty
    
    'Debug.Assert 0
    
    Set clsV = New MTAccountTemplateProperty
    
    'If (Exist(strName)) Then Me.Remove strName ' Remove the instance if already exist...
    

    clsV.Name = strName
    clsV.Value = varValue
    
    
    mCol.Add clsV, UCase(strName)

    
    Set Add = clsV
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function

Public Function ToString() As String
    Dim clsV As MTAccountTemplateProperty
    Dim strS As String
    
    For Each clsV In Me
    
        strS = strS & clsV.ToString() & vbNewLine
    Next
    ToString = strS
End Function


Public Property Get Exist(vntKey As Variant) As Boolean

   On Error GoTo ErrMgr
   
   Dim Itm                  As MTAccountTemplateProperty
   
   Set Itm = Me.Item(vntKey)
   Exist = Not (Itm Is Nothing)
   
   Exit Property
ErrMgr:
   Err.Clear
End Property




' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - item key name id or item long index, start at 1..
' DESCRIPTION   : Return the instance of MTAccountTemplatePropertyThis method is the default method.
'                 The method is not case sensitive. Returns Nothing if the item is not found.
'
'                 If the vntKey is not existing the function will return nothing.
'                 If the Property OptionExplicit is FALSE then if the vntKey is not existing the property will create a new instance
'                 with for name vntKey, the type is VARIANT and the value is Empty.
'
' RETURN        :
Public Property Get Item(vntKey As Variant) As MTAccountTemplateProperty
Attribute Item.VB_UserMemId = 0

   On Error GoTo ErrMgr
   
   If IsNumeric(vntKey) Then
        Set Item = mCol(CLng(vntKey))
   Else
        Set Item = mCol(UCase(vntKey))
   End If
   Exit Property
ErrMgr:
    Set Item = Nothing
End Property

