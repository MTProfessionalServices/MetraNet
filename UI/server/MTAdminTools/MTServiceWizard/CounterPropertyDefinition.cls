VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CPDef"
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
' Contains the information necessary for a counter property definition.
'----------------------------------------------------------------------------


Private mstrName As String                'Name of the CPD
Private mstrDisplayName As String         'Display name of the CPD
Private mstrPreferredCounterTypeName As String  '
Private mstrSDProperty As String          'Service definition property this
                                          'counter is linked to
                                          
Private mstrCounter As String             'counter this is linked to
Private lngID As Long                     'ID for this counter


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Name                                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Name() As String
  Let Name = mstrName
End Property

Public Property Let Name(ByVal strVal As String)
  Let mstrName = strVal
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' DisplayName                                                               '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get DisplayName() As String
  Let DisplayName = mstrDisplayName
End Property

Public Property Let DisplayName(ByVal strVal As String)
  Let mstrDisplayName = strVal
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PreferredCounterTypeName                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get PreferredCounterTypeName() As String
  Let PreferredCounterTypeName = mstrPreferredCounterTypeName
End Property

Public Property Let PreferredCounterTypeName(ByVal strVal As String)
  Let mstrPreferredCounterTypeName = strVal
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ServiceProperty                                                           '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get ServiceProperty() As String
  Let ServiceProperty = mstrSDProperty
End Property

Public Property Let ServiceProperty(ByVal strVal As String)
  Let mstrSDProperty = strVal
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ID                                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get ID() As Long
  Let ID = lngID
End Property

Public Property Let ID(ByVal lngVal As Long)
  Let lngID = lngVal
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Counter                                                                   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Counter() As String
  Let Counter = mstrCounter
End Property

Public Property Let Counter(ByVal strVal As String)
  Let mstrCounter = strVal
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

