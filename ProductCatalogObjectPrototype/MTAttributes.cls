VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAttributes"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTAttributes
'// Description: collection of MTAttribute objects
'// ----------------------------------------------------------------
Option Explicit


'=== internal properties ====================================================
Private mCol As Collection


'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Method:      <<accessor>> get_Item
'// Description: Returns a MTAttribute in the collection by position or name.
'// Arguments:   Key – position (integer) or name (string - not case sensitive)
'// Returns:     the MTAttribute or NULL if the item is not found.
Public Property Get Item(ByVal vntKey As Variant) As MTAttribute
Attribute Item.VB_UserMemId = 0
   On Error GoTo ErrMgr
   If IsNumeric(vntKey) Then
        Set Item = mCol(vntKey)
   Else
        Set Item = mCol(UCase$(vntKey))
   End If
   Exit Property
ErrMgr:
   Set Item = Nothing
End Property

'// ----------------------------------------------------------------
'// Method:      <<accessor>> get_Count
'// Description: Returns the number of items in the collection.
'// Returns:     Long
Public Property Get Count() As Long

    On Error GoTo ErrMgr
    Count = mCol.Count
    Exit Property
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property

'// ----------------------------------------------------------------
'// Method:      <<accessor>> get_NewEnum
'// Description: Return a COM Enumerator over this collection. Allows
'//              to use "for each".
'// Returns:     IEnumVARIANT
Public Property Get NewEnum() As IUnknown ' Documented=no
Attribute NewEnum.VB_UserMemId = -4
    On Error GoTo ErrMgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property

'// ----------------------------------------------------------------
'// Method:      Add
'// Description: Add a new MTAttribute based on meta data.
'// Arguments:   Meta - MTAttributeMetaData
'// Returns:     the new MTAttribute
Public Function Add(ByVal meta As MTAttributeMetaData) As MTAttribute

    On Error GoTo ErrMgr
    
    Dim objMTAttribute As New MTAttribute
    
    Set objMTAttribute.MetaData_ = meta
    mCol.Add objMTAttribute, UCase$(meta.Name)
    
    ' set default value if any
    If Not IsEmpty(meta.DefaultValue) Then
        objMTAttribute.Value = meta.DefaultValue
    End If
    
    Set Add = objMTAttribute
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function


'// ----------------------------------------------------------------
'// Method:      Remove
'// Description: Removes a MTAttribute from the collection.
'// Arguments:   Key – position (integer) or name (string - not case sensitive)
Public Function Remove(ByVal vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    mCol.Remove vntKey
    Remove = True
    Exit Function
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function

'// ----------------------------------------------------------------
'// Method:      Clear
'// Description: Remove all the items from the collection.
Public Function Clear() As Boolean

    On Error GoTo ErrMgr

    Do While Count > 0
        Remove 1
    Loop
    Clear = True
    Exit Function
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function

'// ----------------------------------------------------------------
'// Method:      Exist
'// Description: test if item exists in the collection.
'// Arguments:   Key - position (integer) or name (string - not case sensitive)
'// Returns:     True/False
Public Function Exist(ByVal vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    
    Dim objItem As Object
    
    If IsNumeric(vntKey) Then
        Set objItem = mCol(vntKey)
    Else
        Set objItem = mCol(UCase$(vntKey))
    End If
    
    Exist = True
    Exit Function
ErrMgr:
    Exist = False
    Err.Clear
End Function

'// ----------------------------------------------------------------
Public Function ToString() As String

    On Error GoTo ErrMgr

    Dim clsNode As MTAttribute
    Dim strS As String
    For Each clsNode In Me
        'strS = strS & clsNode.ToString() & vbCrLf
    Next
    ToString = strS

    Exit Function
ErrMgr:
  
  
End Function


'=== internal methods =======================================================
Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    Set mCol = New Collection
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Clear
    Set mCol = Nothing
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub



