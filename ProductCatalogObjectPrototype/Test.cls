VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Test"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' Object: Test
' Description: helper object to hold a bunch of unit tests

Option Explicit

'=== public properties ======================================================

' a product catalog instance accessible to all test methods
Public ProdCat As New MTProductCatalog

'=== dump the catalog =======================================================

'dumps the whole catalog a file (default: c:\temp\dump.txt) and debug window
Public Sub DumpCatalog(Optional FileName As String)
   
   If FileName = "" Then
    FileName = "c:\temp\dump.txt"
   End If

   Open FileName For Output As #1
   
    Dim pi As Object
    For Each pi In PriceableItems_
        DumpPriceableItem pi, 0
    Next

    Dim po As MTProductOffering
    For Each po In ProductOfferings_
        Dump ("PO(" & po.ID & "): " & po.Name)
        DumpProperties po.Properties, 2
        'dump pi's
        For Each pi In po.GetPriceableItems
            DumpPriceableItem pi, 2
        Next
    Next

    Dim acct As MTAccountReference
    For Each acct In AccountReferences_
        Dump ("Acct: " & acct.AccountID)
        'dump subscription
        Dim subscr As MTSubscription
        For Each subscr In acct.GetActiveSubscriptions
            DumpSubscription subscr, 2
        Next
    Next


    Close #1
    
End Sub

' dump to debug window and file
Public Sub Dump(s As String)
    Debug.Print s
    Print #1, s
End Sub

Public Sub DumpPriceableItem(pi As Object, indent As Integer)
        
        'dump this pi
        Dim k As String
        Select Case pi.Kind
            Case PI_TYPE_USAGE
                k = "Usage"
            Case PI_TYPE_RECURRING
                k = "RecurChrg"
            Case PI_TYPE_NON_RECURRING
                k = "NonRecChrg"
            Case PI_TYPE_DISCOUNT
                k = "Discount"
        End Select
        Dump Space(indent) & "PI(" & pi.ID & ") - " & k & ": " & pi.Name
        DumpProperties pi.Properties, indent + 2
        
        'dump paramtable def
        Dim ptd As MTParamTableDefinition
        For Each ptd In pi.GetParamTableDefinitions
            Dim str As String
            str = Space(indent + 2) & "paramtable(" & ptd.ID & ") - " & ptd.Name
            
            ' append pricelist mapping (if instance)
            Dim plm As MTPriceListMapping
            Set plm = pi.GetPriceListMapping(ptd.ID)
            If Not plm Is Nothing Then
                Dim pl As MTPriceList
                str = str & ": prcList:"
                If plm.PriceListID = 0 Then
                    str = str & "--"
                Else
                    Set pl = ProdCat.GetPriceList(plm.PriceListID)
                    str = str & pl.Name
                End If
                str = str & ", canICB: " & plm.CanICB
            End If
            Dump str
        Next

        'dump child pi's
        Dim child As Object
        For Each child In pi.GetChildren
            DumpPriceableItem child, indent + 2
        Next
End Sub

Public Sub DumpProperties(props As MTProperties, indent As Integer)
    Dim prop As MTProperty
    For Each prop In props
        Dim str As String
        str = Space(indent)
        
        ' denote core props as c-, extended as x-
        If prop.GetMetaData().Extended Then
            str = str & "x-"
        Else
            str = str & "c-"
        End If
        
        ' add name and value

        If prop.GetMetaData().DataType = "object" Then
            str = str & prop.GetMetaData().Name & ": object:" & TypeName(prop.Value)
        Else
            str = str & prop.GetMetaData().Name & ": " & prop.Value
        End If
        
        'add attributes
        Dim attr As MTAttribute
        str = str & " ["
        ' todo: For Each attr In prop.Attributes.NewEnum
        Dim i As Integer
        For i = 1 To prop.Attributes.Count
            Set attr = prop.Attributes.Item(i)
            str = str & attr.GetMetaData().Name & "=" & attr.Value & " "
        Next
        str = str & "]"
            
        Dump str
    Next
End Sub

