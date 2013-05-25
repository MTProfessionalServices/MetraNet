VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXProperty"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"399321CB00EC"
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
' CLASS         : MSIXProperty
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   : This object and associated objects implement a full COM Object Model for a MetraTech property.
'                 Some of the properties and methods of this object are reserved by the MetraTech Dialog Manager VBScript layer.
'                 This object must not be used directly, but through an instance of the MSIXHandler object.
'                 Refer to the Metratech Dialog Manager Programming Guide for more information.
'
'                 The MSIX property 'Type' is named <code>PropertyType</code> because Type is a VB reserved key word.
'                 The MSIX attribute UserVisible is a property.
'
'                 MSIX Types - string, unistring, boolean, int32, double, float, timestamp, enum, decimal are supported.

'                 MSIX Boolean - The property <code>Value</code> for MSIX boolean property support the following values
'                       TRUE  - "T","TRUE" ,"Y","ON",1,TRUE
'                       FALSE - "F","FALSE","N","",0,FALSE
'                 The value stored or return is VB Boolean (VT_BOOL) True(-1) or False(0). The Value meter is always 'T' or 'F'.
'
'                 MSIX dynamic enum type : Some MSIX property may not be defined as an enum type. But an enum type can help
'                 to build a UI. Specially if one wants to associate the property with a ComboBox. Rather than storing the value of the enum type
'                 in the config\enumtype folder into a XML file; one can stored and set the enum type programmatically by calling the method
'                 <code>AddValidListOfValues()</code>. The programmer must take care of the localization.
'
'
' $Date: 7/9/2002 3:55:53 PM$
' $Author: Alon Becker$
' $Revision: 110$
' $Workfile: MSIXProperty.cls$
'
'
'****************************************************************************************************************************************************
Option Explicit

Public TRACE_ID As Long

Public Name          As String      ' MSIX <dn> tag.
Public Length        As Long        ' MSIX <type> tag.
Public Required      As Boolean     ' MSIX <required> tag.
Public DefaultValue  As Variant     ' MSIX <defaultvalue> tag. If the default value from the msixdef file is not defined, the DefaultValue is EMPTY (VT_EMPTY)
Public UserVisible   As Boolean     ' MSIX attribute <i>UserVisible</i>. If the attribute is not defined, in the MSIXDEF file, the value is TRUE.
Public Description   As String      ' MSIX <description> tag.



' MDM v2

Public Index         As Long        ' The index in the msixdef file. The property returns the order in which the property definitions are stored in the MSIXDEF file.

Public EnumType      As MSIXEnumType                ' Gets the enum type instance, allocated only if the property is an enum type. See function <code>IsEnumType()</code>.
Public Flags         As eMSIX_PROPERTY_FLAG         ' See enum type eMSIX_PROPERTY_FLAG. The default value is eMSIX_PROPERTY_FLAG_NONE. The flag must be set to eMSIX_PROPERTY_FLAG_METERED so the MSIX property can be metered.
Public Selected      As Long                        ' Defines if the property belongs to the selected property. 0 means not selected , >0 means selected and defines the property order of the selection.
Public Format        As String                      ' Define the value format when the <code>Value</code> property is called.
Public Alignment     As String                      ' Reserved for the MDM. Defines the property alignment in a MDM Product View Browser. Returns the HTML attribute align value : Right or Left.
Public EventFlag     As eMSIX_PROPERTY_EVENT_FLAG   ' Reserved for the MDM. Default value is eMSIX_PROPERTY_EVENT_FLAG_NONE. Not used in this version. DOCUMENTED=NO
Public Tag           As Variant                     ' Returns or sets an expression that stores any extra data needed for your program.

Public EnumTypeSupportEmpty As Boolean              ' Default value false, when an enum type value is empty the property Value return the first enum type value except if the boolean is TRUE


' MDM v2.1

Public ExporTable   As Boolean     ' MDM v2.1 MSIX attribute <i>ExporTable</i>. If the attribute is not defined, in the MSIXDEF file, the value is TRUE.
Public Filterable   As Boolean     ' MDM v2.1 MSIX attribute <i>Filterable</i>. If the attribute is not defined, in the MSIXDEF file, the value is TRUE.


' MDM v3.0
Public capabilities As String ' MDM v3.0 Capability name stored in a CSV format

'Private m_varPreviousValue      As Variant
Private m_varValue              As Variant
Private m_PropertyType          As String
Private m_Sorted                As MTSortOrder
Private m_Parent                As MSIXProperties              ' Reference the collection of MSIXProperty, MSIXProperties instance, the parent.
Private m_varCaption            As Variant                     ' As Variant because I need to know of it was initialized
Private m_booEnabled            As Boolean                     ' Defines if the MSIX property is enabled. If the property is not enabled, the MSIX <code>Required</code> property is ignored and the property is not metered.

Private m_strSQLColumnName      As Variant                      ' As Variant because I need to know of it was initialized

Public Enum eMSIX_PROPERTY_FLAG

    eMSIX_PROPERTY_FLAG_NONE = 0                    ' None, default value.
    eMSIX_PROPERTY_FLAG_METERED = 1                 ' The Property will be metered.
    eMSIX_PROPERTY_FLAG_ACCOUNT_USAGE_TABLE = 2     ' For product view only. This means that the property comes from table t_acc_usage and not the product view table itself.
    eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET = 4    ' For product view only. This means that this property does not belong to the product view. Reserved for the MDM.
    eMSIX_PROPERTY_FLAG_STRING_ID = 8               ' Related to MDM, if this flag is set the following chars only will be allowed to be entered : _ ABCDEFGHIJKLMNOPQRSTVWUXYZabcdefghijklmnopqrstvwuxyz
    eMSIX_PROPERTY_FLAG_DO_NOT_STORE_CAPTION_IN_CACHE = 16  ' Do not Store the caption in the cache. Default mode store in cache. Added in MDM v2.
    eMSIX_PROPERTY_FLAG_COM_OBJECT_PROPERTY = 32 ' Support of COM Object implementing a MTProperties Collection
    eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING = 64  ' MDM 3.0 - Allow to not meter some property in the next metering without to have to alter the value
    eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF = 128           ' MDM 3.0 Loaded from a service definition or product view definition
    eMSIX_PROPERTY_FLAG_PART_OF_LOCALIZED_LIST = 256  ' MDM 3.6 the property with this flag has been created on the fly by the function MSIXProperties.InitializeAsCOMObject
                                                      ' to support ProductCatalog DisplayNames localization
    
    
End Enum

Public Enum eMSIX_PROPERTY_EVENT_FLAG               ' Reserved for the MDM. Define the type of event associated with the property.

    eMSIX_PROPERTY_EVENT_FLAG_NONE = 0              ' None
    eMSIX_PROPERTY_EVENT_FLAG_CLICK_EVENT = 1       ' The Property has a Click Event in the VBScript code
