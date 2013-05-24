VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "List"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
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

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' List.cls -- Contains schema information for a list, which is a set of     '
'             identical properties (or sets of properties) arranged in      '
'             "list" format.                                                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Public Enum FlexListType
'  SIMPLE = 0            'List consisting of one element
'  EXTENDED = 1          'A list of groups
'  FLATEXTENDED = 2      'A list like element1, element2, element1, element2 where
'                        'elmenents 1 and 2 are logically grouped together
'End Enum

Private mstrXPath As String       'xpath used to locate the node, can be absolute or
                                  'relative to the parent page.
Private mstrID As String          'can be used to identify the list if xpath is not unique
Private mstrTitle As String       'The title of the list
Private mstrText As String        'The text prompt for the list
Private mbReadOnly As Boolean     'Indicates read-only

Private mstrFilter As String      'Filter when outputting data

Private mstrStylesheet As String              'Stylesheet path
Private mbUseStyleSheet As Boolean            'Indicates whether an external stylesheet
                                              'will be used.
Private mbOptional As Boolean                 'Indicates the list does not have to be present in the
                                              'file.
Private mbSortable As Boolean                 'This list can be sorted, is exclusive of ordered
Private mbOrdered As Boolean                  'The list can be ordered
Private mbNoAdd As Boolean                    'Indicates the list can be added to
Private mbInsertable As Boolean               'Items can be inserted to the list, but not necessarily at
                                              'the end
Private mbShowPropertyAttributes As Boolean   'Show attributes of properties in the main page

Private mstrNumberHeader As String            'Header for the order field
Private mstrMoveHeader As String              'Header for the move field
Private mstrOrderHeader As String             'Header for the order
Private mstrEditHeader As String              'Header for edit field
Private mstrInsertHeader As String            'Insert header

Private mstrAttributeTableTitle As String     'Title for the attributes table
Private mstrPropertyTableTitle As String      'Title for the properties table

Private mstrAttributeNameHeader As String     'Attribute name header
Private mstrAttributeValueHeader As String    'Attribute value header

'Button text
Private mstrAddButtonText As String
Private mstrRemoveButtonText As String

'For properties of all tables
Private mstrPopupHeader As String             'header for popups
Private mstrPopupTitle As String              'title for popups
Private mstrPopupText As String               'text for popups

Private mstrCustomPopup As String             'custom popup for the list items

'For the attribute tables for SIMPLE and FLATEXTENDED lists
Private mstrAttributePopupHeader As String    'header for popups
Private mstrAttributePopupTitle As String     'title for popups
Private mstrAttributePopupText As String      'text for popups

Private mcollAttributes As New Collection     'Attributes of the list node
Private mcollProperties As New Collection     'Collection of properties
Private mcollLists As New Collection          'Collection of sub-lists
Private mcollGroups As New Collection         'Collection of sub-groups

