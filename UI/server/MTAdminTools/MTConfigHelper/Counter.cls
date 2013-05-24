VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Counter"
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
' MTConfigHelper.Counter                                                    '
'                                                                           '
' Description:  Counter definition for priceable item types.                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mstrName As String
Private mstrType As String

Private mcollParameters As New Collection
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function SetParameter(ByVal vName As Variant, ByVal vValue As Variant)
  Dim objParam As CounterParameter
  
  For Each objParam In mcollParameters
    If UCase(objParam.Name) = UCase(vName) Then
      objParam.value = vValue
      Exit Function
    End If
  Next
  
  'Create the parameter if it didn't exist
  Set objParam = New CounterParameter
  
  objParam.Name = vName
  objParam.value = vValue
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function GetParameter(intIndex As Integer)
  If intIndex > 0 And intIndex <= mcollParameters.Count Then
    Set GetParameter = mcollParameters(intIndex)
  End If
End Function
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
Public Property Get CounterType() As Variant
  Let CounterType = mstrType
End Property

Public Property Let CounterType(ByVal vNewValue As Variant)
  Let mstrType = vNewValue
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Parameters
Public Property Get ParameterCount() As Integer
  Let ParameterCount = mcollParameters.Count
End Property