Public Sub DumpSubscription(subscr As MTSubscription, indent As Integer)
        
        Dim po As MTProductOffering
        Set po = subscr.GetProductOffering()
        Dump Space(indent) & "Subscr(" & subscr.ID & "):  po:" & po.Name & _
             ", active:" & subscr.Active & _
             ", eff:" & subscr.EffectiveDate.StartDate & "-" & subscr.EffectiveDate.EndDate
        
        'pricelist lists:
        Dim plm As MTPriceListMapping
        For Each plm In subscr.GetICBPriceListMappings
            Dim pi As Object
            Set pi = po.GetPriceableItem(plm.PriceableItemID)
            Dim ptd As MTParamTableDefinition
            Set ptd = ProdCat.GetParamTableDefinition(plm.ParamTableDefinitionID)
            Dump Space(indent + 2) & pi.Name & ", " & ptd.Name & ", " & plm.PriceListID
        Next
End Sub


'=== use cases =================================================

Sub MCM_1_ConfigureExistingDiscount()
'TODO
End Sub

Sub MCM_2_CreatePriceList()
    Dim pl As MTPriceList
    Set pl = ProdCat.CreatePriceList
    pl.Name = "Fortune 1000 list"
    pl.CurrencyCode = "DEM"
    pl.Save
End Sub

Sub MCM_3_EditPriceListValues()
' TODO = edit rates
End Sub

Sub MCM_5_ViewSystemRate()
' TODO
End Sub

Sub MCM_7_SetComponentValues()
' TODO
End Sub

Sub MCM_8_CreateProductOffering()
    Dim prodOff As MTProductOffering
    Set prodOff = ProdCat.CreateProductOffering
    
    prodOff.Name = "SuperPlan"
    prodOff.Description = "best rates ever"
    prodOff.Save
    
    ' add a usage priceable item
    Dim prcItemTemplate As Object 'a PriceableItem
    Dim prcItemInstance As Object 'a PriceableItem
    Set prcItemTemplate = ProdCat.GetPriceableItemByName("Audio Conferencing")
    Set prcItemInstance = prodOff.AddPriceableItem(prcItemTemplate.ID)
    
    'set instance specific properties of priceable item instance
    prcItemInstance.Name = "SuperConferencing"
    prcItemInstance.Save
    
    ' add a recurring charge
    Set prcItemTemplate = ProdCat.GetPriceableItemByName("Monthly Service Charge")
    Set prcItemInstance = prodOff.AddPriceableItem(prcItemTemplate.ID)
    
    'set the price list for the "Rates" parameter table
    Dim paramTableDef As MTParamTableDefinition
    Set paramTableDef = ProdCat.GetParamTableDefinitionByName("Rates")
    
    Dim prcList As MTPriceList
    Set prcList = ProdCat.GetPriceListByName("Fortune 1000 list")
    prcItemInstance.SetPriceListMapping paramTableDef.ID, prcList.ID
    
    'TODO : add discount
    
    ' set effective date
    prodOff.EffectiveDate.StartDate = Now()
    prodOff.Save
    
    ' Test it here (AvailabilityDate is 0)
    
    ' test passed, set AvailabilityDate
    prodOff.AvailabilityDate.StartDate = Now()
    prodOff.Save
    
End Sub

Sub MCM_9_EditProductOffering()
    
    Dim prodOff As MTProductOffering
    Set prodOff = ProdCat.GetProductOfferingByName("SuperPlan")
    
    'change Name
    prodOff.Name = "HyperPlan"
    
    ' set an extended property
    prodOff.Properties("Category").Value = "GreatPlans"
    prodOff.Save
    
    'remove priceable item instance
    Dim prcItemInstance As Object 'PriceableItem
    Set prcItemInstance = prodOff.GetPriceableItemByName("SuperConferencing")
    prodOff.RemovePriceableItem prcItemInstance.ID
    
    'add priceable item instance
    Dim prcItemTemplate As Object 'PriceableItem
    Set prcItemTemplate = ProdCat.GetPriceableItemByName("Audio Conferencing")
    Set prcItemInstance = prodOff.AddPriceableItem(prcItemTemplate.ID)
    
    ' see MCM_11_DefinePriceableItemInstances for modification of priceableitem instances

    'set subscribability
    prodOff.SelfSubscribable = True
    prodOff.SelfUnsubscribable = False
    
    'change effective date
    prodOff.EffectiveDate.StartDate = #12/25/2001#
    prodOff.EffectiveDate.EndDate = #12/26/2001#
    prodOff.Save
    
    ' test it (AvailabilityDate is 0)
    
    ' test passed, set AvailabilityDate
    prodOff.AvailabilityDate.StartDate = Now()
    prodOff.Save

End Sub

