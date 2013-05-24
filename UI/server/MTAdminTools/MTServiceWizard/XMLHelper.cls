VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "XMLHelper"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'----------------------------------------------------------------------------
' Copyright 1998, 1999 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' $Workfile: XMLHelper.cls$
' $Date: 05/31/2001 3:35:47 PM$
' $Author: Ralf Boeck$
' $Revision: 10$
'
'
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
' This class provides supporting XML functions for the service wizard objects
'----------------------------------------------------------------------------
Option Explicit

'----------------------------------------------------------------------------
' Global Variables
'----------------------------------------------------------------------------
Private mobjXMLDoc As New DOMDocument   'the xml document
Private mbPrettyPrint As Boolean        'indicates whether to pretty print the
                                        'files or not


''''''''''''''''''
'Let/Get for the pretty print option
Public Property Get PrettyPrint() As Boolean
  Let PrettyPrint = mbPrettyPrint
End Property

Public Property Let PrettyPrint(ByVal Val As Boolean)
  Let mbPrettyPrint = Val
End Property
'---------------------------------------------------------------------------'
' Function GetSingleNode(strXMLFile, strNodeQuery)                          '
'                                                                           '
' Description: Get a single node in an xml file.                            '
'                                                                           '
' Inputs:   strNodeQuery          -- node search to perform                 '
'           strXMLFile            -- XML file to edit                       '
'                                                                           '
' Outputs:  The node found.                                                 '
'---------------------------------------------------------------------------'
Public Function GetSingleNode(strXMLFile, strNodeQuery) As IXMLDOMNode
  Dim objXMLNode As IXMLDOMNode
  
  mobjXMLDoc.async = False
  mobjXMLDoc.validateOnParse = False  'don't validate according to DTD
  mobjXMLDoc.resolveExternals = False
  
  'Load the document
  mobjXMLDoc.Load strXMLFile
  
  'Check for a parse error
  If mobjXMLDoc.parseError Then
    Set GetSingleNode = Nothing
    Exit Function
  End If
  
  'Get the node
  Set objXMLNode = mobjXMLDoc.selectSingleNode(strNodeQuery)
  
  'Check the node
  If objXMLNode Is Nothing Then
    Set GetSingleNode = Nothing
    Exit Function
  End If

  Set GetSingleNode = objXMLNode
  
End Function
'---------------------------------------------------------------------------'
' Function GetSingleNodeText(strXMLFile, strNodeQuery)                      '
'                                                                           '
' Description: Get the text for a single node in an xml file.               '
'                                                                           '
' Inputs:   strNodeQuery          -- node search to perform                 '
'           strXMLFile            -- XML file to edit                       '
'                                                                           '
' Outputs:  The text found.                                                 '
'---------------------------------------------------------------------------'
Public Function GetSingleNodeText(strXMLFile, strNodeQuery)
  Dim objXMLNode As IXMLDOMNode
  
  Set objXMLNode = GetSingleNode(strXMLFile, strNodeQuery)
  
  'Check the node
  If objXMLNode Is Nothing Then
    GetSingleNodeText = ""
    Exit Function
  End If

  GetSingleNodeText = objXMLNode.Text

End Function
'---------------------------------------------------------------------------'
' Function RemoveMultipleNodes(strXMLFile, strNodeQuery)                    '
'                                                                           '
' Description: Remove the nodes with the same name.                         '
'                                                                           '
' Inputs:   strNodeQuery          -- node search to perform                 '
'           strXMLFile            -- XML file to edit                       '
'                                                                           '
' Outputs:  True if successful, false if failure                            '
'---------------------------------------------------------------------------'
Public Function RemoveMultipleNodes(strXMLFile, strNodeQuery) As Boolean
  Dim objXMLNodeList As IXMLDOMNodeList
  Dim objXMLNode As IXMLDOMNode
  
  mobjXMLDoc.async = False
  mobjXMLDoc.validateOnParse = False  'don't validate according to DTD
  mobjXMLDoc.resolveExternals = False
  
  'Get the nodes
  Set objXMLNodeList = GetMultipleNodes(strXMLFile, strNodeQuery)
  
  'Remove the nodes
  If Not objXMLNodeList Is Nothing Then
    For Each objXMLNode In objXMLNodeList
      Call objXMLNode.parentNode.RemoveChild(objXMLNode)
    Next
    
  
    'Save the document
    Call mobjXMLDoc.save(strXMLFile)
  
    If mbPrettyPrint Then
      Call PrettyPrintXMLFile(strXMLFile, 2, 0)
    End If
  End If

  RemoveMultipleNodes = True