Private meListType As FlexListType

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Methods
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub           : GetAttributesFromXML(IXMLDOMNode)                         '
' Description   : From the given schema node, load all the attributes.      '
' Inputs        : The schema node that defines the list.                    '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub GetAttributesFromXML(ByRef objNode As IXMLDOMNode)
  Dim objNodeList As IXMLDOMNodeList  'List of attribute nodes
  Dim objAttributeNode As IXMLDOMNode 'Each attribute node
  Dim intCount As Integer
    
  intCount = 0
  
  'Get the list of attributes
  Set objNodeList = objNode.selectNodes("attribute")
  
  For Each objAttributeNode In objNodeList
   'Add the attribute to the collection
    Call mcollAttributes.Add(LoadAttributeSchemaFromXML(objAttributeNode, mstrID & "Attribute" & intCount))
    intCount = intCount + 1
  Next
  
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub           : GetPropertiesFromXML(IXMLDOMNode)                         '
' Description   : From the given schema node, load all the properties.      '
' Inputs        : The schema node that defines the list.                    '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub GetPropertiesFromXML(ByRef objNode As IXMLDOMNode)
  Dim objNodeList As IXMLDOMNodeList  'List of property nodes
  Dim objPropertyNode As IXMLDOMNode  'Each property node
  Dim intCount As Integer
  Dim i As Integer
  
  intCount = 0
    
  'Get the list of properties
  Set objNodeList = objNode.selectNodes("property")
  
  For Each objPropertyNode In objNodeList
    'Add the property to the collection
    Call mcollProperties.Add(LoadPropertySchemaFromXML(objPropertyNode, mstrID & "Property" & intCount))
    intCount = intCount + 1
  Next
  

  'Update the siblings
  For i = 1 To mcollProperties.Count - 1
    mcollProperties.Item(i).SiblingXPath = mcollProperties.Item(i + 1).XPath
  Next

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub           : GetGroupsFromXML(IXMLDOMNode)                             '
' Description   : From the given schema node, load the groups.              '
' Inputs        : The schema node that defines the page.                    '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub GetGroupsFromXML(ByRef objNode As IXMLDOMNode)
  Dim objNodeList As IXMLDOMNodeList      'List of group nodes
  Dim objGroupNode As IXMLDOMNode         'Each group node
  Dim intCount As Integer
    
  intCount = 0
    
  'Get the list of group nodes
  Set objNodeList = objNode.selectNodes("group")
  
  For Each objGroupNode In objNodeList
    Call mcollGroups.Add(LoadGroupSchemaFromXML(objGroupNode, mstrID & "Group" & intCount))
    intCount = intCount + 1
  Next

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub           : GetListsFromXML(IXMLDOMNode)                              '
' Description   : From the given schema node, load the lists.               '
' Inputs        : The schema node that defines the page.                    '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub GetListsFromXML(ByRef objNode As IXMLDOMNode)
  

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CreateHeaderRow(objXSL)                                   '
' Description   : Create a header for the table that will contain this list.'
' Inputs        : objXSL -- XSL to base the table on                        '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function CreateHeaderRow(ByRef objXSL As DOMDocument30, ByVal strPageXpath As String, ByRef strAction As String)

  Select Case meListType
    Case SIMPLE
      Call CreateListAttributesTable(objXSL, strPageXpath)
      CreateHeaderRow = CreateSimpleHeaderRow(objXSL, strAction)
    Case FLATEXTENDED
      Call CreateListAttributesTable(objXSL, strPageXpath)
      CreateHeaderRow = CreateFlatExtendedHeaderRow(objXSL, strAction)
    Case EXTENDED
      CreateHeaderRow = CreateExtendedHeaderRow(objXSL, strAction)
  End Select

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CreateListAttributesTable(objXSL)                         '
' Description   : Create the attributes table for a list.                   '
' Inputs        : objXSL -- XSL to base the table on                        '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function CreateListAttributesTable(ByRef objXSL As DOMDocument30, ByVal strPageXpath As String)
  Dim objHeaderRow As IXMLDOMNode       'Row for the header
  Dim objHeaderCell As IXMLDOMNode      'Cell data
  Dim objEditHeaderCell As IXMLDOMNode  'Edit Header
  
  Dim objDataRowTemplate As IXMLDOMNode 'Data row template
  Dim objEditOddCell As IXMLDOMNode     'Edit odd
  Dim objEditEvenCell As IXMLDOMNode    'Edit even
  Dim objDataRow As IXMLDOMNode         'Data row
  Dim objOddCell As IXMLDOMNode         'Odd cells
  Dim objEvenCell As IXMLDOMNode        'Even cells
  Dim objCell As IXMLDOMNode            'Actuall cell to add
  Dim objEditCell As IXMLDOMNode        'Edit cell to add
  
  Dim objAttribute As AttributeItem     'Used to make the headers for attributes
  Dim bOdd As Boolean                   'Used for alternating styles
  
  'If there is a stylesheet for this list, do no nothing.
  If mbUseStyleSheet Then
    Exit Function
  Else
    Set objHeaderRow = objXSL.selectSingleNode("//tr[@id='ATTRIBUTE_TABLE_HEADER_ROW']")
    Set objHeaderCell = objXSL.selectSingleNode("//td[@id='ATTRIBUTE_TABLE_HEADER_CELL']")
    Set objEditHeaderCell = objXSL.selectSingleNode("//td[@id='ATTRIBUTE_TABLE_EDIT_HEADER_CELL']")
    
    'Add the edit pencil
    If Not mbReadOnly Then
      Call AddClonedTextCell(objEditHeaderCell, mstrEditHeader)
    End If
    
    'Add the name header
    Call AddClonedTextCell(objHeaderCell, mstrAttributeNameHeader)
    
    'Add the value header
    Call AddClonedTextCell(objHeaderCell, mstrAttributeValueHeader)
    
    'Remove the template header cell
    Call objHeaderCell.parentNode.removeChild(objHeaderCell)
    Call objEditHeaderCell.parentNode.removeChild(objEditHeaderCell)
  
    'Create the data rows
    Set objDataRowTemplate = objXSL.selectSingleNode("//tr[@id='ATTRIBUTE_TABLE_DATA_ROW']")
    
    For Each objAttribute In mcollAttributes
      Set objDataRow = GetClonedNode(objDataRowTemplate, ".", True)
      
      Set objEvenCell = objDataRow.selectSingleNode("//td[@id='ATTRIBUTE_TABLE_DATA_CELL_EVEN']")
      Set objOddCell = objDataRow.selectSingleNode("//td[@id='ATTRIBUTE_TABLE_DATA_CELL_ODD']")
    
      Set objEditEvenCell = objDataRow.selectSingleNode("//td[@id='ATTRIBUTE_TABLE_EDIT_CELL_EVEN']")
      Set objEditOddCell = objDataRow.selectSingleNode("//td[@id='ATTRIBUTE_TABLE_EDIT_CELL_ODD']")
    
      If bOdd Then
        Set objCell = objOddCell
        Set objEditCell = objEditOddCell
      Else
        Set objCell = objEvenCell
        Set objEditCell = objEditEvenCell
      End If
      
      bOdd = Not bOdd
    
      'Loop and create the cells
      'Create the edit cell
      If Not mbReadOnly Then
        Call AddClonedSearchableEvalCell(objEditCell, "EDIT:" & strPageXpath & mstrXPath & "/@" & objAttribute.Name & ":" & objAttribute.ID, "absolutechildNumber(this)")
      End If
      
      'Add the attribute name
      Call AddClonedTextCell(objCell, objAttribute.Text)
      
      'Add the attribute value
        Call AddClonedValueOfCell(objCell, strPageXpath & mstrXPath & "/@" & objAttribute.Name)
      'Call AddClonedValueOfCell(objCell, "./@" & objAttribute.Name)
      
      'Add the cell to the row
      Call objDataRow.appendChild(objCell)
      
      'Remove the template cells
      Call objDataRow.removeChild(objOddCell)
      Call objDataRow.removeChild(objEvenCell)
      Call objDataRow.removeChild(objEditOddCell)
      Call objDataRow.removeChild(objEditEvenCell)
      
      'Add the row to the table
      Call objDataRowTemplate.parentNode.appendChild(objDataRow)
    Next
    
    
    'Remove the template
    Call objDataRowTemplate.parentNode.removeChild(objDataRowTemplate)
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CreateSimpleHeaderRow(objXSL)                             '
' Description   : Create the header row for simple lists.                   '
' Inputs        : objXSL -- XSL to base the table on                        '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function CreateSimpleHeaderRow(ByRef objXSL As DOMDocument30, ByRef strAction As String)
  Dim objHeaderRow As IXMLDOMNode       'Row for the header
  Dim objHeaderCell As IXMLDOMNode      'Cell data
  Dim objEditHeaderCell As IXMLDOMNode  'Edit Cell
  Dim objAttribute As AttributeItem     'Used to make the headers for attributes
  Dim objProperty As Property           'Used for the property headers
    
  'If using a stylesheet, load it for the page
  If mbUseStyleSheet Then
    Call objXSL.Load(mstrStylesheet)
    CreateSimpleHeaderRow = True
  
  'Otherwise, build the stylesheet
  Else
    Set objHeaderRow = objXSL.selectSingleNode("//tr[@id='TABLE_HEADER_ROW']")
    Set objHeaderCell = objHeaderRow.selectSingleNode("//td[@id='TABLE_HEADER_CELL']")
    Set objEditHeaderCell = objHeaderRow.selectSingleNode("//td[@id='TABLE_HEADER_EDIT_CELL']")
    
    'Get the header row
    
    'If an ordered list, add the number and the moveup/down prompt
    If mbOrdered And Not mbReadOnly Then
      Call AddClonedTextCell(objEditHeaderCell, mstrNumberHeader)
      Call AddClonedTextCell(objEditHeaderCell, mstrMoveHeader)
    End If
    
    'if editable
    If Not mbReadOnly Then
      Call AddClonedTextCell(objEditHeaderCell, mstrEditHeader)
      
      'Insert doesn't make sense in an unordered list
      If mbInsertable And mbOrdered Then
        Call AddClonedTextCell(objEditHeaderCell, mstrInsertHeader)
      End If
    End If
    
    'Properties of the list, show the properties and their attributes (if so set)
    For Each objProperty In mcollProperties
      If Not objProperty.Hidden Then
        'Add the cell for the property
        Call AddClonedTextCell(objHeaderCell, objProperty.DisplayName)
        
        'Add any visible attributes
        If mbShowPropertyAttributes Then
          For Each objAttribute In objProperty.Attributes
            If Not objAttribute.Hidden Then
              Call AddClonedTextCell(objHeaderCell, objAttribute.Text)
            End If
          Next
        End If
      End If
    Next
    
    'Remove the Template cell 'cause it's no longer needed
    Call objHeaderCell.parentNode.removeChild(objHeaderCell)
    Call objEditHeaderCell.parentNode.removeChild(objEditHeaderCell)
    CreateSimpleHeaderRow = False
  
  End If
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CreateFlatExtendedHeaderRow(objXSL)                       '
' Description   : Create the header row for flat-extended lists.            '
' Inputs        : objXSL -- XSL to base the table on                        '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function CreateFlatExtendedHeaderRow(ByRef objXSL As DOMDocument30, ByRef strAction As String)
  CreateFlatExtendedHeaderRow = CreateSimpleHeaderRow(objXSL, strAction)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CreateExtendedHeaderRow(objXSL)                           '
