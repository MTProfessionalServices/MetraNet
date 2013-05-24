VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Condition"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' //==========================================================================
' // Copyright 1998-2001 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //==========================================================================
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'DisplayCondition.cls -- Contains information about attributeitems and      '
' properties to support the conditional display of these properties.        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Private mstrData As String            'Data to check
Private mstrDataType As String        'Type of data to check

Private mstrCompare As String         'Comparison to perform

Private mstrValue As String           'Value to check for
Private mstrValueType As String       'Type of the value

Private mstrOptionType As String      'Type of option

Private mstrLink As String            'Used to link various conditions with
                                      'other properties
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Data() As String
  Let Data = mstrData
End Property

Public Property Let Data(ByVal Val As String)
  Let mstrData = Val
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get DataType() As String
  Let DataType = mstrDataType
End Property

Public Property Let DataType(ByVal Val As String)
  Let mstrDataType = Val
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Compare() As String
  Let Compare = mstrCompare
End Property

Public Property Let Compare(ByVal Val As String)
  Let mstrCompare = Val
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Value() As String
  Let Value = mstrValue
End Property

Public Property Let Value(ByVal Val As String)
  Let mstrValue = Val
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get ValueType() As String
  Let ValueType = mstrValueType
End Property

Public Property Let ValueType(ByVal Val As String)
  Let mstrValueType = Val
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get OptionType() As String
  Let OptionType = mstrOptionType
End Property

Public Property Let OptionType(ByVal Val As String)
  Let mstrOptionType = Val
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Link() As String
  Let Link = mstrLink
End Property

Public Property Let Link(ByVal Val As String)
  Let mstrLink = Val
End Property

