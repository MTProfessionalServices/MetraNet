VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Property"
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
' Property.cls -- Contains schema information for an an editable property.  '
'                 Lists and groups consist of properties.                   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mstrXPath As String                 'Description of the property
Private mstrSiblingXPath As String          'xpath of previous sibling
Private mstrDisplayName As String           'Display name for the property
Private mstrPrompt As String                'Prompt to display for user-input
                                            'If not provided by the user, it will be the
                                            'same as the display name
                                  
Dim mstrID As String
                                  
Private mstrLocalizationFQN As String       'FQN to use for localization
Private mstrValue As String                 'Text value of the property

Private mstrPopupHeader As String           'Header for the popup, only for groups
Private mstrPopupTitle As String            'Title for the popup, only for groups
Private mstrPopupText As String             'Text for the popup, only for groups

Private mbOptional As Boolean               'Property is optional
Private mbReadOnly As Boolean               'Property is read-only
Private mbHidden As Boolean                 'The property exists, but is not visible
                                            'to the UI
Private mbSortable As Boolean               'The group/list can be sorted by this property
Private mbReadOnlyLocalized As Boolean      'Property has a read-only localized display name
Private mbEditableLocalized As Boolean      'Property has a localized display name that can be edited

Private mbOverride As Boolean               'Indicates that an override exists for this node
Private mstrOverride As String              'Override value

Private mbOptionOverride As Boolean
Private mstrOptionType As String                  'Type of options for this node

Private mcollAttributes As New Collection   'The attributes of the property

Private mcollDisplayConditions As New Collection  'Display conditions

Private meEditType As FlexEditType

Private mbRefreshOnChange As Boolean              'Indicates the dialog should refresh when this property changes

Private mcollOptions As New Collection            'Input options
Private mcollOverrideOptions As New Collection    'Input options -- overridden
Private mcollOptionConditions As New Collection   'Used when the set of options can vary

Private mobjOptionNodeList As IXMLDOMNodeList      'All option nodes

Private meOriginalEditType As FlexEditType
Private mstrOriginalOptionType As String


'Validation
Private mstrRegExp As String                      'Javascript Regular Expression to use
Private mstrMessage As String                     'Error message to display

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
    Call mcollAttributes.Add(LoadAttributeSchemaFromXML(objAttributeNode, mstrID & "Attribute" & intCount))
    intCount = intCount + 1
  Next
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : RenderPopup(objXSLNode, objXMLNode, strExtra)             '
' Description   : Render this property's part of a popup                    '
' Inputs        : objXSLNode -- XSL for the popup                           '
'               : objXMLNode -- relevant XML node                           '
'               : strExtra   -- extra data for the input name               '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function RenderPopup(ByRef objXSLNode As IXMLDOMNode, _
                            ByRef objXMLNode As IXMLDOMNode, _
                            ByRef strExtra As String, _
                            ByRef strAction As String, _
                            Optional ByRef bNotParent = False)
                            
  Dim objTemplateRowNode As IXMLDOMNode
  Dim objRowNode As IXMLDOMNode
  Dim objPromptNode As IXMLDOMNode
  Dim objPropertyNode As IXMLDOMNode
  Dim eEditType As FlexEditType
  
  Dim strValue As String                        'Value to display
  
  Dim objAttribute As AttributeItem
  Dim strHTML As String
  
  Dim objScriptNode As IXMLDOMNode              'XSL Script Node
    
  'Get the row
  Set objTemplateRowNode = objXSLNode.selectSingleNode("//tr[@id='DIALOG_ROW']")
  
  'Get the property node
  If Not objXMLNode Is Nothing Then
    If bNotParent Then
      Set objPropertyNode = objXMLNode
    Else
      Set objPropertyNode = objXMLNode.selectSingleNode(mstrXPath)
    End If
  End If
  
  'Create the input for the property
  Set objRowNode = GetClonedNode(objTemplateRowNode, ".", True)
  Set objPromptNode = objRowNode.selectSingleNode("//td[@id='DIALOG_PROMPT']")
  Call SetNodeText(objPromptNode, mstrDisplayName)
  
  'Slight hack to handle case of required properties that
  'aren't displayed.
  
  If Not CheckVisible(objXMLNode, Me, strAction) And Not mbOptional Then
    eEditType = HIDDENTEXT
    'If hidden, remove the prompt
    Call objPromptNode.parentNode.removeChild(objPromptNode)
  Else
    eEditType = meEditType
  End If
  
  'Set the input, check for override
  If mbOverride Then
    If Not objPropertyNode Is Nothing Then
      Call SetNodeText(objPropertyNode, mstrOverride)
    End If
    
    strValue = mstrOverride
    
  Else
    If Not objPropertyNode Is Nothing Then
      strValue = objPropertyNode.Text
    Else
      strValue = ""
    End If
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
  
  'Add the property
  If mbOptionOverride Then
    Call MakeInputNode(eEditType, _
                       objRowNode, _
                       "EditProperty" & strExtra, _
                       strValue, _
                       mcollOverrideOptions, _
                       mbRefreshOnChange, _
                       mbReadOnly)
  Else
    Call MakeInputNode(eEditType, _
                       objRowNode, _
                       "EditProperty" & strExtra, _
                       strValue, _
                       mcollOptions, _
                       mbRefreshOnChange, _
                       mbReadOnly)
  End If
                                      
  'Add any necessary validation
  If Len(mstrRegExp) > 0 Then
    Dim objXMLDoc As New DOMDocument30      'XML Document
    Dim objJSNode As IXMLDOMNode            'Javascript node
    Dim objAttr As IXMLDOMAttribute         'Attribute
    Dim objTDNode As IXMLDOMNode            'Table node
    
    Set objJSNode = objXMLDoc.createElement("script")
    Set objAttr = objXMLDoc.createAttribute("language")
    objAttr.Value = "Javascript"
    
    Call objJSNode.Attributes.setNamedItem(objAttr)
    
    Call SetNodeText(objJSNode, "AddValidate('" & "EditProperty" & strExtra & "','" & mstrRegExp & "','" & mstrMessage & "');")
    
    'Append the node
    Set objTDNode = objRowNode.selectSingleNode("//td")
    
    Call objTDNode.appendChild(objJSNode)
  End If
                                      
  'Add the row
  Call objTemplateRowNode.parentNode.appendChild(objRowNode)
                                    
  'Now create the dialogs for the attributes
  For Each objAttribute In mcollAttributes

