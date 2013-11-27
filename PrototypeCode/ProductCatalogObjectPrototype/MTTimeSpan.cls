VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTTimeSpan"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTTimeSpan
'// Description: used to specify a time range for effective dates.
'// ----------------------------------------------------------------

'=== public properties ======================================================

Public Properties As New MTProperties

''// ----------------------------------------------------------------
''// Enum:        MTDateType
''// Description: the type of date type
Public Enum MTDateType
    DATE_TYPE_ABSOLUTE = 1                  'Start/EndDate
    DATE_TYPE_NEXT_BILLING_PERIOD = 2       'next billing period after Start/EndDate
    DATE_TYPE_SUBSCRIPTION_RELATIVE = 3     'number of days relative to subscription start end
End Enum


'=== internal properties ====================================================
'=== public methods =========================================================
'=== internal methods =======================================================

Private Sub Class_Initialize()
       
    Properties.AddWithValues "StartDateType", "int32", 0, False, , False
    Properties.AddWithValues "StartDate", "timestamp", 0, False, , False
    Properties.AddWithValues "StartOffset", "int32", 0, False, , False
    Properties.AddWithValues "EndDateType", "int32", 0, False, , False
    Properties.AddWithValues "EndDate", "timestamp", 0, False, , False
    Properties.AddWithValues "EndOffset", "int32", 0, False, , False

End Sub

''// ----------------------------------------------------------------
''// Property:    StartDateType
''// Description: specifies type of start date
Public Property Get StartDateType() As MTDateType
    StartDateType = Me.Properties.Item("StartDateType").Value
End Property

Public Property Let StartDateType(ByVal vNewValue As MTDateType)
    Me.Properties.Item("StartDateType").Value = vNewValue
End Property

'
''// ----------------------------------------------------------------
''// Property:    StartDate
''// Description: date when time span starts
''//              0 means since beginning of time
''//              only valid for DATE_TYPE_ABSOLUTE, DATE_TYPE_NEXT_BILLING_PERIOD
Public Property Get StartDate() As Date
    StartDate = Me.Properties.Item("StartDate").Value
End Property

Public Property Let StartDate(ByVal vNewValue As Date)
    Me.Properties.Item("StartDate").Value = vNewValue
End Property

'
''// ----------------------------------------------------------------
''// Property:    StartOffset
''// Description: number of days relative to subscription start
''//              0 means at subscription, positive value means days after subscription start
''//              only valid for DATE_TYPE_SUBSCRIPTION_RELATIVE
Public Property Get StartOffset() As Long
    StartOffset = Me.Properties.Item("StartOffset").Value
End Property

Public Property Let StartOffset(ByVal vNewValue As Long)
    Me.Properties.Item("StartOffset").Value = vNewValue
End Property


'
''// ----------------------------------------------------------------
''// Property:    EndDateType
''// Description: specifies type of end date
Public Property Get EndDateType() As MTDateType
    EndDateType = Me.Properties.Item("EndDateType").Value
End Property

Public Property Let EndDateType(ByVal vNewValue As MTDateType)
    Me.Properties.Item("EndDateType").Value = vNewValue
End Property

''// ----------------------------------------------------------------
''// Property:    EndDate
''// Description: date when time span ends
''//              0 means forever
''//              only valid for DATE_TYPE_ABSOLUTE, DATE_TYPE_NEXT_BILLING_PERIOD
Public Property Get EndDate() As Date
    EndDate = Me.Properties.Item("EndDate").Value
End Property

Public Property Let EndDate(ByVal vNewValue As Date)
    Me.Properties.Item("EndDate").Value = vNewValue
End Property

'
''// ----------------------------------------------------------------
''// Property:    EndOffset
''// Description: number of days relative to subscription end
''//              0 means at subscription, positive value means days after subscription end
''//              (does negatrive value make sense?)
''//              only valid for DATE_TYPE_SUBSCRIPTION_RELATIVE
Public Property Get EndOffset() As Long
    EndOffset = Me.Properties.Item("EndOffset").Value
End Property

Public Property Let EndOffset(ByVal vNewValue As Long)
    Me.Properties.Item("EndOffset").Value = vNewValue
End Property

