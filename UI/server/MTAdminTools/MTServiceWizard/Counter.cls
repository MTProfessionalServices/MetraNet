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
'----------------------------------------------------------------------------
' Copyright 1998-2001 by MetraTech Corporation
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
' Contains the information necessary for a counter definition.
'----------------------------------------------------------------------------

Private mstrName As String                  'Name of the counter
Private mstrDescription As String           'Description of the counter

Private lngID As Long                       'ID of the counter

Private mstrCounterType As String           'Counter Type

Private mcollParameters As New Collection   'Collection of counter parameters

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
Public Property Get Description() As String
  Let Description = mstrDescription
End Property

Public Property Let Description(ByVal strVal As String)
  Let mstrDescription = strVal
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
' CounterType
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get CounterType() As String
  Let CounterType = mstrCounterType
End Property

Public Property Let CounterType(ByVal strVal As String)
  Let mstrCounterType = strVal
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Parameters
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Parameters() As Collection
  Set Parameters = mcollParameters
End Property

Public Function RemoveParameter(ByVal strName As String)
  Dim i As Integer        'Counter
  
  For i = 1 To mcollParameters.Count
    If UCase(mcollParameters.Item(i).Name) = UCase(strName) Then
      Call mcollParameters.Remove(i)
      Exit For
    End If
  Next
End Function

Public Function AddParameter(ByVal strName As String, _
                             ByVal strPV As String, _
                             ByVal strValue As String, _
                             ByVal strKind As String)
  Dim objParameter As New CounterParameter
  
  'Remove the parameter if it exists
  Call RemoveParameter(strName)
  
  'Add the parameter
  objParameter.Name = strName
  objParameter.PV = strPV
  objParameter.Value = strValue
  objParameter.Kind = strKind
  
  Call mcollParameters.Add(objParameter)
End Function