End Enum

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the MSIX property in a string (name, type, length, defaultvalue, required, index, value).
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr

    ToString = "name=" & Name & "; type=" & PropertyType & "; LocalizedValue=" & LocalizedValue & "; length=" & Length & "; defaultvalue=" & DefaultValue & "; required=" & Required & "; index=" & Index & "; value=" & Me.Value & "; Enabled=" & Enabled & "; " & vbNewLine
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "ToString", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : PropertyType
' PARAMETERS    :
' DESCRIPTION   : Gets the MSIX Type. 'Type' is a VB keyword. The MSIX type is always
'                 stored and returned in uppercase. It is possible to change the type of a property on the fly. When the type is set to
'                 enum, the <i>strEnumSpace</i> and <i>strEnumTypeName</i> parameter should be defined, but the object support also the 2 syntax.
'                 When the type is set to enum, the enum type and its localization are loaded.
'
'                 MSIX Boolean are internally converted into the enum type Boolean. So an boolean can be assigned to a combo box.
'                 The enum type boolean is defined in the global name space.
' RETURN        :
Public Property Get PropertyType() As String

    On Error GoTo ErrMgr
   
    PropertyType = m_PropertyType
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "PropertyType", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SetPropertyType
' PARAMETERS    :
' DESCRIPTION   : Set the MSIX type. The type of a MSIX property can be changed programmatically. See the property PropertyType().
' RETURN        :
Public Function SetPropertyType(ByVal strType As String, Optional ByVal strEnumSpace As String, Optional ByVal strEnumTypeName As String) As Boolean

    On Error GoTo ErrMgr
    
    m_PropertyType = UCase$(strType)
    
    If IsValidObject(EnumType) Then
    
        EnumType.Delete
    End If
    Set EnumType = Nothing
    
    If (m_PropertyType = MSIXDEF_TYPE_UNISTRING) Then m_PropertyType = MSIXDEF_TYPE_STRING ' String and unistring are the same
    
    ' g_booReadEnumType added in MDM 3.0 so in some case we can avoid to read the enum type...
    'TRACE Me.Name & " - SetPropertyType - " & Me.ToString()
    If g_booReadEnumType And (UCase$(PropertyType) = MSIXDEF_TYPE_ENUM) Or (UCase$(PropertyType) = MSIXDEF_TYPE_BOOLEAN) Then  ' Allow the Enum Type
    
        Set EnumType = New MSIXEnumType
        
        EnumType.Initialize
        Set EnumType.Parent = Me
        
        If ((UCase$(PropertyType) = MSIXDEF_TYPE_BOOLEAN)) Then
        
            strEnumTypeName = MSIXDEF_TYPE_BOOLEAN
            strEnumSpace = METRATECH_GLOBAL_NAME_SPACE_NAME
        End If
        If (Len(strEnumTypeName) = 0) Then strEnumTypeName = Me.Name
        
        EnumType.SetEnumType Parent.Language, strEnumSpace, strEnumTypeName
    End If
    
    Select Case PropertyType ' This is the length for the UI in terms of char, to avoid overflow
    
        Case MSIXDEF_TYPE_FLOAT, MSIXDEF_TYPE_DOUBLE, MSIXDEF_TYPE_DECIMAL
            Length = MTMSIX_DEFAULT_DECIMAL_MAX_CHAR_SIZE
            Alignment = HTML_RIGHT
                
        Case "INT32"
            ' note we do not have max length for a long though we could
            Alignment = HTML_RIGHT
                
        Case Else
            Alignment = HTML_LEFT
    End Select
    SetPropertyType = True
        
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "PropertyType", LOG_ERROR
  SetPropertyType = False
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Class_Initialize
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    m_booEnabled = True
    
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "Class_Initialize", LOG_ERROR
End Sub

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Class_Terminate
' PARAMETERS    :
' DESCRIPTION   : If the enum type object was allocated it is free
' RETURN        :
Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE, "name=" & Me.Name
        
    #End If
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "Class_Terminate", LOG_ERROR
End Sub

' -------------------------------------------------------------------------------
' FUNCTION      : IsEnumType
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE is the property is an enum type.
' RETURN        :
Public Function IsEnumType() As Boolean

    On Error GoTo ErrMgr
    
    IsEnumType = Not CBool(Me.EnumType Is Nothing)
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "IsEnumType", LOG_ERROR
End Function


' -------------------------------------------------------------------------------
' FUNCTION      : Initialize
' PARAMETERS    :
'        objParent          - A reference to the MSIXProperties Instance, the parent.
'        strName            - The name of the MSIX property.
'        strPType           - The type of the MSIX property.
'        lngLength          - The length of the MSIX property only if the string is a STRING.
'        lngFlags           - Internal flag, see enum type eMSIX_PROPERTY_FLAG.
'        booRequired        - The required mode of the MSIX property.
'        varDefaultValue    - The default value of the MSIX property.
'        strEnumSpace       - The enum space of the MSIX property, if the type is enum.
'        strEnumTypeName    - The enum type name of the MSIX property, if the type is enum.
'        booUserVisible     - MSIX attribute UserVisible. The default value is TRUE.
'
' DESCRIPTION   : Initialize an MSIX property with the function parameters. If the length of a string property type is 0, a warning is logged
'                 and the size is set to MSIX_MAX_STRING_LENGTH (255).
'
'                 If the type of an property is enum, the enum type and its localization are loaded. Supports the MSIXCache object if defined.
'                 The MSIX property value is set to its MSIX default value. If there is no MSIX default value, the value is set to Empty.
'
' RETURN        : Returns TRUE if Ok.
Public Function Initialize(ByVal objParent As MSIXProperties, ByVal strName As String, ByVal strPType As String, ByVal lngLength As Long, ByVal lngFlags As eMSIX_PROPERTY_FLAG, ByVal booRequired As Boolean, ByVal varDefaultValue As Variant, Optional ByVal strEnumSpace As String, Optional ByVal strEnumTypeName As String, Optional ByVal booUserVisible As Boolean = True, Optional ByVal booExporTable As Boolean = True, Optional ByVal booFilterable As Boolean = True) As Boolean

    On Error GoTo ErrMgr
    
    Dim strError As String

    Set Me.Parent = objParent
    
    Me.Required = booRequired
    Me.Name = strName
    Me.Flags = lngFlags
    Me.UserVisible = booUserVisible
    
    Me.ExporTable = booExporTable
    Me.Filterable = booFilterable
    
    Me.Length = lngLength
    
    If (IsMissing(varDefaultValue)) Then varDefaultValue = Empty
    
    Me.DefaultValue = IIf(Len(Trim(varDefaultValue)) = 0, Empty, varDefaultValue)
      
    SetPropertyType strPType, strEnumSpace, strEnumTypeName
    
    'If ((Me.Length = 0) And PropertyType = MSIXDEF_TYPE_STRING) Then ' Log a warning is the size of a string is not set, and set a size of MSIX_MAX_STRING_LENGTH!
    '
    '    strError = Replace(MTMSIX_ERROR_01046, "[NAME]", strName)
    '    strError = Replace(strError, "[FILE]", Me.Parent.Name)
    '    TRACE strError, "MSIXProperty.cls", "Initialize", LOG_DEBUG
    '
    '    Me.Length = MSIX_MAX_STRING_LENGTH
    '    Exit Function
    'End If
    
    ' MDM 3.0 - For property added on the fly store a default non localization mark - so we do not call then Back
    ' end localization api which will failed
    If Not CBool(Me.Flags And eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF) Then
        Me.Caption = "{NL}" & Me.Name
    End If
    
    If (Me.Parent.Flags And eMSIX_PROPERTIES_FLAG_SERVICE) Then ' If we dealing with a service we set the default value
        Initialize = ReSetDefault()
    Else
        Initialize = True
    End If
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "Initialize", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Delete
' PARAMETERS    :
' DESCRIPTION   : Internal Delete function called by the parent object when the parent is about to be deleted.
'                 The purpose of this function is to free the parent ref from the child so the parent can be deleted.
'                 This deals with the COM problem of circular reference.
'                 This function cannot be called from the out side (Friend)!
' RETURN        :
Friend Function Delete() As Boolean