End Function
'---------------------------------------------------------------------------'
' Function GetMultipleNodes(strXMLFile, strNodeQuery)                       '
'                                                                           '
' Description: Get the nodes with the same name.                            '
'                                                                           '
' Inputs:   strNodeQuery          -- node search to perform                 '
'           strXMLFile            -- XML file to edit                       '
'                                                                           '
' Outputs:  An IXMLDOMNodeList with all the nodes                           '
'---------------------------------------------------------------------------'
Public Function GetMultipleNodes(strXMLFile, strNodeQuery) As IXMLDOMNodeList
  
  mobjXMLDoc.async = False
  mobjXMLDoc.validateOnParse = False  'don't validate according to DTD
  mobjXMLDoc.resolveExternals = False
  
  'Load the document
  Call mobjXMLDoc.Load(strXMLFile)
  
  'Check for a parse error
  If mobjXMLDoc.parseError Then
    Set GetMultipleNodes = Nothing
    Exit Function
  End If
  
  'Get the list of matching nodes
  Set GetMultipleNodes = mobjXMLDoc.selectNodes(strNodeQuery)

End Function

'---------------------------------------------------------------------------'
' Function GetMultipleNodeText(strXMLFile, strNodeQuery)                    '
'                                                                           '
' Description: Get the text for a nodes with the same name.                 '
'                                                                           '
' Inputs:   strNodeQuery          -- node search to perform                 '
'           strXMLFile            -- XML file to edit                       '
'                                                                           '
' Outputs:  An array with all the node texts.                               '
'---------------------------------------------------------------------------'
Public Function GetMultipleNodeText(strXMLFile, strNodeQuery)
  Dim objXMLNodeList As IXMLDOMNodeList
  Dim objXMLNode As IXMLDOMNode
  Dim arrRetVal()
  Dim intCount
  
  'Init
  intCount = 0
  ReDim arrRetVal(0)
    
  Set objXMLNodeList = GetMultipleNodes(strXMLFile, strNodeQuery)
  
  If objXMLNodeList Is Nothing Then
    GetMultipleNodeText = arrRetVal
    Exit Function
  End If
  
  'Create the return array
  For Each objXMLNode In objXMLNodeList
    ReDim Preserve arrRetVal(intCount)
    arrRetVal(intCount) = objXMLNode.Text
    intCount = intCount + 1
  Next
  
  GetMultipleNodeText = arrRetVal
  
End Function
'---------------------------------------------------------------------------'
' Function SetSingleNodeText(strNodeQuery, strNodeText, strXMLFile)         '
'                                                                           '
' Description: Set the text for a single node in an xml file.               '
'                                                                           '
' Inputs:   strNodeQuery          -- node search to perform                 '
'           strNodeText           -- text to place in node                  '
'           strXMLFile            -- XML file to edit                       '
'                                                                           '
' Outputs:  true  -- if the operation was successful                        '
'           false -- if an error occurred                                   '
'---------------------------------------------------------------------------'
Public Function SetSingleNodeText(ByVal strNodeQuery As String, _
                                  ByVal strNodeText As String, _
                                  ByVal strXMLFile As String) As Boolean
  Dim objXMLNode As IXMLDOMNode
  
  mobjXMLDoc.async = False            'synchronous file i/o
  mobjXMLDoc.validateOnParse = False  'don't validate according to DTD
  mobjXMLDoc.resolveExternals = False
    
  If Len(strNodeQuery) = 0 Or Len(strXMLFile) = 0 Then
    SetSingleNodeText = False
    Exit Function
  End If
    
  'Load the document
  Call mobjXMLDoc.Load(strXMLFile)
    
  'Make sure the document was loaded
  If mobjXMLDoc.parseError Then
    SetSingleNodeText = False
    Exit Function
  End If
  
  'Get the node
  Set objXMLNode = mobjXMLDoc.selectSingleNode(strNodeQuery)
  
  'Check if the node was found
  If objXMLNode Is Nothing Then
    SetSingleNodeText = False
    Exit Function
  End If
  
  'Set the text
  objXMLNode.Text = strNodeText
  
  'Save the document
  Call mobjXMLDoc.save(strXMLFile)

  If mbPrettyPrint Then
    Call PrettyPrintXMLFile(strXMLFile, 2, 0)
  End If

  SetSingleNodeText = True
  
