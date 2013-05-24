VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PITypes"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True

Option Explicit

        
Public Sub Dump(ByVal propset As IMTConfigPropSet, aFilter As Variant)
    Dim pc As New MTProductCatalog

    Dim coll As IMTCollection
    Set coll = pc.GetPriceableItemTypes(aFilter)

    Dim pitype As MTPriceableItemType
    For Each pitype In coll
        Dim piset As IMTConfigPropSet
        Set piset = DumpObj("priceableitem_type", propset, pitype)

        '------------------------------
        ' associated objects
        '------------------------------

        ' param tables
        Dim paramTable As MTParamTableDefinition
        Dim ptset As IMTConfigPropSet
        Set ptset = piset.InsertSet("paramtables")
        For Each paramTable In pitype.GetParamTableDefinitions
            InsertObjectReference ptset, "paramtable", paramTable.name, paramTable.id
        Next

    Next

End Sub


