VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "AttributeItem"
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
' Attribute.cls -- Contains information about attributes.  Attributes       '
'                   consist of name/value pairs.                            '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim mstrName As String        'Name of the attribute
Dim mstrValue As String       'Value of the attribute
Dim mstrText As String        'Text for the attribute

Dim mstrID As String

'Used in popups
Private mstrPopupHeader As String           'Header for the popup - only for groups/lists (not Properties)
Private mstrPopupTitle As String            'Title for the popup - only groups/lists
Private mstrPopupText As String             'Text for the popup - only groups/lists

Dim mbOptional As Boolean                   'Attribute is optional
Dim mbReadOnly As Boolean                   'Attribute is read-only
Dim mbHidden As Boolean                     'The property exists, but is not visible
                                            'to the UI
                                            
Private mbOverride As Boolean               'Indicates that an override exists for this node
Private mstrOverride As String              'Override value
                                            
Private mbRefreshOnChange As Boolean
                                            
Private meEditType As FlexEditType

Private mcollOptions As New Collection            'Input options
Private mcollOverrideOptions As New Collection    'Input options -- overridden

Private mbOptionOverride As Boolean

Private mcollDisplayConditions As New Collection  'Used for the conditional display of attributes
                                                  'in poups.
Private mcollOptionConditions As New Collection   'Used when the set of options can be conditional

Private mobjOptionNodeList As IXMLDOMNodeList     'All option nodes
Private mstrOptionType As String                  'Type of options for this node

Private meOriginalEditType As FlexEditType
Private mstrOriginalOptionType As String

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : RenderPopup(objXSLNode, objXMLNode, strExtra)             '
' Description   : Render this attribute's part of a popup                   '
' Inputs        : objXSLNode -- XSL for the popup                           '
'               : objXMLNode -- relevant XML node                           '
'               : strExtra   -- extra data for the input name               '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function RenderPopup(ByRef objXSLNode As IXMLDOMNode, _
                            ByRef objXMLNode As IXMLDOMNode, _
                            ByRef strExtra As String, _
                            ByRef strAction As String)
  Dim objXMLDoc As New DOMDocument30
  Dim objPromptNode As IXMLDOMNode
  Dim objInputNode As IXMLDOMNode
  Dim objAttributeNode As IXMLDOMAttribute
  Dim strHTML As String
  Dim strValue As String
  Dim eEditType As FlexEditType
    
  'Set the prompt
  Set objPromptNode = objXSLNode.selectSingleNode("//td[@id='DIALOG_PROMPT']")
  
  Call SetNodeText(objPromptNode, mstrText)
  
  'Set the input
  If Not objXMLNode Is Nothing Then
'  If strAction <> "ADD" And Not objXMLNode Is Nothing Then
    Set objAttributeNode = objXMLNode.Attributes.getNamedItem(mstrName)
  End If
  
  
  If Not CheckVisible(objXMLNode, Me, strAction) And Not mbOptional Or mbHidden Then
    eEditType = HIDDENTEXT
    'If hidden, remove the prompt
    Call objPromptNode.parentNode.removeChild(objPromptNode)
  Else
    eEditType = meEditType
  End If
  
  
  If mbOverride Then
    If objAttributeNode Is Nothing Then
      Set objAttributeNode = objXMLDoc.createAttribute(mstrName)
    End If
    
    objAttributeNode.Value = mstrOverride
    Call objXMLNode.Attributes.removeNamedItem(mstrName)
    Call objXMLNode.Attributes.setNamedItem(objAttributeNode)
  End If
  
  'Get the attribute's value or the overridden value
  If Not objAttributeNode Is Nothing Then
    strValue = objAttributeNode.Value
  Else
    strValue = ""
  End If
  
  'If a hidden input, use the value from the schema
  If eEditType = HIDDENTEXT Then
    strValue = mstrValue
  End If
  
  'Set the values of strings
  If UCase(mstrOptionType) = "ENUMSPACE" Then
    If Len(strValue) > 0 Then
      gstrEnumSpace = strValue
    End If
  
  ElseIf UCase(mstrOptionType) = "ENUMTYPE" Then
    'RE-Load the enumtypes in case the enumspace
    'changed
    If Len(strValue) > 0 Then
      gstrEnumType = strValue
    End If
    
    Call LoadOptions(mstrOptionType, Me)
    
  ElseIf UCase(mstrOptionType) = "ENUMERATOR" Then
    
    'Load the enumerators
    Call LoadOptions(mstrOptionType, Me)
  
  End If
  
  'check the options
  Call CheckOptions(objXMLNode, Me)
  
  'Add the attribute
  If mbOptionOverride Then
    Call MakeInputNode(eEditType, _
                       objXSLNode, _
                       "EditAttribute" & strExtra, _
                       strValue, _
                       mcollOverrideOptions, _
                       mbRefreshOnChange)
  Else
    Call MakeInputNode(eEditType, _
                       objXSLNode, _
                       "EditAttribute" & strExtra, _
                       strValue, _
                       mcollOptions, _
                       mbRefreshOnChange)
  End If
                           
                                    
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : ModifyXML(objXML, strValue)                               '
' Description   : Modify this attributes value. Removes the attribute if it '
'               : has no value. Adds it if it is not there.                 '
' Inputs        : objXML  --  XML object                                    '
'               : strValue  -- Value of the attribute                       '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function ModifyXML(ByRef objXMLNode As IXMLDOMNode, ByRef strValue As String)
  Dim objXMLDoc As New DOMDocument30
  Dim objAttributeNode As IXMLDOMAttribute
  
  'First, check to see if the attribute exists
  Set objAttributeNode = objXMLNode.Attributes.getNamedItem(mstrName)
  
  'If the attribute does exist, modify it.  Otherwise, create a new one
  If Not objAttributeNode Is Nothing Then
  
    'If the attribute is optional and has no value, remove it.
    'also remove it if it wasn't visible
    If mbOptional And (Len(strValue) = 0 Or Not CheckVisible(objXMLNode, Me)) Then
      Call objXMLNode.Attributes.removeNamedItem(mstrName)
    Else
      objAttributeNode.Value = strValue
    End If
  
  'Otherwise, create the node and add it
  Else
    'Don't add an optional node with no value
    If mbOptional And Len(strValue) = 0 Then
      Exit Function
    End If
    
    Set objAttributeNode = objXMLDoc.createAttribute(mstrName)
    objAttributeNode.Value = strValue
    
    Call objXMLNode.Attributes.setNamedItem(objAttributeNode)
    
  End If
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Properties
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Text
Public Property Let Text(ByVal strText As String)
  Let mstrText = strText
