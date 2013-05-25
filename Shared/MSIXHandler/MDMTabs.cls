VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MDMTabs"
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
' ****************************************************************************
' CLASS         :
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
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

Public TRACE_ID         As Long
Public Name             As String ' The name of the tab
Public HTMLRendered     As Variant

Private mCol As Collection
Private m_lngSelectedItem As Long

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
' DESCRIPTION   : Add a new tab to the collection with the id strId and return and a reference of it.
'                 If the item already exist the function will fail!
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function Add(varKey As Variant, Optional varCaption As Variant, Optional varToolTipText As Variant) As MDMTabItem

    On Error GoTo ErrMgr
    
    Dim objMDMTabItem As New MDMTabItem
        
    objMDMTabItem.Key = varKey
    objMDMTabItem.Caption = IIf(IsMissing(varCaption), Empty, varCaption)
    objMDMTabItem.ToolTipText = IIf(IsMissing(varToolTipText), Empty, varToolTipText)
    Set objMDMTabItem.Parent = Me
    
    
    mCol.Add objMDMTabItem, UCase$(objMDMTabItem.Key)
    objMDMTabItem.Index = mCol.Count
    
    If (mCol.Count = 1) Then
        objMDMTabItem.Selected = True
    End If
    
    Set Add = objMDMTabItem
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(vntKey As Variant) As MDMTabItem
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
    m_lngSelectedItem = 1
    
    Name = "Tabs"
  
    #If LOG_OBJECT_INFO Then
       TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), TypeName(Me) & ".cls", "Class_Initialize", LOG_ERROR
End Sub

Private Sub Class_Terminate()

On Error GoTo ErrMgr
    
    Clear
    Set mCol = Nothing
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), TypeName(Me) & ".cls", "Class_Terminate", LOG_ERROR
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
        Me.Item(1).Delete
        Remove 1
    Loop
    Clear = True
    Exit Function
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr

    Dim clsNode As MDMTabItem
    Dim strS As String
    For Each clsNode In Me
        strS = strS & clsNode.ToString() & vbCrLf
    Next
    ToString = strS

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMTabItems.cls", "ToString", LOG_ERROR
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


Public Property Get SelectedItem() As MDMTabItem

    Dim objTab As MDMTabItem
    
    For Each objTab In Me
    
        If (objTab.Selected) Then
        
            Set SelectedItem = objTab
            Exit Property
        End If
    Next

End Property



Private Function Rende(ByVal strMDMDir As String, ByVal strTABSHTMLTemplate As String, ByVal strMainDialogHTMLTemplate As String) As String

    On Error GoTo ErrMgr

    Dim strFileName As String
    Dim objTextFile As New cTextFile
    Dim strIn       As String
    Dim strOut      As String
    Dim objTab      As MDMTabItem
    Dim objPP       As New CPreProcessor: objPP.standardVar
    Dim strStringIDChars As String
    Dim strHTMLSubTemplate As String
    Dim strIn2      As String
            
    strFileName = strTABSHTMLTemplate
    objPP.Add "NAME", Me.Name
    
    If (objTextFile.OpenFile(strFileName)) Then
    
        Do While Not objTextFile.EOF()
        
            strIn = objTextFile.ReadLn()
            
            If (Len(strIn)) Then ' Test the size before calling the VB mid$() function, because it does not like empty string.
            
                If (Mid$(Trim(strIn), 1, 1) = "#") Then
                
                    For Each objTab In Me
                    
                        objPP.Add "CAPTION", objTab.Caption
                        objPP.Add "KEY", objTab.Key
                        objPP.Add "INDEX", objTab.Index
                        objPP.Add "TOOLTIP", objTab.ToolTipText
                        objPP.Add "SELECTED", objTab.Selected
                        objPP.Add "SELECTED_STRING", IIf(objTab.Selected, "Selected", "UnSelected")
                                                
                        strOut = strOut & objPP.Process(Mid$(strIn, 2), "[", "]") & vbCrLf
                        
                        If (objTab.Selected) Then ' Set filename for the contain of the tab
                            strHTMLSubTemplate = Mid(strMainDialogHTMLTemplate, 1, Len(strMainDialogHTMLTemplate) - 4) & "." & objTab.Key & ".htm"
                        End If
                    Next
                Else
                    strOut = strOut & strIn & vbCrLf
                End If
            Else
                strOut = strOut & vbCrLf
            End If
        Loop
        objTextFile.CloseFile
        
        
        Rende = strOut & vbNewLine & objTextFile.LoadFile(strHTMLSubTemplate)
    End If
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMTabs.cls", "Render", LOG_ERROR
End Function

Public Function ClearSelection() As Boolean

    Dim objTab As MDMTabItem
    For Each objTab In Me
    
        objTab.Selected(False) = False
    Next
    ClearSelection = True
End Function


