VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTActionMetaData"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'// ----------------------------------------------------------------
'// Object:      MTActionMetaData
'// Description: describes an action column in a RuleSet
'// ----------------------------------------------------------------

Option Explicit

'// ----------------------------------------------------------------
'// Property:    Kind
'// Description: metered or synthetic
Public Kind As Integer

'// ----------------------------------------------------------------
'// Property:    PropertyName
'// Description: property of PriceableItem
Public PropertyName As String

'// ----------------------------------------------------------------
'// Property:    DataType
'// Description: data type for the column values
'//              should describe enums as well
Public DataType As String

'// ----------------------------------------------------------------
'// Property:    DefaultValue
'// Description: default value to use for the column value
Public DefaultValue As Variant


