VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ParameterTableData"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'----------------------------------------------------------------------------
' Copyright 1998-2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
' This class module contains information about parameter table data
'----------------------------------------------------------------------------
Option Explicit


'----------------------------------------------------------------------------
' Global Varirables
'----------------------------------------------------------------------------
Private mstrName                'Name of the parameter table
Private mstrWeightOnKey         'The weight on key
Private mstrStartAt             'The start at value
Private mstrInSession           'In session value
Private mbHasIndexedProperty    'Indicates that this has an indexed property

Private mstrExtension           'Extension the parameter table belongs to

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Name
Public Property Get Name() As Variant
  Let Name = mstrName
End Property

Public Property Let Name(ByVal vNewValue As Variant)
  Let mstrName = vNewValue
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Weight on Key
Public Property Get WeightOnKey() As Variant
  Let WeightOnKey = mstrWeightOnKey
End Property

Public Property Let WeightOnKey(ByVal vNewValue As Variant)
  Let mstrWeightOnKey = vNewValue
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Start At
Public Property Get StartAt() As Variant
  Let StartAt = mstrStartAt
End Property

Public Property Let StartAt(ByVal vNewValue As Variant)
  Let mstrStartAt = vNewValue
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' In Session
Public Property Get InSession() As Variant
  Let InSession = mstrInSession
End Property

Public Property Let InSession(ByVal vNewValue As Variant)
  Let mstrInSession = vNewValue
End Property


Public Property Get HasIndexedProperty() As Boolean
  Let HasIndexedProperty = mbHasIndexedProperty
End Property

Public Property Let HasIndexedProperty(ByVal bNewValue As Boolean)
  Let mbHasIndexedProperty = bNewValue
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'
Public Property Let Extension(ByVal strExtension As String)
  Let mstrExtension = strExtension
End Property

Public Property Get Extension() As String
  Let Extension = mstrExtension
End Property