Sub MCM_10_DefineRecurringCharge()
    Dim recChrg As MTRecurringCharge
    
    Set recChrg = ProdCat.CreateRecurringCharge
        
    'set cycle
'    recChrg.Cycle.CycleType = CYCLE_TYPE_WEEKLY
'    recChrg.Cycle.DayOfWeek = DAY_OF_WEEK_TUESDAY
    
    'proration
    recChrg.ProrateOnActivation = True
    recChrg.ProrateOnDeactivation = False
    recChrg.ProrationType = PRORATION_TYPE_MONTH_30_DAYS
    
    'arrears vs advance
    recChrg.ChargeInAdvance = True
    
    recChrg.Save
End Sub

Sub MCM_11_DefinePriceableItemInstances()
    Dim prodOff As MTProductOffering
    Set prodOff = ProdCat.GetProductOfferingByName("HyperPlan")
    Dim prcItemInstance As Object 'PriceableItem
    Set prcItemInstance = prodOff.GetPriceableItemByName("Audio Conferencing")
    
    ' modify core properties
    prcItemInstance.Name = "SuperConferencing"
    prcItemInstance.Properties.Item("Name").Value = "SuperConferencing" ' same as previous line
    prcItemInstance.Description = "conferencing"
    
    ' modify extended properties
    prcItemInstance.Properties.Item("Discountable").Value = True
    prcItemInstance.Properties.Item("GLCODE").Value = "GL-2000"
    prcItemInstance.Save
    
    ' navigate to child "Unused Ports"
    Set prcItemInstance = prcItemInstance.GetChildByName("Unused Ports")
    
    'choose a new pricelist
    Dim paramTableDef As MTParamTableDefinition
    Set paramTableDef = ProdCat.GetParamTableDefinitionByName("Rates")
    
    Dim prcList As MTPriceList
    Set prcList = ProdCat.GetPriceListByName("Fortune 1000 list")
    prcItemInstance.SetPriceListMapping paramTableDef.ID, prcList.ID

End Sub

Sub MCM_12_MakeBulkSubscriptionUpdates()
' TODO
End Sub

Sub MCM_17_MultiplePriceableItemExample()
'TODO
End Sub

Sub MCM_18_TestRateSchedulesExample()
    Dim objPi As MTUsageCharge
    Dim objPo As MTProductOffering
    Dim objPt As MTParamTableDefinition
    
    Dim objTest As MTRecurringCharge
    
    Dim rs As IMTSQLRowset
    'Set objPi = ProdCat.GetPriceableItem(1016)
    'Set objPt = objPi.GetParamTableDefinition(1004)
    ' objPt.Name = "Fabricio's Pt"
    ' Set rs = objPt.GetRateSchedulesAsRowset(1018)
    Set objPo = ProdCat.GetProductOffering(1022)
    Set objPi = objPo.GetPriceableItem(1030)
    objPi.Name = "Hello World"
    ' Set objTest = ProdCat.GetPriceableItem(1030)
    
    'Set rs = ProdCat.FindPriceListsAsRowset()
    
End Sub

Sub MPM_1_DefineBatchSummaryItem()
'TODO does this affect the catalog?
End Sub

Sub MPM_2_DefineRealTimeSummaryItem()
'TODO does this affect the catalog?
End Sub

Sub MPM_3_DefineDiscount()
'TODO
End Sub

Sub MPM_7_CreateRealTimeRatedPriceableItem()
    
    Dim prcItem As Object 'MTPriceableItem
    Set prcItem = ProdCat.CreateUsageCharge

    prcItem.Name = "AudioConf"
    prcItem.Description = "Audio Conferencing"
    prcItem.ServiceDefinition = "audioconf"
    prcItem.Save
    
    'add child: Transport
    Dim prcItemChild As Object 'MTPriceableItem
    Set prcItemChild = prcItem.CreateUsageChargeChild
    prcItemChild.Name = "Transport"
    prcItemChild.Description = "Charge for transport time"
    prcItemChild.Save
    Dim paramTbl As MTParamTableDefinition
    Set paramTbl = ProdCat.GetParamTableDefinitionByName("Rates")
    prcItemChild.AddParamTableDefinition paramTbl.ID
    
    ' add child: Unused Ports
    Set prcItemChild = prcItem.CreateUsageChargeChild
    prcItemChild.Name = "Unused Ports"
    prcItemChild.Description = "Charge for unused ports"
    prcItemChild.Save
    prcItemChild.AddParamTableDefinition paramTbl.ID
    
