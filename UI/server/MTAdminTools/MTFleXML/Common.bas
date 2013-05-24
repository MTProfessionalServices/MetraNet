Attribute VB_Name = "Common"
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
' Common.bas -- Routines common to many of the classes present.             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public gstrExtension As String
Public gstrEnumSpace As String
Public gstrEnumType As String

Public gbLocalized As Boolean

Public mobjEnumConfig As New MTENUMCONFIGLib.EnumConfig

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub         : LoadGroupSchemaFromXML(objNode)                             '
' Description : Load a group based on the node passed in.                   '
' Inputs      : objNode -- Node containing the set of groups.               '
'             : strID   -- ID of the group.                                 '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadGroupSchemaFromXML(ByRef objNode As IXMLDOMNode, _
                                ByRef strID As String) As Group
  Dim objGroup As New Group   'New group to create
  
  'Get the attributes
  objGroup.ReadOnly = CheckAttributeText(objNode, "readonly", "true")
  objGroup.IsOptional = CheckAttributeText(objNode, "optional", "true")
  objGroup.ShowAttributesInGrid = CheckAttributeText(objNode, "showattributes", "true")
  
  'Get the stylesheet
  objGroup.StyleSheet = GetNodeText(objNode, "stylesheet")
  
  If Len(objGroup.StyleSheet) > 0 Then
    objGroup.UseStyleSheet = True
  Else
    objGroup.UseStyleSheet = False
  End If
  
  'XPath, can be relative or absolute. Optional if all properties have
  'absolute paths. Error will be reported when reading properties
  objGroup.XPath = GetAttributeText(objNode, "xpath")
  
  'Get display information
  objGroup.Title = GetNodeText(objNode, "title")
  objGroup.Text = GetNodeText(objNode, "text")
  
  objGroup.AttributeHeader = GetNodeText(objNode, "AttributeHeader")
  If Len(objGroup.AttributeHeader) = 0 Then
    objGroup.AttributeHeader = "Attributes"
  End If
  
  objGroup.EditHeader = GetNodeText(objNode, "EditHeader")
  If Len(objGroup.EditHeader) = 0 Then
    objGroup.EditHeader = "Edit"
  End If
  
  objGroup.PropertyHeader = GetNodeText(objNode, "PropertyHeader")
  If Len(objGroup.PropertyHeader) = 0 Then
    objGroup.PropertyHeader = "Property"
  End If
  
  objGroup.ValueHeader = GetNodeText(objNode, "ValueHeader")
  If Len(objGroup.ValueHeader) = 0 Then
    objGroup.ValueHeader = "Value"
  End If
  
  
  objGroup.ID = strID
  
  'Now get any defined attributes
  Call objGroup.GetAttributesFromXML(objNode)
  
  'Get any properties
  Call objGroup.GetPropertiesFromXML(objNode)
  
  'Get any subgroups
  Call objGroup.GetGroupsFromXML(objNode)
  
  'Get any sublists
  Call objGroup.GetListsFromXML(objNode)
    
  Set LoadGroupSchemaFromXML = objGroup
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub         : LoadListSchemaFromXML(objNode)                              '
' Description : Load a group based on the node passed in.                   '
' Inputs      : objNode -- Node containing the set of groups.               '
'             : strID   -- ID of the list.                                  '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadListSchemaFromXML(ByRef objNode As IXMLDOMNode, _
                               ByRef strID As String) As List
  Dim objList As New List     'New list to create
  Dim strType As String       'List type string
  
  'Get the attributes
  objList.ReadOnly = CheckAttributeText(objNode, "readonly", "true")
  objList.IsOptional = CheckAttributeText(objNode, "optional", "true")
  
  objList.NotExpandable = CheckAttributeText(objNode, "fixedsize", "true")
  
  'Get the listtype
  strType = GetAttributeText(objNode, "type")
  
  Select Case UCase(strType)
    Case "SIMPLE"
      objList.ListType = SIMPLE
    Case "EXTENDED"
      objList.ListType = EXTENDED
    Case "FLATEXTENDED"
      objList.ListType = FLATEXTENDED
  End Select
  
  'Ordered
  objList.Ordered = CheckAttributeText(objNode, "ordered", "true")
  
  'Insertable
  objList.Insertable = CheckAttributeText(objNode, "insertable", "true")
  
  'Sortable
  objList.Sortable = CheckAttributeText(objNode, "sortable", "true")
  
  'Get showattributes flag
  objList.ShowAttributesInGrid = CheckAttributeText(objNode, "showattributes", "true")
  
  'Get headers for the list attributes
  objList.AttributeNameHeader = GetNodeText(objNode, "attributenameheader")
  If Len(objList.AttributeNameHeader) = 0 Then
    objList.AttributeNameHeader = "Attribute"
  End If
  
  objList.AttributeValueHeader = GetNodeText(objNode, "attributevalueheader")
  If Len(objList.AttributeValueHeader) = 0 Then
    objList.AttributeValueHeader = "Value"
  End If
  
  'Get the button texts
  objList.AddButtonText = GetNodeText(objNode, "add_button_text")
  If Len(objList.AddButtonText) = 0 Then
    objList.AddButtonText = "Add"
  End If
  
  objList.RemoveButtonText = GetNodeText(objNode, "remove_button_text")
  If Len(objList.RemoveButtonText) = 0 Then
    objList.RemoveButtonText = "Remove"
  End If
  
  'Get the stylesheet
  objList.StyleSheet = GetNodeText(objNode, "stylesheet")
  
  If Len(objList.StyleSheet) = 0 Then
    objList.UseStyleSheet = False
  Else
    objList.UseStyleSheet = True
  End If
  
  'Filter
  objList.Filter = GetNodeText(objNode, "filter")
  
  
  'XPath, can be relative or absolute. Optional if all properties have
  'absolute paths. Error will be reported when reading properties
  objList.XPath = GetAttributeText(objNode, "xpath")
  
  'Get display information
  objList.Title = GetNodeText(objNode, "title")
  objList.Text = GetNodeText(objNode, "text")
  
  objList.EditHeader = GetNodeText(objNode, "editheader")
  If Len(objList.EditHeader) = 0 Then
    objList.EditHeader = "Edit"
  End If
  
  objList.InsertHeader = GetNodeText(objNode, "insertheader")
  If Len(objList.InsertHeader) = 0 Then
    objList.InsertHeader = "Insert"
  End If
  
  objList.MoveHeader = GetNodeText(objNode, "moveheader")
  If Len(objList.MoveHeader) = 0 Then
    objList.MoveHeader = "Move"
  End If
  
  objList.NumberHeader = GetNodeText(objNode, "numberheader")
  If Len(objList.NumberHeader) = 0 Then
    objList.NumberHeader = "#"
  End If
  
  objList.AttributeNameHeader = GetNodeText(objNode, "attribute_table_title")
  objList.PropertyTableTitle = GetNodeText(objNode, "property_table_title")
  
  'Get popup data
  objList.AttributePopupHeader = GetNodeText(objNode, "attribute_popup_header")
  
  If Len(objList.AttributePopupHeader) = 0 Then
    objList.AttributePopupHeader = "Edit Attribute"
  End If
  
  objList.AttributePopupText = GetNodeText(objNode, "attribute_popup_text")
  
  objList.AttributePopupTitle = GetNodeText(objNode, "attribute_popup_title")
  
  If Len(objList.AttributePopupTitle) = 0 Then
    objList.AttributePopupTitle = "Edit Attribute"
  End If
  
  objList.PopupHeader = GetNodeText(objNode, "popupheader")
  If Len(objList.PopupHeader) = 0 Then
    objList.PopupHeader = "Edit List"
  End If
  
  objList.PopupText = GetNodeText(objNode, "popuptext")
 
  objList.PopupTitle = GetNodeText(objNode, "popuptitle")
  If Len(objList.PopupTitle) = 0 Then
    objList.PopupTitle = "Edit List"
  End If
  
  objList.ID = strID
  
  
  
  'Now get any defined attributes
  Call objList.GetAttributesFromXML(objNode)
  
  'Get any properties
  Call objList.GetPropertiesFromXML(objNode)
  
  'Get any subgroups
  Call objList.GetGroupsFromXML(objNode)
  
  'Get any sublists
  Call objList.GetListsFromXML(objNode)
    
  Set LoadListSchemaFromXML = objList
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : LoadPropertySchemaFromXML(objNode) as Property            '
' Description   : Load a property based on the node passed in.              '
' Inputs        : objNode -- reference to a property node                   '
'               : strID   -- ID of the property                             '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadPropertySchemaFromXML(ByRef objPropertyNode As IXMLDOMNode, _
                                   ByRef strID As String) As Property
  Dim objProperty As New Property
  
  Dim objValidateNode As IXMLDOMNode  'Validation node
  
  'Get the boolean values, stored in the attributes of the property
  objProperty.Hidden = CheckAttributeText(objPropertyNode, "hidden", "true")
  objProperty.IsOptional = CheckAttributeText(objPropertyNode, "optional", "true")
  objProperty.ReadOnly = CheckAttributeText(objPropertyNode, "readonly", "true")
  objProperty.ReadOnlyLocalized = CheckAttributeText(objPropertyNode, "readonlylocalized", "true")
  objProperty.ReadWriteLocalized = CheckAttributeText(objPropertyNode, "readwritelocalized", "true")
  objProperty.Sortable = CheckAttributeText(objPropertyNode, "sortable", "true")
  objProperty.RefreshOnChange = CheckAttributeText(objPropertyNode, "refreshonchange", "true")
  
  Select Case UCase(GetAttributeText(objPropertyNode, "edittype"))
    Case "TEXT"
      objProperty.EditType = TEXTINPUT
    Case "TEXTAREA"
      objProperty.EditType = TEXTAREA
    Case "RADIO"
      objProperty.EditType = RADIO
    Case "SELECT"
      objProperty.EditType = SINGLESELECT
    Case "MULTISELECT"
      objProperty.EditType = MULTIPLESELECT
    Case "CHECK"
      objProperty.EditType = CHECK
    Case Else
      objProperty.EditType = TEXTINPUT
  End Select
  
  
  objProperty.OriginalEditType = objProperty.EditType
    
  'Get the property data
  objProperty.DisplayName = GetNodeText(objPropertyNode, "display_name")
  objProperty.LocalizationFQN = GetNodeText(objPropertyNode, "localization_fqn")
  objProperty.Prompt = GetNodeText(objPropertyNode, "prompt")
  objProperty.XPath = GetNodeText(objPropertyNode, "xpath")
  
  'Get the popup data
  objProperty.PopupHeader = GetNodeText(objPropertyNode, "popupheader")
  
  If Len(objProperty.PopupHeader) = 0 Then
    objProperty.PopupHeader = "Edit: " & objProperty.DisplayName
  End If
  
  objProperty.PopupText = GetNodeText(objPropertyNode, "popuptext")
  
  objProperty.PopupTitle = GetNodeText(objPropertyNode, "popuptitle")
  If Len(objProperty.PopupTitle) = 0 Then
    objProperty.PopupTitle = "Edit Property"
  End If


  objProperty.ID = strID
  
  'Store option nodes
  Set objProperty.OptionNodes = objPropertyNode.selectNodes("option")
  
  'Load the options
  Call LoadOptions(GetAttributeText(objPropertyNode, "optiontype"), objProperty, objPropertyNode)
  
  objProperty.OriginalOptionType = objProperty.OptionType
  
  'Load the display conditions
  Call LoadDisplayConditions(objPropertyNode, objProperty)
    
  'Load option conditions
  Call LoadOptionConditions(objPropertyNode, objProperty)

  'Load the attributes of the property
  Call objProperty.GetAttributesFromXML(objPropertyNode)
  
  'Get the validation node
  Set objValidateNode = objPropertyNode.selectSingleNode("validate[@type='RegExp']")
  
  If Not objValidateNode Is Nothing Then
    objProperty.RegExp = objValidateNode.selectSingleNode("RegExp").Text
    objProperty.Message = objValidateNode.selectSingleNode("Message").Text
  
  End If
  
  'Set the localized property
  If objProperty.ReadOnlyLocalized Or objProperty.ReadWriteLocalized Then
    gbLocalized = True
  End If
  
  
  Set LoadPropertySchemaFromXML = objProperty
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : LoadAttributeSchemaFromXML(objNode) as property           '
' Description   : Load the given attribute from the passed in node.         '
' Inputs        : objNode -- reference to the attribute node.               '
'               : strID   -- ID of the attribute
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadAttributeSchemaFromXML(ByRef objAttributeNode As IXMLDOMNode, _
                                    ByRef strID As String) As AttributeItem
  Dim objAttribute As New AttributeItem
  Dim objNodeList As IXMLDOMNodeList
  Dim objNode As IXMLDOMNode
  
  'Get the data
  objAttribute.IsOptional = CheckAttributeText(objAttributeNode, "optional", "true")
  objAttribute.ReadOnly = CheckAttributeText(objAttributeNode, "readonly", "true")
  objAttribute.Hidden = CheckAttributeText(objAttributeNode, "hidden", "true")
  objAttribute.RefreshOnChange = CheckAttributeText(objAttributeNode, "refreshonchange", "true")
    
  Select Case UCase(GetAttributeText(objAttributeNode, "edittype"))
    Case "TEXT"
      objAttribute.EditType = TEXTINPUT
    Case "TEXTAREA"
      objAttribute.EditType = TEXTAREA
    Case "RADIO"
      objAttribute.EditType = RADIO
    Case "SELECT"
      objAttribute.EditType = SINGLESELECT
    Case "MULTISELECT"
      objAttribute.EditType = MULTIPLESELECT
    Case "CHECK"
      objAttribute.EditType = CHECK
    Case Else
      objAttribute.EditType = TEXTINPUT
  End Select
  
  objAttribute.OriginalEditType = objAttribute.EditType
  
  objAttribute.Name = GetNodeText(objAttributeNode, "name", True)
  objAttribute.Value = GetNodeText(objAttributeNode, "value")
  objAttribute.Text = GetNodeText(objAttributeNode, "text")
  
    
  'Popup data
  objAttribute.PopupHeader = GetNodeText(objAttributeNode, "popupheader")
  
  If Len(objAttribute.PopupHeader) = 0 Then
    objAttribute.PopupHeader = "Edit: " & objAttribute.Text
  End If
  
  objAttribute.PopupText = GetNodeText(objAttributeNode, "popuptext")
  
  
  objAttribute.PopupTitle = GetNodeText(objAttributeNode, "popuptitle")
  
  If Len(objAttribute.PopupTitle) = 0 Then
    objAttribute.PopupTitle = "Edit Attribute"
  End If
    
  objAttribute.ID = strID
  
  'Add the option nodes
  Set objAttribute.OptionNodes = objAttributeNode.selectNodes("option")
  
  'Load the options
  Call LoadOptions(GetAttributeText(objAttributeNode, "optiontype"), objAttribute, objAttributeNode)
  
  objAttribute.OriginalOptionType = objAttribute.OptionType
  
  'Load the display conditions
  Call LoadDisplayConditions(objAttributeNode, objAttribute)
  
  'Load Option Conditions
  Call LoadOptionConditions(objAttributeNode, objAttribute)
  
  Set LoadAttributeSchemaFromXML = objAttribute
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : LoadOptions(objNode, objSchema)                           '
' Description   : Load the list of options for the node from the schema.    '
' Inputs        : objNode -- Schema node for the item.                      '
'               : objSchema -- Schema object.                               '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadOptions(ByRef strOptionType As String, _
                     ByRef objSchema, _
                     Optional ByRef objItemNode As IXMLDOMNode = Nothing)
  Dim objXMLDoc As New DOMDocument30
  Dim objFSO As New FileSystemObject
  Dim objFolder As Object
  Dim objSubFolder As Object
  
  Dim objNodeList As IXMLDOMNodeList      'List of option nodes
  Dim objNode As IXMLDOMNode              'Used to walk the list
  Dim objAttrNode As IXMLDOMAttribute     'Attributes
  
  Dim collOptions As Collection
  
  Dim objEnumSpace As MTEnumSpace
  
  Dim objEnumType As MTEnumType
  Dim collEnumTypes As MTEnumTypeCollection
  
  Dim objEnumerator As MTEnumerator
  Dim collEnumerators As MTEnumeratorCollection
  
  Dim objRCD As New MTRcd
  Dim objFilelist As MTRcdFileList
  Dim varFile As Variant
  
  Dim bEnumTypeFound As Boolean
  
  Dim i As Integer
 
  If Not objItemNode Is Nothing Then
    objSchema.OptionOverrideFlag = False
    Set collOptions = objSchema.Options
  Else
    objSchema.OptionOverrideFlag = True
    Set collOptions = objSchema.OverrideOptions
  End If
  
  'First, remove all options from the collection
  For i = 1 To collOptions.Count
    Call collOptions.Remove(1)
  Next
    
  If Len(strOptionType) = 0 Then
    strOptionType = ""
  End If
  
  objSchema.OptionType = strOptionType
  
  'Set the options
  Select Case UCase(strOptionType)
    Case "PTYPE"
      Call AddOption(collOptions, "BOOLEAN")
      Call AddOption(collOptions, "DATETIME")
      Call AddOption(collOptions, "DECIMAL")
      Call AddOption(collOptions, "DOUBLE")
      Call AddOption(collOptions, "ENUM")
      Call AddOption(collOptions, "ID")
      Call AddOption(collOptions, "INTEGER")
      Call AddOption(collOptions, "STRING")
      
      
    Case "SDTYPE"
      Call AddOption(collOptions, "boolean")
      Call AddOption(collOptions, "decimal")
      Call AddOption(collOptions, "double")
      Call AddOption(collOptions, "enum")
      Call AddOption(collOptions, "float")
      Call AddOption(collOptions, "int32")
      Call AddOption(collOptions, "string")
      Call AddOption(collOptions, "timestamp")
      Call AddOption(collOptions, "unistring")
      
    Case "TRUEFALSE"
      Call AddOption(collOptions, "True")
      Call AddOption(collOptions, "False")
    
    Case "TF"
      Call AddOption(collOptions, "")
      Call AddOption(collOptions, "T")
      Call AddOption(collOptions, "F")
    Case "YESNO"
      Call AddOption(collOptions, "Yes")
      Call AddOption(collOptions, "No")
    
    Case "YN"
      Call AddOption(collOptions, "Y")
      Call AddOption(collOptions, "N")
    
    Case "10"
      Call AddOption(collOptions, "1")
      Call AddOption(collOptions, "0")
    
    Case "ENUMSPACE"
      'Get a list of the enumspaces for the extension
      For Each objEnumSpace In mobjEnumConfig.GetEnumSpaces()
        'If UCase(objEnumSpace.Extension) = UCase(gstrExtension) Then
          Call AddOption(collOptions, objEnumSpace.Name)
        'End If
      Next
      
      If collOptions.Count > 0 And Len(gstrEnumSpace) = 0 Then
        gstrEnumSpace = collOptions.Item(1).Value
      End If
    
    Case "ENUMTYPE"
      If Len(gstrEnumSpace) > 0 Then
        bEnumTypeFound = False
        Set collEnumTypes = mobjEnumConfig.GetEnumSpace(gstrEnumSpace).GetEnumTypes
        
        If Not collEnumTypes Is Nothing Then
          For Each objEnumType In collEnumTypes
            If gstrEnumType = objEnumType.EnumTypeName Then
              bEnumTypeFound = True
            End If
            
            Call AddOption(collOptions, objEnumType.EnumTypeName)
          Next
        End If
        
        If (Len(gstrEnumType) = 0 And collOptions.Count > 0) Or Not bEnumTypeFound Then
          gstrEnumType = collOptions(1).Value
        End If
      End If
    
    Case "ENUMERATOR"
      If Len(gstrEnumType) > 0 Then
        Set objEnumType = mobjEnumConfig.GetEnumType(gstrEnumSpace, gstrEnumType)
        
        If Not objEnumType Is Nothing Then
          'Add an empty option for enumerators
          'Another way is to add this tag to the schema for the
          'specific item:  <option type="ENUMERATOR"></option>
          Call AddOption(collOptions, "")
          
          For Each objEnumerator In objEnumType.GetEnumerators
            Call AddOption(collOptions, objEnumerator.Name)
          Next
        End If
        
      End If
    
    Case "PRODUCTVIEW"
      objXMLDoc.async = False
      objXMLDoc.validateOnParse = False
      objXMLDoc.resolveExternals = False
      
      Set objFilelist = objRCD.RunQueryInAlternateFolder("*.msixdef", True, objRCD.ExtensionDir & "/" & gstrExtension & "/config/productview")
      
      For Each varFile In objFilelist
        Call objXMLDoc.Load(varFile)
        
        Set objNode = objXMLDoc.selectSingleNode("/defineservice/name")
        
        If Not objNode Is Nothing Then
          Call AddOption(collOptions, objNode.Text)
        End If
      Next
      
    Case "SERVICEDEFINITION"
      objXMLDoc.async = False
      objXMLDoc.validateOnParse = False
      objXMLDoc.resolveExternals = False
      
      Set objFilelist = objRCD.RunQueryInAlternateFolder("*.msixdef", True, objRCD.ExtensionDir & "/" & gstrExtension & "/config/service")
      
      For Each varFile In objFilelist
        Call objXMLDoc.Load(varFile)
        
        Set objNode = objXMLDoc.selectSingleNode("/defineservice/name")
        
        If Not objNode Is Nothing Then
          Call AddOption(collOptions, objNode.Text)
        End If
      Next
    
    Case "STAGE"
      objXMLDoc.async = False
      objXMLDoc.validateOnParse = False
      objXMLDoc.resolveExternals = False
      
      If objFSO.FolderExists(objRCD.ExtensionDir & "/" & gstrExtension & "/config/pipeline") Then
        Set objFolder = objFSO.GetFolder(objRCD.ExtensionDir & "/" & gstrExtension & "/config/pipeline")
        For Each objSubFolder In objFolder.SubFolders
          Call objXMLDoc.Load(objSubFolder.Path & "/stage.xml")
          
          Set objNode = objXMLDoc.selectSingleNode("/xmlconfig/stage/name")
          
          If Not objNode Is Nothing Then
            Call AddOption(collOptions, objNode.Text)
          End If
        Next
      End If
      
    Case Else
  
  End Select
                     
  'Append specified options
  
  'Get the options for the property from the schema file
  If Not objItemNode Is Nothing Then
    If Len(strOptionType) > 0 Then
      Set objNodeList = objItemNode.selectNodes("option[@type='" & strOptionType & "']")
    Else
      Set objNodeList = objItemNode.selectNodes("option")
    End If
    
    If Not objNodeList Is Nothing Then
      For Each objNode In objNodeList
        Set objAttrNode = objNode.Attributes.getNamedItem("value")
        
        If Not objAttrNode Is Nothing Then
          Call AddOption(collOptions, objNode.Text, objAttrNode.Value)
        Else
          Call AddOption(collOptions, objNode.Text)
        End If
      Next
    End If
    
  'Get the options from the stored schema data
  Else
    Set objNodeList = objSchema.OptionNodes
    
    For Each objNode In objNodeList
      If Not objNode.Attributes.getNamedItem("type") Is Nothing Then
        If UCase(objNode.Attributes.getNamedItem("type").Text) = UCase(strOptionType) Then
          Set objAttrNode = objNode.Attributes.getNamedItem("value")
        
          If Not objAttrNode Is Nothing Then
            Call AddOption(collOptions, objNode.Text, objAttrNode.Value)
          Else
            Call AddOption(collOptions, objNode.Text)
          End If
        End If
      End If
    Next
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadDisplayConditions(objItemNode, objSchema)               '
' Description : For the item, load and populate the display conditions      '
' Inputs      : objItemNode -- Node with schema information for the item.   '
'             : objSchema   -- Schema definition for the node.              '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadDisplayConditions(ByRef objItemNode As IXMLDOMNode, _
                               ByRef objSchema)
  Dim objDisplayCondition As Condition            'Display condition to add
  Dim objConditionNodeList As IXMLDOMNodeList     'List of conditions nodes
  Dim objConditionNode As IXMLDOMNode             'Used to walk the list of nodes
  
  Set objConditionNodeList = objItemNode.selectNodes("condition[@type='display']")
  
  For Each objConditionNode In objConditionNodeList
    Set objDisplayCondition = New Condition
    
    objDisplayCondition.DataType = GetNodeText(objConditionNode, "data/@type")
    objDisplayCondition.Data = GetNodeText(objConditionNode, "data")
    
    objDisplayCondition.Compare = GetNodeText(objConditionNode, "compare")
    
    objDisplayCondition.ValueType = GetNodeText(objConditionNode, "value/@type")
    objDisplayCondition.Value = GetNodeText(objConditionNode, "value")
    
    Call objSchema.DisplayConditions.Add(objDisplayCondition)
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : AddOption(collOptions, strDisplay, strValue)                '
' Description : Add an option and display value to a collection.            '
' Inputs      : collOptions -- Collection to add options to.                '
'             : strDisplay  -- Text to display for the option               '
'             : strValue    -- Value of the option, if not passed, assumed  '
'             :                same as display.                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function AddOption(ByRef collOptions As Collection, _
                   ByVal strDisplay As String, _
                   Optional ByVal strValue As String = "#***NOOPTION***#")
                   
  Dim objOption As New DisplayOption
  
  If strValue = "#***NOOPTION***#" Then
    objOption.Value = strDisplay
  Else
    objOption.Value = strValue
  End If
  
  objOption.Display = strDisplay
  
  Call collOptions.Add(objOption)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadOptionConditions(objItemNode,objSchema)                 '
