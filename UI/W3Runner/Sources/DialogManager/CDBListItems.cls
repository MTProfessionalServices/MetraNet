VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CDBListItems"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private mCol    As Collection
Public Name As String
Public TableName As String



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1. If vntKey is Null or Empty the property
'                   return the first item of the collection if there is a first item else <code>Nothing</code>.
'
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(ByVal vntKey As Variant) As CDBListItem
Attribute Item.VB_UserMemId = 0


   On Error GoTo errmgr
   
   If IsNumeric(vntKey) Then
        Set Item = mCol(vntKey)
   Else
        Set Item = mCol(UCase$(vntKey))
   End If
   Exit Property
errmgr:
   Set Item = Nothing
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Removes the item from the collection. The method is not case sensitive.
' RETURN        : Returns TRUE if OK
Public Function Remove(vntKey As Variant) As Boolean

    On Error GoTo errmgr
    mCol.Remove vntKey
    Remove = True
    Exit Function
errmgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Count
' PARAMETERS    :
' DESCRIPTION   : Returns the number of items in the collection.
' RETURN        :
Public Property Get Count() As Long

    On Error GoTo errmgr
    Count = mCol.Count
    Exit Property
errmgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : NewEnum
' PARAMETERS    :
' DESCRIPTION   : Implement the COM Enumerator. This function is used internally by visual basic in for each loop!
' RETURN        : IUnknown
Public Property Get NewEnum() As IUnknown ' Documented=no
Attribute NewEnum.VB_UserMemId = -4


    On Error GoTo errmgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
errmgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property


Private Sub Class_Initialize()

    On Error GoTo errmgr
    Set mCol = New Collection
    Exit Sub
errmgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Class_Terminate
' PARAMETERS    :
' DESCRIPTION   : Free the collection.
' RETURN        :
Private Sub Class_Terminate()

    On Error GoTo errmgr
    
    Clear
    Set mCol = Nothing

    Exit Sub
errmgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   : Remove all the items in the collection. If the item is no more referenced it is deleted and its destructor
'                 Class_Terminate event is raise.
' RETURN        : TRUE if Ok.
Public Function Clear() As Boolean

    On Error GoTo errmgr

    Do While Count > 0
    
        'Me.Item(1).Delete
        Remove 1
    Loop
    Clear = True
    Exit Function
errmgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
'                 strName - The name of the enum type item (also called enumerator).
'                 varValue - The value of the enum type item. A MetraTech Enum Type Item can have more that one value but this object only use the first one.
'                 strCaption - The localization of the enum type.
' DESCRIPTION   : Add a new item to the collection and return and a reference of it. strName is the key of the collection.
'                 If the item already exist it is overwritten.
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function Add(ByVal strName As String) As CDBListItem

    On Error GoTo errmgr
    
    Dim objCDBListItem As New CDBListItem
        
    objCDBListItem.Name = strName
    
    If (Me.Exist(strName)) Then Me.Remove strName
        
    mCol.Add objCDBListItem, UCase$(objCDBListItem.Name)
    
    Set Add = objCDBListItem
    Exit Function
errmgr:
    Set Add = Nothing
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the content of the object in a string.
' RETURN        :
Public Function ToString() As String

    On Error GoTo errmgr

    Dim clsNode As CDBListItem
    Dim strS    As String
    
    For Each clsNode In Me
        strS = strS & clsNode.ToString() & vbCrLf
    Next
    ToString = strS

    Exit Function
errmgr:
  
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : Exist
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Returns TRUE if the item exist in the collection. The method is not case sensitive.
' RETURN        :
Public Function Exist(ByVal vntKey As Variant) As Boolean

    On Error GoTo errmgr
    
    Dim objItem As Object
    
    If IsNumeric(vntKey) Then
        Set objItem = mCol(vntKey)
    Else
        Set objItem = mCol(UCase$(vntKey))
    End If
    Exist = True
    Exit Function
errmgr:
    Exist = False
    Err.Clear
End Function


Public Property Get ItemByID(ByVal lngID As Long) As CDBListItem


   On Error GoTo errmgr
   
   Dim objItem As CDBListItem
   
   For Each objItem In Me
   
        If objItem.ID = lngID Then
        
            Set ItemByID = objItem
            Exit Function
        End If
   Next
   Exit Property
errmgr:
   Set ItemByID = Nothing
End Property

Public Function PopulateBox(lb As Variant) As Boolean

    Dim v As CDBListItem
    Dim i As Long
    lb.Clear
    
    For Each v In Me
    
        lb.AddItem v.Name
        lb.itemData(lb.NewIndex) = v.ID
    Next
    For i = 0 To lb.ListCount - 1
       If InStr(Me.Item(lb.List(i)).Attributes, "/D") Then
            lb.ListIndex = i
        End If
    Next
    
    
    
    PopulateBox = True
End Function
