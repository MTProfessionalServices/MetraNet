VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MDMGrid"
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
' $Date: 9/27/2002 12:56:22 PM$
' $Author: Frederic Torres$
' $Revision: 37$
' $Workfile: MDMGrid.cls$
'
Option Explicit

Public TRACE_ID As Long

' --- MDM v3.5 Properties ---
Public RenderCurrentRowOnly As Boolean ' For MDMGrid only
Public SelectRowMode        As Boolean ' Default false
Public PropertyID           As MSIXProperty ' If SelectedRowMode Is true this property must be set
Public LabelID              As String ' If SelectedRowMode Is true this property could be set

' --- MDM v1 Properties ---
Public Row                  As Long
Public Col                  As Long
Public SelectedProperty     As MSIXProperty
Public CellClass            As String
Public TurnDowns            As New CVariables
Public Width                As Variant
Public Height               As Variant
'Public TurnRight            As Boolean

' --- MDM v2 Properties ---
Public Name             As String
Public ScrollBars       As Long     ' 0-none 1-Vertical 2-Horizontal 3-Both
Public ShowHeaders      As Boolean  ' Default value is TRUE
Public FilterMode       As Long     ' MDM v2.2 - The type is changed from boolean to long so we can support more mode : -1 - Filter on one hard coded property
                                    ' Compatibility with 2.0 is ok! -2 Filter based on a ComboBox
                                    ' Default value is FALSE - Define is the PVB will have a filter textbox
Public ApplyFilter      As Boolean  ' Added for cases in which the rowset is filtered in backend to indicate we do not need to apply the ADO filter
Public FilterProperty   As MSIXProperty
Public FilterPropertySaveValue As String
Public FilterPropertySave As Boolean
Public Filter           As String
Public Filter2          As String
Public FilterOperator   As String

Public DefaultCellClass     As String ' Default Customizable Value
Public DefaultCellClassAlt  As String
Public DefaultHeaderClass   As String

Public HTMLRendered     As String
Public Enabled          As Boolean
Public Visible          As Boolean
Public OverRiddenEvents As New CVariables  ' This is just a container so the MDM VBScript file mdmGridEvents can store/and retreive for each [Documented=no]
                                           ' events if it is the default or a customized on. This speed the rendering process.               [Documented=no]
                                          
'Public HTMLActions      As New CVariables       ' String to generate for each columns  - MDM V2
Private m_objProperties  As MSIXProperties   ' MDM V2

Private m_varCaption    As Variant
Private m_objTools      As MSIXTools

Private m_booIsMTPropertiesMode As Boolean ' MDM V2 - The grid deal with [extended] MTProperties collection of name, value, type




' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        : TRUE if Ok.
Public Function Clear() As Boolean

    On Error GoTo ErrMgr

    TurnDowns.Clear
    OverRiddenEvents.Clear
    Set m_objTools = Nothing
    Clear = True
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE
    #End If
    
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMGrid.cls", "Clear", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function ToString() As String
    ToString = "name=" & Name

End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Caption() As String
    If (IsEmpty(m_varCaption)) Then
        Caption = "{NL}" & Name
    Else
        Caption = m_varCaption
    End If
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Caption
' PARAMETERS    :
' DESCRIPTION   : See property get
' RETURN        :
Public Property Let Caption(ByVal vNewValue As String)
    m_varCaption = vNewValue
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Load(ByVal strQueryTag As String, ByVal strQueryTagRelativePathFromConfig As String) As Boolean

    Dim objError        As New CError
    Dim objRowset       As MTSQLRowset

    Set objRowset = New MTSQLRowset
    
    Load = Tools.ExecSQL(strQueryTagRelativePathFromConfig, strQueryTag, objRowset)
    
    If (Err.Number) Then
    
        objError.Save Err.Number, Err.Description, Err.Source, MTMSIX_ERROR_01025, "MDMGrid.cls", "Load"
        TRACE objError.ToString(), , , LOG_ERROR
        Err.Clear
        Load = False
    Else
        Set Rowset = objRowset
    End If
End Function

Public Property Get Tools() As MSIXTools
    
    If (Not IsValidObject(m_objTools)) Then Set m_objTools = New MSIXTools
    Set Tools = m_objTools
End Property


Public Property Get Rowset() As Variant
    Set Rowset = Me.Properties.Rowset
End Property

Public Property Set Rowset(ByVal vNewValue As Variant)
    Set Me.Properties.Rowset = vNewValue
    Properties.Clear
    Properties.Name = "MDMGrid:" & Me.Name
    Properties.AddPropertiesFromRowset vNewValue
    SetFlag
    Properties.SelectAll
End Property

