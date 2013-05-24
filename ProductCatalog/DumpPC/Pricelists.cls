VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Pricelists"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Sub Dump(ByVal propset As IMTConfigPropSet, Optional ByVal aFilter As Variant)
    Dim pc As New MTProductCatalog

    Dim rowset As IMTRowSet
    ' object ID that comes in the rowset
    Dim id As Long

    Set rowset = pc.FindPriceListsAsRowset(aFilter)
    While Not rowset.EOF
        id = rowset.value("id_prop")

        Dim pl As MTPriceList
        Set pl = pc.GetPriceList(id)

        Dim subset As IMTConfigPropSet
        Set subset = DumpObj("pricelist", propset, pl)

        rowset.MoveNext
    Wend

End Sub