' Description   : Create the header row for extended lists.                 '
' Inputs        : objXSL -- XSL to base the table on                        '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function CreateExtendedHeaderRow(ByRef objXSL As DOMDocument30, ByRef strAction As String)
  Dim objHeaderRow As IXMLDOMNode       'Row for the header
  Dim objHeaderCell As IXMLDOMNode      'Cell data
  Dim objEditHeaderCell As IXMLDOMNode  'Edit header cell
  
  Dim objAttributeTable As IXMLDOMNode  'Attribute table
  Dim objAttribute As AttributeItem     'Used to make the headers for attributes
  
  Dim objProperty As Property           'Used for the property headers
  Dim bAttr As Boolean
    
  'If using a stylesheet, load it for the page
  If mbUseStyleSheet Then
    Call objXSL.Load(mstrStylesheet)
    CreateExtendedHeaderRow = True
  
  'Otherwise, build the stylesheet
  Else
    'Remove the attribute table, since it's not needed for extended lists
    Set objAttributeTable = objXSL.selectSingleNode("//table[@id='ATTRIBUTE_TABLE']")
    Call objAttributeTable.parentNode.removeChild(objAttributeTable)
  
    'Get the header row
    Set objHeaderRow = objXSL.selectSingleNode("//tr[@id='TABLE_HEADER_ROW']")
    Set objHeaderCell = objHeaderRow.selectSingleNode("//td[@id='TABLE_HEADER_CELL']")
    Set objEditHeaderCell = objHeaderRow.selectSingleNode("//td[@id='TABLE_HEADER_EDIT_CELL']")
    
        
    'If an ordered list, add the number and the moveup/down prompt
    If strAction <> "REMOVE" Then
      If mbOrdered And Not mbReadOnly Then
        Call AddClonedTextCell(objEditHeaderCell, mstrNumberHeader)
        Call AddClonedTextCell(objEditHeaderCell, mstrMoveHeader)
      End If
    
      'if editable
      If Not mbReadOnly Then
        Call AddClonedTextCell(objEditHeaderCell, mstrEditHeader)
      
        'Insert doesn't make sense in an unordered list
        If mbInsertable And mbOrdered Then
          Call AddClonedTextCell(objEditHeaderCell, mstrInsertHeader)
        End If
      End If
    End If
    

      
    'Properties of the list, show the properties and their attributes (if so set)
    For Each objProperty In mcollProperties
      If Not objProperty.Hidden Then
        'Add the cell for the property
        Call AddClonedTextCell(objHeaderCell, objProperty.DisplayName)
        
        'Add any visible attributes
        If mbShowPropertyAttributes Then
          bAttr = False
          For Each objAttribute In objProperty.Attributes
            If Not objAttribute.Hidden Then
              'Call AddClonedTextCell(objHeaderCell, objAttribute.Text)
              bAttr = True
            End If
          Next
          
          If bAttr Then
            Call AddClonedTextCell(objHeaderCell, "[" & objProperty.DisplayName & " -- Attributes]")
          End If
        End If
      End If
    Next
    
    'Attributes of the list
    'Extended lists will show the attributes like a property in the row
    For Each objAttribute In mcollAttributes
    'If the attribute is visible, show it
      If Not objAttribute.Hidden Then
        Call AddClonedTextCell(objHeaderCell, objAttribute.Text)
      End If
    Next
    
    'Add the remove header
    If strAction = "REMOVE" Then
      Call AddClonedTextCell(objHeaderCell, "[REMOVE_ALL_BUTTON]")
    End If
    
    'Remove the Template cell 'cause it's no longer needed
    Call objHeaderCell.parentNode.removeChild(objHeaderCell)
    Call objEditHeaderCell.parentNode.removeChild(objEditHeaderCell)
    
    CreateExtendedHeaderRow = False
  
  End If
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CreateDataRows(objRowTemplate, strPageXPath)              '
' Description   : Create the data rows for the list.                        '
' Inputs        : objRowTemplate  -- Template for data rows.                '
'               : strPageXPath    -- Xpath for the page                     '
'               : bOdd            -- even or odd for first cell             '
' Outputs       : Even or Odd for next cell                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function CreateDataRows(ByRef objRowTemplate As IXMLDOMNode, _
                               ByRef strPageXpath As String, _
                               ByRef strAction As String)
  
  Select Case meListType
    Case SIMPLE
      CreateDataRows = CreateSimpleDataRows(objRowTemplate, strPageXpath, strAction)
    Case FLATEXTENDED
      CreateDataRows = CreateFlatExtendedDataRows(objRowTemplate, strPageXpath, strAction)
    Case EXTENDED
      CreateDataRows = CreateExtendedDataRows(objRowTemplate, strPageXpath, strAction)
  End Select
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CreateSimpleDataRows(objRowTemplate, strPageXPath)        '
' Description   : Create the data rows for the list.                        '
' Inputs        : objRowTemplate  -- Template for data rows.                '
'               : strPageXPath    -- Xpath for the page                     '
' Outputs       : Even or Odd for next cell                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function CreateSimpleDataRows(ByRef objRowTemplate As IXMLDOMNode, _
                                      ByRef strPageXpath As String, _
                                      ByRef strAction As String) As Boolean
  Dim objRow As IXMLDOMNode               'Cloned rows
  
  Dim objMoveCell As IXMLDOMNode          'Move cell
  Dim objEditCell As IXMLDOMNode          'Edit cell to add
  Dim objCell As IXMLDOMNode              'Cell to add
  
  Dim objForEach As IXMLDOMNode           'For each node
  Dim objSelectNode As IXMLDOMAttribute   'Select attribute for the node
  Dim objOrderByNode As IXMLDOMAttribute
  Dim objXML As New DOMDocument30             'Used to create nodes
  
  Dim objAttribute As AttributeItem       'List/Property attribute
  Dim objProperty As Property             'Properties of the list
  
                               
  'Create the for-each node
  'For extended lists, base it on the property
  Set objForEach = objXML.createNode(NODE_ELEMENT, "xsl:for-each", "http://www.w3.org/TR/WD-xsl")
  Set objSelectNode = objXML.createAttribute("select")
  
  'Simple Lists & Flat Extended Lists
  'Check for a filter
  If Len(mstrFilter) = 0 Then
    objSelectNode.Value = strPageXpath & mstrXPath & "/" & mcollProperties(1).XPath
  Else
    objSelectNode.Value = strPageXpath & mstrXPath & mstrFilter & "/" & mcollProperties(1).XPath
  End If
  
  'TEMP
  Dim strOrderBy
  strOrderBy = ""
  
  Set objOrderByNode = objXML.createAttribute("order-by")
  objOrderByNode.Value = strOrderBy
  
  'Add the select
  Call objForEach.Attributes.setNamedItem(objSelectNode)
  
  If Len(strOrderBy) > 0 Then
    Call objForEach.Attributes.setNamedItem(objOrderByNode)
  End If
  
  'Add the properties
  For Each objProperty In mcollProperties
    If Not objProperty.ReadOnly Then
   
      'Clone the row
      Set objRow = GetClonedNode(objRowTemplate, ".", True)
      
      'Get the even and odd cells
      Set objCell = objRow.selectSingleNode("//td[@id='TABLE_DATA_CELL']")
      Set objEditCell = objRow.selectSingleNode("//td[@id='TABLE_EDIT_CELL']")
      Set objMoveCell = objRow.selectSingleNode("//td[@id='TABLE_MOVE_CELL']")
                               
      'Add the move up / down
      If mbOrdered And Not mbReadOnly Then
        Call AddClonedEvalCell(objEditCell, "childNumber(this)")
        Call AddClonedSearchableEvalCell(objMoveCell, "MOVE:" & strPageXpath & mstrXPath & "/" & objProperty.XPath, "childNumber(this)")
      End If
              
      If Not mbReadOnly Then
        Call AddClonedSearchableEvalCell(objEditCell, "EDIT:" & strPageXpath & mstrXPath & "/" & objProperty.XPath & ":" & mstrID, "absolutechildNumber(this)")
        
        If mbOrdered And mbInsertable Then
          Call AddClonedSearchableEvalCell(objEditCell, "INSERT:" & strPageXpath & mstrXPath & "/" & objProperty.XPath, "absolutechildNumber(this)")
        End If
      End If
      
      
      'Add the property value
      'Call AddClonedValueOfCell(objCell, strPageXPath & mstrXPath & "/" & objProperty.XPath)
      Call AddClonedValueOfCell(objCell, ".")
      
      'Now add the attributes
      If mbShowPropertyAttributes Then
        'Call AddPropertyAttributesToClonedCell(objCell, objProperty.Attributes, strPageXPath & mstrXPath & "/" & objProperty.XPath)
        Call AddPropertyAttributesToClonedCell(objCell, objProperty.Attributes, ".")
      End If
      
      'Remove the template cells from the row
      Call objCell.parentNode.removeChild(objCell)
      Call objEditCell.parentNode.removeChild(objEditCell)
      Call objMoveCell.parentNode.removeChild(objMoveCell)
      
      
      'Add the row to the xsl
      Call objForEach.appendChild(objRow)
                               
    End If
  
  Next
  
  'Add the for-each node
  Call objRowTemplate.parentNode.appendChild(objForEach)
    
  'Remove the template row
  Call objRowTemplate.parentNode.removeChild(objRowTemplate)
  
  
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CreateFlatExtendedDataRows(objRowTemplate, strPageXPath)  '
' Description   : Create the data rows for the list.                        '
' Inputs        : objRowTemplate  -- Template for data rows.                '
'               : strPageXPath    -- Xpath for the page                     '
' Outputs       : Even or Odd for next cell                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function CreateFlatExtendedDataRows(ByRef objRowTemplate As IXMLDOMNode, _
                                            ByRef strPageXpath As String, _
                                            ByRef strAction As String) As Boolean
  Dim objRow As IXMLDOMNode               'Cloned rows
  
  Dim objCell As IXMLDOMNode              'Cell to add
  Dim objEditCell As IXMLDOMNode          'Edit Cell to add
  Dim objMoveCell As IXMLDOMNode          'Move cell
  
  Dim objMoveLinkNode As IXMLDOMNode
  
  Dim objForEach As IXMLDOMNode           'For each node
  Dim objSelectNode As IXMLDOMAttribute   'Select attribute for the node
  Dim objOrderByNode As IXMLDOMAttribute
  Dim objXML As New DOMDocument30             'Used to create nodes
  
  Dim objAttribute As AttributeItem       'List/Property attribute
  Dim objProperty As Property             'Properties of the list
  
  
                               
  'Create the for-each node
  'For extended lists, base it on the property
  Set objForEach = objXML.createNode(NODE_ELEMENT, "xsl:for-each", "http://www.w3.org/TR/WD-xsl")
  Set objSelectNode = objXML.createAttribute("select")
  
  'Simple Lists & Flat Extended Lists
  'Check for a filter
  If Len(mstrFilter) = 0 Then
    objSelectNode.Value = strPageXpath & mstrXPath & "/" & mcollProperties(1).XPath
  Else
    objSelectNode.Value = strPageXpath & mstrXPath & mstrFilter & "/" & mcollProperties(1).XPath
  End If
  
  
  Dim strOrderBy
  strOrderBy = ""
  
  Set objOrderByNode = objXML.createAttribute("order-by")
  objOrderByNode.Value = strOrderBy
    
  
  'Add the select
  Call objForEach.Attributes.setNamedItem(objSelectNode)
  
  If Len(strOrderBy) > 0 Then
    Call objForEach.Attributes.setNamedItem(objOrderByNode)
  End If
                               
  'Add the properties
  'Clone the row
  Set objRow = GetClonedNode(objRowTemplate, ".", True)
  
  'Get the even and odd cells
  Set objCell = objRow.selectSingleNode("//td[@id='TABLE_DATA_CELL']")
  Set objEditCell = objRow.selectSingleNode("//td[@id='TABLE_EDIT_CELL']")
  Set objMoveCell = objRow.selectSingleNode("//td[@id='TABLE_MOVE_CELL']")
  
  'Add the move up / down
  If strAction <> "REMOVE" Then
    If mbOrdered And Not mbReadOnly Then
      Call AddClonedEvalCell(objEditCell, "childNumber(this)")
    
      Set objMoveLinkNode = objMoveCell.selectSingleNode("//a[@id='MOVE_UP_HREF']")
      Call AddClonedSearchableEvalAttribute(objMoveLinkNode, "MOVEUP:" & strPageXpath & mstrXPath, "href", "childNumber(this)")
      Call objMoveLinkNode.parentNode.removeChild(objMoveLinkNode)
    
      Set objMoveLinkNode = objMoveCell.selectSingleNode("//a[@id='MOVE_DOWN_HREF']")
      Call AddClonedSearchableEvalAttribute(objMoveLinkNode, "MOVEDOWN:" & strPageXpath & mstrXPath, "href", "childNumber(this)")
      Call objMoveLinkNode.parentNode.removeChild(objMoveLinkNode)
    
      Call objRow.appendChild(GetClonedNode(objMoveCell, ".", True))
    End If
            
    If Not mbReadOnly Then
      Call AddClonedSearchableEvalCell(objEditCell, "EDIT:" & strPageXpath & mstrXPath & ":" & mstrID, "childNumber(this)")
    
      If mbOrdered And mbInsertable Then
        Call AddClonedSearchableEvalCell(objEditCell, "INSERT:" & strPageXpath & mstrXPath, "childNumber(this)")
      End If
    End If
  End If
  
  'If strAction <> "REMOVE" Then
  'DO SOME OF THESE NEED TO BE absoluteChildNumber?
    'Add the move up / down
  '  If mbOrdered And Not mbReadOnly Then
  '    Call AddClonedEvalCell(objEditCell, "childNumber(this)")
  '    Call AddClonedSearchableEvalCell(objEditCell, "MOVE:" & strPageXpath & mstrXPath, "childNumber(this)")
  '  End If
            
 '   If Not mbReadOnly Then
 '     Call AddClonedSearchableEvalCell(objMoveCell, "EDIT:" & strPageXpath & mstrXPath & ":" & mstrID, "childNumber(this)")
    
 '     If mbOrdered And mbInsertable Then
