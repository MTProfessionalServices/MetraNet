VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CPD"
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
' MTConfigHelper.CPD                                                        '
'                                                                           '
' Description:  Container for CPD properties.                               '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mstrName As String
Private mstrDisplayName As String
Private mstrServiceProperty As String
Private mstrPreferredCounterType As String


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Name
Public Property Get Name() As Variant
  Let Name = mstrName
End Property

Public Property Let Name(ByVal vNewValue As Variant)
  Let mstrName = vNewValue
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Display Name
Public Property Get DisplayName() As Variant
  Let DisplayName = mstrDisplayName
End Property

Public Property Let DisplayName(ByVal vNewValue As Variant)
  Let mstrDisplayName = vNewValue
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ServiceProperty
Public Property Get ServiceProperty() As Variant
  Let ServiceProperty = mstrServiceProperty
End Property

Public Property Let ServiceProperty(ByVal vNewValue As Variant)
  Let mstrServiceProperty = vNewValue
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' CounterType
Public Property Get PreferredCounterType() As Variant
  Let PreferredCounterType = mstrPreferredCounterType
End Property

Public Property Let PreferredCounterType(ByVal vNewValue As Variant)
  Let mstrPreferredCounterType = vNewValue
End Property