End Property

Public Property Get Text() As String
  Let Text = mstrText
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Name
Public Property Let Name(ByVal strName As String)
  Let mstrName = strName
End Property

Public Property Get Name() As String
  Let Name = mstrName
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Value
Public Property Let Value(ByVal strValue As String)
  Let mstrValue = strValue
End Property

Public Property Get Value() As String
  Let Value = mstrValue
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Readonly
Public Property Let ReadOnly(ByVal bReadOnly As Boolean)
  Let mbReadOnly = bReadOnly
End Property

Public Property Get ReadOnly() As Boolean
  Let ReadOnly = mbReadOnly
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
'Hidden
Public Property Let Hidden(ByVal bHidden As Boolean)
  Let mbHidden = bHidden
End Property

Public Property Get Hidden() As Boolean
  Let Hidden = mbHidden
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' EditType
Public Property Let EditType(ByVal eEditType As FlexEditType)
  Let meEditType = eEditType
End Property

Public Property Get EditType() As FlexEditType
  Let EditType = meEditType
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' OriginalEditType
Public Property Let OriginalEditType(ByVal eEditType As FlexEditType)
  Let meOriginalEditType = eEditType
End Property

Public Property Get OriginalEditType() As FlexEditType
  Let OriginalEditType = meOriginalEditType
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Options
Public Property Get Options() As Collection
  Set Options = mcollOptions
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
' ID
Public Property Get ID() As String
  Let ID = mstrID
End Property

Public Property Let ID(ByVal strID As String)
  Let mstrID = strID
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get DisplayConditions() As Collection
  Set DisplayConditions = mcollDisplayConditions
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get OverrideFlag() As Boolean
  Let OverrideFlag = mbOverride
End Property

Public Property Let OverrideFlag(ByVal Val As Boolean)
  Let mbOverride = Val
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get OverrideValue() As String
  Let OverrideValue = mstrOverride
End Property

Public Property Let OverrideValue(ByVal Val As String)
  Let mstrOverride = Val
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get RefreshOnChange() As Boolean
  Let RefreshOnChange = mbRefreshOnChange
End Property

Public Property Let RefreshOnChange(ByVal bVal As Boolean)
  Let mbRefreshOnChange = bVal
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get OptionConditions() As Collection
  Set OptionConditions = mcollOptionConditions
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Set OptionNodes(ByRef objNodeList As IXMLDOMNodeList)
  Set mobjOptionNodeList = objNodeList
End Property

Public Property Get OptionNodes() As IXMLDOMNodeList
  Set OptionNodes = mobjOptionNodeList
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get OverrideOptions() As Collection
  Set OverrideOptions = mcollOverrideOptions
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get OptionOverrideFlag() As Boolean
  Let OptionOverrideFlag = mbOptionOverride
End Property

Public Property Let OptionOverrideFlag(ByVal Val As Boolean)
  If mbOptionOverride And Not Val Then
    meEditType = meOriginalEditType
    mstrOptionType = mstrOriginalOptionType
  End If
  
  Let mbOptionOverride = Val
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get OptionType() As String
  Let OptionType = mstrOptionType
End Property

Public Property Let OptionType(ByVal Val As String)
  Let mstrOptionType = Val
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get OriginalOptionType() As String
  Let OriginalOptionType = mstrOriginalOptionType
End Property

Public Property Let OriginalOptionType(ByVal Val As String)
  Let mstrOriginalOptionType = Val
End Property
