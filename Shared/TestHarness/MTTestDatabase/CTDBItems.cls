VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CTDBItems"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit



Private mCol As Collection


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method and
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(vntKey As Variant, Optional ByVal booRecursif As Boolean = False, Optional ByVal booUseLongId As Boolean) As CTDBItem
Attribute Item.VB_UserMemId = 0


    On Error GoTo ErrMgr
   
    Dim i As CTDBItem
    
    If booUseLongId Then
        
        For Each i In Me
        
            If i.LongID = CLng(vntKey) Then
            
                Set Item = i
                Exit Property
            End If
        Next
    Else
        If IsNumeric(vntKey) Then
        
            Set Item = mCol(vntKey)
        Else
            Set Item = mCol(UCase$(vntKey))
        End If
    End If
   Exit Property
ErrMgr:

   Dim objItm As CTDBItem
   Dim objTmp As CTDBItem
   
   If (booRecursif) Then
   
        For Each objItm In Me
        
            Set objTmp = objItm.Children.Item(vntKey, booRecursif)
            
            If Not (objTmp Is Nothing) Then
                Set Item = objTmp
                
                Exit Property
            End If
        Next
    End If
   
   Set Item = Nothing
   
End Property


Public Function PreviousItem(lngLongID As Long) As CTDBItem

    Dim p As CTDBItem
    Dim i As CTDBItem
    
    For Each i In Me
    
        If i.LongID = lngLongID Then
        
            Set PreviousItem = p
            Exit Function
        End If
        Set p = i
    Next
    
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Remove the item from the collection. The method is not case sensitive.
' RETURN        : Returns TRUE if OK
Public Function Remove(vntKey As Variant, Optional ByVal booUseLongId As Boolean) As Boolean

    On Error GoTo ErrMgr
    
    Dim it As CTDBItem
    Dim i As Long
    
    If booUseLongId Then
        
        For i = 1 To Me.Count
        
            Set it = mCol(i)
            If it.LongID = CLng(vntKey) Then
            
                mCol.Remove i
                Remove = True
                Exit Function
            End If
        Next
    Else
        mCol.Remove vntKey
        Remove = True
    End If
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
    'Make sure you are not using the comlogger object for logging errors in this module
    'g_booLogWithoutCOMLogger = True
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
'                 Class_Terminate event is raised.
' RETURN        : TRUE if Ok.
Public Function Clear() As Boolean

    On Error GoTo ErrMgr

'    Do While Count > 0
'        Remove 1
'    Loop

    Set mCol = New Collection
    Clear = True
    Exit Function
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
' DESCRIPTION   : Add a new item to the collection with a unic ID
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function AddTestToDB(objParent As CTDBItem, ByVal strID As String) As CTDBItem

    On Error GoTo ErrMgr
    
    Dim objCTDBItem As CTDBItem
    
    Set objCTDBItem = New CTDBItem
    
    Set objCTDBItem.Parent = objParent
    
    objCTDBItem.ID = strID
    
    mCol.Add objCTDBItem, UCase$(objCTDBItem.ID)
    Set AddTestToDB = objCTDBItem
    Exit Function
ErrMgr:
    Set AddTestToDB = Nothing
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr


    Dim clsNode As CTDBItem
    Dim strS    As String
    
    For Each clsNode In Me
    
        strS = strS & clsNode.ToString() & vbCrLf
    Next
    ToString = strS

    Exit Function
ErrMgr:
  TRACE TESTHARNESS_ERROR_7000 & GetVBErrorString(), "CTDBItems.cls", "ToString", LOG_ERROR
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


Public Function SortOnOrder() As Boolean

    On Error GoTo ErrMgr

    sortUserDefinedCollection mCol, "Order"
    SortOnOrder = True
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CTDBItems.cls", "SortOnOrder", LOG_ERROR
End Function




' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : AddTestToSession
' PARAMETERS    :
' DESCRIPTION   : Add a test TDBItem to a session only
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function AddTestToSession(objTDBItem As CTDBItem) As CTDBItem

    On Error GoTo ErrMgr

    mCol.Add objTDBItem
   Set AddTestToSession = objTDBItem
    Exit Function
ErrMgr:
    Set AddTestToSession = Nothing
End Function


