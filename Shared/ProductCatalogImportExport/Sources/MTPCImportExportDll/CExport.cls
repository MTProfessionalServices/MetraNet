VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CExport"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private m_Stats                     As CImportExportStats
Private m_objCommandLine            As CCommandLine
Private m_objParamTableIntegrity    As CParamTableChks
Private m_enmExportMode             As IMPORT_EXPORT_MODE

Private m_objEnumConfig As MTENUMCONFIGLib.EnumConfig ' Force to hold a ref during the all import to keep the data in memory

Private m_objMTProductCatalog As MTProductCatalog
Private m_objMTSecurity As Object

Private m_objSessionContext         As IMTSessionContext

' This is duplicate code.  The other copy is in the CImportWriter Class Module.
'
' The code in CImportWriter should be kept in sync with this code.
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

Private Function ExportCounter(PriceAbleItem As MTPriceableItem) As Boolean

    On Error GoTo ErrMgr
    
    Dim CounterRowset               As IMTRowSet
    Dim lngCounterID                As Long
    Dim Counter                     As IMTCounter
    Dim CounterParameter            As MTCounterParameter
    Dim CounterPropertiesDefinition As MTCounterPropertyDefinition
    Dim i                           As Long
    Dim lngDistributionCPDID        As Long
    Dim IsGroupDiscountDistribution As Boolean
    Dim PriceAbleItemDiscount       As MTDiscount
    
    Set PriceAbleItemDiscount = PriceAbleItem
    Set CounterRowset = PriceAbleItem.GetCountersAsRowset()
    
    Debug.Assert 0
    
    If IsValidObject(PriceAbleItemDiscount.GetDistributionCounter()) Then
    
        lngDistributionCPDID = PriceAbleItemDiscount.GetDistributionCounter().ID
    Else
        lngDistributionCPDID = -1
    End If
    
    XMLOutPutTag "counters", XMLTAGTYPE_OPEN
    
    If CounterRowset.RecordCount Then
        
        Do While Not CounterRowset.EOF
        
            lngCounterID = CounterRowset.Value("id_prop")
            Set Counter = PriceAbleItem.GetCounter(lngCounterID)
            IsGroupDiscountDistribution = CBool(lngDistributionCPDID = Counter.ID)
            
            If IsValidObject(Counter) Then
            
                Set CounterPropertiesDefinition = ProductCatalog.GetCounterPropertyDefinition(lngCounterID)
                
                INFOOBJECT m_Stats.AddNewObject(Counter), "Export "
                
                If Not ExportObjectXMLHeaderAndProperties(Counter, XMLTAGTYPE_OPEN) Then Exit Function
                
                XMLOutPutTagValue "countertypename", Counter.Type.Name
                XMLOutPutTagValue "IsGroupDiscountDistribution", IsGroupDiscountDistribution
                            
                If Not ExportObjectXMLHeaderAndProperties(CounterPropertiesDefinition, XMLTAGTYPE_OPENCLOSE) Then Exit Function
                
                XMLOutPutTag "counterparameters", XMLTAGTYPE_OPEN
                
                If Counter.Parameters.Count > 0 Then
                
                    For i = 1 To Counter.Parameters.Count
                        
                        Set CounterParameter = Counter.Parameters.Item(i)
                        If Not ExportObjectXMLHeaderAndProperties(CounterParameter, XMLTAGTYPE_OPENCLOSE) Then Exit Function
                    Next
                End If
                
                XMLOutPutTag "counterparameters", XMLTAGTYPE_CLOSE
                
                XMLOutPutTag Counter, XMLTAGTYPE_CLOSE
            Else
                ' Counter Not set
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1001, "DISCOUNT", PriceAbleItem.Name, "COUNTERID", lngCounterID)
            End If
            
            CounterRowset.MoveNext
        Loop
    End If
    XMLOutPutTag "counters", XMLTAGTYPE_OPENCLOSE
    ExportCounter = True
Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportCounter", LOG_ERROR
End Function

' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : PriceableItemsInstances
' PARAMETERS    :
' DESCRIPTION   : If Parent = ProductOfferingParent this means we are dealing with the first level the PO level else we are deep
'                 in the children. we do need to carry the ProductOfferingParent, because we use this object to retreive the instances
'
' RETURN        :   TRUE.
Private Function ExportPriceableItemsInstances(Rowset As IMTRowSet, Parent As Object, ProductOfferingParent As MTProductOffering, Optional ByVal booIsChild As Boolean) As Boolean

    Dim PriceAbleItemInstance       As MTPriceableItem
    Dim ChildRowset                 As IMTRowSet
    'Dim Profiler                    As New CProfiler: Profiler.Start True, TypeName(Me), "PriceableItemsInstances"
    Dim strName                     As String
    
    On Error GoTo ErrMgr
    
    XMLOutPutTag "PriceAbleItemInstances", XMLTAGTYPE_OPEN
    
    Do While Not Rowset.EOF
    
        strName = Rowset.Value("nm_name")
        
        Set PriceAbleItemInstance = ProductOfferingParent.GetPriceableItemByName(strName)
        
        INFOOBJECT m_Stats.AddNewObject(PriceAbleItemInstance), "Export "
        
        If Not ExportObjectXMLHeaderAndProperties(PriceAbleItemInstance, XMLTAGTYPE_OPEN) Then Exit Function
        
        If Not ExportDisplayNames(PriceAbleItemInstance.DisplayNames) Then Exit Function
        
        If PriceAbleItemInstance.Kind = PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT Then
          If Not ExportUnitDisplayNames(PriceAbleItemInstance.UnitDisplayNames) Then Exit Function
        End If
        
        PricelistMappings PriceAbleItemInstance, ProductOfferingParent
        
'        Debug.Assert 0
        If Not ExportAdjustments(PriceAbleItemInstance.GetAdjustments, "Instance") Then Exit Function
        
        ' -- Export childrens
        Set ChildRowset = PriceAbleItemInstance.GetChildrenAsRowset
        
        If ChildRowset.RecordCount Then ' MARK-2002:07:09-2
        
            XMLOutPutTag "Children"
            ExportPriceableItemsInstances ChildRowset, PriceAbleItemInstance, ProductOfferingParent ' Recursive call to the function
            XMLOutPutTag "Children", XMLTAGTYPE_CLOSE
        End If
        
        
        
        XMLOutPutTag PriceAbleItemInstance, XMLTAGTYPE_CLOSE
        Rowset.MoveNext
    Loop
    XMLOutPutTag "PriceAbleItemInstances", XMLTAGTYPE_CLOSE
    ExportPriceableItemsInstances = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportPriceableItemsInstances", LOG_ERROR
End Function

Private Function PricelistMappings(PriceAbleItemTemplate As MTPriceableItem, ProductOffering As MTProductOffering) As Boolean

    Dim PriceListMapping            As MTPriceListMapping
    Dim PriceList                   As MTPriceList
    Dim Rowset                      As IMTRowSet
    Dim PriceListMappingRowSet      As IMTRowSet
    'Dim Profiler                    As New CProfiler: Profiler.Start True, TypeName(Me), "ExportPricelistMappings"
    Dim strName                     As String
    Dim ParamTableDefinition        As MTParamTableDefinition
    Dim strWarning                  As String
    Dim strPriceListMappingAttrName As String
    
    
    Const PRICELISTMAPPING_EXCLUDE_PROPERTIES = ",MAPPINGTYPE,"
    
    On Error GoTo ErrMgr
    
    Set PriceListMappingRowSet = PriceAbleItemTemplate.GetNonICBPriceListMappingsAsRowset()
    
    'MARK-2002:07:09-1 - Do not remove this mark it reference some code in the CImport class
    ' Write the tag before we check the number of record in the rowset.
    XMLOutPutTag "pricelistmappings"
    
    If PriceListMappingRowSet.RecordCount Then
    
        Do While Not PriceListMappingRowSet.EOF
        
            Set PriceListMapping = PriceAbleItemTemplate.GetPriceListMapping(PriceListMappingRowSet.Value("id_paramtable"))
            
            m_Stats.AddNewObject PriceListMapping
            
            Set ParamTableDefinition = ProductCatalog.GetParamTableDefinition(PriceListMapping.ParamTableDefinitionID)
            m_objParamTableIntegrity.Add ParamTableDefinition
            
            strPriceListMappingAttrName = PriceAbleItemTemplate.Name & ":" & ParamTableDefinition.Name ' #3.7 This is exported to unit test purpose only
            If Not ExportObjectXMLHeaderAndProperties(PriceListMapping, XMLTAGTYPE_OPEN, strPriceListMappingAttrName, PRICELISTMAPPING_EXCLUDE_PROPERTIES) Then Exit Function
            
            XMLOutPutTagValue "ParamTableDefinitionName", ParamTableDefinition.Name
            
            If PriceListMapping.PriceListID = -1 Then
            
                strWarning = PreProcess(MTPCImportExport_WARNING_1001, "PRODUCTOFFERING", ProductOffering.Name, "PARAMETERTABLE", ParamTableDefinition.Name, "PRICEABLEITEM", PriceAbleItemTemplate.Name)
                XMLOutPutComment = strWarning
                MTPCImportExportModule.TRACE strWarning, Me, "PricelistMappings", LOG_WARNING
            Else
                Set PriceList = ProductCatalog.GetPriceList(PriceListMapping.PriceListID)
                XMLOutPutTagValue "PriceListName", PriceList.Name
            End If
            
            XMLOutPutTag PriceListMapping, XMLTAGTYPE_CLOSE
            
            PriceListMappingRowSet.MoveNext
        Loop
    End If
    
    XMLOutPutTag "pricelistmappings", XMLTAGTYPE_CLOSE
    
    PricelistMappings = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "PricelistMappings", LOG_ERROR
End Function