On Error GoTo ErrMgr

    If Not (EnumType Is Nothing) Then
    
        EnumType.Delete
        Set EnumType = Nothing
    End If
    Set Parent = Nothing ' Free the parent
    Delete = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "Delete", LOG_ERROR
End Function


' -------------------------------------------------------------------------------
' FUNCTION      : Caption
' PARAMETERS    :
' DESCRIPTION   : Gets the localization string of the service/product view property.
'                 If the localization is not found the property returns the name of the property with the
'                 prefix {NL} (NL stands for Non-Localized).
'
'                 You can set the caption programmaticaly for the life of the object.
'
'                 If the language of the <code>Parent</code> is "CN" (Chinese), the property returns
'                 the string in a<i>big5</i> format (HTML Standard to support ASIAN language).
' RETURN        :
Public Property Get Caption() As Variant

    On Error GoTo ErrMgr
    
    Dim strName         As String
    Dim varValue        As Variant
    Dim strCacheName    As String
    
    If (Me.Flags And eMSIX_PROPERTY_FLAG_DO_NOT_STORE_CAPTION_IN_CACHE) Then
        varValue = m_varCaption
        GoTo CheckForAsianLanguage
    End If
    
    If (Not Me.Parent.Localized) Then
  
        strCacheName = "PROPERTY.CAPTION:" & Me.Parent.Language & "/" & Me.Parent.Name & "/" & Me.Name
        If (Parent.Tools.Cache.Exist(strCacheName)) Then
  
            Caption = Parent.Tools.Cache(strCacheName).Data
        Else
            Caption = "{NL}" & Me.Name
        End If
        Exit Property
    End If
   
    If (UCase$(Me.Name) = "MDMINTERVALID") Then ' This case should not happend any way.
        varValue = "MDM Interval ID"
        GoTo CheckForAsianLanguage
    End If
   
    ' Read it from the cache
    strCacheName = "PROPERTY.CAPTION:" & Me.Parent.Language & "/" & Me.Parent.Name & "/" & Me.Name
    If (Parent.Tools.Cache.Exist(strCacheName)) Then
   
        Caption = Parent.Tools.Cache(strCacheName).Data
        Exit Property ' Here we exit becaus, the property has been read from the cache and therefore is already converted to asian language
    End If
    
    ' Read the localized property in the metratech.com name space. This is only for product view.
    If (Me.Flags And eMSIX_PROPERTY_FLAG_ACCOUNT_USAGE_TABLE) Or (IsReserved()) Then
        
        If (IsReserved()) Then ' If the property start with '_' we remove it, I guess because the localization is defined without.
            strName = Mid$(Me.Name, 2)
        Else
            strName = Me.Name
        End If
        Parent.Tools.GetLocalizedString Me.Parent.Language, MTMSIX_METRATECH_DOT_COM_NAME_SPACE & "/" & strName, varValue
    Else
    
        ' Read the localized property in the product view name space
        Parent.Tools.GetLocalizedString Me.Parent.Language, Me.Parent.Name & "/" & Me.Name, varValue
    End If
    
CheckForAsianLanguage:
    
    If (Len(varValue) = 0) Then ' If did not find the localized string we say it...
    
        varValue = "{NL}" & Me.Name
    End If
    '
    ' ASIAN LANGUAGE CONVERTION
    '
    If (IsAsianLanguage(Me.Parent.Language)) Then

        If (Me.Parent.LocalizationFlags And eMSIX_PROPERTIES_LOCALIZATION_FLAG_RETURN_BIG5) Then

            varValue = Me.Parent.Tools.StringConvertUniCode2Big5(varValue)
        End If
    End If
    
    Parent.Tools.Cache.Add strCacheName, varValue   ' Add the entry in the cache
    
TheExit:
    
    Caption = varValue                              ' Return the value
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "Caption", LOG_ERROR
End Property


