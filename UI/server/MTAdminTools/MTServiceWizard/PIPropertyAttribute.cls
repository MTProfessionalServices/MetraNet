VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PIPropertyAttribute"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'----------------------------------------------------------------------------
' Copyright 1998, 1999 by MetraTech Corporation
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
'
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
'
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
' This class is used by the service wizard ASP pages to faciliate creating
' a service through modifying the proper files and putting them in the
' correct location.  Specific methods for setting values of extended property
' attributes for priceable items are included.
'----------------------------------------------------------------------------

Option Explicit

'---------------------------------------------------------------------------'
' Global Variables                                                          '
'---------------------------------------------------------------------------'
Private mstrAttributeName As String         'Name of the attribute
Private mstrAttributeValue As String        'Value of the attribute
Private mstrPropertyName As String          'Name of the property
Private mstrAttributeDefaultValue As String 'Default value of the attribute


'---------------------------------------------------------------------------'
' Class Properties                                                          '
'---------------------------------------------------------------------------'
'NAME
Public Property Let Name(ByVal strName As String)
  Let mstrAttributeName = strName
End Property

Public Property Get Name() As String
  Let Name = mstrAttributeName
End Property

'VALUE
Public Property Let Value(ByVal strVal As String)
  Let mstrAttributeValue = strVal
End Property

Public Property Get Value() As String
  Let Value = mstrAttributeValue
End Property

'PROPERTYNAME
Public Property Let PropertyName(ByVal strName As String)
  Let mstrPropertyName = strName
End Property

Public Property Get PropertyName() As String
  Let PropertyName = mstrPropertyName
End Property

'DEFAULTVALUE
Public Property Let DefaultValue(ByVal strVal As String)
  Let mstrAttributeDefaultValue = strVal
End Property

Public Property Get DefaultValue() As String
  Let DefaultValue = mstrAttributeDefaultValue
End Property
