VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXProperty"
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
' MTConfigHelper.MSIXProperty                                               '
'                                                                           '
' Description:  Property information for MSIX objects                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mobjDN As New Property              'dn
Private mobjType As New Property            'type
Private mobjLength As New Property          'length
Private mobjRequired As New Property        'required
Private mobjDefaultValue As New Property    'default value
Private mobjDescription As New Property     'description of the property

Private mcollAttributes As New Collection           'attributes for the ptype

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : LoadFromXML(objNode)                                      '
' Description   : Load the property from the XML file.  Expects the ptype   '
'               : node to be passed in.                                     '
' Inputs        : objNode -- PType node                                     '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function LoadFromXML(ByRef objPTypeNode As IXMLDOMNode)
  
  If Not objPTypeNode Is Nothing Then
    'Populate the attributes
    Call PopulateAttributes(objPTypeNode, ".", Me)
    
    'Get the data
    mobjDN.value = GetNodeText(objPTypeNode, "dn")
    mobjType.value = GetNodeText(objPTypeNode, "type")
    mobjLength.value = GetNodeText(objPTypeNode, "length")
    mobjRequired.value = GetNodeText(objPTypeNode, "required")
    mobjDefaultValue.value = GetNodeText(objPTypeNode, "defaultvalue")
    mobjDescription.value = GetNodeText(objPTypeNode, "description")
    
    'Get attributes on the data
    Call PopulateAttributes(objPTypeNode, "dn", mobjDN)
    Call PopulateAttributes(objPTypeNode, "type", mobjType)
    Call PopulateAttributes(objPTypeNode, "length", mobjLength)
    Call PopulateAttributes(objPTypeNode, "required", mobjRequired)
    Call PopulateAttributes(objPTypeNode, "defaultvalue", mobjDefaultValue)
    Call PopulateAttributes(objPTypeNode, "description", mobjDescription)
  End If
End Function
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
      objAttribute.value = strValue
      Exit Function
    End If
  Next
  
  'If we get here, the attribute wasn't found, so create it
  Set objAttribute = New PropertyAttribute
  
  objAttribute.Name = strName
  objAttribute.value = strValue
  
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
      GetAttributeValue = objAttribute.value
      Exit Function
    End If
  Next
  
  
  GetAttributeValue = ""
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : Validate(strMessage)                                    '
' Description     : Validate the property.                                  '
' Inputs          : strMessage -- Buffer to populate on failure.            '
' Outputs         : boolean indicatin successful validation.                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function Validate(ByRef strMessage As String)
  
  'Check for length
  If UCase(mobjType.value) = "STRING" Or UCase(mobjType.value) = "UNISTRING" Then
    If Not IsNumeric(mobjLength.value) Then
      strMessage = strMessage & ",Length required for type = " & mobjType.value
    End If
  End If

End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Properties                                                                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Attributes() As Collection
  Set Attributes = mcollAttributes
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get oDN() As Property
  Set oDN = mobjDN
End Property

Public Property Get oMSIXType() As Property
  Set oMSIXType = mobjType
End Property

Public Property Get oLength() As Property
  Set oLength = mobjLength
End Property

Public Property Get oRequired() As Property
  Set oRequired = mobjRequired
End Property

Public Property Get oDefaultValue() As Property
  Set oDefaultValue = mobjDefaultValue
End Property

Public Property Get oDescription() As Property
  Set oDescription = mobjDescription
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get DN() As String
  Let DN = mobjDN.value
End Property

Public Property Get MSIXType() As String
  Let MSIXType = mobjType.value
End Property

Public Property Get Length() As String
  Let Length = mobjLength.value
End Property

Public Property Get Required() As String
  Let Required = mobjRequired.value
End Property

Public Property Get DefaultValue() As String
  Let DefaultValue = mobjDefaultValue.value
End Property

Public Property Get Description() As String
  Let Description = mobjDescription.value
End Property

