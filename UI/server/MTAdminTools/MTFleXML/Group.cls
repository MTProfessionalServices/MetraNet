VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Group"
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
Option Explicit
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Group.cls -- Contains schema information for a group, which is a set of   '
'              Editable properties "grouped" together.                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Private mstrXPath As String       'xpath used to locate the node, can be absolute or
                                  'relative to the parent page.
Private mstrTitle As String       'The title of the group
Private mstrText As String            'The text prompt for the group

Dim mstrID As String

Private mstrEditHeader As String      'String to display in the editor
Private mstrPropertyHeader As String  'Header to display for properties
Private mstrValueHeader As String     'Header for property values
Private mstrAttributeHeader As String 'Header to display for attributes

Private mbReadOnly As Boolean         'Indicates read-only
Private mbShowPropertyAttributes      'Indicates whether or not to show property attributes
                                      'in the grid or not.

Private mbNoPopups As Boolean         'Indicates if popups should not be used to edit

Private mstrStylesheet As String              'Stylesheet path
Private mbUseStyleSheet As Boolean            'Indicates whether an external stylesheet
                                              'will be used.
Private mbOptional As Boolean                 'Indicates the group need not be present in the
                                              'file.
Private mcollAttributes As New Collection     'Attributes of the group node
Private mcollProperties As New Collection     'Collection of properties
Private mcollLists As New Collection          'Collection of sub-lists
Private mcollGroups As New Collection         'Collection of sub-groups

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Methods
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub           : GetAttributesFromXML(IXMLDOMNode)                         '
' Description   : From the given schema node, load all the attributes.      '
' Inputs        : The schema node that defines the group.                   '
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
' Inputs        : The schema node that defines the group.                   '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub GetPropertiesFromXML(ByRef objNode As IXMLDOMNode)
  Dim objNodeList As IXMLDOMNodeList  'List of property nodes
  Dim objPropertyNode As IXMLDOMNode  'Each property node
  Dim strNextSibling As String        'siblings
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
  Dim objNodeList As IXMLDOMNodeList      'list of list nodes
  Dim objListNode As IXMLDOMNode          'Each list node
  Dim intCount As Integer
  
  intCount = 0
    
  'Get the list of list nodes
  Set objNodeList = objNode.selectNodes("list")
  
  For Each objListNode In objNodeList
    Call mcollLists.Add(LoadListSchemaFromXML(objListNode, mstrID & "List" & intCount))
    intCount = intCount + 1
  Next

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : CreateGroupHeaderRow(objXSL)                                '
' Description : Create the header row for the group.                        '
' Inputs      : objXSL  -- XSL for the group                                '
' Outputs     : true if using custom stylesheet                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function CreateHeaderRow(ByRef objXSL As DOMDocument30) As Boolean
  Dim objHeaderRow As IXMLDOMNode     'Header template row
  Dim objHeaderCell As IXMLDOMNode    'Cells in the header row
  Dim objEditHeaderCell As IXMLDOMNode
  
  'If using a stylesheet, load that
  If mbUseStyleSheet Then
    Call objXSL.Load(mstrStylesheet)
    CreateHeaderRow = True
  'Otherwise, build up the style sheet from the stock version passed in
  Else
    Set objHeaderRow = objXSL.selectSingleNode("//tr[@id='TABLE_HEADER_ROW']")
    Set objHeaderCell = objHeaderRow.selectSingleNode("//td[@id='TABLE_HEADER_CELL']")
    Set objEditHeaderCell = objHeaderRow.selectSingleNode("//td[@id='TABLE_EDIT_HEADER_CELL']")
    
    'if the group is not read-only, add the edit column
    If Not mbReadOnly Then
      Call AddClonedTextCell(objEditHeaderCell, mstrEditHeader)
    End If
    
    'Add the properties cell
    Call AddClonedTextCell(objHeaderCell, mstrPropertyHeader)
    
    'Add the values cell
    Call AddClonedTextCell(objHeaderCell, mstrValueHeader)
    
    If mbShowPropertyAttributes Then
      Call AddClonedTextCell(objHeaderCell, mstrAttributeHeader)
    End If
  
    'Remove the Template cell 'cause it's no longer needed
    Call objHeaderCell.parentNode.removeChild(objHeaderCell)
    Call objEditHeaderCell.parentNode.removeChild(objEditHeaderCell)
  
    CreateHeaderRow = False
  End If
                                      
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CreateDataRows(objRowTemplate, strPageXPath)              '
' Description   : Create the data rows for the group.                       '
' Inputs        : objRowTemplate  -- Template for data rows.                '
'               : strPageXPath    -- Xpath for the page                     '
' Outputs       : Even or Odd for next cell                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function CreateDataRows(ByRef objRowTemplate As IXMLDOMNode, _
                               ByRef strPageXpath As String) As Boolean
  
  Dim objAttribute As AttributeItem   'Need row for every attribute of the group
  Dim objProperty As Property         'Need a row for every property
  Dim objRow As IXMLDOMNode           'Row to add
  Dim objCell As IXMLDOMNode          'Current cell
  Dim objEditCell As IXMLDOMNode
  Dim objEvenCell As IXMLDOMNode      'Even row cell
  Dim objOddCell As IXMLDOMNode       'Odd row cell
  Dim objEditEvenCell As IXMLDOMNode      'Even row cell
  Dim objEditOddCell As IXMLDOMNode       'Odd row cell
  
  Dim bOdd
  
  bOdd = True
  
  'Add rows for the attributes
  For Each objAttribute In mcollAttributes
    If Not objAttribute.Hidden Then
      
      'Clone the row
      Set objRow = GetClonedNode(objRowTemplate, ".", True)
      
      'Get the even and odd cells
      Set objEvenCell = objRow.selectSingleNode("//td[@id='TABLE_DATA_CELL_EVEN']")
      Set objOddCell = objRow.selectSingleNode("//td[@id='TABLE_DATA_CELL_ODD']")
    
      Set objEditEvenCell = objRow.selectSingleNode("//td[@id='TABLE_EDIT_CELL_EVEN']")
      Set objEditOddCell = objRow.selectSingleNode("//td[@id='TABLE_EDIT_CELL_ODD']")
      
      'Get the correct cell for the even/odd row
      If bOdd Then
        Set objCell = objOddCell
        Set objEditCell = objEditOddCell
      Else
        Set objCell = objEvenCell
        Set objEditCell = objEditEvenCell
      End If
      
      bOdd = Not bOdd
            
      'Add the edit if the row is not read only
      'If the group is read-only, don't add any cells
      If Not mbReadOnly Then
        If objAttribute.ReadOnly Then
          Call AddClonedTextCell(objEditCell, "")
        Else
          Call AddClonedSearchableEvalCell(objEditCell, "EDIT:" & strPageXpath & mstrXPath & "/@" & objAttribute.Name & ":" & objAttribute.ID, "absolutechildNumber(this)")
        End If
      End If
      
      'Add the attribute name
      Call AddClonedTextCell(objCell, objAttribute.Text)
      
      'Add the attribute value
      Call AddClonedValueOfCell(objCell, strPageXpath & mstrXPath & "/@" & objAttribute.Name)
      'Call AddClonedValueOfCell(objCell, "./@" & objAttribute.Name)
      
      'Add a blank cell for attributes, since attributes don't have attributes
      If mbShowPropertyAttributes Then
        Call AddClonedTextCell(objCell, "[n/a]")
      End If
      
      
      'Remove the template cells from the row
      Call objOddCell.parentNode.removeChild(objOddCell)
      Call objEvenCell.parentNode.removeChild(objEvenCell)
      
      Call objEditOddCell.parentNode.removeChild(objEditOddCell)
      Call objEditEvenCell.parentNode.removeChild(objEditEvenCell)
      
      'Add the row to the xsl
      Call objRowTemplate.parentNode.appendChild(objRow)
      
    End If
  Next
  
  'Add the properties
  For Each objProperty In mcollProperties
    If Not objProperty.Hidden Then
      
      'Clone the row
      Set objRow = GetClonedNode(objRowTemplate, ".", True)
      
      'Get the even and odd cells
      Set objEvenCell = objRow.selectSingleNode("//td[@id='TABLE_DATA_CELL_EVEN']")
      Set objOddCell = objRow.selectSingleNode("//td[@id='TABLE_DATA_CELL_ODD']")
    
      Set objEditEvenCell = objRow.selectSingleNode("//td[@id='TABLE_EDIT_CELL_EVEN']")
      Set objEditOddCell = objRow.selectSingleNode("//td[@id='TABLE_EDIT_CELL_ODD']")
      
      'Get the correct cell for the even/odd row
      If bOdd Then
        Set objCell = objOddCell
        Set objEditCell = objEditOddCell
      Else
        Set objCell = objEvenCell
        Set objEditCell = objEditEvenCell
      End If
      
      bOdd = Not bOdd
                               
      If Not mbReadOnly Then
        If objProperty.ReadOnly Then
          Call AddClonedTextCell(objEditCell, "")
        Else
          Call AddClonedSearchableEvalCell(objEditCell, "EDIT:" & strPageXpath & mstrXPath & "/" & objProperty.XPath & ":" & objProperty.ID, "absolutechildNumber(this)")
        End If
      End If
      
      'Add the property display name
      Call AddClonedTextCell(objCell, objProperty.DisplayName)
      
      'Add the property value
      Call AddClonedValueOfCell(objCell, strPageXpath & mstrXPath & "/" & objProperty.XPath)
      'Call AddClonedValueOfCell(objCell, ".")
      
      'Now add the attributes
      Call AddPropertyAttributesToClonedCell(objCell, objProperty.Attributes, strPageXpath & mstrXPath & "/" & objProperty.XPath)
      
      'Remove the template cells from the row
      Call objOddCell.parentNode.removeChild(objOddCell)
      Call objEvenCell.parentNode.removeChild(objEvenCell)
      
      Call objEditOddCell.parentNode.removeChild(objEditOddCell)
      Call objEditEvenCell.parentNode.removeChild(objEditEvenCell)
      
      'Add the row to the xsl
      Call objRowTemplate.parentNode.appendChild(objRow)
                               
    End If
  Next
  
  'Remove the template row
  Call objRowTemplate.parentNode.removeChild(objRowTemplate)
  
  End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : FindMatchingObjectByID(strID)                             '
