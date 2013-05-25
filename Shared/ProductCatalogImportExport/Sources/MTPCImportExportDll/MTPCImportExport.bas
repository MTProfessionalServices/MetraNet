Attribute VB_Name = "MTPCImportExportModule"
Option Explicit




'Public Const UDRC_TYPE_NAME = "Unit Dependent Recurring Charge"
Public Const PI_TYPE_RECURRING_UNIT_DEPENDENT = 25

Public Const MT_COLLECTION_PROG_ID = "Metratech.MTCollection.1"

Public Const CALENDAR_PARAMETER_TABLE_NAME = "metratech.com/Calendar"

Public EFFECTIVE_DATE_TYPE_STRINGS      As Variant ' contains string const
Public MTUSAGECYCLETYPE_STRINGS         As Variant

Public g_enmExportImportMode             As IMPORT_EXPORT_MODE

Public XMLDom As DOMDocument40

Public Const XML_XML_TAG = "<?xml version=""1.0"" encoding=""UTF-8""?>"

Public Const MTPCIMPORTEXPORT_ERROR_1000 = "Unexpected run time error "
Public Const MTPCImportExport_ERROR_1001 = "MTPCImportExport_ERROR_1001-Counter CounterID=[COUNTERID] is not set on discount [DISCOUNT]"
Public Const MTPCImportExport_ERROR_1002 = "MTPCImportExport_ERROR_1002-XMLDOM Parsing filename=[FILENAME] error=[ERROR] filepos=[FILEPOS] line=[LINE] linepos=[LINEPOS] reason=[REASON] scrtext=[TEXT]"
Public Const MTPCImportExport_ERROR_1003 = "MTPCImportExport_ERROR_1003-File [FILENAME] does not exist"
Public Const MTPCImportExport_ERROR_1004 = "MTPCImportExport_ERROR_1004-Parameter table [NAME] not found (Internal Error)."
Public Const MTPCImportExport_ERROR_1005 = "MTPCImportExport_ERROR_1005-Price List [NAME] not found (Internal Error)."
Public Const MTPCImportExport_ERROR_1006 = "MTPCImportExport_ERROR_1006-PriceAble Item Template [NAME] not found (Internal Error)."
Public Const MTPCImportExport_ERROR_1007 = "MTPCImportExport_ERROR_1007-Cannot create Rate Schedule object."
Public Const MTPCImportExport_ERROR_1008 = "MTPCImportExport_ERROR_1008-Localized string [FQN] not found. Language=[LANGUAGE]"
Public Const MTPCImportExport_ERROR_1009 = "MTPCImportExport_ERROR_1009-PriceAbleItem Type [PRICEABLEITEMTYPE] has not been find and is required for the product offering [PRODUCTOFFERING]"
Public Const MTPCImportExport_ERROR_1010 = "MTPCImportExport_ERROR_1010-Cannot find calendar [CALENDAR]"
Public Const MTPCImportExport_ERROR_1012 = "MTPCImportExport_ERROR_1012-Cannot write file [FILE]"
Public Const MTPCImportExport_ERROR_1013 = "MTPCImportExport_ERROR_1013-Cannot find the Transaction object context (GetObjectContext())"
Public Const MTPCImportExport_ERROR_1014 = "MTPCImportExport_ERROR_1014-The transaction failed to complete so abort transaction"
Public Const MTPCImportExport_ERROR_1015 = "MTPCImportExport_ERROR_1015-In SafeMode warnings are considered errors. "
Public Const MTPCImportExport_ERROR_1016 = "MTPCImportExport_ERROR_1016-Cannot find product offering [PRODUCT_OFFERING]"
Public Const MTPCImportExport_ERROR_1017 = "MTPCImportExport_ERROR_1017-No product offering found for command line value '[COMMANDLINE-VALUE]'"
Public Const MTPCImportExport_ERROR_1018 = "MTPCImportExport_ERROR_1018-Cannot find any rate schedule in ICB subscription : ParameterTable [PT], PriceList ID [PL], PriceAbleItemTemplate [PIT], PriceAbleItemInstance [PII] "
Public Const MTPCImportExport_ERROR_1019 = "MTPCImportExport_ERROR_1019-No price list found for command line value '[COMMANDLINE-VALUE]'"
Public Const MTPCImportExport_ERROR_1020 = "MTPCImportExport_ERROR_1020-Cannot find price list [PL]"
Public Const MTPCImportExport_ERROR_1021 = "MTPCImportExport_ERROR_1021-No corporation found for command line value '[COMMANDLINE-VALUE]'"
Public Const MTPCImportExport_ERROR_1022 = "MTPCImportExport_ERROR_1022-Exporting product offering [PO] failed. Export continue."

Public Const MTPCImportExport_ERROR_1023 = "MTPCImportExport_ERROR_1023-Cannot find corporation [CORP], namespace [CORPNAMESPACE]"
Public Const MTPCImportExport_ERROR_1024 = "MTPCImportExport_ERROR_1024-Error found adding members to group subscription [GSUB] in batch, see MTLog.txt file for details"
Public Const MTPCImportExport_ERROR_1025 = "MTPCImportExport_ERROR_1025-Cannot find check sum form parameter table [PT]"
Public Const MTPCImportExport_ERROR_1026 = "MTPCImportExport_ERROR_1026-Check sum parameter table [PT] does not match. XMLCheckSum=[XMLCHECKSUM]; SystemCheckSum=[SYSTEMCHECKSUM];"
Public Const MTPCImportExport_ERROR_1027 = "MTPCImportExport_ERROR_1027-Exported file XML is not valid. Parsing filename=[FILENAME] error=[ERROR] filepos=[FILEPOS] line=[LINE] linepos=[LINEPOS] reason=[REASON] scrtext=[TEXT]"
Public Const MTPCImportExport_ERROR_1028 = "MTPCImportExport_ERROR_1028-Cannot found the group subscription distribution account [NAMESPACE]:[USERNAME]"
Public Const MTPCImportExport_ERROR_1029 = "MTPCImportExport_ERROR_1029-Cannot find Group Subscription ID for group subscription [GS], corporation [CORP]"
Public Const MTPCImportExport_ERROR_1030 = "MTPCImportExport_ERROR_1030-Cannot login with username:[USERNAME] password namespace:[NAMESPACE]"
Public Const MTPCImportExport_ERROR_1031 = "MTPCImportExport_ERROR_1031-Cannot find parameter table [NAME]"
Public Const MTPCImportExport_ERROR_1032 = "MTPCImportExport_ERROR_1032-Cannot load Rate Schedule id [RSID]"
Public Const MTPCImportExport_ERROR_1033 = "MTPCImportExport_ERROR_1033-Cannot find Unit Dependent Recurring Charge in subscription [SUB_NAME]"
Public Const MTPCImportExport_ERROR_1034 = "MTPCImportExport_ERROR_1034-Internal Error-Cannot find the UDRC ID in the rowset Subscription.GetRecurringChargeUnitValuesAsRowset() from ProductOffering.GetPriceableItemsOfType(GetUDRCTypeID(Me.ProductCatalog))"
Public Const MTPCImportExport_ERROR_1035 = "MTPCImportExport_ERROR_1035-Cannot find price list [PLNAME]"
Public Const MTPCImportExport_ERROR_1036 = "MTPCImportExport_ERROR_1036-Cannot found the charge account [NAMESPACE]:[USERNAME], subscription [SUBNAME]"
Public Const MTPCImportExport_ERROR_1037 = "MTPCImportExport_ERROR_1037-Cannot find priceableitem instance [PIINAME], for group subscription [GSUBNAME]"
Public Const MTPCImportExport_ERROR_1038 = "MTPCImportExport_ERROR_1038-Cannot find Unit Dependent Recurring Charge in group subscription or subscription [SUB_NAME]"
Public Const MTPCImportExport_ERROR_1039 = "MTPCImportExport_ERROR_1039-Cannot find adjustment type [NAME]"
Public Const MTPCImportExport_ERROR_1040 = "MTPCImportExport_ERROR_1040-Cannot find adjustment instance [ADJ_NAME], in price able item [PI_NAME]"
Public Const MTPCImportExport_ERROR_1041 = "MTPCImportExport_ERROR_1041-No price lists found for command line value '[COMMANDLINE-VALUE]'"
Public Const MTPCImportExport_ERROR_1042 = "MTPCImportExport_ERROR_1042-Exporting price list [PL] failed. Export continue."
Public Const MTPCImportExport_ERROR_1043 = "MTPCImportExport_ERROR_1043-Cannot find price able item [NAME]"
Public Const MTPCImportExport_ERROR_1044 = "MTPCImportExport_ERROR_1044-Cannot find parameter table [NAME]"
Public Const MTPCImportExport_ERROR_1045 = "MTPCImportExport_ERROR_1045-Cannot access the RecordCount property of the Error rowset, while executing [DESCRIPTION]"
Public Const MTPCImportExport_ERROR_1046 = "MTPCImportExport_ERROR_1046-The group subscription file [FILE] was exported on a RMP system that does not inforce Hierarchy Restricted Operations, the current RMP system DOES inforce Hierarchy Restricted Operations."
Public Const MTPCImportExport_ERROR_1047 = "MTPCImportExport_ERROR_1047-The private Price List '[PL]' for product offering '[PO]' cannot be found in the system, though the product offering was created and saved. The XML File may have a wrong private Price List name because it was manually edited."
Public Const MTPCImportExport_ERROR_1048 = "MTPCImportExport_ERROR_1048-Error reading XML RateSchedule RuleSet. ErrorDescription:'[ERR_MSG]', XML:'[XML]'"


