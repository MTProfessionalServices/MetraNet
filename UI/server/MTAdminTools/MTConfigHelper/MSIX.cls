VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIX"
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
' MTConfigHelper.MSIX                                                       '
'                                                                           '
' Description:  Container for MSIX information.                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mobjName As New Property                  'Name of the msix
Private mobjDescription As New Property           'Description of the msix

Private mstrPath As String                        'Path for the msix

Private mcollProperties As New Collection         'PTypes


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : LoadFromXML(strPath)                                      '
' Description   : Populate from an XML file.                                '
' Inputs        : strPath -- Path to load XML from                          '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function LoadFromXML(ByVal strPath As String)
  Dim objXML As New DOMDocument30
  
  Dim objNodeList As IXMLDOMNodeList
  Dim objNode As IXMLDOMNode
  
  Dim objProperty As MSIXProperty
  
  objXML.async = False
  objXML.validateOnParse = False
  objXML.resolveExternals = False
  
  'Set the path
  mstrPath = Replace(strPath, "\", "/")
  
  'Load the XML
  Call objXML.Load(mstrPath)
  
  'Do nothing if there is a parse error
  If objXML.parseError Then
    Exit Function
  Else
    'Get the name
    mobjName.value = GetNodeText(objXML, "/defineservice/name")
    
    'Get any attributes for the name
    Call PopulateAttributes(objXML, "/defineservice/name", mobjName)
    
    'Get the description
    mobjDescription.value = GetNodeText(objXML, "/defineservice/description")
    Call PopulateAttributes(objXML, "/defineservice/description", mobjDescription)
    
    Set objNodeList = objXML.selectNodes("/defineservice/ptype")
    
    'Load the properties
    For Each objNode In objNodeList
      Set objProperty = New MSIXProperty
      
      Call objProperty.LoadFromXML(objNode)
      
      Call mcollProperties.Add(objProperty)
    Next
  End If
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetProperty(strName)                                      '
' Description   : Return a property object based on name.                   '
' Inputs        : strName -- Name of the property to get.                   '
' Outputs       : Property object                                           '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetProperty(ByVal strName As String) As Object
  Dim objProperty As Property
  
  For Each objProperty In mcollProperties
    If UCase(objProperty.Name) = UCase(strName) Then
      Set GetProperty = objProperty
      Exit Function
    End If
  Next
  
  Set objProperty = Nothing
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : AddProperty(objProperty)                                '
' Description     : Add an MSIX property to the collection.                 '
' Inputs          : objProperty -- Property to add to the collection.       '
' Outputs         : none                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function AddProperty(ByRef objProperty As MSIXProperty)
  Call mcollProperties.Add(objProperty)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : Validate()                                              '
' Description     : Validate an MSIX file.                                  '
' Inputs          : strMessage -- String buffer, contains error message on  '
'                 :               validation failure.                       '
' Outputs         : boolean indicating successful validation (or failure)   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function Validate(ByRef strMessage As String) As Boolean
  Dim objProperty As MSIXProperty
  Dim strTempMessage As String
  Dim bReturn As Boolean
  
  For Each objProperty In mcollProperties
    If Not objProperty.Validate(strTempMessage) Then
      strMessage = strMessage & strTempMessage
    End If
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Properties                                                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Properties() As Collection
  Set Properties = mcollProperties
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get oName() As Property
  Set oName = mobjName
End Property

Public Property Get oDescription() As Property
  Set oDescription = mobjDescription
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Name() As String
  Let Name = mobjName.value
End Property

Public Property Get Description() As String
  Let Description = mobjDescription.value
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Path() As String
  Let Path = mstrPath
End Property

Public Property Let Path(ByVal strPath As String)
  mstrPath = Replace(strPath, "\", "/")
End Property
