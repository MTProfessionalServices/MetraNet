VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Render"
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
' Render.cls                                                                '
'   Provide access to the rendered sub-elements of the XML file. The return '
'   value is a string with HTML for each item.  HTML is generated through   '
'   the use of XSL stylesheets.                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public Enum FlexListType
  SIMPLE = 0            'List consisting of one element
  EXTENDED = 1          'A list of groups
  FLATEXTENDED = 2      'A list like element1, element2, element1, element2 where
                        'elmenents 1 and 2 are logically grouped together
End Enum

Public Enum FlexEditType
  TEXTINPUT = 0         'INPUT TYPE=TEXT
  TEXTAREA = 1          'TEXTAREA
  SINGLESELECT = 2      'SELECT
  MULTIPLESELECT = 3    'SELECT MULTI
  CHECK = 4             'CHECKBOX
  RADIO = 5             'RADIO
  HIDDENTEXT = 6            'HIDDEN Input
End Enum

Private mintPage As Integer               'Current page to render
Private mintElement As Integer            'Current element on the page
Private mstrSchemaPath As String          'Path to the XML schema for the file
Private mstrXMLPath As String             'Path to the XML file to edit
Private mobjXML As New DOMDocument30      'XMLDOM object
Private mobjXSL As New DOMDocument30      'XMLDOM object
Private mobjFSO As New FileSystemObject   'Used to check existence of files
Private mstrError As String               'Error message

Private mstrCustomPopup As String         'Custom popups to use

Private mobjEdit As New Edit                  'Object to edit the file

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Rendering Information
Private mstrStylesheetPath As String      'Path to the stylesheets
Private mstrPageTemplatePath As String    'Path to the Template for the page
Private mobjSchemaData As New SchemaData  'Schema data object
Private mintPageCount As Integer          'Get the number of pages
Private mbTemplateAsText As Boolean       'Use text for a template
Private mstrTemplateText As String        'Text of the template
Private mstrUserDefinedJS As String       'User defined javascript

Private mobjRCD As New MTRcd

Private mbLocalized As Boolean            'Indicates localization data is necessary
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Functions                                                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : Initialize(strSchemaPath, strXMLPath, strStylesheetPath)  '
' Description   : Initialized the render object by loading the schema and   '
'               : XML file.                                                 '
' Inputs        : strSchemaPath -- Path to the schema file.                 '
'               : strXMLPath    -- Path to the XML file.                    '
'               : strStyleSheetPath -- Path to the directory containing     '
'               :                      the stylesheets.                     '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function Initialize(ByVal strSchemaPath As Variant, _
                           ByVal strXMLPath As Variant, _
                           ByVal strStyleSheetPath As Variant)
  Dim objTextFile As TextStream
  
  On Error GoTo ErrorHandler

  'Check for the existence of the files
  If Not mobjFSO.FileExists(strSchemaPath) Then
    'mstrError = Replace(MTFLEXML_ERROR_04000, "[FILE_NAME]", strSchemaPath)
    Call RaiseError(mstrError, "Edit.Initialize", 4000, LOG_APPLICATION_ERROR)
  End If
  
  If Not mobjFSO.FileExists(strXMLPath) Then
    'mstrError = Replace(MTFLEXML_ERROR_04001, "[FILE_NAME]", strXMLPath)
    Call RaiseError(mstrError, "Edit.Initialize", 4001, LOG_APPLICATION_ERROR)
  End If
  
  If Not mobjFSO.FolderExists(strStyleSheetPath) Then
    'mstrError = Replace(MTFLEXML_ERROR_04007, "[FILE_NAME]", strXMLPath)
    Call RaiseError(mstrError, "Edit.Initialize", 4001, LOG_APPLICATION_ERROR)
  End If
  
  'Assign the values
  mstrSchemaPath = strSchemaPath
  mstrXMLPath = strXMLPath
  mstrStylesheetPath = strStyleSheetPath
  
  
  'Load and parse the schema
  Call mobjSchemaData.Initialize
  
  If mobjSchemaData.ParseFile(mstrSchemaPath) Then
    Call mobjSchemaData.AutoGenerateSchema(mstrXMLPath)
  End If
  
    