' Description   : Find an object that matches the xpath.                    '
' Inputs        : strID -- ID to search for.                                '
' Outputs       : object                                                    '
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
      Set FindMatchingObjectByID = objProperty
      Exit Function
    End If
    
    'Check attributes of the property
    For Each objAttribute In objProperty.Attributes
      If strID = objAttribute.ID Then
        Set FindMatchingObjectByID = objAttribute
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
      Set FindMatchingObject = objProperty
      Exit Function
    End If
    
    'Check attributes of the property
    For Each objAttribute In objProperty.Attributes
      If strPageXpath & mstrXPath & "/" & objProperty.XPath & "/@" & objAttribute.Name = strXPath Then
        Set FindMatchingObject = objAttribute
        Exit Function
      End If
    Next
  Next

  Set FindMatchingObject = Nothing

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : RenderGrid(objGroupXSL)                                     '
' Description : Render the group's grid.                                    '
' Inputs      : XSL object to add the groups data to.                       '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function RenderGrid(ByRef objGroupXSL As DOMDocument30, ByRef strPageXpath As String)
  If Not CreateHeaderRow(objGroupXSL) Then
    
    Call CreateDataRows(objGroupXSL.selectSingleNode("//tr[@id='TABLE_DATA_ROW']"), _
                        strPageXpath)
  End If
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
' PropertyHeader
Public Property Let PropertyHeader(ByVal strPropertyHeader As String)
  Let mstrPropertyHeader = strPropertyHeader