'RMP where the file was exported does not inforce Hierarchy Restricted Operations


Public Const MTPCImportExport_WARNING_1001 = "MTPCImportExport_WARNING_1001-ProductOffering '[PRODUCTOFFERING]', Parameter Table '[PARAMETERTABLE]', PriceAbleItem '[PRICEABLEITEM]'. PriceList has no mapping"""
Public Const MTPCImportExport_WARNING_1002 = "MTPCImportExport_WARNING_1002-RateSchedule [RATESCHEDULE] found with no rule"
Public Const MTPCImportExport_WARNING_1003 = "MTPCImportExport_WARNING_1003-PriceAbleItem Template [PRICEABLEITEMTEMPLATE] already exist"
Public Const MTPCImportExport_WARNING_1004 = "MTPCImportExport_WARNING_1004-Price List [PRICELIST] already exist"
Public Const MTPCImportExport_WARNING_1005 = "MTPCImportExport_WARNING_1005-Calendar [CALENDAR] already exist"
Public Const MTPCImportExport_WARNING_1006 = "MTPCImportExport_WARNING_1006-RateSchedule [RATESCHEDULE] already exist"
Public Const MTPCImportExport_SEVERE_WARNING_1007 = "MTPCImportExport_SEVERE_WARNING_1007-<Counter> has no attribute name in PriceAbleItem '[PRICEABLEITEM]'"
Public Const MTPCImportExport_WARNING_1008 = ""
Public Const MTPCImportExport_SEVERE_WARNING_1009 = "MTPCImportExport_SEVERE_WARNING_1009-No COM+ Transaction involved"
Public Const MTPCImportExport_WARNING_1010 = "MTPCImportExport_WARNING_1010-Rate Schedule already exist : ParameterTable [PT], PriceList [PL], PriceAbleItemTemplate [PIT], StartDate [ST], BeginType [BT], EndDate [ED], EndType [ET]"
Public Const MTPCImportExport_WARNING_1011 = "MTPCImportExport_WARNING_1011-Cannot find account namespace=[NAMESPACE] username=[USERNAME] "
'Public Const MTPCImportExport_WARNING_1012 = ""
Public Const MTPCImportExport_WARNING_1013 = "MTPCImportExport_WARNING_1013-No integrity data found in the xml file [FILE]"
Public Const MTPCImportExport_WARNING_1014 = "MTPCImportExport_WARNING_1014-No group subscription the corporation [CORPORATION]"
Public Const MTPCImportExport_WARNING_1015 = "MTPCImportExport_WARNING_1015-Cannot find account namespace=[NAMESPACE] username=[USERNAME] for the group subscription [SUB]"
Public Const MTPCImportExport_WARNING_1016 = "MTPCImportExport_WARNING_1015-object [OBJECT], property [PROPERTY] has space in its name"
Public Const MTPCImportExport_WARNING_1017 = "MTPCImportExport_WARNING_1017-Reason Code [NAME] already exist"
Public Const MTPCImportExport_WARNING_1018 = "MTPCImportExport_WARNING_1018-No <adjustment type=""template""> tag found for price able item [PI_NAME]"
Public Const MTPCImportExport_WARNING_1019 = "MTPCImportExport_WARNING_1019-No <adjustment type=""instance""> tag found for price able item [PI_NAME]"
Public Const MTPCImportExport_WARNING_1020 = "MTPCImportExport_WARNING_1020-Nothing was exported or imported"
Public Const MTPCImportExport_WARNING_1021 = "Subscription to Product Offering [PO], AccountID:[ACCOUNTID] is in the past '[ENDDATE]'<'[NOW]'"
Public Const MTPCImportExport_WARNING_1022 = "MTPCImportExport_WARNING_1022-The group subscription file [FILE] was exported on a RMP system that DOES inforce Hierarchy Restricted Operations, the current RMP system DOES NOT inforce Hierarchy Restricted Operations."
Public Const MTPCImportExport_WARNING_1023 = "MTPCImportExport_WARNING_1023-Language [LANGUAGE] is not supported by the system"
Public Const MTPCImportExport_WARNING_1024 = "MTPCImportExport_WARNING_1024-Product Offering '[PO]' was found without currency, probably a 3.0 Product Offering, the currency was set to USD"
Public Const MTPCImportExport_WARNING_1025 = "MTPCImportExport_WARNING_1025-No member found in the subscription '[GSUB]'"



Public Const MTPCImportExport_MESSAGE_1000 = "[EXENAME] starting at [NOW]"
Public Const MTPCImportExport_MESSAGE_1001 = "Product Offering [PRODUCTOFFERING] ([POID]) imported successfully, but transaction not completed yet."
Public Const MTPCImportExport_MESSAGE_1002 = "[WARNINGCOUNTER] warning(s) were logged"
Public Const MTPCImportExport_MESSAGE_1003 = "MTPCImportExport application [APPLICATION] terminate"
Public Const MTPCImportExport_MESSAGE_1004 = "Import Product Offering(s) from file [FILE]"
Public Const MTPCImportExport_MESSAGE_1005 = "Export subscriptions from product offering [PO]"
Public Const MTPCImportExport_MESSAGE_1006 = "Import Subscriptions(s) from file [FILE]"
Public Const MTPCImportExport_MESSAGE_1007 = "Account [NAMESPACE]:[ACCOUNTNAME] subscribed to product offering [PO], but transaction not completed yet."
Public Const MTPCImportExport_MESSAGE_1008 = "Import Time [TIME]"
Public Const MTPCImportExport_MESSAGE_1009 = "Export Price List [PL]"
Public Const MTPCImportExport_MESSAGE_1010 = "Import Price List(s) from file [FILE]"
Public Const MTPCImportExport_MESSAGE_1011 = "Export group subscription(s) corporation [CORP]"
Public Const MTPCImportExport_MESSAGE_1012 = "Export group subscription [SUB]"
Public Const MTPCImportExport_MESSAGE_1013 = "Import Group Subscriptions(s) from file [FILE]"
Public Const MTPCImportExport_MESSAGE_1014 = "Integrity verified for parameter table [PT]"
Public Const MTPCImportExport_MESSAGE_1015 = "XML File Integrity Verification"
Public Const MTPCImportExport_MESSAGE_1016 = "Exported XML File has been validated [FILE]"
Public Const MTPCImportExport_MESSAGE_1017 = "PCImportExport [VERSION][CRLF]"
Public Const MTPCImportExport_MESSAGE_1018 = "[LOCALIZATION]Set [OBJECTTYPE].[NAME].DisplayNames(""[LANGUAGE]"")=""[VALUE]"";"
Public Const MTPCImportExport_MESSAGE_1019 = "MTPCImportExport_MESSAGE_1019-No localized property DisplayNames found in object [OBJECT_NAME]"
Public Const MTPCImportExport_MESSAGE_1020 = "About to check commandline date validity CommandLineDate=[DATE]"
Public Const MTPCImportExport_MESSAGE_1021 = "Import Group Subscriptions:[NAME]"


