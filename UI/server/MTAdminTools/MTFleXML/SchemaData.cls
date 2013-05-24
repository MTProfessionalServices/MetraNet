VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "SchemaData"
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
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mobjDict As Dictionary    'Dictionary to contain the data
Private mobjXML As New DOMDocument30  'Microsoft XML document
Private mstrError As String           'Used to return errors

Private mstrTitle As String           'Page title
Private mstrText As String            'Page notes
Private mintPages As Integer          'Count of pages to display

Private mstrExtraInclude              'Extra javascript file to include
Private mstrExtraFunction             'Function to call

Private mstrSchemaFile As String
Private mstrAutoGen As String         'XSL for schema autogeneration

Private mbUseIDs As Boolean           'Use IDs to search


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Functions                                                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub           : Initialize()                                              '
' Description   : Initialize the object, clear the dictionary, etc.         '
' Inputs        : None                                                      '
' Outputs       : None                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Sub Initialize()
  
  'Initialize the page count
  mintPages = 0
  mstrTitle = ""
  mstrText = ""
  mstrError = ""
  
 
  'Clear the dictionary
  Set mobjDict = Nothing
  Set mobjDict = New Dictionary
  
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub           : LoadFile(...)                                             '
' Description   : Load and parse the schema file.                           '
' Inputs        : The schema file path.                                     '
' Outputs       : Nothing                                                   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function ParseFile(ByVal strSchemaPath As String, _
                          Optional ByRef bString As Boolean = False) As Boolean
  Dim objSchemaNode As IXMLDOMNode
  
  gbLocalized = False
  
  'Load the file
  If bString Then
    Call mobjXML.LoadXML(strSchemaPath)
  Else
    mstrSchemaFile = Replace(strSchemaPath, "\", "/")
    Call mobjXML.Load(strSchemaPath)
  End If
  
  'Check for a parse error
  If mobjXML.parseError Then
    'mstrError = Replace(MTFLEXML_ERROR_04002, "[FILE_NAME]", strSchemaPath)
    'mstrError = Replace(mstrError, "[PARSE_ERROR]", mobjXML.parseError.reason)
    Call RaiseError(mstrError, "SchemaData.ParseFile", 4002, LOG_APPLICATION_ERROR)
  End If
    
    
  'Get the schema node
  Set objSchemaNode = mobjXML.selectSingleNode("/flexml_schema")
  
  If Not objSchemaNode Is Nothing Then
    ParseFile = ParseTopNode(objSchemaNode)
  Else
    'mstrError = Replace(MTFLEXML_ERROR_04003, "[FILE_NAME]", strSchemaPath)
    Call RaiseError(mstrError, "SchemaData.ParseFile", 4003, LOG_APPLICATION_ERROR)
  End If
    
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : ParseTopNode(objTopNode)                                  '
' Description   : Parse the top level nodes.                                '
' Inputs        : objTopNode - The top level schema node.                   '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function ParseTopNode(ByRef objTopNode As IXMLDOMNode) As Boolean
  Dim objPageList As IXMLDOMNodeList      'List of page nodes
  Dim objPageNode As IXMLDOMNode          'Used to iterate through the page nodes
  Dim objNode As IXMLDOMNode
  Dim objPage As Page                     'Page object
  Dim bAutoGenerate As Boolean            'Autogenerate schema
  
  On Error GoTo ErrorHandler
  
  'Get the title & optional text
  mstrTitle = GetNodeText(objTopNode, "title")
  mstrText = GetNodeText(objTopNode, "text")
  
  mstrExtraInclude = GetNodeText(objTopNode, "js_validate_include")
  mstrExtraFunction = GetAttributeText(objTopNode.selectSingleNode("js_validate_include"), "function")
  
  bAutoGenerate = CheckNodeText(objTopNode, "autogenerate_schema", "true")
  mstrAutoGen = GetNodeText(objTopNode, "autogenerate_xsl")
  
  If bAutoGenerate Then
    ParseTopNode = True
    Exit Function
  Else
    ParseTopNode = False
  End If
  
  If UCase(GetNodeText(objTopNode, "use_ids")) = "TRUE" Then
    mbUseIDs = True
  Else
    mbUseIDs = False
  End If
  
    
  'Get the edit pages
  mintPages = 1
  
  Set objPageList = objTopNode.selectNodes("page")
  
  If Not objPageList Is Nothing Then
    For Each objPageNode In objPageList
      Set objPage = New Page
      
      objPage.ID = "Page" & mintPages
      
      Call objPage.LoadPageSchema(objPageNode)
      
      'Add the page to the dictionary
      Call mobjDict.Add("Page" & CStr(mintPages), objPage)
      mintPages = mintPages + 1
    Next
  End If
  
ErrorHandler:
  If Err Then
  
  End If
End Function
'---------------------------------------------------------------------------'
' Function    : AutoGenerateSchema(strXMLFile)                              '
' Description : Attempt to autogenerate an xml schema.                      '
' Inputs      : strXMLFile -- XML to generate schema for.                   '
' Outputs     : New schema.                                                 '
'---------------------------------------------------------------------------'
Function AutoGenerateSchema(ByRef strXMLFile As String)
  Dim objXSL As New DOMDocument30
  Dim objXML As New DOMDocument30
  Dim strAutoSchemaPath As String
  Dim strXML As String
  
  
  objXSL.async = False
  objXSL.validateOnParse = False
  objXSL.resolveExternals = False

  objXML.async = False
  objXML.validateOnParse = False
  objXML.resolveExternals = False

  'Hack for now
  'strAutoSchemaPath = Left(mstrSchemaFile, Len(mstrSchemaFile) - InStr(mstrSchemaFile, "/MTFleXML/") - 1)
  'strAutoSchemaPath = strAutoSchemaPath & "/AutoGen/" & mstrAutoGen
  
  'Fix for incorrect file
  strAutoSchemaPath = Mid(mstrSchemaFile, 1, InStr(mstrSchemaFile, "/MTFleXML/"))
  strAutoSchemaPath = strAutoSchemaPath & "MTFleXML/Schema/AutoGen/" & mstrAutoGen
    
    
    
  Call objXSL.Load(strAutoSchemaPath)
  Call objXML.Load(strXMLFile)
  
  strXML = objXML.transformNode(objXSL)
  
  strXML = Replace(strXML, "[TITLE]", mstrTitle)
  strXML = Replace(strXML, "[TEXT]", mstrText)
  
  Call ParseFile(strXML, True)
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Properties                                                                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'PageCount
Public Property Get PageCount() As Integer
  Let PageCount = mintPages - 1
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'PageDict
Public Property Get PageDict() As Dictionary
  Set PageDict = mobjDict
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Use IDs
Public Property Get UseIDs() As Boolean
  Let UseIDs = mbUseIDs
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Title
Public Property Get Title() As String
  Let Title = mstrTitle
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Text() As String
  Let Text = mstrText
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'JSValidateInclude
Public Property Get JSValidateInclude() As String
  Let JSValidateInclude = mstrExtraInclude
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'JSValidateFunction
Public Property Get JSValidateFunction() As String
  Let JSValidateFunction = mstrExtraFunction
End Property

