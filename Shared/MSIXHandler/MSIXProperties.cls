VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXProperties"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"399321CA02CB"
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
' CLASS         : MSIXProperties
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   : This object and associated objects implement a full COM Object Model for a MetraTech
'                 service or product view properties collesction.
'                 Some of the properties and methods of this object are reserved by the MetraTech Dialog Manager VBScript layer.
'                 This object must not be used directly, but through an instance of the object MSIXHandler.
'                 Refer to the Metratech Dialog Manager Programming Guide for more information.
'
' $Date: 10/1/2002 2:58:40 PM$
' $Author: Frederic Torres$
' $Revision: 72$
' $Workfile: MSIXProperties.cls$
'
'*****************************************************************************
Option Explicit

Public TRACE_ID As Long

Private mCol                        As Collection
Private m_eRenderFlags              As eMSIX_RENDER_FLAG
Private m_strName                   As String
Private m_strLanguage               As String
Private m_Rowset                    As Variant          ' COMDBOBJECTSLib.COMProductView or MTSQLRowset
Private m_RowsetColumnIndex         As CVariables       ' The GetRowsetColumnIndex() function return the column index from the name, to speed this process we use a internal cache...
                                                        ' Each time the rowset is reset the cache is cleared
Private m_booEnabled                As Boolean

Private m_objTools                  As MSIXTools        ' This guy uses the instance allocated by the MSIXHandler.
                                                        ' This instance is set by the MSIXHandler parent.

Public Interval                     As MSIXInterval             ' The Interval object. See the MSIXInterval object.
Public Flags                        As eMSIX_PROPERTIES_FLAG    ' Defines if the object is an MSIX property collection for a service or a product view and other associated flags. See the eMSIX_PROPERTIES_FLAG enum type.
Public TimeZoneId                   As Variant                  ' Gets or sets the <i>time zone id</i>. The default value is EMPTY. If TimeZoneId is set the date MSIX property value are localized. Internally the GMT value is kept and may be metered. See the Global\TimeZoneId enum type for the valid time zone id list.
Public DayLightSaving               As Boolean                  ' Gets or sets the <i>day light saving mode</i>. The default value is FALSE. This property is used only when TimeZoneId is set.

Private m_strVersion                      As String                   ' MDM V2

Private m_booLocalized              As Boolean


Private m_objSelector                As CSelector ' MDM V3.5

Public LocalizationFlags            As eMSIX_PROPERTIES_LOCALIZATION_FLAG

Public Enum eMSIX_PROPERTIES_LOAD_FLAG  ' MSIX Properties Flags

    eMSIX_PROPERTIES_LOAD_FLAG_LOAD_PRODUCT_VIEW = 1
    eMSIX_PROPERTIES_LOAD_FLAG_LOAD_SQL_SELECT = 2
    eMSIX_PROPERTIES_LOAD_FLAG_INIT_FROM_ROWSET = 4
    eMSIX_PROPERTIES_LOAD_FLAG_REMOTE_MODE = 8          ' Not supported
End Enum

Public Enum eMSIX_PROPERTIES_LOCALIZATION_FLAG

    eMSIX_PROPERTIES_LOCALIZATION_FLAG_LOCALIZE_DATE_WITH_TIME_ZONE_ID = 1
    eMSIX_PROPERTIES_LOCALIZATION_FLAG_RETURN_BIG5 = 2
    eMSIX_PROPERTIES_LOCALIZATION_FLAG_RETURN_UNICODE = 4
    eMSIX_PROPERTIES_LOCALIZATION_FLAG_DEFAULT_VALUE = eMSIX_PROPERTIES_LOCALIZATION_FLAG_LOCALIZE_DATE_WITH_TIME_ZONE_ID + eMSIX_PROPERTIES_LOCALIZATION_FLAG_RETURN_BIG5
End Enum

' Added in MDM 3.5
Public Configuration                As MDMConfiguration             ' Stores the optional mdm.xml file. See the MDM Programming Guide for more details.


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
'                   strName             - The name of the MSIX property.
'                   PropertyType        - The type of the MSIX property - string, unistring, boolean, enum, double, float, decimal, int32, timestamp.
'                   lngLength           - The length of the MSIX property if the type is a string.
'                   booRequired         - If the property is required.
'                   varDefaultValue     - The MSIX default value.
'                   lngFlags            - See enum type eMSIX_PROPERTY_FLAG, in class MSIXProperty.
'                   strEnumSpace        - If the type is an enum type, the name space.
'                   strEnumTypeName     - If the type is an enum type, the enum type name.
'                   booUserVisible      - The MSIX attribute UserVisible.
'
' DESCRIPTION   : Adds a new MSIX property to the collection and returns a reference to it.
'                 Returns <code>Nothing</code> if the function fails; errors messages are logged in MTLog.txt.
'                 If the MSIX property is an enum type, the enum type and its localization are loaded.
'                 This object supports the MSIXCache object if defined in the MSIXHandler parent object initialize() function.
' RETURN        :
Public Function Add(ByVal strName As String, ByVal PropertyType As String, ByVal lngLength As Long, ByVal booRequired As Boolean, ByVal varDefaultValue As Variant, Optional ByVal lngFlags As eMSIX_PROPERTY_FLAG = eMSIX_PROPERTY_FLAG_NONE, Optional ByVal strEnumSpace As String, Optional ByVal strEnumTypeName As String, Optional ByVal booUserVisible As Boolean = True, Optional ByVal booExporTable As Boolean = True, Optional ByVal booFilterable As Boolean = True) As MSIXProperty

    On Error GoTo ErrMgr
                   
    Dim p As MSIXProperty
    
    Set p = New MSIXProperty
    
    p.Initialize Me, strName, PropertyType, lngLength, lngFlags, booRequired, varDefaultValue, strEnumSpace, strEnumTypeName, booUserVisible, booExporTable, booFilterable
    
    If (Me.Exist(strName)) Then
    
        If IsValidObject(Configuration) Then
            If Configuration.LogWarning Then
                TRACE Replace(MTMSIX_ERROR_01081, "[NAME]", strName), "MSIXProperties.cls", "Add", LOG_WARNING
            End If
        End If
        Me.Remove strName
    End If
    
    mCol.Add p, UCase$(strName)
    p.Index = mCol.Count
    
    TRACE_CONSTRUCTOR_DESTRUCTOR p, TRACE_MSIXHANDLER_INIT_MSIXPROPERTIES, "name=" & p.Name & " parent=" & Me.Name
    
    Set Add = p
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Add", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name Id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
'                 If the function returns <code>Nothing</code>, the Visual Basic/VBScript code calling <code>Item</code>
'                 will fail and raise an error.
' RETURN        :
Public Property Get Item(ByVal vntKey As Variant) As MSIXProperty
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
   
   'RaiseError PreProcess(MTMSIX_ERROR_01087, "NAME", vntKey, "PROPERTIES_NAME", Me.Name), , , LOG_APPLICATION_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Removes the item from the collection. The method is not case sensitive.