End Sub

Sub MPM_8_CreateBatchRatedPriceableItem()
'TODO How is this different from MPM_7_CreateRealTimeRatedPriceableItem?
End Sub

Sub MPM_9_ConfigureExtendedProperties()
'TODO where is meta data stored?
End Sub

Sub MPM_10_DefineParameterTable()
'TODO where is meta data stored?
End Sub

Sub MAM_1_SubscribeToProductOffering()
    
    ' find an account
    Dim acct As MTAccountReference
    Dim acctID As Long
    acctID = 1000
    Set acct = ProdCat.GetAccountReference(acctID)
    
    ' select a ProductOffering from subscribable ProductOfferings
    Dim prodOffs As Collection
    Set prodOffs = acct.GetSubscribableProductOfferings
    Dim prodOff As MTProductOffering
    Set prodOff = prodOffs.Item(1) 'user would pick one
    
    'subscribe to it
    Dim subscr As MTSubscription
    Dim effDate As New MTTimeSpan
    effDate.StartDate = "4/1/2001"
    Set subscr = acct.Subscribe(prodOff.ID, effDate)
    
End Sub

Sub MAM_2_UnsubscribeFromProductOffering()
    ' find an account
    Dim acct As MTAccountReference
    Dim acctID As Long
    acctID = 1000
    Set acct = ProdCat.GetAccountReference(acctID)
    
    ' select an active subscription
    Dim subs As Collection
    Set subs = acct.GetActiveSubscriptions
    Dim subscr As MTSubscription
    Set subscr = subs.Item(1) 'user would pick one

    ' unsubscribe
    acct.Unsubscribe subscr.ID
    
End Sub

Sub MAM_3_ViewSystemRates()
'TODO
End Sub

Sub MAM_4_ViewCustomerRates()
'TODO
End Sub

Sub MAM_5_SetICBDiscountParameters()
'TODO
End Sub

Sub MAM_6_SetICBRatingParameters()
    
    MAM_1_SubscribeToProductOffering 'make sure we have a subscription
    
    ' find an account
    Dim acct As MTAccountReference
    Dim acctID As Long
    acctID = 1000
    Set acct = ProdCat.GetAccountReference(acctID)
    
    ' select an active subscription
    Dim subs As Collection
    Set subs = acct.GetActiveSubscriptions
    Dim subscr As MTSubscription
    Set subscr = subs.Item(1) 'user would pick one


    ' get ICB pricelist, create if necessary
    Dim ICBPrcList As MTPriceList
    Set ICBPrcList = acct.GetICBPriceList
   
    ' get a pricable item and paramtable
    Dim prcItemInstance As Object 'PriceableItem
    Set prcItemInstance = subscr.GetProductOffering().GetPriceableItemByName("Audio Conferencing")
    Dim paramTableDef As MTParamTableDefinition
    Set paramTableDef = ProdCat.GetParamTableDefinitionByName("Rates")
    
    'set pricelist mapping
    subscr.SetICBPriceListMapping prcItemInstance.ID, paramTableDef.ID, ICBPrcList.ID
    
    'TODO edit rates
   
End Sub

'=== various tests =================================================

'create a new version of a product offering
Public Sub TestCreateNewProductOfferingVersion()
    'get existing product offering
    Dim po As MTProductOffering
    Set po = ProdCat.GetProductOfferingByName("Fortune 500 Plan")
    
    'make a new version
    Dim newPo As MTProductOffering
    Set newPo = po.CreateNewVersion
    
    'modify new version
    newPo.EffectiveDate.StartDate = #4/1/2001#
    newPo.Save
    newPo.AddPriceableItem ProdCat.GetPriceableItemByName("Monthly Service Charge").ID
End Sub

