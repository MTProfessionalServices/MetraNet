VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CImportExportStats"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
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
' CREATION DATE : 07/25/2002
' VERSION       :
' DESCRIPTION   :
'*****************************************************************************
Option Explicit

Private mCol As Collection

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(PCObject As Object) As CImportExportStat
Attribute Item.VB_UserMemId = 0

   On Error GoTo ErrMgr
    Set Item = mCol(UCase$(TypeName(PCObject)))
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
'    Debug.Print Err.Description: Debug.Assert False
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
'    Debug.Print Err.Description: Debug.Assert False
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
'    Debug.Print Err.Description: Debug.Assert False
End Property

Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    Set mCol = New Collection

    Exit Sub
ErrMgr:
'    Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Clear
    Set mCol = Nothing

    Exit Sub
ErrMgr:
'    Debug.Print Err.Description: Debug.Assert False
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
'    Debug.Print Err.Description: Debug.Assert False
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
' DESCRIPTION   : Add a new item to the collection with the id strId and return and a reference of it.
'                 If the item already exist the function will fail!
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Private Function Add(PCObject As Object) As CImportExportStat

    On Error GoTo ErrMgr
    
    Dim objImportExportStat As New CImportExportStat
    
    objImportExportStat.ObjectType = UCase$(TypeName(PCObject))
    
    mCol.Add objImportExportStat, objImportExportStat.ObjectType
    Set Add = objImportExportStat
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
Public Function Exist(PCObject As Object) As Boolean

    On Error GoTo ErrMgr
    
    Dim objItem As Object
    Set objItem = mCol(UCase$(TypeName(PCObject)))
    Exist = True
    Exit Function
ErrMgr:
    Exist = False
    Err.Clear
End Function


Public Function AddNewObject(PCObject As Object, Optional ByVal strName As String) As Object

    Dim objStat As CImportExportStat
    
    On Error GoTo ErrMgr
    
    Debug.Print "AddNewObject " & TypeName(PCObject)
    If Me.Exist(PCObject) Then
        Set objStat = Item(PCObject)
    Else
        Set objStat = Add(PCObject)
    End If
    objStat.CreationCounter = objStat.CreationCounter + 1
    
    If Len(strName) Then
        objStat.AddCreationName strName
    Else
        objStat.AddCreationName MTObjectName(PCObject)
    End If
    
    
    Set AddNewObject = PCObject
    Exit Function
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "AddNewObject", LOG_ERROR
End Function

Public Function AddReUsedObject(PCObject As Object, Optional ByVal strName As String) As Object

    Dim objStat As CImportExportStat
    
    On Error GoTo ErrMgr
    
    If Not (PCObject Is Nothing) Then
        
        Debug.Print "AddReUsedObject " & TypeName(PCObject)
        If Me.Exist(PCObject) Then
            Set objStat = Item(PCObject)
        Else
            Set objStat = Add(PCObject)
        End If
        objStat.ReUsedCounter = objStat.ReUsedCounter + 1
        If Len(strName) Then
            objStat.AddReUsedName strName
        Else
            objStat.AddReUsedName MTObjectName(PCObject)
        End If
    End If
    Set AddReUsedObject = PCObject
    Exit Function
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "AddReUsedObject", LOG_ERROR
End Function

Public Function GetSummaryString() As String

    Dim objStat             As CImportExportStat
    Dim s                   As String
    Dim CreationCounter     As Long
    Dim ReUsedCounter       As Long
    
    On Error GoTo ErrMgr
    
    ' -- Sum the object creation --
    
    s = s & "STATISTICS" & vbNewLine
    s = s & "Objects Created" & vbNewLine
    For Each objStat In Me
        If objStat.CreationCounter Then s = s & objStat.CreationCounter & " " & objStat.ObjectType & " " & objStat.GetCreationNamesAsString() & vbNewLine
        CreationCounter = CreationCounter + objStat.CreationCounter
    Next
    s = s & vbNewLine
    
    s = s & "Objects ReUsed" & vbNewLine
    For Each objStat In Me
    
        If objStat.ReUsedCounter Then s = s & objStat.ReUsedCounter & " " & objStat.ObjectType & " " & objStat.GetReUsedNamesAsString() & vbNewLine
        
        ReUsedCounter = ReUsedCounter + objStat.ReUsedCounter
    Next
    s = s & vbNewLine
    
    If CreationCounter = 0 And ReUsedCounter = 0 Then
    
        MTPCImportExportModule.TRACE MTPCImportExport_WARNING_1020, Me, "GetSummaryString", LOG_WARNING
    End If
    GetSummaryString = s
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "GetSummaryString", LOG_ERROR
End Function