End Function
'---------------------------------------------------------------------------'
' Function AddNode(strXMLFile, strLocation, strName, strValue,              '
'                  arrAttributeNames, arrAttributeValues)                   '
'                                                                           '
' Description: Add an xmlnode to the specified locations.                   '
'                                                                           '
' Inputs: strXMLFile        -- The xml file to edit                         '
'         strLocation       -- Parent Location of the nodes.                '
'         strName           -- The name of the node to add.                 '
'         strValue          -- The value of the node to add.                '
'         arrAttributeNames -- Names of attribute nodes for the child.      '
'                              (optional)                                   '
'         arrAttributeValues-- Values of the nodes for the children.        '
'                              (optional)                                   '
'                                                                           '
' Outputs:  true  -- if the operation was successful                        '
'           false -- if an error occurred                                   '
'---------------------------------------------------------------------------'
Public Function AddNode(ByVal strXMLFile As String, _
                        ByVal strLocation As String, _
                        ByVal strName As String, _
                        ByVal strValue As String, _
                        Optional ByRef arrAttributeNames = "", _
                        Optional ByRef arrAttributeValues = "") As Boolean
  
  Dim objLocationNode As IXMLDOMNode
  Dim objNode As IXMLDOMNode
  Dim objAttrNode As IXMLDOMNode
  Dim bAttr As Boolean
  Dim i
  
  
  'Init
  mobjXMLDoc.async = False
  mobjXMLDoc.validateOnParse = False  'don't validate according to DTD
  mobjXMLDoc.resolveExternals = False
  bAttr = False
  
  'Load the document
  Call mobjXMLDoc.Load(strXMLFile)
  
    If mobjXMLDoc.parseError Then
    AddNode = False
    Exit Function
  End If
  
  'Get the location node
  Set objLocationNode = mobjXMLDoc.selectSingleNode(strLocation)
  
  If objLocationNode Is Nothing Then
    AddNode = False
    Exit Function
  End If
  
    
  'Check attribute node lengths
  If IsArray(arrAttributeNames) Then
    If IsArray(arrAttributeValues) Then
      If UBound(arrAttributeNames) <> UBound(arrAttributeValues) Then
         
        AddNode = False
        Exit Function
      End If
      
      bAttr = True
    Else
      AddNode = False
      Exit Function
    End If
  End If
  
  'Create the nodes!!!
  If Len(strName) > 0 Then
    Set objNode = mobjXMLDoc.createNode(NODE_ELEMENT, strName, "")
  
    'Set the child nodes value
    objNode.Text = strValue

    'set the attribute(if any)
    If bAttr Then
      If Len(arrAttributeNames(i)) > 0 Then
        Set objAttrNode = mobjXMLDoc.createNode(NODE_ATTRIBUTE, arrAttributeNames(i), "")
        objAttrNode.Text = arrAttributeValues(i)
        Call objNode.Attributes.setNamedItem(objAttrNode)
      End If
    End If
    
    'attach the node to the location
    Call objLocationNode.appendChild(objNode)
  End If
      
  'save the document
  Call mobjXMLDoc.save(strXMLFile)
  
  
  If mbPrettyPrint Then
    Call PrettyPrintXMLFile(strXMLFile, 2, 0)
  End If

  AddNode = True

End Function