Private Function ExportCalendar(ByVal lngCalendarID As Long) As Boolean

    Dim Rowset              As IMTRowSet
    Dim Calendar            As MTCalendar
    Dim CalendarPeriode     As MTCalendarPeriod
    Dim CalendarHoliday     As IMTCalendarHoliday
    Dim CalendarWeekday     As MTCalendarWeekday
    Dim i                   As Long
    Dim s                   As String
    
    On Error GoTo ErrMgr
    
    Set Calendar = ProductCatalog.GetCalendar(lngCalendarID)
    
    XMLOutPutTag "calendar", XMLTAGTYPE_OPEN, Calendar.Name
    
    INFOOBJECT m_Stats.AddNewObject(Calendar), "Export "
    
    XMLOutPutTagValue "ID", Calendar.ID
    XMLOutPutTagValue "Description", Calendar.Description
    XMLOutPutTagValue "Name", Calendar.Name
    Calendar.TimezoneOffset = 3
    Calendar.CombinedWeekend = False
    

    ' Generate Holiday
    XMLOutPutTag Calendar.GetHolidays(), , "Holidays"
    
    For Each CalendarHoliday In Calendar.GetHolidays()
    
        If Not ExportObjectXMLHeaderAndProperties(CalendarHoliday, XMLTAGTYPE_OPEN, , ",CODE,") Then Exit Function
        XMLOutPutTagValue "CodeFQN", GetCalendarEnumTypeFQNFromValue(CalendarHoliday.Code)
                
        If CalendarHoliday.GetPeriods().Count Then ' Collection of calendar periode
        
            XMLOutPutTag "calendarperiods"
            
            For Each CalendarPeriode In CalendarHoliday.GetPeriods()
            
                XMLOutPutTag CalendarPeriode, XMLTAGTYPE_OPEN
                
                    XMLOutPutTagValue "id", CalendarPeriode.ID
                    XMLOutPutTagValue "code", CalendarPeriode.Code
                    XMLOutPutTagValue "CodeFQN", GetCalendarEnumTypeFQNFromValue(CalendarPeriode.Code)
                    XMLOutPutTagValue "starttime", CalendarPeriode.StartTime
                    XMLOutPutTagValue "endtime", CalendarPeriode.EndTime
                XMLOutPutTag CalendarPeriode, XMLTAGTYPE_CLOSE
            Next
            XMLOutPutTag "calendarperiods", XMLTAGTYPE_CLOSE
        End If
        
        XMLOutPutTag CalendarHoliday, XMLTAGTYPE_CLOSE
    Next
    XMLOutPutTag Calendar.GetHolidays(), XMLTAGTYPE_CLOSE
    
'    Debug.Assert 0
    
    ' Generate WeekDay
    XMLOutPutTag Calendar.GetWeekdays(), , "WeekDays"
    
    For Each CalendarWeekday In Calendar.GetWeekdays()
    
        If Not ExportObjectXMLHeaderAndProperties(CalendarWeekday, XMLTAGTYPE_OPEN, CalendarWeekday.DayOfWeek, ",CODE,") Then Exit Function
        
        XMLOutPutTagValue "CodeFQN", GetCalendarEnumTypeFQNFromValue(CalendarWeekday.Code)
                
        If CalendarWeekday.GetPeriods().Count Then ' Collection of calendar periode
        
            XMLOutPutTag "calendarperiods"
            
            For Each CalendarPeriode In CalendarWeekday.GetPeriods()
            
                XMLOutPutTag CalendarPeriode, XMLTAGTYPE_OPEN
            
                XMLOutPutTagValue "id", CalendarPeriode.ID
                XMLOutPutTagValue "code", CalendarPeriode.Code
                XMLOutPutTagValue "CodeFQN", GetCalendarEnumTypeFQNFromValue(CalendarPeriode.Code)
                XMLOutPutTagValue "starttime", CalendarPeriode.StartTime
                XMLOutPutTagValue "endtime", CalendarPeriode.EndTime
                    
                XMLOutPutTag CalendarPeriode, XMLTAGTYPE_CLOSE
            Next
            XMLOutPutTag "calendarperiods", XMLTAGTYPE_CLOSE
        End If
        XMLOutPutTag CalendarWeekday, XMLTAGTYPE_CLOSE
    Next
    XMLOutPutTag Calendar.GetWeekdays(), XMLTAGTYPE_CLOSE

    XMLOutPutTag "calendar", XMLTAGTYPE_CLOSE
    
    ExportCalendar = True
    
    Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportCalendar", LOG_ERROR
End Function

Public Function ExportProductOfferingMultiFile(ByVal strPath As String, ByVal strProductOfferingNames As String, ByVal eExportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String) As Boolean
    
    Dim objProductOffering          As MTProductOffering
    Dim objProductOfferingNames     As collection
    Dim varProductOfferingName      As Variant
    Dim strXMLFileName              As String
    
    On Error GoTo ErrMgr
    
'    Debug.Assert 0
    
    Set objProductOfferingNames = GetListOfProductOffering(strProductOfferingNames)
    If Not IsValidObject(objProductOfferingNames) Then
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1017, "COMMANDLINE-VALUE", strProductOfferingNames), Me, "ExportProductOffering", LOG_ERROR
        Exit Function
    End If
    
    For Each varProductOfferingName In objProductOfferingNames
    
        strXMLFileName = strPath & "\" & CheckFileName(varProductOfferingName) & ".xml"
        
        If (Not ExportProductOffering(strXMLFileName, varProductOfferingName, eExportMode, strCommandLine)) Then
        
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1022, "PO", varProductOfferingName), Me, "ExportProductOfferingMultiFile", LOG_ERROR
        End If
    Next
    
    ExportProductOfferingMultiFile = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportProductOfferingMultiFile", LOG_ERROR
End Function

Public Function ExportProductOffering(ByVal strXMLFileName As String, ByVal strProductOfferingNames As String, ByVal eExportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String) As Boolean

    Dim Rowset                      As IMTRowSet
    Dim objProductOffering          As MTProductOffering
    Dim objProductOfferingNames     As collection
    Dim lngPriceListID              As Long
    Dim strName                     As String
    Dim PriceAbleItemInstamceRowset As IMTRowSet
    Dim Profiler                    As New CProfiler: Profiler.Start True, TypeName(Me), "ProductOffering"
    Dim varProductOfferingName      As Variant
    Dim objCommandLine              As New CCommandLine
    
    On Error GoTo ErrMgr
    
    Debug.Assert 0

    ExportInit eExportMode, strCommandLine
    XMLOutputInitialize
    XMLOutPutTag "productofferings"
     
    Set objProductOfferingNames = GetListOfProductOffering(strProductOfferingNames)
    
    If Not IsValidObject(objProductOfferingNames) Then
    
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1017, "COMMANDLINE-VALUE", strProductOfferingNames), Me, "ExportProductOffering", LOG_ERROR
        Exit Function
    End If
        
    For Each varProductOfferingName In objProductOfferingNames
        
        PrintConsole vbNewLine & "Export Product Offering " & varProductOfferingName
    
        Set objProductOffering = ProductCatalog.GetProductOfferingByName(varProductOfferingName)
        If Not IsValidObject(objProductOffering) Then
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1016, "PRODUCT_OFFERING", varProductOfferingName), Me, "ExportSubscriptions", LOG_ERROR
            Exit Function
        End If
        
        INFOOBJECT m_Stats.AddNewObject(objProductOffering), "Export "
        
        XMLOutPutTag objProductOffering, , objProductOffering.Name
        
'    Debug.Assert 0
        If Not ExportDisplayNames(objProductOffering.DisplayNames) Then Exit Function
        If Not ExportDisplayDescriptions(objProductOffering.DisplayDescriptions) Then Exit Function

        XMLOutPutTagValue "currency", objProductOffering.GetCurrencyCode()
        If Not ExportObjectXMLHeaderAndProperties(objProductOffering, XMLTAGTYPE_NONE) Then Exit Function   ' do not close the tag
                
        XMLOutPutTagValue "ExportPriceAbleItemInstanceOnly", m_objCommandLine.getValue("-ExportPriceAbleItemInstanceOnly", False)
        
        If Not m_objCommandLine.getValue("-ExportPriceAbleItemInstanceOnly", False) Then
            
            ObjectsUsedByProductOffering objProductOffering ' Export PriceList, PriceAbleItem, RateSchedule, Rate, Calendar used by a Product offering
        End If
        
        ' Export the PriceAbleInstance
        ExportPriceableItemsInstances objProductOffering.GetPriceableItemsAsRowset, objProductOffering, objProductOffering
        
        If Not m_objCommandLine.getValue("-ExportDynamicExtendedProperties", False) Then
        
            ExportDynamicExtendedPropertiesForPO objProductOffering.ID
        
        End If
        
        XMLOutPutTag objProductOffering, XMLTAGTYPE_CLOSE
    Next
    XMLOutPutTag "productofferings", XMLTAGTYPE_CLOSE
    ExportTerminate
'        Debug.Assert 0

    ExportProductOffering = SaveXMLOutPut(strXMLFileName)

    
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ProductOffering", LOG_ERROR

End Function

Private Function ExportDynamicExtendedPropertiesForPO(productOfferingID As Long) As Boolean

    On Error GoTo ErrMgr
    
    Dim Rowset As IMTRowSet
 
    PrintConsole vbNewLine & "Export Dynamic Extended Properties for Product Offering"
 
    Set Rowset = ExecuteQuery("__GET_DYNAMIC_EXTENDED_PROPERTIES_FOR_PO__", "PO_ID", productOfferingID)
    
    XMLOutPutTag "DynamicExtendedProperties"
    
    Do While Not Rowset.EOF
    
        XMLOutPutTag "SpecificationCharacteristic"
    
        XMLOutPutPropertyNameValue "property", "c_spec_type", Rowset.Value("c_spec_type")
        XMLOutPutPropertyNameValue "property", "id_category", Rowset.Value("id_category")
        XMLOutPutPropertyNameValue "property", "c_category", IIf(IsNull(Rowset.Value("c_category")), "", Rowset.Value("c_category"))
        XMLOutPutPropertyNameValue "property", "c_is_required", Rowset.Value("c_is_required")
        XMLOutPutPropertyNameValue "property", "nm_name", IIf(IsNull(Rowset.Value("nm_name")), "", Rowset.Value("nm_name"))
        XMLOutPutPropertyNameValue "property", "nm_description", IIf(IsNull(Rowset.Value("nm_description")), "", Rowset.Value("nm_description"))
        XMLOutPutPropertyNameValue "property", "c_user_visible", Rowset.Value("c_user_visible")
        XMLOutPutPropertyNameValue "property", "c_user_editable", Rowset.Value("c_user_editable")
        XMLOutPutPropertyNameValue "property", "c_min_value", IIf(IsNull(Rowset.Value("c_min_value")), "", Rowset.Value("c_min_value"))
        XMLOutPutPropertyNameValue "property", "c_max_value", IIf(IsNull(Rowset.Value("c_max_value")), "", Rowset.Value("c_max_value"))
        
        ExportLocalizedValues Rowset.Value("n_name"), "SpecificationCharacteristicLocalizedNames"
        
        ExportLocalizedValues Rowset.Value("n_description"), "SpecificationCharacteristicLocalizedDescription"
        
        ExportSpecCharValuesForPO Rowset.Value("id_spec")
        
        XMLOutPutTag "SpecificationCharacteristic", XMLTAGTYPE_CLOSE
        
        Rowset.MoveNext
    Loop
    
    XMLOutPutTag "DynamicExtendedProperties", XMLTAGTYPE_CLOSE

    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExtendedProperties", LOG_ERROR
End Function