End Property

Public Property Get PropertyHeader() As String
  Let PropertyHeader = mstrPropertyHeader
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' AttributeHeader
Public Property Let AttributeHeader(ByVal strAttributeHeader As String)
  Let mstrAttributeHeader = strAttributeHeader
End Property

Public Property Get AttributeHeader() As String
  Let AttributeHeader = mstrAttributeHeader
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ShowAttributesInGrid
Public Property Let ShowAttributesInGrid(ByVal bShowPropertyAttributes As Boolean)
  Let mbShowPropertyAttributes = bShowPropertyAttributes
End Property

Public Property Get ShowAttributesInGrid() As Boolean
  Let ShowAttributesInGrid = mbShowPropertyAttributes
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
' ValueHeader
Public Property Let ValueHeader(ByVal strValueHeader As String)
  Let mstrValueHeader = strValueHeader
End Property

Public Property Get ValueHeader() As String
  Let ValueHeader = mstrValueHeader
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' NoPopups
Public Property Let NoPopups(ByVal bNoPopoups As Boolean)
  Let mbNoPopups = bNoPopoups
End Property

Public Property Get NoPopups() As Boolean
  Let NoPopups = mbNoPopups
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ID
Public Property Get ID() As String
  Let ID = mstrID
End Property

Public Property Let ID(ByVal strID As String)
  Let mstrID = strID
End Property
                              

