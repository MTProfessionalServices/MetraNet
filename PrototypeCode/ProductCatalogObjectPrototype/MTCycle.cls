VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTCycle"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTPCCycle
'// Description: a cycle, as used by discount, recurring charge,
'//              counter, aggregate Rate
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================
Public Properties As New MTProperties

'// ----------------------------------------------------------------
'// Property:    CycleID
'// Description: ID in t_usage_cycle
'//              0 for relative cycle
Public Property Get CycleID() As Long
    CycleID = Me.Properties.Item("CycleID").Value
End Property
Public Property Let CycleID(ByVal vNewValue As Long)
    Me.Properties.Item("CycleID").Value = vNewValue
End Property


'// ----------------------------------------------------------------
'// Property:    CycleTypeID
'// Description: DAILY = 3
'//              WEEKLY = 4         'use EndDayOfWeek
'//              BIWEEKLY = 5       'use StartDay, StartMonth, StartYear
'//              SEMIMONTHLY = 6    'use EndDayOfMonth, EndDayOfMonth2
'//              MONTHLY = 1        'use EndDayOfMonth
'//              QUARTERLY = 7      'use StartDay, StartMonth
Public Property Get CycleTypeID() As Long
    CycleTypeID = Me.Properties.Item("CycleTypeID").Value
End Property
Public Property Let CycleTypeID(ByVal vNewValue As Long)
    Me.Properties.Item("CycleTypeID").Value = vNewValue
End Property


''// ----------------------------------------------------------------
'// Property:    Relative
'// Description: if true cycle type is only used
Public Property Get Relative() As Boolean
    Relative = Me.Properties.Item("Relative").Value
End Property
Public Property Let Relative(ByVal vNewValue As Boolean)
    Me.Properties.Item("Relative").Value = vNewValue
End Property

'// ----------------------------------------------------------------
'// Property:    EndDayOfWeek
'// Description: weekly cycle ends on:
'//              SUNDAY = 1
'//              MONDAY = 2
'//              TUESDAY = 3
'//              WEDNESDAY = 4
'//              THURSDAY = 5
'//              FRIDAY = 6
'//              SATURDAY = 7
Public Property Get EndDayOfWeek() As Long
    EndDayOfWeek = Me.Properties.Item("EndDayOfWeek").Value
End Property
Public Property Let EndDayOfWeek(ByVal vNewValue As Long)
    Me.Properties.Item("EndDayOfWeek").Value = vNewValue
End Property

'// ----------------------------------------------------------------
'// Property:    EndDayOfMonth
'// Description: cycle ends on this day of month
'//              for MONTHLY: if > 27 means end of month
Public Property Get EndDayOfMonth() As Long
    EndDayOfMonth = Me.Properties.Item("EndDayOfMonth").Value
End Property
Public Property Let EndDayOfMonth(ByVal vNewValue As Long)
    Me.Properties.Item("EndDayOfMonth").Value = vNewValue
End Property

'// ----------------------------------------------------------------
'// Property:    EndDayOfMonth2
'// Description: cycle ends on this day of month
'//              for SEMIMONTHLY: if > 27 means end of month
Public Property Get EndDayOfMonth2() As Long
    EndDayOfMonth2 = Me.Properties.Item("EndDayOfMonth").Value
End Property
Public Property Let EndDayOfMonth2(ByVal vNewValue As Long)
    Me.Properties.Item("EndDayOfMonth2").Value = vNewValue
End Property

'// ----------------------------------------------------------------
'// Property:    StartDay
'// Description: absolute day of month cycle starts
Public Property Get StartDay() As Long
    StartDay = Me.Properties.Item("StartDay").Value
End Property
Public Property Let StartDay(ByVal vNewValue As Long)
    Me.Properties.Item("StartDay").Value = vNewValue
End Property

'// ----------------------------------------------------------------
'// Property:    StartMonth
'// Description: absolute month, cycle starts
Public Property Get StartMonth() As Long
    StartMonth = Me.Properties.Item("StartMonth").Value
End Property
Public Property Let StartMonth(ByVal vNewValue As Long)
    Me.Properties.Item("StartMonth").Value = vNewValue
End Property

'// ----------------------------------------------------------------
'// Property:    StartYear
'// Description: absolute year, cycle starts
Public Property Get StartYear() As Long
    StartYear = Me.Properties.Item("StartYear").Value
End Property
Public Property Let StartYear(ByVal vNewValue As Long)
    Me.Properties.Item("StartYear").Value = vNewValue
End Property

'// -----------------------------------------------------------------
'// Method:      ComputeCycleIDFromProperties
'// Description: Sets CycleID from properties (CycleTypeID is already set)
'//              If Relative is true, CycleID will be 0
'//              Meant to be called by owning object before saving MTPCCycle to database:
'//              - call ComputeCycleIDFromProperties
'//              - get CycleID and CycleTypeID and save it in DB
Public Sub ComputeCycleIDFromProperties()
End Sub

'// -----------------------------------------------------------------
'// Method:      ComputePropertiesFromCycleID
'// Description: Sets all properties depending on CycleID and CycleTypeID
'//              If CycleID is 0, Relative will be set to true and all properties other than CycleTypeID to 0
'//              If CycleID is != 0, Relative will be set to false and all properties other than CycleTypeID computed
'//              Meant to be called by owning object when loading MTPCCycle from database:
'//              - set CycleID and CycleTypeID
'//              - call ComputePropertiesFromCycleID
Public Sub ComputePropertiesFromCycleID()
End Sub

'// -----------------------------------------------------------------
'// Method:      CreateAbsoluteCycleFromBillingCycle
'// Description: If this is a billing cycle relative MTPCCycle, then call
'//              this function to compute an absolute cycle based on this cycle
'//              and the Account's billing cycle.
'// Returns:     a new absolute MTPCType
Public Function CreateAbsoluteCycleFromBillingCycle(AccoountID As Long) As MTCycle
End Function


Private Sub Class_Initialize()

    Properties.AddWithValues "CycleID", "int32", 0, False, , False
    Properties.AddWithValues "CycleTypeID", "int32", 0, True, , False
    Properties.AddWithValues "Relative", "boolean", 0, False, , False
    Properties.AddWithValues "EndDayOfWeek", "int32", 0, False, , False
    Properties.AddWithValues "EndDayOfMonth", "int32", 0, False, , False
    Properties.AddWithValues "EndDayOfMonth2", "int32", 0, False, , False
    Properties.AddWithValues "StartDay", "int32", 0, False, , False
    Properties.AddWithValues "StartMonth", "int32", 0, False, , False
    Properties.AddWithValues "StartYear", "int32", 0, False, , False
End Sub


