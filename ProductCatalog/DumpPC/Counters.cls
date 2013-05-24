VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Counters"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Sub DumpTypes(ByVal propset As IMTConfigPropSet, Optional ByVal aFilter As Variant)
    Dim pc As New MTProductCatalog

    Dim rowset As IMTRowSet
    ' object ID that comes in the rowset
    Dim id As Long

    ' TODO: filter ignored
    Dim counterType As IMTCounterType
    For Each counterType In pc.GetCounterTypes

        Dim subset As IMTConfigPropSet
        Set subset = DumpObj("counter_type", propset, counterType)


    Next

End Sub


Public Sub DumpCounters(ByVal propset As IMTConfigPropSet, Optional ByVal aFilter As Variant)
    Dim pc As New MTProductCatalog

    Dim rowset As IMTRowSet
    ' object ID that comes in the rowset
    Dim id As Long

    Set rowset = pc.FindCountersAsRowset(aFilter)
    While Not rowset.EOF
        id = rowset.value("id_prop")

        Dim counter As IMTCounter
        Set counter = pc.GetCounter(id)

        Dim subset As IMTConfigPropSet
        Set subset = DumpObj("counter", propset, counter)

        Dim param As IMTCounterParameter
        For Each param In counter.Parameters
            Dim paramset As IMTConfigPropSet
            Set paramset = DumpObj("parameter", subset, param)
        Next

        rowset.MoveNext
    Wend

End Sub