'        Call AddClonedSearchableEvalCell(objEditCell, "INSERT:" & strPageXpath & mstrXPath, "childNumber(this)")
 '     End If
 '   End If
  
 ' End If
  
  For Each objProperty In mcollProperties
    If Not objProperty.Hidden Then
      
      'Add the property value
      'Get next with name is defined in the template
      Call AddClonedEvalCell(objCell, "GetNextWithName('" & objProperty.XPath & "')")
      
      'Now add the attributes
      If mbShowPropertyAttributes Then
        Call AddPropertyAttributesToClonedCell(objCell, objProperty.Attributes, ".")
      End If
      
      'Add the row to the xsl
      'Call objRow.appendChild(objCell)
                               
    End If
    
  Next
  
  If strAction = "REMOVE" Then
    Call AddClonedSearchableEvalCell(objEditCell, "REMOVE:" & strPageXpath & mstrXPath & ":" & mstrID, "childNumber(this)")
  End If
  
  'Remove the template cells from the row
  Call objCell.parentNode.removeChild(objCell)
  Call objEditCell.parentNode.removeChild(objEditCell)
  Call objMoveCell.parentNode.removeChild(objMoveCell)
  
  
  'Add the for-each node
  Call objForEach.appendChild(objRow)
  Call objRowTemplate.parentNode.appendChild(objForEach)
    
  'Remove the template row
  Call objRowTemplate.parentNode.removeChild(objRowTemplate)
  
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CreateExtendedDataRows(objRowTemplate, strPageXPath)      '
' Description   : Create the data rows for the list.                        '
' Inputs        : objRowTemplate  -- Template for data rows.                '
'               : strPageXPath    -- Xpath for the page                     '
' Outputs       : Even or Odd for next cell                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function CreateExtendedDataRows(ByRef objRowTemplate As IXMLDOMNode, _
                                            ByRef strPageXpath As String, _
                                            ByRef strAction As String) As Boolean
  Dim objRow As IXMLDOMNode               'Cloned rows
  
  Dim objCell As IXMLDOMNode              'Cell to add
  Dim objEditCell As IXMLDOMNode          'Edit cell to add
  Dim objMoveCell As IXMLDOMNode          'Move cell to add
  
  Dim objMoveLinkNode As IXMLDOMNode
  
  Dim objForEach As IXMLDOMNode           'For each node
  Dim objSelectNode As IXMLDOMAttribute   'Select attribute for the node
  Dim objXML As New DOMDocument30             'Used to create nodes
    
  Dim objAttribute As AttributeItem       'List/Property attribute
  Dim objProperty As Property             'Properties of the list
  
                               
  'Create the for-each node
  'For extended lists, base it on the property
  Set objForEach = objXML.createNode(NODE_ELEMENT, "xsl:for-each", "http://www.w3.org/TR/WD-xsl")
  Set objSelectNode = objXML.createAttribute("select")
  
  'Simple Lists & Flat Extended Lists
  If Len(mstrFilter) = 0 Then
    objSelectNode.Value = strPageXpath & mstrXPath
  Else
    objSelectNode.Value = strPageXpath & mstrXPath & mstrFilter
  End If
  
  'Add the select
  Call objForEach.Attributes.setNamedItem(objSelectNode)
                               
  'Add the properties
  'Clone the row
  Set objRow = GetClonedNode(objRowTemplate, ".", True)
  
  'Get the even and odd cells
  Set objEditCell = objRow.selectSingleNode("//td[@id='TABLE_EDIT_CELL']")
  Set objCell = objRow.selectSingleNode("//td[@id='TABLE_DATA_CELL']")
  Set objMoveCell = objRow.selectSingleNode("//td[@id='TABLE_MOVE_CELL']")
    
  'Add the move up / down
  If strAction <> "REMOVE" Then
    If mbOrdered And Not mbReadOnly Then
      Call AddClonedEvalCell(objEditCell, "childNumber(this)")
    
      Set objMoveLinkNode = objMoveCell.selectSingleNode("//a[@id='MOVE_UP_HREF']")
      Call AddClonedSearchableEvalAttribute(objMoveLinkNode, "MOVEUP:" & strPageXpath & mstrXPath, "href", "childNumber(this)")
      Call objMoveLinkNode.parentNode.removeChild(objMoveLinkNode)
    
      Set objMoveLinkNode = objMoveCell.selectSingleNode("//a[@id='MOVE_DOWN_HREF']")
      Call AddClonedSearchableEvalAttribute(objMoveLinkNode, "MOVEDOWN:" & strPageXpath & mstrXPath, "href", "childNumber(this)")
      Call objMoveLinkNode.parentNode.removeChild(objMoveLinkNode)
    
      Call objRow.appendChild(GetClonedNode(objMoveCell, ".", True))
    End If
            
    If Not mbReadOnly Then
      Call AddClonedSearchableEvalCell(objEditCell, "EDIT:" & strPageXpath & mstrXPath & ":" & mstrID, "childNumber(this)")
    
      If mbOrdered And mbInsertable Then
        Call AddClonedSearchableEvalCell(objEditCell, "INSERT:" & strPageXpath & mstrXPath, "childNumber(this)")
      End If
    End If
  End If
  
  
  For Each objProperty In mcollProperties
    If Not objProperty.Hidden Then
      
      'Add the property value
      'Get next with name is defined in the template
      Call AddClonedValueOfCell(objCell, objProperty.XPath)
      
      'Now add the attributes
      If mbShowPropertyAttributes Then
        Call AddPropertyAttributesToClonedCell(objCell, objProperty.Attributes, objProperty.XPath)
      End If
      
      'Add the row to the xsl
      'Call objRow.appendChild(objCell)
                               
    End If
    
  Next
  
        
  'Add the attributes
  For Each objAttribute In mcollAttributes
    If Not objAttribute.Hidden Then
      Call AddClonedValueOfCell(objCell, "./@" & objAttribute.Name)
    End If
  Next
  
  'Add a field for remove
  If strAction = "REMOVE" Then
    Call AddClonedSearchableEvalCell(objEditCell, "REMOVE:" & strPageXpath & mstrXPath & ":" & mstrID, "childNumber(this)")
  End If
  
  
  'Remove the template cells from the row
  Call objEditCell.parentNode.removeChild(objEditCell)
  Call objCell.parentNode.removeChild(objCell)
  Call objMoveCell.parentNode.removeChild(objMoveCell)
  
  'Add the for-each node
  Call objForEach.appendChild(objRow)
  Call objRowTemplate.parentNode.appendChild(objForEach)
    
  'Remove the template row
  Call objRowTemplate.parentNode.removeChild(objRowTemplate)
  
  End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : FindMatchingObjectById(strID)                             '