'---------------------------------------------------------------------------'
' Function AddGroupOfNodes(strXMLFile, strLocation, arrNames, arrValues,    '
'                          arrAttributeNames, arrAttributeValues)           '
'                                                                           '
' Description: Add a set of xml nodes to an xml file. The nodes have parent '
'              in common and are inserted at the specified location.        '
'                                                                           '
' Inputs: strXMLFile        -- The xml file to edit                         '
'         strLocation       -- Parent Location of the nodes.                '
'         arrNames          -- The names of the nodes in the set            '
'         arrValues         -- The values of the nodes in the set           '
'         arrAttributeNames -- Names of attribute nodes for the child.      '
'                              (optional)                                   '
'         arrAttributeValues-- Values of the nodes for the children.        '
'                              (optional)                                   '
'                                                                           '
' Outputs:  true  -- if the operation was successful                        '
'           false -- if an error occurred                                   '
'---------------------------------------------------------------------------'
Public Function AddGroupOfNodes(ByVal strXMLFile As String, _
                                ByVal strLocation As String, _
                                ByRef arrNames, _
                                ByRef arrValues, _
                                Optional ByRef arrAttributeNames = "", _
                                Optional ByRef arrAttributeValues = "") As Boolean
  Dim objLocationNode As IXMLDOMNode
  Dim objNode As IXMLDOMNode
  Dim objAttrNode As IXMLDOMNode
  Dim bAttr As Boolean
  Dim i
  
  
  'Init
  mobjXMLDoc.async = False
  mobjXMLDoc.validateOnParse = False  'don't validate according to DTD
  mobjXMLDoc.resolveExternals = False
  bAttr = False
  
  'Load the document
  Call mobjXMLDoc.Load(strXMLFile)
  
    If mobjXMLDoc.parseError Then
    AddGroupOfNodes = False
    Exit Function
  End If
  
  'Get the location node
  Set objLocationNode = mobjXMLDoc.selectSingleNode(strLocation)
  
  If objLocationNode Is Nothing Then
    AddGroupOfNodes = False
    Exit Function
  End If
  
  'Make sure the node names & values exist
  If Not IsArray(arrNames) Or Not IsArray(arrValues) Then
    AddGroupOfNodes = False
    Exit Function
  End If
  
  If UBound(arrNames) <> UBound(arrValues) Then
    AddGroupOfNodes = False
    Exit Function
  End If
    
  'Check attribute node lengths
  If IsArray(arrAttributeNames) Then
    If IsArray(arrAttributeValues) Then
      If (UBound(arrAttributeNames) <> UBound(arrAttributeValues)) Or _
         (UBound(arrAttributeNames) <> UBound(arrNames)) Then
        AddGroupOfNodes = False
        Exit Function
      End If
      
      bAttr = True
    Else
      AddGroupOfNodes = False
      Exit Function
    End If
  End If
  
  'Create the nodes!!!
  For i = 0 To UBound(arrNames)
    If Len(arrNames(i)) > 0 Then
      'Create the child node
      Set objNode = mobjXMLDoc.createNode(NODE_ELEMENT, arrNames(i), "")
  
      'Set the child nodes value
      objNode.Text = arrValues(i)

      'set the attribute(if any)
      If bAttr Then
        If Len(arrAttributeNames(i)) > 0 Then
          Set objAttrNode = mobjXMLDoc.createNode(NODE_ATTRIBUTE, arrAttributeNames(i), "")
          objAttrNode.Text = arrAttributeValues(i)
          Call objNode.Attributes.setNamedItem(objAttrNode)
        End If
      End If
    
      'attach the node to the location
      Call objLocationNode.appendChild(objNode)
    End If
  Next
    
  'save the document
  Call mobjXMLDoc.save(strXMLFile)
  
  
  If mbPrettyPrint Then
    Call PrettyPrintXMLFile(strXMLFile, 2, 0)
  End If

  AddGroupOfNodes = True

End Function

