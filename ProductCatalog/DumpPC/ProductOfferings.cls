VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ProductOfferings"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True



Public Sub Dump(ByVal propset As IMTConfigPropSet, Optional ByVal aFilter As Variant)
    Dim pc As New MTProductCatalog

    Dim rowset As IMTRowSet
    ' object ID that comes in the rowset
    Dim id As Long

    Set rowset = pc.FindProductOfferingsAsRowset(aFilter)
    While Not rowset.EOF
        id = rowset.value("id_prop")

        Dim po As MTProductOffering
        Set po = pc.GetProductOffering(id)

        Dim subset As IMTConfigPropSet
        Set subset = DumpObj("productoffering", propset, po)

        Dim pirowset As IMTRowSet
        Set pirowset = po.GetPriceableItemsAsRowset
        DumpPriceableItems subset, pirowset, True

        Set pirowset = po.GetPriceableItemsAsRowset
        DumpPriceListMappings subset, pirowset

        rowset.MoveNext
    Wend

End Sub