' Description   : Find the matching object based on an id, rather than an   '
'               : xpath.                                                    '
' Inputs        : strID -- ID to find.                                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function FindMatchingObjectByID(ByRef strID As String) As Object
  
  'Search through the itmes
  Dim objProperty As Property
  Dim objAttribute As AttributeItem
  
  'Check to see if I'm the object to find
  If strID = mstrID Then
    Set FindMatchingObjectByID = Me
    Exit Function
  End If
  
  'Search the attributes
  For Each objAttribute In mcollAttributes
    If strID = objAttribute.ID Then
      Set FindMatchingObjectByID = objAttribute
      Exit Function
    End If
  Next
  
  'Search the properties
  For Each objProperty In mcollProperties
    'Check the property
    If strID = objProperty.ID Then
      Set FindMatchingObjectByID = Me
      Exit Function
    End If
    
    'Check attributes of the property
    For Each objAttribute In objProperty.Attributes
      If strID = objAttribute.ID Then
        Set FindMatchingObjectByID = Me
        Exit Function
      End If
    Next
  Next

  Set FindMatchingObjectByID = Nothing

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : FindMatchingObject(strXPath)                              '
' Description   : Find an object that matches the xpath.                    '
' Inputs        : strXPath -- Xpath to search for.                          '
'               : strPageXPath -- Xpath of the page
' Outputs       : object                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function FindMatchingObject(ByRef strXPath As String, ByRef strPageXpath) As Object
  'Search through the itmes
  Dim objProperty As Property
  Dim objAttribute As AttributeItem
  
  'Check to see if I'm the object to find
  If strXPath = strPageXpath & mstrXPath Then
    Set FindMatchingObject = Me
    Exit Function
  End If
  
  'Search the attributes
  For Each objAttribute In mcollAttributes
    If strPageXpath & mstrXPath & "/@" & objAttribute.Name = strXPath Then
      Set FindMatchingObject = objAttribute
      Exit Function
    End If
  Next
  
  'Search the properties
  For Each objProperty In mcollProperties
    'Check the property
    If strPageXpath & mstrXPath & "/" & objProperty.XPath = strXPath Then
      'Set FindMatchingObject = objProperty
      Set FindMatchingObject = Me
      Exit Function
    End If
    
    'Check attributes of the property
    For Each objAttribute In objProperty.Attributes
      If strPageXpath & mstrXPath & "/" & objProperty.XPath & "/@" & objAttribute.Name = strXPath Then
        'Set FindMatchingObject = objAttribute
        Set FindMatchingObject = Me
        Exit Function
      End If
    Next
  Next

  Set FindMatchingObject = Nothing

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : RenderGrid(objListXSL, strPageXPath)                      '
' Description   : Modify the passed in XSL to render the passed in list.    '
' Inputs        : objListXSL   --  List xsl objectf                         '
'               : strPageXPath --  Base xpath of the calling page           '
' Outputs       : none.                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function RenderGrid(ByRef objListXSL As DOMDocument30, _
                           ByRef strPageXpath As String, _
                           ByRef strAction As String)
  Dim objNode As IXMLDOMNode
  Dim objOnClickNode As IXMLDOMAttribute
                            
  'Create the header
  If Not CreateHeaderRow(objListXSL, strPageXpath, strAction) Then
    Call CreateDataRows(objListXSL.selectSingleNode("//tr[@id='TABLE_DATA_ROW']"), _
                        strPageXpath, _
                        strAction)
    
    'Get rid of unnecessary buttons
    If strAction = "REMOVE" Then
      'Remove the ADD button
      Set objNode = objListXSL.selectSingleNode("//button[@id='LIST_ADD_BUTTON']")
      Call objNode.parentNode.removeChild(objNode)
      
      'Remove the REMOVE Button
      Set objNode = objListXSL.selectSingleNode("//button[@id='LIST_REMOVE_BUTTON']")
      Call objNode.parentNode.removeChild(objNode)
    
    Else
      'Get rid of the OK and cancel buttons
      Set objNode = objListXSL.selectSingleNode("//button[@id='LIST_OK_BUTTON']")
      Call objNode.parentNode.removeChild(objNode)
      
      Set objNode = objListXSL.selectSingleNode("//button[@id='LIST_CANCEL_BUTTON']")
      Call objNode.parentNode.removeChild(objNode)
      
      'Add/remove buttons
      Set objNode = objListXSL.selectSingleNode("//button[@id='LIST_ADD_BUTTON']")
    
      If mbNoAdd Then
        Call objNode.parentNode.removeChild(objNode)
      Else
        Set objOnClickNode = objNode.Attributes.getNamedItem("onClick")
        
        If Len(mstrCustomPopup) > 0 Then
          objOnClickNode.Value = "javascript:OpenDialogWindow('" & mstrCustomPopup & "?Action=Add" & Replace("&XPath=" & strPageXpath & mstrXPath & "&ID=" & mstrID, "'", "\'") & "', '');"
        Else
          objOnClickNode.Value = "javascript:OpenDialogWindow('MTFleXMLPopup.asp?Action=Add" & Replace("&XPath=" & strPageXpath & mstrXPath & "&ID=" & mstrID, "'", "\'") & "', '');"
        End If
      End If
    
      'Remove Node
      Set objNode = objListXSL.selectSingleNode("//button[@id='LIST_REMOVE_BUTTON']")
    
      If mbNoAdd Then
        Call objNode.parentNode.removeChild(objNode)
      Else
        Set objOnClickNode = objNode.Attributes.getNamedItem("onClick")
        objOnClickNode.Value = "[LIST_REMOVE_HREF]"
      End If
    End If
    
    
  End If
                           
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : RenderPopup(objXSLNode, objXMLNode, strExtra)             '
' Description   : Render this attribute's part of a popup                   '
' Inputs        : objXSLNode -- XSL for the popup                           '
'               : objXMLNode -- relevant XML node                           '
'               : strExtra   -- extra data for the input name               '
' Outputs       : html for the popup                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function RenderPopup(ByRef objXSLNode As IXMLDOMNode, _
                            ByRef objXMLNode As IXMLDOMNode, _
                            ByRef strBaseXpath As String, _
                            ByRef strExtra As String, _
                            ByRef strAction As String, _
                            ByRef intIndex As Integer) As String
  
  Dim objProperty As Property         'property item
  Dim objAttribute As AttributeItem   'Attribute of list/property
  Dim objXMLDoc As New DOMDocument30
  Dim objXSL As IXMLDOMNode           'XSL to operate on
  Dim objNode As IXMLDOMNode          'Node to operate on
  Dim objNodeList As IXMLDOMNodeList  'Nodelist
    
  Dim strXPath As String              'XPath to set the xsl template match
  Dim strHTML As String               'HTML for the node
  
  If meListType = SIMPLE Then
    Set objProperty = mcollProperties(1)
    
    strXPath = strBaseXpath & mstrXPath
    
    Set objXSL = GetClonedNode(objXSLNode, ".", True)
    
    Call objProperty.RenderPopup(objXSL, objXMLNode, ":" & objProperty.XPath, strAction, True)
    Call SetMatch(strXPath & "/" & objProperty.XPath, objXSL)
    
    strHTML = objXMLNode.transformNode(objXSL)
    
        
  ElseIf meListType = FLATEXTENDED Then
   For Each objProperty In mcollProperties
      strXPath = strBaseXpath & mstrXPath & "/" & objProperty.XPath
      
      Set objNodeList = objXMLNode.selectNodes(strXPath)
      Set objNode = objNodeList.Item(intIndex - 1)
      
      Set objXSL = GetClonedNode(objXSLNode, ".", True)
      
      Call objProperty.RenderPopup(objXSL, objNode, ":" & objProperty.XPath, strAction, True)
      
      If strAction <> "ADD" Then
        Call SetMatch(strXPath, objXSL)
      End If
              
      strHTML = strHTML & objNode.transformNode(objXSL)
    Next
    
  ElseIf meListType = EXTENDED Then
    strXPath = strBaseXpath & mstrXPath
          
    'Add the properties
    For Each objProperty In mcollProperties
      'If adding, then build the template node
      If strAction = "ADD" Then
        Set objNode = objXMLDoc.createNode(NODE_ELEMENT, objProperty.XPath, "")
        Call objXMLNode.appendChild(objNode)
      End If

      If Not objProperty.Hidden Then
      
        Set objXSL = GetClonedNode(objXSLNode, ".", True)
        'Set objNode = objXMLNode.selectSingleNode(objProperty.XPath)
              
        If CheckVisible(objXMLNode, objProperty, strAction) Or Not objProperty.IsOptional Then
          Call CheckOptions(objXMLNode, objProperty)
          Call objProperty.RenderPopup(objXSL, objXMLNode, ":" & objProperty.XPath, strAction)
                      
          If strAction <> "ADD" Then
            Call SetMatch(strXPath, objXSL)
          End If
              
          strHTML = strHTML & objXMLNode.transformNode(objXSL)
        Else
          objProperty.OptionOverrideFlag = False
        End If
      End If
    Next
    
    'Add the attributes
    For Each objAttribute In mcollAttributes
      'If Not objAttribute.Hidden Then
        If Not objAttribute.Hidden And CheckVisible(objXMLNode, objAttribute, strAction) Then
                
        Set objXSL = GetClonedNode(objXSLNode, ".", True)
        'Set objNode = objXMLNode.selectSingleNode("@" & objAttribute.Name)
        
        Call objAttribute.RenderPopup(objXSL, objXMLNode, ":" & objAttribute.Name, strAction)
        
        If strAction <> "ADD" Then
          Call SetMatch(strXPath, objXSL)
        End If
            
        strHTML = strHTML & objXMLNode.transformNode(objXSL)
      End If
    Next
    
  End If
  
  RenderPopup = strHTML
  
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Properties                                                                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Title
Public Property Get Title() As String
  Let Title = mstrTitle
