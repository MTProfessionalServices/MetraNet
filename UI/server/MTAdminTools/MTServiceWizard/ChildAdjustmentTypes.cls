VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ChildAdjTypeHelper"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'----------------------------------------------------------------------------
' Contains the information necessary for an adjustment type.
'----------------------------------------------------------------------------
Private mstrPIName As String
Private mstrAdjustmentTypeName As String



Public Property Get PIName() As Variant
    PIName = mstrPIName
End Property

Public Property Let PIName(ByVal strVal As Variant)
    mstrPIName = strVal
End Property

Public Property Get AdjustmentTypeName() As Variant
    AdjustmentTypeName = mstrAdjustmentTypeName
End Property

Public Property Let AdjustmentTypeName(ByVal strVal As Variant)
    mstrAdjustmentTypeName = strVal
End Property
