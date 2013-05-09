Attribute VB_Name = "Globals"
' meta data to be stored in some globally accesible instance
Public AttributeMetaDataCollection As New Collection
Public UsageMetaDataCollection As New Collection
Public RecurringChargeMetaDataCollection As New Collection
Public NonRecurringChargeMetaDataCollection As New Collection
Public DiscountMetaDataCollection As New Collection
Public ProductOfferingMetaDataCollection As New Collection
Public PriceListMetaDataCollection As New Collection
Public ParameterTableMetaDataCollection As New Collection
Public SubscriptionMetaDataCollection As New Collection
Public RateScheduleMetaDataCollection As New Collection

' next ID counter
Private NextID_ As Long

' the content of the product catalog
' (global since there might be multiple product catalog instance working on top of the same data)
Public PriceableItems_ As New Collection
Public ProductOfferings_ As New Collection
Public PriceLists_ As New Collection
Public ParamTableDefinitions_ As New Collection
Public AccountReferences_ As New Collection
Public CounterTypes_ As New Collection
Public Counters_ As New Collection
Public RateSchedules_ As New Collection

' return next unique ID to be used
Public Function NextID() As Long
    NextID = NextID_
    NextID_ = NextID_ + 1
End Function

Public Function CreateRateSchedule_(plID As Long, ptdID As Long) As MTRateSchedule
    Dim rs As New MTRateSchedule
    rs.ID = NextID()
    rs.PriceListID = plID
    rs.ParamTableDefID = ptdID
    RateSchedules_.Add rs
    Set CreateRateSchedule_ = rs
End Function

Public Sub Main()
    NextID_ = 1000
    
    LoadMetaData
    LoadSampleCatalog
    
End Sub


Private Sub AddAttrMeta(coll As Collection, nm As String, Optional defval As Variant = Empty)
    Dim meta As New MTAttributeMetaData
    meta.Name = nm
    meta.DefaultValue = defval
    coll.Add meta
End Sub

Private Sub AddPropMeta(coll As Collection, nm As String, cn As String, tp As String, isExtended As Boolean)
    Dim meta As New MTPropertyMetaData
    meta.Name = nm
    meta.DBColumnName = cn
    
    'workaround until sql rowset is fixed:
    If tp = "boolean" Then
        tp = "char"
    End If
      
    meta.DataType = tp
    If tp = "string" Then
        meta.Length = 255
    Else
        meta.Length = 10
    End If
    
    meta.DefaultValue = defval
    meta.Extended = isExtended
    coll.Add meta
End Sub