Public Function AddValidListOfValueFromDictionaryCollection(ByVal objDictionary As Dictionary, ByVal strCollectionName As String) As Boolean
    
    Dim objCol      As Dictionary
    Dim objEntry    As DictionaryEntry
    Dim i           As Long
    Dim obVars      As New CVariables
    
    Set objCol = objDictionary.GetCollection(strCollectionName)
    
    
    For Each objEntry In objCol
        i = i + 1
        obVars.Add i, i, , , objEntry.Value
    Next
    AddValidListOfValueFromDictionaryCollection = AddValidListOfValues(obVars)
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "AddValidListOfValueFromDictionaryCollection", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : AddValidListOfValues
' PARAMETERS    :
' DESCRIPTION   : Allow the MSIX property to programatically change to an enum type by specifing the enum type value.
'                 This type of msix property/enum type are called dynamic enum type.
'
'                 This function accepts 4 types of data sources :
'
'                   <b>1 Array</b> - varDataSource is an array of variant,  The array value are used as enum type item name/localization and values.
'                   <b>2 Arrays</b> - varDataSource and varArrayNames are an arrays of variants,  varDataSource contains the enum type item value and varArrayName contains the enum type name/localization.
'                   <b>3 SQL Query</b> - varDataSource is a string containing an MT SQL Query TAG. The query is executed, and the enum type is populated with the rowset. The first column must be the enum type value, the second column must be the enum type name/localization.
'                     The query must be stored in the strQueryTagRelativePathFromConfig in the XML MTSQLServer.xml File.
'                   <b>4 CVariables CON object</b> - varDataSource is a CVariables collection, the variable name is the enum type name/localization, the variable value is the the enum type value.
'
' RETURN        : TRUE if Ok.
Public Function AddValidListOfValues(varDataSource As Variant, Optional varArrayNames As Variant, Optional ByVal strRowsetColNameForId As String, Optional ByVal strRowsetColNameForLabel As String, Optional ByVal strQueryTagRelativePathFromConfig As String) As Boolean

        Dim i               As Long
        Dim objMTSQLRowset  As Object
        Dim strError        As String
        Dim objVar          As CVariable
        
        On Error GoTo ErrMgr
        
        AddValidListOfValues = True
        
        ' Only new the EnumType if it is nothing
        If EnumType Is Nothing Then
          Set EnumType = New MSIXEnumType
          Set EnumType.Parent = Me
          EnumType.Initialize
        End If
        
        Set EnumType.Entries = New MSIXEnumTypeEntries
        
        If (UCase$(TypeName(varDataSource)) = "CVARIABLES") Then ' CVariables
        
            For Each objVar In varDataSource
        
                EnumType.Entries.Add objVar.Name, objVar.Value, objVar.Caption
            Next
        
        ElseIf (IsArray(varDataSource)) Then ' Array
        
            For i = 0 To UBound(varDataSource)
            
                If (IsMissing(varArrayNames)) Then
                
                    EnumType.Entries.Add CStr(varDataSource(i)), varDataSource(i), varDataSource(i)
                Else
                
                    EnumType.Entries.Add CStr(varArrayNames(i)), varDataSource(i), CStr(varArrayNames(i))
                End If
            Next
            
        ElseIf VarType(varDataSource) = vbString Then '  SQL Query statment

            Set objMTSQLRowset = New MTSQLRowset
            
            ' Log a warning all the time
            strError = Replace(MTMSIX_ERROR_01065, "[QUERY]", CStr(varDataSource))
            strError = Replace(strError, "[PATH]", strQueryTagRelativePathFromConfig)
            TRACE strError, "MSIXProperty.cls", "AddValidListOfValues", LOG_DEBUG

            If (Me.Parent.Tools.ExecSQL(strQueryTagRelativePathFromConfig, CStr(varDataSource), objMTSQLRowset)) Then
            
                Do While Not objMTSQLRowset.EOF
                            
                    ' The first column must be the id the column 2 the label
                    
                    If (objMTSQLRowset.Count = 1) Then ' Label and index are the same
                        EnumType.Entries.Add CStr(objMTSQLRowset.Value(CLng(0))), CStr(objMTSQLRowset.Value(CLng(0))), CStr(objMTSQLRowset.Value(CLng(0)))
                    Else
                        EnumType.Entries.Add CStr(objMTSQLRowset.Value(CLng(1))), CStr(objMTSQLRowset.Value(CLng(0))), CStr(objMTSQLRowset.Value(CLng(1)))
                    End If
                    objMTSQLRowset.MoveNext
                Loop
            End If
                        
        ElseIf (IsValidObject(varDataSource)) Then ' Officially this mode is not documented...
            
            Set objMTSQLRowset = varDataSource ' use a better name to make a better code
            
            Do While Not objMTSQLRowset.EOF
            
                EnumType.Entries.Add "" & objMTSQLRowset.Value(CStr(strRowsetColNameForLabel)), "" & objMTSQLRowset.Value(CStr(strRowsetColNameForId)), "" & objMTSQLRowset.Value(CStr(strRowsetColNameForLabel))
                objMTSQLRowset.MoveNext
            Loop
        Else
        
            strError = MTMSIX_ERROR_01032
            strError = Replace(strError, "[PARAMETER]", "varDataSource")
            strError = Replace(strError, "[VALUE]", TypeName(varDataSource))
            TRACE strError, "MSIXProperty", "AddValidListOfValues", LOG_ERROR
            AddValidListOfValues = False
        End If
        Exit Function
ErrMgr:
    AddValidListOfValues = False
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "AddValidListOfValues", LOG_ERROR
End Function


' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Value
' PARAMETERS    :
'                   booRaiseError - Parameter used only for <code>Value</code> Set mode. If true the property Value will raise an error in case of type mismatch
'                                   or string length overflow.
'                   booLocalizeValueIfParentAskForIt - If the Parent.RenderFlag contains the flag eMSIX_RENDER_FLAG_LOCALIZE_ENUM_TYPE, this property
'                                   will return the localized value. You can force to return the non localized value by setting this parameter to FALSE.
'
' DESCRIPTION   : Gets or Sets the value of the property. The value is returned into a VARIANT containing the right COM Type : string, long, double, decimal...
'
'                 <b>Enum Type</b> - If the property is an enum type, the value is the enum type value.
'                 If the flag eMSIX_RENDER_FLAG_LOCALIZE_ENUM_TYPE is set into <code>Parent.RenderFlag</code>, the value returned is the localized value.
'                 In a MDM Product View Browser Dialog if you set the <code>ProductView.RenderLocalizationMode</code> to TRUE the flag eMSIX_RENDER_FLAG_LOCALIZE_ENUM_TYPE
'                 is set. (See parameter <i>booLocalizeValueIfParentAskForIt</i> to cancel this behavior).
'
'                 If the value is Empty due to a non-initialization and if the enum type is loaded the returned value is the first enum type value, therefore,
'                 the returned value is valid value according the type.
'
'                 <b>Date</b> - If the property is a date and the property <code>Parent.TimeZoneId</code> is set, the value returned is a localized date.
'
'                 <b>UserInvisible</b> : If the property is set to TRUE, the value returned is the string |Not Visible|. At this time the Back End COM API does not allow
'                 to retreive from a product view the MSIX properties value which have the attribute UserVisible=FALSE.
'
'                 VT_EMPTY, VT_NULL : The property <code>Value</code> support this valuee; Note that NULL and EMPTY values will not be sent to the pipeline.
'
'                 When the value is set type and length checking are applied. If the checking fails an error is raised.
'                 One cannot set the value of a MSIX product view property.
'
' RETURN        :
Public Property Get Value(Optional ByVal booRaiseError As Boolean = True, Optional booLocalizeValueIfParentAskForIt As Boolean = True) As Variant
Attribute Value.VB_UserMemId = 0

    Dim objProperty As MSIXProperty
    Dim objEnumType As MSIXEnumType
    Dim lngIndex    As Long
    Dim objBit      As New CBit
    
    On Error GoTo ErrMgr

    If (Me.Parent.IsProductView()) Then     ' In the case of a product view
    
        If (Me.UserVisible) Then
        
            If (Me.Parent.Rowset.EOF) And (Not CBool(Me.Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)) Then
            
                Value = "EOF()"             ' In that case what can i do...
            Else
                ' Problem 1 - 9/17/2000 For the ProductView Browser, I need to stick in the product view the property
                ' mdmIntervalId, so the renderer can render the interval id combo box. In that case I need to get and set
                ' this property value, but in a product view you are not allowed to set a property value.
                ' So I defined 3 kind of property : 1-Service Property (Get/Set), 2-Product View Property (Get), 3-Product view property added on the fly with the flag eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET (Get/Set)
                ' in that case I allow to Set the property value. This 3 kind of property behave like a service property.
                ' If a property/column from a productview rowset is not found, I return the value
                ' stored for a service, if it exist else log an error
                
                lngIndex = Me.Parent.GetRowsetColumnIndex(Me.Name) ' Search the index of the property - Use an internal cache system to speed up the process...
                
                If (lngIndex <> -1) Then ' The property is found in the rowset - No Problemo
                
                    ' PROBLEM 2 - 09/23/2000 - When the rowset is a MTSQLRowsetSimulator/MTSQLRowset and when the column is an enum type
                    ' the rowset contains the enum type id, if the Parent.RenderFlag contains LOCALIZE ENUM TYPE, I need to return
                    ' the localized value (I also do this for service below). So I need to do some thing about it...
                    
                    If (Me.IsEnumType()) Then
                    
                        If (Me.Parent.RenderFlags And eMSIX_RENDER_FLAG_LOCALIZE_ENUM_TYPE) And (booLocalizeValueIfParentAskForIt) Then
                                            
                        ' If the rowset is an COMDBOBJECTSLib.COMProductView, the it is already localized by the Back End but
                        ' in case of MTSQLROWSET and MTSQLROWSETSIMULATOR, I need to do it myself.
                        If (UCase$(TypeName(Me.Parent.Rowset)) = "MTSQLROWSETSIMULATOR") Or (UCase$(TypeName(Me.Parent.Rowset)) = "MTSQLROWSET") Or (UCase$(TypeName(Me.Parent.Rowset)) = "IMTSQLROWSET") Then
                            
                                Value = EnumType.LocalizedValue(Me.Parent.Rowset.Value(CLng(lngIndex))) ' Return the localize value of the enum type.
                                Exit Property
                            End If
                        End If
                    End If
                    ' Set the regular value
                    Value = TimeZoneTheValue(Me.Parent.Rowset.Value(CLng(lngIndex))) ' Adjust date for the time zone if defined
                    
                Else
                    ' Here Since the property is not in the rowset I test its flag, if yes I temporary convert the
                    ' Parent MSIXProperties which was set as a product view into service and call Value() recursively
                    ' When done I restore the context. This seems complex but the idea behind it to avoid :
                    '   1-OR duplicate the code which is below and deals with service value
                    '   2-OR put the code in another function
                    If (Me.Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET) Then
                    
                        Parent.Flags = objBit.ResetBit(Parent.Flags, eMSIX_PROPERTIES_FLAG_PRODUCTVIEW)
                        Parent.Flags = objBit.SetBit(Parent.Flags, eMSIX_PROPERTIES_FLAG_SERVICE)
                        
                        Value = Value(booRaiseError, booLocalizeValueIfParentAskForIt)
                        
                        Parent.Flags = objBit.ResetBit(Parent.Flags, eMSIX_PROPERTIES_FLAG_SERVICE)
                        Parent.Flags = objBit.SetBit(Parent.Flags, eMSIX_PROPERTIES_FLAG_PRODUCTVIEW)
                    Else
                        ' The property was not found - error
                        TRACE Replace(MTMSIX_ERROR_01047, "[PROPERTY]", Me.Name), "MSIXProperty.cls", "Value Get", LOG_WARNING
                    End If
                End If
            End If
        Else
            Value = "|Not Visible|"
        End If
        
    Else        ' In the case of a service
    
        If (Me.IsEnumType()) Then
            
            If (IsEmpty(m_varValue)) Then   ' If a property is an enum type and not initialized, and if the enum type is loaded and
                                            ' we have at least one item, we set and return the first item rather than empty!
                                            
                If (Me.EnumType.Entries.Count) And (Not EnumTypeSupportEmpty) Then ' It is possible to turn off the function by setting to EnumTypeSupportEmpty to TRUE;
                
                    m_varValue = Me.EnumType.Entries.Item(1).Value
                    TRACE PreProcess(MTMSIX_ERROR_01098, "SERVICE", Me.Parent.Name, "PROPERTY", Me.Name, "VALUE", m_varValue), , , LOG_DEBUG
                End If
            End If
        
            If (Parent.RenderFlags And eMSIX_RENDER_FLAG_LOCALIZE_ENUM_TYPE) And (booLocalizeValueIfParentAskForIt) Then
                
                Value = EnumType.LocalizedValue(m_varValue) ' Return the localize value of the enum type
                Exit Property
            End If
        End If
        Value = TimeZoneTheValue(m_varValue) ' Return the value, if the property is an enum type
                                             ' return the id, if it is a date localize it, it asked!
    End If
    Exit Property