Public Const CalendarPeriode_CSVInterface = "StartTime,EndTime,Code,ID"

Public Enum XMLTAGTYPE
        XMLTAGTYPE_NONE = 0
        XMLTAGTYPE_OPEN = 1
        XMLTAGTYPE_CLOSE = 2
        XMLTAGTYPE_OPENCLOSE = XMLTAGTYPE_OPEN + XMLTAGTYPE_CLOSE
End Enum

Public Const CSV_SEPARATOR = ","
Public Const SQL_SEPARATOR = ","
Public Const COMMACODE = "&#44"
Public Const NULLCODE = "<NULL>"

Public Const ID_SEPARATOR = "|"

Public Const XML_INDENT_SIZE = 5

' The char ! mean we exclude the property
'Public Const MTPROPERTY_EXPORT_INTERFACE = "DataTypeAsString,DisplayName,EnumSpace,EnumType,Extended,Length,Overrideable,PropertyGroup,Required,!SummaryView,Value"
Public Const MTPROPERTY_EXPORT_INTERFACE = "Value"

'Public static_booVerbose            As Boolean
Public static_objXMLOutPut          As cStringConcat
Public static_objConsoleWindow      As CConsoleWindow
Public static_strLanguage           As String
Public static_strCommandLine        As String
Public static_lngWarningCounter     As Long
Public static_strSessionGUID        As String
Private static_UTF8Instance         As New CUTF8

'Private m_objLocaleTranslator As COMDBOBJECTSLib.COMLocaleTranslator
Private m_objPVNameIdLookup     As NAMEIDLib.MTNameID
Private m_objEnumConfig         As MTENUMCONFIGLib.EnumConfig
Private m_GetAccountIDRowset    As Object

' According Boeck we must avoid to create the EnumConfig if we do not need it
' rboeck: Commented out enumConfig creation
' Now enumconfig will be created first time needed to avoid it slowing down COMPlus
' (eventually enumConfig will be fixed)
Public static_objEnumConfig         As New EnumConfig

Public RCD As New MTRcd

Private m_strXMLSpace As String

Public Function XMLOutputInitialize() As Boolean

    Dim w As New cWindows
    
    Set static_objXMLOutPut = New cStringConcat
    static_objXMLOutPut.Init 65535
    static_objXMLOutPut.AutomaticCRLF = True
    XMLOutPut = XML_XML_TAG
    
    XMLOutPutTag "xmlconfig", XMLTAGTYPE_OPEN
    
    XMLOutPutTagValue "CreationDate", Now
    XMLOutPutTagValue "ComputerName", w.ComputerName
    XMLOutPutTagValue "UserName", w.Username
    XMLOutPutTagValue "PCImportExportVersion", GetPCImportExportVersion()
    XMLOutPutTagValue "RMPVersion", GetRMPVersion()
    XMLOutPutTagValue "RMPIsHierarchyRestrictedOperations", GetRMPIsHierarchyRestrictedOperations()
    
    
    XMLOutputInitialize = True
End Function

Public Function GetPCImportExportVersion() As String
    GetPCImportExportVersion = App.Major & "." & App.Minor & "." & App.Revision
End Function

Public Function GetRMPVersion() As String
    GetRMPVersion = "" 'App.Major & "." & App.Minor & "." & App.Revision
End Function

Public Function CSVOutputInitialize() As Boolean

    Set static_objXMLOutPut = New cStringConcat
    static_objXMLOutPut.Init 65535
    static_objXMLOutPut.AutomaticCRLF = False
    CSVOutputInitialize = True
End Function

Public Property Get XMLOutPut() As String

    XMLOutPut = static_objXMLOutPut.GetString()
End Property

Public Property Let XMLOutPut(ByVal vNewValue As String)

    On Error Resume Next
    static_objXMLOutPut.Concat vNewValue
    
    If Err.Number Then
        Debug.Assert 0
    End If
End Property


Public Function SaveXMLOutPut(ByVal strXMLFileName As String) As Boolean

    Dim objTextFile As New cTextFile
    
    XMLOutPutTag "xmlconfig", XMLTAGTYPE_CLOSE
    
    'INFO vbNewLine & "Save file " & strXMLFileName
    'If objTextFile.LogFile(strXMLFileName, XMLOutPut, True) Then ' #Pre 3.7
    If objTextFile.SaveFileAsXML(strXMLFileName, XMLOutPut) Then ' #3.7
    
        SaveXMLOutPut = ValidXML(strXMLFileName)
    Else
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1012, "FILE", strXMLFileName), "MTPCImportExportModule", "SaveXMLOutPut", LOG_ERROR
    End If
End Function

