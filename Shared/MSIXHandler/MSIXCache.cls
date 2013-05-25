VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXCache"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'****************************************************************************************************************************************************
'
' Copyright 1998-2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'****************************************************************************************************************************************************
' CLASS         :
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   : MSIXCache object. A MSIXHandler object may use an instance of the class
'                 to cache the following objects :
'                   - Name Space COM Object
'                   - Enum Type list stored CVariables, used by MSIXEnumType
'                   - Service/product view property localizated caption
'                   - Any kind of data...
'
'               An MSIXHandler, MSIXProperties, MSIXProperty, MSIXTool object may work with or without
'               a MSIXCache object. The application using the MSIXHandler object is reponsible for creating the cache
'               and giving the cache to the MSIXHandler through the method Initialize.
'               The application is responsible for deleting the cache too!
'
'               This call implement a COM Collection of the class MSIXCacheItem!
'               A MSIXCacheItem is a name and a data. the data is a variant that can store any thing event
'               a reference to an object.
'
' $Date$
' $Author$
' $Revision$
' $Workfile$
'
'
'****************************************************************************************************************************************************
Option Explicit

Private mCol As Collection

Public Name             As String
Public CreationTime     As Date
Public TRACE_ID         As Long


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(vntKey As Variant) As MSIXCacheItem
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
    
    'Dim strS As String
    'strS = MTMSIX_ERROR_01038
    'strS = Replace(strS, "[NAME]", Item(vntKey).Name)
    'strS = Replace(strS, "[TYPE]", TypeName(Item(vntKey).Data))
    'TRACE strS, "Cache.cls", "Remove", LOG_WARNING
    
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
    CreationTime = MTNow()
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    Exit Sub
errmgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()

    On Error GoTo errmgr
    
    Clear
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    
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
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE, "name=" & Me.Name
    #End If

    Do While Count > 0
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
' DESCRIPTION   : Add a new item to the collection with the id strId and return and a reference of it.
'                 If the item already exist it is overwritten.
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function Add(Optional strId As String, Optional varData As Variant) As MSIXCacheItem

    On Error GoTo errmgr
    
    Dim objMSIXCacheItem As New MSIXCacheItem
    
    objMSIXCacheItem.Id = strId
    'objMSIXCacheItem.CacheName = Me.Name
    'objMSIXCacheItem.CacheCreationTime = CreationTime
    
    If (Len(strId) = 0) Then
        mCol.Add objMSIXCacheItem
    Else
        If (Me.Exist(strId)) Then
        
            Me.Remove strId
        End If
        mCol.Add objMSIXCacheItem, UCase$(objMSIXCacheItem.Id)
    End If
    
    If (Not IsMissing(varData)) Then
    
        If (IsObject(varData)) Then
        
            Set objMSIXCacheItem.Data = varData
        Else
            objMSIXCacheItem.Data = varData
        End If
    End If
    Set Add = objMSIXCacheItem
    Exit Function
errmgr:
    Set Add = Nothing
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo errmgr

    Dim clsNode As MSIXCacheItem
    Dim strS    As String
    
    For Each clsNode In Me
    
        strS = strS & clsNode.ToString() & vbCrLf
    Next
    ToString = strS

    Exit Function
errmgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Cache.cls", "ToString", LOG_ERROR
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

Public Function GetObject(ByVal strProgIdName As String, Optional ByVal strObjectName As String) As Object
    
    Dim strFQObjectName As String
    Dim obj             As Object
    
    On Error GoTo errmgr
    
    strFQObjectName = "OBJECT:" & strProgIdName & "." & strObjectName
    
    If (Me.Exist(strFQObjectName)) Then
        
        Set GetObject = Me.Item(strFQObjectName).Data   ' Return the object from the cache
    Else
        Set obj = CreateObject(strProgIdName)   ' Create the object
        Me.Add strFQObjectName, obj             ' Store the object in the cache
        Set GetObject = obj                     ' Return the object
    End If
    Exit Function
errmgr:

  ' THIS PROPERTY MUST ABSOLUTELY RAISE ANY ERRORS... THAT IS THE WAY WE TELL THE CLIENT ABOUT A TYPE MISMATCH
  Err.Raise Err.Number, Err.Source, Err.Description

End Function