Public Function AddToRowset(ByVal vRS As Variant, Optional ByVal strUniqueColumn As String = Empty)
    
    On Error GoTo ErrMgr
    
    Dim objNewRS As New MTSQLRowsetSimulator
    Dim i As Long
    
    If (Not IsValidObject(vRS)) Then Exit Function
    If (Not IsValidObject(Me.Properties.Rowset)) Then Exit Function
    
    ' initialize new rowset
    objNewRS.Initialize Me.Properties.Rowset.RecordCount + vRS.RecordCount, Me.Properties.Rowset.Count
    
    For i = 0 To Me.Properties.Rowset.Count - 1
      objNewRS.Name(i) = Me.Properties.Rowset.Name(i)
    Next
    
    ' add existing rowset
    If (Me.Properties.Rowset.RecordCount) Then Me.Properties.Rowset.MoveFirst
      
    Do While Not Me.Properties.Rowset.EOF()
  
     For i = 0 To Me.Properties.Rowset.Count - 1
     
         objNewRS.Value(i) = Me.Properties.Rowset.Value(i)
     Next
  
     objNewRS.MoveNext
     Me.Properties.Rowset.MoveNext
    Loop
      
    ' add new rowset
    If (vRS.RecordCount) Then vRS.MoveFirst
      
    Do While Not vRS.EOF()
  
     For i = 0 To vRS.Count - 1
         objNewRS.Value(i) = vRS.Value(i)
     Next
  
     objNewRS.MoveNext
     vRS.MoveNext
    Loop

    ' Remove duplicate rows if strUniqueColumn is specified
    If Not IsEmpty(strUniqueColumn) Then
      Dim bFound As Boolean
      Dim j As Long
      Dim arrUniqueValues() As String
      Dim intUniqueCount As Long
      intUniqueCount = 0
      
      objNewRS.MoveFirst
      i = 0
      Do While Not objNewRS.EOF()
  
        bFound = False
       
        ' Check if we have this strUniqueColumn already and if so remove row
        For j = 0 To intUniqueCount - 1
          If CStr(arrUniqueValues(j)) = CStr(objNewRS.Value(strUniqueColumn)) Then
           bFound = True
           Call objNewRS.RemoveRow(i)
           j = intUniqueCount
          End If
        Next
      
        If Not bFound Then
          ReDim Preserve arrUniqueValues(intUniqueCount)
          arrUniqueValues(intUniqueCount) = CStr(objNewRS.Value(strUniqueColumn))
          intUniqueCount = intUniqueCount + 1
          
          If Not objNewRS.EOF() Then
           Call objNewRS.MoveNext
           i = i + 1
          End If
        End If
      
      Loop
    End If
    
    ' Set new rowset
    objNewRS.MoveFirst
    Set Rowset = objNewRS

    Exit Function

ErrMgr:
  TRACE MTMSIX_ERROR_01033, "MDMGrid.cls", "AddToRowset", LOG_ERROR
  
End Function



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SetFlag
' PARAMETERS    :
' DESCRIPTION   : Tell the propertis object not to store the caption in the cache...
' RETURN        : TRUE if Ok.
Private Function SetFlag() As Boolean

    On Error GoTo ErrMgr

    Dim p           As MSIXProperty
        
    For Each p In Me.Properties
    
        If (Not CBool(p.Flags And eMSIX_PROPERTY_FLAG_DO_NOT_STORE_CAPTION_IN_CACHE)) Then
        
            p.Flags = p.Flags + eMSIX_PROPERTY_FLAG_DO_NOT_STORE_CAPTION_IN_CACHE
        End If
    Next
    SetFlag = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMGrid.cls", "SetFlag", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : RenderGridJavaScript
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        : USE LESS - But it could be...
Friend Function RenderGridJavaScript() As String

    On Error GoTo ErrMgr

    Dim strJavaScript As String
    
    RenderGridJavaScript = PreProcess(MDM_JAVASCRIPT_GRID_RENDERING_TEMPLATE, "NAME", Me.Name, "WIDTH", Me.Width, "HEIGHT", Me.Height, "CRLF", vbNewLine)
Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & RenderGridJavaScript(), "MDMGrid.cls", "RenderGridJavaScript", LOG_ERROR
End Function



Public Property Set MTProperties(Optional varExtendedProperties As Variant, ByVal vNewValue As Variant)

    Dim objRowset As New MTSQLRowsetSimulator
    objRowset.InitWithMTProperties vNewValue, varExtendedProperties
    Set Rowset = objRowset
    m_booIsMTPropertiesMode = True
End Property

Public Property Get Version() As String
    Version = Me.Properties.Version
End Property

Friend Property Let Version(v As String)
    Me.Properties.Version = v
End Property
                    
Public Function IsMTPropertiesMode() As Boolean
    IsMTPropertiesMode = m_booIsMTPropertiesMode
End Function

Public Property Set MTCollection(ByVal vNewValue As Variant)

    Dim objRowset As New MTSQLRowsetSimulator
    objRowset.InitMTCollection vNewValue
    Set Rowset = objRowset
End Property








Public Property Get Properties() As MSIXProperties

    If (Not IsValidObject(m_objProperties)) Then
    
        Set m_objProperties = New MSIXProperties
    End If
    Set Properties = m_objProperties
End Property



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : InitPropertiesObject
' PARAMETERS    :
' DESCRIPTION   : Internal Initialization. To break the evil circle of the COM Circular reference due to the Parent member
'                 the object Properties does not have a Parent member referencing this class. But this class have to share
'                 some data. So these data are given to the Properties object while the MSIXHandler object is initializing.
' RETURN        :
Private Function InitPropertiesObject() As Boolean

    On Error GoTo ErrMgr
    
    'Properties.Localized = False
    
    Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW         ' Tell the properties if it is a service or a product view
    Properties.Language = METRATECH_DEFAULT_LANGUAGE
    Set Properties.Tools = Me.Tools     ' give the instance of the of the tool class
    InitPropertiesObject = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMGrid.cls", "InitPropertiesObject", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If
    
    Enabled = True
    Visible = True
    InitPropertiesObject
    ShowHeaders = True
    DefaultCellClass = "GridCell"
    DefaultCellClassAlt = "GridCellAlt"
    DefaultHeaderClass = "GridHeader"

    ApplyFilter = True         ' Apply an ADO filter that is specified
    FilterPropertySave = True  ' Save filter by default
    
    Version = MDM_VERSION_13
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMGrid.cls", "Class_Initialize", LOG_ERROR
End Sub

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Terminate()

    On Error GoTo ErrMgr

    TurnDowns.Clear
    
    Properties.Delete
    Set Properties.Tools = Nothing
    Set m_objProperties = Nothing
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMGrid.cls", "Class_Terminate", LOG_ERROR
End Sub

