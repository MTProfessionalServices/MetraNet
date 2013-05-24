VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Page"
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
' Page.cls -- Contains schema information for an edit page.  Each "page"    '
'             corresponds to the data displayed in one of the edit tabs.    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mstrPageTitle As String       'The title of the page
Private mstrPageText As String        'The text of the page
Private mstrTabText As String         'For tabbed menus, display this as the tab text
                                      'If omitted, the page title will be used
Private mstrID As String              'ID of the page

Private mbNoPopups As Boolean         'If no popups are used, the page is dislayed as editable in place
Private mbReadOnly As Boolean         'Specifies if the page is read-only or not

'For xsl stylesheet pages
Private mstrStylesheet As String      'Style sheet path
Private mstrStylesheetXML As String   'XML string to use in place of stylesheet file
Private mbUseStyleSheet As Boolean    'Use stylesheet for customized page

'XML information
Private mstrBaseXPath As String           'XPath Base for the page

Private mstrCustomPopup As String         'Custom popup window for editing

'Dictionary for Groups and Lists
Private mdictPageItems As New Dictionary    'Dictionary for groups/lists
Private mintCount As Integer                'Count of items for the page


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Methods                                                                   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub           : LoadSchema(...)                                           '
' Description   : Load a data page.                                         '
' Inputs        : objPageNode - node containing the page schema information '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Sub LoadPageSchema(ByRef objPageNode As IXMLDOMNode)
  Dim objNode As IXMLDOMNode
  Dim objNodeList As IXMLDOMNodeList
  Dim objList As New List
    
  On Error GoTo ErrorHandler
    
  'Get the page attributes
  'Stylesheet, not required
  mstrStylesheet = GetNodeText(objPageNode, "stylesheet")
  
  If Len(mstrStylesheet) = 0 Then
    mbUseStyleSheet = False
  Else
    mbUseStyleSheet = True
  End If
  
  'Check for popup use
  mbNoPopups = CheckAttributeText(objPageNode, "nopopups", "true")
  
  'Check for readonly
  mbReadOnly = CheckAttributeText(objPageNode, "readonly", "true")
    
  'Get the base xpath
  mstrBaseXPath = GetNodeText(objPageNode, "base_xpath")
  
  'Get the popup asp
  mstrCustomPopup = GetNodeText(objPageNode, "custom_popup_asp")
  
  'Get the title
  mstrPageTitle = GetNodeText(objPageNode, "title")
  
  'Get additional text
  mstrPageText = GetNodeText(objPageNode, "text")
  
  'Get the tab text
  mstrTabText = GetNodeText(objPageNode, "tabtext")
  
  'Now get all the lists and groups
  Set objNodeList = objPageNode.childNodes
  
  'Reset the item count
  mintCount = 0
  
  'For each node, perform an action
  For Each objNode In objNodeList
  
    Select Case UCase(objNode.nodeName)
    
      Case "GROUP"
        Call AddGroup(LoadGroupSchemaFromXML(objNode, mstrID & "Group" & mintCount))
      
      Case "LIST"
        Set objList = LoadListSchemaFromXML(objNode, mstrID & "List" & mintCount)
        objList.CustomPopup = mstrCustomPopup
        Call AddList(objList)
    End Select
  Next
  