'---------------------------------------------------------------------------'
' Function AddSet(strXMLFile, strLocation, strParent, arrNames, arrValues,  '
'                 arrAttributeNames, arrAttributeValues)                    '
'                                                                           '
' Description: Add a set of xml nodes to an xml file. The nodes have parent '
'              in common and are inserted at the specified location.        '
'                                                                           '
' Inputs: strXMLFile        -- The xml file to edit                         '
'         strLocation       -- Location to insert the set.                  '
'         strParent         -- The parent node to attach to the location    '
'         arrNames          -- The names of the nodes in the set            '
'         arrValues         -- The values of the nodes in the set           '
'         arrAttributeNames -- Names of attribute nodes for the child.      '
'                              (optional)                                   '
'         arrAttributeValues-- Values of the nodes for the children.        '
'                              (optional)                                   '
'                                                                           '
' Outputs:  true  -- if the operation was successful                        '
'           false -- if an error occurred                                   '
'---------------------------------------------------------------------------'
Public Function AddSet(ByVal strXMLFile As String, _
                       ByVal strLocation As String, _
                       ByVal strParent As String, _
                       arrNames, _
                       arrValues, _
                       Optional ByRef arrAttributeNames = "", _
                       Optional ByRef arrAttributeValues = "") As Boolean

  Dim objLocationNode As IXMLDOMNode  'Node where set will be added
  Dim objParentNode As IXMLDOMNode    'Parent node of the set
  Dim objNode As IXMLDOMNode          'Nodes of the set
  Dim objAttrNode As IXMLDOMNode      'Attribute node
  Dim bAttr As Boolean                'flag indicates whether to add attributes
  Dim i
  
  
  'Init
  mobjXMLDoc.async = False            'synchronous file i/o
  mobjXMLDoc.validateOnParse = False  'don't validate according to DTD
  mobjXMLDoc.resolveExternals = False
  bAttr = False
  
  
  'Load the document
  Call mobjXMLDoc.Load(strXMLFile)
  
  If mobjXMLDoc.parseError Then
    AddSet = False
    Exit Function
  End If
  
  'Get the location node
  Set objLocationNode = mobjXMLDoc.selectSingleNode(strLocation)
  
  If objLocationNode Is Nothing Then
    AddSet = False
    Exit Function
  End If
  
  'Make sure the node names & values exist
  If Not IsArray(arrNames) Or Not IsArray(arrValues) Then
    AddSet = False
    Exit Function
  End If
  
  If UBound(arrNames) <> UBound(arrValues) Then
    AddSet = False
    Exit Function
  End If
    
  'Check attribute node lengths
  If IsArray(arrAttributeNames) Then
    If IsArray(arrAttributeValues) Then
      If (UBound(arrAttributeNames) <> UBound(arrAttributeValues)) Or _
         (UBound(arrAttributeNames) <> UBound(arrNames)) Then
        AddSet = False
        Exit Function
      End If
      
      bAttr = True
    Else
      AddSet = False
      Exit Function
    End If
  End If
  
  'Create the nodes!!!
  'Create the parent node
  Set objParentNode = mobjXMLDoc.createNode(NODE_ELEMENT, strParent, "")
  
  For i = 0 To UBound(arrNames)
    If Len(arrNames(i)) > 0 Then
      'Create the child node
      Set objNode = mobjXMLDoc.createNode(NODE_ELEMENT, arrNames(i), "")
  
      'Set the child nodes value
      objNode.Text = arrValues(i)

      'set the attribute(if any)
      If bAttr Then
        If Len(arrAttributeNames(i)) > 0 Then
          Set objAttrNode = mobjXMLDoc.createNode(NODE_ATTRIBUTE, arrAttributeNames(i), "")
          objAttrNode.Text = arrAttributeValues(i)
          Call objNode.Attributes.setNamedItem(objAttrNode)
        End If
      End If
    
      'attach the node to the parent
      Call objParentNode.appendChild(objNode)
    End If
  Next
  
  'attach the parent node to the specified location
  Call objLocationNode.appendChild(objParentNode)
    
  'save the document
  Call mobjXMLDoc.save(strXMLFile)
  
  
  If mbPrettyPrint Then
    Call PrettyPrintXMLFile(strXMLFile, 2, 0)
  End If

  AddSet = True

End Function

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function PrettyPrintXMLFile(strFilename, intTabSpacing, intStartPos)

  Dim objConfigHelper As Object
  
  Set objConfigHelper = CreateObject("MTConfigHelper.ConfigHelper")
  
  Call objConfigHelper.PrettyPrintXMLFile(strFilename, intTabSpacing, intStartPos)
  Exit Function
  
  
  
  

  Dim objConfig As MTConfigLib.IMTConfig
  Dim objPropSet As MTConfigLib.IMTConfigPropSet
  Dim bChecksumMatch As Boolean
  
  On Error GoTo ErrorHandler
  
  'Create the object
  Set objConfig = CreateObject("MetraTech.MTConfig.1")
  
  'Turn off AutoEnumConversion
  objConfig.AutoEnumConversion = False
  
  If Not objConfig Is Nothing Then
    'Load the file
    Set objPropSet = objConfig.ReadConfiguration(strFilename, bChecksumMatch)
    
    'Save the file, which will format it correctly
    Call objPropSet.Write(strFilename)
  End If
  
ErrorHandler:
  If Err Then
    Exit Function
  End If
End Function

'---------------------------------------------------------------------------'
' Function ValidateFormat(strXMLFile)                                       '
'                                                                           '
' Description: Validates XML file for correct format                        '
'              raises error on parse error                                  '
'                                                                           '
' Inputs:  strXMLFile            -- XML file                                '
'                                                                           '
'---------------------------------------------------------------------------'
Public Function ValidateFormat(strXMLFile)
  
  mobjXMLDoc.async = False
  mobjXMLDoc.validateOnParse = False  'don't validate according to DTD
  mobjXMLDoc.resolveExternals = False
  
  'Load the document
  mobjXMLDoc.Load strXMLFile
  
  'Check for a parse error
  If mobjXMLDoc.parseError Then
    Err.Raise mobjXMLDoc.parseError.errorCode, "XMLHelper", _
              "Error parsing '" & strXMLFile & "' line: " & mobjXMLDoc.parseError.Line & _
              ", " & mobjXMLDoc.parseError.reason
  End If
End Function