'   If Not objAttribute.Hidden And CheckVisible(objPropertyNode, objAttribute, strAction) Then
'      Call CheckOptions(objPropertyNode, objAttribute)
    If CheckVisible(objPropertyNode, objAttribute, strAction) Or Not objAttribute.IsOptional Then
      Set objRowNode = GetClonedNode(objTemplateRowNode, ".", True)
      Call objAttribute.RenderPopup(objRowNode, objPropertyNode, ":" & mstrXPath & ":" & objAttribute.Name, strAction)
      Call objTemplateRowNode.parentNode.appendChild(objRowNode)
    Else
      If Not CheckVisible(objPropertyNode, objAttribute, strAction) Then
        objAttribute.OptionOverrideFlag = False
      End If
    End If
  Next
  
  'Remove the template
  Call objTemplateRowNode.parentNode.removeChild(objTemplateRowNode)

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : ModifyXML(objXML, strValue)                               '
' Description   : Modify this property's value, add the property if it      '
'               : does not exist.                                           '
' Inputs        : objXML    --  XML object                                  '
'               : strValue  -- Value of the attribute                       '
'               : arrNames  -- array of input data                          '
'               : arrVals   -- array of input values                        '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function ModifyXML(ByRef objXMLNode As IXMLDOMNode, _
                          ByRef strValue As String, _
                          ByRef arrNames, _
                          ByRef arrVals, _
                          ByRef strAction As String, _
                          Optional ByRef bNotParent As Boolean = False)
                          
  Dim objXMLDoc As New DOMDocument30        'used to create nodes
  Dim objPropertyNode As IXMLDOMNode        'node for this property
  Dim objSiblingNode As IXMLDOMNode         'sibling node
  Dim strName As Variant                    'names in array
  Dim strAttributeName As String            'attribute name
  Dim objAttribute As AttributeItem
  Dim i As Integer
  
  
  'Check if the node exists
  If bNotParent Then
    Set objPropertyNode = objXMLNode
  Else
    Set objPropertyNode = objXMLNode.selectSingleNode(mstrXPath)
  End If
  
  'If the node does exist, modify it
  If Not objPropertyNode Is Nothing Then
  
    'Handle case for optional node with no value (remove it)
    If mbOptional And Len(strValue) = 0 Then
      Call objPropertyNode.parentNode.removeChild(objPropertyNode)
    End If
  
    Call SetNodeText(objPropertyNode, strValue)
  
    'Handle case for hidden attributes
    
    For Each objAttribute In mcollAttributes
      If objAttribute.Hidden Or Not CheckVisible(objPropertyNode, objAttribute) Then
        If Not CheckVisible(objPropertyNode, objAttribute) Then
          objAttribute.OptionOverrideFlag = False
        End If
      
        Call objAttribute.ModifyXML(objPropertyNode, objAttribute.Value)
      
      Else
        For i = 0 To UBound(arrNames)
          If InStr(arrNames(i), "EditAttribute:" & mstrXPath & ":") > 0 Then
            strAttributeName = Right(arrNames(i), Len(arrNames(i)) - InStrRev(arrNames(i), ":"))
          
            If objAttribute.Name = strAttributeName Then
              Call objAttribute.ModifyXML(objPropertyNode, CStr(arrVals(i)))
              Exit For
            End If
          End If
        Next
      End If
    Next
        
  
  
  'if the node doesn't exist, create it if it was optional and it has a value
  'or if adding, create it
  Else
    If Len(strValue) > 0 Or strAction = "ADD" Or Not mbOptional Then
    'If mbOptional And Len(strValue) > 0 Or strAction = "ADD" Then
      
      'order may be important, so add the property in the order of the schema
            
      Set objPropertyNode = objXMLDoc.createNode(NODE_ELEMENT, mstrXPath, "")
      Call SetNodeText(objPropertyNode, strValue)
      
      'Add the attributes
      For i = 0 To UBound(arrNames)
        If InStr(arrNames(i), "EditAttribute:" & mstrXPath & ":") > 0 Then
          strAttributeName = Right(arrNames(i), Len(arrNames(i)) - InStrRev(arrNames(i), ":"))
          
          'Find the attribute schema that matches
          For Each objAttribute In mcollAttributes
            If objAttribute.Name = strAttributeName Then
              Call objAttribute.ModifyXML(objPropertyNode, CStr(arrVals(i)))
              Exit For
            End If
          Next
        End If
      Next
      
      'if the sibling isn't named, insert last, otherwise insert before
      If Len(mstrSiblingXPath) = 0 Then
        Call objXMLNode.appendChild(objPropertyNode)
      
      'otherwise, insert before the sibling
      Else
        Set objSiblingNode = objXMLNode.selectSingleNode(mstrSiblingXPath)
        Call objXMLNode.insertBefore(objPropertyNode, objSiblingNode)
        
      End If
      
    End If
  End If
  
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : OverrideXML(...)                                          '
' Description   : Modify this property's value, but only for display        '
' Inputs        : objXML    --  XML object                                  '
'               : strValue  -- Value of the attribute                       '
'               : arrNames  -- array of input data                          '
'               : arrVals   -- array of input values                        '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function OverrideXML(ByRef strValue As String, _
                            ByRef arrNames, _
                            ByRef arrVals)
  Dim objAttribute As AttributeItem
  Dim strAttributeName As String
  Dim i As Integer
                          
  mbOverride = True
  mstrOverride = strValue
  
  For Each objAttribute In mcollAttributes
    If Not objAttribute.Hidden Then
      For i = 0 To UBound(arrNames)
        If InStr(arrNames(i), "EditAttribute:" & mstrXPath & ":") > 0 Then
          strAttributeName = Right(arrNames(i), Len(arrNames(i)) - InStrRev(arrNames(i), ":"))
        
          If objAttribute.Name = strAttributeName Then
            objAttribute.OverrideFlag = True
            objAttribute.OverrideValue = arrVals(i)
            Exit For
          End If
        End If
      Next
    End If
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Attributes -- Get Only
Public Property Get Attributes() As Collection
  Set Attributes = mcollAttributes
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'XPath
Public Property Let XPath(ByVal strXPath As String)
  Let mstrXPath = strXPath