Private Function ExportSpecCharValuesForPO(specID As Long) As Boolean

    On Error GoTo ErrMgr
    
    Dim Rowset As IMTRowSet
 
    PrintConsole vbNewLine & "Export Specification Characteristic for Product Offering"
 
    Set Rowset = ExecuteQuery("__GET_SPECIFICATION_CHARACTERISTIC_FOR_PO__", "SPEC_ID", specID)
    
    XMLOutPutTag "SpecCharValues"
    
    Do While Not Rowset.EOF
    
        XMLOutPutTag "SpecCharValue"
    
        XMLOutPutPropertyNameValue "property", "c_is_default", Rowset.Value("c_is_default")
        XMLOutPutPropertyNameValue "property", "nm_value", Rowset.Value("nm_value")
        
        ExportLocalizedValues Rowset.Value("n_value"), "LocalizedSpecCharValue"
        
        XMLOutPutTag "SpecCharValue", XMLTAGTYPE_CLOSE
        
        Rowset.MoveNext
    Loop
    
    XMLOutPutTag "SpecCharValues", XMLTAGTYPE_CLOSE
    
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "SpecificationCharacteristics", LOG_ERROR
End Function
Private Function ExportDynamicExtendedPropertiesForSubscription(subscriptionID As Long) As Boolean

    On Error GoTo ErrMgr
    
    Dim Rowset As IMTRowSet
 
    PrintConsole vbNewLine & "Export Specification Characteristic for Product Offering"
 
    Set Rowset = ExecuteQuery("__GET_DYNAMIC_EXTENDED_PROPERTIES_FOR_SUBSCRIPTION__", "SUBSCRIPTION_ID", subscriptionID)
    
    XMLOutPutTag "CharValues"
    
    Do While Not Rowset.EOF
    
        XMLOutPutTag "CharValue"
    
        XMLOutPutPropertyNameValue "property", "id_scv", Rowset.Value("id_scv")
        XMLOutPutPropertyNameValue "property", "nm_value", IIf(IsNull(Rowset.Value("nm_value")), "", Rowset.Value("nm_value"))
        XMLOutPutPropertyNameValue "property", "c_start_date", Rowset.Value("c_start_date")
        XMLOutPutPropertyNameValue "property", "c_end_date", IIf(IsNull(Rowset.Value("c_end_date")), "", Rowset.Value("c_end_date"))
        XMLOutPutPropertyNameValue "property", "c_spec_name", Rowset.Value("c_spec_name")
        XMLOutPutPropertyNameValue "property", "c_spec_type", Rowset.Value("c_spec_type")
        
        XMLOutPutTag "CharValue", XMLTAGTYPE_CLOSE
        
        Rowset.MoveNext
    Loop
    
    XMLOutPutTag "CharValues", XMLTAGTYPE_CLOSE
    
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "SpecificationCharacteristics", LOG_ERROR
End Function
Private Function ExportLocalizedValues(descriptionID As Long, valueTypeTag As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim objLanguage As Object
    Dim Rowset As IMTRowSet
    
    XMLOutPutTag valueTypeTag
 
    Set Rowset = ExecuteQuery("__GET_LOCALIZED_VALUES__", "DESC_ID", descriptionID)
    
    Do While Not Rowset.EOF
    
        XMLOutPutPropertyNameValue "language", Rowset.Value("tx_lang_code"), Rowset.Value("tx_desc"), , True
        
        Rowset.MoveNext
    Loop
    
    XMLOutPutTag valueTypeTag, XMLTAGTYPE_CLOSE
    ExportLocalizedValues = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportDisplayNames", LOG_ERROR
End Function

Private Function ExportDisplayNames(LocalizedEntity As Object) As Boolean

    On Error GoTo ErrMgr
    
    Dim objLanguage As Object
    
    XMLOutPutTag "DisplayNames"
    
    For Each objLanguage In LocalizedEntity
  
        XMLOutPutPropertyNameValue "language", objLanguage.LanguageCode, objLanguage.Value, , True
    Next
    
    XMLOutPutTag "DisplayNames", XMLTAGTYPE_CLOSE
    ExportDisplayNames = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportDisplayNames", LOG_ERROR
End Function
Private Function ExportUnitDisplayNames(LocalizedEntity As Object) As Boolean

    On Error GoTo ErrMgr
    
    Dim objLanguage As Object
    
    XMLOutPutTag "UnitDisplayNames"
    
    For Each objLanguage In LocalizedEntity
  
        XMLOutPutPropertyNameValue "language", objLanguage.LanguageCode, objLanguage.Value, , True
    Next
    XMLOutPutTag "UnitDisplayNames", XMLTAGTYPE_CLOSE
    ExportUnitDisplayNames = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportUnitDisplayNames", LOG_ERROR
End Function
Private Function ExportDisplayDescriptions(LocalizedEntity As Object) As Boolean

    On Error GoTo ErrMgr
    
    Dim objLanguage As Object
    
    XMLOutPutTag "DisplayDescriptions"
    
    For Each objLanguage In LocalizedEntity
  
        XMLOutPutPropertyNameValue "language", objLanguage.LanguageCode, objLanguage.Value, , True
    Next
    XMLOutPutTag "DisplayDescriptions", XMLTAGTYPE_CLOSE
    ExportDisplayDescriptions = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportDisplayDescriptions", LOG_ERROR
End Function




' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ObjectsUsedByProductOffering
' PARAMETERS    :
' DESCRIPTION   : Export PriceList, PriceAbleItem, RateSchedule, Rate, Calendar used by a Product offering
' RETURN        :
Private Function ObjectsUsedByProductOffering(ProductOffering As MTProductOffering) As Boolean
    
    On Error GoTo ErrMgr
            
    PrintConsole vbNewLine & "Export PriceAbleItems Template"
    XMLOutPutComment = "PriceAbleItems Template used by product offering " & ProductOffering.Name
    If Not ExportPriceAbleItemTemplateUsedBy(ProductOffering, True) Then Exit Function

    PrintConsole vbNewLine & "Export PriceList"
    XMLOutPutComment = "PriceLists used by product offering " & ProductOffering.Name
    If Not ExportPriceListFromProductOffering(ProductOffering, ProductOffering) Then Exit Function
    
    PrintConsole vbNewLine & "Export Calendar"
    XMLOutPutComment = "Calendar used by product offering " & ProductOffering.Name
    If Not ExportCalendarFromProductOffering(ProductOffering, True) Then Exit Function
    
    PrintConsole vbNewLine & "Export RateSchedules"
    XMLOutPutComment = "RateSchedules used by product offering " & ProductOffering.Name
    If Not ExportRateScheduleUsedBy(ProductOffering, ProductOffering) Then Exit Function

    XMLOutPutComment = "product offering " & ProductOffering.Name & " description"
    
    ObjectsUsedByProductOffering = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ObjectsUsedByProductOffering", LOG_ERROR
End Function

Private Function ExportPriceListFromProductOffering(ProductOffering As MTProductOffering, ProductOfferingParent As MTProductOffering, Optional ByVal PriceListIDs As collection) As Boolean
    
    Dim PriceAbleItemInstance       As MTPriceableItem
    Dim ChildRowset                 As IMTRowSet
    Dim strName                     As String
    Dim i                           As Long
    
    Dim PriceListID                 As Variant
    Dim PriceList                   As MTPriceList
    
    On Error GoTo ErrMgr

    If PriceListIDs Is Nothing Then
        If Not GetIDsFromQuery("__GET_PRICELIST_IDS_USED_BY_PO__", ProductOffering.ID, PriceListIDs) Then Exit Function
    End If
    
    XMLOutPutTag "pricelists"
    For Each PriceListID In PriceListIDs

        Set PriceList = ProductCatalog.GetPriceList(PriceListID)
        
        If (PriceList.Type = PRICELIST_TYPE_REGULAR) Then
        
            INFOOBJECT m_Stats.AddNewObject(PriceList), "Export "
            If Not ExportObjectXMLHeaderAndProperties(PriceList, XMLTAGTYPE_OPENCLOSE) Then Exit Function
        End If
        If (PriceList.Type = PRICELIST_TYPE_PO) Then ' Private price liste
        
            INFOOBJECT m_Stats.AddNewObject(PriceList), "Export "
            If Not ExportObjectXMLHeaderAndProperties(PriceList, XMLTAGTYPE_OPENCLOSE, , , "private=true") Then Exit Function
        End If
    Next
    XMLOutPutTag "pricelists", XMLTAGTYPE_CLOSE

    ExportPriceListFromProductOffering = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportPriceListFromProductOffering", LOG_ERROR
End Function

Private Function ExportPriceAbleItemTemplateUsedBy(ProductOfferingOrPriceList As Object, ByVal booFromProductOffering As Boolean) As Boolean
    
    Dim PriceAbleItemInstance       As MTPriceableItem
    Dim ChildRowset                 As IMTRowSet
    Dim strName                     As String
    Dim i                           As Long
    Dim PriceAbleItemTemplateIDs    As collection
    Dim PriceAbleItemTemplateID     As Variant
    Dim PriceAbleItemTemplate       As MTPriceableItem
    
    On Error GoTo ErrMgr

    If booFromProductOffering Then
        If Not GetIDsFromQuery("__GET_PRICEABLEITEM_TEMPLATE_IDS_USED_BY_PO__", ProductOfferingOrPriceList.ID, PriceAbleItemTemplateIDs) Then Exit Function
    Else
        If Not GetIDsFromQuery("__GET_PRICEABLEITEM_TEMPLATE_IDS_USED_BY_PRICE_LIST__", ProductOfferingOrPriceList.ID, PriceAbleItemTemplateIDs) Then Exit Function
    End If
    
    XMLOutPutTag "PriceAbleItemTemplates"
    
    For Each PriceAbleItemTemplateID In PriceAbleItemTemplateIDs

        Set PriceAbleItemTemplate = ProductCatalog.GetPriceableItem(PriceAbleItemTemplateID)
        ExportPriceAbleItemTemplate PriceAbleItemTemplate
    Next
    XMLOutPutTag "PriceAbleItemTemplates", XMLTAGTYPE_CLOSE

    ExportPriceAbleItemTemplateUsedBy = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportPriceAbleItemTemplateUsedBy", LOG_ERROR
End Function


Private Function GetIDsFromQuery(strQueryName As String, lngID As Long, IDs As collection) As Boolean

    On Error GoTo ErrMgr
    
    Dim Rowset As IMTRowSet
    
    Set Rowset = ExecuteQuery(strQueryName, "ID", lngID)
    If Not IsValidObject(Rowset) Then Exit Function
    
    Set IDs = New collection
    
    Do While Not Rowset.EOF
    
        If Not IsNull(Rowset.Value("id")) Then
            IDs.Add Rowset.Value("id")
        End If
        Rowset.MoveNext
    Loop
    GetIDsFromQuery = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "GetIDsFromQuery", LOG_ERROR
End Function


Public Function ExportPriceAbleItemTemplate(PriceAbleItemTemplate As MTPriceableItem) As Boolean

    On Error GoTo ErrMgr
    
    Dim PCEntityType As MTPCEntityType
        
    PCEntityType = PriceAbleItemTemplate.Kind
            
    If PCEntityType = PCENTITY_TYPE_AGGREGATE_CHARGE Or PCEntityType = PCENTITY_TYPE_USAGE Then
    
        ' We do not export this kind of price able item template
        XMLOutPutComment = "PriceAbleItem Template kind PCENTITY_TYPE_AGGREGATE_CHARGE or PCENTITY_TYPE_USAGE are never imported. PriceAbleItemTemplate=" & PriceAbleItemTemplate.Name
        
    Else
    
    
        XMLOutPutTag PriceAbleItemTemplate, XMLTAGTYPE_OPEN, PriceAbleItemTemplate.Name
        
        INFOOBJECT m_Stats.AddNewObject(PriceAbleItemTemplate), "Export PriceAbleItemTemplate "
    
        ' Do not close the XML tag because we have children and counter
        If Not ExportObjectXMLHeaderAndProperties(PriceAbleItemTemplate, XMLTAGTYPE_NONE) Then Exit Function
        
        If Not ExportDisplayNames(PriceAbleItemTemplate.DisplayNames) Then Exit Function
    
        If PriceAbleItemTemplate.Kind = PCENTITY_TYPE_DISCOUNT Then
        
            ExportCounter PriceAbleItemTemplate
        End If
        ' Adjustment Template
        If Not ExportAdjustments(PriceAbleItemTemplate.GetAdjustments, "Template") Then Exit Function
        
        XMLOutPutTag PriceAbleItemTemplate, XMLTAGTYPE_CLOSE
    End If
    ExportPriceAbleItemTemplate = True

Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportPriceAbleItemTemplate", LOG_ERROR
End Function

Private Function ExportAdjustments(Adjustments As IMTCollection, ByVal strAdjustmentCategory) As Boolean

    On Error GoTo ErrMgr
'    Debug.Assert 0

    Dim objAdjustment As Adjustment

    XMLOutPutTag "Adjustments", XMLTAGTYPE_OPEN, , , "type=" & strAdjustmentCategory

    For Each objAdjustment In Adjustments

        INFOOBJECT objAdjustment, "Export "
    
        If Not ExportObjectXMLHeaderAndProperties(objAdjustment, XMLTAGTYPE_OPEN) Then Exit Function ' do not close the tag
        
        If Not ExportDisplayNames(objAdjustment.DisplayNames) Then Exit Function
        
        If strAdjustmentCategory = "Template" Then
        
            If Not ExportReasonCodes(objAdjustment.GetApplicableReasonCodes()) Then Exit Function
        End If
        
        
        XMLOutPutTag objAdjustment, XMLTAGTYPE_CLOSE
    Next
    XMLOutPutTag "Adjustments", XMLTAGTYPE_CLOSE
    
    ExportAdjustments = True

Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportAdjustments", LOG_ERROR
End Function

Private Function ExportReasonCodes(ReasonCodes As IMTCollection) As Boolean

    On Error GoTo ErrMgr
'    Debug.Assert 0

    Dim objReasonCode As ReasonCode

    XMLOutPutTag "ReasonCodes", XMLTAGTYPE_OPEN

    For Each objReasonCode In ReasonCodes
    
        'INFOOBJECT objReasonCode, "Export "
        If Not ExportObjectXMLHeaderAndProperties(objReasonCode, XMLTAGTYPE_OPEN) Then Exit Function ' do not close the tag

        If Not ExportDisplayNames(objReasonCode.DisplayNames) Then Exit Function
        
        XMLOutPutTag objReasonCode, XMLTAGTYPE_CLOSE
    Next
    XMLOutPutTag "ReasonCodes", XMLTAGTYPE_CLOSE
    ExportReasonCodes = True

Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportReasonCode", LOG_ERROR
End Function


Private Function LoadRateSchedule(ByVal lngRateScheduleID) As MTRateSchedule

    On Error GoTo ErrMgr
    
    Dim Rowset                          As IMTRowSet
    Dim ParamTableDefinition            As MTParamTableDefinition
    
    Set Rowset = ExecuteQuery("__GET_ONE_RATESCHEDULE__", "RS_ID", lngRateScheduleID)
    If Not IsValidObject(Rowset) Then Exit Function
    
    Set ParamTableDefinition = ProductCatalog.GetParamTableDefinition(Rowset.Value("id_pt"))
    Set LoadRateSchedule = ParamTableDefinition.GetRateSchedule(Rowset.Value("id_sched"))
    
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "LoadRateSchedule", LOG_ERROR
End Function

'
' RateScheduleIDS and booExportPriceList are use when we export a rate schedule only! Not from a product offering.
'
Private Function ExportRateScheduleUsedBy(ProductOffering As MTProductOffering, ProductOfferingParent As MTProductOffering, Optional RateScheduleIDS As collection = Nothing, Optional ByVal booExportPriceList As Boolean) As Boolean
    
    Dim PriceAbleItemInstance           As MTPriceableItem
    Dim PriceList                       As MTPriceList
    Dim ParamTableDefinition            As MTParamTableDefinition
    Dim RateScheduleID                  As Variant
    Dim RateSchedule                    As MTRateSchedule
    Dim Rowset                          As IMTRowSet
    Dim strXML                          As String
    Dim strRateScheduleID               As String
    Dim arrRateScheduleID               As Variant ' Same as strRateScheduleID  but each item in an array
    Dim lngDefaultActionsCount          As Long
    Dim strCalendarID                   As String
    Dim lngStartPos                     As Long
    Dim lngEndPos                       As Long
    Dim strCalendarName                 As String
    Dim PriceListIDs                    As collection
    
    Const RATESCHEDULE_EXCLUDE_PROPERTIES = ",MAPPINGTYPE,"
    
    On Error GoTo ErrMgr

    If RateScheduleIDS Is Nothing Then
        If Not GetIDsFromQuery("__GET_RATESCHEDULE_IDS_USED_BY_PO__", ProductOffering.ID, RateScheduleIDS) Then Exit Function
    End If
    
    XMLOutPutTag "RateSchedules"
    
    For Each RateScheduleID In RateScheduleIDS
    
        Set Rowset = ExecuteQuery("__GET_ONE_RATESCHEDULE__", "RS_ID", RateScheduleID)
        If Not IsValidObject(Rowset) Then Exit Function
    
        Set PriceList = ProductCatalog.GetPriceList(Rowset.Value("id_pricelist"))
        
        Set ParamTableDefinition = ProductCatalog.GetParamTableDefinition(Rowset.Value("id_pt"))
        m_objParamTableIntegrity.Add ParamTableDefinition
        
        Set RateSchedule = ParamTableDefinition.GetRateSchedule(Rowset.Value("id_sched"))
        
        ' Make an id for the rate schedule
        strRateScheduleID = GetRateScheduleExtId(Me.ProductCatalog, RateSchedule, PriceList, ParamTableDefinition.Name)
        Debug.Print strRateScheduleID
        
        INFOOBJECT m_Stats.AddNewObject(RateSchedule, strRateScheduleID), "Export "
        
        XMLOutPutTag RateSchedule, XMLTAGTYPE_OPEN, strRateScheduleID
       
        ' -- When we export RateSchedule without Product Offering we also export the price list
        If booExportPriceList Then
        
            Set PriceListIDs = New collection
            PriceListIDs.Add PriceList.ID
            ExportPriceListFromProductOffering Nothing, Nothing, PriceListIDs
        End If
        
        If Not ExportObjectXMLHeaderAndProperties(RateSchedule, XMLTAGTYPE_NONE, , RATESCHEDULE_EXCLUDE_PROPERTIES) Then Exit Function
        
        arrRateScheduleID = Split(strRateScheduleID, ID_SEPARATOR)
        
        ' Generate the name of the following because we do not care about the id
        XMLOutPutTagValue "priceableitemname", arrRateScheduleID(0)
        XMLOutPutTagValue "parametertablename", arrRateScheduleID(1)
        XMLOutPutTagValue "pricelistname", arrRateScheduleID(2)
        
        'RateSchedule.TemplateID
        
        lngDefaultActionsCount = 0
        
        If IsValidObject(RateSchedule.RuleSet.DefaultActions) Then
        
            lngDefaultActionsCount = RateSchedule.RuleSet.DefaultActions.Count
        End If
                
        XMLOutPutTagValue "defaultactionscount", lngDefaultActionsCount
        XMLOutPutTagValue "rulesetcount", RateSchedule.RuleSet.Count
        
        XMLOutPutTag "ruleset", XMLTAGTYPE_OPEN
                
        If RateSchedule.RuleSet.Count Or lngDefaultActionsCount Then
        
                XMLOutPut = "<![CDATA["
            
                strXML = RateSchedule.RuleSet.WriteToSet().WriteToBuffer
                strXML = Replace(strXML, XML_XML_TAG, "")
                
                ' Strip the calendar id and replace it with the calendar name
                
      If UCase$(ParamTableDefinition.Name) = UCase$(CALENDAR_PARAMETER_TABLE_NAME) Then

        Const CALENDAR_ID_XML_TAG_START = "<prop_value ptype=""INTEGER"">"
        Const CALENDAR_ID_XML_TAG_END = "</prop_value>"

        lngStartPos = InStr(strXML, CALENDAR_ID_XML_TAG_START)
        lngEndPos = InStr(lngStartPos, strXML, CALENDAR_ID_XML_TAG_END)
        strCalendarID = Mid(strXML, lngStartPos + Len(CALENDAR_ID_XML_TAG_START), lngEndPos - lngStartPos - Len(CALENDAR_ID_XML_TAG_START))

        strCalendarName = ProductCatalog.GetCalendar(CLng(strCalendarID)).Name

        strXML = Mid(strXML, 1, lngStartPos + Len(CALENDAR_ID_XML_TAG_START) - 1) & "|" & strCalendarName & "|" & Mid(strXML, lngEndPos)
      End If
                XMLOutPut = strXML
                XMLOutPut = "]]>"
        Else
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_WARNING_1002, "RATESCHEDULE", strRateScheduleID), Me, "ImportRateScheduleForProductOffering", LOG_WARNING
        End If
        XMLOutPutTag "ruleset", XMLTAGTYPE_CLOSE
        XMLOutPutTag RateSchedule, XMLTAGTYPE_CLOSE
    Next
    XMLOutPutTag "RateSchedules", XMLTAGTYPE_CLOSE

    ExportRateScheduleUsedBy = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportRateScheduleUsedBy", LOG_ERROR