ErrMgr:

    Value = MTMSIX_ERROR_01033 & " " & GetVBErrorString()
    TRACE MTMSIX_ERROR_01033 & " " & GetVBErrorString(), "MSIXProperty.cls", "Value Get", LOG_ERROR
    If (Err.Number = 3265) Then Value = Null
    Value = Null
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Value()
' PARAMETERS    :
' DESCRIPTION   : See the property Get.
' RETURN        :
Public Property Let Value(Optional ByVal booRaiseError As Boolean = True, Optional booLocalizeValueIfParentAskForIt As Boolean = True, ByVal vNewValue As Variant)

    On Error GoTo ErrMgr
    
    Dim lngPropertyIndex    As Long
    Dim objBit              As New CBit
       
    If (Me.Parent.IsProductView()) Then
    
        ' Read the comment in Value() Get to understand this piece of code.
        If (Me.Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET) Then ' Extra Property for Product View
        
            Parent.Flags = objBit.ResetBit(Parent.Flags, eMSIX_PROPERTIES_FLAG_PRODUCTVIEW)
            Parent.Flags = objBit.SetBit(Parent.Flags, eMSIX_PROPERTIES_FLAG_SERVICE)
            Value = vNewValue
            Parent.Flags = objBit.ResetBit(Parent.Flags, eMSIX_PROPERTIES_FLAG_SERVICE)
            Parent.Flags = objBit.SetBit(Parent.Flags, eMSIX_PROPERTIES_FLAG_PRODUCTVIEW)
        Else
        
            RaiseError PreProcess(MTMSIX_ERROR_01028, "PROPERTY", Me.Caption, "VALUE", vNewValue), , , LOG_APPLICATION_ERROR '  Cannot set values in a product view
        End If
        GoTo TheExit
    End If
    
    If (IsEmpty(vNewValue)) Or (IsNull(vNewValue)) Then ' we accept to set the value empty and null
    
        GoTo SetVarVarlue ' Skip the type checking...
    End If
        
    If (Len(CStr(vNewValue)) = 0) Then  ' If the value set is an empty string, and the property is a numeric, we
                                        ' want to avoid the type checking that will fail...
    
        If (InArray(Me.PropertyType, Array(MSIXDEF_TYPE_DOUBLE, MSIXDEF_TYPE_FLOAT, MSIXDEF_TYPE_INT32, MSIXDEF_TYPE_DECIMAL))) Then
                
            GoTo SetVarVarlue ' we set the numeric with an empty string , which is weird but we do not have a better solution for now! Fred and kevin.
        End If
    End If
        
    Select Case UCase$(Me.PropertyType) ' Apply type checking
    
        Case MSIXDEF_TYPE_ENUM
                vNewValue = CStr(vNewValue) ' Convert the value into a string, to avoid decimal/enum type problem with Oracle...
                
                'Don't meter empty enums if supporting empty enums
                If (EnumTypeSupportEmpty) Then
                    If (Len(vNewValue) = 0) Then
                        If (Me.Flags And eMSIX_PROPERTY_FLAG_METERED) Then
                            Me.Flags = objBit.ResetBit(Me.Flags, eMSIX_PROPERTY_FLAG_METERED)
                        End If
                    Else
                        Me.Flags = objBit.SetBit(Me.Flags, eMSIX_PROPERTY_FLAG_METERED)
                    End If
                End If
        Case MSIXDEF_TYPE_STRING
            
            If (Me.Length <> 0) Then ' don't check the length if it is set to 0
              If (Me.Length) Then
                  If (Len(vNewValue) > Me.Length) And (booRaiseError) Then RaiseError PreProcess(MTMSIX_ERROR_01000, "PROPERTY", Me.Caption, "VALUE", vNewValue), , , LOG_APPLICATION_ERROR
              End If
            End If
            
        Case MSIXDEF_TYPE_DOUBLE
            If (Not IsNumeric(vNewValue)) And (booRaiseError) Then
                RaiseError PreProcess(MTMSIX_ERROR_01003, "PROPERTY", Me.Caption, "VALUE", vNewValue), , , LOG_APPLICATION_ERROR
            End If
            vNewValue = CDbl(vNewValue) ' be sure to convert the value into the right type to avoid problem when metering is the value was set as a DECIMAL
            ' Test if the value fit in our database type
            'If (Not Me.Parent.Tools.CheckAmountStoredAsNumeric22_10(CDbl(vNewValue))) Then RaiseError Replace(MTMSIX_ERROR_01006, "[PROPERTY]", Me.Caption)

        Case MSIXDEF_TYPE_FLOAT
            If (Not IsNumeric(vNewValue)) And (booRaiseError) Then RaiseError PreProcess(MTMSIX_ERROR_01002, "PROPERTY", Me.Caption, "VALUE", vNewValue), , , LOG_APPLICATION_ERROR
            vNewValue = CSng(vNewValue) ' be sure to convert the value into the right type to avoid problem when metering is the value was set as a DECIMAL
            ' Test if the value fit in our database type
            'If (Not Me.Parent.Tools.CheckAmountStoredAsNumeric22_10(CDbl(vNewValue))) Then RaiseError Replace(MTMSIX_ERROR_01006, "[PROPERTY]", Me.Caption)

        Case MSIXDEF_TYPE_INT32
            If (Not IsNumeric(vNewValue)) And (booRaiseError) Then RaiseError PreProcess(MTMSIX_ERROR_01001, "PROPERTY", Me.Caption, "VALUE", vNewValue), , , LOG_APPLICATION_ERROR
            vNewValue = CLng(vNewValue) ' be sure to convert the value into the right type to avoid problem when metering is the value was set as a DECIMAL
            
        Case MSIXDEF_TYPE_DECIMAL
            If (Not IsNumeric(vNewValue)) And (booRaiseError) Then RaiseError PreProcess(MTMSIX_ERROR_01058, "PROPERTY", Me.Caption, "VALUE", vNewValue), , , LOG_APPLICATION_ERROR
            ' Test if the value fit in our database type
            
            If (Not Me.Parent.Tools.IsValidDecimal(vNewValue)) Then RaiseError PreProcess(MTMSIX_ERROR_01006, "PROPERTY", Me.Caption, "VALUE", vNewValue), , , LOG_APPLICATION_ERROR
            
            vNewValue = CDec(vNewValue) ' be sure we have a DECIMAL, and not a double or a single, so the pipeline will be happy

        Case MSIXDEF_TYPE_BOOLEAN
            If Me.EnumTypeSupportEmpty And Len("" & vNewValue) = 0 Then ' When we set "" to a boolean we convert it to FALSE else if Me.EnumTypeSupportEmpty
                vNewValue = Empty
            Else
                vNewValue = Me.Parent.Tools.BooleanValue(vNewValue) ' Convert, TRUE, FALSE, T, F, Y, N into a boolean
            End If
            
        Case MSIXDEF_TYPE_TIMESTAMP

            vNewValue = Me.Parent.Tools.UMTDateToCDate(vNewValue) ' Back in 3.5 - removed in 3.0
            'vNewValue = CDate(vNewValue) ' removed in 3.5
            
            If (CLng(CDate(vNewValue)) = 0) Then ' this is a null data 12:0:0 am - ' Support the case when a date is null - CDATE(aDate)=0, Internal we use an Empty
                vNewValue = Empty
            End If

    End Select
    
SetVarVarlue:

    m_varValue = vNewValue
    
TheExit:
    Exit Property
    
ErrMgr:

  ' THIS PROPERTY MUST ABSOLUTELY RAISE ANY ERRORS... THAT IS THE WAY WE TELL THE CLIENT ABOUT A TYPE MISMATCH
  Err.Raise Err.Number, Err.Source, Err.Description
  
End Property



' -------------------------------------------------------------------------------
' FUNCTION      : BooleanValue
' PARAMETERS    :
' DESCRIPTION   : Converts and returns the MSIX property value into a TRUE/FALSE value. FALSE value are : FALSE, F, N, "", 0 and
'                 the remaining are TRUE.
'                 This property is usefulle to support MSIX service written before the MSIX type boolean was supported (MPM v1.2).
' RETURN        :
Public Property Get BooleanValue(Optional ByVal booRaiseError As Boolean = True) As Boolean

    On Error GoTo ErrMgr

    Dim strV As String
    
    strV = CStr(Me.Value(booRaiseError))
    
    BooleanValue = Me.Parent.Tools.BooleanValue(strV)
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "BooleanValue", LOG_ERROR
End Property



' -------------------------------------------------------------------------------
' FUNCTION      : LocalizedValue
' PARAMETERS    :
' DESCRIPTION   : Gets the localized value of the property.
' RETURN        :
Public Property Get LocalizedValue(Optional ByVal booRaiseError As Boolean = True) As Variant

    On Error GoTo ErrMgr

    Dim lngFlag As Long
            
    lngFlag = Parent.RenderFlags ' Save the flags
    
    Parent.RenderFlags = eMSIX_RENDER_FLAG_LOCALIZE_ENUM_TYPE ' Set the parent flag so the property value return a localized enum type
    
    LocalizedValue = Value(booRaiseError) ' Call
    
    Parent.RenderFlags = lngFlag ' Reset theb context

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "LocalizedValue", LOG_ERROR
End Property


