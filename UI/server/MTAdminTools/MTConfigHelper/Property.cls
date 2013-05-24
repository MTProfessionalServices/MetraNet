VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Property"
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
' MTConfigHelper.Property                                                   '
'                                                                           '
' Description:  General use property, with name, value, and attributes.     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mstrName                    'Name of the property
Private mstrValue                   'Value of the property

Private mcollAttributes As New Collection    'Collection of attributes

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : SetAttributeValue(strName, strValue)                      '
' Description   : Create (if necessary) and set the value of an attribute.  '
' Inputs        : strName   --  Name of the attribute                       '
'               : strValue  --  Value of the attribute                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function SetAttributeValue(ByVal strName As String, _
                                  Optional ByVal strValue As String = "")
  Dim objAttribute As PropertyAttribute
    
  For Each objAttribute In mcollAttributes
    If UCase(objAttribute.Name) = UCase(strName) Then
      objAttribute.Value = strValue
      Exit Function
    End If
  Next
  
  'If we get here, the attribute wasn't found, so create it
  Set objAttribute = New PropertyAttribute
  
  objAttribute.Name = strName
  objAttribute.Value = strValue
  
  Call mcollAttributes.Add(objAttribute)
                             
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : GetAttributeValue(strName)                              '
' Description     : Return the value of the specified attribute.            '
' Inputs          : strName -- name of the attribute to get.                '
' Outputs         : Value of the attribute.                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetAttributeValue(ByVal strName As String) As String
  Dim objAttribute As PropertyAttribute
  
  For Each objAttribute In mcollAttributes
    If UCase(objAttribute.Name) = UCase(strName) Then
      GetAttributeValue = objAttribute.Value
      Exit Function
    End If
  Next
  
  
  GetAttributeValue = ""
End Function
''''''''''''''''''''''''''''''''''''''''''''''''''
' Properties
''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Attributes() As Collection
  Set Attributes = mcollAttributes
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Name() As String
  Let Name = mstrName
End Property

Public Property Let Name(ByVal strName As String)
  Let mstrName = strName
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Value() As String
  Let Value = mstrValue
End Property

Public Property Let Value(ByVal strValue As String)
  Let mstrValue = strValue
End Property

