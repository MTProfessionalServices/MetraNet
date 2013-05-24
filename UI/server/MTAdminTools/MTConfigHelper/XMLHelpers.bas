Attribute VB_Name = "XMLHelpers"
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
' XMLHelpers.bas                                                            '
' Simple XML helper functions                                               '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function GetNodeText(ByRef objXML As IXMLDOMNode, _
                     ByRef strXPath As String) As String
  Dim objNode As IXMLDOMNode
  
  Set objNode = objXML.selectSingleNode(strXPath)
  
  If Not objNode Is Nothing Then
    GetNodeText = objNode.Text
  Else
    GetNodeText = ""
  End If
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function PopulateAttributes(ByRef objXML As IXMLDOMNode, _
                            ByRef strXPath As String, _
                            ByRef objProperty As Object)
  Dim objAttribute As IXMLDOMAttribute
  Dim objNode As IXMLDOMNode
  
  If Not objProperty Is Nothing Then
  
    If Not objXML Is Nothing Then
  
      Set objNode = objXML.selectSingleNode(strXPath)
  
      If Not objNode Is Nothing Then
        For Each objAttribute In objNode.Attributes
          Call objProperty.SetAttributeValue(objAttribute.Name, objAttribute.value)
        Next
      End If
    End If
  End If
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function PrettyPrintXML(ByVal strPath As String, _
                        ByVal intIndent As Integer, _
                        ByVal intStart As Integer, _
                        Optional ByVal bStringOnly As Boolean) As String
  
  Dim objXML As New DOMDocument30
  Dim objFSO As New FileSystemObject
  Dim objTxtStream As TextStream
  Dim strXML As String
  
  
  objXML.async = False
  objXML.validateOnParse = False
  objXML.resolveExternals = False
  
  If bStringOnly Then
    Call objXML.loadXML(strPath)
  Else
    Call objXML.Load(strPath)
  End If
  
  If Not objXML.parseError Then
    strXML = PrettyPrintNode(objXML, intIndent, intStart - intIndent)
  
    If Not bStringOnly Then
      Set objTxtStream = objFSO.CreateTextFile(strPath, True)
  
      Call objTxtStream.Write(strXML)
  
      Call objTxtStream.Close
    End If
    
    PrettyPrintXML = strXML
  End If
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function PrettyPrintNode(ByRef objNode As IXMLDOMNode, intIndent, intStart)
  Dim strOut As String
  Dim strIndent As String
  Dim objAttribute As IXMLDOMAttribute
  Dim objChildNode As IXMLDOMNode
  
  Dim i As Integer
  
  'Create the indent
  For i = 1 To intStart
    strIndent = strIndent & " "
  Next
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  'not handled
  'NODE_NOTATION
  '
  'unknown
  'NODE_ENTITY, NODE_ENTITY_REFERENCE
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  If Not objNode Is Nothing Then
    Select Case objNode.nodeType
      Case NODE_CDATA_SECTION
        strOut = "<![CDATA[" & objNode.Text & "]]>"
      
      Case NODE_COMMENT
        strOut = "<!-- " & objNode.Text & " -->"
      
      Case NODE_TEXT
        strOut = objNode.Text
        
      Case NODE_PROCESSING_INSTRUCTION
        strOut = strIndent & objNode.xml
        
      'Do nothings
      Case NODE_ATTRIBUTE
      Case NODE_NOTATION
      Case NODE_DOCUMENT_FRAGMENT
        
      'NODE_ELEMENT, NODE_DOCUMENT, (NODE_ENTITY, NODE_ENTITY_REFERENCE -- Behavior unknown)
      Case Else
      
        'DOCTYPE
        If objNode.nodeType = NODE_DOCUMENT_TYPE Then
          strOut = strIndent & "<!DOCTYPE>"
        
        'Don't create tag for DOCUMENT
        ElseIf objNode.nodeType = NODE_DOCUMENT Then
        
        Else
          strOut = strIndent & "<" & objNode.nodeName
        End If
        
        If Not objNode.Attributes Is Nothing Then
          For Each objAttribute In objNode.Attributes
            strOut = strOut & " " & objAttribute.Name
            strOut = strOut & "=""" & objAttribute.value & """"
          Next
        End If
        
        If objNode.nodeType <> NODE_DOCUMENT_TYPE And objNode.nodeType <> NODE_DOCUMENT Then
          strOut = strOut & ">"
        End If
        
        For i = 0 To objNode.childNodes.Length - 1
          Set objChildNode = objNode.childNodes(i)
          
          If objChildNode.nodeType = NODE_ELEMENT Then
            strOut = strOut & vbNewLine
          End If
          
          strOut = strOut & PrettyPrintNode(objChildNode, intIndent, intStart + intIndent)
          
          If objChildNode.nodeType = NODE_ELEMENT Then
            If i = objNode.childNodes.Length - 1 Then
              strOut = strOut & vbNewLine
            End If
            
            strOut = strOut & strIndent
          End If
        Next
        
        If objNode.nodeType <> NODE_DOCUMENT_TYPE And objNode.nodeType <> NODE_DOCUMENT Then
          strOut = strOut & "</" & objNode.nodeName & ">"
        End If
    End Select
  End If

  PrettyPrintNode = strOut
End Function