End Property

Public Property Let Title(ByVal strTitle As String)
  Let mstrTitle = strTitle
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' XPath
Public Property Get XPath() As String
  Let XPath = mstrXPath
End Property
                          
Public Property Let XPath(ByVal strXPath As String)
  Let mstrXPath = strXPath
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Text
Public Property Get Text() As String
  Let Text = mstrText
End Property

Public Property Let Text(ByVal strText As String)
  Let mstrText = strText
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ReadOnly
Public Property Get ReadOnly() As Boolean
  Let ReadOnly = mbReadOnly
End Property

Public Property Let ReadOnly(ByVal bReadOnly As Boolean)
  Let mbReadOnly = bReadOnly
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Use stylesheet
Public Property Let UseStyleSheet(ByVal bUseStyleSheet As Boolean)
  Let mbUseStyleSheet = bUseStyleSheet
End Property

Public Property Get UseStyleSheet() As Boolean
  Let UseStyleSheet = mbUseStyleSheet
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Stylesheet
Public Property Let StyleSheet(ByVal strStyleSheet As String)
  Let mstrStylesheet = strStyleSheet
End Property

Public Property Get StyleSheet() As String
  Let StyleSheet = mstrStylesheet
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Properties
Public Property Get Properties() As Collection
  Set Properties = mcollProperties
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Attributes
Public Property Get Attributes() As Collection
  Set Attributes = mcollAttributes
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Groups
Public Property Get Groups() As Collection
  Set Groups = mcollGroups
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Lists
Public Property Get Lists() As Collection
  Set Lists = mcollLists
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Optional
Public Property Let IsOptional(ByVal bOptional As Boolean)
  Let mbOptional = bOptional