' -------------------------------------------------------------------------------
' FUNCTION      : IsReserved
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE if the MSIX property is a MSIX reserved property. MSIX reserved property start with a '_', like _Amount for instance.
' RETURN        :
Public Function IsReserved() As Boolean

    On Error GoTo ErrMgr

    If (Len(Name)) Then
        IsReserved = Mid$(Name, 1, 1) = "_"
    End If
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "IsReserved", LOG_ERROR
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : SetDefault
' PARAMETERS    :
' DESCRIPTION   : Sets the MSIX property value to its MSIX default value.
' RETURN        : TRUE if Ok.
Public Function ReSetDefault() As Boolean

    On Error GoTo ErrMgr

    Value = DefaultValue
    ReSetDefault = True
    Exit Function
ErrMgr:
  ReSetDefault = False
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "ReSetDefault", LOG_ERROR
End Function


' -------------------------------------------------------------------------------
' FUNCTION      : Sorted
' PARAMETERS    :
' DESCRIPTION   : Related to the MDM. Gets or sets the MSIX sorted property. The values are:
'                       0               - means not sorted
'                       SORT_ASCENDING  - 1
'                       SORT_DESCENDING - 2
'
'                 Only one property at a time is selected for the sort. When one sets a property as sorted,
'                 the previous one is cleared.
' RETURN        : Returns a MTSortOrder value. MTSortOrder enum type belong to the Back End COM API.
Public Property Get Sorted() As MTSortOrder

    On Error GoTo ErrMgr

    Sorted = m_Sorted
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "Sorted", LOG_ERROR
End Property

' -------------------------------------------------------------------------------
' FUNCTION      : Sorted
' PARAMETERS    :
' DESCRIPTION   : See Sorted Get.
' RETURN        :
Public Property Let Sorted(ByVal vNewValue As MTSortOrder)

    On Error GoTo ErrMgr

    Dim objProperty As MSIXProperty
    
    For Each objProperty In Me.Parent
            
        If Not (objProperty Is Me) Then objProperty.InternalSetSorted 0
    Next
    m_Sorted = vNewValue

    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "Sorted", LOG_ERROR
End Property

' -------------------------------------------------------------------------------
' FUNCTION      : ReverseSort
' PARAMETERS    :
' DESCRIPTION   : Related to the MDM. Reverses the order of the sort. If the property is not sorted the function is ignored.
' RETURN        :
Public Function ReverseSort() As Boolean

    On Error GoTo ErrMgr

    If (Me.Sorted = SORT_ASCENDING) Then ' Do not use a IFF because of the case 0 not selected
    
        Me.Sorted = SORT_DESCENDING
        
    ElseIf (Me.Sorted = SORT_DESCENDING) Then
    
        Me.Sorted = SORT_ASCENDING
    End If
    ReverseSort = True
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "ReverseSort", LOG_ERROR
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : TimeZoneTheValue
' PARAMETERS    :
' DESCRIPTION   : If the property type is a timestamp and if the Parent.TimeZoneId is set, then
'                 return the date value according the TimeZoneId.
' RETURN        :
Friend Function TimeZoneTheValue(varValue As Variant) As Variant

    
    On Error GoTo ErrMgr
    
    If (Me.PropertyType = MSIXDEF_TYPE_TIMESTAMP) And (Not IsEmpty(Me.Parent.TimeZoneId)) Then ' in the case of a date and we have a time zone id
    
        Me.Parent.Tools.LocaleTranslatorObject.Init Me.Parent.Language
        TimeZoneTheValue = CDate(Me.Parent.Tools.LocaleTranslatorObject.GetDateTime(CDate(varValue), CLng(Me.Parent.TimeZoneId), Me.Parent.DayLightSaving))
    Else
        TimeZoneTheValue = varValue
    End If
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "ReverseSort", LOG_ERROR
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : Parent
' PARAMETERS    :
' DESCRIPTION   : Gets a reference of the <code>Parent</code> object,  an MSIXProperties instance.
' RETURN        :
Public Property Get Parent() As MSIXProperties

    On Error GoTo ErrMgr

    If (Not IsValidObject(m_Parent)) Then
    
        RaiseError Replace(MTMSIX_ERROR_01055, "[NAME]", Me.Name), , , LOG_APPLICATION_ERROR
    End If
    Set Parent = m_Parent

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Parent", "MSIXProperty.cls", LOG_ERROR
End Property

' -------------------------------------------------------------------------------
' FUNCTION      : Parent
' PARAMETERS    :
' DESCRIPTION   : See property Gets. This property is Friendly...
' RETURN        :
Friend Property Set Parent(ByVal vNewValue As MSIXProperties)

    On Error GoTo ErrMgr

    Set m_Parent = vNewValue

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Parent", "MSIXProperty.cls", LOG_ERROR
End Property



' -------------------------------------------------------------------------------
' FUNCTION      : InternalSetSorted
' PARAMETERS    :
' DESCRIPTION   : Internal usage to set the sort property without using the property Sorted
' RETURN        :
Friend Function InternalSetSorted(eSortedValue As MTSortOrder) As Boolean
    On Error GoTo ErrMgr

    m_Sorted = eSortedValue

    Exit Function
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Parent", "MSIXProperty.cls", LOG_ERROR
End Function



' -------------------------------------------------------------------------------
' FUNCTION      : Caption
' PARAMETERS    : See Property Caption Get
' RETURN        :
Public Property Let Caption(vValue As Variant)

    On Error GoTo ErrMgr
    
    Dim strCacheName    As String
    
    If (Me.Flags And eMSIX_PROPERTY_FLAG_DO_NOT_STORE_CAPTION_IN_CACHE) Then
        m_varCaption = vValue
    Else
        
        ' Read it from the cache
        strCacheName = "PROPERTY.CAPTION:" & Me.Parent.Language & "/" & Me.Parent.Name & "/" & Me.Name
        Parent.Tools.Cache.Add strCacheName, vValue   ' Add the entry in the cache
    End If
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "Caption Let", LOG_ERROR
End Property


