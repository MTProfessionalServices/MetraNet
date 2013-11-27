VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTConditionMetaData"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'// ----------------------------------------------------------------
'// Object:      MTConditionMetaData
'// Description: describes a condition column in a RuleSet
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

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
'// Property:    Operator
'// Description: Operator to use for all rows in this the column
'//              Only used if OperatorPerRule is false
Public Operator As MTOperatorType

'// ----------------------------------------------------------------
'// Property:    OperatorPerRule
'// Description: if true operator is defined at rule-level
'//              if false the columns Operator is used
Public OperatorPerRule As Boolean

'// ----------------------------------------------------------------
'// Property:    DisplayOperator
'// Description: if true display the operator
Public DisplayOperator As Boolean