End Function

Private Function ExportCalendarFromProductOffering(ProductOfferingOrPriceList As Object, booProductOffering As Boolean) As Boolean
    
    Dim PriceAbleItemInstance           As MTPriceableItem
    Dim PriceList                       As MTPriceList
    Dim ParamTableDefinition            As MTParamTableDefinition
    Dim CalendarIDs                 As collection
    Dim CalendarID                  As Variant
    Dim Calendar                    As MTCalendar
    Dim Rowset                          As IMTRowSet
    Dim strCalendarID               As String
    Dim strXML                          As String
    
    On Error GoTo ErrMgr
    
    If booProductOffering Then

        If Not GetIDsFromQuery("__GET_CALENDAR_IDS_USED_BY_PO__", ProductOfferingOrPriceList.ID, CalendarIDs) Then Exit Function
    Else
    
        If Not GetIDsFromQuery("__GET_CALENDAR_IDS_USED_BY_PRICE_LIST__", ProductOfferingOrPriceList.ID, CalendarIDs) Then Exit Function
    End If
    
    XMLOutPutTag "Calendars"
    
    For Each CalendarID In CalendarIDs
    
        If Not ExportCalendar(CalendarID) Then Exit Function
    Next
    XMLOutPutTag "Calendars", XMLTAGTYPE_CLOSE
    ExportCalendarFromProductOffering = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportCalendarFromProductOffering", LOG_ERROR
