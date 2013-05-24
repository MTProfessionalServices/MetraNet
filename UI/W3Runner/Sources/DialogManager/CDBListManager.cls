VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CDBListManager"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private mCol    As Collection

Public IDColumnName As String

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1. If vntKey is Null or Empty the property
'                   return the first item of the collection if there is a first item else <code>Nothing</code>.
'
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(ByVal vntKey As Variant) As CDBListItems


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


    On Error GoTo errmgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
errmgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property


Private Sub Class_Initialize()

    On Error GoTo errmgr
    Set mCol = New Collection
    IDColumnName = "id"
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
Public Function Add(ByVal strName As String, ByVal strTableName As String) As CDBListItems

    On Error GoTo errmgr
    
    Dim objCDBListItems As CDBListItems
    
    Set objCDBListItems = LoadListItem(strTableName)
    objCDBListItems.Name = strName
    
    If (Me.Exist(strName)) Then Me.Remove strName
        
    mCol.Add objCDBListItems, UCase$(objCDBListItems.Name)
    
    Set Add = objCDBListItems
    Exit Function
errmgr:
    FShowError PreProcess(DBDialogManager_ERROR_1000, "LISTNAME", strName, "TABLENAME", strTableName)
    Set Add = Nothing
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the content of the object in a string.
' RETURN        :
Public Function ToString() As String

    On Error GoTo errmgr

    Dim clsNode As CDBListItems
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

Public Function LoadListItem(strTableName As String) As CDBListItems
    Dim strSQL          As String
    Dim i               As Long
    Dim objDBListItems  As CDBListItems
    Dim objDBListItem   As CDBListItem
    Dim objRST          As Variant
            
    On Error GoTo errmgr
    
    Set objDBListItems = New CDBListItems
    objDBListItems.TableName = strTableName
    strSQL = PreProcess(CDialogManager_SQL_SELECT, "TABLENAME", strTableName, "IDCOLUMN", IDColumnName)
    Set objRST = g_objDB.SqlRun(strSQL, g_objDB.NewRecordset())
    
    If IsValidObject(objRST) Then
    
        If Not objRST.EOF Then
        
            Do While Not objRST.EOF
            
                If Len("" & objRST.fields("NAME").Value) Then
                
                    Set objDBListItem = objDBListItems.Add(objRST.fields("NAME").Value)
                    
                    For i = 0 To objRST.fields.Count - 1
                
                        COMProperty(objDBListItem, objRST.fields(i).Name) = objRST.fields(i).Value
                    Next
                End If
                objRST.MoveNext
            Loop
        End If
    End If
    Set LoadListItem = objDBListItems
    Exit Function
errmgr:
End Function