'excercise all methods that return rowsets
Public Sub TestRowset()
    Const SORT_ASCENDING = 1
    Const SORT_DESCENDING = 2
    Dim rowset As IMTSQLRowset
    Dim Count As Integer
    Dim i As Integer
    Dim Name As String
    Dim Value As Variant
    
    ' all pricable items
    Debug.Print "===all pricable items=============================="
    Set rowset = ProdCat.FindPriceableItemsAsRowset
    rowset.Sort "n_name", SORT_ASCENDING

    While Not rowset.EOF
        Count = rowset.Count
        For i = 0 To Count - 1
            Name = rowset.Name(i)
            Value = rowset.Value(i)
            Debug.Print Name & " = " & Value
        Next
        Debug.Print "---------------------------------------"
        rowset.MoveNext
    Wend

    ' all product offerings
    Debug.Print "===all product offerings=============================="
    Set rowset = ProdCat.FindProductOfferingsAsRowset
    rowset.Sort "n_name", SORT_ASCENDING

    While Not rowset.EOF
        Count = rowset.Count
        For i = 0 To Count - 1
            Name = rowset.Name(i)
            Value = rowset.Value(i)
            Debug.Print Name & " = " & Value
        Next
        Debug.Print "---------------------------------------"
        rowset.MoveNext
    Wend
    
    ' all pricelists
    Debug.Print "===all pricelists=============================="
    Set rowset = ProdCat.FindPriceListsAsRowset
    rowset.Sort "n_name", SORT_ASCENDING

    While Not rowset.EOF
        Count = rowset.Count
        For i = 0 To Count - 1
            Name = rowset.Name(i)
            Value = rowset.Value(i)
            Debug.Print Name & " = " & Value
        Next
        Debug.Print "---------------------------------------"
        rowset.MoveNext
    Wend
    
    ' priceable items of a product offering
    Debug.Print "===priceable items of a product offering=============================="
    
    Dim po As MTProductOffering
    Set po = ProdCat.GetProductOfferingByName("Fortune 500 Plan")
    
    Set rowset = po.GetPriceableItemsAsRowset
    rowset.Sort "n_name", SORT_ASCENDING

    While Not rowset.EOF
        Count = rowset.Count
        For i = 0 To Count - 1
            Name = rowset.Name(i)
            Value = rowset.Value(i)
            Debug.Print Name & " = " & Value
        Next
        Debug.Print "---------------------------------------"
        rowset.MoveNext
    Wend

    ' subscribable product offerings
    Debug.Print "===subscribable product offerings=============================="
    
    Dim acct As MTAccountReference
    Set acct = ProdCat.GetAccountReference(1000)
    
    Set rowset = acct.FindSubscribableProductOfferingsAsRowset
    rowset.Sort "n_name", SORT_ASCENDING

    While Not rowset.EOF
        Count = rowset.Count
        For i = 0 To Count - 1
            Name = rowset.Name(i)
            Value = rowset.Value(i)
            Debug.Print Name & " = " & Value
        Next
        Debug.Print "---------------------------------------"
        rowset.MoveNext
    Wend
End Sub

'excercise MTFilter
Public Sub TestFilter()
    Const SORT_ASCENDING = 1
    Const SORT_DESCENDING = 2
    Dim rowset As IMTSQLRowset
    Dim Count As Integer
    Dim i As Integer
    Dim Name As String
    Dim Value As Variant
    
    ' all discounts starting with "A"
    Debug.Print "===all discounts=============================="
    
    Dim filter As New MTFilter
    
    filter.Add "Kind", OPERATOR_TYPE_EQUAL, PI_TYPE_DISCOUNT
    filter.Add "Name", OPERATOR_TYPE_LIKE_W, "A"
    
    Set rowset = ProdCat.FindPriceableItemsAsRowset(filter)
    rowset.Sort "n_name", SORT_ASCENDING

    While Not rowset.EOF
        Count = rowset.Count
        For i = 0 To Count - 1
            Name = rowset.Name(i)
            Value = rowset.Value(i)
            Debug.Print Name & " = " & Value
        Next
        Debug.Print "---------------------------------------"
        rowset.MoveNext
    Wend

    Debug.Print "===all discounts using two filters=============================="
    
    Dim baseFilter As New MTFilter
    Dim userFilter As New MTFilter
    
    baseFilter.Add "Kind", OPERATOR_TYPE_EQUAL, PI_TYPE_DISCOUNT
    
    userFilter.Add "Name", OPERATOR_TYPE_LIKE_W, "A"
    userFilter.Add "GLCODE", OPERATOR_TYPE_LIKE, "GL*-7"
    
    Set rowset = ProdCat.FindPriceableItemsAsRowset(baseFilter.CreateMergedFilter(userFilter))
    rowset.Sort "n_name", SORT_ASCENDING
    While Not rowset.EOF
        Count = rowset.Count
        For i = 0 To Count - 1
            Name = rowset.Name(i)
            Value = rowset.Value(i)
            Debug.Print Name & " = " & Value
        Next
        Debug.Print "---------------------------------------"
        rowset.MoveNext
    Wend


End Sub