End Function



Private Function GetCalendarEnumTypeFQNFromValue(strValue As String) As String
    GetCalendarEnumTypeFQNFromValue = GetFQNFromEnumTypeValue(CALENDAR_PARAMETER_TABLE_NAME, "CalendarCode", strValue)
End Function




Public Function ExportRateSchedule(ByVal strXMLFileName As String, strPriceListName As String, strPriceAbleItemName As String, ByVal eExportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String) As Boolean

    Dim Rowset                      As IMTRowSet
    Dim PriceList                   As MTPriceList
    Dim PriceAbleItemTemplate       As MTPriceableItem
    Dim lngPriceListID              As Long
    Dim strName                     As String
    Dim PriceAbleItemInstamceRowset As IMTRowSet
    Dim Profiler                    As New CProfiler: Profiler.Start True, TypeName(Me), "PriceList"
    Dim RateScheduleIDS             As New collection
    
    On Error GoTo ErrMgr
        
'    Debug.Assert 0
    
    ExportInit eExportMode, strCommandLine
    XMLOutputInitialize
    
    INFO vbNewLine & "Export Rate Schedule(s) for PriceAbleItem:" & strPriceAbleItemName & " PriceList:" & strPriceListName

    Set PriceList = ProductCatalog.GetPriceListByName(strPriceListName)
    Set PriceAbleItemTemplate = ProductCatalog.GetPriceableItemByName(strPriceAbleItemName)
    
    'Set RowSet = ProductCatalog.FindPriceListsAsRowset
    
    Set Rowset = ExecuteQuery("__GET_ALL_RATE_SCHEDULE_IDS_USED_BY_PL_AND_PAIT__", "PRICELISTID", PriceList.ID, "PRICEABLEITEMID", PriceAbleItemTemplate.ID)

    Do While Not Rowset.EOF
    
        RateScheduleIDS.Add Rowset.Value("id_sched")
        Rowset.MoveNext
    Loop
    
    If Not ExportRateScheduleUsedBy(Nothing, Nothing, RateScheduleIDS, True) Then Exit Function
    ExportTerminate
    ExportRateSchedule = SaveXMLOutPut(strXMLFileName)
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportPriceList", LOG_ERROR
End Function

Public Function ExportSubscriptions(ByVal strXMLFileName As String, ByVal strProductOfferingNames As String, ByVal strUserName As String, strPassWord As String, strNameSpace As String, ByVal eExportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String, ByVal strDate As String) As Boolean

    Dim Rowset                      As IMTRowSet
    Dim objProductOffering          As MTProductOffering
    Dim lngPriceListID              As Long
    Dim strName                     As String
    Dim PriceAbleItemInstamceRowset As IMTRowSet
    Dim Profiler                    As New CProfiler: Profiler.Start True, TypeName(Me), "ProductOffering"
    Dim varProductOfferingName      As Variant
    Dim objProductOfferingNames     As collection
    Dim objAccountCatalog           As New MTYAACLib.MTAccountCatalog
    Dim datDate                    As Date
        
    On Error GoTo ErrMgr
        
'    Debug.Assert 0
       
    MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_MESSAGE_1020, "DATE", strDate), Me, "ExportSubscriptions", LOG_INFO
    datDate = CDate(strDate)
       
    ExportInit eExportMode, strCommandLine
    
    Set m_objSessionContext = GetSessionContext(strUserName, strPassWord, strNameSpace)
    If Not IsValidObject(m_objSessionContext) Then Exit Function
    objAccountCatalog.Init m_objSessionContext
    
    XMLOutputInitialize
    
    XMLOutPutTag "subscriptions"
    
    Set objProductOfferingNames = GetListOfProductOffering(strProductOfferingNames)
    If Not IsValidObject(objProductOfferingNames) Then
    
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1017, "COMMANDLINE-VALUE", strProductOfferingNames), Me, "ExportSubscriptions", LOG_ERROR
        Exit Function
    End If
        
    For Each varProductOfferingName In objProductOfferingNames
        
        PrintConsole vbNewLine & PreProcess(MTPCImportExport_MESSAGE_1005, "PO", varProductOfferingName) & vbNewLine
        
        Set objProductOffering = Me.ProductCatalog.GetProductOfferingByName(CStr(varProductOfferingName))
        If Not IsValidObject(objProductOffering) Then
        
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1016, "PRODUCT_OFFERING", varProductOfferingName), Me, "ExportSubscriptions", LOG_ERROR
            Exit Function
        End If
        
        Set Rowset = ExecuteQuery("__GET_SUBSCRIPTION_INFO_FROM_PO__", "ID", objProductOffering.ID)
        
        Do While Not Rowset.EOF
        
            If Not ExportSubscriptionAccountInfo(objProductOffering, objAccountCatalog, objProductOffering.ID, Rowset, datDate) Then Exit Function
            Rowset.MoveNext
        Loop
    Next
    XMLOutPutTag "subscriptions", XMLTAGTYPE_CLOSE
    ExportTerminate
    ExportSubscriptions = SaveXMLOutPut(strXMLFileName)
    Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportSubscriptions", LOG_ERROR
End Function


Private Function ExportSubscriptionAccountInfo(ByVal ProductOffering As MTProductOffering, objAccountCatalog As MTYAACLib.MTAccountCatalog, lngPOID As Long, Rowset As IMTRowSet, ByVal datDate As Date) As Boolean

    Dim objPCAccount        As MTPCAccount
    Dim lngAccountID        As Long
    Dim lngSubscriptionID   As Long
    Dim objSubscription     As MTSubscription
    Dim objMTYAAC           As MTYAAC
    Dim strSubscriptionName As String
            
'    Debug.Assert 0
    
    lngAccountID = Rowset.Value("id_acc")
    lngSubscriptionID = Rowset.Value("id_sub")
    
    Set objPCAccount = Me.ProductCatalog.GetAccount(lngAccountID)
    Set objSubscription = objPCAccount.GetSubscription(lngSubscriptionID)
    
    If objSubscription.EffectiveDate.EndDate < datDate Then
        
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_WARNING_1021, "PO", ProductOffering.Name, "ACCOUNTID", lngAccountID, "ENDDATE", objSubscription.EffectiveDate.EndDate, "NOW", datDate), Me, "ExportSubscriptionAccountInfo", LOG_WARNING
    Else
    
        Set objMTYAAC = objAccountCatalog.GetAccount(lngAccountID)
            
        ' Open the tag subscription here
        If Not ExportObjectXMLHeaderAndProperties(objSubscription, XMLTAGTYPE_OPEN, ProductOffering.Name) Then Exit Function
        XMLOutPutTagValue "username", objMTYAAC.LoginName
        XMLOutPutTagValue "namespace", objMTYAAC.Namespace
        
        strSubscriptionName = "PO=" & ProductOffering.Name & "|Account=" & objMTYAAC.Namespace & ":" & objMTYAAC.LoginName
        
        ExportSubscriptionOrGroupSubscriptionICB ProductOffering, objSubscription
        
        If Not ExportUDRCInfo(ProductOffering, objSubscription, strSubscriptionName) Then Exit Function
        
        If Not m_objCommandLine.getValue("-ExportDynamicExtendedProperties", False) Then
        
            ExportDynamicExtendedPropertiesForSubscription lngSubscriptionID
            
        End If
                
        XMLOutPutTag "subscription", XMLTAGTYPE_CLOSE
        
        INFOOBJECT m_Stats.AddNewObject(objSubscription, strSubscriptionName), ""
    End If
    
    ExportSubscriptionAccountInfo = True
    
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportSubscriptionAccountInfo", LOG_ERROR
End Function


Private Function ExportUDRCInfo(ProductOffering As MTProductOffering, objSubscriptionOrGroupSubscription As Variant, strSubscriptionOrGroupSubscriptionName As String) As Boolean

    Dim r                   As IMTRowSet
    Dim rr                  As Object
    Dim possibleUDRC        As Variant
    Dim possibleUDRCs       As Variant
    Dim a                   As MTGroupSubscription
    Dim booContinue         As Boolean
    Dim lngContinueCounter  As Long
    
    Const UNIT_VALUE_ROWSET_EXCLUDE_COLUMNS = ",ID_PROP,ID_SUB,"
    
    
    Set possibleUDRCs = ProductOffering.GetPriceableItems
    Set r = objSubscriptionOrGroupSubscription.GetRecurringChargeUnitValuesAsRowset()
    
    ' Clone the rowset with a MTMSIX.MTSQLRowsetSimulator so we can change the data
    ' Insert the Recurring Charge Tmplate Name in the id column
    Set rr = CreateObject("MTMSIX.MTSQLRowsetSimulator")
    rr.CloneFrom r
    
    For Each possibleUDRC In possibleUDRCs
      If possibleUDRC.Kind = PI_TYPE_RECURRING_UNIT_DEPENDENT Then
        'This is a UDRC
        booContinue = True
        lngContinueCounter = 0
        
        Do While booContinue
        
            If rr.Find("id_prop", possibleUDRC.ID) Then
            
                rr.Value("id_prop") = possibleUDRC.Name
            Else
                If lngContinueCounter = 0 Then ' if we do not found at least one UDCR this is an error, if we do not found a second or third or more one this is time to exit
                
                    MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1034, "SUB_NAME", strSubscriptionOrGroupSubscriptionName), Me, "ExportUDRCInfo", LOG_ERROR
                    Exit Function
                Else
                    booContinue = False
                End If
            End If
            lngContinueCounter = lngContinueCounter + 1
        Loop
      End If
    Next
    rr.Name("id_prop") = "Name"
    rr.Name("vt_start") = "StartDate"
    rr.Name("vt_end") = "EndDate"
    rr.Name("n_value") = "Value"
  rr.Name("nm_unit_name") = "UnitName"

    rr.MoveFirst
    XMLOutPutRowset "UDRCS", "UDRC", rr, UNIT_VALUE_ROWSET_EXCLUDE_COLUMNS, "name", "startdate"
            
    ExportUDRCInfo = True
    
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportUDRCInfo", LOG_ERROR
End Function

Private Function ExportSubscriptionOrGroupSubscriptionICB(ProductOffering As MTProductOffering, objSubscription As IMTSubscriptionBase) As Boolean

    On Error GoTo ErrMgr
    
    Dim objPriceAbleItem        As MTPriceableItem
    
    
