VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXEnumTypeEntries"
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
'
' MODIFIED      : $Date$
' LAST AUTHOR   : $Author$
' REVISION      : $Revision$
' FILENAME      : $Workfile$
'
' * *  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
' CLASS         : MSIXEnumTypeEntries
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   :
'                   This object implements a collection of MSIXEnumTypeEntry.
'                   Some of the properties and methods of this object are reserved by the MetraTech Dialog Manager VBScript layer.
'
'                   This object cannot be created directly, but can be created through an instance of the object MSIXHandler as a service
'                   or a product view object. Initializing an MSIXHandler object as a service or a product view automatically loads all the enum types and their localization.
'
'                   Refer to the "Metratech Dialog Manager Programming Guide" for more information.
'

'
'**********************************************************************************************************************************************************
Option Explicit

Public TRACE_ID As Long
Private mCol    As Collection
Public Id       As String

'Public NameSpace    As String
'Public EnumTypeName As String
'Public Language     As String


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1. If vntKey is Null or Empty the property
'                   return the first item of the collection if there is a first item else <code>Nothing</code>.
'
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(ByVal vntKey As Variant) As MSIXEnumTypeEntry
Attribute Item.VB_UserMemId = 0


   On Error GoTo ErrMgr
   
   ' This allows to deals with values that come none initialized from the database...
   ' This might add some confusion some time...
   ' This will be documented in the MDM Programming guide...
   If (IsNull(vntKey) Or IsEmpty(vntKey)) Then
   
        If (Me.Count) Then vntKey = CLng(1)
   End If
   
   If IsNumeric(vntKey) Then
        Set Item = mCol(vntKey)
   Else
        Set Item = mCol(UCase$(vntKey))
   End If
   Exit Property
ErrMgr:
    TRACE Replace(MTMSIX_ERROR_01072, "[ENTRY]", CStr(vntKey)), "MSIXEnumTypeEntries.cls", "Item", LOG_ERROR
    RaiseError Replace(MTMSIX_ERROR_01072, "[ENTRY]", CStr(vntKey)), "MTMSIX.MSIXEnumTypeEntries", , LOG_APPLICATION_ERROR
    Set Item = Nothing
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Removes the item from the collection. The method is not case sensitive.
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
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Class_Terminate
' PARAMETERS    :
' DESCRIPTION   : Free the collection.
' RETURN        :
Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Clear
    Set mCol = Nothing
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If
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
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE
    #End If

    Do While Count > 0
    
        'Me.Item(1).Delete
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
'                 strName - The name of the enum type item (also called enumerator).
'                 varValue - The value of the enum type item. A MetraTech Enum Type Item can have more that one value but this object only use the first one.
'                 strCaption - The localization of the enum type.
' DESCRIPTION   : Add a new item to the collection and return and a reference of it. strName is the key of the collection.
'                 If the item already exist it is overwritten.
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function Add(ByVal strName As String, Optional ByVal varValue As Variant, Optional ByVal strCaption As String) As MSIXEnumTypeEntry

    On Error GoTo ErrMgr
    
    Dim objMSIXEnumTypeEntry As New MSIXEnumTypeEntry
        
    objMSIXEnumTypeEntry.Name = strName
    
    If (Me.Exist(strName)) Then Me.Remove strName
        
    mCol.Add objMSIXEnumTypeEntry, UCase$(objMSIXEnumTypeEntry.Name)
    
    objMSIXEnumTypeEntry.Value = varValue
    
    objMSIXEnumTypeEntry.Caption = strCaption
    
    Set Add = objMSIXEnumTypeEntry
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the content of the object in a string.
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr

    Dim clsNode As MSIXEnumTypeEntry
    Dim strS    As String
    
    For Each clsNode In Me
        strS = strS & clsNode.ToString() & vbCrLf
    Next
    ToString = strS

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXEnumEntries.cls", "ToString", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ItemByValue
' PARAMETERS    :
'                   vntKey - The value used to do the look up.
'
' DESCRIPTION   : Returns an item in the collection based on the enum type item value rather that on the enum type
'                 name. This method is the default method is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get ItemByValue(ByVal vntValue As Variant) As MSIXEnumTypeEntry

   On Error GoTo ErrMgr
   
   Dim objVar   As MSIXEnumTypeEntry
   Dim strError As String
   
   For Each objVar In Me
        If UCase$(CStr(objVar.Value)) = UCase$(CStr(vntValue)) Then
        
            Set ItemByValue = objVar
            Exit Property
        End If
   Next
   Exit Property
ErrMgr:
    
    strError = MTMSIX_ERROR_01078
    strError = Replace(strError, "[VALUE]", CStr(vntValue))
    strError = Replace(strError, "[TOSTRING]", Me.ToString())
    TRACE strError, "MSIXEnumTypeEntries.cls", "ItemByValue", LOG_ERROR
    
    Set ItemByValue = Nothing
    
End Property


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
    'TRACE "Exist? " & strPropertyName & " YES"
    Exist = True
    Exit Function
ErrMgr:
    'TRACE "Exist? " & strPropertyName & " FALSE"
    Exist = False
    Err.Clear
End Function


' -------------------------------------------------------------------------------
' FUNCTION      : Populate
' PARAMETERS    :
' DESCRIPTION   : Populate a Cvariable object with the enum type names and values!
' RETURN        :
Public Function Populate(ByVal objVariables As CVariables) As Boolean 'documented=no

    Dim objVar As CVariable
    
    For Each objVar In objVariables
    
        Me.Add objVar.Name, objVar.Value, objVar.Caption
    Next
    Populate = True
End Function
