VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CIECache"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 6/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

'--end block--'
 

Private mCol As Collection

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(vntKey As Variant) As CIECacheEntry
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
' DESCRIPTION   : Remove the item from the collection. The method is not case sensitive.
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
    


    Set mCol = New Collection
    Clear = True
    Exit Function
errmgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
' DESCRIPTION   : Add a new item to the collection with the id strId and return and a reference of it.
'                 If the item already exist the function will fail!
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function Add(strName As String) As CIECacheEntry

    On Error GoTo errmgr
    
    Dim IECacheEntry As New CIECacheEntry
    
    IECacheEntry.URL = strName
    
    mCol.Add IECacheEntry, LCase$(strName)
    
    Set Add = IECacheEntry
    Exit Function
errmgr:
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo errmgr

    Dim clsNode  As CIECacheEntry
    Dim strS As String
    For Each clsNode In Me
        strS = strS & clsNode.ToString() & vbNewLine
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




Public Function Load() As Boolean
    
   Dim ICEI             As INTERNET_CACHE_ENTRY_INFO
   Dim hFile            As Long
   Dim cachefile        As String
   Dim posUrl           As Long
   Dim posEnd           As Long
   Dim dwBuffer         As Long
   Dim pntrICE          As Long
   
   #If W3RUNNER_DEFINE Then
        frmMain.TRACE PreProcess("W3Runner.IECache.Load"), w3rMETHOD
   #End If
   
   Clear
   
  'Like other APIs, calling FindFirstUrlCacheEntry or
  'FindNextUrlCacheEntry with an insufficient buffer will
  'cause the API to fail, and the buffer pointing to the
  'correct size required for a successful call.
   dwBuffer = 0

  'Call to determine the required buffer size
   hFile = FindFirstUrlCacheEntry(0&, ByVal 0, dwBuffer)
   
  'both conditions hould be met by the first call
   If (hFile = ERROR_CACHE_FIND_FAIL) And _
      (Err.LastDllError = ERROR_INSUFFICIENT_BUFFER) Then
   
     'The INTERNET_CACHE_ENTRY_INFO data type is a
     'variable-length type. It is neccessary to allocate
     'memnory for the result of the call and pass the
     'pointer to this memory location to the API.
      pntrICE = LocalAlloc(LMEM_FIXED, dwBuffer)
        
     'allocation successful
      If pntrICE Then
         
        'set a Long pointer to the memory location
         CopyMemory ByVal pntrICE, dwBuffer, 4
         
        'and call the first find API again passing the
        'pointer to the allocated memory
         hFile = FindFirstUrlCacheEntry(vbNullString, ByVal pntrICE, dwBuffer)
       
        'hfile should = 1 (success)
         If hFile <> ERROR_CACHE_FIND_FAIL Then
         
           'loop through the cache
            Do
            
              'the pointer has ben filled, so move the
              'data back into a ICEI structure
               CopyMemory ICEI, ByVal pntrICE, Len(ICEI)
            
              'CacheEntryType is a long representing
              'the type of entry returned
               If (ICEI.CacheEntryType And _
                   NORMAL_CACHE_ENTRY) = NORMAL_CACHE_ENTRY Then
               
                 'extract the string from the memory location
                 'pointed to by the lpszSourceUrlName member
                 'and add to a list
                  cachefile = GetStrFromPtrA(ICEI.lpszSourceUrlName)
                  Add cachefile
               End If
               
              'free the pointer and memory associated
              'with the last-retrieved file
               Call LocalFree(pntrICE)
               
              'and again repeat the procedure, this time calling
              'FindNextUrlCacheEntry with a buffer size set to 0.
              'This will cause the call to once again fail,
              'returning the required size as dwBuffer
               dwBuffer = 0
               Call FindNextUrlCacheEntry(hFile, ByVal 0, dwBuffer)
               
              'allocate and assign the memory to the pointer
               pntrICE = LocalAlloc(LMEM_FIXED, dwBuffer)
               CopyMemory ByVal pntrICE, dwBuffer, 4
               
           'and call again with the valid parameters.
           'If the call fails (no more data), the loop exits.
           'If the call is successful, the Do portion of the
           'loop is executed again, extracting the data from
           'the returned type
            Loop While FindNextUrlCacheEntry(hFile, ByVal pntrICE, dwBuffer)
  
         End If 'hFile
         
      End If 'pntrICE
   
   End If 'hFile
   
  'clean up by closing the find handle, as
  'well as calling LocalFree again to be safe
   Call LocalFree(pntrICE)
   Call FindCloseUrlCache(hFile)
   Load = True
   
End Function


Private Function GetStrFromPtrA(ByVal lpszA As Long) As String

   GetStrFromPtrA = String$(lstrlenA(ByVal lpszA), 0)
   Call lstrcpyA(ByVal GetStrFromPtrA, ByVal lpszA)
End Function
 
Public Function DeleteAll(Optional ByVal strWildCard As String, Optional ByVal booTrace As Boolean = True) As Boolean

    #If W3RUNNER_DEFINE Then
        If booTrace Then
        frmMain.TRACE PreProcess("W3Runner.IECache.DeleteAll ""[WILDCARD]""", "WILDCARD", strWildCard), w3rMETHOD
        End If
    #End If
    
    If Not Me.DeleteCookies(strWildCard, False) Then Exit Function
    If Not Me.DeleteFiles(strWildCard, False) Then Exit Function
    DeleteAll = True
End Function

Public Function DeleteFiles(Optional ByVal strWildCard As String, Optional ByVal booTrace As Boolean = True) As Boolean

    Dim objCacheEntry As CIECacheEntry
    
    #If W3RUNNER_DEFINE Then
        If booTrace Then
            frmMain.TRACE PreProcess("W3Runner.IECache.DeleteFiles ""[WILDCARD]""", "WILDCARD", strWildCard), w3rMETHOD
        End If
    #End If
    
    For Each objCacheEntry In Me
    
        If Not objCacheEntry.IsCookie Then
            objCacheEntry.Delete strWildCard, booTrace
        End If
    Next
    DeleteFiles = True
End Function

Public Function DeleteCookies(Optional ByVal strWildCard As String, Optional ByVal booTrace As Boolean = True) As Boolean

    Dim objCacheEntry As CIECacheEntry
    
    
    #If W3RUNNER_DEFINE Then
        If booTrace Then
            frmMain.TRACE PreProcess("W3Runner.IECache.DeleteCookies ""[WILDCARD]""", "WILDCARD", strWildCard), w3rMETHOD
        End If
    #End If
    
    For Each objCacheEntry In Me
    
        If objCacheEntry.IsCookie Then
        
            objCacheEntry.Delete strWildCard
        End If
    Next
    DeleteCookies = True
End Function