ErrorHandler:
  If Err Then
    Initialize = False
  Else
    Initialize = True
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : RenderPage(intPage)                                       '
' Description   : Return the HTML for the given page.                       '
' Inputs        : intPage -- The page to render                             '
' Outputs       : HTML for the page.                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function RenderPage(ByVal intPage As Integer, ByVal strAction As String) As String
  Dim objTemplateFile As TextStream       'The page template
  Dim strTemplateText As String           'Contents of the page template
  Dim strLanguageSelectHTML As String     'Template to select languages
  Dim strHTML As String                   'Rendered HTML
  
  Dim objGroupXSL As New DOMDocument30    'XSL for groups
  Dim objListXSL As New DOMDocument30     'XSL for lists
  Dim objPageXSL As New DOMDocument30     'XSL for the whole Page
  
  Dim objTemplate As TextStream           'File template
  
  Dim objXML As New DOMDocument30
  
  Dim objPage As Page                     'The page to render
  Dim strPage As String                   'The page
  
  
  'Init
  objPageXSL.async = False
  objPageXSL.validateOnParse = False
    
  objGroupXSL.async = False
  objGroupXSL.validateOnParse = False
  
  objListXSL.async = False
  objListXSL.validateOnParse = False
  
  strAction = UCase(strAction)
  
    'Load the html template
  If mbTemplateAsText Then
    strTemplateText = mstrPageTemplatePath
  Else
    Set objTemplate = mobjFSO.OpenTextFile(mstrPageTemplatePath)
    strTemplateText = objTemplate.ReadAll()
  End If
    
  'Get the name of the page
  strPage = "Page" & CStr(intPage)
  
  Set objPage = mobjSchemaData.PageDict(strPage)
  
  'Load the XML
  'Call objXML.Load(mstrXMLPath)
  
  'Load the group and list xsl
  Call objGroupXSL.Load(mstrStylesheetPath & "/groups_grid.xsl")
  Call objListXSL.Load(mstrStylesheetPath & "/lists_grid.xsl")
  
  
  'Get HTML for the page
  If InStr(objPage.StyleSheet, mstrStylesheetPath) = 0 Then
    objPage.StyleSheet = mstrStylesheetPath & "/" & objPage.StyleSheet
  End If
  
  strHTML = objPage.Render(objGroupXSL, objListXSL, mobjXML, strAction)
  
  'Perform substitutions
  'Load the HTML into the template
  strHTML = Replace(strTemplateText, "[PAGE_HTML]", strHTML)
  strHTML = Replace(strHTML, "[PAGE_TITLE]", objPage.PageTitle)
  strHTML = Replace(strHTML, "[PAGE_NOTES]", objPage.PageText)
  
  strHTML = Replace(strHTML, "[SCHEMA_TITLE]", mobjSchemaData.Title)
  strHTML = Replace(strHTML, "[SCHEMA_TEXT]", mobjSchemaData.Text)

  'Make the substitutions that were specified in the schema
  strHTML = Replace(strHTML, "[XMLFILE]", mstrXMLPath)
  strHTML = Replace(strHTML, "[SCHEMAFILE]", mstrSchemaPath)
  strHTML = Replace(strHTML, "[TEMPLATEFILE]", mstrPageTemplatePath)
  
    
  RenderPage = strHTML

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : RenderPopup(strXPath, intIndex)                           '
' Description   : Return the HTML for the given popup.                      '
' Inputs        : strXPath  -- XPath for the data to edit.                  '
'               : intIndex  -- Relative index for the search.               '
' Outputs       : HTML for the page.                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function RenderPopup(ByVal strXPath As String, _
                            ByVal intIndex As Integer, _
                            ByVal strAction As String, _
                            ByVal strID As String) As String
  Dim objNodeList As IXMLDOMNodeList  'List of nodes matching the XPath
  Dim objXSLNode As IXMLDOMNode       'Node for the XSL doc
  Dim objXMLNode As IXMLDOMNode       'Node for the xml to view
  Dim objTempNode As IXMLDOMNode      'used for simple lists
  Dim strParentXpath As String        'xpath when searching for parents
  Dim objItem                         'object to render
  Dim objNewItem
  
  'Items that can be returned
  Dim objAttribute As AttributeItem
  Dim objProperty As Property
  Dim objList As List
  
  Dim strPageXpath As String
  Dim strHTML As String                 'HTML for the popup
  
  'Template for the popup
  Dim objTemplate As TextStream
  Dim strTemplate As String
  
  
  strAction = UCase(strAction)
  
  'Load the html template
  If mbTemplateAsText Then
    strTemplate = mstrPageTemplatePath
  Else
    Set objTemplate = mobjFSO.OpenTextFile(mstrPageTemplatePath)
    strTemplate = objTemplate.ReadAll()
  End If

  'Load the XSL
  Call mobjXSL.Load(mstrStylesheetPath & "/popup.xsl")
  Set objXSLNode = mobjXSL.documentElement
  
  'Load the XML
  'Call mobjXML.Load(mstrXMLPath)

      
    'Get the schema object
    If mobjSchemaData.UseIDs Then
      Set objItem = FindMatchingObjectByID(strID)
    Else
      Set objItem = FindMatchingObject(strXPath, strPageXpath)
    End If
    
    Select Case UCase(TypeName(objItem))
      Case "ATTRIBUTEITEM"
        Set objAttribute = objItem
        
        'Load the XML
        strParentXpath = Left(strXPath, InStrRev(strXPath, "/") - 1)
        
        Set objNodeList = mobjXML.selectNodes(strParentXpath)
          
        Set objXMLNode = objNodeList.Item(intIndex - 1)
        
        Call objAttribute.RenderPopup(objXSLNode, objXMLNode, ":" & objAttribute.Name, strAction)
        Call SetMatch(strParentXpath, objXSLNode)
        
        strHTML = objXMLNode.transformNode(objXSLNode)
      
      Case "PROPERTY"
        Set objProperty = objItem
        
        'Load the XML
        strParentXpath = Left(strXPath, InStrRev(strXPath, "/") - 1)
        Set objNodeList = mobjXML.selectNodes(strParentXpath)
        Set objXMLNode = objNodeList.Item(intIndex - 1)
        
        
        'Check if the parent is a simple list, which is a special case
        'Set objNewItem = FindMatchingObject(strParentXpath, strPageXpath)
        
        'If Not objNewItem Is Nothing Then
        '  If UCase(TypeName(objNewItem)) = "LIST" Then
        '    Set objList = objNewItem
        '    If objList.ListType = SIMPLE Then
              'The property's render popup method expects to find the property
              'as the first node with a matching name that is a child of the
              'passed-in node.  This does not work for simple lists.
        '      Set objNodelist = mobjXML.selectNodes(strXPath)
        '      Set objXMLNode = objNodelist.Item(intIndex - 1)
              
        '      Set objTempNode = objXMLNode.cloneNode(True)
              
        '      Call objXMLNode.appendChild(objTempNode)
        '    End If
        '  End If
        'End If
        
        
        
        
        Call objProperty.RenderPopup(objXSLNode, objXMLNode, ":" & objProperty.XPath, strAction)
        Call SetMatch(strParentXpath, objXSLNode)
        
        strHTML = objXMLNode.transformNode(objXSLNode)
        
        ' Condition to display "Compile Formula" Button to compile the MTSQL formula from plugin page
        ' OnClick of this button javascript function "CompileForm" will be called
        If (InStr(1, mstrSchemaPath, "Plugins\COMInterpreterSchema.xml", vbTextCompare) > 1) And (objProperty.XPath = "Program") Then
            strHTML = strHTML & "<tr><td align=""center"" colspan=""2""><br><button class=""clsBlueButton""  onClick=""javascript:CompileForm();"">Compile Formula</button><input type=hidden name=hdnPopUpSize value=MTSQL></td><tr>"
        End If
      
      Case "LIST"
        Set objList = objItem
        
        Set objNodeList = mobjXML.selectNodes(strXPath)
        
        If strAction <> "ADD" Then
          
          If objList.ListType = SIMPLE Then
            Set objXMLNode = objNodeList.Item(intIndex - 1)
          ElseIf objList.ListType = FLATEXTENDED Then
            Set objXMLNode = objNodeList.Item(0)
          ElseIf objList.ListType = EXTENDED Then
            Set objXMLNode = objNodeList.Item(intIndex - 1)
          End If
        
        Else
          If objList.ListType = EXTENDED Then
            Set objXMLNode = mobjXML.createNode(NODE_ELEMENT, Right(objList.XPath, Len(objList.XPath) - InStrRev(objList.XPath, "/")), "")
          Else
            Set objXMLNode = mobjXML.createNode(NODE_ELEMENT, "dummy", "")
          End If
        End If
          
        
        strHTML = objList.RenderPopup(objXSLNode, objXMLNode, strPageXpath, "", strAction, intIndex)
    End Select
