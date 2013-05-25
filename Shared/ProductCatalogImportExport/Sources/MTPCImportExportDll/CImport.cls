VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 2  'RequiresTransaction
END
Attribute VB_Name = "CImportWriter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

' -ipo -file "C:\Development\Japanese Audio Conferencing Product Offering.xml" -username su -password su123

' added in 4.0
Private m_CachedPriceableItemID As New CVariables   ' used for import group sub to cache the priceable item instance
                                                    ' the key of the collection is the PO name + the PIi Name we store only the PIi id

Private m_CachedParamTableID As New CVariables      ' same as below for parameter table

' 3.6 bug :10652


#Const ImportGroupSubscriptions_OPTIMIZE_FOR_SPEED = True

Private Const SUBSCRIBE_ACCOUNT_ALREADY_SUBSCRIBER_MT_ERROR As Long = -289472485

Public Enum IMPORT_EXPORT_MODE
    IMPORT_EXPORT_MODE_DEFAULT_MODE = 1 ' default mode
    IMPORT_EXPORT_MODE_SAFE_MODE = 2
    IMPORT_EXPORT_MODE_OVERWRITE_MODE = 4 ' Should not be implemented in 3.5
    IMPORT_EXPORT_MODE_COM_PLUS = 8
    IMPORT_EXPORT_UNIT_TEST_ROLLBACK = 16
    IMPORT_EXPORT_MULTI_FILE = 32
    IMPORT_EXPORT_VERBOSE = 64
    IMPORT_EXPORT_SKIP_INTEGRITY = 128
End Enum

Private m_objSessionContext         As IMTSessionContext
Private m_strFirstPriceList         As String
Private m_strCurrentProductOffering As String
Private m_objAdjustmentCatalog      As MetraTech_Adjustments.AdjustmentCatalog
Private m_objMTProductCatalog       As MTProductCatalog
Private m_objMTSecurity             As Object
Private m_enmImportMode             As IMPORT_EXPORT_MODE
Private m_objParamTableIntegrity    As CParamTableChks
Private m_Stats                     As CImportExportStats
Private m_objCommandLine            As CCommandLine
Private m_lngTime                   As Long
Private m_objEnumConfig             As MTENUMCONFIGLib.EnumConfig ' Force to hold a ref during the all import to keep the data in memory
Private m_objSupportedLanguageCodes As CVariables

Private m_objAvoidComPlusFifteenSecondDelayRowset As Object

Public Function ImportProductOffering(ByVal strXMLFileName As String, ByVal eImportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String, ByVal strAuthUserName As String, strAuthPassWord As String, strAuthNameSpace As String) As Boolean
    
    On Error GoTo ErrMgr
    
    'Dim Profiler                As New CProfiler: Profiler.Start True, TypeName(Me), "ImportProductOffering"
    Dim ProductOffering         As MTProductOffering
    Dim objXMLProductOfferings  As IXMLDOMNodeList
    Dim objXMLProductOffering   As IXMLDOMNode
    Dim strPOName               As String
    Dim strPropertyBagFile      As String
    Dim objPropertyBag          As New cIniFile
    Dim lngPOCounter            As Long
    Dim lngProductOfferingIndex As Long
    Dim booImportPriceAbleItemOnly As Boolean
    Dim strCurrencyCode         As String
    Dim lngPrivatePriceListID   As Long
       
    If Not ImportInit(strXMLFileName, eImportMode, strCommandLine) Then Exit Function
    
    Set m_objSessionContext = GetSessionContext(strAuthUserName, strAuthPassWord, strAuthNameSpace)
    If Not IsValidObject(m_objSessionContext) Then Exit Function
    
    ProductCatalog.SetSessionContext m_objSessionContext

    'PrintConsole vbNewLine & PreProcess(MTPCImportExport_MESSAGE_1004, "FILE", strXMLFileName)
    Debug.Assert 0
    
    INFO PreProcess(MTPCImportExport_MESSAGE_1004, "FILE", strXMLFileName)
    
    If Not XMLInputInitialize(strXMLFileName) Then Exit Function
    
    Set objXMLProductOfferings = XMLDom.selectNodes("xmlconfig/productofferings/productoffering")
    
    For Each objXMLProductOffering In objXMLProductOfferings
       
        booImportPriceAbleItemOnly = False
        If IsValidObject(objXMLProductOffering.selectSingleNode("exportpriceableiteminstanceonly")) Then ' Check first if the tag exist so we keep compatibility with 3.0 xml file
            booImportPriceAbleItemOnly = objXMLProductOffering.selectSingleNode("exportpriceableiteminstanceonly").Text
        End If
        
        lngPOCounter = lngPOCounter + 1
    
        strPOName = objXMLProductOffering.Attributes.getNamedItem("name").Text
                
        m_strCurrentProductOffering = strPOName
        PrintConsole vbNewLine & "Import Product Offering " & strPOName

        ' Create a PO, set its name and update the stats
        Set ProductOffering = m_Stats.AddNewObject(SetMTObjectName(ProductCatalog.CreateProductOffering(), strPOName))
        
        If IsValidObject(objXMLProductOffering.selectSingleNode("currency")) Then
            strCurrencyCode = objXMLProductOffering.selectSingleNode("currency").Text
        Else
            If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1024, "PO", strPOName)) Then Exit Function
            strCurrencyCode = "USD"
        End If
        
        ProductOffering.SetCurrencyCode strCurrencyCode

        If Not ImportMTProperty(ProductOffering, objXMLProductOffering, , ",NONSHAREDPRICELISTID,AVAILABILITYDATE,") Then GoTo RollBackAndExit  ' Set the Product offering property without the AVAILABILITYDATE
        
        If Not ImportDisplayNamesIfExist(objXMLProductOffering, ProductOffering) Then Exit Function
        If Not ImportDisplayDescriptionsIfExist(objXMLProductOffering, ProductOffering) Then Exit Function
        
        If Not ImportCollectionProperties(objXMLProductOffering, ProductOffering) Then Exit Function
        
        'call new funtion
        
        ProductOffering.Save ' Force to save the PO to create the private price list
        
        ImportSpecificationCharacteristicForPO ProductOffering.ID, objXMLProductOffering, strAuthUserName, strAuthPassWord, strAuthNameSpace
                
        lngPrivatePriceListID = ProductOffering.NonSharedPriceListID
        
        If Not booImportPriceAbleItemOnly Then
        
            If Not ImportPriceAbleItemTemplateForProductOffering(ProductOffering, objXMLProductOffering) Then GoTo RollBackAndExit
            If Not ImportPriceListForProductOffering(objXMLProductOffering, lngPrivatePriceListID, ProductOffering) Then GoTo RollBackAndExit
            If Not ImportCalendar(objXMLProductOffering) Then GoTo RollBackAndExit
            If Not ImportRateScheduleForProductOffering("rateschedules", ProductOffering, objXMLProductOffering) Then GoTo RollBackAndExit
        End If
        
        If Not ImportPriceAbleItemInstanceForProductOffering(ProductOffering, objXMLProductOffering) Then GoTo RollBackAndExit
        
        If Not ImportMTProperty(ProductOffering, objXMLProductOffering, , ",NONSHAREDPRICELISTID,") Then GoTo RollBackAndExit ' Set the Product offering property with the AVAILABILITYDATE
        
        
        
        INFOOBJECT ProductOffering, "Saving "
        ProductOffering.Save
        INFO PreProcess(MTPCImportExport_MESSAGE_1001, "PRODUCTOFFERING", ProductOffering.Name, "POID", ProductOffering.ID)
        
        '
        ' -- For QA only - Read information to update the property bag at the end of the import
        '-PropertyBag "c:\temp\pcexport\PropertyBag.txt"  -ProductOfferingIndex 1 -SetCurrency -SetDefaultPriceList
        '
        '[BAG]
        'DefaultPricelistName = USAGE_Simple_DPL10275335
        'Currency=USD
        'ProductOffering.ID(1) = 105
        'ProductOffering.Name(1) = USAGE_Simple_PO10275335
        '
        
'        Debug.Assert 0
        
        If m_objCommandLine.Exist("-propertybag") Then

            strPropertyBagFile = m_objCommandLine.getValue("-propertybag")


            INFO "strPropertyBagFile=" & strPropertyBagFile
            
            lngProductOfferingIndex = lngPOCounter + CLng(m_objCommandLine.getValue("-ProductOfferingIndex", 1)) - 1

            objPropertyBag.Init strPropertyBagFile
            objPropertyBag.SetVar "BAG", "ProductOffering.ID(" & lngProductOfferingIndex & ")", ProductOffering.ID
            objPropertyBag.SetVar "BAG", "ProductOffering.Name(" & lngProductOfferingIndex & ")", ProductOffering.Name

            If m_objCommandLine.Exist("-SetCurrency") Then objPropertyBag.SetVar "BAG", "currency", "USD"
            If m_objCommandLine.Exist("-SetDefaultPriceList") Then objPropertyBag.SetVar "BAG", "DefaultPricelistName", m_strFirstPriceList
       End If
    Next
    
    ' UNIT TEST SPECIAL MODE
    If eImportMode And IMPORT_EXPORT_UNIT_TEST_ROLLBACK Then
        GoTo RollBackAndExit
    End If
    
    If Not ImportTerminate() Then Exit Function
    
    ImportProductOffering = True
TheExit:
    Exit Function
    
RollBackAndExit:
    TransactionAbort
    GoTo TheExit

ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ProductOffering", LOG_ERROR
    TransactionAbort
End Function

' DisplayNames Support 3.6
Public Function ImportDisplayNamesIfExist(objXMLObjectNode As IXMLDOMNode, PCCatalogObject As Object) As Boolean

    On Error GoTo ErrMgr
    
    Debug.Print "ImportDisplayNamesIfExist:" & TypeName(PCCatalogObject)
    
    If IsValidObject(objXMLObjectNode.selectSingleNode("displaynames")) Then
    
        If Not ImportDisplayNames(PCCatalogObject, PCCatalogObject.DisplayNames, objXMLObjectNode.selectSingleNode("displaynames")) Then Exit Function
    Else
    
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_MESSAGE_1019, "OBJECT_NAME", PCCatalogObject.Name), Me, "ImportProductOffering", LOG_INFO
    End If
    ImportDisplayNamesIfExist = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportDisplayNamesIfExist", LOG_ERROR
End Function

Public Function ImportUnitDisplayNamesIfExist(objXMLObjectNode As IXMLDOMNode, PCCatalogObject As Object) As Boolean

    On Error GoTo ErrMgr
    
    Debug.Print "ImportUnitDisplayNamesIfExist:" & TypeName(PCCatalogObject)
    
    If IsValidObject(objXMLObjectNode.selectSingleNode("unitdisplaynames")) Then
    
        If Not ImportDisplayNames(PCCatalogObject, PCCatalogObject.UnitDisplayNames, objXMLObjectNode.selectSingleNode("unitdisplaynames")) Then Exit Function
    Else
    
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_MESSAGE_1019, "OBJECT_NAME", PCCatalogObject.Name), Me, "ImportProductOffering", LOG_INFO
    End If
    ImportUnitDisplayNamesIfExist = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportUnitDisplayNamesIfExist", LOG_ERROR
End Function
Public Function ImportDisplayDescriptionsIfExist(objXMLObjectNode As IXMLDOMNode, PCCatalogObject As Object) As Boolean

    On Error GoTo ErrMgr
    
    Debug.Print "ImportDisplayDescriptionsIfExist:" & TypeName(PCCatalogObject)
    
    If IsValidObject(objXMLObjectNode.selectSingleNode("displaydescriptions")) Then
    
        If Not ImportDisplayNames(PCCatalogObject, PCCatalogObject.DisplayDescriptions, objXMLObjectNode.selectSingleNode("displaydescriptions")) Then Exit Function
    Else
    
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_MESSAGE_1019, "OBJECT_NAME", PCCatalogObject.Name), Me, "ImportProductOffering", LOG_INFO
    End If
    ImportDisplayDescriptionsIfExist = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportDisplayDescriptionsIfExist", LOG_ERROR
End Function
Private Function ImportDisplayNames(PCObject As Object, LocalizedEntity As Object, XMLDisplayNameNode As IXMLDOMNode) As Boolean

    On Error GoTo ErrMgr
    
    Dim XMLLanguageNode As IXMLDOMNode
    Dim strLanguage     As String
    Dim strValue        As String
    Dim strObjectType   As String
    Dim strObjectName   As String
    
    InitRMPSupportedLanguageList LocalizedEntity
    
    
    strObjectType = TypeName(PCObject)
    strObjectName = MTObjectName(PCObject)
    
    For Each XMLLanguageNode In XMLDisplayNameNode.selectNodes("language")
    
        strLanguage = XMLLanguageNode.Attributes.getNamedItem("name").Text
        strValue = XMLLanguageNode.Text
        
'        Debug.Assert 0
        
        If m_objSupportedLanguageCodes.Exist(strLanguage) Then

            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_MESSAGE_1018, "OBJECTTYPE", strObjectType, "NAME", strObjectName, "LANGUAGE", strLanguage, "VALUE", strValue), Me, "ImportDisplayNames", LOG_DEBUG
            LocalizedEntity.Setmapping strLanguage, strValue
        Else
        
            If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1023, "LANGUAGE", strLanguage)) Then Exit Function
        End If
    Next
    ImportDisplayNames = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportDisplayNames", LOG_ERROR
End Function



