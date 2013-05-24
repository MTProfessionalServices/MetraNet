VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PriceableItemType"
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
' MTConfigHelper.PriceableItem                                              '
'                                                                           '
' Description:  Container for Priceable Item information.                   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mstrName As String            'Name of the PI
Private mstrDescription As String     'Description of the PI
Private mstrType As String            'Type of the PI
Private mstrParent As String          'Parent of the PI

Private mcollChildren As New Collection         'Children of the PI
Private mcollParameterTables As New Collection  'Parameter tables

Private mcollCPDs As New Collection             'CPD definitions
Private mcollCounters As New Collection         'Counters

Private mstrServiceDefinition As String         'Service linked to this priceable item
Private mstrProductView As String               'Product view linked to this priceable item

Private mstrXMLPath As String                   'XML path for the type (used for editing existing PI Types)

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : LoadFromXML(strPath)                                      '
' Description   : Populate from an XML file.                                '
' Inputs        : strPath -- Path to load XML from                          '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function LoadFromXML(ByVal strPath As String)
  Dim objXML As New DOMDocument30           'XML DOM object
  Dim objNodeList As IXMLDOMNodeList        'List of XML nodes
  Dim objNode As IXMLDOMNode                'XML node
  
  'Init the XML DOM object
  objXML.async = False
  objXML.validateOnParse = False
  objXML.resolveExternals = False
  
  Call objXML.Load(strPath)
  
  If objXML.parseError Then
  
  Else
    mstrXMLPath = strPath
  
    mstrName = GetNodeText(objXML, "/priceable_item/name")
    mstrDescription = GetNodeText(objXML, "/priceable_item/description")
    mstrType = GetNodeText(objXML, "/priceable_item/item_type")
    mstrParent = GetNodeText(objXML, "/priceable_item/relationships/parent")
    mstrServiceDefinition = GetNodeText(objXML, "/priceable_item/pipeline/service_definition")
    mstrProductView = GetNodeText(objXML, "/priceable_item/pipeline/product_view")
    
    'Get the parameter tables
    Set objNodeList = objXML.selectNodes("/priceable_item/parameter_table")
    
    For Each objNode In objNodeList
      Call mcollParameterTables.Add(objNode.Text)
    Next
    
    'Get the children
    Set objNodeList = objXML.selectNodes("/priceable_item/relationships/child")
    
    For Each objNode In objNodeList
      Call mcollChildren.Add(objNode.Text)
    Next
    
    'Get CPD's and Counters if necessary
    Set objNodeList = objXML.selectNodes("/priceable_item/counters/cpd")
    
    For Each objNode In objNodeList
      Call AddCPDFromXML(objNode)
    Next
    
    Set objNodeList = objXML.selectNodes("/priceable_item/counters/counter")
    
    For Each objNode In objNodeList
      Call AddCounterFromXML(objNode)
    Next
    
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddCPDFromXML(objNode)                                    '
' Description   : Add a new cpd to the collection, based on the XML data.   '
' Inputs        : objNode -- cpd node from a priceable item def. file       '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function AddCPDFromXML(ByRef objNode As IXMLDOMNode)
  Dim objCPD As New CPD
  
  objCPD.Name = GetNodeText(objNode, "name")
  objCPD.DisplayName = GetNodeText(objNode, "display_name")
  objCPD.ServiceProperty = GetNodeText(objNode, "service_property")
  objCPD.PreferredCounterType = GetNodeText(objNode, "preferred_counter_type")
  
  Call mcollCPDs.Add(objCPD)

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddCounterFromXML(objNode)                                '
' Description   : Add a new counter to the collection, based on the XML.    '
' Inputs        : objNode -- counter node from a priceable item def. file.  '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function AddCounterFromXML(ByRef objNode As IXMLDOMNode)
  Dim objCounter As New Counter
  Dim objParamList As IXMLDOMNodeList
  Dim objParamNode As IXMLDOMNode
  
  objCounter.Name = GetNodeText(objNode, "name")
  objCounter.CounterType = GetNodeText(objNode, "type")
  
  Set objParamList = objNode.selectNodes("parameter")
  
  For Each objParamNode In objParamList
    Call objCounter.SetParameter(GetNodeText(objParamNode, "name"), GetNodeText(objParamNode, "value"))
    'objCounter.GetParameter(GetNodeText(objParamNode, "name")).value _
    '= GetNodeText(objParamNode, "value")
  Next
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Properties                                                                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Name() As String
  Let Name = mstrName
End Property

Public Property Get Description() As String
  Let Description = mstrDescription
End Property

Public Property Get PIType() As String
  Let PIType = mstrType
End Property

Public Property Get Parent() As String
  Let Parent = mstrParent
End Property

Public Property Get ServiceDefinition() As String
  Let ServiceDefinition = mstrServiceDefinition
End Property

Public Property Get ProductView() As String
  Let ProductView = mstrProductView
End Property

Public Property Get ParameterTables() As Collection
  Set ParameterTables = mcollParameterTables
End Property

Public Property Get Children() As Collection
  Set Children = mcollChildren
End Property

''''''''
Public Property Get XMLPath() As String
  Let XMLPath = mstrXMLPath
End Property


