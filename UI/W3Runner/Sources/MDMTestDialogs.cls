VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MDMTestDialogs"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit


Private mCol As Collection





' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(vntKey As Variant) As MDMTestDialog
Attribute Item.VB_UserMemId = 0



   On Error GoTo ErrMgr
   If IsNumeric(vntKey) Then
        Set Item = mCol(vntKey)
   Else
        Set Item = mCol(UCase$(vntKey))
   End If
   Exit Property
ErrMgr:
   FShowError PreProcess(FREDRUNNER_ERROR_07026, "INDEX", vntKey)
   Set Item = Nothing
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Remove the item from the collection. The method is not case sensitive.
' RETURN        : Returns TRUE if OK
Public Function Remove(vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    mCol.Remove vntKey
    Remove = True
    Exit Function
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Count
' PARAMETERS    :
' DESCRIPTION   : Returns the number of items in the collection.
' RETURN        :
Public Property Get Count() As Long

    On Error GoTo ErrMgr
    Count = mCol.Count
    Exit Property
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : NewEnum
' PARAMETERS    :
' DESCRIPTION   : Implement the COM Enumerator. This function is used internally by visual basic in for each loop!
' RETURN        : IUnknown
Public Property Get NewEnum() As IUnknown ' Documented=no
Attribute NewEnum.VB_UserMemId = -4

    On Error GoTo ErrMgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property

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

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   : Remove all the items in the collection. If the item is no more referenced it is deleted and its destructor
'                 Class_Terminate event is raise.
' RETURN        : TRUE if Ok.
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

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
' DESCRIPTION   : Add a new item to the collection with the id strId and return and a reference of it.
'                 If the item already exist the function will fail!
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function Add(objparent As MDMTestDialog) As MDMTestDialog

    On Error GoTo ErrMgr
    
    Dim objMDMTestDialog As New MDMTestDialog
    Set objMDMTestDialog.Parent = objparent
    
    mCol.Add objMDMTestDialog, objMDMTestDialog.Name
    
    Set Add = objMDMTestDialog
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function



' -------------------------------------------------------------------------------
' FUNCTION      : Exist
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Returns TRUE if the item exist in the collection. The method is not case sensitive.
' RETURN        :
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