Private Function TransactionLogInfo() As Boolean

    On Error GoTo ErrMgr
    
    If m_enmImportMode And IMPORT_EXPORT_MODE_COM_PLUS Then
    
        If IsValidObject(GetObjectContext()) Then
            
            MTPCImportExportModule.TRACE "-- TRANSACTION INFO --", , , LOG_INFO, False
            MTPCImportExportModule.TRACE "PCImportExportSessionGUID=" & SessionGUID, , , LOG_INFO, False
            MTPCImportExportModule.TRACE "GetObjectContext() found", , , LOG_INFO, False
            MTPCImportExportModule.TRACE "GetObjectContext().IsInTransaction=" & GetObjectContext().IsInTransaction, , , LOG_INFO, False
        Else
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1013), Me, "TransactionInit", LOG_ERROR
            Exit Function
        End If
    End If
    TransactionLogInfo = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "TransactionLogInfo", LOG_ERROR
End Function



Public Function TransactionInit() As Boolean

    On Error GoTo ErrMgr

    If m_enmImportMode And IMPORT_EXPORT_MODE_COM_PLUS Then
        TransactionInit = TransactionLogInfo()
    Else
        If RaiseWarningAndCancel(MTPCImportExport_SEVERE_WARNING_1009) Then Exit Function
        TransactionInit = True
    End If
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "TransactionInit", LOG_ERROR
End Function

Public Function TransactionComplete() As Boolean

    On Error GoTo ErrMgr
    
    If m_enmImportMode And IMPORT_EXPORT_MODE_COM_PLUS Then
    
        INFO "About to complete transaction. PCImportExportSessionGUID=" & SessionGUID
        GetObjectContext().SetComplete
        INFO "Database Transactions Completed. PCImportExportSessionGUID=" & SessionGUID
    End If
    TransactionComplete = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "TransactionComplete", LOG_ERROR
End Function

Public Function TransactionAbort() As Boolean

    On Error GoTo ErrMgr
    
    If m_enmImportMode And IMPORT_EXPORT_MODE_COM_PLUS Then
        INFO "About to Abort Database Transactions. PCImportExportSessionGUID=" & SessionGUID
        GetObjectContext().SetAbort
        INFO "Database Transactions Aborted. PCImportExportSessionGUID=" & SessionGUID
    End If
    TransactionAbort = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "TransactionAbort", LOG_ERROR
End Function

' This is duplicate code.  The other copy is in the CExport Class Module.
'
' The code in CExport should be kept in sync with this code.
Public Property Get ProductCatalog() As MTProductCatalog

    If Not IsValidObject(m_objMTProductCatalog) Then
        Set m_objMTProductCatalog = CreateObject("MetraTech.MTProductCatalog")
    End If

    If Not IsValidObject(m_objMTSecurity) Then
        ' This is here to fix CR 11336.  If this were not here then the MTSecurity
        ' object would be created and released many times over (creating the MTSecurity
        ' object (which is a singleton) is very costly).
        Set m_objMTSecurity = CreateObject("Metratech.MTSecurity")
    End If

    Set ProductCatalog = m_objMTProductCatalog

End Property

Public Function PriceList(ByVal strXMLFileName As String) As Boolean
    
'    On Error GoTo ErrMgr
'
'    Dim Reader As New SAXXMLReader                        ' This one will do the work
'    Dim ContentHandler  As New CSaxParserPriceList
'    Dim ErrorHandler    As New CSaxParserError
'
'    Set Reader.ContentHandler = ContentHandler      ' And they should work together
''    Set Reader.ErrorHandler = ErrorHandler          ' the same here
'
''     Debug.Assert 0
'    Reader.parseURL strXMLFileName
    
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "PriceList", LOG_ERROR
End Function


Private Function ImportPriceAbleItemTemplateForProductOffering(ProductOffering As MTProductOffering, XMLNode As IXMLDOMNode) As Boolean

    Dim XMLPriceAbleItemTemplates  As IXMLDOMNodeList
    Dim XMLPriceAbleItemTemplate   As IXMLDOMNode
    Dim PriceAbleItemType          As MTPriceableItemType
    Dim XMLPriceAbleItemType       As IXMLDOMNode
    Dim strPriceAbleItemTypeName   As String
    Dim PCEntityType               As MTPCEntityType
    Dim PriceAbleItemTemplate      As MTPriceableItem
    Dim strName                    As String
    Dim XMLCounter                 As IXMLDOMNode
    Dim strTypeName                As String
    'Dim Profiler                   As New CProfiler: Profiler.Start True, TypeName(Me), "ImportPriceAbleItemTemplateForProductOffering"
    
    On Error GoTo ErrMgr
    
'    Debug.Assert 0
        
    PrintConsole vbNewLine & "Import PriceAbleItem Templates"
    
    Set XMLPriceAbleItemTemplates = XMLNode.selectSingleNode("priceableitemtemplates").childNodes
    
    For Each XMLPriceAbleItemTemplate In XMLPriceAbleItemTemplates
    
        If XMLPriceAbleItemTemplate.nodeType <> NODE_COMMENT Then
            
            strName = XMLPriceAbleItemTemplate.Attributes.getNamedItem("name").Text
            
            ' Get
            Set XMLPriceAbleItemType = XMLPriceAbleItemTemplate.selectSingleNode("priceableitemtype")
            
            strTypeName = XMLPriceAbleItemType.Attributes.getNamedItem("name").Text
            Set PriceAbleItemType = ProductCatalog.GetPriceableItemTypeByName(strTypeName)
            
            If IsValidObject(PriceAbleItemType) Then
            
                PCEntityType = PriceAbleItemType.Kind
                
                Select Case PCEntityType
                
                    Case PCENTITY_TYPE_AGGREGATE_CHARGE, PCENTITY_TYPE_USAGE
                    
                        ' we do not create the template for this kind of type
                    Case Else
                    
                        If IsValidObject(m_Stats.AddReUsedObject(ProductCatalog.GetPriceableItemByName(strName))) Then
                            
                            If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1003, "PRICEABLEITEMTEMPLATE", strName), Me, "ImportPriceAbleItemTemplateForProductOffering") Then Exit Function
                        Else
                        
                            Set PriceAbleItemTemplate = m_Stats.AddNewObject(PriceAbleItemType.CreateTemplate())
                            PriceAbleItemTemplate.Name = strName
                            If Not ImportMTProperty(PriceAbleItemTemplate, XMLPriceAbleItemTemplate) Then Exit Function
                            
                            INFOOBJECT PriceAbleItemTemplate, "Import "
                            
'                            Debug.Assert 0
                            If Not ImportAdjustmentsTemplate(XMLPriceAbleItemTemplate, PriceAbleItemTemplate) Then Exit Function
                            
                            If Not ImportDisplayNamesIfExist(XMLPriceAbleItemTemplate, PriceAbleItemTemplate) Then Exit Function

                            PriceAbleItemTemplate.Save
                            
                            If PCEntityType = PCENTITY_TYPE_DISCOUNT Then
                                ImportCounterForProductOffering PriceAbleItemTemplate, XMLPriceAbleItemTemplate
                            End If
                        End If
                End Select
            Else
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1009, "PRICEABLEITEMTYPE", strTypeName, "PRODUCTOFFERING", ProductOffering.Name), Me, "ImportPriceAbleItemTemplateForProductOffering", LOG_ERROR
                Exit Function
            End If
        End If
    Next
    ImportPriceAbleItemTemplateForProductOffering = True
    
Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportPriceAbleItemTemplateForProductOffering", LOG_ERROR
End Function

Private Function ImportAdjustmentsTemplate(XMLPriceAbleItemTemplate As IXMLDOMNode, PriceAbleItemTemplate As MTPriceableItem) As Boolean

On Error GoTo ErrMgr

    Dim XMLAdjustments          As IXMLDOMNodeList
    Dim XMLAdjustment           As IXMLDOMNode
    Dim XMLAdjustmentType       As IXMLDOMNode
    Dim strAdjustmentName       As String
    Dim strAdjustmentTypeName   As String
    Dim objAdjustment           As Adjustment
    Dim objAdjustmentType       As AdjustmentType
    
'    Debug.Assert 0
    '
    ' Accept that there is no <adjustments> tag for compatibility issues
    '
    If IsValidObject(XMLPriceAbleItemTemplate.selectSingleNode("adjustments")) Then
        
        Set XMLAdjustments = XMLPriceAbleItemTemplate.selectSingleNode("adjustments").childNodes
        
        For Each XMLAdjustment In XMLAdjustments
        
            Set XMLAdjustmentType = XMLAdjustment.selectSingleNode("adjustmenttype")
            strAdjustmentTypeName = XMLAdjustmentType.Attributes.getNamedItem("name").Text
            
            Set objAdjustmentType = AdjustmentCatalog.GetAdjustmentTypeByName(strAdjustmentTypeName)
            
            If Not IsValidObject(objAdjustmentType) Then
    
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1039, "NAME", strAdjustmentTypeName), Me, "ImportAdjustmentsTemplate", LOG_ERROR
                Exit Function
            End If
            
            strAdjustmentName = XMLAdjustment.Attributes.getNamedItem("name").Text
            Set objAdjustment = m_Stats.AddNewObject(SetMTObjectName(PriceAbleItemTemplate.CreateAdjustment(objAdjustmentType.ID), strAdjustmentName))
            
            If Not ImportDisplayNamesIfExist(XMLAdjustment, objAdjustment) Then Exit Function
            
            INFOOBJECT objAdjustment, "Import "
            
            If Not ImportMTProperty(objAdjustment, XMLAdjustment) Then Exit Function
            If Not ImportReasonCodes(XMLAdjustment, objAdjustment) Then Exit Function
        Next
        PrintConsole vbNewLine
    Else
        ' This warning does not stop the execution in case of safe mode
        ' this is just a compatibility warning with old XML file from PCImportExport 3.0 and 3.0.1
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_WARNING_1018, "PI_NAME", PriceAbleItemTemplate.Name), Me, "ImportAdjustmentsTemplate", LOG_WARNING
    End If
    ImportAdjustmentsTemplate = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportAdjustmentsTemplate", LOG_ERROR
End Function

Private Function ImportReasonCodes(XMLAdjustment As IXMLDOMNode, objAdjustment As Adjustment) As Boolean

    On Error GoTo ErrMgr

    Dim XMLReasonCodes          As IXMLDOMNodeList
    Dim XMLReasonCode           As IXMLDOMNode
    Dim strReasonCodeName       As String
    Dim objReasonCode           As ReasonCode
    
    Set XMLReasonCodes = XMLAdjustment.selectSingleNode("reasoncodes").childNodes
    
    For Each XMLReasonCode In XMLReasonCodes
    
        strReasonCodeName = XMLReasonCode.Attributes.getNamedItem("name").Text
        
        On Error Resume Next
        Set objReasonCode = Nothing
        Set objReasonCode = AdjustmentCatalog.GetReasonCodeByName(strReasonCodeName)
        Err.Clear
        On Error GoTo ErrMgr
        
        If IsValidObject(m_Stats.AddReUsedObject(objReasonCode)) Then
            If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1017, "NAME", strReasonCodeName), Me, "ImportReasonCodes") Then Exit Function
        Else
        
            Set objReasonCode = AdjustmentCatalog.CreateReasonCode()
            m_Stats.AddNewObject SetMTObjectName(objReasonCode, strReasonCodeName)
            If Not ImportMTProperty(objReasonCode, XMLReasonCode) Then Exit Function

            If Not ImportDisplayNamesIfExist(XMLReasonCode, objReasonCode) Then Exit Function
            
            objReasonCode.Save
        End If
        objAdjustment.AddExistingReasonCode objReasonCode
    Next
    ImportReasonCodes = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportReasonCodes", LOG_ERROR
End Function


Private Function ImportCounterForProductOffering(PriceAbleItem As MTPriceableItem, XMLNode As IXMLDOMNode) As Boolean

    On Error GoTo ErrMgr

    Dim XMLCounters                 As IXMLDOMNodeList
    Dim XMLCounter                  As IXMLDOMNode
    Dim XMLTmpNode                  As IXMLDOMNode
    Dim strName                     As String
    Dim strTypeName                 As String
    Dim CounterType                 As MTCounterType
    Dim Counter                     As MTCounter
    Dim XMLCounterParameters        As IXMLDOMNodeList
    Dim XMLCounterParameter         As IXMLDOMNode
    Dim CounterPropertyDefinition   As MTCounterPropertyDefinition
    Dim strCounterPropertyDefinitionName As String
    Dim strParameterName            As String
    Dim strParameterValue           As String
    Dim booIsGroupDiscountDistribution  As Boolean
        
'    Debug.Assert 0
    
    Set XMLCounters = XMLNode.selectSingleNode("counters").childNodes
    
    For Each XMLCounter In XMLCounters
    
        ' Support the case where the counter has no name
        If IsValidObject(XMLCounter.Attributes.getNamedItem("name")) Then
    
            strName = XMLCounter.Attributes.getNamedItem("name").Text
        Else
            If RaiseWarningAndCancel(PreProcess(MTPCImportExport_SEVERE_WARNING_1007, "PRICEABLEITEM", PriceAbleItem.Name), Me, "ImportCounterForProductOffering") Then Exit Function
            strName = "Name generated by the import " & Timer()
        End If
        
        strTypeName = XMLCounter.selectSingleNode("countertypename").Text
        
        If IsValidObject(XMLCounter.selectSingleNode("isgroupdiscountdistribution")) Then
        
            booIsGroupDiscountDistribution = CBool(XMLCounter.selectSingleNode("isgroupdiscountdistribution").Text)
        End If
        
        Set CounterType = ProductCatalog.GetCounterTypeByName(strTypeName)

        Set Counter = m_Stats.AddNewObject(SetMTObjectName(CounterType.CreateCounter(), strName))
        
        If Not ImportMTProperty(Counter, XMLCounter) Then Exit Function
        
        Set XMLCounterParameters = XMLCounter.selectSingleNode("counterparameters").selectNodes("counterparameter")
        
        For Each XMLCounterParameter In XMLCounterParameters
        
            strParameterName = XMLCounterParameter.Attributes.getNamedItem("name").Text
            
            strParameterValue = XMLCounterParameter.selectSingleNode("property[@name='Value']").Text
            
            #If BUILD301 Then
            
                Counter.SetParameter strParameterName, strParameterValue
            #Else
                ' 3.5
                Counter.GetParameter(strParameterName).Value = strParameterValue
            #End If
        Next
        
        strCounterPropertyDefinitionName = UCase$(XMLCounter.selectSingleNode("counterpropertydefinition").Attributes.getNamedItem("name").Text)
        
        For Each CounterPropertyDefinition In PriceAbleItem.PriceAbleItemType.GetCounterPropertyDefinitions
        
            If UCase$(CounterPropertyDefinition.Name) = strCounterPropertyDefinitionName Then
            
                PriceAbleItem.SetCounter CounterPropertyDefinition.ID, Counter
                Exit For
            End If
        Next
        
        If booIsGroupDiscountDistribution Then
            
            Debug.Assert 0
            
            Dim d As MTDiscount
            Set d = PriceAbleItem
            d.SetDistributionCounter Counter
        End If
    Next
    PriceAbleItem.Save
    ImportCounterForProductOffering = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportCounterForProductOffering", LOG_ERROR