Private Sub LoadMetaData()
    
    'Attributes
    AddAttrMeta AttributeMetaDataCollection, "visible", False
    AddAttrMeta AttributeMetaDataCollection, "editable", False
    
    ' Usage
    AddPropMeta UsageMetaDataCollection, "ID", "id_prop", "int32", False
    AddPropMeta UsageMetaDataCollection, "Kind", "n_kind", "int32", False
    AddPropMeta UsageMetaDataCollection, "Name", "n_name", "string", False
    AddPropMeta UsageMetaDataCollection, "DisplayName", "n_displayname", "string", False
    
    AddPropMeta UsageMetaDataCollection, "Description", "n_desc", "string", False
    AddPropMeta UsageMetaDataCollection, "ServiceDefinition", "nm_servicedef", "string", False
    AddPropMeta UsageMetaDataCollection, "GLCODE", "nm_glcode", "string", True
    AddPropMeta UsageMetaDataCollection, "Category", "nm_category", "string", True
    AddPropMeta UsageMetaDataCollection, "Discountable", "b_discountable", "boolean", True
    AddPropMeta UsageMetaDataCollection, "Tax Exempt", "b_taxexempt", "boolean", True
    AddPropMeta UsageMetaDataCollection, "My Extended Property", "nm_MyProperty", "string", True

    ' RecurringCharge
    AddPropMeta RecurringChargeMetaDataCollection, "ID", "id_prop", "int32", False
    AddPropMeta RecurringChargeMetaDataCollection, "Kind", "n_kind", "int32", False
    AddPropMeta RecurringChargeMetaDataCollection, "Name", "n_name", "string", False
    AddPropMeta RecurringChargeMetaDataCollection, "DisplayName", "n_displayname", "string", False
    AddPropMeta RecurringChargeMetaDataCollection, "Description", "n_desc", "string", False
    AddPropMeta RecurringChargeMetaDataCollection, "ServiceDefinition", "nm_servicedef", "string", False
    AddPropMeta RecurringChargeMetaDataCollection, "GLCODE", "nm_glcode", "string", True
    AddPropMeta RecurringChargeMetaDataCollection, "Category", "nm_category", "string", True
    AddPropMeta RecurringChargeMetaDataCollection, "Discountable", "b_discountable", "boolean", True
    AddPropMeta RecurringChargeMetaDataCollection, "Tax Exempt", "b_taxexempt", "boolean", True
    AddPropMeta RecurringChargeMetaDataCollection, "ProrateOnActivation", "b_ProrateOnActivation", "boolean", False
    AddPropMeta RecurringChargeMetaDataCollection, "ProrateOnDeactivation", "b_ProrateOnDeactivation", "boolean", False
    AddPropMeta RecurringChargeMetaDataCollection, "ChargeInAdvance", "b_ChargeInAdvance", "Boolean", False
    AddPropMeta RecurringChargeMetaDataCollection, "ProrationType", "b_ProrationType", "int32", False

    AddPropMeta RecurringChargeMetaDataCollection, "Cycle", "", "object", False
    AddPropMeta RecurringChargeMetaDataCollection, "CycleID", "", "int32", False

    'NonRecurringCharge
    AddPropMeta NonRecurringChargeMetaDataCollection, "ID", "id_prop", "int32", False
    AddPropMeta NonRecurringChargeMetaDataCollection, "Kind", "n_kind", "int32", False
    AddPropMeta NonRecurringChargeMetaDataCollection, "Name", "n_name", "string", False
    AddPropMeta NonRecurringChargeMetaDataCollection, "DisplayName", "n_displayname", "string", False
    AddPropMeta NonRecurringChargeMetaDataCollection, "Description", "n_desc", "string", False
    AddPropMeta NonRecurringChargeMetaDataCollection, "ServiceDefinition", "nm_servicedef", "string", False
    AddPropMeta NonRecurringChargeMetaDataCollection, "GLCODE", "nm_glcode", "string", True
    AddPropMeta NonRecurringChargeMetaDataCollection, "Category", "nm_category", "string", True
    AddPropMeta NonRecurringChargeMetaDataCollection, "Discountable", "b_discountable", "boolean", True
    AddPropMeta NonRecurringChargeMetaDataCollection, "Tax Exempt", "b_taxexempt", "boolean", True
     AddPropMeta NonRecurringChargeMetaDataCollection, "RecurringChargeEvent", "b_RecurringChargeEvent", "int32", False

    'Discount
    AddPropMeta DiscountMetaDataCollection, "ID", "id_prop", "int32", False
    AddPropMeta DiscountMetaDataCollection, "Kind", "n_kind", "int32", False
    AddPropMeta DiscountMetaDataCollection, "Name", "n_name", "string", False
    AddPropMeta DiscountMetaDataCollection, "DisplayName", "n_displayname", "string", False
    AddPropMeta DiscountMetaDataCollection, "Description", "n_desc", "string", False
    AddPropMeta DiscountMetaDataCollection, "ServiceDefinition", "nm_servicedef", "string", False
    AddPropMeta DiscountMetaDataCollection, "TargetValueType", "", "int32", False
    AddPropMeta DiscountMetaDataCollection, "Cycle", "", "object", False
    AddPropMeta DiscountMetaDataCollection, "CycleID", "", "int32", False
    AddPropMeta DiscountMetaDataCollection, "GLCODE", "nm_glcode", "string", True
    AddPropMeta DiscountMetaDataCollection, "Category", "nm_category", "string", True
    AddPropMeta DiscountMetaDataCollection, "Discountable", "b_discountable", "boolean", True
    AddPropMeta DiscountMetaDataCollection, "Tax Exempt", "b_taxexempt", "boolean", True

    'ProductOffering
    AddPropMeta ProductOfferingMetaDataCollection, "ID", "id_prop", "int32", False
    AddPropMeta ProductOfferingMetaDataCollection, "Name", "n_name", "string", False
    AddPropMeta ProductOfferingMetaDataCollection, "DisplayName", "n_displayname", "string", False
    AddPropMeta ProductOfferingMetaDataCollection, "Description", "n_desc", "string", False
    AddPropMeta ProductOfferingMetaDataCollection, "SelfSubscribable", "b_user_susbscribe", "boolean", False
    AddPropMeta ProductOfferingMetaDataCollection, "SelfUnsubscribable", "b_user_unsusbscribe", "boolean", False
    AddPropMeta ProductOfferingMetaDataCollection, "Category", "nm_category", "string", True
    AddPropMeta ProductOfferingMetaDataCollection, "InternalInformationURL", "nm_InternalInformationURL", "string", True
    AddPropMeta ProductOfferingMetaDataCollection, "ExternalInformationURL", "nm_ExternalInformationURL", "string", True
    
    'ProductOffering - Sub Object
    AddPropMeta ProductOfferingMetaDataCollection, "EffectiveDate", "", "object", False
    AddPropMeta ProductOfferingMetaDataCollection, "AvailabilityDate", "", "object", False

    'PriceList
    AddPropMeta PriceListMetaDataCollection, "ID", "id_prop", "int32", False
    AddPropMeta PriceListMetaDataCollection, "Name", "n_name", "string", False
    AddPropMeta PriceListMetaDataCollection, "Description", "n_desc", "string", False
    AddPropMeta PriceListMetaDataCollection, "CurrencyCode", "nm_currency_code", "string", False
    AddPropMeta PriceListMetaDataCollection, "Category", "nm_category", "string", True
    ' The property below shouldn't really be there. Testing purposes only.
    AddPropMeta PriceListMetaDataCollection, "HasRates", "nm_hasrates", "string", True

    'Parameter Table
    AddPropMeta ParameterTableMetaDataCollection, "ID", "id_prop", "int32", False
    AddPropMeta ParameterTableMetaDataCollection, "Name", "n_name", "string", False
    AddPropMeta ParameterTableMetaDataCollection, "ConditionHeader", "nm_condheader", "string", False
    AddPropMeta ParameterTableMetaDataCollection, "ActionHeader", "nm_actheader", "string", False
    AddPropMeta ParameterTableMetaDataCollection, "HelpURL", "nm_helpurl", "string", False

    ' Subscription
    AddPropMeta SubscriptionMetaDataCollection, "ID", "id_prop", "int32", False
    AddPropMeta SubscriptionMetaDataCollection, "Active", "b_Active", "boolean", False
    AddPropMeta SubscriptionMetaDataCollection, "UseEffectiveDate", "b_UseEffectiveDate", "boolean", False
    AddPropMeta SubscriptionMetaDataCollection, "EffectiveDate", "", "object", False
    
    'RateSchedule
    AddPropMeta RateScheduleMetaDataCollection, "ID", "id_prop", "int32", False
    AddPropMeta RateScheduleMetaDataCollection, "Name", "n_name", "string", False
    AddPropMeta RateScheduleMetaDataCollection, "Start Date", "nm_startdate", "string", False
    AddPropMeta RateScheduleMetaDataCollection, "End Date", "nm_enddate", "string", False
    