' RETURN        : Returns TRUE if OK
Public Function Remove(ByVal vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    
    Dim p As MSIXProperty
   
    Set p = Me.Item(vntKey)
    If IsValidObject(p) Then
      p.Delete
    End If
    
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

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    Set mCol = New Collection
    
    g_booReadEnumType = True
    
    Set Interval = New MSIXInterval
    Set Interval.Parent = Me
    
    LocalizationFlags = eMSIX_PROPERTIES_LOCALIZATION_FLAG_DEFAULT_VALUE
    m_booEnabled = True
    
    m_strVersion = MDM_VERSION_13
    
    #If LOG_OBJECT_INFO Then
    
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
        TRACE_CONSTRUCTOR_DESTRUCTOR Interval, TRACE_INIT_MSIXINTERVALID, "Parent Properties ID=" & ObjPtr(Me)
    #End If
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    Clear
    Set mCol = Nothing
    Set Rowset = Nothing
    Set m_objTools = Nothing
    
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
' DESCRIPTION   : Removes all the items in the collection. If the item is no longer referenced, it is deleted and its destructor
'                 Class_Terminate event is raised.
' RETURN        : TRUE if Ok.
Public Function Clear() As Boolean

    On Error GoTo ErrMgr

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE
    #End If

    If IsValidObject(mCol) Then
      Do While Count
          Item(1).Delete ' For each item call the delete so every item delete its parent reference to this instance.
          Remove 1
      Loop
    End If
    
    Clear = True
    Exit Function
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
'                 booHTMLTable - If true, returns the result in a HTML table.
' DESCRIPTION   : Returns the value(s) of the instance in a string.
' RETURN        :
Public Function ToString(Optional booHTMLTable As Boolean = False) As String

    On Error GoTo ErrMgr
    
    Dim objProperty      As MSIXProperty
    Dim objConcat        As New cStringConcat
    Dim varValue         As Variant
       
    objConcat.Init 4096 ' PreAllocate a 4k Buffer
    
    If (booHTMLTable) Then
    
        objConcat.Concat "<TABLE  width='100%' border=0 cellpadding=1 cellspacing=1>"
        objConcat.Concat "<tr>"
        objConcat.Concat "<td Class='mdmDebuggerCellProperty'><b>Index</td>"
        objConcat.Concat "<td Class='mdmDebuggerCellProperty'><b>Name</td>"
        objConcat.Concat "<td Class='mdmDebuggerCellProperty'><b>Type</td>"
        objConcat.Concat "<td Class='mdmDebuggerCellProperty'><b>Length</td>"
        objConcat.Concat "<td Class='mdmDebuggerCellProperty'><b>Required</td>"
        objConcat.Concat "<td Class='mdmDebuggerCellProperty'><b>Enabled</td>"
        objConcat.Concat "<td Class='mdmDebuggerCellProperty'><b>Value</td>"
        objConcat.Concat "<td Class='mdmDebuggerCellProperty'><b>Value COM Type</td>"
        objConcat.Concat "</tr>"
        
        For Each objProperty In Me
        
            objConcat.Concat "<tr>"
            objConcat.Concat "<td Class='mdmDebuggerCellProperty'>" & objProperty.Index & "</td>"
            objConcat.Concat "<td Class='mdmDebuggerCellProperty'>" & objProperty.Name & "</td>"
            objConcat.Concat "<td Class='mdmDebuggerCellProperty'>" & objProperty.PropertyType & "</td>"
            objConcat.Concat "<td Class='mdmDebuggerCellProperty'>" & objProperty.Length & "</td>"
            objConcat.Concat "<td Class='mdmDebuggerCellProperty'>" & objProperty.Required & "</td>"
            objConcat.Concat "<td Class='mdmDebuggerCellProperty'>" & objProperty.Enabled & "</td>"
            
            If (IsEmpty(objProperty.Value())) Then
                objConcat.Concat "<td Class='mdmDebuggerCellProperty'>Empty</td>"
                objConcat.Concat "<td Class='mdmDebuggerCellProperty'>&nbsp;</td>"
            Else
                varValue = objProperty.NonLocalizedValue
                If (Len("" & varValue)) Then
                    objConcat.Concat "<td Class='mdmDebuggerCellProperty'>" & varValue & "</td>"
                Else
                    objConcat.Concat "<td Class='mdmDebuggerCellProperty'>&nbsp;</td>"
                End If
                objConcat.Concat "<td Class='mdmDebuggerCellProperty'>" & TypeName(varValue) & "</td>"
            End If
            objConcat.Concat "</tr>"
        Next
        objConcat.Concat "</TABLE>"
    Else
        For Each objProperty In Me
        
            objConcat.Concat objProperty.ToString()
        Next
    End If
    ToString = objConcat.GetString()

    Exit Function
ErrMgr:
        'Debug.Print Err.Description: Debug.Assert False
End Function
 


' -------------------------------------------------------------------------------
' FUNCTION      : Exist
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Returns TRUE if the item exists in the collection. The method is not case sensitive.
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


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ClearSelection
' PARAMETERS    :
' DESCRIPTION   : Resets to 0 the <code>Selected</code> property for each item in the collection.
' RETURN        : TRUE if Ok.
Public Function ClearSelection() As Boolean

    On Error GoTo ErrMgr

    Dim p As MSIXProperty
    For Each p In Me
    
        p.Selected = 0
    Next
    ClearSelection = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "ClearSelection", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadAccountType
' PARAMETERS    :
'                   strAccountType - The account type to load the properties for
' DESCRIPTION   : Loads all the properties for an account type
' RETURN        : TRUE / FALSE
Public Function LoadAccountType(ByVal strAccountType As String) As Boolean
  On Error GoTo ErrMgr
  
  Dim objAccountType
  Set objAccountType = New AccountType
  objAccountType.InitializeByName strAccountType
  
  Dim objSD As ServiceDefinition
  Set objSD = objAccountType.GetMSIXProperties()
  
  Dim objNewProperty As MSIXProperty
    
  ' Loop around properties and add them
  Dim prop As IMTPropertyMetaData
  For Each prop In objSD.Properties

      Dim dataType As String
      Select Case prop.dataType
        Case 11:
          dataType = MSIXDEF_TYPE_DECIMAL
        Case 10:
          dataType = MSIXDEF_TYPE_ENUM
        Case 7:
          dataType = MSIXDEF_TYPE_BOOLEAN
        Case 5:
          dataType = MSIXDEF_TYPE_TIMESTAMP
        Case 4:
          dataType = MSIXDEF_TYPE_STRING
        Case 2:
          dataType = MSIXDEF_TYPE_INT32
        Case Else:
          dataType = MSIXDEF_TYPE_STRING
          TRACE "Unknown type (" & prop.dataType & ") for prop (" & prop.Name & ") defaulting to string...", "MSIXProperties.cls", "LoadAccountType", LOG_ERROR
      End Select
      
      If UCase$(prop.Name) = "PRICELIST" Or UCase$(prop.Name) = "CURRENCY" Then
        dataType = MSIXDEF_TYPE_STRING ' a little trick since the view and service def are different types
      End If
    
    'TRACE ">L> (" & prop.Name & ") = " & prop.DisplayName, "MSIXProperties.cls", "LoadAccountType", LOG_DEBUG
    
    Set objNewProperty = Me.Add(prop.Name, dataType, prop.Length, Me.Tools.BooleanValue(prop.Required), prop.DefaultValue, eMSIX_PROPERTY_FLAG_METERED + eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF + eMSIX_PROPERTY_FLAG_DO_NOT_STORE_CAPTION_IN_CACHE, prop.EnumSpace, prop.EnumType, True, True, True)
    Me(prop.Name).Caption = prop.DisplayName
    
  Next
  
  LoadAccountType = True
  
  Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "LoadAccountType", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadMSIXDEFXMLFile
' PARAMETERS    :
'                   strXMLFileName      - The msixdef file name to load.
'                   strName             - Returns the name of the service or product view definition.
'                   booClear            - Clears the object before loading the MSIXDEF file. The default value is TRUE.
'                   eOptionalAttribut   - Reserved.
'
' DESCRIPTION   : Loads an MSIXDEF file name. The full path must be specified.
' RETURN        :
Public Function LoadMSIXDEFXMLFile(ByVal strXMLFileName As String, ByRef strName As String, Optional booClear As Boolean = True, Optional eOptionalAttribut As eMSIX_PROPERTY_FLAG) As Boolean
 
    On Error GoTo ErrMgr

    Dim objXML                  As New XMLDomMgr
    Dim objXMLDefineService     As IXMLDOMNode
    Dim objXMLDefineServices    As IXMLDOMNodes
    Dim objXMLTypes             As IXMLDOMNodes
    Dim objXMLType              As IXMLDOMNode
    Dim v                       As Variant
    Dim objTagType              As IXMLDOMNode
    Dim strEnumSpace            As String
    Dim strEnumTypeName         As String
    Dim strUserVisible          As String
    Dim objProfiler             As New CProfiler
    Dim objNewProperty          As MSIXProperty
    Dim lngLength               As Long
    Dim strLength               As String
    Dim PropertyType            As String
    Dim strPropertyName         As String
    Dim strFilterAble           As String
    Dim strExportAble          As String
    
     objProfiler.Start MTMSIX_PROFILER_ON, "MSIXProperties.cls", "LoadMSIXDEFXMLFile"
    
    If (booClear) Then Me.Clear

    If (objXML.LoadFile(strXMLFileName)) Then
        
        Set objXMLDefineServices = objXML.FindXMLNodesInChild(objXML.XMLDoc, MSIXDEF_KEYWORD_DEFINESERVICE)

        If (objXMLDefineServices.Count = 1) Then

            Set objXMLDefineService = objXMLDefineServices.Item(1)

            strName = objXML.Property(objXMLDefineService, MSIXDEF_KEYWORD_NAME)
            m_strName = strName

            Set objXMLTypes = objXML.FindXMLNodesInChild(objXMLDefineService, MSIXDEF_KEYWORD_PTYPE)

            For Each objXMLType In objXMLTypes
            
                strUserVisible = objXML.AttributValue(objXMLType, MSIXDEF_KEYWORD_ATTRIBUT_USERVISIBLE)
                
                strFilterAble = objXML.AttributValue(objXMLType, MSIXDEF_KEYWORD_ATTRIBUT_FILTERABLE)
                strExportAble = objXML.AttributValue(objXMLType, MSIXDEF_KEYWORD_ATTRIBUT_EXPORTABLE)
                                
                If (Len(strUserVisible) = 0) Then strUserVisible = "TRUE"
                If (Len(strFilterAble) = 0) Then strFilterAble = "TRUE"
                If (Len(strExportAble) = 0) Then strExportAble = "TRUE"
                
                If (Not IsBoolean(strUserVisible)) Or (Not IsBoolean(strFilterAble)) Or (Not IsBoolean(strExportAble)) Then
                
                    TRACE PreProcess(MTMSIX_ERROR_01029, "[FILE]", strXMLFileName), "MSIXProperties.cls", "LoadMSIXDEFXMLFile", LOG_ERROR
                    Exit Function
                End If
                
                Set objTagType = objXML.XmlNode(objXMLType, MSIXDEF_KEYWORD_TYPE)
                strEnumSpace = objXML.AttributValue(objTagType, MSIXDEF_KEYWORD_ATTRIBUT_ENUMSPACE)
                                
                PropertyType = UCase$(objXML.Property(objXMLType, MSIXDEF_KEYWORD_TYPE))
                strPropertyName = objXML.Property(objXMLType, MSIXDEF_KEYWORD_DN)
                strEnumTypeName = objXML.AttributValue(objTagType, MSIXDEF_KEYWORD_ATTRIBUT_ENUMTYPE)
                                
                
                ' Support enum type definition in MSIX def file syntax 1 and 2
                
                If (PropertyType = MSIXDEF_KEYWORD_ENUM) Then ' If the property is an enum type set with the 1.2 Format - the name space is the service/product view name
                
                    If (Len(strEnumSpace) = 0) Then strEnumSpace = strName
                    If (Len(strEnumTypeName) = 0) Then strEnumTypeName = strPropertyName
                End If
                
                lngLength = 0
                strLength = objXML.Property(objXMLType, MSIXDEF_KEYWORD_LENGTH)
                If (Len(strLength)) Then
                
                    If (IsNumeric(strLength)) Then
                    
                        lngLength = strLength
                    Else
                        TRACE Replace(MTMSIX_ERROR_01045, "[FILE]", strXMLFileName), "MSIXProperties.cls", "LoadMSIXDEFXMLFile()", LOG_ERROR
                    End If
                End If

                Set objNewProperty = Me.Add(strPropertyName, PropertyType, lngLength, Me.Tools.BooleanValue(objXML.Property(objXMLType, MSIXDEF_KEYWORD_REQUIRED)), objXML.Property(objXMLType, MSIXDEF_KEYWORD_DEFAULTVALUE), eMSIX_PROPERTY_FLAG_METERED + eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF, strEnumSpace, strEnumTypeName, CBool(strUserVisible), CBool(strExportAble), CBool(strFilterAble))
                If (IsValidObject(objNewProperty)) Then
                    objNewProperty.Flags = objNewProperty.Flags + eOptionalAttribut
                Else
                    TRACE Replace(MTMSIX_ERROR_01068, "[PROPERTY]", strPropertyName), "MSIXProperties.cls", "LoadMSIXDEFXMLFile", LOG_ERROR
                    Exit Function
                End If
            Next
            LoadMSIXDEFXMLFile = True
            TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_LOAD_MSIXDEF_FILE, " Name=" & strName & " FileName=" & strXMLFileName
            
            If (Flags And eMSIX_PROPERTIES_FLAG_SERVICE) Then ' in the case of a service set the default value
                ReSetDefaults
            End If
        End If
    End If

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "LoadMSIXDEFXMLFile", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Delete
' PARAMETERS    :
' DESCRIPTION   : Internal Delete function called by the parent object when the parent is about to be deleted.
'                 The purpose of this function is to free the parent ref from the child so the parent can be deleted.
'                 This deals with the COM problem of circular reference.
'                 This function cannot be called from the out side (Friend)!
' RETURN        :
Public Function Delete() As Boolean

On Error GoTo ErrMgr

    Clear  ' Calls delete on each member of col
    
    If IsValidObject(Interval) Then Interval.Delete
    If IsValidObject(Interval) Then Set Interval = Nothing
    If IsValidObject(Rowset) Then Set Rowset = Nothing
    If IsValidObject(m_RowsetColumnIndex) Then Set m_RowsetColumnIndex = Nothing
    If IsValidObject(m_objTools) Then Set m_objTools = Nothing
    If IsValidObject(mCol) Then Set mCol = Nothing
    
    Delete = True
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Delete", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : RenderFlags
' PARAMETERS    :
' DESCRIPTION   : we do not want to have a pointer to the MSIX from this object, to avoid circular reference at the level.
'                 So I duplication the RenderFlag that belong to the MSIX class. Each this property in the MSIX
'                 class is update the code update the property is that class so we are all the time updated!
'                 and we can use the property!
' RETURN        :
Friend Property Get RenderFlags() As eMSIX_RENDER_FLAG

    On Error GoTo ErrMgr

    RenderFlags = m_eRenderFlags

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "RenderFlags", LOG_ERROR
End Property

Friend Property Let RenderFlags(eValue As eMSIX_RENDER_FLAG)

    On Error GoTo ErrMgr

    m_eRenderFlags = eValue

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "RenderFlags", LOG_ERROR
End Property


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Load
' PARAMETERS    :
'                 lngAccountID                      - If not defined, use the interval.AccountId member.
'                 strSQLExtensionOrQueryTag         - See description.
'                 eFlags                            - See description.
'                 strQueryTagRelativePathFromConfig - See description.
'                 strRemoteVirtualDirectory         - Not used in this version.
'                 strRemoteServerName               - Not used in this version.
'
' DESCRIPTION   : In the case of a product view <i><b>only</b></i>, the function loads the product view data.
'                 The sub object <i>Interval</i> must be loaded and the interval.id must be set.
'                 By default the interval.id is set to the current interval id.
'                 The product view data are stored in a COM object COMDBOBJECTSLib.COMProductView.
'                 The property <code>Rowset</code> returns a reference to this object.
'
'                 By setting the strSQLExtensionOrQueryTag paramter with a SQL Extension, it is possible to set
'                 the SQLExtension of the MT API DataAccessor. GetProductView(ViewID(), strSQLExtensionOrQueryTag).
'                 See the Metratech documentation about the COMDBOBJECTSLib.COMDataAccessor COM object .
'
'                 This function allows also to load a MTSQLRowset based on a SQL Query.
'                 In that case, the location of the XML Query file is defined in the strQueryTagRelativePathFromConfig parameter.
'                 Note the path is relative to the Config folder. A valid path would be "queries\mam\sql".
'                 See Metratech documentation about the COM object MTSqlRowset.
'
'                 eFlags define if load a product view or a SQL Query Tag and other associated flags.
'                 See the enum type eMSIX_PROPERTIES_LOAD_FLAG
'
' RETURN        : TRUE if Ok.
Public Function Load(Optional lngAccountID As Long, Optional ByVal strSQLExtensionOrQueryTag As String, Optional ByVal eFlags As eMSIX_PROPERTIES_LOAD_FLAG = eMSIX_PROPERTIES_LOAD_FLAG_LOAD_PRODUCT_VIEW, Optional ByVal strQueryTagRelativePathFromConfig As String, Optional ByVal strRemoteVirtualDirectory As String, Optional ByVal strRemoteServerName As String) As Boolean

    Dim objError        As New CError
    Dim objProfiler     As New CProfiler
    
    objProfiler.Start MTMSIX_PROFILER_ON, "MSIXProperties.cls", "Load"
    
'    'Debug.Assert 0
    
    TRACE "MSIXProperties.Load lngAccountID=" & Me.Interval.AccountID & " lngIntervalID=" & Me.Interval.Id & " ProductView.Name=" & Me.Name
        
    If (eFlags And eMSIX_PROPERTIES_LOAD_FLAG_LOAD_PRODUCT_VIEW) Then ' we are loading a standard product view
        
        If (eFlags And eMSIX_PROPERTIES_LOAD_FLAG_REMOTE_MODE) Then ' The product view is a remote one
        
            ' -- The remote mode was cancel --
            'Set Me.Rowset = GetRemoteProductView(Me.Interval.AccountID, Me.Interval.ID, Me.Name & ".MSIXDEF", strSQLExtensionOrQueryTag, strQueryTagRelativePathFromConfig, strRemoteVirtualDirectory, strRemoteServerName)
            'If (IsValidObject(Me.Rowset)) Then
            '
            '     TRACE "GetRemoteProductView() Succeed!", "MSIXProperties.cls", "Load", LOG_WARNING
            '     Load = True
            ' End If
        Else
            
            Tools.DataAccessorObject.AccountID = IIf(lngAccountID = 0, Me.Interval.AccountID, lngAccountID) ' Set every thing to call GetProductView()
            Tools.DataAccessorObject.IntervalID = Me.Interval.Id
            Tools.DataAccessorObject.LanguageCode = Me.Language
            On Error Resume Next
            
            Set Me.Rowset = Tools.DataAccessorObject.GetProductView(ViewID(), strSQLExtensionOrQueryTag)
            
            If (Err.Number) Then
            
                Set Me.Rowset = Nothing ' Free the rowset because the previous rowset is not what we want
                
                objError.Save Err.Number, Err.Description, Err.Source, MTMSIX_ERROR_01025, "MSIXProperties.cls", "Load"
                TRACE objError.ToString(), , , LOG_ERROR
                Err.Clear
            Else
                '  'Debug.Print Me.Tools.COMProductViewToString(Me.Rowset)
                Load = True
            End If
        End If
    
    ElseIf (eFlags And eMSIX_PROPERTIES_LOAD_FLAG_LOAD_SQL_SELECT) Then ' We are loading a SQL Query Tag
                
        On Error Resume Next
        
        Set Rowset = New MTSQLRowset
        
        If (lngAccountID = 0) Then
            Load = Tools.ExecSQL(strQueryTagRelativePathFromConfig, strSQLExtensionOrQueryTag, Me.Rowset)
        Else
            Load = Tools.ExecSQL(strQueryTagRelativePathFromConfig, strSQLExtensionOrQueryTag, Me.Rowset, "ACCOUNT_ID", lngAccountID)
        End If
        
        If (Err.Number) Then
        
            objError.Save Err.Number, Err.Description, Err.Source, MTMSIX_ERROR_01025, "MSIXProperties.cls", "Load"
            TRACE objError.ToString(), , , LOG_ERROR
            Err.Clear
            Load = False
        Else
            If (eFlags And eMSIX_PROPERTIES_LOAD_FLAG_INIT_FROM_ROWSET) Then ' We are loading a SQL Query Tag
            
                AddPropertiesFromRowset Me.Rowset ' Rebuild the collection of properties from the rowset
                CancelLocalization ' To Avoid localization problem, a localization can still be set after the load().
            End If
            Load = True
        End If
    End If
    On Error GoTo 0
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ViewID
' PARAMETERS    :
' DESCRIPTION   : Gets the ViewID of the product view.
' RETURN        :
Public Property Get ViewID() As Long

    On Error GoTo ErrMgr

    ViewID = GetProductViewId(m_strName)
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "ViewID", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetProductViewId
' PARAMETERS    :
' DESCRIPTION   : Returns the ViewID of the product view.
' RETURN        :
Private Function GetProductViewId(strProductViewName As String) As Long

    On Error GoTo ErrMgr
    
    GetProductViewId = Tools.PVNameIdLookUpObject.GetNameID(strProductViewName)
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "GetProductViewId", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : IsProductView
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE is the object is initialized as a product view.
' RETURN        :
Public Function IsProductView() As Boolean

    On Error GoTo ErrMgr

    IsProductView = CBool(Flags And eMSIX_PROPERTIES_FLAG_PRODUCTVIEW)
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "GetProductViewId", LOG_ERROR

End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ClearData
' PARAMETERS    :
' DESCRIPTION   : In the case of a service definition <i><b>only</b></i> this function clears the properties values.
'                 If a MSIX property does not have a MSIX default value, the value is reset to Empty.
' RETURN        : TRUE if Ok.
Friend Function ClearData() As Boolean

    On Error GoTo ErrMgr

    Dim p As MSIXProperty
    If (Me.Flags And eMSIX_PROPERTIES_FLAG_SERVICE) Then
    
        For Each p In Me     ' I think this loop is useless because SetDefault to it too.
    
            p.Value = Empty
        Next
        ReSetDefaults
    End If
    ClearData = True

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "ClearData", LOG_ERROR



End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SetDefault
' PARAMETERS    :
' DESCRIPTION   : Resets all the MSIX default property values. If a property does not have a default value, the value is reset to Empty.
' RETURN        : TRUE if Ok.
Public Function ReSetDefaults() As Boolean

    On Error GoTo ErrMgr

    Dim objProperty As MSIXProperty
        
    If (Me.Flags And eMSIX_PROPERTIES_FLAG_SERVICE) Then
    
        For Each objProperty In Me
        
            objProperty.ReSetDefault
        Next
    End If
    ReSetDefaults = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "SetDefault", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ItemSelected
' PARAMETERS    :
'                   lngSelectedPosition: The selected position of the item.
'
' DESCRIPTION   : Gets the MSIXProperty item, set as selected at the position <i>lngSelectedPosition</i>.
'                 If there is not item selected at the position the function will return <code>Nothing</code>
' RETURN        :
Public Property Get ItemSelected(ByVal lngSelectedPosition As Long) As MSIXProperty

   On Error GoTo ErrMgr

    Dim objProperty As MSIXProperty
    
    For Each objProperty In Me
    
        If objProperty.Selected = lngSelectedPosition Then
        
            Set ItemSelected = objProperty
            Exit Property
        End If
    Next
    Exit Property
ErrMgr:
   Set ItemSelected = Nothing
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Language
' PARAMETERS    :
' DESCRIPTION   : Gets or sets the current language. The value of the property is set by the MSIXHandler parent object.
' RETURN        :
Public Property Get Language() As String

    On Error GoTo ErrMgr

    Language = m_strLanguage
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Language", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Language
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Let Language(ByVal vNewValue As String)

    On Error GoTo ErrMgr

    m_strLanguage = vNewValue

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Language", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Name
' PARAMETERS    :
' DESCRIPTION   : gets the name of the service or product view.
' RETURN        :
Public Property Get Name() As String

    On Error GoTo ErrMgr

    Name = m_strName
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Name Get", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Name
' PARAMETERS    :
' DESCRIPTION   : gets the name of the service or product view.
' RETURN        :
Public Property Let Name(ByVal strName As String)

    On Error GoTo ErrMgr

    m_strName = strName
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Name Let", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Tools
' PARAMETERS    :
' DESCRIPTION   : Gets or sets the instance of the MSIXTools object.
'                 The value of the property is set by the MSIXHandler parent object. The objects MSIXHandler and
'                 MSIXProperties share the same instance. The MSIXProperty items in the collection can have
'                 access to this property by calling : <code>Parent.Tools</code>.
'                 See the MDM Programming Guide and MDM Object Model for more details.
' RETURN        :
Public Property Get Tools() As MSIXTools

    On Error GoTo ErrMgr

    Set Tools = m_objTools
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Tools", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Tools
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Set Tools(ByVal vNewValue As MSIXTools)

    On Error GoTo ErrMgr

    Set m_objTools = vNewValue
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Tools", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Generator
' PARAMETERS    :
' DESCRIPTION   : MetraTech Reserved. Not documented.
' RETURN        :
Public Function Generator(strTemplateFileName As String, strOutPutFileName As String) As Boolean ' DOCUMENTED=NO

    On Error GoTo ErrMgr

    Dim strFileName As String
    Dim objTextFile As New cTextFile
    Dim strIn       As String
    Dim strOut      As String
    Dim objProperty As MSIXProperty
    Dim objPP       As New CPreProcessor: objPP.standardVar
    
    objPP.Add "NOW", MTNow()
    
    If (objTextFile.OpenFile(strTemplateFileName)) Then
    
        objPP.Add "PROPERTY.PARENT", UCase$(Me.Name), PREPROCESSOR_ADD_LOWERCASE + PREPROCESSOR_ADD_UPPERCASE
    
        Do While Not objTextFile.EOF()
        
            strIn = objTextFile.ReadLn()
            
            If (Len(strIn)) Then
            
                If (Mid$(Trim(strIn), 1, 1) = "#") Then
                
                    For Each objProperty In Me
                        
                        objPP.Add "PROPERTY.NAME", UCase$(objProperty.Name), PREPROCESSOR_ADD_LOWERCASE + PREPROCESSOR_ADD_UPPERCASE + PREPROCESSOR_ADD_CAPTIONCASE
                        objPP.Add "PROPERTY.MAXLENGTH", objProperty.Length, PREPROCESSOR_ADD_LOWERCASE + PREPROCESSOR_ADD_UPPERCASE + PREPROCESSOR_ADD_CAPTIONCASE
                        objPP.Add "PROPERTY.TYPE", objProperty.PropertyType, PREPROCESSOR_ADD_LOWERCASE + PREPROCESSOR_ADD_UPPERCASE + PREPROCESSOR_ADD_CAPTIONCASE
                        objPP.Add "PROPERTY.REQUIRED", objProperty.Required, PREPROCESSOR_ADD_LOWERCASE + PREPROCESSOR_ADD_UPPERCASE + PREPROCESSOR_ADD_CAPTIONCASE
                        objPP.Add "PROPERTY.VALUE", objProperty.Value, PREPROCESSOR_ADD_LOWERCASE + PREPROCESSOR_ADD_UPPERCASE + PREPROCESSOR_ADD_CAPTIONCASE
                        objPP.Add "PROPERTY.FORMAT", objProperty.Format, PREPROCESSOR_ADD_LOWERCASE + PREPROCESSOR_ADD_UPPERCASE + PREPROCESSOR_ADD_CAPTIONCASE
                        objPP.Add "PROPERTY.DEFAULTVALUE", objProperty.DefaultValue, PREPROCESSOR_ADD_LOWERCASE + PREPROCESSOR_ADD_UPPERCASE + PREPROCESSOR_ADD_CAPTIONCASE
                        objPP.Add "PROPERTY.ISENUMTYPE", objProperty.IsEnumType, PREPROCESSOR_ADD_LOWERCASE + PREPROCESSOR_ADD_UPPERCASE + PREPROCESSOR_ADD_CAPTIONCASE
                        objPP.Add "PROPERTY.CAPTION", objProperty.LocalizedValue, PREPROCESSOR_ADD_LOWERCASE + PREPROCESSOR_ADD_UPPERCASE + PREPROCESSOR_ADD_CAPTIONCASE
                        
                        strOut = strOut & objPP.Process(Mid$(strIn, 2), "[", "]") & vbCrLf
                    Next
                Else
                    strOut = strOut & objPP.Process(strIn, "[", "]") & vbCrLf
                End If
            Else
                strOut = strOut & vbCrLf
            End If
        Loop
        objTextFile.CloseFile
        objTextFile.LogFile strOutPutFileName, strOut, True
    End If
    Generator = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Generator", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Find
' PARAMETERS    :
'                   strColumnName -  The name of the column used to do the look up.
'                   strValue      -  The value used to do the look up.
' DESCRIPTION   : In the case of a product view <i><b>only</b></i> and after the product view rowset has been loaded.
'                 It is possible to select/find one row in the rowset by calling the function this way :
'                 <code>Find("AccountId",123)</code>
'                 The function will select the first row that <i>match AccountId=123</i>.
' RETURN        : Returns TRUE if one record was found else FALSE.
Public Function Find(ParamArray NamesValues() As Variant) As Boolean

    On Error GoTo ErrMgr

    If (IsValidObject(Rowset)) Then
        Find = Tools.RowSetQuickFind(Me.Rowset, NamesValues)
    Else
        TRACE Replace(MTMSIX_ERROR_01048, "[NAME]", Me.Name), "MSIXProperties.cls", "Find()"
    End If
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Find", LOG_ERROR
End Function

'' --------------------------------------------------------------------------------------------------------------------------------------------------------------
'' FUNCTION      : SavePreviousValues
'' PARAMETERS    :
'' DESCRIPTION   : MetraTech Reserved.
'' RETURN        :
'Public Function SavePreviousValues() As Boolean
'
'    On Error GoTo ErrMgr
'
'    Dim objProperty As MSIXProperty
'
'    For Each objProperty In Me
'
'        objProperty.PreviousValue = objProperty.Value
'    Next
'    SavePreviousValues = True
'    Exit Function
'ErrMgr:
'    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "SavePreviousValues", LOG_ERROR
'End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ClearSortedProperty
' PARAMETERS    :
' DESCRIPTION   : Remove the fact that one property is viewed as the sorted property.
' RETURN        :
Friend Function ClearSortedProperty() As Boolean

    On Error GoTo ErrMgr

    Dim objProperty As MSIXProperty
    
    For Each objProperty In Me
            
        objProperty.Sorted() = 0
    Next
    ClearSortedProperty = True

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "SavePreviousValues", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SortedProperty
' PARAMETERS    :
' DESCRIPTION   : Gets the current sorted property. If there is no sorted property defined, the function returns <code>Nothing</code>.
' RETURN        :
Public Function SortedProperty() As MSIXProperty

    On Error GoTo ErrMgr

    Dim objProperty As MSIXProperty
    
    For Each objProperty In Me
            
        If (objProperty.Sorted) Then
        
            Set SortedProperty = objProperty
        End If
    Next
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "SortedProperty", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Rowset
' PARAMETERS    :
' DESCRIPTION   : Gets or sets the rowset. If the rowset was loaded as a product view, the object type is
'                 COMDBOBJECTSLib.COMProductView. If the rowset was loaded with SQL query tag the object type
'                 is MTSQLRowset. Both support the sort function.
' RETURN        :
Public Property Get Rowset() As Variant

    On Error GoTo ErrMgr

    If (IsEmpty(m_Rowset)) Then
        Set Rowset = Nothing        ' do this to avoid type mismatch because empty is not nothing.
    Else
        Set Rowset = m_Rowset
    End If
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Rowset", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Rowset
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Set Rowset(ByVal vNewValue As Variant)

    On Error GoTo ErrMgr

    Set m_Rowset = vNewValue
    Set m_RowsetColumnIndex = New CVariables
    
    If (CDbl(Version) >= CDbl(MDM_VERSION_20)) Then  ' MDM V2
    
        AddPropertiesFromRowset vNewValue
        
        If (Len(Name) = 0) Then ' If when we set the rowset the name is not set , this mean we are not dealing with a MT Product view
                                ' Because we did not load the msix definition. So I set the name to a dummy uniqu value to avoid
                                ' different MSIXProperties.Property caption share the same entry in the cache. the name is part of
                                ' the FQN used to id the entry in the cache, when name is blank if 2 rowset have the same property
            Name = "PV-" & GetTickCount() ' Set the name with a unique dummy product view name.
        End If
    End If
    
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Rowset", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : RowsetSupportSort
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE if the rowset supports the sort function.
'                 Only COMDBOBJECTSLib.COMProductView and MTSQLRowset support the sort function.
' RETURN        :
Public Function RowsetSupportSort() As Boolean

    On Error GoTo ErrMgr

    
    Dim strRowSetType As String ' Rowset support sort
    
    strRowSetType = UCase$(TypeName(Rowset))
    
    RowsetSupportSort = CBool(strRowSetType = "ICOMPRODUCTVIEW") Or CBool(strRowSetType = "IMTSQLROWSET") Or CBool(strRowSetType = "IMTXMLROWSET")
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "RowsetSupportSort", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : RowsetSupportInterval
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE if the interval id rowset object was loaded.
' RETURN        :
Public Function RowsetSupportInterval() As Boolean

    On Error GoTo ErrMgr

    RowsetSupportInterval = IsValidObject(Me.Interval.Rowset) ' We are testing the interval id rowset
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "IntervalSupport", LOG_ERROR
End Function




' -------------------------------------------------------------------------------
' FUNCTION      : GetRowsetColumnIndex
' PARAMETERS    :
' DESCRIPTION   : Returns the index of a column name is a Rowset or compatible object. Return -1 if the columns is not found.
' RETURN        :
Friend Function GetRowsetColumnIndex(ByVal strPropertyName As String) As Long

    On Error GoTo ErrMgr

    Dim i                   As Long
    Dim objVar              As CVariable
    Dim strRowSetColName    As String
    
    strPropertyName = UCase$(strPropertyName)
    
    ' Check in the cache
    On Error Resume Next
    Set objVar = m_RowsetColumnIndex.Item(strPropertyName)
    If (Not objVar Is Nothing) Then
    
        GetRowsetColumnIndex = objVar.Value
        Exit Function
    End If
    
    Err.Clear
    On Error GoTo ErrMgr
    
    For i = 0 To Rowset.Count - 1
    
        strRowSetColName = UCase$(Rowset.Name(CLng(i)))
        
        If (strRowSetColName = strPropertyName) Or (strRowSetColName = "C_" & strPropertyName) Then
        
            GetRowsetColumnIndex = i
            m_RowsetColumnIndex.Add strPropertyName, i ' add the value into the internal cache
            Exit Function
        End If
    Next
    GetRowsetColumnIndex = -1 ' not found
    m_RowsetColumnIndex.Add strPropertyName, -1 ' add the value into the internal cache
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "GetRowsetColumnIndex", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SetPropertiesFromRowset
' PARAMETERS    :
'                 objRowset -  The rowset object used to populate the service (COMPRODUCTVIEW, MTSQLROWSET, MTSQLRowsetSimulator).
'
' DESCRIPTION   : In the case of a service <i><b>only</b></i>, sets the service properties value from a Rowset object.
'                 The population is based only on the current rowset row. The rowset column name and properties name must match.
'                 If the rowset columns name start with prefix "c_", the prefix is ignored.
' RETURN        :
Public Function SetPropertiesFromRowset(objRowset As Variant) As Boolean

    On Error GoTo ErrMgr
    
    Dim strName As String
    Dim i       As Long
        
    For i = 0 To objRowset.Count - 1
    
        strName = objRowset.Name(CLng(i))
        
        If Me.Exist(strName) Then
        
            Me.Item(strName).Value = objRowset.Value(CLng(i))
        End If
        
        If (Len(strName) > 2) Then ' Remove the first 2 char to skip the c_
        
            If UCase(Mid$(strName, 1, 2)) = "C_" Then
            
              If Me.Exist(Mid$(strName, 3)) Then
              
                Me.Item(Mid$(strName, 3)).Value = objRowset.Value(CLng(i))
              End If
            End If
        End If
    Next
    
    SetPropertiesFromRowset = True
    Exit Function
ErrMgr:

    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "SetPropertiesFromRowset", LOG_ERROR
    SetPropertiesFromRowset = False
     
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : CopyTo
' PARAMETERS    :
'                   objDestinationProperties - The MSIXProperties destination object.
'                   booForceProductViewCopy  - Reserved.
'
' DESCRIPTION   : In the case of a service <i><b>only</b></i>, copy the properties value into another MSIXProperties object.
'                 All the property names that do not match are ignored.
' RETURN        :
Public Function CopyTo(ByVal objDestinationProperties As MSIXProperties, Optional ByVal booForceProductViewCopy As Boolean = False) As Boolean

    On Error GoTo ErrMgr
    
    Dim objProperty             As MSIXProperty
    Dim objProductView          As MSIXProperties
    Dim objRowset               As MTSQLRowsetSimulator
    Dim i                       As Long
   
    If (booForceProductViewCopy) Then
    
        ' This case is not documented. it allows to copy to a Product view destination object. By default a Product view
        ' object is not updatable. In one case in the MAM development we had to do it. But the rowset was a MTSQLRowsetSimulator.
    
        Set objProductView = objDestinationProperties
        Set objRowset = objProductView.Rowset
            
        ' Update the ProductView rowset based on the service properties value...
        ' Note that this can only work if the rowset is a MTSqlRowsetSimulator
        
        If (UCase$(TypeName(objRowset)) = "MTSQLROWSETSIMULATOR") Then
        
            For i = 0 To objRowset.Count - 1
                            
                If Me.Exist(objRowset.Name(i)) Then
                
                    objRowset.Value(i) = Me.Item(objRowset.Name(i))
                End If
            Next
            CopyTo = True
        Else
            TRACE MTMSIX_ERROR_01066, "CopyTo", "MSIXProperties.cls", LOG_ERROR
            CopyTo = False
        End If
    Else
        For Each objProperty In Me ' Default behavior
        
            ''Debug.Print objProperty.Name & "=" & objProperty.Value
            
            If objDestinationProperties.Exist(objProperty.Name) Then
            
                objDestinationProperties.Item(objProperty.Name).Value = objProperty.Value
            End If
        Next
        CopyTo = True
    End If
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CopyTo", "MSIXProperties.cls", LOG_ERROR
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SetPropertiesFromRowset
' PARAMETERS    :
' DESCRIPTION   : Add properties based on the Rowset column, all properties are defined as
'                 <i>type=string, length=255, Required=False, DefaultValue=Empty, Not Meterable</i>.
' RETURN        :
Public Function AddPropertiesFromRowset(objRowset As Variant) As Boolean

    On Error GoTo ErrMgr
    
    '
    ' In a next release we could update the type and length because we could use the ADO recordset
    ' in the case of a MTSQLRowset or ICOMProductView! Think about it Freddy!
    ' Me!
    ' NO! MDM V2
    ' Re-ME!
    
    Dim strName     As String
    Dim i           As Long
    Dim varValue    As Variant
    Dim strType     As String
    Dim lngLength   As Long
    Dim strMSIXType As String
    Dim IsMTSQLRowsetSimulator As Boolean
    
    If (Not IsValidObject(objRowset)) Then
    
        ''Debug.Assert 0
        Exit Function
    End If
    
    IsMTSQLRowsetSimulator = UCase$(TypeName(objRowset)) = UCase$("MTSQLRowsetSimulator")
    
    Me.Clear
    For i = 0 To objRowset.Count - 1
    
        strName = objRowset.Name(CLng(i))
        If (Not IsMTSQLRowsetSimulator) Then strType = objRowset.Type(CLng(i))
        
        lngLength = 0
        Select Case UCase(strType)
        
            Case "BSTR", "CHAR":
                                    strMSIXType = MSIXDEF_TYPE_STRING
                                    lngLength = MSIX_MAX_STRING_LENGTH
                                    
            Case "INT32":           strMSIXType = MSIXDEF_TYPE_INT32
            Case "FLOAT", "DOUBLE": strMSIXType = MSIXDEF_TYPE_DOUBLE
            Case "DECIMAL":         strMSIXType = MSIXDEF_TYPE_DECIMAL
            Case "TIMESTAMP":       strMSIXType = MSIXDEF_TYPE_TIMESTAMP
            Case Else
                                    strMSIXType = MSIXDEF_TYPE_STRING
        End Select
        Me.Add strName, strMSIXType, 255, False, Empty, eMSIX_PROPERTY_FLAG_NONE
    Next
    AddPropertiesFromRowset = True
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "AddPropertiesFromRowset", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SelectAll
' PARAMETERS    :
'                 strPropertyCSVList - If defined select only the property defined in the CSV list.
'
' DESCRIPTION   : Sets the <code>Selected</code> property of each MSIXProperty item in
'                 the collection has selected. The selected order is the creation order.
' RETURN        : TRUE if Ok.
Public Function SelectAll(Optional ByVal strPropertyCSVList As String, Optional ByVal strExcludePropertyCSVList As String) As Boolean

    On Error GoTo ErrMgr

    Dim p           As MSIXProperty
    Dim objList     As New CVariables
    Dim objListItem As CVariable
    Dim i           As Long
    
    
'Debug.Assert 0
    
    If (Len(strPropertyCSVList)) Then
    
        If Not (objList.LoadCSVString(strPropertyCSVList)) Then
        
            TRACE Replace(MTMSIX_ERROR_01069, "[LIST]", strPropertyCSVList), "MSIXProperties.cls", "SelectAll", LOG_ERROR
            Exit Function
        End If
        For Each objListItem In objList
            
            If (Me.Exist(objListItem.Name)) Then
                i = i + 1
                Me.Item(objListItem.Name).Selected = i
            End If
        Next
    Else
        
        If Len(strExcludePropertyCSVList) = 0 Then
        
            For Each p In Me
            
                p.Selected = p.Index
            Next
        Else
            If Not (objList.LoadCSVString(strExcludePropertyCSVList)) Then
        
                TRACE Replace(MTMSIX_ERROR_01069, "[LIST]", strExcludePropertyCSVList), "MSIXProperties.cls", "SelectAll", LOG_ERROR
                Exit Function
            End If
            i = 0
            For Each p In Me
            
                If Not objList.Exist(p.Name) Then
                
                    i = i + 1
                    p.Selected = i
                End If
            Next
        End If
    End If
    SelectAll = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "SelectAll", LOG_ERROR
End Function



' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : PopulateRowsetPropertiesForRemoteCall
' PARAMETERS    : MTXMLRowset object
' DESCRIPTION   : Populates the rowset with payment server information
' RETURN        : TRUE or FALSE
Private Function PopulateRowsetPropertiesForRemoteCall(ByRef Rowset As MTXMLRowset, ByVal strRemoteServerName As String) As Boolean

    Dim objServerAccessSet      As New MTServerAccessDataSet
    Dim objServerAccess         As MTServerAccessData
    
    On Error GoTo ErrMgr
      
    PopulateRowsetPropertiesForRemoteCall = False
    
    objServerAccessSet.Initialize
    Set objServerAccess = objServerAccessSet.FindAndReturnObject(strRemoteServerName)
    Set objServerAccessSet = Nothing
        
    Rowset.HostName = objServerAccess.ServerName
    Rowset.UserName = objServerAccess.UserName
    Rowset.PassWord = objServerAccess.PassWord
    
    PopulateRowsetPropertiesForRemoteCall = True
    Exit Function
Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "PopulateRowsetPropertiesForRemoteCall", LOG_ERROR
End Function


Private Function GetRemoteProductView(ByVal lngAccountID As Long, ByVal lngIntervalId As Long, ByVal strMsixdef As String, ByVal strSQLExtension As String, strLocalRelativPathForQuery As String, ByVal strRemoteVirtualDirectory As String, ByVal strRemoteServerName As String) As Variant

    Dim objRowset               As New MTXMLRowset   ' create the XML rowset
    Dim rcd                     As New MTRcd         ' create RCD
    Dim configPath              As String
    Dim booVirtualDirDefined    As Boolean
    Dim i                       As Long
    
    On Error GoTo ErrMgr
    

    
'    Dim objHTTP             As Object
'    Dim aRequestString      As String
'
'    Set objHTTP = CreateObject("Microsoft.XMLHTTP")
'
'    aRequestString = "http://f-torres/paymentsvr/GetRemoteProductView.asp?AccountID=123&IntervalID=1000&Language=us&Msixdef=metratech.com/AccountCreditRequest.MSIXDEF"
'    TRACE "ABOUT TO " & aRequestString
'    objHTTP.open "GET", aRequestString, False, "mtsystem", "mtsystem"
'    objHTTP.send
'    TRACE objHTTP.responseText
'    GoTo ErrMgr
    
    TRACE "MSIXProperties.GetRemoteProductView lngAccountID=" & lngAccountID & " lngIntervalID=" & lngIntervalId & " strMsixdef=" & strMsixdef & " strSQLExtension=" & strSQLExtension & " strLocalRelativPathForQuery=" & strLocalRelativPathForQuery & " strRemoteServerName=" & strRemoteServerName, "MSIXProperties.cls", "GetRemoteProductView", LOG_WARNING
    
    PopulateRowsetPropertiesForRemoteCall objRowset, strRemoteServerName ' Set required properties
    
    ' Initialize the rowset
    configPath = rcd.ExtensionDir & strLocalRelativPathForQuery ' "\paymentsvrclient\config\PaymentServer"
    objRowset.Init configPath
    
    ' Build the query
    objRowset.SetQueryTag "__GET_REMOTE_PRODUCT_VIEW__"
    
    objRowset.AddParam "%%ACCOUNT_ID%%", CStr(lngAccountID)
    objRowset.AddParam "%%INTERVAL_ID%%", CStr(lngIntervalId)
    objRowset.AddParam "%%MSIXDEF%%", CStr(strMsixdef)
    objRowset.AddParam "%%LANGUAGE%%", Me.Language
    
    If (Not booVirtualDirDefined) Then ' Set the virtual directory
    
        objRowset.AddParam "%%VirtualDirectory%%", strRemoteVirtualDirectory
    End If
    
    On Error Resume Next
    objRowset.Execute
    If (Err.Number) Then
    
        TRACE MTMSIX_ERROR_01067 & " " & GetVBErrorString(), "MSIXProperties.cls", "GetRemoteProductView", LOG_ERROR
    End If
    On Error GoTo ErrMgr
    Set GetRemoteProductView = objRowset
    Exit Function
ErrMgr:
    Set GetRemoteProductView = Nothing
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "GetRemoteProductView", LOG_ERROR
End Function




' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : CancelLocalization
' PARAMETERS    :
' RETURN        : TRUE if Ok.
Public Function CancelLocalization() As Boolean ' Documented=no

    On Error GoTo ErrMgr

    Dim p           As MSIXProperty

    For Each p In Me
    
        p.Caption = p.Name
    Next

    CancelLocalization = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "CancelLocalization", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Localized
' PARAMETERS    :
' DESCRIPTION   : Gets true if the service/product view properties are localized
' RETURN        :
Public Property Get Localized() As Boolean
    Localized = m_booLocalized
End Property

Public Property Let Localized(ByVal vNewValue As Boolean)
    m_booLocalized = vNewValue
End Property



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SelectedPropertiesCount
' PARAMETERS    :
' DESCRIPTION   : Return the number of properties selected.
' RETURN        :
Public Property Get SelectedPropertiesCount() As Long

    On Error GoTo ErrMgr

    Dim p           As MSIXProperty
    Dim lngCount    As Long
    
    For Each p In Me
    
        If (CBool(p.Selected)) Then
        
            lngCount = lngCount + 1
        End If
    Next
    SelectedPropertiesCount = lngCount
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "SelectedPropertiesCount", LOG_ERROR
End Property


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : InitializeAsCOMObject
' PARAMETERS    :
' DESCRIPTION   : Fill the MSIXProperties object based on a MT COM object exposing the IMTProperties interface. Support enum type.
' RETURN        :
Public Function InitializeAsCOMObject(objMTCOMObject As Variant) As Boolean

    On Error GoTo ErrMgr
  
    Dim objMTProperty           As Variant
    Dim objSubMTProperty        As Variant
    Dim objSubObject            As Variant
    Dim strCompoundPropertyName As String
        
    TRACEDEBUG "InitializeAsCOMObject " & TypeName(objMTCOMObject)
    
    For Each objMTProperty In objMTCOMObject.Properties
        
        TRACEDEBUG "Property Name:" & objMTProperty.Name
        
        With objMTProperty
        
            If (UCase$(objMTProperty.DataTypeAsString()) = MSIXDEF_TYPE_OBJECT) Then  ' Include the mtproperties of a compound object
                                                                            ' The compound object must expose a MTProperties collection
                strCompoundPropertyName = objMTProperty.Name
                
                If (UCase$(strCompoundPropertyName) = "UNITVALUEENUMERATION") Or (UCase$(strCompoundPropertyName) = "SUBSCRIBABLEACCOUNTTYPES") Then

                
                    ' We ignore this property which a special one not really standard
                    ' according the MTPROPERTY STANDARD...
                Else
                    ' Need to Validate, if not grab another property, there is no Continue so
                    ' goto the end of the loop
                    If (IsEmpty(objMTProperty.Value)) Or (IsNull(objMTProperty.Value)) Then
                        GoTo nxt
                    Else
                        Set objSubObject = objMTProperty.Value
                    End If
                    
                    If UCase$(TypeName(objSubObject)) = "LOCALIZEDENTITY" Then
                    
                    
                        'Debug.Assert 0
                        
                        'Dim objLanguageMappings As IEnumerable
                        'Set objLanguageMappings = objSubObject.LanguageMappings

                        Dim objLanguage As LocalizedEntry
                        For Each objLanguage In objSubObject
                            'WScript.echo "Language " & objLanguage.Key & "=" & objLanguage.Value
                            TRACEDEBUG "Property Name:" & strCompoundPropertyName & MSIXDEF_COMPOUND_PROPERTY_SEPARATOR & objLanguage.LanguageCode
                            Me.Add strCompoundPropertyName & MSIXDEF_COMPOUND_PROPERTY_SEPARATOR & objLanguage.LanguageCode, "string", .Length, False, Empty, eMSIX_PROPERTY_FLAG_COM_OBJECT_PROPERTY + eMSIX_PROPERTY_FLAG_PART_OF_LOCALIZED_LIST
                        Next
                    Else
                        For Each objSubMTProperty In objSubObject.Properties
                            With objSubMTProperty
                                TRACEDEBUG "Property Name:" & strCompoundPropertyName & MSIXDEF_COMPOUND_PROPERTY_SEPARATOR & .Name
                                Me.Add strCompoundPropertyName & MSIXDEF_COMPOUND_PROPERTY_SEPARATOR & .Name, .DataTypeAsString(), .Length, .Required, Empty, eMSIX_PROPERTY_FLAG_COM_OBJECT_PROPERTY
                            End With
                        Next
                    End If
                End If
            Else
                If (UCase$(objMTProperty.DataTypeAsString()) = MSIXDEF_TYPE_ENUM) Then
                    Me.Add .Name, .DataTypeAsString, .Length, .Required, .Value, eMSIX_PROPERTY_FLAG_COM_OBJECT_PROPERTY, objMTProperty.EnumSpace, objMTProperty.EnumType
                Else
                    Me.Add .Name, .DataTypeAsString, .Length, .Required, .Value, eMSIX_PROPERTY_FLAG_COM_OBJECT_PROPERTY
                End If
            End If
        End With
nxt:
    Next
    InitializeAsCOMObject = True
    Exit Function
ErrMgr:

  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "InitializeAsCOMObject", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function PopulateFromCOMObject(objMTCOMObject As Variant) As Boolean

    On Error GoTo ErrMgr
  
    Dim objMSIXProperty     As MSIXProperty
    Dim strSubObjectName    As String
    Dim objSubObject        As Object
    Dim strSubPropertyName  As String
    Dim lngPos              As Long
    Dim strValue            As String
    Dim booTrace            As Boolean
    Dim objProperty         As Variant ' MTProperty
        
''Debug.Assert 0
'
'It is about our COM object MTProperties class. The method Item() is the default method.
'Therefore this VB6 code for example is valid :
'
'        objProductCatalog.Properties("Name").Value
'
'Now if you use the object AdjustmentType which is a C# object implementing the COM Object MTProperties
'the previous code does not work because the Item method is not viewed as the default method. You have to add the name Item
'
'        objProductCatalog.Properties.Item("Name").Value
'
'
'We know that with .NET there is no more default method and value like COM, but it seems that a COM object embeded in a C#
'has also the same behavior
'
    
    For Each objMSIXProperty In Me
        
        TRACEDEBUG objMSIXProperty.Name
        TRACE PreProcess("PopulateFromCOMObject Copy property [NAME]", "NAME", objMSIXProperty.Name), , , LOG_DEBUG
            
        booTrace = False
        lngPos = InStr(objMSIXProperty.Name, MSIXDEF_COMPOUND_PROPERTY_SEPARATOR)   ' If we have a __ this mean this is a compound properties
        If (lngPos) Then
        
            strSubObjectName = Mid(objMSIXProperty.Name, 1, lngPos - 1)
            strSubPropertyName = Mid(objMSIXProperty.Name, lngPos + Len(MSIXDEF_COMPOUND_PROPERTY_SEPARATOR))
                        
            On Error Resume Next
            Set objSubObject = CallByName(objMTCOMObject, strSubObjectName, VbGet) ' Get a ref on the sub object
            If (Err.Number) Then Set objSubObject = Nothing
            On Error GoTo ErrMgr
            
            If (IsValidObject(objSubObject)) Then
            
                If objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_PART_OF_LOCALIZED_LIST Then ' MDM 3.6
                
                    Dim objLanguage         As LocalizedEntry
                    'Dim objLanguageMappings As IEnumerable
                    'Set objLanguageMappings = objSubObject.LanguageMappings
                    
                    'Debug.Assert 0
                    
                    For Each objLanguage In objSubObject
                    
                        If UCase$(objLanguage.LanguageCode) = UCase$(strSubPropertyName) Then
                                
                            objMSIXProperty.Value = objLanguage.Value
                            TRACEDEBUG objMSIXProperty.Name & "=" & objMSIXProperty.Value
                            booTrace = True
                            Exit For
                        End If
                    Next
                
                ElseIf IsObject(objSubObject.Properties.Item(CStr(strSubPropertyName)).Value) Then ' MDM 3.5
                    '
                    ' If we are here this mean we have a triple object in a row O1.O2.O3
                    '
                    ' MDM Do not support this case but in MAM 3.5 Adjustment the case appear
                    ' so I ignore it...
                    TRACE PreProcess("MDM-WARNING-MDM does support only 1 level of embed object in dialog. [O1].[O2].[O3] Found", "O3", strSubPropertyName, "O2", strSubObjectName, "O1", TypeName(objMTCOMObject)), Me, "PopulateFromCOMObject", LOG_DEBUG
                Else
                    objMSIXProperty.Value = objSubObject.Properties.Item(CStr(strSubPropertyName)).Value ' Read the property value
                    TRACEDEBUG objMSIXProperty.Name & "=" & objMSIXProperty.Value
                    booTrace = True
                End If
            Else
                TRACE PreProcess("Compound object [COMPOUND_OBJECT] from [OBJECT_TYPE] property [NAME] is Nothing " & GetVBErrorString(), "NAME", objMSIXProperty.Name, "OBJECT_TYPE", TypeName(objMTCOMObject), "COMPOUND_OBJECT", strSubObjectName), Me, "PopulateFromCOMObject", LOG_ERROR
            End If
        Else
            If (Tools.MTPropertiesExist(objMTCOMObject, objMSIXProperty.Name)) Then
                
                On Error Resume Next
                
                objMSIXProperty.Value = objMTCOMObject.Properties.Item(CStr(objMSIXProperty.Name)).Value
                If (Err.Number) Then
                    TRACE PreProcess("Cannot read from object [OBJECT_TYPE] property [NAME]. " & GetVBErrorString(), "NAME", objMSIXProperty.Name, "OBJECT_TYPE", TypeName(objMTCOMObject)), Me, "PopulateFromCOMObject", LOG_ERROR
                    Err.Clear
                Else
                    TRACEDEBUG objMSIXProperty.Name & "=" & objMSIXProperty.Value
                    booTrace = True
                End If
                On Error GoTo ErrMgr
            End If
        End If
        If (booTrace) Then
            ' Printing the value must support NULL - bug found 3/5/2003 with NOA!
            TRACE PreProcess("PopulateFromCOMObject [NAME]=[VALUE];", "NAME", objMSIXProperty.Name, "VALUE", "" & objMSIXProperty.Value), Me, "PopulateFromCOMObject", LOG_DEBUG
        End If
    Next
    PopulateFromCOMObject = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "PopulateFromCOMObject", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Enabled() As Boolean

    On Error GoTo ErrMgr
    
    Enabled = m_booEnabled
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Enabled Get", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let Enabled(ByVal vNewValue As Boolean)

    On Error GoTo ErrMgr
  
    Dim objMSIXProperty As MSIXProperty
    
    m_booEnabled = vNewValue
    
    For Each objMSIXProperty In Me
    
        objMSIXProperty.Enabled = vNewValue
    Next
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "Enabled Let", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function PopulateCOMObject(objMTCOMObject As Variant) As Boolean

    On Error GoTo ErrMgr
  
    Dim objMSIXProperty     As MSIXProperty
    Dim strSubObjectName    As String
    Dim objSubObject        As Object
    Dim strSubPropertyName  As String
    Dim lngPos              As Long
    
'    'Debug.Assert 0
    
    For Each objMSIXProperty In Me
    
        
        TRACE PreProcess("PopulateCOMObject [NAME]=[VALUE];", "NAME", objMSIXProperty.Name, "VALUE", objMSIXProperty.Value), , , LOG_DEBUG
        
        
        lngPos = InStr(objMSIXProperty.Name, MSIXDEF_COMPOUND_PROPERTY_SEPARATOR)
        
        '
        ' COMPOUND PROPERTY CASE
        '
        If (lngPos) Then ' If we have a . this mean this is a compound properties
        
            strSubObjectName = Mid(objMSIXProperty.Name, 1, lngPos - 1)
            strSubPropertyName = Mid(objMSIXProperty.Name, lngPos + Len(MSIXDEF_COMPOUND_PROPERTY_SEPARATOR))
                        
            Set objSubObject = CallByName(objMTCOMObject, strSubObjectName, VbGet) ' Get a ref on the sub object
            
            
            ' MDM 3.6 Support of Part of localized list property
            If objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_PART_OF_LOCALIZED_LIST Then
            
                     objSubObject.SetMapping strSubPropertyName, objMSIXProperty.Value
 
            Else
                    Select Case UCase(objSubObject.Properties.Item(CStr(strSubPropertyName)).DataTypeAsString)
                    
                        Case MSIXDEF_TYPE_TIMESTAMP ' Support the case when a date is null - CDATE(aDate)=0, Internal we use an Empty
                        
                            If UCase$(TypeName(objSubObject)) = UCase$("IMTPCTimeSpan") And UCase$(strSubPropertyName) = "STARTDATE" Then
                            
                                If Len("" & objMSIXProperty.Value) Then ' Property is defined
                                
                                    objSubObject.Properties.Item(CStr(strSubPropertyName)).Value = objMSIXProperty.Value
                                Else
                                    objSubObject.SetStartdateNull ' Property is blank
                                End If
                            
                            ElseIf UCase$(TypeName(objSubObject)) = UCase$("IMTPCTimeSpan") And UCase$(strSubPropertyName) = "ENDDATE" Then
                            
                                If Len("" & objMSIXProperty.Value) Then ' Property is defined
                                
                                    objSubObject.Properties.Item(CStr(strSubPropertyName)).Value = objMSIXProperty.Value
                                Else
                                    objSubObject.SetEnddateNull ' Property is blank
                                End If
                                                    
                            Else
                                '
                                ' If compound property is a timestamp and not inside object type IMTPCTimeSpan
                                ' which is not likely to happen because all date in the product cataglog
                                ' are stored in a IMTPCTimeSpan! But just in case
                                '
                                objSubObject.Properties.Item(CStr(strSubPropertyName)).Value = objMSIXProperty.Value
                                TRACE "Compound property type timestamp and not inside object type IMTPCTimeSpan found", "MSIXProperties.cls", "PopulateCOMObject", LOG_WARNING
                            End If
                                            
                        Case Else
                            ' MDM 3.5
                            If IsObject(objSubObject.Properties.Item(CStr(strSubPropertyName)).Value) Then
                                '
                                ' If we are here this mean we have a triple object in a row O1.O2.O3
                                '
                                ' MDM Do not support this case but in MAM 3.5 Adjustment the case appear so I ignore it...
                                TRACE PreProcess("MDM-WARNING-MDM Does not support only 1 level of embed object in dialog. [O1].[O2].[O3] Found", "O3", strSubPropertyName, "O2", strSubObjectName, "O1", TypeName(objMTCOMObject)), , , LOG_DEBUG
                            Else
                                ' If compound property is not a timestamp
                                objSubObject.Properties.Item(CStr(strSubPropertyName)).Value = objMSIXProperty.Value
                            End If
                    End Select
            End If
        Else
        
        '
        ' REGULAR PROPERTY CASE
        '
        
            If (Tools.MTPropertiesExist(objMTCOMObject, objMSIXProperty.Name)) Then
                             
                Select Case UCase(objMTCOMObject.Properties.Item(CStr(objMSIXProperty.Name)).DataTypeAsString)
                
                    Case MSIXDEF_TYPE_TIMESTAMP ' Support the case when a date is null - CDATE(aDate)=0, Internal we use an Empty
                    
                        objMTCOMObject.Properties.Item(objMSIXProperty.Name).Value = IIf(IsEmpty(objMSIXProperty.Value), CDate(0), objMSIXProperty.Value)
                                                
                    Case Else
                        objMTCOMObject.Properties.Item(objMSIXProperty.Name).Value = objMSIXProperty.Value
                End Select
            End If
        End If
    Next
    PopulateCOMObject = True
    Exit Function
ErrMgr:

  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "PopulateCOMObject", LOG_ERROR
End Function



Public Property Get Version() As String
    Version = m_strVersion
End Property

Public Property Let Version(ByVal vNewValue As String)
    m_strVersion = vNewValue
End Property


Public Property Get XML() As String

    On Error GoTo ErrMgr
    
    Dim objMSIXProperty As MSIXProperty
    Dim strXML          As String
    Dim strValue        As String
    
'- <properties>
'- <property>
'  <dn>taxtype</dn>
'  <value>3</value>
'  </property>
    
    strXML = strXML & "<properties>" & vbNewLine
    
    For Each objMSIXProperty In Me
    
    
        If (objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF) = eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF Then
        
            If (objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_METERED) Then
            
                strXML = strXML & "  <property>" & vbNewLine
                strXML = strXML & InTag("dn", LCase$(objMSIXProperty.Name), "    ")
                
                Select Case UCase$(objMSIXProperty.PropertyType)
                Case MSIXDEF_TYPE_TIMESTAMP
                    strValue = objMSIXProperty.MSIXDateValue
                Case Else
                    strValue = objMSIXProperty.Value
                End Select
                strXML = strXML & InTag("value", strValue, "    ")
                strXML = strXML & "  </property>" & vbNewLine
            End If
        End If
    Next
    strXML = strXML & "</properties>" & vbNewLine
    XML = strXML
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "XML Get", LOG_ERROR
End Property

' We expect the XML that the xml has been validated
Public Property Let XML(strXML As String) ' #RUDI

    On Error GoTo ErrMgr
    
    Dim m_XMLDoc            As New MSXML2.DOMDocument30
    Dim XMLMSIXProperties   As IXMLDOMNodeList
    Dim XMLMSIXProperty     As IXMLDOMNode
    Dim strValue            As String
    Dim strPName            As String
    Dim objMSIXProperty     As MSIXProperty
    Dim strNewType             As String
        
    m_XMLDoc.loadXML strXML
    Set XMLMSIXProperties = m_XMLDoc.selectNodes("/properties/property")
    
    ' Clear the flag eMSIX_PROPERTY_FLAG_METERED for all the property
    For Each objMSIXProperty In Me
        If objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_METERED Then objMSIXProperty.Flags = objMSIXProperty.Flags - eMSIX_PROPERTY_FLAG_METERED
    Next
    
    For Each XMLMSIXProperty In XMLMSIXProperties
    
        strPName = XMLMSIXProperty.selectSingleNode("dn").Text
        strValue = XMLMSIXProperty.selectSingleNode("value").Text
        
'        Debug.Print strPName & " " & strValue
        
        If Not Me.Exist(strPName) Then
        
            strNewType = ""
        
            Select Case UCase(strPName)
                
                Case UCase$("_NewParentInternalID"), UCase$("_INTERVALID"), UCase$("_NewParentID"): strNewType = MSIXDEF_TYPE_INT32
                
                Case UCase$("_TransactionCookie"), UCase$("_CollectionID"): strNewType = MSIXDEF_TYPE_STRING
                
                Case UCase$("_Resubmit"), UCase$("ProfileStage"): strNewType = MSIXDEF_TYPE_BOOLEAN
                
            End Select
            
            If Len(strNewType) Then
                Me.Add strPName, strNewType, 255, False, Empty
            Else
                RaiseError PreProcess(MTMSIX_ERROR_01102, "NAME", strPName, "SERVICE", Me.Name), , , LOG_APPLICATION_ERROR
            End If
             
        End If
        
        Select Case Me.Item(strPName).PropertyType

            Case MSIXDEF_TYPE_STRING

                ' If the string is too long we truncate it and log a warning.
                ' This can happen if someone has errors in the queue and then changes the service definition.
                If Me.Item(strPName).Length < Len(strValue) Then

                    Me.Item(strPName).Value = Mid(strValue, 1, Me.Item(strPName).Length)
                    TRACE PreProcess(MTMSIX_ERROR_01106, "NAME", strPName, "VALUE", strValue, "LENGTH", Me.Item(strPName).Length), "MSIXProperties.cls", "XML Let", LOG_WARNING
                Else

                    Me.Item(strPName).Value = strValue
                End If

            Case Else

                Me.Item(strPName).Value = strValue
                
        End Select

        Me.Item(strPName).Flags = Me.Item(strPName).Flags + eMSIX_PROPERTY_FLAG_METERED
    Next
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "XML Let", LOG_ERROR
End Property

Public Property Get Selector() As CSelector
    If Not IsValidObject(m_objSelector) Then Set m_objSelector = New CSelector
    Set Selector = m_objSelector
End Property


Public Property Let Session(objSession As IMTSession)

    On Error GoTo ErrMgr
    Dim objMSIXProperty As MSIXProperty
    Dim vchild As Variant
    Dim Value As Variant
    Dim strPName As String
    Dim strMSIXType  As String
    
    
    ' Clear the flag eMSIX_PROPERTY_FLAG_METERED for all the property
    For Each objMSIXProperty In Me
        If objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_METERED Then objMSIXProperty.Flags = objMSIXProperty.Flags - eMSIX_PROPERTY_FLAG_METERED
    Next
    
    For Each vchild In objSession
    
        Select Case vchild.Type
    
            Case SESSION_PROPERTY_TYPE_DATE: Value = objSession.GetOLEDateProperty(vchild.NameID)
            'Case SESSION_PROPERTY_TYPE_TIME: Value = objSession.GetTimeProperty(vchild.Nameid) ' NEVER METER ACCORDING DEREK
            Case SESSION_PROPERTY_TYPE_STRING: Value = objSession.GetStringProperty(vchild.NameID)
            Case SESSION_PROPERTY_TYPE_LONG: Value = objSession.GetLongProperty(vchild.NameID)
            Case SESSION_PROPERTY_TYPE_DOUBLE: Value = objSession.GetDoubleProperty(vchild.NameID)
            Case SESSION_PROPERTY_TYPE_BOOLEAN: Value = objSession.GetBoolProperty(vchild.NameID)
            
            Case SESSION_PROPERTY_TYPE_DECIMAL: Value = objSession.GetDecimalProperty(vchild.NameID)
            
            Case SESSION_PROPERTY_TYPE_ENUM:
                Value = objSession.GetEnumProperty(vchild.NameID)
                Value = Me.Tools.GetEnumValueByID(Value)
        End Select
        strMSIXType = GetMSIXTypeStringFromSessionTypeID(vchild.Type)
  
        Debug.Print vchild.Name, Value
        strPName = vchild.Name
        
        If Not Me.Exist(strPName) Then
        
'            Select Case UCase(strPName)
'                Case UCase$("_NewParentInternalID"), UCase$("_INTERVALID"), UCase$("_NewParentID"): strNewType = MSIXDEF_TYPE_INT32
'                Case UCase$("_TransactionCookie"), UCase$("_CollectionID"): strNewType = MSIXDEF_TYPE_STRING
'                Case UCase$("_Resubmit"), UCase$("ProfileStage"): strNewType = MSIXDEF_TYPE_BOOLEAN
'            End Select
            
            If Len(strMSIXType) Then
                Me.Add strPName, strMSIXType, 255, False, Empty
            Else
                RaiseError PreProcess(MTMSIX_ERROR_01102, "NAME", strPName, "SERVICE", Me.Name), , , LOG_APPLICATION_ERROR
            End If
        End If
        
        Select Case Me.Item(strPName).PropertyType

            Case MSIXDEF_TYPE_STRING

                ' If the string is too long we truncate it and log a warning.
                ' This can happen if someone has errors in the queue and then changes the service definition.
                If Me.Item(strPName).Length < Len(Value) Then

                    Me.Item(strPName).Value = Mid(Value, 1, Me.Item(strPName).Length)
                    TRACE PreProcess(MTMSIX_ERROR_01106, "NAME", strPName, "VALUE", Value, "LENGTH", Me.Item(strPName).Length), "MSIXProperties.cls", "Session Let", LOG_WARNING
                Else

                    Me.Item(strPName).Value = Value
                End If

            Case Else

                Me.Item(strPName).Value = Value
                
        End Select

        Me.Item(strPName).Flags = Me.Item(strPName).Flags + eMSIX_PROPERTY_FLAG_METERED
 
 ' Since 4.0 we no longer speacial case _ properties.  They will be handled elsewhere
 '       If Len(strPName) Then
 '           If Mid(strPName, 1, 1) = "_" Then
 '               Me.Item(strPName).Flags = Me.Item(strPName).Flags + eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF
 '           End If
 '       End If
        
        
    Next
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperties.cls", "XML Let", LOG_ERROR
End Property


' Return the name/value/expected value of the property that did not match else ""
Public Function CompareValues(ParamArray defines() As Variant) As String
    Dim i                   As Long
    Dim strName             As String
    Dim strValue            As String
    Dim strExpectedValue    As String
    
    
    
    For i = 0 To UBound(defines()) Step 2
    
        strName = "" & defines(i)
        strValue = "" & defines(i + 1)
        
        If Me.Item(strName).IsEnumType Then
            
            strExpectedValue = "" & Me.Item(strName).LocalizedValue
        Else
            strExpectedValue = "" & Me.Item(strName).Value
        End If
        
        CompareValues = "Name:" & strName & "; PassedValue:" & strValue & "; ExpectedValue:" & strExpectedValue & "; "
        If Not Me.Exist(strName) Then Exit Function
        If strExpectedValue <> strValue Then Exit Function
    Next
    CompareValues = ""
End Function

Public Property Let CSV(Optional ByVal booFillOnlyIfEmpty As Boolean = False, strValues As String)

    Dim i                   As Long
    Dim strName             As String
    Dim strValue            As String
    Dim arr                 As Variant
    
    arr = Split(strValues, ",")
    For i = 0 To UBound(arr) Step 2
    
        strName = "" & arr(i)
        strValue = "" & arr(i + 1)
        If booFillOnlyIfEmpty Then
            If IsEmpty(Me.Item(strName).Value) Then
                Me.Item(strName).Value = strValue
            End If
        Else
            Me.Item(strName).Value = strValue
        End If
    Next
End Property

Private Function TRACEDEBUG(ByVal strMessage As String) As Boolean
    Debug.Print strMessage
    If IsValidObject(Me.Configuration) Then
        If Me.Configuration.LogDebug Then
            TRACE strMessage, Me, , LOG_DEBUG
        End If
    End If
    TRACEDEBUG = True
End Function


Private Function Testr(objPO As Variant)


Debug.Assert 0
Dim pc
Set pc = CreateObject("Metratech.MTProductCatalog")

Dim po
Set po = pc.GetProductOfferingByName("Audio Conferencing Product Offering 7/14/2003 1:26:12 PM")
Set po = objPO

'wscript.echo "Product Offering Id " & po.ID

Dim objProperties
Set objProperties = po.Properties

Dim objProperty

'for each objProperty in objProperties
'   wscript.echo "[" & objProperty.Name & "][" & objProperty.DataTypeAsString & "]=" & objProperty.Value
'next


Set objProperty = objProperties("DisplayNames")
'wscript.echo "[" & objProperty.Name & "][" & objProperty.DataTypeAsString & "]=" & objProperty.Value

Dim objLocalized
Set objLocalized = objProperty.Value

'wscript.echo "ID is " & objLocalized.ID

'wscript.echo "objLocalized is a [" & TypeName(objLocalized) & "]"
'wscript.echo "objLocalized.LanguageMappings is a [" & TypeName(objLocalized.LanguageMappings) & "]"

Dim objLanguage
Dim objLanguageMappings As IEnumerable
Set objLanguageMappings = objLocalized.LanguageMappings

For Each objLanguage In objLanguageMappings
  Debug.Print "Language " & objLanguage.Key & "=" & objLanguage.Value
Next

End Function