'    Debug.Assert 0
    
    XMLOutPutTag "icbs", XMLTAGTYPE_OPEN
    
    For Each objPriceAbleItem In ProductOffering.GetPriceableItems
    
        If Not ExportPriceAbleItemSubscriptionOrGroupSubscriptionICB(objPriceAbleItem, ProductOffering, objSubscription, True) Then Exit Function
    Next
    XMLOutPutTag "icbs", XMLTAGTYPE_CLOSE
    ExportSubscriptionOrGroupSubscriptionICB = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportSubscriptionOrGroupSubscriptionICB", LOG_ERROR
End Function

Private Function ExportPriceAbleItemSubscriptionOrGroupSubscriptionICB(objPriceAbleItem As MTPriceableItem, ProductOffering As MTProductOffering, objSubscription As IMTSubscriptionBase, ByVal booParentLevel As Boolean) As Boolean

    On Error GoTo ErrMgr
    
    Dim objParamTable           As MTParamTableDefinition
    Dim objPriceListMapping     As MTPriceListMapping
    Dim Rowset                  As IMTRowSet
    Dim RateScheduleIDS         As collection
    Dim objChildPriceAbleItem   As MTPriceableItem

    For Each objParamTable In objPriceAbleItem.PriceAbleItemType.GetParamTableDefinitions
    
        ' -- The subscription link us here to the AccountID
        Set objPriceListMapping = objSubscription.GetICBPriceListMapping(objPriceAbleItem.ID, objParamTable.ID)
        
        If IsValidObject(objPriceListMapping) Then
        
            If (objPriceListMapping.MappingType = MAPPING_ICB_SUBSCRIPTION) Or (objPriceListMapping.MappingType = MAPPING_ICB_GROUP_SUBSCRIPTION) Then
            
                XMLOutPutTag "icb", XMLTAGTYPE_OPEN
                
                XMLOutPutTagValue "currency", objPriceListMapping.GetPriceList().CurrencyCode
        
                ' -- The Parameter Table Name and PriceAbleItem Name are exported as part of the rate schedule
                
                ' Build the collection a RateSchedule ID to export
                Set RateScheduleIDS = New collection
                Set Rowset = objParamTable.GetRateSchedulesByPriceListAsRowset(objPriceListMapping.PriceListID, objPriceAbleItem.GetTemplate.ID)
                Set RateScheduleIDS = MakeIDsCollection(Rowset, "id_sched")

                If Not IsValidObject(RateScheduleIDS) Then
                
                    MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1018, "PT", objParamTable.Name, "PLID", objPriceListMapping.PriceListID, "PIT", objPriceAbleItem.GetTemplate.Name, "PII", objPriceAbleItem.Name), Me, "IsSubscriptionHasICB", LOG_ERROR
                    Exit Function
                End If
                If Not ExportRateScheduleUsedBy(ProductOffering, ProductOffering, RateScheduleIDS, False) Then Exit Function
                If Not ExportCalendarUsedByRateSchedules(RateScheduleIDS) Then Exit Function
                                    
                XMLOutPutTag "icb", XMLTAGTYPE_CLOSE
            End If
        End If
    Next
    If booParentLevel Then
        GoSub PROCESS_CHILDREN_ICB
    End If
    ExportPriceAbleItemSubscriptionOrGroupSubscriptionICB = True
    Exit Function
    
PROCESS_CHILDREN_ICB:

    If objPriceAbleItem.GetChildren().Count Then

        XMLOutPutTag "icbs_child", XMLTAGTYPE_OPEN
        For Each objChildPriceAbleItem In objPriceAbleItem.GetChildren()
    
            If Not ExportPriceAbleItemSubscriptionOrGroupSubscriptionICB(objChildPriceAbleItem, ProductOffering, objSubscription, False) Then Exit Function
        Next
        XMLOutPutTag "icbs_child", XMLTAGTYPE_CLOSE
        
    End If

Return
    
    
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportPriceAbleItemSubscriptionOrGroupSubscriptionICB", LOG_ERROR
End Function


Private Function ExportCalendarUsedByRateSchedules(RateScheduleIDS As collection) As Boolean

    On Error GoTo ErrMgr
    
    Dim RateScheduleID  As Variant
    Dim CalendarID      As Variant
    Dim ParameterTable  As MTParamTableDefinition
    
    Dim RateSchedule As MTRateSchedule
        
    XMLOutPutTag "Calendars"
    
    For Each RateScheduleID In RateScheduleIDS
    
        Set RateSchedule = LoadRateSchedule(RateScheduleID)
        
        Set ParameterTable = Me.ProductCatalog.GetParamTableDefinition(RateSchedule.ParameterTableID)
        
        If UCase$(ParameterTable.Name) = UCase$(CALENDAR_PARAMETER_TABLE_NAME) Then
        
            If IsValidObject(RateSchedule) Then
            
                If IsValidObject(RateSchedule.RuleSet.DefaultActions) Then
                
                    ' Calendar is stored in the item 1 of the default action. FABRICIO said.
                    If (RateSchedule.RuleSet.DefaultActions.Count >= 1) Then
                    
                        CalendarID = RateSchedule.RuleSet.DefaultActions.Item(1).PropertyValue
                        
                        If (IsNumeric(CalendarID)) Then
                        
                            If Not ExportCalendar(CalendarID) Then Exit Function
                        End If
                    End If
                End If
            Else
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1032, "RSID", RateScheduleID), Me, "ExportCalendarUsedByRateSchedules", LOG_ERROR
                Exit Function
            End If
        End If
    Next
    XMLOutPutTag "Calendars", XMLTAGTYPE_CLOSE
    ExportCalendarUsedByRateSchedules = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportCalendarUsedByRateSchedules", LOG_ERROR
End Function


Private Function ExportInit(ByVal eExportMode As IMPORT_EXPORT_MODE, strCommandLine As String) As Boolean

    On Error GoTo ErrMgr
    
    
    g_enmExportImportMode = eExportMode
    
    Set m_objEnumConfig = New MTENUMCONFIGLib.EnumConfig
    
    Set m_Stats = New CImportExportStats
    Set m_objParamTableIntegrity = New CParamTableChks
    
#If CONSOLE Then
    Set static_objConsoleWindow = New CConsoleWindow
    static_objConsoleWindow.Initialize App.EXEName
#End If
    
    PrintConsoleAppInfo
    
    
    Set m_objCommandLine = New CCommandLine
    m_objCommandLine.Init strCommandLine
    TraceCommandLineInSafeWay strCommandLine
    
    m_enmExportMode = eExportMode
    
    ExportInit = True
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportInit", LOG_ERROR
End Function


Private Function ExportTerminate() As Boolean

    On Error GoTo ErrMgr
    
    m_objParamTableIntegrity.GenerateXML
    
    
    ExportTerminate = True
    INFO m_Stats.GetSummaryString()
    Set m_objEnumConfig = Nothing
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportTerminate", LOG_ERROR
End Function

Private Sub Class_Initialize()
    MTPCImportExportModule_Initialize
End Sub

Public Function ExportPriceList(ByVal strXMLFileName As String, ByVal strPriceListNames As String, ByVal eExportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String) As Boolean

    Dim Rowset                      As IMTRowSet
    Dim objPriceList                As MTPriceList
    Dim objPriceListNames           As collection
    Dim lngPriceListID              As Long
    Dim strName                     As String
    Dim PriceAbleItemInstamceRowset As IMTRowSet
    Dim Profiler                    As New CProfiler: Profiler.Start True, TypeName(Me), "PriceList"
    Dim varPriceListName            As Variant


    On Error GoTo ErrMgr

    ExportInit eExportMode, strCommandLine
    XMLOutputInitialize
    XMLOutPutTag "PriceLists"
'    Debug.Assert 0




    Set objPriceListNames = GetListOfPriceList(strPriceListNames)
    If Not IsValidObject(objPriceListNames) Then
    
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1019, "COMMANDLINE-VALUE", strPriceListNames), Me, "ExportPriceList", LOG_ERROR
        Exit Function
    End If

    For Each varPriceListName In objPriceListNames

        PrintConsole vbNewLine & vbNewLine & PreProcess(MTPCImportExport_MESSAGE_1009, "PL", varPriceListName)

        Set objPriceList = ProductCatalog.GetPriceListByName(varPriceListName)
        If Not IsValidObject(objPriceList) Then
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1020, "PL", varPriceListName), Me, "ExportSubscriptions", LOG_ERROR
            Exit Function
        End If

        INFOOBJECT m_Stats.AddNewObject(objPriceList), "Export "
        
        XMLOutPutTag objPriceList, , objPriceList.Name


        ' Export the PO
        If Not ExportObjectXMLHeaderAndProperties(objPriceList, XMLTAGTYPE_NONE) Then Exit Function   ' do not close the tag

        ' Export PriceList, PriceAbleItem, RateSchedule, Rate, Calendar used by a Product offering
        ObjectsUsedByPriceList objPriceList
        
        XMLOutPutTag objPriceList, XMLTAGTYPE_CLOSE
    Next
    XMLOutPutTag "PriceLists", XMLTAGTYPE_CLOSE
    ExportTerminate
    ExportPriceList = SaveXMLOutPut(strXMLFileName)
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportPriceList", LOG_ERROR
End Function

' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ObjectsUsedByProductOffering
' PARAMETERS    :
' DESCRIPTION   : Export PriceList, PriceAbleItem, RateSchedule, Rate, Calendar used by a Product offering
' RETURN        :
Private Function ObjectsUsedByPriceList(PriceList As MTPriceList) As Boolean
    
    On Error GoTo ErrMgr
    
    Dim RateScheduleIDS As New collection
    Dim Rowset  As IMTRowSet
    
'    Debug.Assert 0
            
    PrintConsole vbNewLine & "Export PriceAbleItems Template"
    XMLOutPutComment = "PriceAbleItems Template used by Price List " & PriceList.Name
    If Not ExportPriceAbleItemTemplateUsedBy(PriceList, False) Then Exit Function

    PrintConsole vbNewLine & "Export Calendar"
    XMLOutPutComment = "Calendar used by price list " & PriceList.Name
    If Not ExportCalendarFromProductOffering(PriceList, False) Then Exit Function

    Set Rowset = ExecuteQuery("__GET_RATE_SCHEDULE_IDs_USED_BY_PL__", "ID", PriceList.ID)
    Do While Not Rowset.EOF
        RateScheduleIDS.Add Rowset.Value("id")
        Rowset.MoveNext
    Loop
    
    PrintConsole vbNewLine & "Export RateSchedules"
    XMLOutPutComment = "RateSchedules used by price list" & PriceList.Name
    If Not ExportRateScheduleUsedBy(Nothing, Nothing, RateScheduleIDS, False) Then Exit Function

    ObjectsUsedByPriceList = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ObjectsUsedByPriceList", LOG_ERROR
End Function