End Function


Private Function ImportPriceListForProductOffering(XMLNode As IXMLDOMNode, lngPrivatePriceListID As Long, ProductOffering As MTProductOffering) As Boolean

    On Error GoTo ErrMgr

    Dim XMLPriceLists               As IXMLDOMNodeList
    Dim XMLPriceList                As IXMLDOMNode
    Dim PriceList                   As MTPriceList
    Dim PriceAbleItemType           As MTPriceableItemType
    Dim XMLPriceAbleItemType        As IXMLDOMNode
    Dim strPriceAbleItemTypeName    As String
    Dim strName                     As String
    Dim lngIndex                    As Long
    Dim booPrivatePriceList         As Boolean
    Dim strPOName                   As String
    
    
    If IsValidObject(ProductOffering) Then strPOName = ProductOffering.Name
    
    PrintConsole vbNewLine & "Import Price Lists"
    
    Set XMLPriceLists = XMLNode.selectSingleNode("pricelists").childNodes
    
    For Each XMLPriceList In XMLPriceLists
    
        lngIndex = lngIndex + 1
    
        strName = XMLPriceList.Attributes.getNamedItem("name").Text
        
        If (IsValidObject(XMLPriceList.Attributes.getNamedItem("private"))) Then
            booPrivatePriceList = LCase$(XMLPriceList.Attributes.getNamedItem("private").Text) = "true"
        Else
            booPrivatePriceList = False
        End If
                        
        If lngIndex = 1 Then m_strFirstPriceList = strName ' save the first price list for later for QA
                
        
        If IsValidObject(m_Stats.AddReUsedObject(ProductCatalog.GetPriceListByName(strName))) Then ' A private price list should not exist
        
            If booPrivatePriceList Then
                Set PriceList = m_Stats.AddNewObject(Me.ProductCatalog.GetPriceList(lngPrivatePriceListID)) ' Get the price list
                'INFO "Private price list found. PriceList.Name=" & PriceList.Name
            Else
                If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1004, "PRICELIST", strName), Me, "ImportPriceListForProductOffering") Then Exit Function
            End If
        Else
            If booPrivatePriceList Then ' this case can happen when people manually change the name of the po and forget to change the name of the private price list

                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1047, "PO", strPOName, "PL", strName), Me, "ImportPriceListForProductOffering", LOG_ERROR
            Else
                Set PriceList = m_Stats.AddNewObject(SetMTObjectName(ProductCatalog.CreatePriceList(), strName)) ' Create a price list, set its name and update the stats
                If Not ImportMTProperty(PriceList, XMLPriceList) Then Exit Function
                INFOOBJECT PriceList, "Import "
                PriceList.Save
            End If
        End If
    Next
    ImportPriceListForProductOffering = True
Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportPriceListForProductOffering", LOG_ERROR
End Function


Private Function ImportRateScheduleForProductOffering(strRateSchedulesXPath As String, ProductOffering As MTProductOffering, XMLNode As IXMLDOMNode, Optional ByVal booImportPriceList As Boolean) As Boolean

    On Error GoTo ErrMgr

    Dim XMLRateSchedules            As IXMLDOMNodeList
    Dim XMLRateSchedule             As IXMLDOMNode
    Dim XMLPCTimeSpan               As IXMLDOMNode
    Dim PriceAbleItemType           As MTPriceableItemType
    Dim XMLPriceAbleItemType        As IXMLDOMNode
    Dim strPriceAbleItemTypeName    As String
    Dim PCEntityType                As MTPCEntityType
    Dim RateSchedule                As MTRateSchedule
    Dim ParamTable                  As MTParamTableDefinition
    Dim PriceList                   As MTPriceList
    Dim PriceAbleItemTemplate       As MTPriceableItem
    Dim strName                     As String
    Dim strXMLRuleSet               As String
    Dim strRateScheduleID           As String
    Dim eBeginType                  As MTPCDateType, eEndType As MTPCDateType
    Dim datStartDate                As String, datEndDate As String
    Dim lngEndOffSet                As Long, lngStartOffSet As Long
    
    PrintConsole vbNewLine & "Import Rate Schedules"
    
    Set XMLRateSchedules = XMLNode.selectSingleNode(strRateSchedulesXPath).childNodes
    
    For Each XMLRateSchedule In XMLRateSchedules
    
        strRateScheduleID = XMLRateSchedule.Attributes.getNamedItem("name").Text
        strName = XMLRateSchedule.selectSingleNode("parametertablename").Text
        
        Set ParamTable = ProductCatalog.GetParamTableDefinitionByName(strName)
        If Not IsValidObject(ParamTable) Then
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1004, "NAME", strName), Me, "ImportRateScheduleForProductOffering", LOG_ERROR
            Exit Function
        End If
        
        strName = XMLRateSchedule.selectSingleNode("pricelistname").Text
        
        ' -- Only when use without a product offering --
        If booImportPriceList Then
            If Not ImportPriceListForProductOffering(XMLRateSchedule, ProductOffering.NonSharedPriceListID, ProductOffering) Then Exit Function
        End If
        
        Set PriceList = ProductCatalog.GetPriceListByName(strName)
        If Not IsValidObject(PriceList) Then
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1005, "NAME", strName), Me, "ImportRateScheduleForProductOffering", LOG_ERROR
            Exit Function
        End If
        
        strName = XMLRateSchedule.selectSingleNode("priceableitemname").Text
        Set PriceAbleItemTemplate = ProductCatalog.GetPriceableItemByName(strName)
        If Not IsValidObject(PriceAbleItemTemplate) Then
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1006, "NAME", strName), Me, "ImportRateScheduleForProductOffering", LOG_ERROR
            Exit Function
        End If
        
        ' -- Check to see if the  RateSchedule already exist --
        Set XMLPCTimeSpan = XMLRateSchedule.selectSingleNode("pctimespan[@name='EffectiveDate']")
        eBeginType = XMLPCTimeSpan.selectSingleNode("property[@name='StartDateType']").Text
        eEndType = XMLPCTimeSpan.selectSingleNode("property[@name='EndDateType']").Text
        datStartDate = XMLPCTimeSpan.selectSingleNode("property[@name='StartDate']").Text
        datEndDate = XMLPCTimeSpan.selectSingleNode("property[@name='EndDate']").Text
        lngStartOffSet = XMLPCTimeSpan.selectSingleNode("property[@name='StartOffset']").Text
        lngEndOffSet = XMLPCTimeSpan.selectSingleNode("property[@name='EndOffset']").Text
        
        ' cannonize date format
        datStartDate = Format(datStartDate, "mm/dd/yyyy hh:mm:ss")
        datEndDate = Format(datEndDate, "mm/dd/yyyy hh:mm:ss")
        
        ' Used in the error handler
        strRateScheduleID = "RateSchedule(pt=" & ParamTable.Name & ",pl=" & PriceList.Name & ",pit=" & PriceAbleItemTemplate.Name & ",begintype=" & eBeginType & ",endtype=" & eEndType & ",startdate=" & datStartDate & ",enddate=" & datEndDate & ",StartOffSet=" & lngStartOffSet & ",EndOffSett=" & lngEndOffSet & ")"
        
        If RateScheduleExist(ParamTable.ID, PriceList.ID, PriceAbleItemTemplate.ID, eBeginType, eEndType, datStartDate, datEndDate, lngStartOffSet, lngEndOffSet) Then
        
            Dim objDummyRateSchedule As New MTRateSchedule
            m_Stats.AddReUsedObject objDummyRateSchedule, strRateScheduleID  ' Add to the statistic that we re used a rate schedule
            
            If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1010, "PT", ParamTable.Name, "PL", PriceList.Name, "PIT", PriceAbleItemTemplate, "ST", datStartDate, "ED", datEndDate, "BT", eBeginType, "ET", eEndType), Me, "ImportRateScheduleForProductOffering") Then Exit Function
        Else
            Set RateSchedule = m_Stats.AddNewObject(ParamTable.CreateRateSchedule(PriceList.ID, PriceAbleItemTemplate.ID), strRateScheduleID)
            If Not IsValidObject(RateSchedule) Then
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1007), Me, "ImportRateScheduleForProductOffering", LOG_ERROR
                Exit Function
            End If
            If Not ImportSingleAllocatedRateSchedule(RateSchedule, XMLRateSchedule, ParamTable.Name, strRateScheduleID) Then Exit Function
        End If
    Next
    ImportRateScheduleForProductOffering = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportRateScheduleForProductOffering", LOG_ERROR
End Function


Private Function ImportSingleAllocatedRateSchedule(RateSchedule As MTRateSchedule, XMLRateSchedule As IXMLDOMNode, strParamTableName As String, strRateScheduleID As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim strXMLRuleSet As String
    Dim lngStartPos                 As Long
    Dim lngEndPos                   As Long
    Dim strCalendarName             As String
    Dim lngCalendarID               As String
    Dim ConfigPropSet               As MTConfigPropSet
    Dim Config                      As MTConfig
    Dim objError                    As New CError
    
    Static AAA As Long
    
    AAA = AAA + 1
    
    If AAA = 2 Then
'        Debug.Assert 0
    End If
    
    Const RATESCHEDULE_EXCLUDE_PROPERTIES = ",PARAMETERTABLEID,PRICELISTID,TEMPLATEID,MAPPINGTYPE,"

    INFOOBJECT RateSchedule, "Import "
    
    If Not ImportMTProperty(RateSchedule, XMLRateSchedule, , RATESCHEDULE_EXCLUDE_PROPERTIES) Then Exit Function
                
    strXMLRuleSet = Trim(XMLRateSchedule.selectSingleNode("ruleset").Text)
    If Len(strXMLRuleSet) Then
    
        If UCase$(strParamTableName) = UCase$(CALENDAR_PARAMETER_TABLE_NAME) Then
        
'            Debug.Assert 0
            lngStartPos = InStr(strXMLRuleSet, "|")
            lngEndPos = InStr(lngStartPos + 1, strXMLRuleSet, "|")
            strCalendarName = Mid(strXMLRuleSet, lngStartPos + 1, lngEndPos - lngStartPos - 1)
            
            On Error Resume Next
            lngCalendarID = ProductCatalog.GetCalendarByName(strCalendarName)
            If Err.Number Then
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1010, "CALENDAR", strCalendarName), Me, "ImportRateScheduleForProductOffering", LOG_ERROR
                Exit Function
            End If
            On Error GoTo ErrMgr
            
            strXMLRuleSet = Mid(strXMLRuleSet, 1, lngStartPos - 1) & lngCalendarID & Mid(strXMLRuleSet, lngEndPos + 1)
        End If
        
        strXMLRuleSet = XML_XML_TAG & vbNewLine & strXMLRuleSet
    
        Set Config = New MTConfig
        
        On Error Resume Next
        Set ConfigPropSet = Config.ReadConfigurationFromString(strXMLRuleSet, False)
        objError.Save Err.Number, Err.Description, Err.Source
        On Error GoTo ErrMgr
        If objError.Number <> 0 Then
        
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1048, "ERR_MSG", objError.ToString, "XML", strXMLRuleSet), Me, "ImportSingleAllocatedRateSchedule", LOG_ERROR
            Exit Function
        End If
        objError.Clear
                        
        RateSchedule.RuleSet.ReadFromSet ConfigPropSet
    
        On Error Resume Next
        RateSchedule.SaveWithRules
        objError.Save Err.Number, Err.Description, Err.Source
        On Error GoTo ErrMgr
        GoSub ProcessSaveError
        
    Else
        ' This warning is special event in safemode we accept it
        If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1002, "RATESCHEDULE", strRateScheduleID), Me, "ImportRateScheduleForProductOffering") Then Exit Function
        
        On Error Resume Next
        RateSchedule.Save
        objError.Save Err.Number, Err.Description, Err.Source
        On Error GoTo ErrMgr
        GoSub ProcessSaveError
    End If
    
    ImportSingleAllocatedRateSchedule = True
    
    Exit Function
    
ProcessSaveError:
    If objError.Number = -289472483 Then
    
        If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1006 & " " & objError.ToString(), "RATESCHEDULE", strRateScheduleID), Me, "ImportSingleAllocatedRateSchedule") Then Exit Function
        
    ElseIf objError.Number = 0 Then
        
    Else
        objError.Raise
    End If
