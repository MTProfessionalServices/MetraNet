Attribute VB_Name = "XMLHelper"
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
' Function      : GetNodeText(...)                                          '
' Description   : Get the text of an xml node.                              '
' Inputs        : objXML      - xml node/document                           '
'               : strQuery    - query to get the node                       '
'               : bRequired   - if the node is required (optional, default  '
'               :               is false.                                   '
' Outputs       : The value of the node, or raise an error if a required    '
'               : node does not exist.                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetNodeText(ByRef objXML As IXMLDOMNode, _
                            ByVal strQuery As String, _
                            Optional ByVal bRequired As Boolean = False)
  Dim strError As String
  Dim objNode As IXMLDOMNode
  
  If Not objXML Is Nothing Then
  
    'Get the node
    Set objNode = objXML.selectSingleNode(strQuery)
  
    If Not objNode Is Nothing Then
      GetNodeText = objNode.Text
    Else
      If bRequired Then
        strError = Replace(MTFLEXML_ERROR_04250, "[NODE_NAME]", strQuery)
        Call RaiseError(strError, "GetNodeText", 4250, LOG_APPLICATION_ERROR)
      Else
        GetNodeText = ""
      End If
    End If
  Else
    GetNodeText = ""
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CheckNodeText(...)                                        '
' Description   : Return true if the node text is matched.  False otherwise.'
' Inputs        : objXML      - xml node/document                           '
'               : strQuery    - query to get the node                       '
'               : strValue    - value to compare                            '
' Outputs       : True or false, depending on the result of the comparison. '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function CheckNodeText(ByRef objXML As IXMLDOMNode, _
                              ByVal strQuery As String, _
                              ByVal strValue As String) As Boolean

  If UCase(GetNodeText(objXML, strQuery)) = UCase(strValue) Then
    CheckNodeText = True
  Else
    CheckNodeText = False
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetAttributeText(...)                                     '
' Description   : Get the text of an xml node attribute.                    '
' Inputs        : objXML        - xml node/document                         '
'               : strAttribute  - name of the attribute                     '
'               : bRequired     - indicates whether the attribute is        '
'               :                 required or not (optional, default=false) '
' Outputs       : The value of the attribute, or raise an error if a        '
'               : required attribute does not exist.                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetAttributeText(ByRef objXML As IXMLDOMNode, _
                                 ByVal strAttribute As String, _
                                 Optional ByVal bRequired As Boolean = False)
  Dim objAttribute As IXMLDOMAttribute
  Dim strError As String
  
  On Error GoTo ErrorHandler
  
  Set objAttribute = objXML.Attributes.getNamedItem(strAttribute)
  
  If Not objAttribute Is Nothing Then
    GetAttributeText = objAttribute.Text
  Else
    If bRequired Then
      strError = Replace(MTFLEXML_ERROR_04251, "[ATTRIBUTE_NAME]", strAttribute)
      strError = Replace(strError, "[NODE_NAME]", objXMLNode.nodeName)
      Call RaiseError(strError, "GetAttributeText", 4251, LOG_APPLICATION_ERROR)
    Else
      GetAttributeText = ""
    End If
  End If
  
ErrorHandler:
  If Err Then
  
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CheckAttributeText(...)                                   '
' Description   : Check the value of an attribute.                          '
' Inputs        : objXML        - xml node/document                         '
'               : strAttribute  - name of the attribute                     '
'               : strValue      - value to check                            '
' Outputs       : The value of the attribute, or raise an error if a        '
'               : required attribute does not exist.                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function CheckAttributeText(ByRef objXML As IXMLDOMNode, _
                            ByVal strAttribute As String, _
                            ByVal strValue As String)
  
  If UCase(GetAttributeText(objXML, strAttribute)) = UCase(strValue) Then
    CheckAttributeText = True
  Else
    CheckAttributeText = False
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : ReplaceNodeText(objNode, strSearch, strReplace)           '
' Description   : Replace all occurrences of strText in the currrent node   '
'               : or it's subnodes.                                         '
' Inputs        : objNode -- Node to replace text for or containing nodes   '
'               :            to have text replaced.                         '
'               : strSearch -- Text to search for                           '
'               : strReplace -- Text to replace with                        '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ReplaceNodeText(ByRef objNode As IXMLDOMNode, _
                              ByRef strSearch As String, _
                              ByRef strReplace As String)
  Dim objChildNode As IXMLDOMNode     '
    
  'If no child nodes, replace the text
  If objNode.childNodes.length = 0 Then
    If objNode.Text = strSearch Then
      Call SetNodeText(objNode, strReplace)
    End If
  
  'Else search the children and replace
  Else
    For Each objChildNode In objNode.childNodes
      Call ReplaceNodeText(objNode, strSearch, strReplace)
    Next
  End If
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetClonedNode(objNode, strSearch, bDeep)                  '
' Description   : Get a clone of a node specified by strSearch. The node    '
'               : searched for should be a child of objNode.                '
' Inputs        : objNode   -- node containing the node to clone            '
'               : strSearch -- XSL pattern query for the node to clone.     '
'               : bDeep     -- get child nodes                              '
' Outputs       : The cloned node.                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function GetClonedNode(ByRef objNode As IXMLDOMNode, _
                       ByRef strSearch As String, _
                       ByRef bDeep As Boolean) As IXMLDOMNode
  Set GetClonedNode = objNode.selectSingleNode(strSearch).cloneNode(bDeep)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : PropSetPrint(strXMLFile)                                  '
' Description   : Use propset to pretty print the xml file.                 '
' Inputs        : strXMLFile -- XML File to pretty print.                   '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function PropSetPrint(ByVal strXMLFile As String)
  Dim objConfig As New MTConfig
  Dim objPropSet As MTConfigPropSet
  Dim bChecksum As Boolean
  
  bChecksum = False
  
  'Don't convert enums to their ids
  objConfig.AutoEnumConversion = False
    
  'Read the file
  Set objPropSet = objConfig.ReadConfiguration(strXMLFile, bChecksum)
  
  'Write the file
  Call objPropSet.Write(strXMLFile)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : SetNodeText(objNode, strText)                             '
' Description   : Set the text of the node.  If a CDATA section exists, put '
'               : the text in the CDATA section.                            '
' Inputs        : objNode -- Node to set the text for.                      '
'               : strText -- Text for the node.                             '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function SetNodeText(ByRef objNode As IXMLDOMNode, ByRef strText As String)
  Dim objChildNode As IXMLDOMNode
  
  For Each objChildNode In objNode.childNodes
    If objChildNode.nodeType = NODE_CDATA_SECTION Then
      objChildNode.Text = strText
      Exit Function
    End If
  Next
  
  'A CDATA section wasn't found, so set the node text directly
  objNode.Text = strText

End Function