' -------------------------------------------------------------------------------
' FUNCTION      : Operation
' DESCRIPTION   : Allows you to apply mathematical and compare operations of decimal MSIX property. This function is
'                 only usefull for VBScript client because <i>VBScript does not support decimal operations</i>.
'                 Visual Basic supports decimal operations.
'                 The supported operations are : */+-\,mod,abs,int,=,>,>=,<,<=,<>,round. For the differents operation supported
'                 see the Visual Basic documentation. The round operation need a parameter NumDecimalPlaces.
'                 NumDecimalPlaces indicates how many places to the right of the decimal are included in the rounding. If omitted, integers are returned by the Round function.
'                 Use the parameter decValue to set NumDecimalPlaces.
' PARAMETERS    :
' RETURN        : The result of the operation. In the case of a compare, returns TRUE or FALSE.
Public Function Operation(ByVal strOp As String, Optional ByVal decValue As Variant) As Variant
    
    Dim objDecimal As New CDecimal
    Dim varTmp     As Variant
    
    objDecimal.Value = Value
    
    varTmp = objDecimal.Operation(strOp, decValue)
    
    ' Test if the function return a decimal or a boolean. If the function returns boolean this
    ' mean this operator is a comparator like =,<,>...We do not want to store the result in the
    ' property itself. Plus if the Parent object is a ProductView we cannot update the value
    ' in that case this mean that we just want to apply an math ops based on the property
    ' but we do not want to update the property
    
    If (VarType(varTmp) = vbDecimal) Then
    
        If (Not Me.Parent.IsProductView()) Then ' ProductView rowset cannot be updated..
        
            Value = varTmp
        End If
    End If
    Operation = varTmp
    
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : SQLColumnName
' DESCRIPTION   : For a ProductView only returns the SQL Name of the property
' PARAMETERS    : NOT USED YET
' RETURN        :
Public Property Get SQLColumnName() As String ' DOCUMENTED=NO

    If (Not IsEmpty(m_strSQLColumnName)) Then
    
        SQLColumnName = m_strSQLColumnName
    Else
        If (Flags And eMSIX_PROPERTY_FLAG_ACCOUNT_USAGE_TABLE) Then
            SQLColumnName = Me.Name
        Else
            SQLColumnName = DB_SQL_COLUMN_PREFIX & Me.Name
        End If
    End If
End Property

' -------------------------------------------------------------------------------
' FUNCTION      : SQLColumnName
' DESCRIPTION   : See get property.
' PARAMETERS    :
' RETURN        :
Public Property Let SQLColumnName(ByVal vNewValue As String) ' DOCUMENTED=NO

    m_strSQLColumnName = vNewValue
End Property



' -------------------------------------------------------------------------------
' FUNCTION      : LocalizedValue
' PARAMETERS    :
' DESCRIPTION   : Gets the non localized value of the property. MSIX enum type property have a value and a localization.
'                 the property return the value in any case. See property Value().
' RETURN        :
Public Property Get NonLocalizedValue() As Variant

    On Error GoTo ErrMgr

    NonLocalizedValue = Value(, False)
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "NonLocalizedValue", LOG_ERROR
End Property

' -------------------------------------------------------------------------------
' FUNCTION      : IsValueDecimal
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE if the non localized value is a COM Decimal type. In the MetraTech Plateform
'                 used with Oracle, long database type does not exist and are replaced with numeric(x).
' RETURN        :
Public Function IsValueDecimal() As Boolean
    IsValueDecimal = VarType(Me.NonLocalizedValue()) = vbDecimal
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : StringID
' PARAMETERS    :
' DESCRIPTION   : Get Or set if the property is a string id. A string id is a string that
'                 accept only the following char _ ABCDEFGHIJKLMNOPQRSTVWUXYZabcdefghijklmnopqrstvwuxyz
' RETURN        :
Public Property Get StringID() As Boolean

    StringID = CBool(Me.Flags And eMSIX_PROPERTY_FLAG_STRING_ID)
End Property

Public Property Let StringID(ByVal vNewValue As Boolean)
    Dim objBit As New CBit
    If (vNewValue) Then
        Me.Flags = objBit.SetBit(Flags, eMSIX_PROPERTY_FLAG_STRING_ID)
    Else
        Me.Flags = objBit.ResetBit(Flags, eMSIX_PROPERTY_FLAG_STRING_ID)
    End If
End Property

Public Property Get Enabled() As Boolean
    Enabled = m_booEnabled
End Property

Public Property Let Enabled(ByVal vNewValue As Boolean)
    m_booEnabled = vNewValue
End Property

Public Function IsValueEqualToDefaultValue() As Boolean

    On Error GoTo ErrMgr
    
    ' The order of this 4 rules is important
    If IsNull(Value) And IsNull(DefaultValue) Then IsValueEqualToDefaultValue = True: Exit Function         '1
    If IsEmpty(Value) And IsEmpty(DefaultValue) Then IsValueEqualToDefaultValue = True: Exit Function       '2
    
    If IsNull(Value) Or IsNull(DefaultValue) Then IsValueEqualToDefaultValue = False: Exit Function         '3
    If IsEmpty(Value) Or IsEmpty(DefaultValue) Then IsValueEqualToDefaultValue = False: Exit Function       '4
    
    Select Case UCase$(Me.PropertyType) ' Apply type checking
        
        Case MSIXDEF_TYPE_DOUBLE, MSIXDEF_TYPE_FLOAT
            IsValueEqualToDefaultValue = CDbl(Value) = CDbl(DefaultValue)
            
        Case MSIXDEF_TYPE_DECIMAL
            IsValueEqualToDefaultValue = CDec(Value) = CDec(DefaultValue)
            
        Case MSIXDEF_TYPE_INT32
            IsValueEqualToDefaultValue = CLng(Value) = CLng(DefaultValue)
            
        Case MSIXDEF_TYPE_BOOLEAN
            IsValueEqualToDefaultValue = Parent.Tools.BooleanValue(Value) = Parent.Tools.BooleanValue(DefaultValue)
            
        Case MSIXDEF_TYPE_TIMESTAMP
            IsValueEqualToDefaultValue = CDate(Value) = CDate(DefaultValue)
            
        Case Else 'Case MSIXDEF_TYPE_ENUM, MSIXDEF_TYPE_STRING,
            IsValueEqualToDefaultValue = CStr(Value) = CStr(DefaultValue)
    End Select
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "IsValueEqualToDefaultValue", LOG_ERROR
End Function

'Public Property Get SerializedValue(Optional ByVal strSeparator As String = "|") As String
'
'On Error GoTo ErrMgr
'    ' all lower case
'    SerializedValue = "name" & strSeparator & Me.Name & strSeparator & "value" & strSeparator & Me.Value & strSeparator & "localizedvalue" & strSeparator & Me.LocalizedValue
'Exit Property
'ErrMgr:
'  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "SerializedValue Set", LOG_ERROR
'End Property
'
'Public Property Let SerializedValue(Optional ByVal strSeparator As String = "|", ByVal vNewValue As String)
'
'    Dim s   As Variant
'    Dim arr As Variant
'    Dim i   As Long
'
'On Error GoTo ErrMgr
'
'    arr = Split(vNewValue, strSeparator)
'
'    For i = 0 To UBound(arr()) Step 2
'
'        Select Case arr(i)
'
'            Case "value": Me.Value = arr(i + 1)
'        End Select
'    Next
'Exit Property
'ErrMgr:
'  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXProperty.cls", "SerializedValue Set", LOG_ERROR
'End Property

Public Property Get MSIXDateValue() As String
    '1999-01-01T02:00:00Z
    MSIXDateValue = VBA.Format$(Me.Value, "yyyy-mm-dd\Thh:nn:ss\Z")
End Property