Return

ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportSingleAllocatedRateSchedule", LOG_ERROR
End Function
Private Function ImportSpecificationCharacteristicForPO(productOfferingID As Long, XMLNode As IXMLDOMNode, ByVal strAuthUserName As String, strAuthPassWord As String, strAuthNameSpace As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim ImportProperties As Variant
        
    Set ImportProperties = CreateObject("MetraTech.MTPCImportDynamicProperties.DynamicPropertiesImport")
    
    If Not ImportProperties.ImportSpecCharacteristicForPO(productOfferingID, XMLNode.xml, strAuthUserName, strAuthPassWord, strAuthNameSpace) Then Exit Function
    
    ImportSpecificationCharacteristicForPO = True
    
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportSpecificationCharacteristicForPO", LOG_ERROR
End Function

Private Function ImportCharacteristicValuesForSub(subscriptionID As Long, XMLNode As IXMLDOMNode, ByVal strAuthUserName As String, strAuthPassWord As String, strAuthNameSpace As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim ImportProperties As Variant
        
    Set ImportProperties = CreateObject("MetraTech.MTPCImportDynamicProperties.DynamicPropertiesImport")
    
    If Not ImportProperties.ImportCharacteristicValuesForSub(subscriptionID, XMLNode.xml, strAuthUserName, strAuthPassWord, strAuthNameSpace) Then Exit Function
    
    ImportCharacteristicValuesForSub = True
    
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportCharacteristicValuesForSub", LOG_ERROR
End Function
Private Function ImportPriceAbleItemInstanceForProductOffering(ProductOffering As MTProductOffering, XMLNode As IXMLDOMNode) As Boolean

    On Error GoTo ErrMgr
    
    Dim strName                             As String
    Dim XMLPriceAbleItemInstances           As IXMLDOMNodeList
    Dim XMLPriceAbleItemInstance            As IXMLDOMNode
    Dim XMLPriceAbleItemType                As IXMLDOMNode
    Dim PriceAbleItemInstance               As MTPriceableItem
    Dim PriceAbleItemTemplate               As MTPriceableItem
    Dim PriceAbleItemInstanceChild          As MTPriceableItem
    Dim XMLPriceAbleItemInstanceChilds      As IXMLDOMNodeList
    Dim XMLPriceAbleItemInstanceChild       As IXMLDOMNode
    'Dim Profiler                            As New CProfiler: Profiler.Start True, TypeName(Me), "ImportPriceAbleItemInstanceForProductOffering"
    
    
'    Debug.Assert 0

    PrintConsole vbNewLine & "Import PriceAbleItem Instances"
    
    ' Save because the PO must exist in the databse at this time
    ' If the PO already exist this will raise an error and force to roll back all
    ProductOffering.Save
    
    Set XMLPriceAbleItemInstances = XMLNode.selectSingleNode("priceableiteminstances").childNodes
    
    For Each XMLPriceAbleItemInstance In XMLPriceAbleItemInstances
    
        strName = XMLPriceAbleItemInstance.Attributes.getNamedItem("name").Text
        
        Set PriceAbleItemTemplate = ProductCatalog.GetPriceableItemByName(strName)
       
        ' Add the template to the product offering and get back the instance
        ' We cannot add a usage type instance twice from the same template
        ' If it is the case the ProductOffering.AddPriceableItem() will raise an error the COM+ transaction
        ' will be rollback
        Set PriceAbleItemInstance = m_Stats.AddNewObject(ProductOffering.AddPriceableItem(PriceAbleItemTemplate))
        
        If Not ImportAdjustmentsInstance(XMLPriceAbleItemInstance, PriceAbleItemInstance) Then Exit Function
        
        INFOOBJECT PriceAbleItemInstance, "Import "
        
        ' -- IMPORTANT REMARK -- The function ImportDisplayNamesIfExist MUST BE CALLED
        ' -- before ImportPropertiesAndMappingToPriceAbleItemInstance. Because ImportPropertiesAndMappingToPriceAbleItemInstance
        ' -- Save the PriceAble Item instance and is the only one that does this...
        If Not ImportDisplayNamesIfExist(XMLPriceAbleItemInstance, PriceAbleItemInstance) Then Exit Function
        
        If PriceAbleItemInstance.Kind = PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT Then
         If Not ImportUnitDisplayNamesIfExist(XMLPriceAbleItemInstance, PriceAbleItemInstance) Then Exit Function
        End If
        
        If Not ImportPropertiesAndMappingToPriceAbleItemInstance(PriceAbleItemInstance, XMLPriceAbleItemInstance, False) Then Exit Function
   
        ' Check for children and process them
        If IsValidObject(XMLPriceAbleItemInstance.selectSingleNode("children")) Then ' MARK-2002:07:09-2
        
            Set XMLPriceAbleItemInstanceChilds = XMLPriceAbleItemInstance.selectSingleNode("children").selectSingleNode("priceableiteminstances").childNodes
            
            For Each XMLPriceAbleItemInstanceChild In XMLPriceAbleItemInstanceChilds
            
                ' #3.7 Little Comment : we do not need to add/create the priceableitem instance at the children level the fact to add the
                ' parent will create the children, therefore i only do a get
                Set PriceAbleItemInstanceChild = GetPriceAbleItemChildByName(PriceAbleItemInstance, XMLPriceAbleItemInstanceChild.Attributes.getNamedItem("name").Text)
                
                ' Import the adjustment instance - this mostly consist to import the display names...
                'Debug.Assert 0
                If Not ImportAdjustmentsInstance(XMLPriceAbleItemInstanceChild, PriceAbleItemInstanceChild) Then Exit Function
                
                ' -- IMPORTANT REMARK -- The function ImportDisplayNamesIfExist MUST BE CALLED
                ' -- before ImportPropertiesAndMappingToPriceAbleItemInstance. Because ImportPropertiesAndMappingToPriceAbleItemInstance
                ' -- Save the PriceAble Item instance and is the only one that does this...
                If Not ImportDisplayNamesIfExist(XMLPriceAbleItemInstanceChild, PriceAbleItemInstanceChild) Then Exit Function
                
                If Not ImportPropertiesAndMappingToPriceAbleItemInstance(PriceAbleItemInstanceChild, XMLPriceAbleItemInstanceChild, True) Then Exit Function
            Next
        End If
    Next
    ImportPriceAbleItemInstanceForProductOffering = True
Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportPriceAbleItemInstanceForProductOffering", LOG_ERROR
End Function

'THISONE
Private Function ImportPropertiesAndMappingToPriceAbleItemInstance(PriceAbleItemInstance As MTPriceableItem, XMLPriceAbleItemInstance As IXMLDOMNode, booIsChild As Boolean) As Boolean

    Dim ParamTable                          As MTParamTableDefinition
    Dim PriceList                           As MTPriceList
    Dim XMLPriceAbleItemInstanceMappings    As IXMLDOMNodeList
    Dim XMLPriceAbleItemInstanceMapping     As IXMLDOMNode
    Dim PriceListMapping                    As MTPriceListMapping
    Dim strParamTableName                   As String
    
    On Error GoTo ErrMgr
    
    Const PRICELIST_MAPPING_IGNORE_PROPERTIES = ",MAPPINGTYPE,PARAMTABLEDEFINITIONID,PRICEABLEITEMID,PRICELISTID,"

    ' Apply the properties exported to the instance
    If Not ImportMTProperty(PriceAbleItemInstance, XMLPriceAbleItemInstance) Then Exit Function
'    Debug.Assert 0
    PriceAbleItemInstance.Save

    ' I add a bug in one mario file - so I had to add this test - but it should not occur again - Search for MARK-2002:07:09-1
    If IsValidObject(XMLPriceAbleItemInstance.selectSingleNode("pricelistmappings")) Then
    
        ' Apply the pricelist mappings
        
        Set XMLPriceAbleItemInstanceMappings = XMLPriceAbleItemInstance.selectSingleNode("pricelistmappings").selectNodes("pricelistmapping") ' if we do not have <pricelistmapping> we are fine
        
        For Each XMLPriceAbleItemInstanceMapping In XMLPriceAbleItemInstanceMappings
            
            strParamTableName = XMLPriceAbleItemInstanceMapping.selectSingleNode("paramtabledefinitionname").Text
            Set ParamTable = ProductCatalog.GetParamTableDefinitionByName(strParamTableName)
            
            If IsValidObject(XMLPriceAbleItemInstanceMapping.selectSingleNode("pricelistname")) Then
            
                Set PriceList = ProductCatalog.GetPriceListByName(XMLPriceAbleItemInstanceMapping.selectSingleNode("pricelistname").Text)
                
                If IsValidObject(PriceList) Then
                
                    INFOOBJECT PriceAbleItemInstance, "Set Price List Mapping PriceAbleIteInstance='" & PriceAbleItemInstance.Name & "' PT='" & ParamTable.Name & "' PL='" & PriceList.Name & "'"
                    
                    PriceAbleItemInstance.SetPriceListMapping ParamTable.ID, PriceList.ID
                    
                    Set PriceListMapping = m_Stats.AddNewObject(PriceAbleItemInstance.GetPriceListMapping(ParamTable.ID))
                    
                    If Not ImportMTProperty(PriceListMapping, XMLPriceAbleItemInstanceMapping, , PRICELIST_MAPPING_IGNORE_PROPERTIES) Then Exit Function
                    
                    PriceListMapping.Save
                Else
'                    Debug.Assert 0
                    MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1035, "PLNAME", XMLPriceAbleItemInstanceMapping.selectSingleNode("pricelistname").Text), Me, "ImportPropertiesAndMappingToPriceAbleItemInstance", LOG_ERROR
                    Exit Function
                End If
            Else
                ' No mappings for the PriceAbleItemInstance
                If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1001, "PRODUCTOFFERING", m_strCurrentProductOffering, "PARAMETERTABLE", strParamTableName, "PRICEABLEITEM", PriceAbleItemInstance.Name), Me, "ImportPropertiesAndMappingToPriceAbleItemInstance") Then Exit Function
            End If
        Next
    Else
        ' PriceList has no mapping - This case should not happens again because fixed in export class - Kept just for compatibility with 3.0.0 release
        If RaiseWarningAndCancel(PreProcess(PreProcess(MTPCImportExport_WARNING_1001, "PRODUCTOFFERING", m_strCurrentProductOffering, "PARAMETERTABLE", strParamTableName, "PRICEABLEITEM", PriceAbleItemInstance.Name), Me, "ImportPropertiesAndMappingToPriceAbleItemInstance")) Then Exit Function
    End If
    ImportPropertiesAndMappingToPriceAbleItemInstance = True
Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportPropertiesAndMappingToPriceAbleItem", LOG_ERROR
End Function




Public Function GetPriceAbleItemChildByName(PriceAbleItem As MTPriceableItem, ByVal strChildName As String) As MTPriceableItem

    Dim ChildPriceAbleItem As MTPriceableItem
    
    On Error GoTo ErrMgr
    
    strChildName = UCase$(strChildName)
    
    For Each ChildPriceAbleItem In PriceAbleItem.GetChildren
    
        If UCase$(ChildPriceAbleItem.Name) = strChildName Then
        
            Set GetPriceAbleItemChildByName = ChildPriceAbleItem
            Exit Function
        End If
    Next
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "GetPriceAbleItemChildByName", LOG_ERROR
End Function

Private Function ImportCalendar(XMLNode As IXMLDOMNode) As Boolean
    
    Dim XMLCalendars        As IXMLDOMNodeList
    Dim XMLCalendar         As IXMLDOMNode
    Dim Calendar            As MTCalendar
    Dim XMLHolidays         As IXMLDOMNodeList
    Dim XMLHoliday          As IXMLDOMNode
    Dim CalendarHoliday     As MTCalendarHoliday
    Dim CalendarWeekday     As MTCalendarWeekday
    Dim CalendarPeriod      As MTCalendarPeriod
    Dim XMLCalendarPeriods  As IXMLDOMNodeList
    Dim XMLCalendarPeriod   As IXMLDOMNode
    Dim XMLWeekDays         As IXMLDOMNodeList
    Dim XMLWeekDay          As IXMLDOMNode
    Dim strName             As String
    'Dim Profiler            As New CProfiler: Profiler.Start True, TypeName(Me), "ImportCalendar"
    
    On Error GoTo ErrMgr
    
'    Debug.Assert 0
    
    If IsValidObject(XMLNode.selectSingleNode("calendars")) Then
    
        PrintConsole vbNewLine & "Import Calendar"
    
        Set XMLCalendars = XMLNode.selectSingleNode("calendars").selectNodes("calendar")
        
        For Each XMLCalendar In XMLCalendars
        
            strName = XMLCalendar.Attributes.getNamedItem("name").Text
            
            'If IsValidObject(m_Stats.AddReUsedObject(ProductCatalog.GetCalendarByName(strName))) Then
            If CalendarExist(strName) Then
    
                Set Calendar = New MTCalendar
                m_Stats.AddReUsedObject Calendar, strName
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_WARNING_1005, "CALENDAR", strName), Me, "ImportCalendar", LOG_WARNING
            Else
            
                Set Calendar = ProductCatalog.CreateCalendar()
                Calendar.Name = strName
                Calendar.Description = XMLCalendar.selectSingleNode("description").Text
                
                m_Stats.AddNewObject Calendar ' update statistic now that the name has been set
                
                
                
                INFOOBJECT Calendar, "Import "
                
                Set XMLHolidays = XMLCalendar.selectSingleNode("collection[@name='Holidays']").selectNodes("calendarholiday")
                
                For Each XMLHoliday In XMLHolidays
                
                    Set CalendarHoliday = m_Stats.AddNewObject(Calendar.CreateHoliday(XMLHoliday.Attributes.getNamedItem("name").Text))
                    
                    If Not ImportMTProperty(CalendarHoliday, XMLHoliday, , ",CODE,") Then Exit Function
                    CalendarHoliday.Code = GetValueFromFQN(XMLHoliday.selectSingleNode("codefqn").Text)
                    
                    If IsValidObject(XMLHoliday.selectSingleNode("calendarperiods")) Then
                        Set XMLCalendarPeriods = XMLHoliday.selectSingleNode("calendarperiods").selectNodes("calendarperiod")
                        
                        For Each XMLCalendarPeriod In XMLCalendarPeriods
                        
                            Set CalendarPeriod = m_Stats.AddNewObject(CalendarHoliday.CreatePeriod())
                            
                            CalendarPeriod.Code = GetValueFromFQN(XMLCalendarPeriod.selectSingleNode("codefqn").Text)
                            CalendarPeriod.StartTime = XMLCalendarPeriod.selectSingleNode("starttime").Text
                            CalendarPeriod.EndTime = XMLCalendarPeriod.selectSingleNode("endtime").Text
                        Next
                    End If
                Next
        
                Set XMLWeekDays = XMLCalendar.selectSingleNode("collection[@name='WeekDays']").selectNodes("calendarweekday")
                For Each XMLWeekDay In XMLWeekDays
                
                    Set CalendarWeekday = m_Stats.AddNewObject(Calendar.CreateWeekday(XMLWeekDay.Attributes.getNamedItem("name").Text))
                    
                    If Not ImportMTProperty(CalendarWeekday, XMLWeekDay, , ",CODE,") Then Exit Function
                    CalendarWeekday.Code = GetValueFromFQN(XMLWeekDay.selectSingleNode("codefqn").Text)
                    
                    If IsValidObject(XMLWeekDay.selectSingleNode("calendarperiods")) Then
                                
                        If IsValidObject(XMLWeekDay.selectSingleNode("calendarperiods")) Then
                        
                            Set XMLCalendarPeriods = XMLWeekDay.selectSingleNode("calendarperiods").selectNodes("calendarperiod")
                            
                            For Each XMLCalendarPeriod In XMLCalendarPeriods
                            
                                Set CalendarPeriod = m_Stats.AddNewObject(CalendarWeekday.CreatePeriod())
                                
                                CalendarPeriod.Code = GetValueFromFQN(XMLCalendarPeriod.selectSingleNode("codefqn").Text)
                                CalendarPeriod.StartTime = XMLCalendarPeriod.selectSingleNode("starttime").Text
                                CalendarPeriod.EndTime = XMLCalendarPeriod.selectSingleNode("endtime").Text
                            Next
                        End If
                    End If
                Next
                Calendar.Save
            End If
        Next
    End If
    
    ImportCalendar = True
Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportCalendar", LOG_ERROR
End Function



