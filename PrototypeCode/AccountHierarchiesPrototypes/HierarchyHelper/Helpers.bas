Attribute VB_Name = "Helpers"
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
'  Helpers.bas                                                              '
'  Helpful common routines for hierarchy display.                           '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim g_objXML As New DOMDocument30
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : SetAttribute(objEntity, strAttribute, strValue,         '
'               :              bRecurse)                                  '
' Description   : Set an attribute for a group of nodes.                  '
' Inputs        : objEntity       --  Node of entity to set attributes    '
'               : strAttribute    --  Attribute to add                    '
'               : strValue        --  Value of attribute                  '
'               : bRecurse        --  Recurse through child entities.     '
' Outputs       : none                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function SetAttribute(ByRef objEntity As IXMLDOMNode, _
                      ByVal strAttribute As String, _
                      ByVal strValue As String, _
                      ByVal bRecurse As Boolean) As Boolean
                      
  Dim objEntityList As IXMLDOMNodeList            'List of entities (when recursing)
  Dim objEntityNode As IXMLDOMNode                'Used to iterate through list of entities
  Dim objAttr As IXMLDOMAttribute                 'Attribute to add
  
  'Create the attribute and add it
  Set objAttr = g_objXML.createAttribute(strAttribute)
  objAttr.Value = strValue
  Call objEntity.Attributes.setNamedItem(objAttr)
  
  'If recursive, loop through child nodes
  
  'Problem with objEntity eventually becoming nothing
  If bRecurse Then
    Set objEntityList = objEntity.selectNodes(ENTITY_CHILD_NODES)
    
    For Each objEntityNode In objEntityList
      Call SetAttribute(objEntityNode, strAttribute, strValue, bRecurse)
    Next
  End If

  SetAttribute = True
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : SetEntityValue(objEntity, strProperty, strValue,        '
'               :                bRecurse)                                '
' Description   : Set a value for a group of nodes                        '
' Inputs        : objEntity       --  Node of entity to set attributes    '
'               : strProperty     --  Property to set value for.          '
'               : strValue        --  Value of attribute                  '
'               : bRecurse        --  Recurse through child entities.     '
'               : bAppend         --  append the value to the node's val. '
' Outputs       : none                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function SetEntityValue(ByRef objEntity As IXMLDOMNode, _
                        ByVal strProperty As String, _
                        ByVal strValue As String, _
                        ByVal bRecurse As Boolean, _
                        Optional ByVal bAppend As Boolean = False) As Boolean
                        
  Dim objEntityList As IXMLDOMNodeList            'List of entities (when recursing)
  Dim objEntityNode As IXMLDOMNode                'Used to iterate through list of entities
  Dim objPropertyNode As IXMLDOMNode              'Property to modify
  
  'Set the node's value
  Set objPropertyNode = objEntity.selectSingleNode(strProperty)
  
  If Not objPropertyNode Is Nothing Then
    If bAppend Then
      objPropertyNode.Text = objPropertyNode.Text & strValue
    Else
      objPropertyNode.Text = strValue
    End If
  End If
  
  'Recurse if necessary
  If bRecurse Then
    Set objEntityList = objEntity.selectNodes(ENTITY_CHILD_NODES)
    
    For Each objEntity In objEntityList
      Call SetEntityValue(objEntity, strProperty, strValue, bRecurse, bAppend)
    Next
  End If
                        
  SetEntityValue = True

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : CloneEntity(objEntity)                                      '
' Description : Clone the selected entity, including all attributes.        '
' Inputs      : objEntity -- Entity to clone                                '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function CloneEntity(ByRef objEntity As IXMLDOMNode) As IXMLDOMNode
  Dim objAttribute As IXMLDOMAttribute        'Used to set attributes
  
  Dim objHierarchyNode As IXMLDOMNode         'Node to return
  Dim objNode As IXMLDOMNode                  'Node with data to copy
  
  'create the entity node and its attributes
  Set objHierarchyNode = objEntity.cloneNode(False)
  
  'Create the children
  'Parent ID
  Set objNode = objEntity.selectSingleNode(ENTITY_PARENT_ID)
  
  If Not objNode Is Nothing Then
    Call objHierarchyNode.appendChild(objNode.cloneNode(True))
  End If
  
  'NAME
  Set objNode = objEntity.selectSingleNode(ENTITY_NAME)
  
  If Not objNode Is Nothing Then
    Call objHierarchyNode.appendChild(objNode.cloneNode(True))
  End If
  
  'ID
  Set objNode = objEntity.selectSingleNode(ENTITY_ID)
  
  If Not objNode Is Nothing Then
    Call objHierarchyNode.appendChild(objNode.cloneNode(True))
  End If
  
  Set CloneEntity = objHierarchyNode
End Function
