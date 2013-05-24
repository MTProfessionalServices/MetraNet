Attribute VB_Name = "Common"
Option Explicit

Function DumpObj(ByVal name As String, ByVal propset As IMTConfigPropSet, ByVal object As Object) As IMTConfigPropSet
        Dim subset As IMTConfigPropSet
        Set subset = propset.InsertSet(name)

        Dim property As MTProperty
        For Each property In object.Properties
            If property.DataTypeAsString = "object" And property.Value <> Empty Then
                DumpObj property.name, subset, property.Value
            ElseIf property.DataTypeAsString = "boolean" Then
                Dim boolstr
                If property.Value Then
                    boolstr = "TRUE"
                Else
                    boolstr = "FALSE"
                End If
                subset.InsertProp property.name, PROP_TYPE_STRING, boolstr
            Else
                subset.InsertProp property.name, PROP_TYPE_STRING, property.Value
            End If
        Next
        
        Set DumpObj = subset
End Function


Sub InsertObjectReference(ByVal propset As IMTConfigPropSet, tagname As String, name As String, id As Long)

' TODO: insert the ID as an attribute!
'            Dim prop As IMTConfigProp
'            Set prop = CreateObject("Metratech.MTConfigProp.1")
'            prop.name = "paramtable"
'            prop.AddProp PROP_TYPE_STRING, paramTable.name
'            ptset.InsertConfigProp prop

            propset.InsertProp tagname, PROP_TYPE_STRING, name

End Sub


Private Sub DumpUsageCharge(ByVal propset As IMTConfigPropSet, ByVal charge As MTUsageCharge)
    ' dump the object itself
    Dim usageset As IMTConfigPropSet
    Set usageset = DumpObj("usagecharge_template", propset, charge)

    ' dump objects associated to the usage charge

End Sub

Private Sub DumpAggregateCharge(ByVal propset As IMTConfigPropSet, ByVal charge As MTAggregateCharge)
    ' dump the object itself
    Dim subset As IMTConfigPropSet
    Set subset = DumpObj("aggregatecharge_template", propset, charge)

    ' dump objects associated to the aggregate charge

End Sub


Private Sub DumpDiscount(ByVal propset As IMTConfigPropSet, ByVal discount As MTDiscount)
    ' dump the object itself
    Dim subset As IMTConfigPropSet
    Set subset = DumpObj("discount_template", propset, discount)

    ' dump objects associated to the discount
    'Dim cycle As MTPCCycle
    'Set cycle = discount.cycle
    'Dim cycleset As IMTConfigPropSet
    'Set cycleset = DumpObj("cycle", subset, cycle)
End Sub

Private Sub DumpNonRecurringCharge(ByVal propset As IMTConfigPropSet, ByVal nonrc As MTNonRecurringCharge)
    ' dump the object itself
    Dim subset As IMTConfigPropSet
    Set subset = DumpObj("nonrecurringcharge_template", propset, nonrc)

    ' dump objects associated to the nonrecurring charge

End Sub

Private Sub DumpRecurringCharge(ByVal propset As IMTConfigPropSet, ByVal rc As MTRecurringCharge)
    ' dump the object itself
    Dim subset As IMTConfigPropSet
    Set subset = DumpObj("recurringcharge_template", propset, rc)

    ' dump objects associated to the recurring charge

End Sub


Public Sub DumpPriceableItems(ByVal propset As IMTConfigPropSet, rowset As IMTRowSet, showMappings As Boolean)
    Dim pc As New MTProductCatalog

    ' object ID that comes in the rowset
    Dim id As Long
    Dim kind As MTPCEntityType

    While Not rowset.EOF
        id = rowset.Value("id_prop")
        kind = rowset.Value("n_kind")

        Dim tagname As String
        Select Case kind
            Case PCENTITY_TYPE_USAGE
                tagname = "usagecharge"
            Case PCENTITY_TYPE_AGGREGATE_CHARGE
                tagname = "aggregatecharge"
            Case PCENTITY_TYPE_RECURRING
                tagname = "recurringcharge"
            Case PCENTITY_TYPE_NON_RECURRING
                tagname = "nonrecurringcharge"
            Case PCENTITY_TYPE_DISCOUNT
                tagname = "discount"
        End Select

        Dim pi As MTPriceableItem
        Set pi = pc.GetPriceableItem(id)

        Dim subset As IMTConfigPropSet
        Set subset = DumpObj(tagname, propset, pi)