End Sub

' load a sample set
Private Sub LoadSampleCatalog()

    Dim pc As New MTProductCatalog

    '--- parameter tables -------------
    Dim ptd As MTParamTableDefinition
    
    'Rates
    Set ptd = pc.CreateParamTableDefinition
    ptd.Name = "Rates"
    ptd.Save

    'Taxes
    Set ptd = pc.CreateParamTableDefinition
    ptd.Name = "Taxes"
    ptd.Save

    'Unused Port Calculation
    Set ptd = pc.CreateParamTableDefinition
    ptd.Name = "Unused Port Calculation"
    ptd.ConditionHeader = "Conditions"
    ptd.ActionHeader = "Actions"
    ptd.Save
    
    'Calendar
    Set ptd = pc.CreateParamTableDefinition
    ptd.Name = "Calendar"
    ptd.ConditionHeader = "Conditions"
    ptd.ActionHeader = "Actions"
    ptd.Save
    
    'Video Conference
    Set ptd = pc.CreateParamTableDefinition
    ptd.Name = "Video Conference Rates"
    ptd.ConditionHeader = "Conditions"
    ptd.ActionHeader = "Actions"
    
    ' condition meta data
    Dim ConditionMetaData As New Collection
    Dim conditionMeta As MTConditionMetaData

    Set conditionMeta = New MTConditionMetaData
    conditionMeta.PropertyName = "Duration"
    conditionMeta.DataType = "int32"
    'conditionMeta.Operator = OPERATOR_TYPE_LESS
    conditionMeta.OperatorPerRule = True

    ConditionMetaData.Add conditionMeta

    Set ptd.ConditionMetaData = ConditionMetaData
    
    ' action meta data
    Dim ActionMetaData As New Collection
    Dim actionMeta As MTActionMetaData

    Set actionMeta = New MTActionMetaData
    actionMeta.PropertyName = "Rate"
    actionMeta.DataType = "decimal"
    ActionMetaData.Add actionMeta

    Set actionMeta = New MTActionMetaData
    actionMeta.PropertyName = "MTI"
    actionMeta.DataType = "int32"
    ActionMetaData.Add actionMeta

    Set actionMeta = New MTActionMetaData
    actionMeta.PropertyName = "MinCharge"
    actionMeta.DataType = "decimal"
    ActionMetaData.Add actionMeta

    Set actionMeta = New MTActionMetaData
    actionMeta.PropertyName = "MinUOM"
    actionMeta.DataType = "string"
    ActionMetaData.Add actionMeta

    Set actionMeta = New MTActionMetaData
    actionMeta.PropertyName = "SetupCharge"
    actionMeta.DataType = "decimal"
    ActionMetaData.Add actionMeta
    
    Set ptd.ActionMetaData = ActionMetaData
    
    
    
    ptd.Save
    

    Set ptd = pc.CreateParamTableDefinition
    ptd.Name = "Video Conference Cancellation Charges"
    ptd.ConditionHeader = "Conditions"
    ptd.ActionHeader = "Actions"
    ptd.Save

    Set ptd = pc.CreateParamTableDefinition
    ptd.Name = "Video Conference Connection Rates"
    ptd.ConditionHeader = "Conditions"
    ptd.ActionHeader = "Actions"
    ptd.Save

    '
    ' RateConn (added by dyoung)
    '
    Set ptd = pc.CreateParamTableDefinition
    ptd.Name = "RateConn"
    ptd.ConditionHeader = "Conditions"
    ptd.ActionHeader = "Actions"

    ' condition meta data
    Dim ConditionMetaData2 As New Collection ' already defined above
    Dim conditionMeta2 As MTConditionMetaData ' already defined above

    Set conditionMeta2 = New MTConditionMetaData
    conditionMeta2.PropertyName = "Duration"
    conditionMeta2.DataType = "int32"
    'conditionMeta.Operator = OPERATOR_TYPE_LESS
    conditionMeta2.OperatorPerRule = True

    ConditionMetaData2.Add conditionMeta

    Set ptd.ConditionMetaData = ConditionMetaData2
    
    ' action meta data
    Dim ActionMetaData2 As New Collection ' already defined above
    Dim actionMeta2 As MTActionMetaData ' already defined above

    Set actionMeta2 = New MTActionMetaData
    actionMeta2.PropertyName = "Rate"
    actionMeta2.DataType = "decimal"
    ActionMetaData2.Add actionMeta

    Set actionMeta2 = New MTActionMetaData
    actionMeta2.PropertyName = "MTI"
    actionMeta2.DataType = "int32"
    ActionMetaData2.Add actionMeta

    Set actionMeta2 = New MTActionMetaData
    actionMeta2.PropertyName = "MinCharge"
    actionMeta2.DataType = "decimal"
    ActionMetaData2.Add actionMeta

    Set actionMeta2 = New MTActionMetaData
    actionMeta2.PropertyName = "MinUOM"
    actionMeta2.DataType = "string"
    ActionMetaData2.Add actionMeta

    Set actionMeta2 = New MTActionMetaData
    actionMeta2.PropertyName = "SetupCharge"
    actionMeta2.DataType = "decimal"
    ActionMetaData2.Add actionMeta
    
    Set ptd.ActionMetaData = ActionMetaData2
    
    '---------Counter Types -----
    Dim ct As New MTCounterType
    
    ct.Name = "SummationOnOneProductViewProperty"
    ct.Description = "Simple SUM aggregate over one product view property"
    ct.FormulaTemplate = "SUM(%%A%%)"
    
    Dim param As New MTCounterParameter
    
    param.DBType = "STRING"
    param.Kind = "PRODUCT_VIEW_PROPERTY"
    param.Name = "A"
    
    ct.AddParam_ param
    
    CounterTypes_.Add ct
    
    Dim ct1 As New MTCounterType
    
    ct1.Name = "SUM(A)+SUM(B)+SUM(C)"
    ct.Description = "Summation over three parameters"
    ct.FormulaTemplate = "SUM(%%A%%)+SUM(%%B%%)+SUM(%%C%%)"
    
    Set param = New MTCounterParameter
    
    param.DBType = "STRING"
    param.Kind = "PRODUCT_VIEW_PROPERTY"
    param.Name = "A"
    
    ct1.AddParam_ param
    
    
    
    Set param = New MTCounterParameter
    
    param.DBType = "STRING"
    param.Kind = "PRODUCT_VIEW"
    param.Name = "B"
    
    ct1.AddParam_ param
    
    
    Set param = New MTCounterParameter
    
    param.Kind = "CONST"
    param.Name = "C"
    
    ct1.AddParam_ param
    
    CounterTypes_.Add ct1
    
    '---------Counters -----
    
    Dim c As MTCounter
    
    Set c = ct.CreateCounter
    
    c.Name = "TotalFaxPages"
    c.ID = 123
    c.Description = "SUM over total fax pages"
    c.SetParameter "A", "t_pv_fax/TotalPages", False
    c.Formula = "SUM(t_pv_fax.TotalPages)"
    c.Save
    
    Counters_.Add c
    
    Dim c1 As MTCounter
    
    Set c1 = ct1.CreateCounter
    
    c1.Name = "Some Boris' wacked counter"
    c1.ID = 124
    c1.Description = "Meaningless Summation on PV prop, PV and a CONST"
    c1.SetParameter "A", "t_pv_fax/TotalPages", False
    c1.SetParameter "B", "t_pv_audioconfcall", False
    c1.SetParameter "C", 1000, False
    c.Formula = "SUM(t_pv_fax.TotalPages) + COUNT(t_pv_audioconfcall.*) + 1000"
    
    c1.Save
    
    Counters_.Add c1


    '---PriceableItems-----------
    Dim prcItem As MTUsageCharge
    Dim recChrg As MTRecurringCharge
    Dim NonRecChrg As MTNonRecurringCharge
     
    ' conferencing
    Set prcItem = pc.CreateUsageCharge
    prcItem.Name = "Audio Conferencing"
    prcItem.DisplayName = "Audio Conferencing"
    prcItem.Description = "Audio Conferencing charges"
    prcItem.Properties.Item("GLCODE").Value = "GL-432"
    prcItem.Properties.Item("GLCODE").Attributes.Item("visible").Value = True
    prcItem.Properties.Item("Tax Exempt").Value = True
    prcItem.Properties.Item("Tax Exempt").Attributes.Item("visible").Value = False
    
    prcItem.Properties.Item("My Extended Property").Value = "Kevin is awesome!"
    prcItem.Properties.Item("My Extended Property").Attributes.Item("visible").Value = False
    prcItem.Save
    
    ' child: conference - usage
    Dim prcItem2 As MTUsageCharge
    Set prcItem2 = prcItem.CreateUsageChargeChild
    prcItem2.Name = "Conference - usage"
    prcItem2.DisplayName = "Conference - usage"
    prcItem2.Description = "Usage charges for conference connection"
    prcItem2.Properties.Item("GLCODE").Value = "GL-432"
    prcItem2.Properties.Item("GLCODE").Attributes.Item("visible").Value = True
    prcItem2.Properties.Item("Tax Exempt").Value = False
    prcItem2.Properties.Item("Tax Exempt").Attributes.Item("visible").Value = False
    prcItem.Properties.Item("My Extended Property").Value = "The GUI Team Rules!"
    prcItem.Properties.Item("My Extended Property").Attributes.Item("visible").Value = False
    prcItem2.Save
   
    ' child: Bridge - usage
    Dim prcItem3 As MTUsageCharge
    Set prcItem3 = prcItem2.CreateUsageChargeChild
    prcItem3.Name = "Bridge - usage"
    prcItem3.DisplayName = "Bridge - usage"
    prcItem3.Description = "Charge for bridge time"
    prcItem3.Save
    prcItem3.AddParamTableDefinition pc.GetParamTableDefinitionByName("Rates").ID
    prcItem3.AddParamTableDefinition pc.GetParamTableDefinitionByName("Calendar").ID
    prcItem3.AddParamTableDefinition pc.GetParamTableDefinitionByName("Taxes").ID
    
    ' child: Transport - usage
    Set prcItem3 = prcItem2.CreateUsageChargeChild
    prcItem3.Name = "Transport - usage"
    prcItem3.DisplayName = "Transport - usage"
    prcItem3.Description = "Charge for transport time"
    prcItem3.Save
    prcItem3.AddParamTableDefinition pc.GetParamTableDefinitionByName("Rates").ID
    prcItem3.AddParamTableDefinition pc.GetParamTableDefinitionByName("Calendar").ID
    prcItem3.AddParamTableDefinition pc.GetParamTableDefinitionByName("Taxes").ID
    
    ' child: Cancellation
    Set prcItem3 = prcItem.CreateUsageChargeChild
    prcItem3.Name = "Cancellation"
    prcItem3.DisplayName = "Cancellation"
    prcItem3.Description = "Conference Cancellation charge"
    prcItem3.Save
    prcItem3.AddParamTableDefinition pc.GetParamTableDefinitionByName("Rates").ID
    prcItem3.AddParamTableDefinition pc.GetParamTableDefinitionByName("Taxes").ID
    
    ' child: Unused Ports
    Set prcItem3 = prcItem.CreateUsageChargeChild
    prcItem3.Name = "Unused Ports"
    prcItem3.DisplayName = "Unused Ports"
    prcItem3.Description = "Charge for unused ports"
    prcItem3.Save
    prcItem3.AddParamTableDefinition pc.GetParamTableDefinitionByName("Rates").ID
    prcItem3.AddParamTableDefinition pc.GetParamTableDefinitionByName("Taxes").ID
    prcItem3.AddParamTableDefinition pc.GetParamTableDefinitionByName("Unused Port Calculation").ID
    
    ' Monthly Service Charge
    Set recChrg = pc.CreateRecurringCharge
    recChrg.Name = "Monthly Service Charge"
    recChrg.DisplayName = "Monthly Service Charge"
    recChrg.Description = "Monthly service charge"
    recChrg.Save
    recChrg.AddParamTableDefinition pc.GetParamTableDefinitionByName("Rates").ID
    recChrg.AddParamTableDefinition pc.GetParamTableDefinitionByName("Taxes").ID
 
    ' Usage
    Dim prcItem4 As MTUsageCharge
    Set prcItem4 = pc.CreateUsageCharge
    prcItem4.Name = "Email Broadcast"
    prcItem4.DisplayName = "Email Broadcast"
    prcItem4.Description = "Email Broadcast"
    prcItem4.Properties.Item("GLCODE").Value = "GL-502"
    prcItem4.Properties.Item("GLCODE").Attributes.Item("visible").Value = True
    prcItem4.Properties.Item("Tax Exempt").Value = True
    prcItem4.Properties.Item("Tax Exempt").Attributes.Item("visible").Value = False
    
    prcItem4.Save

    
    ' conferencing
    Dim prcItem5 As MTUsageCharge
    Set prcItem5 = pc.CreateUsageCharge
    prcItem5.Name = "Video Conferencing"
    prcItem5.DisplayName = "Video Conferencing"
    prcItem5.Description = "Video Conferencing charges"
    prcItem5.Properties.Item("GLCODE").Value = "GL-600"
    prcItem5.Properties.Item("GLCODE").Attributes.Item("visible").Value = True
    prcItem5.Properties.Item("Tax Exempt").Value = True
    prcItem5.Properties.Item("Tax Exempt").Attributes.Item("visible").Value = False
    
    prcItem5.AddParamTableDefinition pc.GetParamTableDefinitionByName("Video Conference Rates").ID
    'prcItem5.AddParamTableDefinition pc.GetParamTableDefinitionByName("Video Conference Cancellation Charges").ID
    
    prcItem5.Save
    
    ' child: conference - usage
    Dim prcItem6 As MTUsageCharge
    Set prcItem6 = prcItem5.CreateUsageChargeChild
    prcItem6.Name = "Video Conference Connection"
    prcItem6.DisplayName = "Video Conference Connection"
    prcItem6.Description = "Usage charges for conference connection"
    prcItem6.Properties.Item("GLCODE").Value = "GL-601"
    prcItem6.Properties.Item("GLCODE").Attributes.Item("visible").Value = True
    prcItem6.Properties.Item("Tax Exempt").Value = False
    prcItem6.Properties.Item("Tax Exempt").Attributes.Item("visible").Value = False
    
    prcItem6.Save
    
    prcItem6.AddParamTableDefinition pc.GetParamTableDefinitionByName("Video Conference Connection Rates").ID
   
    
    '---PriceLists-------------------
    Dim prcList As MTPriceList
    
    ' Fortune 500 list
    Set prcList = pc.CreatePriceList
    prcList.Name = "Fortune 500 list"
    prcList.Description = "Fortune 500 list"
    prcList.CurrencyCode = "USD"
    prcList.HasRates = "Yes"
    prcList.Save
    
    ' Base list list
    Set prcList = pc.CreatePriceList
    prcList.Name = "Base list"
    prcList.Description = "Base list"
    prcList.CurrencyCode = "USD"
    prcList.HasRates = "No"
    prcList.Save

    '---Discounts---------------------
    Dim discount As MTDiscount
    ' Crazy Discount
    Set discount = pc.CreateDiscount
    discount.Name = "Crazy Discount"
    discount.DisplayName = "Somewhat Eccentric Discount"
    discount.Description = "Save BIG money!"
    discount.Properties.Item("GLCODE").Value = "GL-Discount123"
    discount.Properties.Item("GLCODE").Attributes.Item("visible").Value = True
    'discount.AddParamTableDefinition pc.GetParamTableDefinitionByName("TieredDiscount").ID
    discount.Save
    
    ' Simple Discount
    Set discount = pc.CreateDiscount
    discount.Name = "Simple Discount"
    discount.DisplayName = "Discount"
    discount.Description = "Save a good amount of money!"
    discount.Properties.Item("GLCODE").Value = "GL-Discount124"
    'discount.Properties.Item("GLCODE").Attributes.Item("visible").Value = True
    discount.Save
    'discount.AddCounter c.ID, MTCounterKind.COUNTER_QUALIFIER
    
    
    '---Product Offerings ------------
    Dim prodOff As MTProductOffering
    
    ' Fortune 500 plan
    Set prodOff = pc.CreateProductOffering
    prodOff.Name = "Fortune 500 Plan"
    prodOff.DisplayName = "Fortune 500 Super Saver Package"
    prodOff.SelfSubscribable = True
    prodOff.SelfUnsubscribable = False
    
    prodOff.EffectiveDate.StartDate = Now()
    prodOff.AvailabilityDate.StartDate = Now()
    
    prodOff.Properties.Item("InternalInformationURL").Value = "http://www.cnn.com"
    
    prodOff.Save
    
    prodOff.AddPriceableItem pc.GetPriceableItemByName("Audio Conferencing").ID
    
    Dim pi As Object
    Dim piInstance As Object
    
    Set pi = pc.GetPriceableItemByName("Video Conferencing")
    Set piInstance = prodOff.AddPriceableItem(pi.ID)
    Set ptd = pc.GetParamTableDefinitionByName("Video Conference Rates")
    Set prcList = pc.GetPriceListByName("Fortune 500 list")
    piInstance.SetPriceListMapping ptd.ID, prcList.ID
    
    'set the pricelist mapping for the child
    Set ptd = pc.GetParamTableDefinitionByName("Video Conference Connection Rates")
    Set piInstance = prodOff.GetPriceableItemByName("Video Conference Connection")
    
    piInstance.SetPriceListMapping ptd.ID, prcList.ID
    
    
    Set pi = pc.GetPriceableItemByName("Monthly Service Charge")
    Set piInstance = prodOff.AddPriceableItem(pi.ID)
    Set ptd = pc.GetParamTableDefinitionByName("Rates")
    Set prcList = pc.GetPriceListByName("Fortune 500 list")
    piInstance.SetPriceListMapping ptd.ID, prcList.ID
    
    ' Base offering
    Set prodOff = pc.CreateProductOffering
    prodOff.Name = "Base offering"
    prodOff.DisplayName = "Basic Package"
    prodOff.AddPriceableItem pc.GetPriceableItemByName("Audio Conferencing").ID
    prodOff.AddPriceableItem pc.GetPriceableItemByName("Monthly Service Charge").ID
    prodOff.Save
    
    '--- accounts ----
    pc.CreateAccountReference 1000
    pc.CreateAccountReference 1001
    pc.CreateAccountReference 1002
    pc.CreateAccountReference 1003

    '--- subscribtions ---
    
    ' subscribe acct 1000 to Fortune 500 Plan
    Dim acct As MTAccountReference
    Set acct = pc.GetAccountReference(1000)
    Set prodOff = pc.GetProductOfferingByName("Fortune 500 Plan")
    Dim subscr As MTSubscription
    Dim effDate As New MTTimeSpan
    
    effDate.StartDate = Now()
    effDate.EndDate = "5/18/2001 9:00:22 AM "
    
    Set subscr = acct.Subscribe(prodOff.ID, effDate)
    
    'set icb pl for account 1000, Fortune 500 Plan, Monthly Service Charge
    Set prcList = acct.GetICBPriceList
    Dim prcItemInstance As Object 'PriceableItem
    Set prcItemInstance = subscr.GetProductOffering().GetPriceableItemByName("Monthly Service Charge")
    Dim paramTableDef As MTParamTableDefinition
    Set paramTableDef = pc.GetParamTableDefinitionByName("Rates")
    subscr.SetICBPriceListMapping prcItemInstance.ID, paramTableDef.ID, prcList.ID
   
    ' Non Recurring Charge
    Set NonRecChrg = pc.CreateNonRecurringCharge
    NonRecChrg.Name = "Srini Non Recurring Charge"
    NonRecChrg.Description = "Good charge"
    NonRecChrg.Save

    ' Data for Rates
    ' Rate Schedules
    ' Pricelist Mappings
    Set prodOff = pc.GetProductOfferingByName("Fortune 500 Plan")
    
    Set piInstance = prodOff.GetPriceableItemByName("Video Conferencing")
    
    Set ptd = pc.GetParamTableDefinitionByName("Video Conference Rates")
    
    Dim plm As MTPriceListMapping
    
    Set plm = piInstance.GetPriceListMapping(ptd.ID)

    Dim rs As MTRateSchedule
    Dim rs2 As MTRateSchedule
    
    Set rs = plm.CreateRateSchedule()
    rs.Name = "Reg rates"
    rs.EffectiveDate.StartDate = #1/12/2001#
    rs.EffectiveDate.EndDate = #12/12/2001#
    rs.EffectiveDate.EndDateType = DATE_TYPE_ABSOLUTE
    rs.EffectiveDate.EndDateType = DATE_TYPE_ABSOLUTE
    
    Set rs2 = plm.CreateRateSchedule
    rs2.Name = "Special Rates"
    rs2.EffectiveDate.StartDate = #6/30/2001#
    ' rs2.EffectiveDate.EndDate =
    rs2.EffectiveDate.EndDateType = DATE_TYPE_ABSOLUTE
    rs2.EffectiveDate.EndDateType = DATE_TYPE_ABSOLUTE
    
    ' Pricelist Based Rates
    Set ptd = pc.GetParamTableDefinitionByName("Video Conference Rates")
    Set pl = pc.GetPriceListByName("Fortune 500 list")
    Set rs = CreateRateSchedule_(pl.ID, ptd.ID)
    
    rs.Name = "PL Reg Rates"
    rs.EffectiveDate.StartDateType = DATE_TYPE_ABSOLUTE
    rs.EffectiveDate.StartDate = #12/12/2000#
    rs.EffectiveDate.EndDateType = DATE_TYPE_ABSOLUTE
    rs.EffectiveDate.EndDate = #12/12/2001#
    
    Set rs = CreateRateSchedule_(pl.ID, ptd.ID)
    rs.Name = "PL Special Rates"
    rs.EffectiveDate.StartDateType = DATE_TYPE_ABSOLUTE
    rs.EffectiveDate.StartDate = #6/1/2001#
    rs.EffectiveDate.EndDateType = DATE_TYPE_ABSOLUTE
    rs.EffectiveDate.EndDate = #7/1/2001#

End Sub


