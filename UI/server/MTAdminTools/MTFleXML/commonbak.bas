Attribute VB_Name = "Common"
' //==========================================================================
' // @doc $Workfile$
' //
' // Copyright 1998 by MetraTech Corporation
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
' //
' // Created by: Noah W. Cushing
' //
' // $Date$
' // $Author$
' // $Revision$
' //==========================================================================
Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Common.bas -- Routines common to many of the classes present.             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub         : LoadGroupSchemaFromXML(objNode)                             '
' Description : Load a group based on the node passed in.                   '
' Inputs      : objNode -- Node containing the set of groups.               '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadGroupSchemaFromXML(ByRef objNode As IXMLDOMNode) As Group
  Dim objGroup As New Group   'New group to create
  
  'Get the attributes
  objGroup.ReadOnly = CheckAttributeText(objNode, "readonly", "true")
  objGroup.IsOptional = CheckAttributeText(objNode, "optional", "true")
  
  'Get the stylesheet
  objGroup.StyleSheet = GetNodeText(objNode, "stylesheet")
  
  If Len(objGroup.StyleSheet) > 0 Then
    objGroup.UseStyleSheet = True
  Else
    objGroup.UseStyleSheet = False
  End If
  
  'XPath, can be relative or absolute. Optional if all properties have
  'absolute paths. Error will be reported when reading properties
  objGroup.XPath = GetAttributeText(objNode, "xpath")
  
  'Get display information
  objGroup.Title = GetNodeText(objNode, "title")
  objGroup.Text = GetNodeText(objNode, "text")
  
  'Now get any defined attributes
  Call objGroup.GetAttributesFromXML(objNode)
  
  'Get any properties
  Call objGroup.GetPropertiesFromXML(objNode)
  
  'Get any subgroups
  Call objGroup.GetGroupsFromXML(objNode)
  
  'Get any sublists
  Call objGroup.GetListsFromXML(objNode)
    
  Set LoadGroupSchemaFromXML = objGroup
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub         : LoadListSchemaFromXML(objNode)                              '
' Description : Load a group based on the node passed in.                   '
' Inputs      : objNode -- Node containing the set of groups.               '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadListSchemaFromXML(ByRef objNode As IXMLDOMNode) As List
  Dim objList As New List     'New list to create
  Dim strType As String       'List type string
  
  'Get the attributes
  objList.ReadOnly = CheckAttributeText(objNode, "readonly", "true")
  objList.IsOptional = CheckAttributeText(objNode, "optional", "true")
  
  'Get the listtype
  strType = GetAttributeText(objNode, "type")
  
  Select Case UCase(strType)
    Case "SIMPLE"
      objList.ListType = 0
    Case "EXTENDED"
      objList.ListType = 1
    Case "FLATEXTENDED"
      objList.ListType = 2
  End Select
  
  'Get the stylesheet
  objList.StyleSheet = GetNodeText(objNode, "stylesheet")
  
  If Len(objList.StyleSheet) = 0 Then
    objList.UseStyleSheet = True
  Else
    objList.UseStyleSheet = False
  End If
  
  'XPath, can be relative or absolute. Optional if all properties have
  'absolute paths. Error will be reported when reading properties
  objList.XPath = GetNodeText(objNode, "xpath")
  
  'Get display information
  objList.Title = GetNodeText(objNode, "title")
  objList.Text = GetNodeText(objNode, "text")
  
  'Now get any defined attributes
  Call objList.GetAttributesFromXML(objNode)
  
  'Get any properties
  Call objList.GetPropertiesFromXML(objNode)
  
  'Get any subgroups
  Call objList.GetGroupsFromXML(objNode)
  
  'Get any sublists
  Call objList.GetListsFromXML(objNode)
    
  Set LoadListSchemaFromXML = objList
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : LoadPropertySchemaFromXML(objNode) as Property            '
' Description   : Load a property based on the node passed in.              '
' Inputs        : objNode -- reference to a property node                   '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadPropertySchemaFromXML(ByRef objPropertyNode As IXMLDOMNode) As Property
  Dim objProperty As New Property
  
  'Get the boolean values, stored in the attributes of the property
  objProperty.Hidden = CheckAttributeText(objPropertyNode, "hidden", "true")
  objProperty.IsOptional = CheckAttributeText(objPropertyNode, "optional", "true")
  objProperty.ReadOnly = CheckAttributeText(objPropertyNode, "readonly", "true")
  objProperty.ReadOnlyLocalized = CheckAttributeText(objPropertyNode, "readonlylocalized", "true")
  objProperty.ReadWriteLocalized = CheckAttributeText(objPropertyNode, "readwritelocalized", "true")
  objProperty.Sortable = CheckAttributeText(objPropertyNode, "sortable", "true")
    
  'Get the property data
  objProperty.DisplayName = GetNodeText(objPropertyNode, "display_name")
  objProperty.LocalizationFQN = GetNodeText(objPropertyNode, "localization_fqn")
  objProperty.Prompt = GetNodeText(objPropertyNode, "prompt")
  objProperty.XPath = GetNodeText(objPropertyNode, "xpath")
  
  'Load the attributes of the property
  Call objProperty.GetAttributesFromXML(objPropertyNode)
    
  Set LoadPropertySchemaFromXML = objProperty
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : LoadAttributeSchemaFromXML(objNode) as property           '
' Description   : Load the given attribute from the passed in node.         '
' Inputs        : objNode -- reference to the attribute node.               '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadAttributeSchemaFromXML(ByRef objAttributeNode As IXMLDOMNode) As AttributeItem
  Dim objAttribute As New AttributeItem
  
  'Get the data
  objAttribute.IsOptional = CheckAttributeText(objAttributeNode, "optional", "true")
  objAttribute.ReadOnly = CheckAttributeText(objAttributeNode, "readonly", "true")
    
  objAttribute.Name = GetNodeText(objAttributeNode, "name", True)
  objAttribute.Value = GetNodeText(objAttributeNode, "value")
  objAttribute.Text = GetNodeText(objAttributeNode, "text")
  
  Set LoadAttributeSchemaFromXML = objAttribute
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddGridHeaderAttribute(objTemplateNode, objAttribute,     '
'               :                        collXPath)                         '
' Inputs        : objTemplateNode -- Node to duplicate and add as a sibling.'
'               : objAttribute    -- Attribute to add                       '
'               : collXPath       -- XPath data to add                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function AddGridHeaderAttribute(ByRef objTemplateNode As IXMLDOMNode, _
                                ByRef objAttribute As AttributeItem, _
                                ByRef collXPath As Collection)
  Dim objNewNode As IXMLDOMNode   'Node to add
  
  'Create the new node
  Set objNewNode = objTemplateNode.cloneNode(True)
  objNewNode.Text = objAttribute.Text
  
  'Add the new node
  Call objTemplateNode.parentNode.appendChild(objNewNode)
  
  'Add the xpath
  Call collXPath.Add("/@" & objAttribute.Name)
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddGridHeaderProperty(objTemplateNode, objProperty,       '
'               :                       collXPath)                          '
' Inputs        : objTemplateNode -- Node to duplicate and add as a sibling.'
'               : objProperty     -- Property to add                        '
'               : collXPath       -- XPath data to add                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function AddGridHeaderProperty(ByRef objTemplateNode As IXMLDOMNode, _
                                ByRef objProperty As Property, _
                                ByRef collXPath As Collection)
  Dim objNewNode As IXMLDOMNode   'Node to add
  
  'Create the new node
  Set objNewNode = objTemplateNode.cloneNode(True)
  objNewNode.Text = objProperty.DisplayName
  
  'Add the new node
  Call objTemplateNode.parentNode.appendChild(objNewNode)
  
  'Add the xpath to the collecition
  Call collXPath.Add("/" & objProperty.XPath)
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : ReplaceHeaderRow(objXSL, objNewHeaderXSL)                 '
' Description   : Replace the header row of the template with the new       '
'               : header.                                                   '
' Inputs        : objXSL          -- XSL for the group                      '
' Outputs       : objNewHeaderXSL -- New XSL for the header                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ReplaceHeaderRow(ByRef objXSL As IXMLDOMNode, _
                          ByRef objNewHeaderXSL As IXMLDOMNode)
  Dim objHeaderRow As IXMLDOMNode     'header row
  
  Set objHeaderRow = objXSL.selectSingleNode("//tr[@id='TABLE_HEADER_ROW']")
  Call objHeaderRow.parentNode.replaceChild(objNewHeaderXSL, objHeaderRow)

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GenerateGroupXSL(objGroup, objXSL, strPageXPath)          '
' Description   : Modify the XSL data input to reflect the contents of the  '
'               : group.                                                    '
' Inputs        : objGroup      --  the group schema                        '
'               : objXSL        --  the XSL to modify                       '
'               : strPageXPath  --  base XPath for the page                 '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function GenerateGroupXSL(ByRef objGroup As Group, _
                          ByRef objXSL As DOMDocument30, _
                          ByVal strPageXPath)
  'Header Nodes
  Dim objHeaderRowNode As IXMLDOMNode           'Node for the header row
  Dim objHeaderCellNode As IXMLDOMNode          'Template for header cells
  Dim objHeaderCellEditNode As IXMLDOMNode      'Node for the edit prompt
  Dim objNewHeaderCellNode As IXMLDOMNode       'Node for dynamically added headers
  Dim objNode As IXMLDOMNode                    'General purpose node
  
  'Row Nodes
  Dim objRowTemplateNode As IXMLDOMNode         'Row template to make copies of
  Dim objRowNode As IXMLDOMNode                 'Data row to add
  
  'XSL nodes
  Dim objXSLTextNode As IXMLDOMNode               'xsl text
  Dim objXSLValueNode As IXMLDOMNode              'xsl:value-of node
  Dim objXSLSelectAttribute As IXMLDOMAttribute   'select attribute for value-of
  
  Dim bAttributes As Boolean                    'Indicates that attributes of properties
                                                'should be displayed in the grid.
  Dim bOdd As Boolean                           'Indicates if this is an even or odd row
  
  Dim objAttribute As AttributeItem             'Attributes of groups/properties
  Dim objProperty As Property                   'Properties of groups
  
  Dim objStyleSheet As New DOMDocument30        'The custom stylesheet for the group
                          
  'First check for a group stylesheet
  If objGroup.UseStyleSheet Then  'MORE WORK HERE
    Call objStyleSheet.Load(objGroup.StyleSheet)
    
    If objStyleSheet.parseError Then
      Err.Raise -1
    End If
    
    Set objXSL = objStyleSheet
    
  Else
    'Get some useful nodes
    Set objHeaderRowNode = GetClonedNode(objXSL.documentElement, "//tr[@id='TABLE_HEADER_ROW']", True)
    Set objHeaderCellEditNode = GetClonedNode(objXSL.documentElement, "//td[@id='TABLE_HEADER_EDIT_CELL']", True)
    
    'If not read-only, add the edit node
    If Not objGroup.ReadOnly And Not objGroup.NoPopups Then
      Call ReplaceNodeText(objHeaderCellEditNode, "##TEXT##", objGroup.EditHeader)
      Call objHeaderRowNode.appendChild(objHeaderCellEditNode)
    End If
    
    'Add the header for properties (this includes attributes of the group)
    Set objHeaderCellNode = GetClonedNode(objXSL.documentElement, "//td[@id='TABLE_HEADER_CELL']", True)
    Call ReplaceNodeText(objHeaderCellNode, "##TEXT##", objGroup.PropertyHeader)
    Call objHeaderRowNode.appendChild(objHeaderCellNode)
    
    'If necessary, add the attributes header
    bAttributes = False
    
    If objGroup.ShowAttributesInGrid Then
      For Each objProperty In objGroup.Properties
        For Each objAttribute In objProperty.Attributes
          If Not objAttribute.Hidden Then
            bAttributes = True
            Exit For
          End If
        Next
        
        If bAttributes Then
          Exit For
        End If
      Next
    
      If bAttributes Then
        Set objHeaderCellNode = GetClonedNode(objXSL.documentElement, "//td[@id='TABLE_HEADER_CELL']", True)
        Call ReplaceNodeText(objHeaderCellNode, "##TEXT##", objGroup.AttributeHeader)
        Call objHeaderRowNode.appendChild(objHeaderCellNode)
      End If
    End If
    
    'Replace the stock template's header row
    Call ReplaceHeaderRow(objXSL.documentElement, objHeaderRowNode)
    
    
    'NOW -- WRITE THE DATA ROWS
    'Get the templates
    Set objRowTemplateNode = objXSL.selectSingleNode("//tr[@id='TABLE_DATA_ROW']")
    
    'Add the attributes of the group
    For Each objAttribute In objGroup.Attributes
      Set objRowNode = objRowTemplateNode.cloneNode(True)
      Call MakeAttributeRow(objAttribute, objRowNode, strPageXPath, bOdd, bAttributes)
      bOdd = Not bOdd
    Next
    
    'Add the properties of the group
    For Each objProperty In objGroup.Properties
      Set objRowNode = objRowTemplateNode.cloneNode(True)
      
                          
                          
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : MakeAttributeRow(objAttribute, objTemplateRow, strGroupXPath)'
' Description : Return a row for the attribute based on the attribute and   '
'             : the template row.                                           '
' Inputs      : objAttribute    --  Attribute to add the row for            '
'             : objTemlpateRow  --  Template for the row                    '
'             : strGroupXPath   --  XPath for the group (no trailing /)     '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function MakeAttributeRow(ByRef objAttribute As AttributeItem, _
                          ByRef objTemplateRow As IXMLDOMNode, _
                          ByRef strGroupXPath As String, _
                          bOdd As Boolean, _
                          bAddBlank As Boolean)
  
  Dim objCellEvenTemplateNode As IXMLDOMNode    'Cell template to make copies of
  Dim objCellOddTemplateNode As IXMLDOMNode     'Cell template to make copies of
  Dim objEditCellEvenTemplateNode As IXMLDOMNode 'Cell template to make copies of
  Dim objEditCellOddTemplateNode As IXMLDOMNode 'Cell template to make copies of
  Dim objCellNode As IXMLDOMNode                'Data cell to add
    
  'Copy the template nodes
  Set objCellEvenTemplateNode = objTemplateRow.selectSingleNode("//td[@id='TABLE_DATA_EVEN_CELL']")
  Set objCellOddTemplateNode = objTemplateRow.selectSingleNode("//td[@id='TABLE_DATA_ODD_CELL']")
    
  Set objEditCellEvenTemplateNode = objTemplateRow.selectSingleNode("//td[@id='TABLE_DATA_EVEN_EDIT_CELL']")
  Set objEditCellOddTemplateNode = objTemplateRow.selectSingleNode("//td[@id='TABLE_DATA_ODD_EDIT_CELL']")
      
  If Not objAttribute.ReadOnly Then
    If bOdd Then
      Set objCellNode = objEditCellOddTemplateNode.cloneNode(True)
    Else
      Set objCellNode = objEditCellEvenTemplateNode.cloneNode(True)
    End If
        
    'Add the edit link
    Call XSLAddSearchableChildNumber(objCellNode, "ATTRIBUTE_" & objAttribute.Name)
        
    'The td may not be a child of the row node, so add the new node as a child of
    'the parent of the template node, even or odd doesn't matter
    Call objEditCellOddTemplateNode.parentNode.appendChild(objCellNode)
  End If
      
      
  'Add the attribute
  If bOdd Then
    Set objCellNode = objEditCellOddTemplateNode.cloneNode(False)
  Else
    Set objCellNode = objEditCellEvenTemplateNode.cloneNode(False)
  End If
      
  Call XSLAddValueNode(objCellNode, strPageXPath & objGroup.XPath & "/@" & objAttribute.Name)
  Call objEditCellOddTemplateNode.parentNode.appendChild(objCellNode)
      
  'Add a blank node
  If bOdd Then
    Set objCellNode = objEditCellOddTemplateNode.cloneNode(True)
  Else
    Set objCellNode = objEditCellEvenTemplateNode.cloneNode(True)
  End If
      
  objCellNode.Text = ""

  If bAddBlank Then
    Call objEditCellOddTemplateNode.parentNode.appendChild(objCellNode)
  End If
  
  
  'Remove the templates
  Call objCellEvenTemplateNode.parentNode.removeChild(objCellEvenTemplateNode)
  Call objCellOddTemplateNode.parentNode.removeChild(objCellOddTemplateNode)
  Call objEditCellEvenTemplateNode.parentNode.removeChild(objEditCellEvenTemplateNode)
  Call objEditCellOddTemplateNode.parentNode.removeChild(objEditCellOddTemplateNode)
                          
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : MakePropertyRow(objAttribute, objTemplateRow, strGroupXPath)'
' Description : Return a row for the attribute based on the attribute and   '
'             : the template row.                                           '
' Inputs      : objAttribute    --  Attribute to add the row for            '
'             : objTemlpateRow  --  Template for the row                    '
'             : strGroupXPath   --  XPath for the group (no trailing /)     '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function MakePropertyRow(ByRef objProperty As Property, _
                          ByRef objTemplateRow As IXMLDOMNode, _
                          ByRef strGroupXPath As String, _
                          bOdd As Boolean, _
                          bAttributes As Boolean)
  Dim objAttribute As AttributeItem             'attributes of the properties
  Dim objXML As New DOMDocument                 'xml document
  Dim objRow As IXMLDOMNode                     'rows of attributes
  Dim objCellEvenTemplateNode As IXMLDOMNode    'Cell template to make copies of
  Dim objCellOddTemplateNode As IXMLDOMNode     'Cell template to make copies of
  Dim objEditCellEvenTemplateNode As IXMLDOMNode 'Cell template to make copies of
  Dim objEditCellOddTemplateNode As IXMLDOMNode 'Cell template to make copies of
  Dim objCellNode As IXMLDOMNode                'Data cell to add
  Dim objTableNode As IXMLDOMNode               'table for the attributes
  Dim bTempReadOnly As Boolean                  'used for attributes
    
  'Copy the template nodes
  Set objCellEvenTemplateNode = objTemplateRow.selectSingleNode("//td[@id='TABLE_DATA_EVEN_CELL']")
  Set objCellOddTemplateNode = objTemplateRow.selectSingleNode("//td[@id='TABLE_DATA_ODD_CELL']")
    
  Set objEditCellEvenTemplateNode = objTemplateRow.selectSingleNode("//td[@id='TABLE_DATA_EVEN_EDIT_CELL']")
  Set objEditCellOddTemplateNode = objTemplateRow.selectSingleNode("//td[@id='TABLE_DATA_ODD_EDIT_CELL']")
      
  If Not objProperty.ReadOnly Then
    If bOdd Then
      Set objCellNode = objEditCellOddTemplateNode.cloneNode(True)
    Else
      Set objCellNode = objEditCellEvenTemplateNode.cloneNode(True)
    End If
        
    'Add the edit link
    Call XSLAddSearchableChildNumber(objCellNode, "PROPERTY_" & objProperty.XPath)
        
    'The td may not be a child of the row node, so add the new node as a child of
    'the parent of the template node, even or odd doesn't matter
    Call objEditCellOddTemplateNode.parentNode.appendChild(objCellNode)
  End If
      
      
  'Add the property
  If bOdd Then
    Set objCellNode = objEditCellOddTemplateNode.cloneNode(False)
  Else
    Set objCellNode = objEditCellEvenTemplateNode.cloneNode(False)
  End If
      
  Call XSLAddValueNode(objCellNode, strPageXPath & objGroup.XPath & "/@" & objAttribute.Name)
  Call objEditCellOddTemplateNode.parentNode.appendChild(objCellNode)
      
  'Add the attributes
  If bOdd Then
    Set objCellNode = objEditCellOddTemplateNode.cloneNode(True)
  Else
    Set objCellNode = objEditCellEvenTemplateNode.cloneNode(True)
  End If
      
  objCellNode.Text = ""

  If bAttributes Then
    Set objTableNode = objXML.createNode(NODE_ELEMENT, "table", "")
    
    For Each objAttribute In objAttribute
      'A little hack to use the make attribute row function
      Set objRow = objXML.createNode(NODE_ELEMENT, "tr", "")
      Call objRow.appendChild(objEditCellOddTemplateNode)
      Call objRow.appendChild(objEditCellEvenTemplateNode)
      
      objAttribute.ReadOnly = True
      Call MakeAttributeRow(objAttribute, objRow, strGroupXPath & "/" & objProperty.XPath, bOdd, False)
      
    
    Call objEditCellOddTemplateNode.parentNode.appendChild(objCellNode)
  End If
  
  
  'Remove the templates
  Call objCellEvenTemplateNode.parentNode.removeChild(objCellEvenTemplateNode)
  Call objCellOddTemplateNode.parentNode.removeChild(objCellOddTemplateNode)
  Call objEditCellEvenTemplateNode.parentNode.removeChild(objEditCellEvenTemplateNode)
  Call objEditCellOddTemplateNode.parentNode.removeChild(objEditCellOddTemplateNode)
                          
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : XSLAddSearchableChildNumber(objNode, strSearch)             '
' Description : Places an xsl:eval(childNumber()) function in as a child of '
'             : the passed in node of format '##strSearch:<xsl:eval/>##'    '
' Inputs      : objNode -- The node to add the eval to.                     '
'             : strSearch -- String to be used for searching later          '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function XSLAddSearchableChildNumber(ByRef objNode As IXMLDOMNode, _
                                     ByRef strSearch As String)
  Dim objXML As New DOMDocument30         'Used to create nodes
  Dim objXSLPreTextNode As IXMLDOMNode    'Text node
  Dim objXSLEvalNode As IXMLDOMNode       'Eval node
  Dim objXSLPostTextNode As IXMLDOMNode   'Text node
  
  Set objXSLPreTextNode = objXML.createTextNode("##" & strSearch & ":")
  Set objXSLEvalNode = objXML.createNode(NODE_ELEMENT, "xsl:eval", "http://www.w3.org/TR/WD-xsl")
  Set objXSLPostTextNode = objXML.createTextNode("##")
  
  Call objNode.appendChild(objXSLPreTextNode)
  Call objNode.appendChild(objXSLEvalNode)
  Call objNode.appendChild(objXSLPostTextNode)
                                     
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : XSLAddValueNode(objNode, strSelect)                         '
' Description : Add an xsl:value-of node to the passed in node.             '
' Inputs      : objNode   -- node to add the value-of to.                   '
'             : strSelect -- value to set the select attribute to.          '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function XSLAddValueNode(ByRef objNode As IXMLDOMNode, ByRef strSelect As String)
  Dim objXML As New DOMDocument30
  Dim objXSLAttribute As IXMLDOMAttribute
  Dim objXSLValueNode As IXMLDOMNode
  
  Set objXSLValueNode = objXML.createNode(NODE_ELMENT, "xsl:value-of", "http://www.w3.org/TR/WD-xsl")
  Set objXSLAttribute = objXML.createNode(NODE_ATTRIBUTE, "select", "")
  
  objXSLAttribute.Value = strSelect
  
  Call objXSLValueNode.Attributes.setNamedItem(objXSLAttribute)
  
  Call objNode.appendChild(objXSLValueNode)
End Function
