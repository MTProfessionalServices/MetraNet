VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MDMForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' ****************************************************************************************************************************************************
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
' CREATION DATE : 08/21/2000
' VERSION       : 1.0
' DESCRIPTION   : This class was created so by using it in vbscript mdm asp file
'                 we have a syntax that look like a real object oriented frame work!
'                 plus it will allow us to extend this logical structure easely.
'
'                 This class implement a collection a of CVariable I had to do that rather
'                 than directly use a CVariables because there were some syntax problem.
'                 And I want this ojbect to behave like a IIS Session object.
'                 We can set a new value this way :
'                       Form("Name")        =   "Fred"
'                       Set Form("Rowset")  =   objRowset
'
'
'
'
' $Date: 4/4/2002 12:41:14 PM$
' $Author: Frederic Torres$
' $Revision: 38$
' $Workfile: MDMForm.cls$
'
'
'
' ****************************************************************************************************************************************************
Option Explicit

' --- MDM v1 Properties ---
Public ServiceMsixdefFileName       As String
Public RouteTo                      As String
Public HTMLTemplateFileName         As String
Public ProductViewMsixdefFileName   As String
Public HelpFile                     As String
Public Initialized                  As Boolean          ' Tell/store if the initialized event succeed
Public Localize                     As Boolean          ' Gets ot sets if we localize the service.
Public Page                         As New MDMPage

' MDM V2
Public Version                      As String           ' Initialized to 1.0 be default. The Programmer must set the correct version of the MDM supported. Some Optimization and New feature become then available...
Public HTMLTemplateSource           As String
Public JavaScriptInitialize         As String           ' The variables can contains some JavaScript that will be executed the next time the dialog is rendered. One the dialog is rendered this variables is cleared.
Public Modal                        As Boolean          'If the dialog is opened in a pop up window. If true the MDM does not close the window on the OK or CANCEL event but just ask for a refresh. The dialog client must set the property JavaScriptInitialize.
Public ErrorHandler                 As Boolean          ' If true the MDM work flow catch and display error from the form event

' MDM v2.1
Public ShowExportIcon               As Boolean          ' MDM v2.1 - default value is false



Private mCol                        As Collection

' --- MDM v2 Properties ---
Public TRACE_ID As Long
Private m_objTabs                    As MDMTabs      ' MDM v2
Private m_objGrids                   As MDMGrids     ' MDM v2
Private m_objWidgets                 As MDMWidgets   ' MDM v2
Private m_objGrid                    As MDMGrid      ' Product View Grid info

' Private MDM v2.2
Public MsixdefExtension              As String       ' Set the default extension where to read the msixdef file. default value core. have a property in the MDMForm and MSIXHandler
                                                     ' object because the in a MDM Dialog work flow when the service object is available  (FORM_Initialize event) it is already to
                                                     ' late the service has been loaded. so we need to set this property in the FORM object at the beginning og the file
                                                     ' and the asp function  mdm_CreateServiceInstance() will set the Service.MsixdefExtension.
' -- MDM 3.0
Private m_objSerializer As New CCOMSerializer

' -- MDM 3.5
Public OnDisplayEndOfPageJavaScript                   As String
Public CallParentPopUpWithNoURLParameters             As Boolean ' Default false old behavior
Public LoginDialog                                    As Boolean ' The dialog can mark the dialog as LoginDialog, there for we hande time out on login dialog.
Public LoginDialogRouteTo                             As String

Private Sub Class_Initialize()

    On Error GoTo ErrMgr

   #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If
    Set mCol = New Collection
    Localize = True
    MsixdefExtension = ""
    
    Version = MDM_VERSION_13 ' For Compatibility reason...
    
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMForm.cls", "Class_Initialize", LOG_ERROR
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr


    If (IsValidObject(m_objTabs)) Then m_objTabs.Clear
    Set m_objTabs = Nothing
    Clear
    Set mCol = Nothing
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMForm.cls", "Class_Terminate", LOG_ERROR
End Sub

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   : Remove all the items in the collection. If the item is no more referenced it is deleted and its destructor
'                 Class_Terminate event is raised.
' RETURN        : TRUE if Ok.
Public Function Clear() As Boolean

    On Error GoTo ErrMgr
    
    Do While Count > 0
        Remove 1
    Loop
    Clear = True
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE
    #End If

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMForm.cls", "Clear", LOG_ERROR
End Function



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Removes the item from the collection. The method is not case sensitive.
' RETURN        : Returns TRUE if OK
Public Function Remove(vntKey As Variant) As Boolean
    On Error GoTo ErrMgr
    
    If IsNumeric(vntKey) Then
         mCol.Remove vntKey
    Else
        mCol.Remove UCase$(vntKey)
    End If
    Remove = True
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMForm.cls", "Remove", LOG_ERROR
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
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMForm.cls", "Count", LOG_ERROR
End Property

Public Property Get NewEnum() As IUnknown ' Documented=no
Attribute NewEnum.VB_UserMemId = -4
    On Error GoTo ErrMgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMForm.cls", "NewEnum", LOG_ERROR
End Property






' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
'                   strName     -   The name of the variable
'                   varValue    -   The value of the variable. Can be an COM object.
' DESCRIPTION   :
'
' RETURN        :
Public Function Add(ByVal strName As String, Optional ByVal varValue As Variant) As CVariable

    On Error GoTo ErrMgr
      
    Dim clsV As CVariable
        
    Set clsV = New CVariable ' Now we can create an object
    
    If (Exist(strName)) Then Me.Remove strName ' Remove the instance if already exist...
    
    clsV.Name = strName
    If (IsObject(varValue)) Then
    
        Set clsV.Value = varValue
    Else
    
        clsV.Value = varValue
    End If
    
    mCol.Add clsV, UCase$(strName)
    
    Set Add = clsV
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string.
' RETURN        :
Public Function ToString(Optional booEnter As Boolean = True, Optional strSeparator As String = ";", Optional strDCote As String = """", Optional booIncludeType As Boolean = True) As String
    Dim clsV As CVariable
    Dim strS As String
    
    For Each clsV In Me
    
        strS = strS & clsV.ToString(strSeparator, strDCote, booIncludeType)
    Next
    ToString = strS
End Function


' -------------------------------------------------------------------------------
' FUNCTION      : Exist
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Returns TRUE if the item exist in the collection.
' RETURN        :
Public Property Get Exist(vntKey As Variant) As Boolean
   On Error GoTo ErrMgr
   
   Dim Itm                  As CVariable
   
   Set Itm = mCol(vntKey)
   Exist = True
   Exit Property
ErrMgr:
    Exist = False
   Err.Clear
End Property




' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns the instance of CVariableThis method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
'
' RETURN        :
Public Property Get Item(vntKey As Variant) As Variant
Attribute Item.VB_UserMemId = 0

   On Error GoTo ErrMgr
   
   Dim objVar As CVariable
      
   If IsNumeric(vntKey) Then
        Set objVar = mCol(CLng(vntKey))
   Else
        Set objVar = mCol(UCase$(vntKey))
   End If
   
   If (IsObject(objVar.Value)) Then
   
        Set Item = objVar.Value ' return a ref to the object stored
   Else
         Set Item = objVar ' return the value
   End If
   
   Exit Property
ErrMgr:
    If Not IsNumeric(vntKey) Then
    
        Err.Clear
        Set objVar = Me.Add(vntKey, Empty)
        Set Item = objVar
        Exit Property
    End If
    Set Item = Nothing
End Property

' -------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Let Item(vntKey As Variant, varValue As Variant)

    Dim objVar As CVariable

    ' we just want to store the value
    ' This test allow to support this case : Form("ShowCheckBox") = Form("ShowButtonRetry")
    If (UCase$(TypeName(varValue)) = "CVARIABLE") Then
    
        Set objVar = Me.Add(vntKey, varValue.Value) ' Remove and add
    Else
        Set objVar = Me.Add(vntKey, varValue) ' Remove and add
    End If
End Property

' -------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Set Item(vntKey As Variant, objObject As Object)

    Dim objVar As CVariable
    
    If (Not Me.Exist(vntKey)) Then
        
        Me.Add vntKey, objObject
    Else
        Me.Add vntKey, objObject ' Remove and Add
    End If
End Property

Public Property Get Tabs() As MDMTabs

    If (Not IsValidObject(m_objTabs)) Then
    
        Set m_objTabs = New MDMTabs
    End If
    Set Tabs = m_objTabs
End Property

Public Property Get Grids() As MDMGrids

    If (Not IsValidObject(m_objGrids)) Then
    
        Set m_objGrids = New MDMGrids
    End If
    Set Grids = m_objGrids
End Property

Public Function WidgetsDefined() As Boolean
    WidgetsDefined = IsValidObject(m_objWidgets)
End Function

Public Function TabsDefined() As Boolean
    TabsDefined = IsValidObject(m_objTabs)
End Function

Public Function GridsDefined() As Boolean
    GridsDefined = IsValidObject(m_objGrids)
End Function

Friend Function RenderGridJavaScript() As String

    On Error GoTo ErrMgr
    
    Dim objGrid             As MDMGrid
    Dim strJavaScript       As String
    
    If (Not GridsDefined()) Then Exit Function
        
    strJavaScript = strJavaScript & vbNewLine
    strJavaScript = strJavaScript & "<!-- Grid(s) Information -->"
    strJavaScript = strJavaScript & vbNewLine
    
    ' Generate a call to a function to resize each grid
    For Each objGrid In Me.Grids
    
        If (objGrid.Visible) Then
        
            strJavaScript = strJavaScript & "mdm_ResizeGrid('" & objGrid.Name & "');" & vbNewLine
        End If
    Next
    
    ' Generate the JavaScript const for each grid : Width and Height
    For Each objGrid In Me.Grids
    
        If (objGrid.Visible) Then
        
            strJavaScript = strJavaScript & objGrid.RenderGridJavaScript()
        End If
    Next
    RenderGridJavaScript = strJavaScript
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & RenderGridJavaScript(), "MDMForm.cls", "RenderGridJavaScript", LOG_ERROR
End Function

Public Property Get Widgets() As MDMWidgets

    If (Not IsValidObject(m_objWidgets)) Then
    
        Set m_objWidgets = New MDMWidgets
    End If
    Set Widgets = m_objWidgets
End Property

Public Property Get Grid() As MDMGrid
    If (Not IsValidObject(m_objGrid)) Then
        ''Debug.Assert 0
        Set m_objGrid = New MDMGrid
    End If
    Set Grid = m_objGrid
End Property

Private Property Get PropertiesList() As String

    PropertiesList = "HelpFile,HTMLTemplateFileName,HTMLTemplateSource,JavaScriptInitialize,Localize,Modal,MsixdefExtension,ProductViewMsixdefFileName,ServiceMsixdefFileName,ShowExportIcon,Version"
End Property


Public Property Get Serialize() As String
    m_objSerializer.PropertiesCSVList = PropertiesList
    Serialize = m_objSerializer.Serialize(Me)
End Property

Public Property Let Serialize(ByVal vNewValue As String)
    m_objSerializer.Serialize(Me) = vNewValue
End Property
