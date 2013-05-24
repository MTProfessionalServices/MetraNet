VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Charge"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'----------------------------------------------------------------------------
' Copyright 1998-2002 by MetraTech Corporation
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
' Contains the information necessary for a charge.
'----------------------------------------------------------------------------

Private mstrName As String                           'Name of the charge
Private mstrDisplayName As String                    'Display name of the charge
Private lngID As Long                                'ID of the charge
Private mcollChargeProperties As New Collection      'Charge properties


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Name
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Name() As String
  Let Name = mstrName
End Property

Public Property Let Name(ByVal strVal As String)
  Let mstrName = strVal
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Description
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get DisplayName() As String
  Let DisplayName = mstrDisplayName
End Property

Public Property Let DisplayName(ByVal strVal As String)
  Let mstrDisplayName = strVal
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ID
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get ID() As Long
  Let ID = lngID
End Property

Public Property Let ID(ByVal lngVal As Long)
  Let lngID = strVal
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ChargeProperties
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get ChargeProperties() As Collection
  Set ChargeProperties = mcollChargeProperties
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'GetChargeProperty
Public Function GetChargeProperty(ByVal strName As String) As ChargeProperty
  Dim i As Integer      'ChargeProperty
  
  For i = 1 To mcollChargeProperties.Count
    If UCase(mcollChargeProperties.Item(i).Name) = UCase(strName) Then
      Set GetCharge = mcollChargeProperties.Item(i)
      Exit Function
    End If
  Next

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'RemoveChargeProperty
Public Function RemoveChargeProperty(ByVal strName As String)
  Dim i As Integer      'ChargeProperty
  
  For i = 1 To mcollChargeProperties.Count
    If UCase(mcollChargeProperties.Item(i).Name) = UCase(strName) Then
      Call mcollChargeProperties.Remove(i)
      Exit For
    End If
  Next

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'AddChargeProperty
Public Function AddChargeProperty(ByVal strName As String)
  Dim objChargeProperty As New ChargeProperty
  
  'First, remove, then add
  Call RemoveChargeProperty(strName)
  
  'Now add
  objChargeProperty.Name = strName
  
  Call mcollChargeProperties.Add(objChargeProperty)
  
End Function