ErrorHandler:
  If Err Then
  
  End If
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddGroup(objGroup)                                        '
' Description   : Add the group specified by objGroup to the dictionary of  '
'               : Page items.                                               '
' Inputs        : objGroup -- Group object                                  '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function AddGroup(ByRef objGroup As Group)
  Dim strName As String
  
  'Set the name of the item
  strName = "GROUP" & CStr(mintCount)
  
  'Add the item to the dictionary
  Call mdictPageItems.Add(strName, objGroup)
  
  'increment the count of items
  mintCount = mintCount + 1

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddList(objList)                                          '
' Description   : Add the list specified by objList to the dictionary of    '
'               : Page items.                                               '
' Inputs        : objList -- List object                                    '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function AddList(ByRef objList As List)
  Dim strName As String
  
  'Set the name of the item
  strName = "LIST" & CStr(mintCount)
  
  'Add the item to the dictionary
  Call mdictPageItems.Add(strName, objList)
  
  'increment the count of items
  mintCount = mintCount + 1
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Render(objGroupXSL, objListXSL)                             '
' Description : Render the whole page.                                      '
' Inputs      : objGroupXSL -- XSL for groups.                              '
'             : objListXSL  -- XSL for lists.                               '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function Render(ByRef objGroupXSL As DOMDocument30, _
                       ByRef objListXSL As DOMDocument30, _
                       ByRef objXML As DOMDocument30, _
                       ByRef strAction As String) As String
  'Items to render
  Dim objGroup As Group
  Dim objList As List
  Dim objXSL As New DOMDocument30
  

  Dim objKeys                 'Dictionary Keys
  
  Dim strHTML As String       'HTML to return
  
  Dim i As Integer            'Counter
  
  'Init
  objXSL.async = False
  objXSL.validateOnParse = False
  
  
  strAction = UCase(strAction)
  
  If mbUseStyleSheet Then
    If Len(mstrStylesheetXML) > 0 Then
      Call objXSL.LoadXML(mstrStylesheetXML)
    Else
      Call objXSL.Load(mstrStylesheet)
    End If
    
    strHTML = objXML.transformNode(objXSL)
  
  Else
  
    objKeys = mdictPageItems.Keys
  
    'Walk the dictionary
    For i = 0 To mintCount - 1
      If InStr(objKeys(i), "GROUP") > 0 Then
        Set objGroup = mdictPageItems(objKeys(i))
        
        Call objXSL.LoadXML(objGroupXSL.xml)
        
        Call objGroup.RenderGrid(objXSL, mstrBaseXPath)
        
        strHTML = strHTML & objXML.transformNode(objXSL)
        
        'Call objXSL.save("d:\temp\" & objKeys(i) & ".xml")
    
        'Perform Group-specific substitutions
        strHTML = Replace(strHTML, "[GROUP_TITLE]", objGroup.Title)
        strHTML = Replace(strHTML, "[GROUP_TEXT]", objGroup.Text)
      
      Else
        Set objList = mdictPageItems(objKeys(i))
        
        Call objXSL.LoadXML(objListXSL.xml)
        
        Call objList.RenderGrid(objXSL, mstrBaseXPath, strAction)
        'Call objXSL.save("d:\temp\bubba.xsl")
        strHTML = strHTML & objXML.transformNode(objXSL)
        
        'Perform List-specific substitutions
        strHTML = Replace(strHTML, "[LIST_TITLE]", objList.Title)
        strHTML = Replace(strHTML, "[LIST_TEXT]", objList.Text)
        
        strHTML = Replace(strHTML, "[LIST_ADD_BUTTON_TEXT]", objList.AddButtonText)
        strHTML = Replace(strHTML, "[LIST_REMOVE_BUTTON_TEXT]", objList.RemoveButtonText)
        
        If objList.ListType <> EXTENDED Then
          strHTML = Replace(strHTML, "[ATTRIBUTE_TABLE_TITLE]", objList.AttributeTableTitle)
          strHTML = Replace(strHTML, "[PROPERTY_TABLE_TITLE]", objList.PropertyTableTitle)
        Else
          strHTML = Replace(strHTML, "[ATTRIBUTE_TABLE_TITLE]", "")
          strHTML = Replace(strHTML, "[PROPERTY_TABLE_TITLE]", "")
        End If
      End If
    Next
  End If
  
  Render = strHTML
                       
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : FindMatchingObjectById(strID)                             '
' Description   : Find the matching object based on an id, rather than an   '
'               : xpath.                                                    '
' Inputs        : strID -- ID to find.                                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function FindMatchingObjectByID(ByRef strID As String)
  Dim objGroup As Group               'Group object
  Dim objList As List                 'List object
  Dim objProperty As Property         'Property object
  Dim objAttribute As AttributeItem   'Attribute object
  
  Dim objReturn As Object             'Object to return
  
  Dim objKeys                         'Dictionary keys
  
  Dim i As Integer                    'counter
  
  objKeys = mdictPageItems.Keys
  
  'Search the dictionary
  For i = 0 To mintCount - 1
    'Check the groups
    If InStr(objKeys(i), "GROUP") > 0 Then
      Set objGroup = mdictPageItems.Item(objKeys(i))
      
      Set objReturn = objGroup.FindMatchingObjectByID(strID)
      
      If Not objReturn Is Nothing Then
        Set FindMatchingObjectByID = objReturn
        Exit Function
      End If
    
    Else
      Set objList = mdictPageItems.Item(objKeys(i))
    
      Set objReturn = objList.FindMatchingObjectByID(strID)
      
      If Not objReturn Is Nothing Then
        Set FindMatchingObjectByID = objReturn
        Exit Function
      End If
    End If
  Next

  Set FindMatchingObjectByID = Nothing
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : FindMatchingObject(strXPath)                              '
' Description   : Find the object that matches the XPath                    '
' Inputs        : strXPath -- XPath to match.                               '
' Outputs       : matching object.                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function FindMatchingObject(ByRef strXPath As String)
  Dim objGroup As Group               'Group object
  Dim objList As List                 'List object
  Dim objProperty As Property         'Property object
  Dim objAttribute As AttributeItem   'Attribute object
  
  Dim objReturn As Object             'Object to return
  
  Dim objKeys                         'Dictionary keys
  
  Dim i As Integer                    'counter
  
  objKeys = mdictPageItems.Keys
  
  'Search the dictionary
  For i = 0 To mintCount - 1
    'Check the groups
    If InStr(objKeys(i), "GROUP") > 0 Then
      Set objGroup = mdictPageItems.Item(objKeys(i))
      
      If InStr(strXPath, mstrBaseXPath & objGroup.XPath) > 0 Then
        Set objReturn = objGroup.FindMatchingObject(strXPath, mstrBaseXPath)
        
        If Not objReturn Is Nothing Then
          Set FindMatchingObject = objReturn
          Exit Function
        End If
      End If
      
    Else
      Set objList = mdictPageItems.Item(objKeys(i))
    
      If InStr(strXPath, mstrBaseXPath & objList.XPath) > 0 Then
        Set objReturn = objList.FindMatchingObject(strXPath, mstrBaseXPath)
        
        If Not objReturn Is Nothing Then
          Set FindMatchingObject = objReturn
          Exit Function
        End If
      End If
      
    End If
  Next

  Set FindMatchingObject = Nothing
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Properties                                                                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Page Title
Public Property Let PageTitle(ByVal strPageTitle As String)
  Let mstrPageTitle = strPageTitle
