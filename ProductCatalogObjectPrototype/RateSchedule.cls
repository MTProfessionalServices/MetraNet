VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTRateSchedule"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Member0" ,"ParameterTable"
Attribute VB_Ext_KEY = "Member1" ,"PriceableItem"
Attribute VB_Ext_KEY = "Member2" ,"PriceList"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTRateSchedule
'// Description: Collection of Rules for a PriceableItem that
'//              belong to a single PriceList. RateSchedules have effective
'//              dates.
'// ----------------------------------------------------------------
Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Property:    ID
'// Description: unique ID
Public ID As Long

'// ----------------------------------------------------------------
'// Property:    Description
'// Description: description of rate schedule
Public Name As String

'// ----------------------------------------------------------------
'// Property:    EffectiveDate
'// Description: time span during which these rates are effective
Public EffectiveDate As New MTTimeSpan

Public PriceListID As Long

Public ParamTableDefID As Long

'=== internal properties ====================================================

'=== public methods =========================================================
'// ----------------------------------------------------------------
'// Property:    PriceList
'// Description: pricelist the schedule belongs to
Public Function GetPriceList() As MTPriceList
    ' Implement
End Function

Public Function SetPriceList(ByVal prcLstID As Long)
'    mPriceListID = prcLstID
End Function

'// ----------------------------------------------------------------
'// Property:    RuleSet
'// Description: the actual Rules to be used for this rate schedule
Public Function GetRuleSet() As MTRuleSet
    'TODO
    Set GetRuleSet = New MTRuleSet
End Function

'// ----------------------------------------------------------------
'// Method:      GetPriceableItems
'// Description: returns all priceable items that use this rate schedule
'// Returns:     Collection of PriceableItems
Public Function GetPriceableItems() As Collection
    'TODO
End Function

'// ----------------------------------------------------------------
'// Method:      IsEffective
'// Description: returns true if this rateschedule is effective at a certain
'//              time
'// Arguments:   time - Date
'// Returns:     True/False
Public Function IsEffective(ByVal time As Date) As Boolean
    If EffectiveDate.StartDate <= time And EffectiveDate.EndDate >= time Then
        IsEffective = True
    Else
        IsEffective = False
    End If
End Function

'=== internal methods =======================================================
Private Sub Class_Initialize()
    EffectiveDate.StartDate = #1/1/1990#
    EffectiveDate.EndDate = #1/1/2200#
End Sub