' Return Nothing is no objects are added to the collection
' Ignore private price list
Private Function GetListOfPriceList(strPriceListFileName As String) As collection
    
    Dim objTools As Object
    Dim arrVar   As Variant
    Dim v        As Variant
    Dim objCol   As collection
    Dim Rowset   As IMTRowSet
        
    If InStr(strPriceListFileName, "*") Then

        Set Rowset = ProductCatalog.FindPriceListsAsRowset()
        
        Do While Not Rowset.EOF

            If Rowset.Value("n_type") <> PRICELIST_TYPE_PO Then ' ignore private price list
        
                If Not IsValidObject(objCol) Then Set objCol = New collection
                
                If Len("" & Rowset.Value("nm_name")) Then
                
                    If UCase$("" & Rowset.Value("nm_name")) Like UCase$(strPriceListFileName) Then
                    
                        objCol.Add Rowset.Value("nm_name")
                    End If
                End If
            End If
            Rowset.MoveNext
        Loop
    Else
        Set objTools = CreateObject("MTMSIX.MSIXTools")
        arrVar = objTools.SplitTrim(strPriceListFileName, ",")
        For Each v In arrVar
            If Not IsValidObject(objCol) Then Set objCol = New collection
            objCol.Add v
        Next
    End If
    Set GetListOfPriceList = objCol
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "GetListOfPriceList", LOG_ERROR
End Function


' Return Nothing is no objects are added to the collection
Private Function GetListOfProductOffering(strProductOfferingFileName As String) As collection
    
    Dim objTools As Object
    Dim arrVar   As Variant
    Dim v        As Variant
    Dim objCol   As collection
    Dim Rowset   As IMTRowSet
        
    If InStr(strProductOfferingFileName, "*") Then

        Set Rowset = ProductCatalog.FindProductOfferingsAsRowset()
        
        Do While Not Rowset.EOF
        
            If Not IsValidObject(objCol) Then Set objCol = New collection
            If UCase$("" & Rowset.Value("nm_name")) Like UCase$(strProductOfferingFileName) Then objCol.Add Rowset.Value("nm_name")
            Rowset.MoveNext
        Loop
    Else
        Set objTools = CreateObject("MTMSIX.MSIXTools")
        arrVar = objTools.SplitTrim(strProductOfferingFileName, ",")
        For Each v In arrVar
            If Not IsValidObject(objCol) Then Set objCol = New collection
            objCol.Add v
        Next
    End If
    Set GetListOfProductOffering = objCol
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "GetListOfProductOffering", LOG_ERROR
End Function


Public Function ExportGroupSubscriptions(ByVal strXMLFileName As String, ByVal strCorporationNames As String, ByVal strCorporationNameSpace As String, ByVal strGroupSubscriptionNames As String, ByVal strUserName As String, strPassWord As String, strNameSpace As String, ByVal eExportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String, ByVal strDate As String) As Boolean

    Dim Rowset                      As IMTRowSet
    Dim objProductOffering          As MTProductOffering
    Dim lngPriceListID              As Long
    Dim strName                     As String
    Dim PriceAbleItemInstamceRowset As IMTRowSet
    Dim Profiler                    As New CProfiler: Profiler.Start True, TypeName(Me), "ProductOffering"
    Dim varProductOfferingName      As Variant
    Dim objCorporationCollection    As CVariables
    Dim objMTYAAC                   As MTYAAC
    Dim objAccountCatalog           As New MTYAACLib.MTAccountCatalog
    Dim objImportExportUserAccount  As MTYAACLib.MTYAAC
    Dim Corporation                 As CVariable
    Dim GroupSubscriptionCollection As CVariables
    Dim GroupScriptionVar           As CVariable
    Dim objGroupSubscription        As MTGroupSubscription
    Dim GroupSubscriptionMember     As MTGSubMember
    Dim CurrentAccountMember        As MTYAAC
    Dim i                           As Long
    Dim lngAccountID                As Long
    Dim strDistributionAccountUserName As String, strDistributionAccountNameSpace As String
    Dim objGroupMembersAsRowset     As IMTRowSet
    Dim objChargeAccountRowset      As IMTRowSet
    Dim objChargeAccountRowset2     As Variant
    Dim lngPriceAbleItemWithChargeAccountID As Long
    Dim objPriceAbleItemWithChargeAccountID As MTPriceableItem
    
    On Error GoTo ErrMgr
       
           
    ExportInit eExportMode, strCommandLine
    
    Set m_objSessionContext = GetSessionContext(strUserName, strPassWord, strNameSpace)
    If Not IsValidObject(m_objSessionContext) Then Exit Function
    objAccountCatalog.Init m_objSessionContext
    
    Set objImportExportUserAccount = objAccountCatalog.GetAccountByName(strUserName, strNameSpace)
        
    XMLOutputInitialize
    
    XMLOutPutTag "groupsubscriptions"

    'Debug.Assert 0
        
    Set objCorporationCollection = GetListOfCorporation(strDate, strCorporationNames, strCorporationNameSpace, objImportExportUserAccount.AccountID, objAccountCatalog)
    If Not IsValidObject(objCorporationCollection) Then
    
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1021, "COMMANDLINE-VALUE", strCorporationNames), Me, "ExportGroupSubscriptions", LOG_ERROR
        Exit Function
    End If
    
    For Each Corporation In objCorporationCollection ' Name=Name, Value=Id, Tag=namespace

        PrintConsole PreProcess(MTPCImportExport_MESSAGE_1011, "CORP", Corporation.Name) & vbNewLine

        Set GroupSubscriptionCollection = GetListOfGroupSubscription(strGroupSubscriptionNames, Corporation.Value, Corporation.Name)
        
        If IsValidObject(GroupSubscriptionCollection) Then
        
            For Each GroupScriptionVar In GroupSubscriptionCollection
            
                PrintConsole PreProcess(MTPCImportExport_MESSAGE_1012, "SUB", GroupScriptionVar.Name)
        
                Set objGroupSubscription = ProductCatalog.GetGroupSubscriptionByID(GroupScriptionVar.Value)
                
                INFOOBJECT m_Stats.AddNewObject(objGroupSubscription), "Export "
                If Not ExportObjectXMLHeaderAndProperties(objGroupSubscription, XMLTAGTYPE_OPEN) Then Exit Function
                
                ' Distribution Account Name
                If (objGroupSubscription.DistributionAccount = 0) Then
                    strDistributionAccountUserName = "": strDistributionAccountNameSpace = "" ' No DistributionAccount
                Else
                    Set objMTYAAC = objAccountCatalog.GetAccount(objGroupSubscription.DistributionAccount)
                    strDistributionAccountUserName = objMTYAAC.LoginName
                    strDistributionAccountNameSpace = objMTYAAC.Namespace
                End If
                XMLOutPutTagValue "distributionaccountusername", strDistributionAccountUserName
                XMLOutPutTagValue "distributionaccountnamespace", strDistributionAccountNameSpace
                
                Set objProductOffering = ProductCatalog.GetProductOffering(objGroupSubscription.productOfferingID)
                
                XMLOutPutTagValue "ProductOffering", objProductOffering.Name
                XMLOutPutTagValue "Corporation", Corporation.Name   ' May be /GLOBAL
                XMLOutPutTagValue "CorporationNameSpace", Corporation.Tag
                
                XMLOutPutTag "members"
                
                Set objGroupMembersAsRowset = objGroupSubscription.Membership.GroupMembersAsRowset
                
                Do While Not objGroupMembersAsRowset.EOF

                    lngAccountID = objGroupMembersAsRowset.Value("id_acc")
                    
                    If GetUserNameNameSpaceFromAccountID(ProductCatalog, objAccountCatalog, lngAccountID, strUserName, strNameSpace) Then
                        
                        XMLOutPutTag "gsubmember", XMLTAGTYPE_OPEN, strUserName & ":" & strNameSpace    '  in 3.7 I added the username+Namespce this is only for unittest purpose
                                                                                                        '  to compare input and output xml file. Some time the account list
                                                                                                        '  is not in the same order in the input and output file
                        XMLOutPutPropertyNameValue "property", "AccountID", "" & lngAccountID
                        XMLOutPutPropertyNameValue "property", "AccountName", strUserName
                        XMLOutPutPropertyNameValue "property", "StartDate", "" & objGroupMembersAsRowset.Value("vt_start")
                        XMLOutPutPropertyNameValue "property", "EndDate", "" & objGroupMembersAsRowset.Value("vt_end")
                        
                        XMLOutPutTagValue "namespace", strNameSpace
                    End If
                    XMLOutPutTag "gsubmember", XMLTAGTYPE_CLOSE
                    objGroupMembersAsRowset.MoveNext
                Loop
                XMLOutPutTag "members", XMLTAGTYPE_CLOSE
                
                
                
                Set objChargeAccountRowset = objGroupSubscription.GetRecurringChargeAccounts(Now()) ' We Pass now because the time is ignored
                
                '
                ' Charge Accounts
                '
                
                ' Clone the rowset with a MTMSIX.MTSQLRowsetSimulator so we can change the data
                ' Replace the id_acc and id_prop column with UserName, NameSpace
                ' Replace nm_display_name with priceableitemname the PriceAbleItem name in the rowset
                Set objChargeAccountRowset2 = CreateObject("MTMSIX.MTSQLRowsetSimulator")
                objChargeAccountRowset2.CloneFrom objChargeAccountRowset
                
                objChargeAccountRowset2.Name("id_acc") = "UserName"
                objChargeAccountRowset2.Name("id_prop") = "NameSpace"
                objChargeAccountRowset2.Name("vt_start") = "StartDate"
                objChargeAccountRowset2.Name("vt_end") = "EndDate"
                objChargeAccountRowset2.Name("nm_display_name") = "priceableitemname"
                
                ' :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :)
                ' :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :)
                ' :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :) :> :)
                
                ' WE NEED TO REPLACE THE DISPLAY_NAME COLUMN WITH A COLUMN NAME
                ' priceableitemname, with the name of the instance in the PO.
                
                Do While Not objChargeAccountRowset2.EOF
                
                    ' Replace the PriceAbleItem Id with the name, the name is unique in the product offering
                    lngPriceAbleItemWithChargeAccountID = objChargeAccountRowset2.Value("NameSpace") ' NameSpace used to be the column id_prop
                    Set objPriceAbleItemWithChargeAccountID = objProductOffering.GetPriceableItem(lngPriceAbleItemWithChargeAccountID)
                    objChargeAccountRowset2.Value("priceableitemname") = objPriceAbleItemWithChargeAccountID.Name

                    ' Replace the account id with the username/namespace
                    Debug.Assert 0
                    ' Check for bug ESR-5604
                    If IsNull(objChargeAccountRowset2.Value("UserName")) Then
                        Err.Raise vbObjectError + 1, "ExportGroupSubscriptions", "Supposedly Group Subscriptions of PI configured like: One charge per participant, which are not supported by this application."
                    End If
                    
                    lngAccountID = objChargeAccountRowset2.Value("UserName")
                    Set objMTYAAC = objAccountCatalog.GetAccount(lngAccountID)
                    objChargeAccountRowset2.Value("UserName") = objMTYAAC.LoginName
                    objChargeAccountRowset2.Value("NameSpace") = objMTYAAC.Namespace
                    
                    objChargeAccountRowset2.MoveNext
                Loop
                objChargeAccountRowset2.MoveFirst
                XMLOutPutRowset "ChargeAccounts", "ChargeAccount", objChargeAccountRowset2, "", "priceableitemname", "startdate"
                
                
                '
                ' UDRC
                '
                Debug.Assert 0
                If Not ExportUDRCInfo(objProductOffering, objGroupSubscription, " GroupSub:" & objGroupSubscription.Name & ", ProductOffering:" & objProductOffering.Name) Then Exit Function
                

                '
                ' ICB
                '
