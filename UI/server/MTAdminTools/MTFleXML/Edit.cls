VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Edit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
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
' MTFleXML.Edit                                                             '
'                                                                           '
' Description:  This file contains the main routines used by the MTFleXML   '
'               editor to modify files.                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mobjXML As New DOMDocument30      'XML dom document
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Functions                                                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function ModifyXML(ByRef strXPath As String, _
                          ByRef intIndex As Integer, _
                          ByRef objXMLDoc As DOMDocument30, _
                          ByRef objItem, _
                          ByRef arrNames, _
                          ByRef arrVals, _
                          ByRef strAction As String)
  
  Dim objAttributeNode As IXMLDOMAttribute
  Dim objNodeList As IXMLDOMNodeList        'List of matching nodes
  Dim objNode As IXMLDOMNode                'Attribute nodes
  Dim objParentNode As IXMLDOMNode          'Parent node, used when adding lists
  Dim strParentXpath As String              'Parent Xpath
  
  Dim strValue As String
  
  Dim bNotParent As Boolean
  
  'Possible Item types to pass in
  Dim objList As List
  Dim objProperty As Property
  Dim objAttribute As AttributeItem

  Dim i As Integer                          'counter
  
    Select Case UCase(TypeName(objItem))
      Case "ATTRIBUTEITEM"
        Set objAttribute = objItem
        'If the item is an attribute, then the XPath should yield the attribute node
        'since attributes may be optional, search based on the parent node
        strParentXpath = Left(strXPath, InStrRev(strXPath, "/") - 1)
        
        'Search for the parent
        Set objNodeList = objXMLDoc.selectNodes(strParentXpath)
        
        If objNodeList.length > 0 And objNodeList.length <= intIndex Then
          Set objNode = objNodeList.Item(intIndex - 1)
          
          Call objAttribute.ModifyXML(objNode, CStr(arrVals(0)))
        End If
        
        
      Case "PROPERTY"
        Set objProperty = objItem
        
        'Properties have one value, and many attributes, and be the property node itself
        strParentXpath = Left(strXPath, InStrRev(strXPath, "/") - 1)
        
        'Search for the parent
        Set objNodeList = objXMLDoc.selectNodes(strParentXpath)
        
        If objNodeList.length > 0 And objNodeList.length <= intIndex Then
          Set objNode = objNodeList.Item(intIndex - 1)
          
          'Find the value for this property, and modify the xml
          For i = 0 To UBound(arrNames)
            If arrNames(i) = "EditProperty:" & objProperty.XPath Then
              Call objProperty.ModifyXML(objNode, CStr(arrVals(i)), arrNames, arrVals, strAction)
              Exit For
            End If
          Next
        End If
        
      Case "LIST"
        Set objList = objItem
          
        Set objNodeList = objXMLDoc.selectNodes(strXPath)
        
        If objNodeList.length > 0 Or strAction = "ADD" Then 'And objNodelist.length >= intIndex Then
          
          'If removing
          If strAction = "UPDATE" Then
            'For extended lists
            Select Case objList.ListType
              Case EXTENDED
                Set objNode = objNodeList.Item(intIndex - 1)
                Call objNode.parentNode.removeChild(objNode)
                
            End Select
          
            Exit Function
          End If
          
          'If adding, get the parent node
          If strAction = "ADD" Then
            strParentXpath = Left(strXPath, InStrRev(strXPath, "/") - 1)
            Set objParentNode = objXMLDoc.selectSingleNode(strParentXpath)
            
            'Make a node for extended lists
            Set objNode = objXMLDoc.createNode(NODE_ELEMENT, Right(objList.XPath, Len(objList.XPath) - InStrRev(objList.XPath, "/")), "")
          Else
            Set objNode = objNodeList.Item(intIndex - 1)
          End If
          
          'Edit attributes if extended lists
          If objList.ListType = EXTENDED Then
            For Each objAttribute In objList.Attributes
              
              'Handle hidden attributes with fixed values
              If objAttribute.Hidden Then
                Call objAttribute.ModifyXML(objNode, objAttribute.Value)
              
              'Else use the form value
              Else
                For i = 0 To UBound(arrNames)
                  If arrNames(i) = "EditAttribute:" & objAttribute.Name Then
                    Call objAttribute.ModifyXML(objNode, CStr(arrVals(i)))
                    Exit For
                  End If
                Next
              End If
            Next
            
            bNotParent = False
          Else
            bNotParent = True
          End If
       
          'Properties
          For Each objProperty In objList.Properties
          
            'If read-only, make no changes
            If Not objProperty.ReadOnly Then
            
              'Different case if the property is hidden
              If objProperty.Hidden Then
                'Handle different list types differently
                'Flat extended lists
                If objList.ListType = FLATEXTENDED Then
                  If strAction = "ADD" Then
                    Set objNode = objXMLDoc.createNode(NODE_ELEMENT, objProperty.XPath, "")
                  Else
                    Set objNode = objNodeList.Item(0).selectNodes(objProperty.XPath).Item(intIndex - 1)
                  End If
                End If
                
                'SIMPLE Lists
                If objList.ListType = SIMPLE And strAction = "ADD" Then
                  Set objNode = objXMLDoc.createNode(NODE_ELEMENT, objProperty.XPath, "")
                End If
                
                Call objProperty.ModifyXML(objNode, objProperty.Value, arrNames, arrVals, strAction, bNotParent)
                
                'If the list is simple or flatextended, append the new node
                If strAction = "ADD" Then
                  If objList.ListType = FLATEXTENDED Or SIMPLE Then
                    Call objParentNode.appendChild(objNode)
                  End If
                End If
              
              'For non-hidden properties
              Else
                'Check for the property masked out, only for extended properties
                If objList.ListType = EXTENDED Then
                  If strAction <> "ADD" Then
                  'If the property is not visible due to processing of conditions, clear it
                    If Not CheckVisible(objNode, objProperty) Then
                      Call objProperty.ModifyXML(objNode, "", arrNames, arrVals, strAction, bNotParent)
                    End If
                  End If
                End If
                
                For i = 0 To UBound(arrNames)
                  If arrNames(i) = "EditProperty:" & objProperty.XPath Then
                    
                    'Handle different list types differently
                    'Flat extended lists
                    If objList.ListType = FLATEXTENDED Then
                      If strAction = "ADD" Then
                        Set objNode = objXMLDoc.createNode(NODE_ELEMENT, objProperty.XPath, "")
                      Else
                        Set objNode = objNodeList.Item(0).selectNodes(objProperty.XPath).Item(intIndex - 1)
                      End If
                    End If
                    
                    'SIMPLE Lists
                    If objList.ListType = SIMPLE And strAction = "ADD" Then
                      Set objNode = objXMLDoc.createNode(NODE_ELEMENT, objProperty.XPath, "")
                    End If
                    
                    'Fix so that EXTENDED lists don't have optional properties written
                    If objList.ListType = SIMPLE Or objList.ListType = FLATEXTENDED Then
                      Call objProperty.ModifyXML(objNode, CStr(arrVals(i)), arrNames, arrVals, strAction, bNotParent)
                    Else
                      'Never pass ADD for extended lists
                      Call objProperty.ModifyXML(objNode, CStr(arrVals(i)), arrNames, arrVals, "UPDATE", bNotParent)
                    End If
                    
                    'If the list is simple or flatextended, append the new node
                    If strAction = "ADD" Then
                      If objList.ListType = FLATEXTENDED Or SIMPLE Then
                        Call objParentNode.appendChild(objNode)
                      End If
                    End If
                    
                    'Exit the loop, move to the next property
                    Exit For
                  End If
                Next
              End If
            End If          'not objProperty.ReadOnly
          Next
          
          'Only add extended list once
          If strAction = "ADD" Then
            If objList.ListType = EXTENDED Then
              Call objParentNode.appendChild(objNode)
            End If
          End If
          
        End If
     
    End Select
    
  'End If