Public Function InsertTestsInToSession(objTDBItemsToInsert As CTDBItems, objTDBItemPasteAfter As CTDBItem) As Boolean

    On Error GoTo ErrMgr

    Dim i As Long
    
    If IsValidObject(objTDBItemPasteAfter) Then
        
        For i = objTDBItemsToInsert.Count To 1 Step -1
        
            InsertTestToSession objTDBItemsToInsert.Item(i).Clone(True, False), objTDBItemPasteAfter
        Next
    Else
            
        For i = 1 To objTDBItemsToInsert.Count
        
            InsertTestToSession objTDBItemsToInsert.Item(i).Clone(True, False), objTDBItemPasteAfter
        Next
    End If
    InsertTestsInToSession = True
Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CTDBItems.cls", "InsertTestsInToSession", LOG_ERROR
End Function


Public Function InsertTestToSession(objTDBItem As CTDBItem, objTDBItemPasteAfter As CTDBItem) As CTDBItem

    On Error GoTo ErrMgr

    '''''''''mCol.Add objTDBItem
    
    If IsValidObject(objTDBItemPasteAfter) Then
        mCol.Add objTDBItem, , , GetIndexFromLongID(objTDBItemPasteAfter.LongID)
    Else
        mCol.Add objTDBItem
    End If
    Set InsertTestToSession = objTDBItem
    Exit Function
ErrMgr:
    
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : MoveUpTestInTestSession
' PARAMETERS    :
' DESCRIPTION   : Moves the test in the TestSession one level up
' RETURN        : returns true if succeeds or false if fails

Public Function MoveUpTestInTestSession(currentObj As CTDBItem, prevObj As CTDBItem) As Boolean

    On Error GoTo ErrMgr
    
    Dim lngIndex1 As Long
    Dim lngIndex2 As Long
    
    lngIndex1 = GetIndexFromLongID(currentObj.LongID)
    lngIndex2 = GetIndexFromLongID(prevObj.LongID)
    
    Me.Remove lngIndex1
    
    mCol.Add currentObj, , before:=lngIndex2
    
    
    MoveUpTestInTestSession = True

Exit Function
ErrMgr: MoveUpTestInTestSession = False

End Function



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : MoveDownTestInTestSession
' PARAMETERS    :
' DESCRIPTION   : Moves the test in the TestSession one level down
' RETURN        : returns true if succeeds or false if fails

Public Function MoveDownTestInTestSession(currentObj As CTDBItem, nextObj As CTDBItem) As Boolean
    
    On Error GoTo ErrMgr
    
    Dim lngIndex1 As Long
    Dim lngIndex2 As Long
    
    lngIndex1 = GetIndexFromLongID(currentObj.LongID)
    lngIndex2 = GetIndexFromLongID(nextObj.LongID)
    
    Me.Remove lngIndex1
    
    mCol.Add currentObj, , After:=lngIndex2 - 1
    
    MoveDownTestInTestSession = True
    
    Exit Function
ErrMgr:
    
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
' DESCRIPTION   : This Add is used by the XMLLoader to add a test info to a test session. This add
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function Add(ByVal strID As String, Optional booNoKey As Boolean = False) As CTDBItem


    On Error GoTo ErrMgr
    
    Dim objTDBItem As New CTDBItem
        
    objTDBItem.ID = strID
    
    If (booNoKey) Then
    
        mCol.Add objTDBItem
    Else
        
        mCol.Add objTDBItem, UCase$(objTDBItem.ID)
    End If
    
    Set Add = objTDBItem
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function

Public Function FindWithID(ByVal lngID As Long) As CTDBItem

    On Error GoTo ErrMgr


    Dim objItem As CTDBItem
    For Each objItem In Me
    
        If (lngID = objItem.LongID) Then
            Set FindWithID = objItem
            Exit Function
        End If
    Next

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItems", "FindWithID"
End Function

Private Function GetIndexFromLongID(lngLongID As Long) As Long

    On Error GoTo ErrMgr


    Dim objItem As CTDBItem
    Dim i       As Long
    
    For i = 1 To Me.Count
        
        If (lngLongID = Me.Item(i).LongID) Then
            GetIndexFromLongID = i
            Exit Function
        End If
    Next
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItems", "GetIndexFromLongID"
End Function