'  End If

  'Perform substitutions
  strHTML = Replace(strTemplate, "[POPUP_HTML]", strHTML)
  strHTML = Replace(strHTML, "[POPUP_HEADER]", objItem.PopupHeader)
  strHTML = Replace(strHTML, "[POPUP_TITLE]", objItem.PopupTitle)
  strHTML = Replace(strHTML, "[POPUP_TEXT]", objItem.PopupText)
  
  'Add additional Javascript
  
  If Len(mobjSchemaData.JSValidateInclude) > 0 Then
    strHTML = Replace(strHTML, "[JS_VALIDATE_INCLUDE]", "<script language=""Javascript"" src=""" & mobjSchemaData.JSValidateInclude & """></script>")
    strHTML = Replace(strHTML, "[JS_VALIDATE_FUNCTION]", " bValidated = " & mobjSchemaData.JSValidateFunction & ";")
  Else
    strHTML = Replace(strHTML, "[JS_VALIDATE_INCLUDE]", "")
    strHTML = Replace(strHTML, "[JS_VALIDATE_FUNCTION]", "")
  End If
  
  strHTML = Replace(strHTML, "[JS_USER_DEFINED]", mstrUserDefinedJS)
  
  RenderPopup = strHTML

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : ModifyXML(strXpath, intIndex, arrNames, arrVals, strAction) '
' Description : Make changes to the XML file, supports adding items as well.'
' Inputs      : strXPath  -- xpath for the base object                      '
'             : intIndex  -- index of the item to modify, or to insert.     '
'             : arrNames  -- array of names of items                        '
'             : arrVals   -- array of values                                '
'             : strAction -- indicates adding new, modifying or removing.   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function ModifyXML(ByRef strXPath As String, _
                          ByRef intIndex As Integer, _
                          ByRef arrNames, _
                          ByRef arrVals, _
                          ByVal strAction As String, _
                          ByVal strID As String)
  Dim objItem                           'Item to add
  Dim objNodeList As IXMLDOMNodeList    'List of nodes matching xpath
  Dim objNode As IXMLDOMNode            'Node to add/modify
  Dim strPageXpath As String            'Xpath of the page the object belongs to
  
  'Step 1: Load the XML
  'Call mobjXML.Load(mstrXMLPath)
  
  'Get the item
  If mobjSchemaData.UseIDs Then
    Set objItem = FindMatchingObjectByID(strID)
  Else
    Set objItem = FindMatchingObject(strXPath, strPageXpath)
  End If

  'Modify the XML
  Call mobjEdit.ModifyXML(strXPath, intIndex, mobjXML, objItem, arrNames, arrVals, UCase(strAction))
    
  'Save to temp
  'Call mobjXML.save("d:\temp\new.xml")
  'Call mobjXML.save(mstrXMLPath)
    
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : SetOverrides(strXpath, intIndex, arrNames, arrVals, _       '
'             : strAction)                                                  '
' Description : Make changes to the XML file, supports adding items as well.'
' Inputs      : strXPath  -- xpath for the base object                      '
'             : intIndex  -- index of the item to modify, or to insert.     '
'             : arrNames  -- array of names of items                        '
'             : arrVals   -- array of values                                '
'             : strAction -- indicates adding new, modifying or removing.   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function SetOverrides(ByRef strXPath As String, _
                             ByRef intIndex As Integer, _
                             ByRef arrNames, _
                             ByRef arrVals, _
                             ByVal strAction As String, _
                             ByVal strID As String)
  Dim objItem                           'Item to add
  Dim strPageXpath As String            'Xpath of the page the object belongs to
  
  'Step 1: Load the XML
  'Call mobjXML.Load(mstrXMLPath)
  
  'Get the item
  If mobjSchemaData.UseIDs Then
    Set objItem = FindMatchingObjectByID(strID)
  Else
    Set objItem = FindMatchingObject(strXPath, strPageXpath)
  End If

  'Modify the XML
  Call mobjEdit.OverrideXML(strXPath, intIndex, mobjXML, objItem, arrNames, arrVals, UCase(strAction))
    
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : SaveXML()                                                   '
' Description : Save the xml file.                                          '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function SaveXML()
  Call mobjXML.save(mstrXMLPath)
  
  'Fix for problem with SQL Interpreter plug-ins
  'Call PropSetPrint(mstrXMLPath)
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadXML()                                                   '
' Description : Save the xml file.                                          '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function LoadXML()
  Call mobjXML.Load(mstrXMLPath)
  
  Call ClearOverrides
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : ClearOverrides()                                            '
' Description : Remove all the values that have been overridden.            '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function ClearOverrides()
  Dim objPage As Page                 'Iterate through the pages
  Dim objGroup As Group               '
  Dim objList As List                 '
  Dim objProperty As Property         '
  Dim objAttribute As AttributeItem   '
  
  Dim objKeys                         'Dictionary keys
  
  Dim i As Integer                    'Counter
  Dim j As Integer                    'Counter
  
  
  
  For i = 1 To mobjSchemaData.PageCount
    Set objPage = mobjSchemaData.PageDict("Page" & CStr(i))
    
      
    objKeys = objPage.PageItems.Keys
  
    'Walk the dictionary
    For j = 0 To objPage.PageItems.Count - 1
      If InStr(objKeys(j), "GROUP") > 0 Then
        Set objGroup = objPage.PageItems(objKeys(j))
        
        For Each objProperty In objGroup.Properties
          objProperty.OverrideFlag = False
          objProperty.OptionOverrideFlag = False
          
          For Each objAttribute In objProperty.Attributes
            objAttribute.OverrideFlag = False
            objAttribute.OptionOverrideFlag = False
          Next
        Next
      
      Else
        Set objList = objPage.PageItems(objKeys(j))
        
        For Each objAttribute In objList.Attributes
          objAttribute.OverrideFlag = False
          objAttribute.OptionOverrideFlag = False
        Next
        
        For Each objProperty In objList.Properties
          objProperty.OverrideFlag = False
          objProperty.OptionOverrideFlag = False
          
          For Each objAttribute In objProperty.Attributes
            objAttribute.OverrideFlag = False
            objAttribute.OptionOverrideFlag = False
          Next
        Next
      End If
    Next
  Next
        
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : FindMatchingObjectByID(strID)                               '
' Description : Returns a schema object that matches the id                 '
' Inputs      : strID -- ID to match                                        '
' Outputs     : Matching object.                                            '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function FindMatchingObjectByID(ByRef strID As String) As Object
  Dim objPage As Page                 'Page object
  Dim objItem As Object               'object returne
  Dim i As Integer                    'Counter
  
  For i = 1 To mobjSchemaData.PageCount
    Set objPage = mobjSchemaData.PageDict("Page" & CStr(i))
    
    'If the item could be in this page
    Set objItem = objPage.FindMatchingObjectByID(strID)
      
    If Not objItem Is Nothing Then
      'strPageXpath = objPage.XPath
      Set FindMatchingObjectByID = objItem
      Exit Function
    End If
  Next
  
  
  Set FindMatchingObjectByID = Nothing
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : FindMatchingObject(strXPath)                                '
' Description : Returns a schema object that matches the XPath              '
' Inputs      : strXPath -- XPath to match                                  '
' Outputs     : Matching object.                                            '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function FindMatchingObject(ByRef strXPath As String, ByRef strPageXpath As String) As Object
  Dim objPage As Page                 'Page object
  
  Dim objItem As Object               'object returne
 
  Dim i As Integer                    'Counter
  
  For i = 1 To mobjSchemaData.PageCount
    Set objPage = mobjSchemaData.PageDict("Page" & CStr(i))
    
    'If the item could be in this page
    If InStr(strXPath, objPage.XPath) > 0 Then
      Set objItem = objPage.FindMatchingObject(strXPath)
      
      If Not objItem Is Nothing Then
        strPageXpath = objPage.XPath
        Set FindMatchingObject = objItem
        Exit Function
      End If
    End If
  Next
  
  
  Set FindMatchingObject = Nothing
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Properties                                                                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Page
Public Property Let Page(ByVal intPage As Integer)
  Let mintPage = intPage
End Property

Public Property Get Page() As Integer
  Let Page = mintPage
End Property

Public Property Get PageTabText(ByVal intPage As Integer)
  If intPage > 0 And intPage <= mobjSchemaData.PageCount Then
    If Len(mobjSchemaData.PageDict.Item("Page" & intPage).TabText) > 0 Then
      Let PageTabText = mobjSchemaData.PageDict.Item("Page" & intPage).TabText
    Else
      Let PageTabText = mobjSchemaData.PageDict.Item("Page" & intPage).PageTitle
    End If
  End If
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Current Element
Public Property Let CurrentElement(ByVal intElement As Integer)
  Let mintElement = intElement
End Property

Public Property Get CurrentElement() As Integer
  Let CurrentElement = mintElement
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PageCount
Public Property Get PageCount() As Integer
  Let PageCount = mobjSchemaData.PageCount
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PageTemplate
Public Property Let PageTemplate(ByVal strPageTemplatePath As String)
  Let mstrPageTemplatePath = strPageTemplatePath
End Property

Public Property Get PageTemplate() As String
  Let PageTemplate = mstrPageTemplatePath
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' TextTemplate
Public Property Let TextTemplate(ByVal bTemplateAsText As Boolean)
  Let mbTemplateAsText = bTemplateAsText
End Property

Public Property Get TextTemplate() As Boolean
  Let TextTemplate = mbTemplateAsText
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' XML Path
Public Property Get XMLPath() As String
  Let XMLPath = mstrXMLPath
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Schema Path
Public Property Get SchemaPath() As String
  Let SchemaPath = mstrSchemaPath
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Stylesheet path
Public Property Get StylesheetPath() As String
  Let StylesheetPath = mstrStylesheetPath
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'XML Doc
Public Property Get XMLDoc() As DOMDocument30
  Set XMLDoc = mobjXML
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Extension
Public Property Get Extension() As String
  Let Extension = gstrExtension
End Property

Public Property Let Extension(ByVal Val As String)
  Let gstrExtension = Val
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Page
Public Property Get PageObject(ByVal intPage As Integer) As Page
  Set PageObject = mobjSchemaData.PageDict("Page" & CStr(intPage))
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Localized
Public Property Get Localized() As Boolean
  Let Localized = gbLocalized
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' User defined JS
Public Property Get UserDefinedJS() As String
  Let UserDefinedJS = mstrUserDefinedJS
End Property

Public Property Let UserDefinedJS(ByVal strUserDefinedJS As String)
  Let mstrUserDefinedJS = strUserDefinedJS
End Property

Private Sub Class_Initialize()
  mobjXSL.async = False
  mobjXSL.validateOnParse = False
  mobjXSL.resolveExternals = False
  
  mobjXML.async = False
  mobjXML.validateOnParse = False
  mobjXML.resolveExternals = False
End Sub