Public Function ImportRateSchedule(ByVal strXMLFileName As String, ByVal eImportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String) As Boolean

    'Dim Profiler                As New CProfiler: Profiler.Start True, TypeName(Me), "ImportRateSchedule"
    Dim RateSchedule            As MTRateSchedule
    Dim objXMLRateSchedules     As IXMLDOMNodeList
    Dim objXMLRateSchedule      As IXMLDOMNode
    Dim strPOName               As String
    Dim strPropertyBagFile      As String
    Dim objPropertyBag          As New cIniFile
    'Dim lngPOCounter            As Long
    Dim lngRateScheduleIndex As Long
    
    On Error GoTo ErrMgr
    
'    Debug.Assert 0

    If Not ImportInit(strXMLFileName, eImportMode, strCommandLine) Then Exit Function
    
    PrintConsole vbNewLine & "Import RateSchedule(s) from file " & strXMLFileName
    
    If Not XMLInputInitialize(strXMLFileName) Then GoTo RollBackAndExit
    
    If Not ImportRateScheduleForProductOffering("xmlconfig/rateschedules", Nothing, XMLDom, True) Then GoTo RollBackAndExit
    
    If Not ImportTerminate() Then Exit Function ' Here the Exit Function is ok because we already roll back
    
    ImportRateSchedule = True
    Exit Function
    
TheExit:
    Exit Function
    
RollBackAndExit:
    TransactionAbort
    GoTo TheExit
    
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportRateSchedule", LOG_ERROR
End Function

Private Sub Class_Initialize()
    Dim w As New cWindows
    SessionGUID = w.CreateGUIDKey()
    MTPCImportExportModule_Initialize
    MTGlobal_VB_MSG.MTInitializeLogFileForPCImportExport
End Sub

Public Property Get SessionGUID() As String
    SessionGUID = static_strSessionGUID
End Property

Public Property Let SessionGUID(ByVal vNewValue As String)
    static_strSessionGUID = vNewValue
End Property

Private Function RateScheduleExist(lngParamTableID As Long, lngPriceListID As Long, lngPriceAbleItemId As Long, eBeginType As MTPCDateType, eEndType As MTPCDateType, datStartDate As String, datEndDate As String, lngStartOffSet As Long, lngEndOffSet As Long) As Boolean

    On Error GoTo ErrMgr
    
    Dim Rowset As IMTRowSet
    Set Rowset = ExecuteQuery("__IS_RATE_SCHEDULE_EXIST__", "PARAM_TABLE_ID", lngParamTableID, "PRICE_LIST_ID", lngPriceListID, "PRICE_ABLE_ITEM_ID", lngPriceAbleItemId, "BEGIN_TYPE", eBeginType, "END_TYPE", eEndType, "START_DATE", datStartDate, "END_DATE", datEndDate, "START_OFFSET", lngStartOffSet, "END_OFFSET", lngEndOffSet)
    RateScheduleExist = Rowset.RecordCount = 1
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "RateScheduleExist", LOG_ERROR
End Function

Private Sub Class_Terminate()
    INFO PreProcess(MTPCImportExport_MESSAGE_1002, "WARNINGCOUNTER", WarningCounter)
End Sub

Public Property Get WarningCounter() As Long
    WarningCounter = static_lngWarningCounter
End Property

Public Property Let WarningCounter(ByVal vNewValue As Long)
    static_lngWarningCounter = vNewValue
End Property

Private Function ImportInit(ByVal strXMLFileName As String, ByVal eImportMode As IMPORT_EXPORT_MODE, strCommandLine As String) As Boolean

    On Error GoTo ErrMgr
        
    m_lngTime = GetTickCount()
    g_enmExportImportMode = eImportMode
    
    Set m_objEnumConfig = New MTENUMCONFIGLib.EnumConfig
    
    Set m_Stats = New CImportExportStats
    
#If CONSOLE Then
    Set static_objConsoleWindow = New CConsoleWindow
    static_objConsoleWindow.Initialize App.EXEName
#End If

    PrintConsoleAppInfo
    
    Set m_objCommandLine = New CCommandLine
    
    m_objCommandLine.Init strCommandLine
    TraceCommandLineInSafeWay strCommandLine
    
    m_enmImportMode = eImportMode
    
    If Not AvoidComPlusFifteenSecondDelay() Then Exit Function
        
    If Not (CBool(g_enmExportImportMode And IMPORT_EXPORT_SKIP_INTEGRITY)) Then
    
        Set m_objParamTableIntegrity = New CParamTableChks
        
        If Not m_objParamTableIntegrity.CheckIntegrityOfXMLFile(strXMLFileName, Me.ProductCatalog) Then
        
            Exit Function
        End If
    End If
    
    If Not TransactionInit() Then Exit Function
    
    ImportInit = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportInit", LOG_ERROR
End Function

Private Function ImportTerminate() As Boolean

    On Error GoTo ErrMgr
    
    If TransactionComplete() Then
        ImportTerminate = True
    Else
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1014), Me, "ImportTerminate", LOG_ERROR
        TransactionAbort
    End If
    INFO m_Stats.GetSummaryString()
    Set m_objEnumConfig = Nothing
    
    m_lngTime = GetTickCount() - m_lngTime
    
    INFO PreProcess(MTPCImportExport_MESSAGE_1008, "TIME", m_lngTime)
    
        
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportTerminate", LOG_ERROR
End Function

Private Function RaiseWarningAndCancel(ByVal strText As String, Optional ByVal Module As Variant, Optional ByVal strFunctionName As String) As Boolean

    If CBool(m_enmImportMode And IMPORT_EXPORT_MODE_SAFE_MODE) Then ' Tell the call to cancel the import

        MTPCImportExportModule.TRACE MTPCImportExport_ERROR_1015 & strText, Module, strFunctionName, LOG_ERROR
        RaiseWarningAndCancel = True
    Else
        RaiseWarningAndCancel = False
        MTPCImportExportModule.TRACE strText, Module, strFunctionName, LOG_WARNING
    End If
End Function