End Property

Public Property Get PageTitle() As String
  Let PageTitle = mstrPageTitle
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Page Text
Public Property Let PageText(ByVal strPageText As String)
  Let mstrPageText = strPageText
End Property

Public Property Get PageText() As String
  Let PageText = mstrPageText
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Use popups
Public Property Let NoPopups(ByVal bNoPopups As Boolean)
  Let mbNoPopups = bNoPopups
End Property

Public Property Get NoPopups() As Boolean
  Let NoPopups = mbNoPopups
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Read only
Public Property Let ReadOnly(ByVal bReadOnly As Boolean)
  Let mbReadOnly = bReadOnly
End Property

Public Property Get ReadOnly() As Boolean
  Let ReadOnly = mbReadOnly
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
'Stylesheet
Public Property Let StyleSheet(ByVal strStyleSheet As String)
  Let mstrStylesheet = strStyleSheet
End Property

Public Property Get StyleSheet() As String
  Let StyleSheet = mstrStylesheet
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'XPath
Public Property Get XPath() As String
  Let XPath = mstrBaseXPath
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'TabText
Public Property Get TabText() As String
  Let TabText = mstrTabText
End Property

Public Property Let TabText(ByVal strTabText As String)
  Let mstrTabText = strTabText
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
Public Property Get PageItems() As Dictionary
  Set PageItems = mdictPageItems
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' CustomPopup
Public Property Get CustomPopup() As String
  Let CustomPopup = mstrCustomPopup
End Property

Public Property Let CustomPopup(ByVal strCustomPopup As String)
  Let mstrCustomPopup = strCustomPopup
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' StylesheetXML
Public Property Get StylesheetXML() As String
  Let StylesheetXML = mstrStylesheetXML
End Property

Public Property Let StylesheetXML(ByVal strStylesheetXML As String)
  Let mstrStylesheetXML = strStylesheetXML
End Property

