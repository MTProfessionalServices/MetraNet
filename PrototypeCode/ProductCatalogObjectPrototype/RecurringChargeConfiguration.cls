VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "RecurringConfiguration"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Member0" ,"RecurringChargeCycle"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
' Object: RecurringConfiguration
' Description: Recurring charge specific properties of a priceable item

Option Explicit

' --- public properties ----------------------------------------------------

' if true, charge in advance, otherwise in arrears
Public ChargeInAdvance As Boolean

' if true, prorate when a subscriber subscribes to the product offering
Public ProrateOnActivation As Boolean

' if true, prorate when a subscriber unsubscribes to the product offering
Public ProrateOnDeactivation As Boolean

' type of proration that should be done (None, 30 day, true-month, etc).
Public ProrationType As Integer

' cycle of this recurring charge
Public RecurringChargeCycle As RecurringChargeCycle

' start date and end date of this recurring charge
Public StartDate As ActionDate

Public EndDate As ActionDate

' --- internal properties ----------------------------------------------------

' --- public methods ----------------------------------------------------



' --- internal methods ----------------------------------------------------