'        Select Case kind
'            Case PCENTITY_TYPE_USAGE
'                ' dump the usage charge
'                Dim usage As MTUsageCharge
'                Set usage = pc.GetPriceableItem(id)
'                DumpUsageCharge propset, usage
'            Case PCENTITY_TYPE_AGGREGATE_CHARGE
'                ' dump the aggregate charge
'                Dim agg As MTAggregateCharge
'                Set agg = pc.GetPriceableItem(id)
'                DumpAggregateCharge propset, agg
'            Case PCENTITY_TYPE_RECURRING
'                ' dump the recurring charge
'                Dim recur As MTRecurringCharge
'                Set recur = pc.GetPriceableItem(id)
'                DumpRecurringCharge propset, recur
'            Case PCENTITY_TYPE_NON_RECURRING
'                ' dump the non recurring charge
'                Dim nonrecur As MTNonRecurringCharge
'                Set nonrecur = pc.GetPriceableItem(id)
'                DumpNonRecurringCharge propset, nonrecur
'            Case PCENTITY_TYPE_DISCOUNT
'                ' dump the discount
'                Dim discount As MTDiscount
'                Set discount = pc.GetPriceableItem(id)
'                DumpDiscount propset, discount
'        End Select


        If showMappings Then
            Dim mappingsSet As IMTConfigPropSet
            Set mappingsSet = propset.InsertSet("pricelistmappings")

            Dim mappingsRowset As IMTRowSet
            Set mappingsRowset = pi.GetPriceListMappingsAsRowset
            While Not mappingsRowset.EOF

                Dim mappingSet As IMTConfigPropSet
                Set mappingSet = mappingsSet.InsertSet("mapping")
                InsertObjectReference mappingSet, "paramtable", mappingsRowset.Value("tpt_nm_name"), mappingsRowset.Value("id_paramtable")
                
                ' do extra checking for null cases
                If IsNull(mappingsRowset.Value("tpl_nm_name")) Then
                  If IsNull(mappingsRowset.Value("id_pricelist")) Then
                    InsertObjectReference mappingSet, "pricelist", "unknown", -1
                  Else
                    InsertObjectReference mappingSet, "pricelist", "unknown", mappingsRowset.Value("id_pricelist")
                  End If
                Else
                  InsertObjectReference mappingSet, "pricelist", mappingsRowset.Value("tpl_nm_name"), mappingsRowset.Value("id_pricelist")
                End If

                
                mappingSet.InsertProp "canicb", PROP_TYPE_STRING, mappingsRowset.Value("b_canICB")


                mappingsRowset.MoveNext
            Wend
        End If



        rowset.MoveNext
    Wend


End Sub



Public Sub DumpPriceListMappings(ByVal propset As IMTConfigPropSet, rowset As IMTRowSet)
    Dim pc As New MTProductCatalog

    ' object ID that comes in the rowset
    Dim id As Long
    Dim kind As MTPCEntityType

    Dim mappingsSet As IMTConfigPropSet
    Set mappingsSet = propset.InsertSet("pricelistmappings")

    While Not rowset.EOF
        id = rowset.Value("id_prop")
        kind = rowset.Value("n_kind")
        
        Dim pi As MTPriceableItem
        Set pi = pc.GetPriceableItem(id)

        Dim mappingsRowset As IMTRowSet
        Set mappingsRowset = pi.GetPriceListMappingsAsRowset
        While Not mappingsRowset.EOF

            Dim mappingSet As IMTConfigPropSet
            Set mappingSet = mappingsSet.InsertSet("mapping")
            InsertObjectReference mappingSet, "priceableitem", pi.name, pi.id
            InsertObjectReference mappingSet, "paramtable", mappingsRowset.Value("tpt_nm_name"), mappingsRowset.Value("id_paramtable")
                             
            ' do extra checking for null cases
            If IsNull(mappingsRowset.Value("tpl_nm_name")) Then
                 If IsNull(mappingsRowset.Value("id_pricelist")) Then
                    InsertObjectReference mappingSet, "pricelist", "unknown", -1
                 Else
                    InsertObjectReference mappingSet, "pricelist", "unknown", mappingsRowset.Value("id_pricelist")
                 End If
            Else
               InsertObjectReference mappingSet, "pricelist", mappingsRowset.Value("tpl_nm_name"), mappingsRowset.Value("id_pricelist")
            End If
                
            mappingSet.InsertProp "canicb", PROP_TYPE_STRING, mappingsRowset.Value("b_canICB")


            mappingsRowset.MoveNext
        Wend

        rowset.MoveNext
    Wend


End Sub