End Property

Public Property Get IsOptional() As Boolean
  Let IsOptional = mbOptional
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' List Type
Public Property Let ListType(ByVal eListType As FlexListType)
  Let meListType = eListType
End Property

Public Property Get ListType() As FlexListType
  Let ListType = meListType
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sortable
Public Property Let Sortable(ByVal bSortable As Boolean)
  Let mbSortable = bSortable
End Property

Public Property Get Sortable() As Boolean
  Let Sortable = mbSortable
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Ordered
Public Property Let Ordered(ByVal bOrdered As Boolean)
  Let mbOrdered = bOrdered
End Property

Public Property Get Ordered() As Boolean
  Let Ordered = mbOrdered
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' NotExpandable
Public Property Let NotExpandable(ByVal bExpandable As Boolean)
  Let mbNoAdd = bExpandable
End Property

Public Property Get NotExpandable() As Boolean
  Let NotExpandable = mbNoAdd
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Insertable
Public Property Let Insertable(ByVal bInsertable As Boolean)
  Let mbInsertable = bInsertable
End Property

Public Property Get Insertable() As Boolean
  Let Insertable = mbInsertable
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' NumberHeader
Public Property Let NumberHeader(ByVal strNumberHeader As String)
  Let mstrNumberHeader = strNumberHeader
