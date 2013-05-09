VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTCounterType"
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
'// Property:    ID
'// Description: unique ID of this product offering
Public ID As Long

'// ----------------------------------------------------------------
'// Property:    Name
'// Description: name as shown to the user
Public Name As String

'// ----------------------------------------------------------------
'// Property:    Description
Public Description As String
    
    
'// ----------------------------------------------------------------
'// Property:    FormulaTemplate
Public FormulaTemplate As String

Private mParameters As New Collection

Private mCounters As New Collection



'// ----------------------------------------------------------------
'// Method:      GetParameters
'// Description: Get all parameters
'//              associated with this type
'// Returns:     Collection of Parameters

Public Function GetParameters() As Collection
    Set GetParameters = mParameters
End Function

'// ----------------------------------------------------------------
'// Method:      CreateCounter
'// Description: create new counter object from this type
'// Returns:     IMTCounter
Public Function CreateCounter() As MTCounter
    '
    Dim c As New MTCounter
    mCounters.Add c
    Set CreateCounter = c
End Function

'// ----------------------------------------------------------------
'// Method:      RemoveCounter
'// Description: remove counter object by db id
'// Returns:

Public Function RemoveCounter(ByVal aCounterID As Long)
    '
    
End Function

'// ----------------------------------------------------------------
'// Method:      GetCounter
'// Description: get a counter object by db id
'// Returns:     IMTCounter or NULL if not found

Public Function GetCounter(ByVal aCounterID As Long) As MTCounter
    '
    
End Function

'// ----------------------------------------------------------------
'// Method:      GetParameters
'// Description: get all Counter instances of this type
'// Returns:     Collection of IMTCounter objects

Public Function GetCounters() As Collection
    Set GetCounters = mCounters
End Function

Public Function AddParam_(ByVal p As MTCounterParameter)
    mParameters.Add p
End Function






