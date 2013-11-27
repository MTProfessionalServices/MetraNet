VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTCounterParameter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'// ----------------------------------------------------------------
'//Object: MTProductOffering
'// Description: Subscribable grouping of Priceable items.
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Property:    Name
'// Description: name as shown to the user
Public Name As String

'// ----------------------------------------------------------------
'// Property:    Value
Public Value As Variant
    
'// ----------------------------------------------------------------
'// Property:    Kind:
'// PVProperty, PV or CONST
Public Kind As Variant
    
'// ----------------------------------------------------------------
'// Property:    DBType
'// NUMERIC, STRING
Public DBType As Variant
    