'                Debug.Assert 0
                ExportSubscriptionOrGroupSubscriptionICB objProductOffering, objGroupSubscription
                
                XMLOutPutTag objGroupSubscription, XMLTAGTYPE_CLOSE
            Next
        Else
            MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_WARNING_1014, "CORPORATION", Corporation.Name), Me, "ExportGroupSubscriptions", LOG_WARNING
        End If
    Next
    XMLOutPutTag "groupsubscriptions", XMLTAGTYPE_CLOSE
    ExportTerminate
    ExportGroupSubscriptions = SaveXMLOutPut(strXMLFileName)
    Exit Function
ErrMgr:

    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportGroupSubscriptions", LOG_ERROR
End Function




' Return Nothing is no objects are added to the collection
Private Function GetListOfGroupSubscription(strGroupSubscriptions As String, ByVal lngCorporateAccountID As Long, ByVal strCorporateName As String) As CVariables
    
    Dim objTools As Object
    Dim arrVar   As Variant
    Dim v        As Variant
    Dim objCol   As CVariables
    Dim Rowset   As IMTRowSet
    Dim lngGroupSubID As Long
        
    If InStr(strGroupSubscriptions, "*") Then

        Set Rowset = ProductCatalog.GetGroupSubscriptionByCorporateAccount(lngCorporateAccountID)
        
        Do While Not Rowset.EOF
        
            If Not IsValidObject(objCol) Then Set objCol = New CVariables
            If UCase$("" & Rowset.Value("tx_name")) Like UCase$(strGroupSubscriptions) Then objCol.Add Rowset.Value("tx_name"), Rowset.Value("id_group")
            Rowset.MoveNext
        Loop
    Else
        Set objTools = CreateObject("MTMSIX.MSIXTools")
        arrVar = objTools.SplitTrim(strGroupSubscriptions, ",")
        For Each v In arrVar
            If Not IsValidObject(objCol) Then Set objCol = New CVariables
            lngGroupSubID = GetGroupSubscriptionID(lngCorporateAccountID, v)
            
            If (lngGroupSubID = 0) Then
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1029, "GS", v, "CORP", strCorporateName), Me, "GetListOfGroupSubscription", LOG_ERROR
            End If
            
            objCol.Add v, lngGroupSubID
        Next
    End If
    Set GetListOfGroupSubscription = objCol
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "GetListOfGroupSubscription", LOG_ERROR
End Function

Private Function GetGroupSubscriptionID(ByVal lngCorporateAccountID As Long, ByVal strGroupSubscriptionName As String) As Long

    On Error GoTo ErrMgr

    Dim Rowset   As IMTRowSet
    
    Set Rowset = ProductCatalog.GetGroupSubscriptionByCorporateAccount(lngCorporateAccountID)
    GetGroupSubscriptionID = 0 ' default bad value
    
    Do While Not Rowset.EOF
    
        If UCase$(Rowset.Value("tx_name")) = UCase$(strGroupSubscriptionName) Then
    
            GetGroupSubscriptionID = Rowset.Value("id_group")
            Exit Function
        End If
        Rowset.MoveNext
    Loop
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "GetGroupSubscriptionID", LOG_ERROR
End Function


' Return Nothing is no objects are added to the collection
Private Function GetListOfCorporation(strDate As String, strCorporationFileName As String, ByVal strCorporationNameSpace As String, lngUserAccountID As Long, objAccountCatalog As MTYAACLib.MTAccountCatalog) As CVariables
    
    Dim objTools As Object
    Dim arrVar   As Variant
    Dim v        As Variant
    Dim objCol   As CVariables
    Dim Rowset   As IMTRowSet
    Dim Corporation As CVariable
    Dim CorporationNameList As CVariables
    Dim strTmpCorpNameSpace As String
    
    On Error GoTo ErrMgr
        
    If UCase$(strCorporationFileName) = "/GLOBAL" Then
    
        Set objCol = New CVariables
        
        objCol.Add "/GLOBAL", 1
    Else
    
        Set CorporationNameList = GetCorporationList(strCorporationNameSpace, strDate, lngUserAccountID, objAccountCatalog)
            
        For Each Corporation In CorporationNameList
        
            If Not IsValidObject(objCol) Then Set objCol = New CVariables
            
            If Len(strCorporationNameSpace) Then
            
                strTmpCorpNameSpace = strCorporationNameSpace
            Else
                strTmpCorpNameSpace = Corporation.Tag
            End If
            If UCase$("" & Corporation.Name) Like UCase$(strCorporationFileName) Then objCol.Add Corporation.Name, Corporation.Value, , , , strTmpCorpNameSpace
        Next
    End If
    Set GetListOfCorporation = objCol
Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "GetListOfCorporation", LOG_ERROR
End Function

'
'Public Function ListProductOffering() As Boolean
'
'    Dim Rowset                      As IMTRowSet
'    Dim objProductOffering          As MTProductOffering
'    Dim strName                     As String
'
'    On Error GoTo ErrMgr
'
'    PrintConsole vbNewLine & "List Product Offering" & vbNewLine
'
'    Set Rowset = ProductCatalog.FindProductOfferingsAsRowset()
'
'    Do While Not Rowset.EOF
'
'        strName = Rowset.value("nm_name")
'        PrintConsole strName & vbNewLine
'        'Set objProductOffering = ProductCatalog.GetProductOfferingByName(strName)
'
'        MTPCImportExportModule.TRACE strName, , , LOG_INFO
'        Rowset.MoveNext
'    Loop
'    ListProductOffering = True
'    Exit Function
'ErrMgr:
'    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ListProductOffering", LOG_ERROR
'End Function


Public Function ExportPriceListMultiFile(ByVal strPath As String, ByVal strPriceListNames As String, ByVal eExportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String) As Boolean
    
    Dim objPriceList          As MTPriceList
    Dim objPriceListNames     As collection
    Dim varPriceListName      As Variant
    Dim strXMLFileName        As String
    
    On Error GoTo ErrMgr
    
'    Debug.Assert 0
    
    Set objPriceListNames = GetListOfPriceList(strPriceListNames)
    If Not IsValidObject(objPriceListNames) Then
    
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1041, "COMMANDLINE-VALUE", strPriceListNames), Me, "ExportPriceList", LOG_ERROR
        Exit Function
    End If
    
    For Each varPriceListName In objPriceListNames
    
        strXMLFileName = strPath & "\" & CheckFileName(varPriceListName) & ".xml"
        
        Set objPriceList = ProductCatalog.GetPriceListByName(varPriceListName)
        
        If (objPriceList.Type <> PRICELIST_TYPE_PO) Then ' Private price liste
        
            If (Not ExportPriceList(strXMLFileName, varPriceListName, eExportMode, strCommandLine)) Then
            
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1042, "PL", varPriceListName), Me, "ExportPriceListMultiFile", LOG_ERROR
            End If
        End If
    Next
    ExportPriceListMultiFile = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ExportPriceListMultiFile", LOG_ERROR
End Function









Public Function TestBug(ByVal eExportMode As IMPORT_EXPORT_MODE, ByVal strCommandLine As String) As Boolean

    Dim Rowset                      As IMTRowSet
    Dim objProductOffering          As MTProductOffering
    Dim objProductOfferingNames     As collection
    Dim lngPriceListID              As Long
    Dim strName                     As String
    Dim PriceAbleItemInstamceRowset As IMTRowSet
    Dim Profiler                    As New CProfiler: Profiler.Start True, TypeName(Me), "ProductOffering"
    Dim varProductOfferingName      As Variant
    Dim objCommandLine              As New CCommandLine
    Dim i                           As Long
    
    
    Dim objMTLogger                 As Object
    
    
    On Error GoTo ErrMgr


'    Debug.Assert 0

    Set objMTLogger = CreateObject("MTLogger.MTLogger.1")
    objMTLogger.Init "logging", "[" & App.EXEName & ".Dll]" ' DUMMY_NAME mean that since DUMMY_NAME.XML does not exist we log into the default log file MTLOG.TXT


    ExportInit eExportMode, strCommandLine
    XMLOutputInitialize
    XMLOutPutTag "productofferings"
    
    MTPCImportExportModule.TRACE "BEGIN OF TEST", Me, "TestBug", LOG_WARNING
    MTPCImportExportModule.TRACE "BEGIN OF TEST", Me, "TestBug", LOG_WARNING
    MTPCImportExportModule.TRACE "BEGIN OF TEST", Me, "TestBug", LOG_WARNING
     
    objMTLogger.LogThis CLng(LOG_WARNING), "BEGIN OF TEST"
    objMTLogger.LogThis CLng(LOG_WARNING), "BEGIN OF TEST"
    objMTLogger.LogThis CLng(LOG_WARNING), "BEGIN OF TEST"
         
    
    For i = 1 To 256
    

        MTPCImportExportModule.TRACE "TestBug:" & i, Me, "TestBug", LOG_ERROR
        MTPCImportExportModule.TRACE "TestBug:" & i, Me, "TestBug", LOG_WARNING
        MTPCImportExportModule.TRACE "TestBug:" & i, Me, "TestBug", LOG_INFO
        MTPCImportExportModule.TRACE "TestBug:" & i, Me, "TestBug", LOG_DEBUG
        MTPCImportExportModule.TRACE "---------------------", Me, "TestBug", LOG_DEBUG
        
        
        objMTLogger.LogThis CLng(LOG_ERROR), "TestBug:" & i
        objMTLogger.LogThis CLng(LOG_WARNING), "TestBug:" & i
        objMTLogger.LogThis CLng(LOG_INFO), "TestBug:" & i
        objMTLogger.LogThis CLng(LOG_DEBUG), "TestBug:" & i
        objMTLogger.LogThis CLng(LOG_DEBUG), " ---------------------"
    Next
     
     MTPCImportExportModule.TRACE "EOF OF TEST", Me, "TestBug", LOG_WARNING
     MTPCImportExportModule.TRACE "EOF OF TEST", Me, "TestBug", LOG_WARNING
     MTPCImportExportModule.TRACE "EOF OF TEST", Me, "TestBug", LOG_WARNING
     
     objMTLogger.LogThis CLng(LOG_WARNING), "EOF OF TEST"
     objMTLogger.LogThis CLng(LOG_WARNING), "EOF OF TEST"
     objMTLogger.LogThis CLng(LOG_WARNING), "EOF OF TEST"
     
    ExportTerminate
    TestBug = True
    Exit Function
ErrMgr:
    MTPCImportExportModule.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, "ProductOffering", LOG_ERROR
End Function

