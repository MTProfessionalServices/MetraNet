VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTProperties"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTProperties
'// Description: collection of MTProperty objects
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'=== internal properties ====================================================
Private mCol As Collection

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Method:      <<accessor>> get_Item
'// Description: Returns a MTProperty in the collection by position or name.
'// Arguments:   Key – position (integer) or name (string - not case sensitive)
'// Returns:     the MTProperty or NULL if the item is not found.
Public Property Get Item(ByVal vntKey As Variant) As MTProperty
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
'// Description: Add a new MTProperty based on meta data.
'// Arguments:   Meta - MTPropertyMetaData
'// Returns:     the new MTProperty
Public Function Add(ByVal meta As MTPropertyMetaData) As MTProperty
    Dim objMTProperty As New MTProperty
    
    Set objMTProperty.MetaData_ = meta
    mCol.Add objMTProperty, UCase$(meta.Name)
    
    If Not IsEmpty(meta.DefaultValue) Then
        objMTProperty.Value = meta.DefaultValue
    End If
    
    Set Add = objMTProperty
    Exit Function
End Function

'// ----------------------------------------------------------------
'// Method:      Remove
'// Description: Removes a MTProperty from the collection.
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

    Dim clsNode As MTProperty
    Dim strS As String
    For Each clsNode In Me
        strS = strS & clsNode.ToString() & vbCrLf
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


Public Function AddWithValues(ByVal strName As String, ByVal PropertyType As String, ByVal lngLength As Long, ByVal booRequired As Boolean, Optional ByVal varDefaultValue As Variant, Optional ByVal booExtended As Boolean = False, Optional ByVal strDBColumnName As String, Optional ByVal strDBTableName As String) As MTProperty

    Dim objMetaData As MTPropertyMetaData
    
    Set objMetaData = New MTPropertyMetaData
    
    objMetaData.Name = strName
    objMetaData.DataType = PropertyType
    objMetaData.Length = lngLength
    objMetaData.Required = booRequired
    If (IsMissing(varDefaultValue)) Then varDefaultValue = Empty
    objMetaData.DefaultValue = varDefaultValue
    objMetaData.Extended = booExtended
    objMetaData.DBColumnName = strDBColumnName
    objMetaData.DBTableName = strDBTableName
    
    Set AddWithValues = Me.Add(objMetaData)
End Function