End Property

Public Property Get NumberHeader() As String
  Let NumberHeader = mstrNumberHeader
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' MoveHeader
Public Property Let MoveHeader(ByVal strMoveHeader As String)
  Let mstrMoveHeader = strMoveHeader
End Property

Public Property Get MoveHeader() As String
  Let MoveHeader = mstrMoveHeader
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' EditHeader
Public Property Let EditHeader(ByVal strEditHeader As String)
  Let mstrEditHeader = strEditHeader
End Property

Public Property Get EditHeader() As String
  Let EditHeader = mstrEditHeader
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' InsertHeader
Public Property Let InsertHeader(ByVal strInsertHeader As String)
  Let mstrInsertHeader = strInsertHeader
End Property

Public Property Get InsertHeader() As String
  Let InsertHeader = mstrInsertHeader
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ShowAttributesInGrid
Public Property Let ShowAttributesInGrid(ByVal bShowPropertyAttributes As Boolean)
  Let mbShowPropertyAttributes = bShowPropertyAttributes
End Property

Public Property Get ShowAttributesInGrid() As Boolean
  Let ShowAttributesInGrid = mbShowPropertyAttributes
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' AttributeNameHeader
Public Property Let AttributeNameHeader(ByVal strAttributeNameHeader As String)
  Let mstrAttributeNameHeader = strAttributeNameHeader
End Property

Public Property Get AttributeNameHeader() As String
  Let AttributeNameHeader = mstrAttributeNameHeader
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' AttributeValueHeader
Public Property Let AttributeValueHeader(ByVal strAttributeValueHeader As String)
  Let mstrAttributeValueHeader = strAttributeValueHeader
End Property

Public Property Get AttributeValueHeader() As String
  Let AttributeValueHeader = mstrAttributeValueHeader
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' AttributeTableTitle
Public Property Let AttributeTableTitle(ByVal strAttributeTableTitle As String)
  Let mstrAttributeTableTitle = strAttributeTableTitle
End Property

Public Property Get AttributeTableTitle() As String
  Let AttributeTableTitle = mstrAttributeTableTitle
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PropertyTableTitle
Public Property Let PropertyTableTitle(ByVal strPropertyTableTitle As String)
  Let mstrPropertyTableTitle = strPropertyTableTitle
End Property

Public Property Get PropertyTableTitle() As String
  Let PropertyTableTitle = mstrPropertyTableTitle
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Popup Header
Public Property Get PopupHeader() As String
  Let PopupHeader = mstrPopupHeader
End Property

Public Property Let PopupHeader(ByVal strPopupHeader As String)
  Let mstrPopupHeader = strPopupHeader
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Popup Title
Public Property Get PopupTitle() As String
  Let PopupTitle = mstrPopupTitle
End Property

Public Property Let PopupTitle(ByVal strPopupTitle As String)
  Let mstrPopupTitle = strPopupTitle
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Popup Text
Public Property Get PopupText() As String
  Let PopupText = mstrPopupText
End Property

Public Property Let PopupText(ByVal strPopupText As String)
  Let mstrPopupText = strPopupText
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Popup Header
Public Property Get AttributePopupHeader() As String
  Let AttributePopupHeader = mstrAttributePopupHeader
End Property

Public Property Let AttributePopupHeader(ByVal strAttributePopupHeader As String)
  Let mstrAttributePopupHeader = strAttributePopupHeader
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Popup Title
Public Property Get AttributePopupTitle() As String
  Let AttributePopupTitle = mstrAttributePopupTitle
End Property

Public Property Let AttributePopupTitle(ByVal strAttributePopupTitle As String)
  Let mstrAttributePopupTitle = strAttributePopupTitle
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Popup Text
Public Property Get AttributePopupText() As String
  Let AttributePopupText = mstrAttributePopupText
End Property

Public Property Let AttributePopupText(ByVal strAttributePopupText As String)
  Let mstrAttributePopupText = strAttributePopupText
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Add Button Text
Public Property Get AddButtonText() As String
  Let AddButtonText = mstrAddButtonText
End Property

Public Property Let AddButtonText(ByVal strAddButtonText As String)
  Let mstrAddButtonText = strAddButtonText
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Remove Button Text
Public Property Get RemoveButtonText() As String
  Let RemoveButtonText = mstrRemoveButtonText
End Property

Public Property Let RemoveButtonText(ByVal strRemoveButtonText As String)
  Let mstrRemoveButtonText = strRemoveButtonText
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ID
Public Property Get ID() As String
  Let ID = mstrID
End Property

Public Property Let ID(ByVal strID As String)
  Let mstrID = strID
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Filter
Public Property Let Filter(ByVal strFilter As String)
  Let mstrFilter = strFilter
End Property

Public Property Get Filter() As String
  Let Filter = mstrFilter
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'CustomPopup
Public Property Let CustomPopup(ByVal strCustomPopup As String)
  Let mstrCustomPopup = strCustomPopup
End Property

Public Property Get CustomPopup() As String
  Let CustomPopup = mstrCustomPopup
End Property