Public Function TurnNameIntoFile(ByVal strCSVFileName As String) As String
    strCSVFileName = Replace(strCSVFileName, "/", "_")
    strCSVFileName = Replace(strCSVFileName, "\", "_")
    TurnNameIntoFile = Replace(strCSVFileName, ":", "_")
End Function

'Public Function SaveCSVOutPut(ByVal strCSVFileName As String) As Boolean
'
'    Dim objTextFile As New cTextFile
'
'
'    'INFO vbNewLine & "Save file " & strCSVFileName
'    SaveCSVOutPut = objTextFile.LogFile(strCSVFileName, XMLOutPut, True)
'End Function

Public Function XMLOutPutTagValue(ByVal strTagName As String, Optional ByVal strValue As String) As Boolean

    XMLOutPut = m_strXMLSpace & "<" & LCase$(strTagName) & ">" & TO_UTF8(ProcessXML(strValue)) & "</" & LCase$(strTagName) & ">"
End Function




Public Function XMLOutPutTag(ByVal varName As Variant, Optional ByVal eTagType As XMLTAGTYPE = XMLTAGTYPE_OPEN, Optional ByVal strTagAttributeName As String, Optional strComment As String, Optional strExtendedAttributeNameValue As String) As Boolean



    Dim strTagName As String
    
    
    Dim strExtendedAttributeName As String
    Dim strExtendedAttributeValue As String
    
    If Len(strExtendedAttributeNameValue) Then
        strExtendedAttributeName = Mid(strExtendedAttributeNameValue, 1, InStr(strExtendedAttributeNameValue, "=") - 1)
        strExtendedAttributeValue = Mid(strExtendedAttributeNameValue, InStr(strExtendedAttributeNameValue, "=") + 1)
        strExtendedAttributeNameValue = " " & ProcessXML(strExtendedAttributeName) & "=""" & TO_UTF8(ProcessXML(strExtendedAttributeValue)) & """ "
    End If
    
    If IsObject(varName) Then
        strTagName = GetCOMObjectTypeNameForXML(varName)
    Else
        strTagName = varName
    End If
    
    If Len(strTagAttributeName) Then
        strTagAttributeName = " name=""" & TO_UTF8(ProcessXML(strTagAttributeName)) & """"
    End If
    
    If eTagType And XMLTAGTYPE_CLOSE Then
        
        If Len(m_strXMLSpace) Then m_strXMLSpace = Mid(m_strXMLSpace, 1, Len(m_strXMLSpace) - XML_INDENT_SIZE)
        GoSub GenerateComment
        XMLOutPut = m_strXMLSpace & "</" & LCase$(strTagName) & ">"
    Else
        XMLOutPut = m_strXMLSpace & "<" & LCase$(strTagName) & IIf(Len(strTagAttributeName), strTagAttributeName, "") & IIf(Len(strExtendedAttributeNameValue), strExtendedAttributeNameValue, "") & ">"
        GoSub GenerateComment
        m_strXMLSpace = m_strXMLSpace & Space(XML_INDENT_SIZE)
    End If
    Exit Function
    
GenerateComment:
    If Len(strComment) Then
        Dim b As Boolean
        b = XMLOutPutAutomaticCRLF
        XMLOutPutAutomaticCRLF = False
        XMLOutPutComment = strComment
        XMLOutPutAutomaticCRLF = b
    End If
Return
End Function

Public Function XMLOutPutProperty(Property As MTProperty, Optional strComment As String, Optional ByVal varSpecificValue As Variant) As Boolean
    If IsMissing(varSpecificValue) Then
        XMLOutPutProperty = XMLOutPutPropertyNameValue(GetCOMObjectTypeNameForXML(Property), Property.Name, Property.Value, strComment)
    Else
        XMLOutPutProperty = XMLOutPutPropertyNameValue(GetCOMObjectTypeNameForXML(Property), Property.Name, varSpecificValue, strComment)
    End If
End Function

Public Function XMLOutPutPropertyNameValue(strPropertyType As String, strPropertyName As String, ByVal strPropertyValue As String, Optional strComment As String, Optional ByVal booAcceptBlankValue As Boolean = False) As Boolean

    Dim v               As Variant
    Dim arrProperties   As Variant
    Dim m_strXMLSpaceBU As String
    Dim strValue        As String
    Dim strPName        As String
    
    On Error GoTo ErrMgr
        
    XMLOutPutAutomaticCRLF = False
    m_strXMLSpaceBU = m_strXMLSpace
    m_strXMLSpace = ""
    
    XMLOutPut = m_strXMLSpaceBU
    
    strPName = strPropertyName
    
    #If BUILD301 Then
        If InStr(strPName, " ") Then ' Check for no space in property name
            TRACE PreProcess(MTPCImportExport_WARNING_1016, "OBJECT", strPropertyType, "PROPERTY", strPropertyName), "MTPCImportExportModule", "XMLOutPutProperty", LOG_WARNING
            strPName = Replace(strPName, " ", "") ' in 3.0.1 the property StartDate and AccountID of the object gsubmember has a space in their meta data definition
        End If
    #End If

    strValue = strPropertyValue

    ' From now on, we will always write out zero-length properties so that all possible properties are visible in the exported XML
    ' TRW - 5/10/2007
    'If (Len(strValue) > 0) Or (booAcceptBlankValue) Then
    
        '<property name="accountID">53309</property>
        Debug.Print "<" & strPropertyType & " name=""" & strPName & """>" & ProcessXML(strValue) & "<" & strPropertyType & ">"
        XMLOutPutTag strPropertyType, , strPName
        m_strXMLSpace = "" ' delete the indent and we do not care to restore it at this time , we do it a the end of the function
        XMLOutPut = TO_UTF8(ProcessXML(strValue))
        XMLOutPutTag strPropertyType, XMLTAGTYPE_CLOSE, , strComment

        If (g_enmExportImportMode And IMPORT_EXPORT_VERBOSE) Then
    
                MTGlobal_VB_MSG.TRACE strPropertyType & " " & strPName & "= """ & strValue & """", "MTPCImportExportModule", "XMLOutPutProperty", LOG_INFO
        End If
    'End If
    m_strXMLSpace = m_strXMLSpaceBU
    XMLOutPutAutomaticCRLF = True
    XMLOutPut = "" ' force a new line
    
    
    XMLOutPutPropertyNameValue = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString() & "; ObjectType=" & strPropertyType, "MTPCImportExportModule", "XMLOutPutPropertyNameValue", LOG_ERROR
End Function

' BP:
Public Function XMLOutPutCollectionItem(ByVal strPropertyValue As String) As Boolean

    Dim v               As Variant
    Dim arrProperties   As Variant
    Dim m_strXMLSpaceBU As String
    Dim strValue        As String
    Dim strPName        As String
    
    On Error GoTo ErrMgr
        
    XMLOutPutAutomaticCRLF = False
    m_strXMLSpaceBU = m_strXMLSpace
    m_strXMLSpace = ""
    
    XMLOutPut = m_strXMLSpaceBU
    
    strPName = "item"
    
    strValue = strPropertyValue
    
    If (Len(strValue) > 0) Then
    
        '<property name="accountID">53309</property>
        Debug.Print "<" & strPName & """>" & ProcessXML(strValue) & "<" & strPName & ">"
        XMLOutPutTagValue strPName, strValue
        m_strXMLSpace = "" ' delete the indent and we do not care to restore it at this time , we do it a the end of the function
    End If
    m_strXMLSpace = m_strXMLSpaceBU
    XMLOutPutAutomaticCRLF = True
    XMLOutPut = "" ' force a new line
    
    If (g_enmExportImportMode And IMPORT_EXPORT_VERBOSE) Then
    
        MTGlobal_VB_MSG.TRACE strPName & "=" & strValue, "MTPCImportExportModule", "XMLOutPutCollectionItem", LOG_INFO
    End If
    
    XMLOutPutCollectionItem = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString() & "; ObjectType=" & "MTCollection", "MTPCImportExportModule", "XMLOutPutCollectionItem", LOG_ERROR
End Function




Public Function ExportObjectXMLHeaderAndProperties(ByVal Object As Object, eTagType As XMLTAGTYPE, Optional ByVal strAttributeName As String, Optional ByVal strExcludedProperties As String, Optional strExtendedAttributeNameValue As String) As Boolean

    Dim Property                As MTProperty
    Dim strTmpName              As String
    Dim strLCasePropertyName    As String
    Dim strComment              As String
    Dim booIsWrongMetaData      As Boolean
    Dim varSpecificValue        As Variant
    Dim v                       As Variant
    Dim strTmpExclude           As String
    
    On Error GoTo ErrMgr
    

    strTmpName = MTObjectName(Object)
    If Len(strTmpName) Then strAttributeName = strTmpName
    If eTagType And XMLTAGTYPE_OPEN Then XMLOutPutTag Object, , strAttributeName, , strExtendedAttributeNameValue
    
    For Each Property In Object.Properties
    
        strLCasePropertyName = UCase$(Property.Name)
        
        #If BUILD301 Then
            If InStr(strLCasePropertyName, " ") Then ' Check for no space in property name
                TRACE PreProcess(MTPCImportExport_WARNING_1016, "OBJECT", TypeName(Object), "PROPERTY", Property.Name), "MTPCImportExportModule", "ExportObjectXMLHeaderAndProperties", LOG_WARNING
                strLCasePropertyName = Replace(strLCasePropertyName, " ", "") ' in 3.0.1 the property StartDate and AccountID of the object gsubmember has a space in their meta data definition
            End If
        #End If
        
        strComment = ""
        
        If (strLCasePropertyName <> "NAME") And (InStr(strExcludedProperties, "," & strLCasePropertyName & ",") = 0) Then ' do not export the property name
        
            'INFO "3.1 " & TypeName(Object) & " " & Property.DataTypeAsString & " " & Property.Name & "=" & Property.value
        
            If Property.DataTypeAsString = "object" Then
                
                ' BP: QI for IMTCollection interface. Let's try to export collections in a generic way
                ' Dim coll As IMTCollection
                ' Set coll = Property.Value
                If TypeOf Property.Value Is IMTCollection Then ' Not coll Is Nothing Then
                    ExportCollection Property
                Else
                If IsEmpty(Property.Value) Then
                
                    If (strLCasePropertyName = "UNITVALUEENUMERATION") Then
                        
                        'Debug.Assert 0
                        For Each v In Object.UnitValueEnumeration
                        
                            varSpecificValue = varSpecificValue & v & " "
                        Next
                        XMLOutPutProperty Property, strComment, Trim$(varSpecificValue)
                    End If
                Else
                    If UCase$(TypeName(Property.Value)) = "LOCALIZEDENTITY" Then
                    
                        ' 3.6
                        '
                        ' We ignore this kind of object at that level, a specific code will handle multi language properties
                        '
                    
                    ElseIf UCase$(TypeName(Property.Value)) = "ADJUSTMENTFORMULA" Then
                        
                        ' We do not export the adjustment formula we do not need them because they are part of
                        ' the adjustment type and we do not export adjustment type to use it but just to
                        ' be able at import time to retreive the adjustment type name
                        
                    ElseIf UCase$(TypeName(Object)) = "ADJUSTMENT" And IsAPriceAbleItem(Property.Value) Then
                    
                        ' We do not export the Adjustment parent priceable item we probably already exportinhg it at a higher level
                        
                    Else
                        ' 3.7 we do not export at all the boolean property Relative
                        ' which is replaced with enum type Mode
                        If TypeName(Property.Value) = "IMTPCCycle" Then
                            strTmpExclude = ",RELATIVE,"
                        Else
                            strTmpExclude = ""
                        End If
                        ExportObjectXMLHeaderAndProperties = ExportObjectXMLHeaderAndProperties(Property.Value, XMLTAGTYPE_OPENCLOSE, Property.Name, strTmpExclude)
                    End If
                    End If
                End If
            Else
                ' Generate a comment to give the enum type a name
                If LCase$(TypeName(Object)) = "imtpctimespan" And ((strLCasePropertyName = "STARTDATETYPE") Or (strLCasePropertyName = "ENDDATETYPE")) Then
                    strComment = EFFECTIVE_DATE_TYPE_STRINGS(Property.Value)
                End If
                
                If LCase$(TypeName(Object)) = "imtpccycle" And (strLCasePropertyName = "CYCLETYPEID") Then
                    strComment = MTUSAGECYCLETYPE_STRINGS(Property.Value)
                End If
                XMLOutPutProperty Property, strComment
            End If
        End If
    Next
    If eTagType And XMLTAGTYPE_CLOSE Then XMLOutPutTag Object, XMLTAGTYPE_CLOSE
    ExportObjectXMLHeaderAndProperties = True
    Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString() & "; ObjectType=" & TypeName(Object), "MTPCImportExportModule", "ExportObjectXMLHeaderAndProperties", LOG_ERROR
End Function


Public Property Get XMLOutPutAutomaticCRLF() As Boolean
    static_objXMLOutPut.AutomaticCRLF = XMLOutPutAutomaticCRLF
End Property

Public Property Let XMLOutPutAutomaticCRLF(ByVal vNewValue As Boolean)
     static_objXMLOutPut.AutomaticCRLF = vNewValue
End Property

Public Function SaxGetAttributeValue(Attributes As MSXML2.IVBSAXAttributes, strName As String) As String

    Dim i As Long
    For i = 0 To (Attributes.Length - 1)
        If Attributes.getLocalName(i) = strName Then
            SaxGetAttributeValue = Attributes.getValue(i)
        End If
    Next
End Function


'Public Function SetMTProperty(o As Object, strPropertyName As String, strValue As String) As Boolean
'
'    On Error GoTo ErrMgr
'
'    Dim strTrace As String
'
'    strTrace = TypeName(o) & "(""" & o.Name & """).Properties(""" & strPropertyName & """).Value=" & strValue ' Build the string here in case of run time error we have some info
'
'    If strPropertyName <> "ID" Then
'
'        o.Properties.Item(strPropertyName).value = strValue
'        If static_booVerbose Then
'            INFO strTrace
'        End If
'    End If
'    SetMTProperty = True
'    Exit Function
'ErrMgr:
'    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString() & " " & strTrace, "MTPCImportExportModule", "SaveMTObject", LOG_ERROR
'End Function

Public Function SaveMTObject(o As Object) As Boolean

    On Error GoTo ErrMgr
    
    Dim strTrace As String
    
    strTrace = TypeName(o) & "(""" & o.Name & """).Save" ' Build the string here in case of run time error we have some info
    
    o.Save
    #If DEBUG_ Then
        INFO strTrace
    #End If
    SaveMTObject = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString() & " " & strTrace, "MTPCImportExportModule", "SaveMTObject", LOG_ERROR
End Function

Public Function INFO(ByVal strText As String, Optional ByVal Module As Variant, Optional ByVal strFunctionName As String) As Boolean

    #If DEBUG_ Then
        Debug.Print strText
        INFO = MTPCImportExportModule.TRACE(strText, Module, strFunctionName, LOG_INFO)
    #End If
End Function

Public Function INFOOBJECT(o As Object, strMessage As String) As Boolean

    PrintConsole "."
    
'    #If DEBUG_ Then
'        If static_booVerbose Then
'            INFOOBJECT = INFO(strMessage & " " & TypeName(o) & ".Name=" & MTObjectName(o))
'        Else
'End If
'#End If
End Function

Public Function TRACE(ByVal strText As String, Optional ByVal Module As Variant, Optional ByVal strFunctionName As String, Optional ByVal enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_DEBUG, Optional ByVal booDisplayConsole As Boolean = True) As Boolean

    If enmLogLevel = LOG_ERROR Then
        Debug.Assert 0
    End If

#If CONSOLE Then
    If (Not static_objConsoleWindow Is Nothing) And (booDisplayConsole) Then
    
        If enmLogLevel = LOG_DEBUG Then
        
        ElseIf enmLogLevel = LOG_INFO Then
        
        ElseIf enmLogLevel = LOG_WARNING Then
        
            static_objConsoleWindow.WriteText ".w", False ' Display at the console level just a char to tel the use there is a Warning
        Else
            If enmLogLevel = LOG_ERROR Then static_objConsoleWindow.WriteText vbNewLine
            static_objConsoleWindow.WriteText vbNewLine & strText
        End If
    End If
#End If
    
    If enmLogLevel = LOG_WARNING Then static_lngWarningCounter = static_lngWarningCounter + 1
    
    If Len(static_strSessionGUID) Then strText = "[SessionGUID=" & static_strSessionGUID & "]" & strText

    ' TRACE in mtlog.txt
    TRACE = MTGlobal_VB_MSG.TRACE(strText, Module, strFunctionName, enmLogLevel)
    
    
    
     ''''''''''''''fixTRACE strText, Module, strFunctionName, enmLogLevel
    Debug.Print strText
End Function


Private Function fixTRACE(ByVal strText As String, Optional ByVal Module As Variant, Optional ByVal strFunctionName As String, Optional ByVal enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_DEBUG) As Boolean

    Dim strModuleTrace      As String
    Dim strFunctionTrace    As String
    Dim strAppInfo          As String
    Dim s                   As String
    
    If IsMissing(Module) Then Module = ""
    If IsObject(Module) Then Module = TypeName(Module)
    
    If (Len(Module)) Then Module = "Module=" & Module & ";"
    If (Len(strFunctionName)) Then strFunctionTrace = "Function=" & strFunctionName & ";"
      
    s = "[LOGLEVEL:" & enmLogLevel & "]" & strModuleTrace & IIf(Len(strModuleTrace), " ", "") & strFunctionTrace & IIf(Len(strFunctionTrace), " ", "") & strText & " "
    
    Dim t As New cTextFile
    t.LogFile Environ("temp") & "\MTPCImportExport2.log", s
End Function


Public Function AddPostFixToFileName(ByVal strXMLFileName As String, strPostFix As String) As String
    AddPostFixToFileName = Replace(LCase$(strXMLFileName), ".xml", "_" & strPostFix & ".xml")
End Function



Public Property Let XMLOutPutComment(ByVal vNewValue As String)
    XMLOutPut = m_strXMLSpace & "<!-- " & vNewValue & " -->"
End Property



Public Function GetAccountID(ByVal strUserName As String, ByVal strNameSpace As String) As Long

    Dim i      As Long
    
    On Error GoTo ErrMgr
    
    GetAccountID = -1
    
    If Not IsValidObject(m_GetAccountIDRowset) Then
    
        Set m_GetAccountIDRowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
        m_GetAccountIDRowset.Init GetConfigRelativePath()
    End If
    m_GetAccountIDRowset.SetQueryString PreProcess("select id_acc from t_account_mapper where nm_login=N'[USERNAME]' and nm_space=N'[NAMESPACE]'", "USERNAME", strUserName, "NAMESPACE", strNameSpace)
    m_GetAccountIDRowset.Execute
    
    If m_GetAccountIDRowset.RecordCount = 0 Then
        ' we just return -1
    Else
        GetAccountID = m_GetAccountIDRowset.Value(CLng(0))
    End If
Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString() & " UserName:" & strUserName & "; NameSpace:" & strNameSpace, "MTPCImportExportModule", "GetAccountID", LOG_ERROR
End Function

Public Function ExecuteQuery(strQuery As String, ParamArray Parameters() As Variant) As IMTRowSet

    Dim Rowset As IMTRowSet
    Dim i      As Long
    
    On Error GoTo ErrMgr
    
    Set Rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    Rowset.Init GetConfigRelativePath()
    Rowset.SetQueryTag strQuery
    
    For i = 0 To UBound(Parameters()) Step 2
    
        Rowset.AddParam "%%" & Parameters(i) & "%%", CStr(Parameters(i + 1))
    Next
    
    Rowset.Execute
    Set ExecuteQuery = Rowset
Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString() & " Query=" & strQuery, "MTPCImportExportModule", "ExecuteQuery", LOG_ERROR
End Function

Public Function GetConfigRelativePath() As String
     GetConfigRelativePath = "queries\PCImportExport"
End Function


Public Function TranslateEnum(Prop As Object, Value As String) As String

    Dim resultProp As String
    
    If Len(Prop.EnumType) Then
        TranslateEnum = static_objEnumConfig.GetEnumeratorByID(CLng(Value))
    Else
        TranslateEnum = Value
    End If
End Function

Public Function PrintConsole(s As String) As Boolean
    
    #If CONSOLE Then
        If Not static_objConsoleWindow Is Nothing Then
           static_objConsoleWindow.WriteText s, False
        End If
    #Else
        TRACE s, , , LOG_INFO
    #End If
    Debug.Print s;
    DoEvents
End Function




' Skip the IMT part of the com object name
Public Function GetCOMObjectTypeNameForXML(ByVal o As Object) As String
    Dim s As String
    s = LCase$(TypeName(o))
    If Len(s) >= 3 Then
        If Mid(s, 1, 3) = "imt" Then s = Mid(s, 4)
    End If
    GetCOMObjectTypeNameForXML = s
End Function

Public Function XMLInputInitialize(strXMLFileName As String) As Boolean

    Dim objPP       As New CPreProcessor
    Dim objTextFile As New cTextFile
    
    On Error GoTo ErrMgr
   
    If Not objTextFile.ExistFile(strXMLFileName) Then
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1003, "FILENAME", strXMLFileName), "MTPCImportExportModule", "ImportProductOffering", LOG_ERROR
        Exit Function
    End If
    
    Set XMLDom = New DOMDocument40
    
    If XMLDom.Load(strXMLFileName) Then
        XMLInputInitialize = True
    Else
        objPP.Add "FILENAME", strXMLFileName
        objPP.Add "ERROR", XMLDom.parseError.errorCode
        objPP.Add "FILEPOS", XMLDom.parseError.filepos
        objPP.Add "LINE", XMLDom.parseError.Line
        objPP.Add "LINEPOS", XMLDom.parseError.linepos
        objPP.Add "REASON", XMLDom.parseError.reason
        objPP.Add "TEXT", XMLDom.parseError.srcText
        
        MTPCImportExportModule.TRACE objPP.Process(MTPCImportExport_ERROR_1002), "MTPCImportExportModule", "ImportProductOffering", LOG_ERROR
    End If
Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), "MTPCImportExportModule", "XMLInputInitialize", LOG_ERROR
End Function


Public Function ImportMTProperty(objPCComObject As Object, XMLNode As IXMLDOMNode, Optional ByVal strOptionalOnlyProperties As String, Optional ByVal strOptionalExclude As String, Optional ByVal strEnumTypeList As String) As Boolean

    Dim objXMLProperties    As IXMLDOMNodeList
    Dim objXMLProperty      As IXMLDOMNode
    Dim strName             As String
    Dim strValue            As String
    Dim objPCTimeSpan       As Object
    Dim objPCCycle          As MTPCCycle
    Dim booDoIt             As Boolean
    Dim v                   As Variant
    
    On Error GoTo ErrMgr
    
    
    Const IMPORT_PROPERTY_IGNORE = ",ID,PARENTID,KIND,PRODUCTOFFERINGID,TEMPLATEID,TYPEID,DISTRIBUTIONCPDID," ' property DISTRIBUTIONCPDID added in 3.8
    
    ' Import all the generic MTProperty
    Set objXMLProperties = XMLNode.selectNodes("property")
    
    For Each objXMLProperty In objXMLProperties
    
        strName = objXMLProperty.Attributes.getNamedItem("name").Text
        strValue = objXMLProperty.Text

        ' If we have a value and we must not ignore the value
        If Len(strValue) And (Not CBool(InStr(IMPORT_PROPERTY_IGNORE & strOptionalExclude, "," & UCase$(strName) & ","))) Then
        
            If Len(strOptionalOnlyProperties) Then
                booDoIt = InStr(strOptionalOnlyProperties, "," & UCase$(strName) & ",")
            Else
                booDoIt = True
            End If
            If booDoIt Then
            
                If (g_enmExportImportMode And IMPORT_EXPORT_VERBOSE) Then
                
                    MTGlobal_VB_MSG.TRACE TypeName(objPCComObject) & " " & strName & "=" & strValue, "MTPCImportExportModule", "ImportMTProperty", LOG_INFO
                End If
                
                Debug.Print TypeName(objPCComObject) & " " & strName & "=" & strValue
                
                If InStr(strEnumTypeList, "," & UCase$(strName) & ",") Then
                
                    v = GetValueFromFQN(strValue)
                    If IsEmpty(v) Then Exit Function
                    strValue = v
                End If
                
                
                If objPCComObject.Properties.Item(strName).Extended Then ' MDM 3.5
                
                    objPCComObject.Properties.Item(strName).Value = strValue
                Else
                    
                    If (LCase$(strName) = "unitvalueenumeration") And LCase$(TypeName(objPCComObject)) = "imtrecurringcharge" Then

                        For Each v In Split(strValue, " ")
                            objPCComObject.AddUnitValueEnumeration v
                        Next
                    Else
                        CallByName objPCComObject, strName, VbLet, strValue
                    End If
                End If
            End If
        End If
    Next
           
    ' Import all the generic PCTimeSpan property
    Set objXMLProperties = XMLNode.selectNodes("pctimespan")
    
    For Each objXMLProperty In objXMLProperties
    
        strName = objXMLProperty.Attributes.getNamedItem("name").Text
        
        If (Not CBool(InStr(IMPORT_PROPERTY_IGNORE & strOptionalExclude, "," & UCase$(strName) & ","))) Then
        
           If Len(strOptionalOnlyProperties) Then
                booDoIt = InStr(strOptionalOnlyProperties, "," & UCase$(strName) & ",")
            Else
                booDoIt = True
            End If
            If booDoIt Then
        
                Set objPCTimeSpan = CallByName(objPCComObject, strName, VbGet)
                If Not ImportMTProperty(objPCTimeSpan, objXMLProperty) Then Exit Function
            End If
        End If
    Next
    
    ' Import all the generic MTPCCycle property
    Set objXMLProperties = XMLNode.selectNodes("pccycle")
    For Each objXMLProperty In objXMLProperties
    
        strName = objXMLProperty.Attributes.getNamedItem("name").Text ' The name should be cycle there is only one per object
        Set objPCCycle = CallByName(objPCComObject, strName, VbGet)
        If Not ImportMTProperty(objPCCycle, objXMLProperty, , ",CYCLEID,ADAPTERPROGID,CYCLETYPEDESCRIPTION,") Then Exit Function
        'objPCCycle.ComputePropertiesFromCycleID
    Next
    ImportMTProperty = True
Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), "MTPCImportExportModule", "ImportMTProperty", LOG_ERROR
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Get PVNameIdLookUpObject() As NAMEIDLib.MTNameID

    On Error GoTo ErrMgr

    If (Not IsValidObject(m_objPVNameIdLookup)) Then
            Set m_objPVNameIdLookup = New NAMEIDLib.MTNameID
    End If
    Set PVNameIdLookUpObject = m_objPVNameIdLookup

    Exit Property
ErrMgr:
  MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), "MTPCImportExportModule", "PVNameIdLookUpObject", LOG_ERROR
End Property

Public Property Get EnumConfig() As MTENUMCONFIGLib.EnumConfig

    On Error GoTo ErrMgr

    If (Not IsValidObject(m_objEnumConfig)) Then
            Set m_objEnumConfig = New MTENUMCONFIGLib.EnumConfig
    End If
    Set EnumConfig = m_objEnumConfig

    Exit Property
ErrMgr:
  MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), "MTPCImportExportModule", "EnumConfig", LOG_ERROR
End Property


Public Function GetValueFromFQN(strFQN As String) As Variant

    On Error GoTo ErrMgr

    Dim lngDBID As Long
    
    lngDBID = PVNameIdLookUpObject.GetNameID(strFQN)
    GetValueFromFQN = EnumConfig.GetEnumeratorValueByID(lngDBID)
    Exit Function
ErrMgr:
  MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString() & " FQN=" & strFQN, "MTPCImportExportModule", "GetIDFromFQN", LOG_ERROR
End Function


Public Function GetFQNFromID(ByVal lngDBID As Long) As Variant

    On Error GoTo ErrMgr
    GetFQNFromID = PVNameIdLookUpObject.getName(lngDBID)
    Exit Function
ErrMgr:
  MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString() & " lngDBID=" & lngDBID, "MTPCImportExportModule", "GetFQNFromID", LOG_ERROR
End Function

Public Function GetFQNFromEnumTypeValue(ByVal strNameSpace As String, ByVal strName As String, ByVal strValue As String) As String

    GetFQNFromEnumTypeValue = GetFQNFromID(GetEnumTypeInternalDBID(strNameSpace, strName, strValue))
End Function

Public Function GetEnumTypeInternalDBID(ByVal strNameSpace As String, ByVal strName As String, ByVal strValue As String) As Long

    GetEnumTypeInternalDBID = EnumConfig.GetID(strNameSpace, strName, strValue)
End Function

Public Function GetRateScheduleExtId(ProductCatalog As MTProductCatalog, RateSchedule As MTRateSchedule, PriceList As MTPriceList, strParamTableName As String) As String
    
    Dim PriceAbleItem               As MTPriceableItem
    Dim s                           As String
    
    Set PriceAbleItem = ProductCatalog.GetPriceableItem(RateSchedule.TemplateID)
    
    s = PriceAbleItem.Name & ID_SEPARATOR & strParamTableName & ID_SEPARATOR & PriceList.Name _
                 & ID_SEPARATOR & RateSchedule.EffectiveDate.StartDate & ID_SEPARATOR & RateSchedule.EffectiveDate.StartDateType & ID_SEPARATOR & RateSchedule.EffectiveDate.StartOffset _
                 & ID_SEPARATOR & RateSchedule.EffectiveDate.EndDate & ID_SEPARATOR & RateSchedule.EffectiveDate.EndDateType & ID_SEPARATOR & RateSchedule.EffectiveDate.EndOffset
                 
    GetRateScheduleExtId = Replace(s, ",", COMMACODE)
End Function



Public Function ProcessXML(ByVal vNewValue As String) As String
    vNewValue = Replace(vNewValue, "&", "&amp;")
    vNewValue = Replace(vNewValue, ">", "&gt;")
    ProcessXML = Replace(vNewValue, "<", "&lt;")
End Function


Public Property Get MTObjectName(ByVal MTObject As Object) As String
    On Error Resume Next
    MTObjectName = MTObject.Name
    If Err.Number Then
        Err.Clear
    End If
End Property

' The function must return the MTObject
Public Function SetMTObjectName(ByVal MTObject As Object, ByVal strName As String) As Object
    MTObject.Name = strName
    Set SetMTObjectName = MTObject
End Function

Public Function GetSessionContext(strUserName As String, strPassWord As String, strNameSpace As String) As IMTSessionContext

    On Error GoTo ErrMgr
    Set GetSessionContext = CreateObject("Metratech.MTLoginContext").Login(strUserName, strNameSpace, strPassWord)
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1030, "USERNAME", strUserName, "NAMESPACE", strNameSpace) & " " & GetVBErrorString(), "MTPCImportExportModule", "GetSessionContext", LOG_ERROR
End Function



Public Function MakeIDsCollection(Rowset As IMTRowSet, strFieldName As String) As collection

'    Debug.Assert 0
    
    On Error GoTo ErrMgr
    
    Dim objIDS As collection
    
    Do While Not Rowset.EOF
        
        If Not IsValidObject(objIDS) Then Set objIDS = New collection
        objIDS.Add Rowset.Value(strFieldName)
        Rowset.MoveNext
    Loop
    Set MakeIDsCollection = objIDS
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), "MTPCImportExportModule", "MakeIDsCollection", LOG_ERROR
End Function


Public Function MTPCImportExportModule_Initialize()

    MTGlobal_VB_MSG.MTInitializeLogFileForPCImportExport
    
    EFFECTIVE_DATE_TYPE_STRINGS = Array("PCDATE_TYPE_NO_DATE", "PCDATE_TYPE_ABSOLUTE", "PCDATE_TYPE_SUBSCRIPTION_RELATIVE", "PCDATE_TYPE_NEXT_BILLING_PERIOD", "PCDATE_TYPE_NULL")
    MTUSAGECYCLETYPE_STRINGS = Array("NO_CYCLE", "MONTHLY_CYCLE", "ONDEMAND_CYCLE", "DAILY_CYCLE", "WEEKLY_CYCLE", "BIWEEKLY_CYCLE", "SEMIMONTHLY_CYCLE", "QUARTERLY_CYCLE", "ANNUALLY_CYCLE", "SEMIANNUALLY_CYCLE")
    static_strLanguage = "US"
    
    INFO PreProcess(MTPCImportExport_MESSAGE_1000, "NOW", Now(), "EXENAME", App.EXEName & ".dll"), "MTPCImportExportModule", "Class_Initialize"

End Function


Public Function GetCorporationList(ByVal strNameSpace As String, ByVal strDate As String, lngUserAccountID As Long, objAccountCatalog As MTYAACLib.MTAccountCatalog) As CVariables

    Dim objMTYAAC           As MTYAAC
    Dim Rowset              As MTYAACLib.IMTSQLRowset
    Dim CorporationList     As New CVariables
    Dim filter              As New RowsetLib.MTDataFilter
    Dim operatorType        As MTYAACLib.MTOperatorType
    Dim columns             As MTYAACLib.IMTCollection
    Dim out1                As Object
        
    On Error GoTo ErrMgr
    
    'If IsDate(strDate) Then
    '    Set objMTYAAC = objAccountCatalog.GetAccount(lngUserAccountID, CDate(strDate))
    'Else
    '    Set objMTYAAC = objAccountCatalog.GetAccount(lngUserAccountID)
    'End If

    'Set rowset = objMTYAAC.GetAncestorMgr.HierarchyRoot(CDate(strDate)).GetChildListAsRowset
    
    '======Fix for CR 13677========
    operatorType = OPERATOR_TYPE_EQUAL
    filter.Add "isCorporate", operatorType, True
        
    Set Rowset = objAccountCatalog.FindAccountsAsRowset(CDate(strDate), columns, filter, Nothing, Nothing, 100, out1, Nothing)
    
    Do While Not Rowset.EOF
        'Debug.Print ">" + Rowset.value("nm_login")
        
        If Len(strNameSpace) Then
        
            ' we store the namespace in the tag property
        
            If UCase$(Rowset.Value("name_space")) = UCase$(strNameSpace) Then
            
                CorporationList.Add Rowset.Value("username"), Rowset.Value("_AccountID"), , , Rowset.Value("username"), Rowset.Value("name_space")
            End If
        Else
            CorporationList.Add Rowset.Value("username"), Rowset.Value("_AccountID"), , , Rowset.Value("username"), Rowset.Value("name_space")
        End If
        Rowset.MoveNext
    Loop
    Set GetCorporationList = CorporationList
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), "MTPCImportExportModule", "GetCorporationList", LOG_ERROR
End Function


Public Function IsInfinity(datDate As String) As Boolean
    IsInfinity = CBool(CDate(datDate) = RCD.GetMaxDate())
End Function




Public Function ValidXML(strXMLFileName As String) As Boolean

    Dim objPP       As New CPreProcessor
    Dim objTextFile As New cTextFile
    Dim XMLDom As DOMDocument40
    
    On Error GoTo ErrMgr

    If Not objTextFile.ExistFile(strXMLFileName) Then
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1003, "FILENAME", strXMLFileName), "MTPCImportExportModule", "ImportProductOffering", LOG_ERROR
        Exit Function
    End If
    
    Set XMLDom = New DOMDocument40
    
    If XMLDom.Load(strXMLFileName) Then
        INFO PreProcess(MTPCImportExport_MESSAGE_1016, "FILE", strXMLFileName)
        ValidXML = True
    Else
        objPP.Add "FILENAME", strXMLFileName
        objPP.Add "ERROR", XMLDom.parseError.errorCode
        objPP.Add "FILEPOS", XMLDom.parseError.filepos
        objPP.Add "LINE", XMLDom.parseError.Line
        objPP.Add "LINEPOS", XMLDom.parseError.linepos
        objPP.Add "REASON", XMLDom.parseError.reason
        objPP.Add "TEXT", XMLDom.parseError.srcText
        
        MTPCImportExportModule.TRACE objPP.Process(MTPCImportExport_ERROR_1027), "MTPCImportExportModule", "ValidXML", LOG_ERROR
    End If
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), "MTPCImportExportModule", "ValidXML", LOG_ERROR
End Function


Public Function PrintConsoleAppInfo() As Boolean

    PrintConsole PreProcess(MTPCImportExport_MESSAGE_1017, "VERSION", GetPCImportExportVersion(), "CRLF", vbNewLine)
    PrintConsoleAppInfo = True
End Function



Public Function GetUserNameNameSpaceFromAccountID(ProductCatalog As MTProductCatalog, objAccountCatalog As MTYAACLib.MTAccountCatalog, ByVal lngAccountID As Long, ByRef strUserName As String, ByRef strNameSpace As String) As Boolean

    Dim objPCAccount        As MTPCAccount
    Dim objMTYAAC           As MTYAAC
    
    Set objPCAccount = ProductCatalog.GetAccount(lngAccountID)
    Set objMTYAAC = objAccountCatalog.GetAccount(lngAccountID)
    strUserName = objMTYAAC.LoginName
    strNameSpace = objMTYAAC.Namespace
    
    GetUserNameNameSpaceFromAccountID = True
    
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), "MTPCImportExportModule", "GetUserNameNameSpaceFromAccountID", LOG_ERROR
End Function


Public Function XMLOutPutRowset(ByVal strTagName As String, ByVal strRowTagName As String, r As Variant, ByVal strExcludeColumnAsID As String, strColumnNameForAttributeName1 As String, strColumnNameForAttributeName2 As String) As Boolean

On Error GoTo ErrMgr

    Dim i                       As Long
    Dim strAttributeNameValue   As String

    XMLOutPutTag strTagName, XMLTAGTYPE_OPEN
    
    Do While Not r.EOF
           
        strAttributeNameValue = ""
        
        If Len(strColumnNameForAttributeName1) Then
        
            strAttributeNameValue = r.Value(strColumnNameForAttributeName1)
            
            If Len(strColumnNameForAttributeName2) Then
            
                strAttributeNameValue = strAttributeNameValue & ":" & r.Value(strColumnNameForAttributeName2)
            End If
        End If
        
        XMLOutPutTag strRowTagName, XMLTAGTYPE_OPEN, strAttributeNameValue
                
        For i = 0 To r.Count - 1
        
            If InStr(strExcludeColumnAsID, UCase$(r.Name(CLng(i)))) And CBool(Len(strExcludeColumnAsID)) Then
                XMLOutPutTagValue r.Name(CLng(i)) & "_ID", r.Value(CLng(i)) ' End the property name with _ID so they will be ignored at import
            Else
                XMLOutPutTagValue r.Name(CLng(i)), r.Value(CLng(i))
            End If
        Next
        XMLOutPutTag strRowTagName, XMLTAGTYPE_CLOSE
        r.MoveNext
    Loop
    XMLOutPutTag strTagName, XMLTAGTYPE_CLOSE
    XMLOutPutRowset = True

Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), "MTPCImportExportModule", "XMLOutPutRowset", LOG_ERROR
End Function


'Public Function GetUDRCTypeID(ProductCatalog As MTProductCatalog) As Long

'    Dim objType As Variant
'
'    Static UDRCTypeID As Long
'
'    If UDRCTypeID > 0 Then
'        GetUDRCTypeID = UDRCTypeID
'        Exit Function
'    End If
    
'    For Each objType In ProductCatalog.GetPriceableItemTypes()
    
'        If UCase(objType.Name) = UCase(UDRC_TYPE_NAME) Then
    
'            UDRCTypeID = objType.ID
'            GetUDRCTypeID = objType.ID
'            Exit Function
'        End If
'    Next
'Exit Function
'ErrMgr:
'    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), "MTPCImportExportModule", "GetUDRCTypeID", LOG_ERROR
'End Function

Public Function IsAPriceAbleItem(ByVal o As Object) As Boolean

    Dim p As MTPriceableItem
    On Error Resume Next
    Set p = o
    IsAPriceAbleItem = Err.Number = 0
    Err.Clear
End Function
Public Function GetObjectFromMTCollection(objCol As IMTCollection, strName As String) As Object
    Dim o As Variant
    For Each o In objCol
        If UCase$(o.Name) = UCase$(strName) Then
            Set GetObjectFromMTCollection = o
            Exit Function
        End If
    Next
End Function


Public Function CheckFileName(ByVal strFileName As String) As String
    strFileName = Replace(strFileName, ":", "_")
    strFileName = Replace(strFileName, "\", "_")
    strFileName = Replace(strFileName, "/", "_")
    strFileName = Replace(strFileName, "<", "_")
    strFileName = Replace(strFileName, ">", "_")
    strFileName = Replace(strFileName, "*", "_")
    strFileName = Replace(strFileName, "?", "_")
    strFileName = Replace(strFileName, "|", "_")
    CheckFileName = strFileName
End Function



Public Function TraceCommandLineInSafeWay(strCommandLine As String) As Boolean

    Dim objCommandLine  As New CCommandLine
    Dim s               As String
    Dim i               As Long
    
    objCommandLine.Init strCommandLine
    
    i = 1
    Do While i <= objCommandLine.Count
        If UCase$(objCommandLine.Item(i)) = "-PASSWORD" Then
            i = i + 1
        Else
            s = s & objCommandLine.Item(i) & " "
        End If
        i = i + 1
    Loop
    s = Trim(s)
    MTGlobal_VB_MSG.TRACE s, , , LOG_INFO

'    MTPCImportExportModule.TRACE "CommandLine:" & s, , , LOG_INFO
    TraceCommandLineInSafeWay = True
End Function



' IN 3.7 this function is no more used
' we used the dom to save the file and convert unicode into utf8
Public Function TO_UTF8(ByVal strText As String) As String

    Dim strUTF8 As String
    
    strUTF8 = strText
    
    'strUTF8 = static_UTF8Instance.StringToUTF8(strText)
    
'    TRACE "TO_UTF8:strText={" & strText & "}strUTF8={" & strUTF8 & "}", "MTPCImportExportModule", "TO_UTF8", LOG_DEBUG
    
    TO_UTF8 = strUTF8
    
End Function

Public Function INTERNAL_TRACE(ByVal strText As String, Optional ByVal Module As Variant, Optional ByVal strFunctionName As String, Optional ByVal enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_DEBUG) As Boolean

    INTERNAL_TRACE = TRACE("[INTERNALTRACE]" & strText, Module, strFunctionName, LOG_DEBUG)
    'Dim t As New cTextFile
    't.LogFile "c:\MTPCImportExport.internal.log", Now() & " " & strText
    
End Function



' In 3.6 I have noticed a bug when reporting error via rowset
' I create this wrapper method so at least I can log a better error message
Public Function CallRecordCount(o As Object, strDescription As String) As Long

    On Error GoTo ErrMgr
    Dim e As New CError
    CallRecordCount = o.RecordCount
    Exit Function
ErrMgr:
    e.Save Err.Number, Err.Description, Err.Source, strDescription
    MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1045, "DESCRIPTION", strDescription) & ".VBRunTimeError:" & e.ToString(), "MTPCImportExportModule", "CallRecordCount", LOG_ERROR
End Function

Public Function GetRMPIsHierarchyRestrictedOperations(Optional ByVal PC As MTProductCatalog) As Boolean

    If Not IsValidObject(PC) Then
    
        Set PC = CreateObject("MetraTech.MTProductCatalog")
    End If
        
    GetRMPIsHierarchyRestrictedOperations = PC.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations)
    
End Function

Public Function ExportCollection(ByVal CollectionProperty As MTProperty) As Boolean

    On Error GoTo ErrMgr
    Dim proptype
    proptype = "Collection"
    
    Dim coll_item As Variant
    
    If CollectionProperty.Value Is Nothing Then
        ExportCollection = True
        Exit Function
    End If
    
    ' XMLOutPutTag proptype & "name='" & CollectionProperty.Name & "'"
    
    XMLOutPutTag proptype, XMLTAGTYPE_OPEN, CollectionProperty.Name
    
    For Each coll_item In CollectionProperty.Value
      Dim strprop As String
      
      strprop = coll_item
      XMLOutPutCollectionItem strprop
    Next
    XMLOutPutTag proptype, XMLTAGTYPE_CLOSE
    ExportCollection = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), "ExportCollection", LOG_ERROR
End Function

