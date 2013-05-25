VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXHandlers"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'****************************************************************************************************************************************************
'
' Copyright 1998-2002 by MetraTech Corporation
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
' ****************************************************************************
' CLASS         :
' AUTHOR        : F.Torres
' CREATION DATE : 06/06/2002
' VERSION       :
' DESCRIPTION   : MetraTech Extentable Service.
'
'
' $Date$
' $Author$
' $Revision$
' $Workfile$
'
'
'
'*****************************************************************************
Option Explicit

Public TRACE_ID As Long

Private mCol As Collection

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(vntKey As Variant) As MSIXHandler
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
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Clear
    Set mCol = Nothing
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
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
Public Function Add(Optional ByVal strType As String, Optional ByVal objMSIXHandlerLoaded As MSIXHandler, Optional ByVal strLanguage As String = "US", Optional ByVal strVersion As String = "3.5") As MSIXHandler

    On Error GoTo ErrMgr
    
    If Not IsValidObject(objMSIXHandlerLoaded) Then ' we need to load the metadata
    
        Set objMSIXHandlerLoaded = New MSIXHandler
        
        If Not objMSIXHandlerLoaded.Initialize(strType & ".msixdef", , strLanguage, , , , , strVersion) Then
            Exit Function
        End If
    End If
    
    objMSIXHandlerLoaded.ChildKey = MTXServiceModule.GetUniqueStringID()
    mCol.Add objMSIXHandlerLoaded, objMSIXHandlerLoaded.ChildKey
    Set Add = objMSIXHandlerLoaded

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


' -------------------------------------------------------------------------------
' FUNCTION      : Exist
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Returns TRUE if the item exist in the collection. The method is not case sensitive.
' RETURN        :
Public Function UpdateProperty(ByVal strPropertyName As String, ByVal strNewValue As Variant, Optional ByVal strOperator As String, Optional ByVal varCompareValue As Variant) As Long

    Dim objChild            As MSIXHandler
    Dim objMSIXProperty     As MSIXProperty
    Dim booExp              As Boolean
    Dim lngUpdateCount      As Long
    
    On Error GoTo ErrMgr
    
    For Each objChild In Me
    
        booExp = False
        
        If objChild.Properties.Exist(strPropertyName) Then
        
            Set objMSIXProperty = objChild.Properties(strPropertyName)
            
            If objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_METERED Then
            
                If (Len(strOperator) = 0) Then ' All or do we have an operator
                    
                    booExp = True
                Else
                
                
                    Select Case UCase$(strOperator)
                        
                        Case "="
                        
                            Select Case UCase$(objMSIXProperty.PropertyType) ' Apply type checking
                            
                                Case MSIXDEF_TYPE_DOUBLE: booExp = CDbl(varCompareValue) = CDbl(objMSIXProperty.Value)
                                Case MSIXDEF_TYPE_FLOAT: booExp = CSng(varCompareValue) = CSng(objMSIXProperty.Value)
                                Case MSIXDEF_TYPE_INT32: booExp = CLng(varCompareValue) = CLng(objMSIXProperty.Value)
                                Case MSIXDEF_TYPE_DECIMAL: booExp = CDec(varCompareValue) = CDec(objMSIXProperty.Value)
                                Case MSIXDEF_TYPE_BOOLEAN: booExp = CBool(varCompareValue) = CBool(objMSIXProperty.Value)
                                Case MSIXDEF_TYPE_TIMESTAMP: booExp = CDate(varCompareValue) = CDate(objMSIXProperty.Value)
                                Case Else ' MSIXDEF_TYPE_ENUM, MSIXDEF_TYPE_STRING
                                    booExp = CStr(varCompareValue) = CStr(objMSIXProperty.Value)
                            End Select
                            
                        Case "LIKE"
                        
                            booExp = CStr(objMSIXProperty.Value) Like CStr(varCompareValue)
                    End Select
                End If
                If booExp Then
                    objMSIXProperty.Value = strNewValue
                    lngUpdateCount = lngUpdateCount + 1
                End If
            End If
        End If
    
    Next
    UpdateProperty = lngUpdateCount
Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "UpdateProperty", LOG_ERROR
  RaiseError MTMSIX_ERROR_01033 & GetVBErrorString(), TypeName(Me)
End Function