' Description : Load conditions that define what the set of options will be.'
' Inputs      : objItemNode -- Node for the schema item being loaded.       '
'             : objSchema -- the schema object to populate.                 '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadOptionConditions(ByRef objItemNode As IXMLDOMNode, _
                              ByRef objSchema)
  Dim objNodeList As IXMLDOMNodeList    'List of option conditions
  Dim objNode As IXMLDOMNode            'Used to walk the list
  
  Dim objOptionCondition As Condition
  
  Set objNodeList = objItemNode.selectNodes("condition[@type='option']")
  
  For Each objNode In objNodeList
    Set objOptionCondition = New Condition
    
    objOptionCondition.DataType = GetNodeText(objNode, "data/@type")
    objOptionCondition.Data = GetNodeText(objNode, "data")
    
    objOptionCondition.Compare = GetNodeText(objNode, "compare")
    
    objOptionCondition.ValueType = GetNodeText(objNode, "value/@type")
    objOptionCondition.Value = GetNodeText(objNode, "value")
    
    objOptionCondition.OptionType = GetNodeText(objNode, "optiontype")
    
    objOptionCondition.Link = GetNodeText(objNode, "link")
    
    Call objSchema.OptionConditions.Add(objOptionCondition)
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : CheckVisible(objListXML, objProperty)                       '
' Description : Determine if a property should be visible or not.           '
' Inputs      : objListXML -- XML for the list                              '
'             : objProperty -- Property to check visbility for.             '
' Outputs     : true/false, indicating visbility                            '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function CheckVisible(ByRef objXML As IXMLDOMNode, _
                      ByRef objSchema, _
                      Optional ByVal strAction As String)
  
  Dim objCondition As Condition             'Used to check the display
  Dim objAttribute As IXMLDOMAttribute
  Dim objNode As IXMLDOMNode
  
  Dim strData As String                     'Data to check
  Dim strValue As String                    'Value to check data against
  
  Dim bVisible As Boolean
  
  
  bVisible = False
      
  If objSchema.DisplayConditions.Count > 0 Then
      
    For Each objCondition In objSchema.DisplayConditions
      If UCase(objCondition.DataType) = "NODE" Then
        Set objNode = objXML.selectSingleNode(objCondition.Data)
        
        If Not objNode Is Nothing Then
          strData = objNode.Text
        End If
        
      ElseIf UCase(objCondition.DataType) = "ATTRIBUTE" Then
        Set objAttribute = objXML.selectSingleNode(objCondition.Data)
        
        If Not objAttribute Is Nothing Then
          strData = objAttribute.Text
        End If
      
      Else
        strData = objCondition.Data
      End If
      
      If UCase(objCondition.ValueType) = "NODE" Then
        Set objNode = objXML.selectSingleNode(objCondition.Value)
        If Not objNode Is Nothing Then
          strValue = objNode.Text
        End If
      
      ElseIf UCase(objCondition.ValueType) = "ATTRIBUTE" Then
        Set objAttribute = objXML.selectSingleNode(objCondition.Value)
        
        If Not objAttribute Is Nothing Then
          strValue = objAttribute.Text
        End If
      
      Else
        strValue = objCondition.Value
      End If
      
      'Do the EVAL
      Select Case (objCondition.Compare)
        Case "="
          If UCase(strData) = UCase(strValue) Then
            bVisible = bVisible Or True
          Else
            bVisible = bVisible Or False
          End If
        
        Case "<>"
          If UCase(strData) <> UCase(strValue) Then
            bVisible = bVisible Or True
          Else
            bVisible = bVisible Or False
          End If
      End Select
    Next
  Else
    bVisible = True
  End If


  CheckVisible = bVisible
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CheckOptions(objXML, objSchema)                           '
' Description   : Update the obtions list for the schema object.            '
' Inputs        : objXML -- XML for the object                              '
'               : objSchema -- schema object that contains the option list. '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function CheckOptions(ByRef objXML As IXMLDOMNode, _
                      ByRef objSchema)
  Dim objCondition As Condition
  Dim objNode As IXMLDOMNode
  Dim objAttribute As IXMLDOMAttribute
  
  Dim strData As String
  Dim strValue As String
  
  'If there are no conditions, make no changes
  If objSchema.OptionConditions.Count > 0 Then
  
    'Evaluate the conditions
    For Each objCondition In objSchema.OptionConditions
      
      'Get the data and value
      If UCase(objCondition.DataType) = "NODE" Then
        Set objNode = objXML.selectSingleNode(objCondition.Data)
        If Not objNode Is Nothing Then
          strData = objNode.Text
        End If
      ElseIf UCase(objCondition.DataType) = "ATTRIBUTE" Then
        Set objAttribute = objXML.selectSingleNode(objCondition.Data)
        
        If Not objAttribute Is Nothing Then
          strData = objAttribute.Text
        End If
        
      Else
        strData = objCondition.Data
      End If
      
      If UCase(objCondition.ValueType) = "NODE" Then
        Set objNode = objXML.selectSingleNode(objCondition.Value)
        If Not objNode Is Nothing Then
          strValue = objNode.Text
        End If
      
      ElseIf UCase(objCondition.ValueType) = "ATTRIBUTE" Then
        Set objAttribute = objXML.selectSingleNode(objCondition.Value)
        
        If Not objAttribute Is Nothing Then
          strValue = objAttribute.Text
        End If
      
      Else
        strValue = objCondition.Value
      End If
      
      'Do the EVAL
      Select Case (objCondition.Compare)
        Case "="
          If UCase(strData) = UCase(strValue) Then
            Call LoadOptions(objCondition.OptionType, objSchema)
            objSchema.OptionOverrideFlag = True
            objSchema.EditType = SINGLESELECT
            Exit Function
          End If
        
        Case "<>"
          If UCase(strData) <> UCase(strValue) Then
            Call LoadOptions(objCondition.OptionType, objSchema)
            objSchema.OptionOverrideFlag = True
            objSchema.EditType = SINGLESELECT
            Exit Function
          End If
      End Select
    Next
    objSchema.OptionOverrideFlag = False
  Else
    If UCase(objSchema.OptionType) <> "ENUMSPACE" And _
       UCase(objSchema.OptionType) <> "ENUMTYPE" And _
      UCase(objSchema.OptionType) <> "ENUMERATOR" Then
      objSchema.OptionOverrideFlag = False
    End If
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddClonedTextCell(objCellTemplate, strText)               '
' Description   : Add a cloned cell as sibling of the template cell with    '
'               : text equal to strText.                                    '
' Inputs        : objCellTemplate -- Node to base the clone on              '
'               : strText         -- Text for the node                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function AddClonedTextCell(ByRef objCellTemplate As IXMLDOMNode, _
                           ByRef strText As String)
  
  Dim objNewCell As IXMLDOMNode     'Cell to add
  
  'Get the clone
  Set objNewCell = GetClonedNode(objCellTemplate, ".", True)
  
  'Set the node text
  Call SetNodeText(objNewCell, strText)
    
  'Add the clone
  Call objCellTemplate.parentNode.appendChild(objNewCell)
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddClonedValueOfCell(objCellTemplate, strSelect)          '
' Description   : Add a cloned cell that contains a value-of node.          '
' Inputs        : objCellTemplate -- template for the cell.                 '
'               : strSelect       -- select attribute for the value-of node.'
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function AddClonedValueOfCell(ByRef objCellTemplate As IXMLDOMNode, _
                              ByRef strSelect As String)
  
  Dim objXML As New DOMDocument30             'XML document, to create nodes
  Dim objAttributeNode As IXMLDOMAttribute    'Attribute node
  Dim objValueNode As IXMLDOMNode             'Value node
  Dim objNewCell As IXMLDOMNode               'Cell to add
  
  'Get the clone
  Set objNewCell = GetClonedNode(objCellTemplate, ".", True)
    
  'Add the value-of nodes
  Set objAttributeNode = objXML.createAttribute("select")
  objAttributeNode.Value = strSelect
  
  Set objValueNode = objXML.createNode(NODE_ELEMENT, "xsl:value-of", "http://www.w3.org/TR/WD-xsl")
  
  Call objValueNode.Attributes.setNamedItem(objAttributeNode)
  
  'Add the node to the cloned node
  Call objNewCell.appendChild(objValueNode)
  
  'Add the cloned node
  Call objCellTemplate.parentNode.appendChild(objNewCell)
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddClonedEvalCell(objCellTemplate, strEval)               '
' Description   : Add a cloned node that contains an xsl:eval.              '
' Inputs        : objCellTemplate -- template for the node.                 '
'               : strEval         -- text of the eval node                  '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function AddClonedEvalCell(ByRef objCellTemplate As IXMLDOMNode, _
                           ByRef strEval As String)
  
  Dim objXML As New DOMDocument30         'Used to create nodes
  Dim objNewCell As IXMLDOMNode           'New cell to add
  Dim objXSLEvalNode As IXMLDOMNode       'Eval node
  
  'Clone the template
  Set objNewCell = GetClonedNode(objCellTemplate, ".", True)
    
  'Create the nodes
  Set objXSLEvalNode = objXML.createNode(NODE_ELEMENT, "xsl:eval", "http://www.w3.org/TR/WD-xsl")
  
  'Set the eval statement
  Call SetNodeText(objXSLEvalNode, strEval)
  
  'Append the nodes
  Call objNewCell.appendChild(objXSLEvalNode)
  
  Call objCellTemplate.parentNode.appendChild(objNewCell)
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddClonedSearchableEvalCell(objCellTemplate, strSearch,   '
'               :                             strEval)                      '
' Description   : Add a cloned node that contains an xsl:eval surrounded by '
'               : searchable data.                                          '
' Inputs        : objCellTemplate -- template for the node.                 '
'               : strSearch       -- searchable string                      '
'               : strEval         -- text of the eval node                  '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function AddClonedSearchableEvalCell(ByRef objCellTemplate As IXMLDOMNode, _
                                     ByRef strSearch As String, _
                                     ByRef strEval As String)
  
  Dim objXML As New DOMDocument30         'Used to create nodes
  Dim objNewCell As IXMLDOMNode           'New cell to add
  Dim objXSLPreTextNode As IXMLDOMNode    'Text node
  Dim objXSLEvalNode As IXMLDOMNode       'Eval node
  Dim objXSLPostTextNode As IXMLDOMNode   'Text node
  
  'Clone the template
  Set objNewCell = GetClonedNode(objCellTemplate, ".", True)
    
  'Create the nodes
  Set objXSLPreTextNode = objXML.createTextNode("##" & strSearch & ":")
  Set objXSLEvalNode = objXML.createNode(NODE_ELEMENT, "xsl:eval", "http://www.w3.org/TR/WD-xsl")
  Set objXSLPostTextNode = objXML.createTextNode("##")
  
  'Set the eval statement
  Call SetNodeText(objXSLEvalNode, strEval)
  
  'Append the nodes
  Call objNewCell.appendChild(objXSLPreTextNode)
  Call objNewCell.appendChild(objXSLEvalNode)
  Call objNewCell.appendChild(objXSLPostTextNode)
  
  Call objCellTemplate.parentNode.appendChild(objNewCell)
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddClonedSearchableEvalAttribute(objCellTemplate, strSearch,   '
'               :                             strEval)                      '
' Description   : Add a cloned node that contains an xsl:eval surrounded by '
'               : searchable data.                                          '
' Inputs        : objCellTemplate -- template for the node.                 '
'               : strSearch       -- search string                          '
'               : strAttribute    -- attribute to add                       '
'               : strEval         -- text of the eval node                  '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function AddClonedSearchableEvalAttribute(ByRef objCellTemplate As IXMLDOMNode, _
                                          ByRef strSearch As String, _
                                          ByRef strAttribute As String, _
                                          ByRef strEval As String)
  
  Dim objXML As New DOMDocument30           'Used to create nodes
  Dim objAttributeNode As IXMLDOMAttribute  'New cell to add
  Dim objXSLAttributeNode As IXMLDOMNode    'attribute node
  Dim objXSLPreTextNode As IXMLDOMNode      'Text node
  Dim objXSLEvalNode As IXMLDOMNode         'Eval node
  Dim objXSLPostTextNode As IXMLDOMNode     'Text node
  Dim objNewCell As IXMLDOMNode
  
  'Clone the template
  Set objNewCell = GetClonedNode(objCellTemplate, ".", True)
    
  'Create the nodes
  Set objXSLAttributeNode = objXML.createNode(NODE_ELEMENT, "xsl:attribute", "http://www.w3.org/TR/WD-xsl")
  Set objAttributeNode = objXML.createAttribute("name")
  
  objAttributeNode.Value = strAttribute
  
  
  Set objXSLPreTextNode = objXML.createTextNode("##" & strSearch & ":")
  Set objXSLEvalNode = objXML.createNode(NODE_ELEMENT, "xsl:eval", "http://www.w3.org/TR/WD-xsl")
  Set objXSLPostTextNode = objXML.createTextNode("##")
  
  'Set the eval statement
  Call SetNodeText(objXSLEvalNode, strEval)
  
  'Append the nodes
  Call objXSLAttributeNode.Attributes.setNamedItem(objAttributeNode)
  Call objXSLAttributeNode.appendChild(objXSLPreTextNode)
  Call objXSLAttributeNode.appendChild(objXSLEvalNode)
  Call objXSLAttributeNode.appendChild(objXSLPostTextNode)
  
  If objNewCell.childNodes.length = 0 Then
    Call objNewCell.appendChild(objXSLAttributeNode)
  Else
    Call objNewCell.insertBefore(objXSLAttributeNode, objNewCell.childNodes(0))
  End If
  
  Call objCellTemplate.parentNode.appendChild(objNewCell)
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddPropertyAttributesToClonedCell(objCellTemplate,        '
'               :                                   objAttributes)          '
' Description   : Add a table containing attributes to a cell.              '
' Inputs        : objCellTemplate -- Template for the cell to clone         '
'               : objAttributes   -- Collection of attributes for the prop. '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function AddPropertyAttributesToClonedCell(ByRef objCellTemplate As IXMLDOMNode, _
                                          ByRef objAttributes As Collection, _
                                          ByRef strXPath As String)
  
  Dim objXML As New DOMDocument30       'Document to create nodes
  Dim objNewCell As IXMLDOMNode         'New Cell Node
  Dim objTableNode As IXMLDOMNode
  Dim objRowNode As IXMLDOMNode
  Dim objStyleAttribute As IXMLDOMAttribute
  Dim objAttributeNameNode As IXMLDOMNode
  Dim objAttributeEqualsNode As IXMLDOMNode
  Dim objAttributeValueNode As IXMLDOMNode
  Dim objAttribute As AttributeItem
  Dim intCount As Integer
  
  If objAttributes.Count > 0 Then
  
    intCount = 0
  
    'Check for hidden nodes
    For Each objAttribute In objAttributes
      If Not objAttribute.Hidden Then
        intCount = 1
        Exit For
      End If
    Next
    
    If intCount = 0 Then
      Exit Function
    End If
    
    intCount = 0
    
    'Create nodes
    Set objTableNode = objXML.createNode(NODE_ELEMENT, "table", "")
    
    'Get the clone
    Set objNewCell = GetClonedNode(objCellTemplate, ".", True)
'    Call SetNodeText(objNewCell, "")
        
    intCount = 0
    For Each objAttribute In objAttributes
      If Not objAttribute.Hidden Then
        Set objRowNode = objXML.createNode(NODE_ELEMENT, "tr", "")
      
        'Setup attribute = value
        Set objAttributeNameNode = objXML.createNode(NODE_ELEMENT, "td", "")
        Call SetNodeText(objAttributeNameNode, objAttribute.Text)
        
        'Get the style
        If Not objNewCell.Attributes.getNamedItem("class") Is Nothing Then
          Set objStyleAttribute = objNewCell.Attributes.getNamedItem("class").cloneNode(True)
          Call objAttributeNameNode.Attributes.setNamedItem(objStyleAttribute)
        End If
        
        'Append
        Call objRowNode.appendChild(objAttributeNameNode)
        
        Set objAttributeEqualsNode = objXML.createNode(NODE_ELEMENT, "td", "")
        Call SetNodeText(objAttributeEqualsNode, "=")
        
        'Get the style
        If Not objNewCell.Attributes.getNamedItem("class") Is Nothing Then
          Set objStyleAttribute = objNewCell.Attributes.getNamedItem("class").cloneNode(True)
          Call objAttributeEqualsNode.Attributes.setNamedItem(objStyleAttribute)
        End If
        
        'Append
        Call objRowNode.appendChild(objAttributeEqualsNode)
        
        Set objAttributeValueNode = objXML.createNode(NODE_ELEMENT, "td", "")
        Call AddClonedValueOfCell(objAttributeEqualsNode, strXPath & "/@" & objAttribute.Name)
        
        'Append the cells to the row
        Call objRowNode.appendChild(objAttributeValueNode)
        
        'Append the row to the table
        Call objTableNode.appendChild(objRowNode)
        
        intCount = intCount + 1
      End If
    Next
    
    'Append the table to the cloned cell
    Call objNewCell.appendChild(objTableNode)
    
    'Append the cell to the parent
    Call objCellTemplate.parentNode.appendChild(objNewCell)
  End If
                                          
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : ReplaceHeaderRow(objXSL, objNewHeaderXSL)                 '
' Description   : Replace the header row of the template with the new       '
'               : header.                                                   '
' Inputs        : objXSL          -- XSL for the group                      '
' Outputs       : objNewHeaderXSL -- New XSL for the header                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ReplaceHeaderRow(ByRef objXSL As IXMLDOMNode, _
                          ByRef objNewHeaderXSL As IXMLDOMNode)
  Dim objHeaderRow As IXMLDOMNode     'header row
  
  Set objHeaderRow = objXSL.selectSingleNode("//tr[@id='TABLE_HEADER_ROW']")
  Call objHeaderRow.parentNode.replaceChild(objNewHeaderXSL, objHeaderRow)

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : MakeInputNode(eEditType, objXSL, strValue,                  '
'             :                      collOptions)                           '
' Description : Get a template node based on the edit type.                 '
' Inputs      : eEditType -- Edit type for the object.                      '
'             : objXSL    -- XSL for the input                              '
'             : strValue  -- value of the node                              '
'             : collOptions -- collection of options, for certain types.    '
' Outputs     : A node with the input.                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function MakeInputNode(ByRef eEditType As FlexEditType, _
                       ByRef objXSLNode As IXMLDOMNode, _
                       ByRef strName As String, _
                       ByRef strValue As String, _
                       ByRef collOptions As Collection, _
                       ByRef bRefresh As Boolean, _
                       Optional ByVal bReadOnly As Boolean = False)
  
  Dim objXML As New DOMDocument30
  Dim objTemplateNode As IXMLDOMNode
  Dim objAttributeNode As IXMLDOMAttribute
  Dim objNode As IXMLDOMNode
  Dim objNewNode As IXMLDOMNode
  Dim objNewAttribute As IXMLDOMAttribute
  Dim i As Integer
  
  'Get the correct node type, remove those that do not apply
  'If readonly, use the prompt
  Set objNode = objXSLNode.selectSingleNode("//td[@id='DIALOG_READONLY']")
  If bReadOnly Then
    Call SetNodeText(objNode, strValue)
    
    'Create a hidden input
    Set objNewNode = objXML.createNode(NODE_ELEMENT, "input", "")
    Set objNewAttribute = objXML.createAttribute("type")
    objNewAttribute.Value = "hidden"
    
    Call objNewNode.Attributes.setNamedItem(objNewAttribute)
    
    Call objNode.appendChild(objNewNode)
    
    'Set the name of the input
    Call SetInputName(objNode, "input", strName)
    
  Else
    Call objNode.parentNode.removeChild(objNode)
  End If
  
    
  Set objNode = objXSLNode.selectSingleNode("//td[@id='DIALOG_CHECKBOX_INPUT']")
  If eEditType = CHECK And Not bReadOnly Then
    Set objTemplateNode = objNode
  Else
    Call objNode.parentNode.removeChild(objNode)
  End If
   
  Set objNode = objXSLNode.selectSingleNode("//td[@id='DIALOG_HIDDENTEXT_INPUT']")
  If eEditType = HIDDENTEXT And Not bReadOnly Then
    Set objTemplateNode = objNode
  Else
    Call objNode.parentNode.removeChild(objNode)
  End If
   
  Set objNode = objXSLNode.selectSingleNode("//td[@id='DIALOG_RADIO_INPUT']")
  If eEditType = RADIO And Not bReadOnly Then
    Set objTemplateNode = objNode
  Else
    Call objNode.parentNode.removeChild(objNode)
  End If
    
  Set objNode = objXSLNode.selectSingleNode("//td[@id='DIALOG_MULTI_SELECT_INPUT']")
  If eEditType = MULTIPLESELECT And Not bReadOnly Then
    Set objTemplateNode = objNode
  Else
    Call objNode.parentNode.removeChild(objNode)
  End If
      
  Set objNode = objXSLNode.selectSingleNode("//td[@id='DIALOG_SELECT_INPUT']")
  If eEditType = SINGLESELECT And Not bReadOnly Then
    Set objTemplateNode = objNode
  Else
    Call objNode.parentNode.removeChild(objNode)
  End If
  
  Set objNode = objXSLNode.selectSingleNode("//td[@id='DIALOG_TEXTAREA_INPUT']")
  If eEditType = TEXTAREA And Not bReadOnly Then
    Set objTemplateNode = objNode
  Else
    Call objNode.parentNode.removeChild(objNode)
  End If
  
  Set objNode = objXSLNode.selectSingleNode("//td[@id='DIALOG_TEXT_INPUT']")
  If eEditType = TEXTINPUT And Not bReadOnly Then
    Set objTemplateNode = objNode
  Else
    Call objNode.parentNode.removeChild(objNode)
  End If
  
  If Not bReadOnly Then
  
    'Add the refresh event to the node if necessary, only for selects now
    If bRefresh Then
      Set objNode = objTemplateNode.selectSingleNode(".//select")
      
      If Not objNode Is Nothing Then
        Set objAttributeNode = objXML.createAttribute("onChange")
        objAttributeNode.Value = "javascript:RefreshDialog();"
        Call objNode.Attributes.setNamedItem(objAttributeNode)
      End If
    End If
    
    'Now that we have the node, add values to it
    Select Case eEditType
      Case CHECK
        Call SetInputName(objTemplateNode, "input", strName)
      Case RADIO
        Call SetInputName(objTemplateNode, "input", strName)
  
      Case MULTIPLESELECT
        For Each objNode In objTemplateNode.childNodes
          If UCase(objNode.nodeName) = "INPUT" Then
            'Set the value of the input
            Set objAttributeNode = objXML.createAttribute("value")
            objAttributeNode.Value = strValue
            Call objNode.Attributes.setNamedItem(objAttributeNode)
            
            Call SetInputName(objTemplateNode, "select", strName)
          End If
        Next
      Case SINGLESELECT
        'Add the options
        For i = 1 To collOptions.Count
          If UCase(collOptions(i).Value) = UCase(strValue) Then
            Call AddOptionNode(objTemplateNode, collOptions(i).Display, collOptions(i).Value, True)
          Else
            Call AddOptionNode(objTemplateNode, collOptions(i).Display, collOptions(i).Value, False)
          End If
        Next
        
        Call SetInputName(objTemplateNode, "select", strName)
        
      Case TEXTAREA
        Set objNode = SetInputName(objTemplateNode, "textarea", strName)
        Call SetNodeText(objNode, strValue)
      
      Case TEXTINPUT
        Set objNode = SetInputName(objTemplateNode, "input", strName)
        
        Set objAttributeNode = objXML.createAttribute("value")
        objAttributeNode.Value = strValue
        Call objNode.Attributes.setNamedItem(objAttributeNode)
        
      Case HIDDENTEXT
        Set objNode = SetInputName(objTemplateNode, "input", strName)
        
        Set objAttributeNode = objXML.createAttribute("value")
        objAttributeNode.Value = strValue
        Call objNode.Attributes.setNamedItem(objAttributeNode)
    End Select
  End If
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : SetInputName(objNode, strName, strInput)                    '
' Description : Set the name of the specified input node, which is a child  '
'             : of objNode.                                                 '
' Inputs      : objNode -- contains the input node as a child etc.          '
'             : strName -- name of the input                                '
'             : strInput -- name of input tag                               '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function SetInputName(ByRef objNode As IXMLDOMNode, _
                      ByRef strInput As String, _
                      ByRef strName As String) As IXMLDOMNode
  Dim objXML As New DOMDocument30
  Dim objAttributeNode As IXMLDOMAttribute
  Dim objInputNode As IXMLDOMNode
  
  If objNode.childNodes.length > 0 Then
    For Each objInputNode In objNode.childNodes
      'recurse to find the node
      Call SetInputName(objInputNode, strInput, strName)
  
      'Set the name of the node
      If UCase(objInputNode.nodeName) = UCase(strInput) Then
        Set objAttributeNode = objXML.createAttribute("name")
        objAttributeNode.Value = strName
        Call objInputNode.Attributes.setNamedItem(objAttributeNode)
        Set SetInputName = objInputNode
        Exit For
      End If
    Next
  End If
                      
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : AddOptionNode(objNode, strOption, strValue, bSelected)      '
' Description : Add an option to the node, set the value and selected flag. '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function AddOptionNode(ByRef objNode As IXMLDOMNode, _
                       ByRef strOption As String, _
                       ByRef strValue As String, _
                       ByRef bSelected As Boolean)
  Dim objXML As New DOMDocument30
  Dim objOptionNode As IXMLDOMNode
  Dim objAttributeNode As IXMLDOMAttribute
  
  Set objOptionNode = objXML.createNode(NODE_ELEMENT, "option", "")
  
  Call SetNodeText(objOptionNode, strOption)
  
  If bSelected Then
    Set objAttributeNode = objXML.createAttribute("selected")
    objAttributeNode.Value = "true"
    Call objOptionNode.Attributes.setNamedItem(objAttributeNode)
  End If
                         
  Set objAttributeNode = objXML.createAttribute("value")
  objAttributeNode.Value = strValue
  Call objOptionNode.Attributes.setNamedItem(objAttributeNode)
  
  Call objNode.appendChild(objOptionNode)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function SetMatch(ByRef strMatch As String, ByRef objXSLNode As IXMLDOMNode)
  Dim objXML As New DOMDocument30
  Dim objAttribute As IXMLDOMAttribute
  Dim objTemplateNode As IXMLDOMNode
  
  Set objTemplateNode = objXSLNode.selectSingleNode("//xsl:template")
  
  Set objAttribute = objXML.createAttribute("match")
  objAttribute.Value = strMatch
  Call objTemplateNode.Attributes.setNamedItem(objAttribute)

End Function