End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function OverrideXML(ByRef strXPath As String, _
                            ByRef intIndex As Integer, _
                            ByRef objXMLDoc As DOMDocument30, _
                            ByRef objItem, _
                            ByRef arrNames, _
                            ByRef arrVals, _
                            ByRef strAction As String)
  
  Dim objAttributeNode As IXMLDOMAttribute
  Dim objNodeList As IXMLDOMNodeList        'List of matching nodes
  Dim objNode As IXMLDOMNode                'Attribute nodes
  Dim objParentNode As IXMLDOMNode          'Parent node, used when adding lists
  Dim strParentXpath As String              'Parent Xpath
  
  Dim strValue As String
  
  Dim bNotParent As Boolean
  
  'Possible Item types to pass in
  Dim objList As List
  Dim objProperty As Property
  Dim objAttribute As AttributeItem

  Dim i As Integer                          'counter
  
  Select Case UCase(TypeName(objItem))
    Case "ATTRIBUTEITEM"
      Set objAttribute = objItem
      objAttribute.OverrideFlag = True
      objAttribute.OverrideValue = CStr(arrVals(0))
    
    Case "PROPERTY"
      Set objProperty = objItem
        
      'Find the value for this property, and modify the xml
      For i = 0 To UBound(arrNames)
        If arrNames(i) = "EditProperty:" & objProperty.XPath Then
          Call objProperty.OverrideXML(CStr(arrVals(i)), arrNames, arrVals)
          Exit For
        End If
      Next
      
    Case "LIST"
      Set objList = objItem
        
      'Edit attributes if extended lists
      If objList.ListType = EXTENDED Then
        For Each objAttribute In objList.Attributes
          
          'Handle hidden attributes with fixed values
          If Not objAttribute.Hidden Then
            For i = 0 To UBound(arrNames)
              If arrNames(i) = "EditAttribute:" & objAttribute.Name Then
                objAttribute.OverrideFlag = True
                objAttribute.OverrideValue = arrVals(i)
                
                'If UCase(objAttribute.OptionType) = "ENUMSPACE" Or _
                '   UCase(objAttribute.OptionType) = "ENUMTYPE" Or _
                '   UCase(objAttribute.OptionType) = "ENUMERATOR" Then

                '   Call LoadOptions(objAttribute.OptionType, objAttribute)
                'End If
                
                Exit For
              End If
            Next
          End If
        Next
      End If
   
      'Properties
      For Each objProperty In objList.Properties
      
        'Different case if the property is hidden
        If Not objProperty.Hidden Then

      
          For i = 0 To UBound(arrNames)
            If arrNames(i) = "EditProperty:" & objProperty.XPath Then
              
              'Handle different list types differently
              Call objProperty.OverrideXML(CStr(arrVals(i)), arrNames, arrVals)
              'Exit the loop, move to the next property
              Exit For
            End If
          Next
        End If
      Next
      
  End Select
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Subs                                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Private Sub Class_Initialize()
  mobjXML.async = False
  mobjXML.validateOnParse = False
End Sub
