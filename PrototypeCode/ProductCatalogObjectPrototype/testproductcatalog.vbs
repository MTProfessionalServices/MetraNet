Sub TestDumpCatalog()
    Set test= CreateObject("MTProdCatProto.Test")
    test.DumpCatalog
End Sub

Sub TestUseCases()
    Set test= CreateObject("MTProdCatProto.Test")
    test.MCM_1_ConfigureExistingDiscount
    test.MCM_2_CreatePriceList
    test.MCM_3_EditPriceListValues
    test.MCM_5_ViewSystemRate
    test.MCM_7_SetComponentValues
    test.MCM_8_CreateProductOffering
    test.MCM_9_EditProductOffering
    test.MCM_10_DefineRecurringCharge
    test.MCM_11_DefinePriceableItemInstances
    test.MCM_12_MakeBulkSubscriptionUpdates
    test.MCM_17_MultiplePriceableItemExample
    
    test.MPM_7_CreateRealTimeRatedPriceableItem
    
    test.MAM_1_SubscribeToProductOffering
    test.MAM_2_UnsubscribeFromProductOffering
    test.MAM_3_ViewSystemRates
    test.MAM_4_ViewCustomerRates
    test.MAM_5_SetICBDiscountParameters
    test.MAM_6_SetICBRatingParameters

    test.TestCreateNewProductOfferingVersion
    
    test.DumpCatalog
End Sub

Sub TestRowset()
    Set test= CreateObject("MTProdCatProto.Test")
    test.TestRowset
    test.TestFilter
End Sub


Sub TestAll()
	TestDumpCatalog
	TestUseCases
	TestRowset
End Sub

TestAll