Public Function ImportSubscriptions(ByVal strXMLFileName As String, ByVal eImportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String, ByVal strAuthUserName As String, strAuthPassWord As String, strAuthNameSpace As String) As Boolean

    On Error GoTo ErrMgr
    
    'Dim Profiler                As New CProfiler: Profiler.Start True, TypeName(Me), "ImportSubscriptions"
    Dim Subscription            As MTSubscription
    Dim objXMLSubscriptions     As IXMLDOMNodeList
    Dim objXMLSubscription      As IXMLDOMNode
    Dim objXMLICBs              As IXMLDOMNodeList
    Dim objXMLICB               As IXMLDOMNode
    Dim objXMLUDRCs             As IXMLDOMNodeList
    Dim objXMLUDRC              As IXMLDOMNode
    Dim XMLRateSchedule         As IXMLDOMNode
    Dim objXMLPCTimeSpanSubscription      As IXMLDOMNode
    Dim strProductOfferingName  As String
    Dim strUserName             As String
    Dim strNameSpace            As String
    Dim objPCAccount            As MTPCAccount
    'Dim objMTYAAC               As MTYAAC
    Dim objAccountCatalog       As New MTYAACLib.MTAccountCatalog
    Dim lngProductOfferingID    As Long
    Dim bModified               As Boolean
    Dim objProductOffering      As MTProductOffering
    Dim SubscriptionDateInfo    As MTPCTimeSpan
    Dim booDateModified         As Variant
    Dim objSubscription         As MTSubscription
    Dim strSubscriptionName     As String
    Dim booIsICB                As Boolean
    Dim objPriceAbleItem        As MTPriceableItem
    Dim objParamTable           As MTParamTableDefinition
    Dim objPriceListMapping     As MTPriceListMapping
    Dim objICBRateSchedule      As MTRateSchedule
    Dim strCurrency             As String
    Dim strRateScheduleID       As String
    Dim objError                As New CError
    Dim strUDRCName             As String
    Dim varUDRCValue            As Variant ' Decimal
    Dim strUDRCStartDate        As String
    Dim strUDRCEndDate          As String
    Dim lngURDCInstanceID       As Long
    Dim UDRCInstances           As Variant
    Dim UDRCInstance            As Variant
    Dim objMTYAAC_AccountID     As Long
    Dim UDRCNameUniqueList      As CVariables
        
    
    Debug.Assert 0
    
    Set m_objSessionContext = GetSessionContext(strAuthUserName, strAuthPassWord, strAuthNameSpace)
    If Not IsValidObject(m_objSessionContext) Then Exit Function
    
    objAccountCatalog.Init m_objSessionContext
    ProductCatalog.SetSessionContext m_objSessionContext
    
    INTERNAL_TRACE "[START]ImportSubscriptions(""" & strXMLFileName & """)"
    
    If Not ImportInit(strXMLFileName, eImportMode, strCommandLine) Then Exit Function
    
    INFO PreProcess(MTPCImportExport_MESSAGE_1006, "FILE", strXMLFileName)
    
    If Not XMLInputInitialize(strXMLFileName) Then GoTo RollBackAndExit
    
    Set objXMLSubscriptions = XMLDom.selectNodes("xmlconfig/subscriptions/subscription")
    
    For Each objXMLSubscription In objXMLSubscriptions
        
        Set objXMLICBs = objXMLSubscription.selectNodes("icbs/*") ' the <icbs> tag is always there
        booIsICB = objXMLICBs.Length
        
        strProductOfferingName = objXMLSubscription.Attributes.getNamedItem("name").Text
        
        Set objProductOffering = Me.ProductCatalog.GetProductOfferingByName(strProductOfferingName)
        If Not IsValidObject(objProductOffering) Then
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1016, "PRODUCT_OFFERING", strProductOfferingName), Me, "ImportSubscriptions", LOG_ERROR
            GoTo RollBackAndExit
        End If
        
        strUserName = objXMLSubscription.selectSingleNode("username").Text
        strNameSpace = objXMLSubscription.selectSingleNode("namespace").Text
        

        ' REMOVED IN 3.7, because temporarily GetAccountByName was broken and also checked that MTPCImportExportModule.GetAccountID()
        ' is unicode compatible...
        'Set objMTYAAC = objAccountCatalog.GetAccountByName(strUserName, strNameSpace)
        
        objMTYAAC_AccountID = MTPCImportExportModule.GetAccountID(strUserName, strNameSpace)
        
        If objMTYAAC_AccountID = -1 Then
        
            If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1011, "USERNAME", strUserName, "NAMESPACE", strNameSpace) & GetVBErrorString(), Me, "ImportSubscriptions") Then GoTo RollBackAndExit
            
        Else
        
            strSubscriptionName = "ProductOffering=" & objProductOffering.Name & " Account=" & strNameSpace & ":" & strUserName
            Set objPCAccount = Me.ProductCatalog.GetAccount(objMTYAAC_AccountID)
            
            Set SubscriptionDateInfo = New MTPCTimeSpan
            Set objXMLPCTimeSpanSubscription = objXMLSubscription.selectSingleNode("pctimespan")
            
            If Not ImportMTProperty(SubscriptionDateInfo, objXMLPCTimeSpanSubscription) Then GoTo RollBackAndExit
          
            Set objSubscription = m_Stats.AddNewObject(objPCAccount.Subscribe(objProductOffering.ID, SubscriptionDateInfo, bModified), strSubscriptionName)
            
            MTGlobal_VB_MSG.TRACE PreProcess(MTPCImportExport_MESSAGE_1007, "ACCOUNTNAME", strUserName, "NAMESPACE", strNameSpace, "PO", strProductOfferingName)
            
            INFOOBJECT objSubscription, ""
            
            '
            ' UDRC
            '
'            Debug.Assert 0
            Set objXMLUDRCs = objXMLSubscription.selectNodes("udrcs/udrc") ' the <icbs> tag is always there
            Set UDRCNameUniqueList = GetUniqueList(objXMLUDRCs, "name")
            ' import the first one only
            If Not ImportSubscriptionOrGroupSubUDRC(objSubscription, objProductOffering, objXMLUDRCs, strSubscriptionName, UDRCNameUniqueList, True) Then Exit Function
            ' import the rest
            If Not ImportSubscriptionOrGroupSubUDRC(objSubscription, objProductOffering, objXMLUDRCs, strSubscriptionName, UDRCNameUniqueList, False) Then Exit Function
            '
            ' ICB
            '
            If booIsICB Then
            
'                Debug.Assert 0
                
                ' -- Process the parent level icb
                Set objXMLICBs = objXMLSubscription.selectNodes("icbs/icb")
                For Each objXMLICB In objXMLICBs
                    If Not ImportCalendar(objXMLICB) Then Exit Function
                    If Not SetICBPriceListMappingToSubOrGroupSub(objSubscription, objXMLICB, objProductOffering, strSubscriptionName) Then GoTo RollBackAndExit
                Next
                
                ' -- Process the children level icb
                Set objXMLICBs = objXMLSubscription.selectNodes("icbs/icbs_child/icb")
                For Each objXMLICB In objXMLICBs
                    If Not ImportCalendar(objXMLICB) Then Exit Function
                    If Not SetICBPriceListMappingToSubOrGroupSub(objSubscription, objXMLICB, objProductOffering, strSubscriptionName) Then GoTo RollBackAndExit
                Next
            End If
            'objSubscription.Save
            
            ImportCharacteristicValuesForSub objSubscription.ID, objXMLSubscription, strAuthUserName, strAuthPassWord, strAuthNameSpace
            
        End If
        INTERNAL_TRACE "[SUBSCRIBE]ImportSubscriptions(""" & strXMLFileName & """," & strNameSpace & ":" & strUserName & ").RESULT=TRUE"
    Next
    If Not ImportTerminate() Then Exit Function
    ImportSubscriptions = True
    INTERNAL_TRACE "[END]ImportSubscriptions(""" & strXMLFileName & """)"
TheExit:
    Exit Function
RollBackAndExit:
    INTERNAL_TRACE "[START]ImportSubscriptions(""" & strXMLFileName & """," & strNameSpace & ":" & strUserName & ").RESULT=FALSE"
    TransactionAbort
    GoTo TheExit
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportSubscriptions", LOG_ERROR
    GoTo RollBackAndExit
End Function

Private Function GetCachedPriceableItemID(objProductOffering As MTProductOffering, strPriceAbleItem As String) As Long

    Dim strKey                  As String
    Dim objPriceAbleItem        As MTPriceableItem
    
    strKey = objProductOffering.Name & "|" & strPriceAbleItem
    
    If m_CachedPriceableItemID.Exist(strKey) Then
    
        GetCachedPriceableItemID = m_CachedPriceableItemID.Item(strKey).Value
        Exit Function
    Else
        Set objPriceAbleItem = objProductOffering.GetPriceableItemByName(strPriceAbleItem) '' TODO:could be cached
        If Not IsValidObject(objPriceAbleItem) Then
        
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1043, "NAME", strPriceAbleItem), Me, "GetCachedPriceableItemID", LOG_ERROR
            Exit Function
        End If
        m_CachedPriceableItemID.Add strKey, objPriceAbleItem.ID
        GetCachedPriceableItemID = GetCachedPriceableItemID(objProductOffering, strPriceAbleItem)
    End If
End Function


Private Function GetCachedParamTableID(strParamTable As String) As Long

    Dim strKey                  As String
    Dim objParamTable           As MTParamTableDefinition
    
    strKey = strParamTable
    
    If m_CachedParamTableID.Exist(strKey) Then
    
        GetCachedParamTableID = m_CachedParamTableID.Item(strKey).Value
        Exit Function
    Else
        Set objParamTable = Me.ProductCatalog.GetParamTableDefinitionByName(strParamTable)
        
        If Not IsValidObject(objParamTable) Then
    
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1044, "NAME", strParamTable), Me, "GetCachedParamTableID", LOG_ERROR
            Exit Function
        End If
        m_CachedParamTableID.Add strKey, objParamTable.ID
        GetCachedParamTableID = GetCachedParamTableID(strParamTable)
    End If
End Function


Private Function SetICBPriceListMappingToSubOrGroupSub(objSubscriptionOrGroupSubscription As IMTSubscriptionBase, objXMLICB As IXMLDOMNode, objProductOffering As MTProductOffering, strSubscriptionOrGroupSubcriptionName As String, Optional ByVal booParentLevel As Boolean = True) As Boolean

    Dim objPriceListMapping     As MTPriceListMapping
    Dim objICBRateSchedule      As MTRateSchedule
    Dim ParamTableID            As Long
    Dim XMLRateSchedule         As IXMLDOMNode
    Dim PriceAbleItemID         As Long
    Dim strCurrency             As String
    Dim XMLICBChild             As IXMLDOMNode
    Dim XMLICBChilds            As IXMLDOMNodeList
    Dim booParentEmpty          As Boolean
    Dim strPriceAbleItem        As String
    Dim strParamTable           As String
    
    On Error GoTo ErrMgr

    Set XMLRateSchedule = objXMLICB.selectSingleNode("rateschedules/rateschedule") ' -- Only one rateschedule per price able item icb ed --
    
    strCurrency = objXMLICB.selectSingleNode("currency").Text
    
    Debug.Assert 0
    
    strPriceAbleItem = objXMLICB.selectSingleNode("rateschedules/rateschedule/priceableitemname").Text
    PriceAbleItemID = GetCachedPriceableItemID(objProductOffering, strPriceAbleItem)
    If PriceAbleItemID = 0 Then Exit Function

    strParamTable = objXMLICB.selectSingleNode("rateschedules/rateschedule/parametertablename").Text
    ParamTableID = GetCachedParamTableID(strParamTable)
    If ParamTableID = 0 Then Exit Function
    
    objSubscriptionOrGroupSubscription.SetICBPriceListMapping PriceAbleItemID, ParamTableID, strCurrency  ' Remember the currency is ignore we use the one from the PO
    '
    ' There is a bug in the 3.0.1 API with GetICBPriceListMapping() which does not call context.Complete!
    ' Therefore the method objPriceListMapping.CreateRateSchedule() always failed because it think the transaction
    ' has been aborted.
    '
    Set objPriceListMapping = m_Stats.AddNewObject(objSubscriptionOrGroupSubscription.GetICBPriceListMapping(PriceAbleItemID, ParamTableID), "ICB-" & strSubscriptionOrGroupSubcriptionName)
    
    Set objICBRateSchedule = m_Stats.AddNewObject(objPriceListMapping.CreateRateSchedule(), "ICB-" & strSubscriptionOrGroupSubcriptionName)
    
    If Not ImportSingleAllocatedRateSchedule(objICBRateSchedule, XMLRateSchedule, strParamTable, "") Then Exit Function
    
    SetICBPriceListMappingToSubOrGroupSub = True
    Exit Function

ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "SetICBPriceListMappingToSubOrGroupSub", LOG_ERROR
End Function

Private Function CalendarExist(strCalendarName As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim Rowset As IMTRowSet
    Set Rowset = ExecuteQuery("__IS_CALENDAR_EXIST__", "CALENDAR_NAME", strCalendarName)
    CalendarExist = Rowset.RecordCount = 1
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "CalendarExist", LOG_ERROR
End Function


Public Function ImportPriceLists(ByVal strXMLFileName As String, ByVal eImportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String, ByVal strAuthUserName As String, strAuthPassWord As String, strAuthNameSpace As String) As Boolean

    On Error GoTo ErrMgr
    
    'Dim Profiler                As New CProfiler: Profiler.Start True, TypeName(Me), "ImportPriceLists"
    
    Dim objAccountCatalog       As New MTYAACLib.MTAccountCatalog
    
    Dim objXMLPriceList         As IXMLDOMNode
    Dim objXMLPriceLists        As IXMLDOMNodeList
    
'    Debug.Assert 0
    
    Set m_objSessionContext = GetSessionContext(strAuthUserName, strAuthPassWord, strAuthNameSpace)
    If Not IsValidObject(m_objSessionContext) Then Exit Function
    
    objAccountCatalog.Init m_objSessionContext
    ProductCatalog.SetSessionContext m_objSessionContext
    
    If Not ImportInit(strXMLFileName, eImportMode, strCommandLine) Then Exit Function
    
    'PrintConsole vbNewLine & PreProcess(MTPCImportExport_MESSAGE_1010, "FILE", strXMLFileName)
    INFO PreProcess(MTPCImportExport_MESSAGE_1010, "FILE", strXMLFileName)
    
    If Not XMLInputInitialize(strXMLFileName) Then GoTo RollBackAndExit
    
    ImportPriceListForProductOffering XMLDom.selectSingleNode("xmlconfig"), -1, Nothing ' Not from a product offering
    
    Set objXMLPriceLists = XMLDom.selectNodes("xmlconfig/pricelists/pricelist")
    For Each objXMLPriceList In objXMLPriceLists
    
        If Not ImportPriceAbleItemTemplateForProductOffering(Nothing, objXMLPriceList) Then GoTo RollBackAndExit
        
        If Not ImportCalendar(objXMLPriceList) Then GoTo RollBackAndExit
        If Not ImportRateScheduleForProductOffering("rateschedules", Nothing, objXMLPriceList) Then GoTo RollBackAndExit
    Next
    If Not ImportTerminate() Then Exit Function
    ImportPriceLists = True
    
TheExit:
    Exit Function
    
RollBackAndExit:
    TransactionAbort
    GoTo TheExit

ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportPriceLists", LOG_ERROR
    TransactionAbort
End Function


Public Function ImportGroupSubscriptions(ByVal strXMLFileName As String, _
                                         ByVal eImportMode As IMPORT_EXPORT_MODE, _
                                         ByVal strCommandLine As String, _
                                         ByVal strAuthUserName As String, _
                                               strAuthPassWord As String, _
                                               strAuthNameSpace As String, _
                                               strHierarchyDate As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim GroupSubscription               As MTGroupSubscription
    Dim objXMLGroupSubscriptions        As IXMLDOMNodeList
    Dim objXMLGroupSubscription         As IXMLDOMNode
    Dim objAccountCatalog               As New MTYAACLib.MTAccountCatalog
    Dim strGroupSubscriptionName        As String
    Dim strProductOfferingName          As String
    Dim strCorporationName              As String
    Dim objProductOffering              As MTProductOffering
    Dim CorporationList                 As CVariables
    Dim objImportExportUserAccount      As MTYAACLib.MTYAAC
    Dim objXMLMembers                   As IXMLDOMNodeList
    Dim objXMLMember                    As IXMLDOMNode
    Dim GroupSubscriptionMember         As MTGSubMember
    Dim strAccountName                  As String
    Dim strNameSpace                    As String
    Dim MembersCollection               As IMTCollection
    Dim NewMembersRowset                As IMTRowSet
    Dim objMTYAAC                       As MTYAAC
    Dim booIsAllAccountExist            As Boolean
    Dim strEndDate                      As String
    Dim objXMLICBs                      As IXMLDOMNodeList
    Dim objXMLICB                       As IXMLDOMNode
    Dim booIsICB                        As Boolean
    Dim strDistributionAccountName      As String
    Dim strDistributionAccountNameSpace As String
    Dim strUserName                     As String
    Dim strPriceAbleInstanceName        As String
    Dim objXMChargeAccounts             As IXMLDOMNodeList
    Dim objXMChargeAccount              As IXMLDOMNode
    Dim objPriceAbleInstance            As MTPriceableItem
    Dim lngPriceAbleInstanceID          As Long
    Dim objXMLUDRCs                     As IXMLDOMNodeList
    Dim objXMLUDRC                      As IXMLDOMNode
    Dim strCorporationNameSpace         As String
    Dim lngCorporationID                As Long
    Dim objTmpCorp                      As CVariable
    Dim objMTYAAC_AccountID             As Long
    Dim lngChargeAccountCounter         As Long
    Dim UDRCNameList                                As New CVariables
    Dim ChargeAccountPriceAbleItemNameList          As New CVariables
    Dim lngImport1GroupSubTime          As Long
    Dim lngImport1GroupSubTimeICB       As Long
        
       
    Debug.Assert 0

    Set m_objSessionContext = GetSessionContext(strAuthUserName, strAuthPassWord, strAuthNameSpace)
    If Not IsValidObject(m_objSessionContext) Then Exit Function
    
    objAccountCatalog.Init m_objSessionContext
    ProductCatalog.SetSessionContext m_objSessionContext
    Set objImportExportUserAccount = objAccountCatalog.GetAccountByName(strAuthUserName, strAuthNameSpace)
    
    If Not ImportInit(strXMLFileName, eImportMode, strCommandLine) Then Exit Function
    
    INFO PreProcess(MTPCImportExport_MESSAGE_1013, "FILE", strXMLFileName)
    
    If Not XMLInputInitialize(strXMLFileName) Then GoTo RollBackAndExit
    
    Set CorporationList = GetCorporationList("", strHierarchyDate, objImportExportUserAccount.AccountID, objAccountCatalog)
    
    Set objXMLGroupSubscriptions = XMLDom.selectNodes("xmlconfig/groupsubscriptions/groupsubscription")
    
    '
    ' Execute Business Rule regarding the Hierarchy Restricted Operations from the file and from the RMP system
    '
    If IsValidObject(XMLDom.selectSingleNode("xmlconfig/rmpishierarchyrestrictedoperations")) Then
    
        
        If CBool(XMLDom.selectSingleNode("xmlconfig/rmpishierarchyrestrictedoperations").Text) = False Then ' RMP where the file was exported does not inforce Hierarchy Restricted Operations
        
            If GetRMPIsHierarchyRestrictedOperations(Me.ProductCatalog) Then ' The current systeme inforce Hierarchy Restricted Operations

                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1046, "FILE", strXMLFileName), Me, "ImportGroupSubscriptions", LOG_ERROR
                GoTo RollBackAndExit
            End If
            
        Else ' RMP where the file was exported DOES inforce Hierarchy Restricted Operations
            
            If GetRMPIsHierarchyRestrictedOperations(Me.ProductCatalog) = False Then ' The current systeme DOES NOT inforce Hierarchy Restricted Operations

                If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1022, "FILE", strXMLFileName)) Then
                
                    GoTo RollBackAndExit
                End If
            End If
        End If
        
    Else
        ' In Previous release from 3.6 this tag did not exist...
    End If
        
    For Each objXMLGroupSubscription In objXMLGroupSubscriptions
    
        lngImport1GroupSubTime = GetTickCount()
        DebugTrace "Start"
    
        lngChargeAccountCounter = 0
        
        Set objXMLICBs = objXMLGroupSubscription.selectNodes("icbs/*") ' the <icbs> tag is always there
        booIsICB = objXMLICBs.Length
    
        strGroupSubscriptionName = objXMLGroupSubscription.Attributes.getNamedItem("name").Text
        
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_MESSAGE_1021, "NAME", strGroupSubscriptionName), Me, "ImportGroupSubscriptions", LOG_INFO
        
        strProductOfferingName = objXMLGroupSubscription.selectSingleNode("productoffering").Text
        Set objProductOffering = ProductCatalog.GetProductOfferingByName(strProductOfferingName)
        
        If Not IsValidObject(objProductOffering) Then
        
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1016, "PRODUCT_OFFERING", strProductOfferingName), Me, "ImportGroupSubscriptions", LOG_ERROR
            GoTo RollBackAndExit
        End If
        
        strCorporationName = objXMLGroupSubscription.selectSingleNode("corporation").Text
        strCorporationNameSpace = objXMLGroupSubscription.selectSingleNode("corporationnamespace").Text
        
        If strCorporationName = "/GLOBAL" Then
        
            lngCorporationID = 1
        Else
            
            '
            ' Search for the corporation based on the name and name space
            '
            lngCorporationID = 0
            
            For Each objTmpCorp In CorporationList
            
                If UCase$(strCorporationName) = UCase$(objTmpCorp.Name) Then
                
                    If UCase$(strCorporationNameSpace) = UCase$(objTmpCorp.Tag) Then
                    
                        lngCorporationID = objTmpCorp.Value
                        Exit For
                    End If
                End If
            Next
        End If
        
        If lngCorporationID = 0 Then

            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1023, "CORP", strCorporationName, "CORPNAMESPACE", strCorporationNameSpace), Me, "ImportGroupSubscriptions", LOG_ERROR
            GoTo RollBackAndExit
        End If
        DebugTrace "Corporation Found"
        
        '
        '        - Group Subscription Business Rule
        '           We must verify that all the account/member of a group subscription exist before we create the group subscription
        '           if one account is missing we will raise a warning say Group subscription was not created because an account is missing...
        '
        
        DebugTrace "Loading Members"
        PrintConsole vbNewLine & "Loading Members"

        ' Create a collection of group subscription members
        Set MembersCollection = CreateObject(MT_COLLECTION_PROG_ID)
        Set objXMLMembers = objXMLGroupSubscription.selectNodes("members/gsubmember")
        booIsAllAccountExist = True
        
        For Each objXMLMember In objXMLMembers
        
            INFOOBJECT Nothing, ""
            Set GroupSubscriptionMember = New MTGSubMember
            strAccountName = objXMLMember.selectSingleNode("property[@name='AccountName']").Text
            strNameSpace = objXMLMember.selectSingleNode("namespace").Text
            objMTYAAC_AccountID = -1

            On Error Resume Next
            #If ImportGroupSubscriptions_OPTIMIZE_FOR_SPEED Then ' -- 3.6 Optimization for QA -- This will turned off for the standard build
                objMTYAAC_AccountID = MTPCImportExportModule.GetAccountID(strAccountName, strNameSpace)
            #Else
                Set objMTYAAC = objAccountCatalog.GetAccountByName(strAccountName, strNameSpace)
                If IsValidObject(objMTYAAC) Then objMTYAAC_AccountID = objMTYAAC.AccountID
            #End If
            On Error GoTo ErrMgr
            
            If objMTYAAC_AccountID <> -1 Then
            
                GroupSubscriptionMember.AccountID = objMTYAAC_AccountID
                GroupSubscriptionMember.StartDate = objXMLMember.selectSingleNode("property[@name='StartDate']").Text
                strEndDate = objXMLMember.selectSingleNode("property[@name='EndDate']").Text
                If IsInfinity(strEndDate) Then
                    ' -- Let the end date as blank --
                Else
                    GroupSubscriptionMember.EndDate = strEndDate
                End If
                m_Stats.AddNewObject GroupSubscriptionMember, strNameSpace & ":" & strAccountName
                MembersCollection.Add GroupSubscriptionMember
            Else
                If RaiseWarningAndCancel(PreProcess(MTPCImportExport_WARNING_1015, "SUB", strGroupSubscriptionName, "USERNAME", strAccountName, "NAMESPACE", strNameSpace) & GetVBErrorString(), Me, "ImportSubscriptions") Then GoTo RollBackAndExit
                booIsAllAccountExist = False
                'Exit For
            End If
        Next
        
        DebugTrace "CreateGroupSubscription()"
    
        ' Create the group subscription
        Set GroupSubscription = ProductCatalog.CreateGroupSubscription()
        GroupSubscription.EffectiveDate = New MTPCTimeSpan ' Weird but true - bad C++ implementation - there is no set
        GroupSubscription.Cycle = New MTPCCycle
        GroupSubscription.Name = strGroupSubscriptionName
        GroupSubscription.productOfferingID = objProductOffering.ID
        GroupSubscription.CorporateAccount = lngCorporationID
        m_Stats.AddNewObject GroupSubscription
        If Not ImportMTProperty(GroupSubscription, objXMLGroupSubscription, , "DISTRIBUTIONACCOUNT,CORPORATEACCOUNT,ID_GROUP,ID_SUB,PO,") Then GoTo RollBackAndExit   ' Set the Product offering property with the AVAILABILITYDATE
        
        ' Set the distribution account
        strDistributionAccountName = objXMLGroupSubscription.selectSingleNode("distributionaccountusername").Text
        strDistributionAccountNameSpace = objXMLGroupSubscription.selectSingleNode("distributionaccountnamespace").Text
        If (Len(strDistributionAccountName)) Then
        
            On Error Resume Next
            Set objMTYAAC = objAccountCatalog.GetAccountByName(strDistributionAccountName, strDistributionAccountNameSpace)
            If Err.Number <> 0 Then
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1028 & " " & GetVBErrorString(), "USERNAME", strDistributionAccountName, "NAMESPACE", strDistributionAccountNameSpace), Me, "ImportGroupSubscriptions", LOG_ERROR
                GoTo RollBackAndExit
            End If
            On Error GoTo ErrMgr
            GroupSubscription.DistributionAccount = objMTYAAC.AccountID
        End If
        
        
        DebugTrace "UDRC"
        '
        ' UDRC - We need to set the UDRC before we save - we only set the first item
        '
        Set objXMLUDRCs = objXMLGroupSubscription.selectNodes("udrcs/udrc") ' the <icbs> tag is always there
        Set UDRCNameList = GetUniqueList(objXMLUDRCs, "name")
'        Debug.Assert 0
        If Not ImportSubscriptionOrGroupSubUDRC(GroupSubscription, objProductOffering, objXMLUDRCs, strGroupSubscriptionName, UDRCNameList, True) Then GoTo RollBackAndExit
        
        '
        ' Set the Charge Account
        '
        '- <chargeaccounts>
        '- <chargeaccount>
        '  <namespace>mt</namespace>
        '  <nm_display_name>RC UDRC For GS</nm_display_name>
        '  <username>Discount_Receiver53233</username>
        '  <startdate>12/16/2002</startdate>
        '  <enddate>12/16/2038</enddate>
        '  </chargeaccount>
        '  </chargeaccounts>
        DebugTrace "ChargeAccount"
        Set objXMChargeAccounts = objXMLGroupSubscription.selectNodes("chargeaccounts/chargeaccount") ' the <icbs> tag is always there
        Set ChargeAccountPriceAbleItemNameList = GetUniqueList(objXMChargeAccounts, "priceableitemname")

        If Not SetChargeAccount(objProductOffering, GroupSubscription, objAccountCatalog, strGroupSubscriptionName, objXMChargeAccounts, ChargeAccountPriceAbleItemNameList, True) Then GoTo RollBackAndExit

        DebugTrace "GroupSubscription.Save"
        GroupSubscription.Save ' We need to save  the group sub before we add the member
        
        DebugTrace "ImportSubscriptionOrGroupSubUDRC"
        
        ' UDRC - now we can set the item 2 to max count
        If Not ImportSubscriptionOrGroupSubUDRC(GroupSubscription, objProductOffering, objXMLUDRCs, strGroupSubscriptionName, UDRCNameList, False) Then GoTo RollBackAndExit
        
        DebugTrace "SetChargeAccount"
        ' Charge Account - now we can set the item 2 to max count
        If Not SetChargeAccount(objProductOffering, GroupSubscription, objAccountCatalog, strGroupSubscriptionName, objXMChargeAccounts, ChargeAccountPriceAbleItemNameList, False) Then GoTo RollBackAndExit

        If MembersCollection.Count > 0 Then
        
            DebugTrace "AddAccountBatch"
        
            Set NewMembersRowset = GroupSubscription.AddAccountBatch(MembersCollection, Nothing, True)
            
            If CallRecordCount(NewMembersRowset, "GroupSubscription.AddAccountBatch") > 0 Then
            
                TRACERowset NewMembersRowset, "AddAccountBatch() Rowset errors"
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1024, "GSUB", strGroupSubscriptionName), Me, "ImportGroupSubscriptions", LOG_ERROR
                GoTo RollBackAndExit
            End If
        Else
        
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_WARNING_1025, "GSUB", strGroupSubscriptionName), Me, "ImportGroupSubscriptions", LOG_WARNING
        End If

                
        '
        ' ICB
        '
        If booIsICB Then
            
'            Debug.Assert 0
            DebugTrace "ICB"
            lngImport1GroupSubTimeICB = GetTickCount()
            
            ' -- Process the parent level icb
            Set objXMLICBs = objXMLGroupSubscription.selectNodes("icbs/icb")
            For Each objXMLICB In objXMLICBs
            
                If Not ImportCalendar(objXMLICB) Then Exit Function
                If Not SetICBPriceListMappingToSubOrGroupSub(GroupSubscription, objXMLICB, objProductOffering, strGroupSubscriptionName) Then GoTo RollBackAndExit
            Next
            lngImport1GroupSubTimeICB = GetTickCount() - lngImport1GroupSubTimeICB
            DebugTrace "ICB:" & lngImport1GroupSubTimeICB
                        
            DebugTrace "ICBCHILD"
            
            ' -- Process the children level icb
            Set objXMLICBs = objXMLGroupSubscription.selectNodes("icbs/icbs_child/icb")
            For Each objXMLICB In objXMLICBs
            
                If Not ImportCalendar(objXMLICB) Then Exit Function
                If Not SetICBPriceListMappingToSubOrGroupSub(GroupSubscription, objXMLICB, objProductOffering, strGroupSubscriptionName) Then GoTo RollBackAndExit
            Next
        End If

        lngImport1GroupSubTime = GetTickCount() - lngImport1GroupSubTime
        MTPCImportExportModule.TRACE "Import Group Sub Time:" & strGroupSubscriptionName & "=" & lngImport1GroupSubTime, Me, "ImportGroupSubscriptions", LOG_INFO

    Next
    
    If Not ImportTerminate() Then Exit Function
    ImportGroupSubscriptions = True
    
TheExit:
    Exit Function
    
RollBackAndExit:
    TransactionAbort
    GoTo TheExit

ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportGroupSubscriptions", LOG_ERROR
    GoTo RollBackAndExit
End Function


'-igs -file "t:\Development\Core\MTProductCatalog\ImportExport\GROUPSUB\GroupSubscription.xml"  -username su -password su123 -namespace system_user
'-egs -corp "PCIE-TEST-CORP37162" -groupsubscription "Fred-GS1" -file "c:\temp\s.xml" -username su -password su123 -namespace system_user

 '-egs -corp "PCIE-TEST-CORP56269" -groupsubscription "FRED-GS-2-" -file "c:\temp\ss.xml"  -username su -password su123 -namespace system_user


'-igs -file "t:\Development\Core\MTProductCatalog\ImportExport\GROUPSUB\GroupSubscription@.xml"  -username su -password su123 -namespace system_user




'Private Function GetPrivatePriceListFromProductOffering(ProductOffering As MTProductOffering) As MTPriceList
'
'On Error GoTo ErrMgr
'    Set GetPrivatePriceListFromProductOffering = Me.ProductCatalog.GetPriceList(ProductOffering.NonSharedPriceListID)
'    Exit Function
'ErrMgr:
'    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString() & " PO.Name=" & ProductOffering.Name, Me, "GetPrivatePriceListFromProductOffering", LOG_ERROR
'End Function



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : AvoidComPlusFifteenSecondDelay
' PARAMETERS  :
' DESCRIPTION  : must be called before first database interaction to avoid 15 second COM+ delay
'                The 15 second delay occurs if the first database connection is not-complus and
'                committing a subsequent COM+ transaction would bring the connection count to zero.

Private Function AvoidComPlusFifteenSecondDelay() As Boolean

  ' create a dummy rowset and keep it around until the end of the class
  ' to avoid connection count going to 0
  On Error GoTo ErrMgr

  Set m_objAvoidComPlusFifteenSecondDelayRowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
  m_objAvoidComPlusFifteenSecondDelayRowset.Init "queries\ProductCatalog"
  AvoidComPlusFifteenSecondDelay = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "AvoidComPlusFifteenSecondDelay", LOG_ERROR
End Function

Private Property Get AdjustmentCatalog() As AdjustmentCatalog

    If Not IsValidObject(m_objAdjustmentCatalog) Then
        Set m_objAdjustmentCatalog = New MetraTech_Adjustments.AdjustmentCatalog
        m_objAdjustmentCatalog.Initialize m_objSessionContext
    End If
    Set AdjustmentCatalog = m_objAdjustmentCatalog
End Property

Private Function ImportAdjustmentsInstance(XMLPriceAbleItemInstance As IXMLDOMNode, PriceAbleItemInstance As MTPriceableItem) As Boolean

On Error GoTo ErrMgr

    Dim XMLAdjustments          As IXMLDOMNodeList
    Dim XMLAdjustment           As IXMLDOMNode
    Dim XMLAdjustmentType       As IXMLDOMNode
    Dim strAdjustmentName       As String
    Dim strAdjustmentTypeName   As String
    Dim objAdjustment           As Adjustment
    Dim objAdjustmentType       As AdjustmentType
    
'    Debug.Assert 0

    If IsValidObject(XMLPriceAbleItemInstance.selectSingleNode("adjustments")) Then
    
        Set XMLAdjustments = XMLPriceAbleItemInstance.selectSingleNode("adjustments").childNodes
        
        For Each XMLAdjustment In XMLAdjustments
        
            strAdjustmentName = XMLAdjustment.Attributes.getNamedItem("name").Text
            
            Set objAdjustment = GetObjectFromMTCollection(PriceAbleItemInstance.GetAdjustments, strAdjustmentName)
            If IsValidObject(objAdjustment) Then
            
                INFOOBJECT objAdjustment, "Import "
                If Not ImportMTProperty(objAdjustment, XMLAdjustment) Then Exit Function
                If Not ImportDisplayNamesIfExist(XMLAdjustment, objAdjustment) Then Exit Function
            Else
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1040, "ADJ_NAME", strAdjustmentName, "PI_NAME", PriceAbleItemInstance.Name), Me, "ImportGroupSubscriptions", LOG_ERROR
                Exit Function
            End If
        Next
    Else
        ' This warning does not stop the execution in case of safe mode
        ' this is just a compatibility warning with old XML file from PCImportExport 3.0 and 3.0.1
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_WARNING_1019, "PI_NAME", PriceAbleItemInstance.Name), Me, "ImportAdjustmentsTemplate", LOG_WARNING
    End If
    ImportAdjustmentsInstance = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportAdjustmentsInstance", LOG_ERROR
End Function

Public Function ImportProductOfferingMultiFile(ByVal eImportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String, ByVal strAuthUserName As String, strAuthPassWord As String, strAuthNameSpace As String, strPathWildCard As String) As Boolean
    
    On Error GoTo ErrMgr
    
    Dim objTextFile     As New cTextFile
    Dim strPath         As String
    Dim strWildCard     As String
    Dim objFiles        As New CVariables
    Dim objFile        As CVariable
    
'    Debug.Assert 0
    strPath = objTextFile.GetPathFromFileName(strPathWildCard)
    strWildCard = objTextFile.GetFileName(strPathWildCard)
    
    If objTextFile.GetFilesList(strPath, strWildCard, objFiles) Then
    
        For Each objFile In objFiles

            Me.ImportProductOffering objFile.Value, eImportMode, strCommandLine & " -file """ & objFile.Value & """ ", strAuthUserName, strAuthPassWord, strAuthNameSpace
        Next
    End If
    ImportProductOfferingMultiFile = True
TheExit:
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportProductOfferingMultiFile", LOG_ERROR
    TransactionAbort
End Function



Public Function ImportPriceListMultiFile(ByVal eImportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String, ByVal strAuthUserName As String, strAuthPassWord As String, strAuthNameSpace As String, strPathWildCard As String) As Boolean
    
    On Error GoTo ErrMgr
    
    Dim objTextFile     As New cTextFile
    Dim strPath         As String
    Dim strWildCard     As String
    Dim objFiles        As New CVariables
    Dim objFile        As CVariable
    
'    Debug.Assert 0
    strPath = objTextFile.GetPathFromFileName(strPathWildCard)
    strWildCard = objTextFile.GetFileName(strPathWildCard)
    
    If objTextFile.GetFilesList(strPath, strWildCard, objFiles) Then
    
        For Each objFile In objFiles

            Me.ImportPriceLists objFile.Value, eImportMode, strCommandLine & " -file """ & objFile.Value & """ ", strAuthUserName, strAuthPassWord, strAuthNameSpace
        Next
    End If
    ImportPriceListMultiFile = True
TheExit:
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportPriceListMultiFile", LOG_ERROR
    TransactionAbort
End Function


Private Function InitRMPSupportedLanguageList(LocalizedEntity As Object) As Boolean

    On Error GoTo ErrMgr
    
    Dim objLanguage As Object
    
    If Not IsValidObject(m_objSupportedLanguageCodes) Then
    
'        Debug.Assert 0
        
        Set m_objSupportedLanguageCodes = New CVariables

        For Each objLanguage In LocalizedEntity
            
            m_objSupportedLanguageCodes.Add objLanguage.LanguageCode
        Next
    End If
    InitRMPSupportedLanguageList = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "InitRMPSupportedLanguageList", LOG_ERROR
End Function


Private Function GetUniqueList(objXMLUDRCs As IXMLDOMNodeList, strTag As String) As CVariables
        
On Error GoTo ErrMgr
            
    Dim UDRCNameList    As New CVariables
    Dim objXMLUDRC      As IXMLDOMNode
    Dim strName         As String
    
    For Each objXMLUDRC In objXMLUDRCs
    
        strName = objXMLUDRC.selectSingleNode(strTag).Text
        UDRCNameList.Add strName, strName
    Next
    Set GetUniqueList = UDRCNameList
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "GetUniqueList", LOG_ERROR
End Function


Private Function SetChargeAccount(objProductOffering As MTProductOffering, GroupSubscription As MTGroupSubscription, objAccountCatalog As MTYAACLib.MTAccountCatalog, strGroupSubscriptionName As String, objXMChargeAccounts As IXMLDOMNodeList, ChargeAccountPriceAbleItemNameList As CVariables, booSetOnlyFirstOne As Boolean) As Boolean

On Error GoTo ErrMgr

    Dim objXMChargeAccount          As IXMLDOMNode
    Dim strUserName                 As String
    Dim strNameSpace                As String
    Dim strPriceAbleInstanceName    As String
    Dim objMTYAAC                   As MTYAAC
    Dim objPriceAbleInstance        As MTPriceableItem
    Dim ChargeAccountPriceAbleItemName As CVariable
    Dim booDoIt                     As Boolean
    Dim lngItemCounter              As Long
    Dim lngPriceAbleInstanceID      As Long
    
    For Each ChargeAccountPriceAbleItemName In ChargeAccountPriceAbleItemNameList
    
        lngItemCounter = 0
        
        For Each objXMChargeAccount In objXMChargeAccounts
         
            strPriceAbleInstanceName = UCase$(objXMChargeAccount.selectSingleNode("priceableitemname").Text)
            
            If strPriceAbleInstanceName = UCase$(ChargeAccountPriceAbleItemName.Value) Then
            
                lngItemCounter = lngItemCounter + 1
            
                If booSetOnlyFirstOne Then
                    booDoIt = CBool(lngItemCounter = 1)
                Else
                    booDoIt = CBool(lngItemCounter > 1)
                End If
            
                If booDoIt Then
                
                    strUserName = objXMChargeAccount.selectSingleNode("username").Text
                    strNameSpace = objXMChargeAccount.selectSingleNode("namespace").Text
                    
                    On Error Resume Next
                    Set objMTYAAC = objAccountCatalog.GetAccountByName(strUserName, strNameSpace)
                    If Err.Number <> 0 Then
                     MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1036 & " " & GetVBErrorString(), "SUBNAME", strGroupSubscriptionName, "USERNAME", strNameSpace, "NAMESPACE", strNameSpace), Me, "ImportGroupSubscriptions", LOG_ERROR
                     Exit Function
                    End If
                    On Error GoTo ErrMgr
                             
                    Set objPriceAbleInstance = objProductOffering.GetPriceableItemByName(strPriceAbleInstanceName)
                    
                    If IsValidObject(objPriceAbleInstance) Then
                    
                         lngPriceAbleInstanceID = objPriceAbleInstance.ID
                         
                         ' 3.7 According Travis we must do that....
                         If booSetOnlyFirstOne Then
                         
                             GroupSubscription.SetChargeAccount lngPriceAbleInstanceID, objMTYAAC.AccountID, CDate(0), CDate(0)
                         Else
                             GroupSubscription.SetChargeAccount lngPriceAbleInstanceID, objMTYAAC.AccountID, objXMChargeAccount.selectSingleNode("startdate").Text, objXMChargeAccount.selectSingleNode("enddate").Text
                         End If
                         
                    Else
                         MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1037, "GSUBNAME", strGroupSubscriptionName, "PIINAME", strPriceAbleInstanceName), Me, "ImportGroupSubscriptions", LOG_ERROR
                         Exit Function
                    End If
                End If
            End If
         Next
     Next
     SetChargeAccount = True
     Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "SetChargeAccount", LOG_ERROR
End Function




Private Function ImportSubscriptionOrGroupSubUDRC(SubscriptionGroupSubscription As Object, objProductOffering As MTProductOffering, objXMLUDRCs As IXMLDOMNodeList, strSubscriptionGroupSubscriptionName As String, UDRCNameList As CVariables, booImportOnlyFirstOne As Boolean) As Boolean

    Dim objXMLUDRC                      As IXMLDOMNode
    Dim UDRCInstances                   As Variant
    Dim UDRCInstance                    As Variant
    Dim strUDRCName                     As String
    Dim varUDRCValue                    As Variant
    Dim strUDRCStartDate                As String
    Dim strUDRCEndDate                  As String
    Dim lngURDCInstanceID               As Long
    Dim UDRCName                        As CVariable
    Dim booDoIt                         As Boolean
    Dim lngItemCounter                  As Long
    

    'Set UDRCInstances = objProductOffering.GetPriceableItemsOfType(GetUDRCTypeID(Me.ProductCatalog))
    
    Set UDRCInstances = objProductOffering.GetPriceableItems

    For Each UDRCName In UDRCNameList
    
        lngItemCounter = 0
        
        For Each objXMLUDRC In objXMLUDRCs
        
            strUDRCName = UCase$(objXMLUDRC.selectSingleNode("name").Text)
            
            If strUDRCName = UCase$(UDRCName.Value) Then
            
                lngItemCounter = lngItemCounter + 1
            
                If booImportOnlyFirstOne Then
                    booDoIt = CBool(lngItemCounter = 1)
                Else
                    booDoIt = CBool(lngItemCounter > 1)
                End If
                
                If booDoIt Then
                
                    varUDRCValue = objXMLUDRC.selectSingleNode("value").Text
                    strUDRCStartDate = objXMLUDRC.selectSingleNode("startdate").Text
                    strUDRCEndDate = objXMLUDRC.selectSingleNode("enddate").Text
                    lngURDCInstanceID = 0
                    
                    'Find UDRC instance
                    For Each UDRCInstance In UDRCInstances
                      If UDRCInstance.Kind = PI_TYPE_RECURRING_UNIT_DEPENDENT Then
                        If UCase$(UDRCInstance.Name) = strUDRCName Then lngURDCInstanceID = UDRCInstance.ID: Exit For
                      End If
                    Next
                    
                    If lngURDCInstanceID Then
                    
                        If booImportOnlyFirstOne Then
                            SubscriptionGroupSubscription.SetRecurringChargeUnitValue lngURDCInstanceID, varUDRCValue, CDate(0), CDate(0)
                            'SubscriptionGroupSubscription.SetRecurringChargeUnitValue lngURDCInstanceID, varUDRCValue, strUDRCStartDate, strUDRCEndDate
                        Else
                            SubscriptionGroupSubscription.SetRecurringChargeUnitValue lngURDCInstanceID, varUDRCValue, strUDRCStartDate, strUDRCEndDate
                        End If
                    Else
                    
                        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1038, "SUB_NAME", strSubscriptionGroupSubscriptionName), Me, "ImportGroupSubscriptions", LOG_ERROR
                    End If
                End If
            End If
        Next
    Next
    ImportSubscriptionOrGroupSubUDRC = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportGroupSubscriptions", LOG_ERROR
End Function


Private Function DebugTrace(s As String)
    Debug.Print "DebugTrace:" & s
End Function


'BP: Attempt to handle IMTCollection properties in generic way
Public Function ImportCollectionProperties(objXMLObjectNode As IXMLDOMNode, PCCatalogObject As Object) As Boolean

    On Error GoTo ErrMgr
    Dim collections As IXMLDOMNodeList
    Dim collection As IXMLDOMNode
    Dim items As IXMLDOMNodeList
    Dim propname
    Dim coll_prop As IMTProperty
    Dim Item As Variant
    
    
    
    Debug.Print "ImportCollectionProperties: " & TypeName(PCCatalogObject)
    Set collections = objXMLObjectNode.selectNodes("collection")
    Debug.Print "ImportCollectionProperties detected: " & collections.Length & " collection properties"
    For Each collection In collections
        propname = collection.Attributes.getNamedItem("name").Text
        Set coll_prop = PCCatalogObject.Properties(propname)
        Set items = collection.selectNodes("item")
        For Each Item In items
            coll_prop.Value.Add Item.Text
        Next
    Next
    ImportCollectionProperties = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ImportCollectionProperties", LOG_ERROR
End Function

