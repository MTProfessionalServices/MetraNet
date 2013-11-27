VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTFilter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'// ----------------------------------------------------------------
'// Object:      MTFilter
'// Description: Filter to be used for searches
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================
Public Enum MTOperatorType
    OPERATOR_TYPE_NONE = 0            'no operator defined
    OPERATOR_TYPE_LIKE = 1            'LIKE
    OPERATOR_TYPE_LIKE_W = 2          'LIKE that adds wildcard to value (for convenience)
    OPERATOR_TYPE_EQUAL = 3           ' =
    OPERATOR_TYPE_NOT_EQUAL = 4       ' !=
    OPERATOR_TYPE_GREATER = 5         ' >
    OPERATOR_TYPE_GREATER_EQUAL = 6   ' >=
    OPERATOR_TYPE_LESS = 7            ' <
    OPERATOR_TYPE_LESS_EQUAL = 8      ' <=
End Enum

'=== internal properties ====================================================
Private mItems As Collection

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Method:      <<accessor>> get_Item
'// Description: Returns a MTFilterItem in the collection by position or name.
'// Arguments:   idx – position (integer)
'// Returns:     the MTFilterItem or NULL if the item is not found.
Public Property Get Item(ByVal idx As Long) As MTFilterItem
   Set Item = mItems(idx)
End Property

'// ----------------------------------------------------------------
'// Method:      <<accessor>> get_Count
'// Description: Returns the number of items in the collection.
'// Returns:     Long
Public Property Get Count() As Long
    Count = mItems.Count
End Property

'// ----------------------------------------------------------------
'// Method:      <<accessor>> get_NewEnum
'// Description: Return a COM Enumerator over this collection. Allows
'//              to use "for each".
'// Returns:     IEnumVARIANT
Public Property Get NewEnum() As IUnknown ' Documented=no
Attribute NewEnum.VB_UserMemId = -4
    Set NewEnum = mItems.[_NewEnum]
End Property

'// ----------------------------------------------------------------
'// Method:      Add
'// Description: Add a new filter item
'// Arguments:   propName - name of property
'//              op - the operator
'//              value - the value to compare against
'//                      (in the future one could pass multiple values in to simulate OR)
'// Returns:     position of inserted item
Public Function Add(ByVal propName As String, ByVal op As MTOperatorType, ByVal Value As Variant) As Long
    Dim Item As New MTFilterItem
    Item.PropertyName = propName
    Item.Operator = op
    Item.Value = Value
   
    mItems.Add Item
    Add = mItems.Count
End Function

'// ----------------------------------------------------------------
'// Method:      Remove
'// Description: Removes a MTFilterItem from the collection.
'// Arguments:   Key – position (integer) or name (string - not case sensitive)
Public Sub Remove(ByVal idx As Long)
    mItems.Remove idx
End Sub

'// ----------------------------------------------------------------
'// Method:      Clear
'// Description: Remove all the items from the collection.
Public Sub Clear()
    Do While Count > 0
        Remove 1
    Loop
End Sub

'// ----------------------------------------------------------------
'// Method:      CreateMergedFilter
'// Description: merges this filter with another one into a new filter
'// Arguments:   filter - other filter to be merged
'// Returns:     a MTFilter that contains the merge result
Public Function CreateMergedFilter(ByVal filter As MTFilter) As MTFilter
    Dim mergedFilter As New MTFilter
    Dim Item As MTFilterItem
    
    ' add this filter
    For Each Item In mItems
        mergedFilter.Add Item.PropertyName, Item.Operator, Item.Value
    Next
    
    ' add other filter
    For Each Item In filter
        mergedFilter.Add Item.PropertyName, Item.Operator, Item.Value
    Next
        
    Set CreateMergedFilter = mergedFilter
End Function

'=== internal methods =======================================================
Private Sub Class_Initialize()
    Set mItems = New Collection
End Sub

Private Sub Class_Terminate()
    Clear
    Set mItems = Nothing
End Sub