End Property

Public Property Get XPath() As String
  Let XPath = mstrXPath
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Sibling XPath
Public Property Let SiblingXPath(ByVal strSiblingXPath As String)
  Let mstrSiblingXPath = strSiblingXPath
End Property

Public Property Get SiblingXPath() As String
  Let SiblingXPath = mstrSiblingXPath
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'DisplayName
Public Property Let DisplayName(ByVal strDisplayName As String)
  Let mstrDisplayName = strDisplayName
End Property

Public Property Get DisplayName() As String
  Let DisplayName = mstrDisplayName
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Prompt
Public Property Let Prompt(ByVal strPrompt As String)
  Let mstrPrompt = strPrompt
End Property

Public Property Get Prompt() As String
  Let Prompt = mstrPrompt
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Localization FQN
Public Property Let LocalizationFQN(ByVal strLocalizationFQN As String)
  Let mstrLocalizationFQN = strLocalizationFQN
End Property

Public Property Get LocalizationFQN() As String
  Let LocalizationFQN = mstrLocalizationFQN
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'ReadOnlyLocalized
Public Property Let ReadOnlyLocalized(ByVal bReadOnlyLocalized As Boolean)
  Let mbReadOnlyLocalized = bReadOnlyLocalized
End Property

Public Property Get ReadOnlyLocalized() As Boolean
  Let ReadOnlyLocalized = mbReadOnlyLocalized
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'ReadWriteLocalized
Public Property Let ReadWriteLocalized(ByVal bReadWriteLocalized As Boolean)
  Let mbEditableLocalized = bReadWriteLocalized
End Property

Public Property Get ReadWriteLocalized() As Boolean
  Let ReadWriteLocalized = mbEditableLocalized
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
'Hidden
Public Property Let Hidden(ByVal bHidden As Boolean)
  Let mbHidden = bHidden
End Property

Public Property Get Hidden() As Boolean
  Let Hidden = mbHidden
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
'Sortable
Public Property Let Sortable(ByVal bSortable As Boolean)
  Let mbSortable = bSortable
End Property

Public Property Get Sortable() As Boolean
  Let Sortable = mbSortable
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
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get RegExp() As String
  Let RegExp = mstrRegExp
End Property

Public Property Let RegExp(ByVal Val As String)
  Let mstrRegExp = Val
End Property

Public Property Get Message() As String
  Let Message = mstrMessage
End Property

Public Property Let Message(ByVal Val As String)
  Let mstrMessage = Val
End Property

