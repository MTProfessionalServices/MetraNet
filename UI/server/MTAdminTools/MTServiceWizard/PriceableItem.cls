VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PriceableItem"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'----------------------------------------------------------------------------
' Copyright 1998-2001 by MetraTech Corporation
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
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
' This class is used by the service wizard ASP pages to faciliate creating
' a service through modifying the proper files and putting them in the
' correct location.  Specific methods for creating services based on the
' priceable items are included.
'----------------------------------------------------------------------------

Option Explicit

'---------------------------------------------------------------------------'
' Global Variables                                                          '
'---------------------------------------------------------------------------'

''''''''''''''''''''''''''''''''''''''''''''''''''
' Data directly associated with this priceable item
Private mstrName As String                        'Priceable Item name
Private mstrDescription As String                 'Description of the item

Private mstrParent As String                      'Parent of the item

Private mcollChildren As New Collection           'Children of the priceable item, by id

Private mcollParameterTables As New Collection    'Parameter tables

Private meType As MTPCEntityType                     'Priceable item type

Private mstrServiceDefinition As String             'Service definition linked to this
                                                    'priceable item.
Private mstrProductView As String                   'product view this pi is linked to
                                                    
Private mcollPropertyAttributes As New Collection   'Attribute values for properties

Private mintID As Long                              'ID


Private mcollCounterTypes As New Collection         'Available counter types

Private mcollCounterPropertyDefinitions As New Collection   'CPD's for counters
Private mcollCounters As New Collection                     'Counters

Private mcollCharges As New Collection              ' Charges (e.g. setup charge, transport charge) in the pi
Private mcollAdjustmentTypes As New Collection      ' Collection of Adjustment Types
'''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''
' Data indirectly associated, such as available compounds, etc.
Private mcollAvailableCompounds As New Collection   'Available parent/child p.items
Private mcollAvailableTables As New Collection      'Available parameter tables

Private mAdjustmentCol As New MTCollection
Private mReasonCodeAJTypeMap As New Dictionary
Dim objAdjustmentFormula As MetraTech_Adjustments.ICalculationFormula

Private mcollCompositeAdjustment As New Collection




'---------------------------------------------------------------------------'
' Functions                                                                 '
'---------------------------------------------------------------------------'
'---------------------------------------------------------------------------'
' Function    : Initialize(strExtension)                                    '
' Description : Initialize the priceable item.                              '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'---------------------------------------------------------------------------'
Function Initialize(ByRef strExtensionPath As String)
  Dim objXMLHelper As New XMLHelper
  Dim objRCD As New MTRcd           'RCD object
  Dim objFIlelist As MTRcdFileList  'File list object
  
  'Following are used for counters
  Dim objCounterNodeList As IXMLDOMNodeList
  Dim objCounterNode As IXMLDOMNode
  Dim objParamNodeList As IXMLDOMNodeList
  Dim objParamNode As IXMLDOMNode

  Dim objCounter As Counter               'Counter
  
  Dim strExtension As Variant       'Extension Object
  Dim strFile As Variant            'File names
  Dim strName As String             'name
  Dim strType As String             'pi type
  Dim objTempNode As IXMLDOMNode    'Temp node
  Dim strParent As String           'Parent pi type
  
  
  
  '1 -- Load the available compounds
  Set objFIlelist = objRCD.RunQueryInAlternateFolder("*.xml", True, strExtensionPath & PRICEABLE_ITEM_DIR)
  
  For Each strFile In objFIlelist
    strName = objXMLHelper.GetSingleNodeText(strFile, "/priceable_item/name")
    strType = objXMLHelper.GetSingleNodeText(strFile, "/priceable_item/item_type")
    strParent = objXMLHelper.GetSingleNodeText(strFile, "/priceable_item/relationships/parent")
    
    If Len(strName) > 0 And UCase(strName) <> UCase(mstrName) And Len(strParent) = 0 And UCase(mstrParent) <> UCase(strName) Then
      If UCase(strType) = "USAGE" Or UCase(strType) = "AGGREGATE" Then
        'Check if the priceableitem does not have any adjustments of type rebill (CR: 9397)
        Set objTempNode = objXMLHelper.GetSingleNode(strFile, "/priceable_item/adjustment_type[Kind='4']")
        
        If objTempNode Is Nothing Then
          Call mcollAvailableCompounds.Add(strName)
        End If
      End If
    End If
  Next
  
  '2 -- Load the Parameter Tables
  For Each strExtension In objRCD.ExtensionList
    Set objFIlelist = objRCD.RunQueryInAlternateFolder("*.msixdef", True, objRCD.ExtensionDir & "/" & strExtension & "/" & PARAMETER_TABLE_DIR)
  
    For Each strFile In objFIlelist
      strName = objXMLHelper.GetSingleNodeText(strFile, "/defineservice/name")
    
      If Len(strName) > 0 Then
        Call mcollAvailableTables.Add(strExtension & "/" & strName)
      End If
    Next
  Next

  
  '3 -- Load the Available Counters
  For Each strExtension In objRCD.ExtensionList
    strFile = objRCD.ExtensionDir & "/" & strExtension & COUNTER_TYPE_XML
    
    Set objCounterNodeList = objXMLHelper.GetMultipleNodes(strFile, "/mt_config/CounterTypes/CounterType")
    
    If Not objCounterNodeList Is Nothing Then
      For Each objCounterNode In objCounterNodeList
        Set objCounter = New Counter
      
        objCounter.Name = objCounterNode.selectSingleNode("Name").Text
        objCounter.Description = objCounterNode.selectSingleNode("Description").Text
      
        Set objParamNodeList = objCounterNode.selectNodes("FormulaDef/Params/Param")
      
        For Each objParamNode In objParamNodeList
          Call objCounter.AddParameter(objParamNode.selectSingleNode("Name").Text, _
                                       "", _
                                       "", _
                                       objParamNode.selectSingleNode("Kind").Text)
      
        Next
        
        'Add the counter object
        Call mcollCounterTypes.Add(objCounter)
      Next
    End If
  Next
End Function

'---------------------------------------------------------------------------'
' Function    : Clear                                                       '
' Description : set all members to initial state                            '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'---------------------------------------------------------------------------'
Private Function Clear()

    mstrName = ""
    mstrDescription = ""
    mstrParent = ""

    Set mcollChildren = Nothing
    Set mcollParameterTables = Nothing
    meType = 0

    mstrServiceDefinition = ""
    mstrProductView = ""
                                                    
    Set mcollPropertyAttributes = Nothing

    mintID = 0

    Set mcollCounterPropertyDefinitions = Nothing
    Set mcollCounters = Nothing
    Set mcollCharges = Nothing
    Set mcollAdjustmentTypes = Nothing
    Set mReasonCodeAJTypeMap = Nothing
End Function


'---------------------------------------------------------------------------'
' Function    : LoadFromXML(strXMLFIle)                                     '
' Description : Load the template priceable item from an XML file.          '
' Inputs      : strXMLFile -- string containing the path to the XML file.   '
' Outputs     : none                                                        '
'---------------------------------------------------------------------------'
Public Function LoadFromXML(ByVal strXMLFile As String, _
                            Optional ByVal strExtension = "")
  Dim objXMLHelper As New XMLHelper     'XML helper object
  Dim objNodeList As IXMLDOMNodeList    'List of XML nodes
  Dim objNode As IXMLDOMNode            'XML node
  
  Dim objApplicNodeList As IXMLDOMNodeList    'List of XML nodes
  Dim objApplicNode As IXMLDOMNode            'XML node
  Dim objRuleNode As IXMLDOMNode            'XML node
  
  Dim objReasonCodeNodeList As IXMLDOMNodeList    'List of XML nodes
  Dim objReasonCodesNode As IXMLDOMNode            'XML node
  Dim objReasonCodeNode As IXMLDOMNode            'XML node
  
  
  Dim objParameterNodeList As IXMLDOMNodeList   'Parameter node list
  Dim objParameterNode As IXMLDOMNode           'Parameter node
    
  Dim objDataNode As IXMLDOMNode
  Dim strProductView As String                  'Used when loading counter parameters
  Dim strKind As String                         'Used when loading counter parameters
  Dim strFormulaPart As String
  
  Dim objCounter As Counter
  Dim objCharge As Charge
  Dim objAdjustmentType As AdjustmentType
  Dim objATH As AdjustmentTypeHelper
  Dim adjustTypeBool As Boolean
  Dim ctx
  
  
  Dim objChargeProperty As ChargeProperty
  Dim objPropertyNodeList As IXMLDOMNodeList    'Property node list
  Dim objPropertyNode As IXMLDOMNode            'Property node
  
  Dim pc As New MTProductCatalog
  Dim reasoncodereader As New ReasonCodeFileReader
  Dim applicrulereader As New ApplicabilityRuleFileReader
  Set ctx = pc.GetSessionContext()
  
  Dim sEntireFormula As String
  
  
  
  
  'clear out state from previous load
  Call Clear
    
  If Len(strXMLFile) > 0 Then
    
    'validate xml file
    Call objXMLHelper.ValidateFormat(strXMLFile)
    
    'Get the name
    mstrName = objXMLHelper.GetSingleNodeText(strXMLFile, "/priceable_item/name")
  
    'Description
    mstrDescription = objXMLHelper.GetSingleNodeText(strXMLFile, "/priceable_item/description")
  
    'Charge Type
    Select Case UCase(objXMLHelper.GetSingleNodeText(strXMLFile, "/priceable_item/item_type"))
      Case "USAGE"
        meType = PCENTITY_TYPE_USAGE
      Case "RECURRING"
        meType = PCENTITY_TYPE_RECURRING
      Case "NON-RECURRING"
        meType = PCENTITY_TYPE_NON_RECURRING
      Case "DISCOUNT"
        meType = PCENTITY_TYPE_DISCOUNT
      Case "AGGREGATE"
        meType = PCENTITY_TYPE_AGGREGATE_CHARGE
    End Select
  
    'Get the CPD objects
    Set objNodeList = objXMLHelper.GetMultipleNodes(strXMLFile, "/priceable_item/counters/cpd")
    
    For Each objNode In objNodeList
      Call AddCPD(objNode.selectSingleNode("name").Text, _
                  objNode.selectSingleNode("display_name").Text, _
                  objNode.selectSingleNode("service_property").Text, _
                  objNode.selectSingleNode("preferred_counter_type").Text)
    Next
    
    'Get the counters objects
    Set objNodeList = objXMLHelper.GetMultipleNodes(strXMLFile, "/priceable_item/counters/counter")
    
    For Each objNode In objNodeList
      Set objCounter = New Counter
      objCounter.Name = objNode.selectSingleNode("name").Text
      objCounter.CounterType = objNode.selectSingleNode("type").Text
                                      
      Set objParameterNodeList = objNode.selectNodes("parameter")
      
      For Each objParameterNode In objParameterNodeList
        'Get the product view
        Set objDataNode = objParameterNode.selectSingleNode("product_view")
        If Not objDataNode Is Nothing Then
          strProductView = objDataNode.Text
        Else
          strProductView = ""
        End If
        
        'Get the kind
        Set objDataNode = objParameterNode.selectSingleNode("kind")
        If Not objDataNode Is Nothing Then
          strKind = objDataNode.Text
        Else
          strKind = ""
        End If
        
        Call objCounter.AddParameter(objParameterNode.selectSingleNode("name").Text, _
                                     strProductView, _
                                     objParameterNode.selectSingleNode("value").Text, _
                                     strKind)
 
      Next
      
      'Set the description, which is not currently used, but required
      objCounter.Description = "_blank_"
      Call mcollCounters.Add(objCounter)
    Next
    
    'service def and product view
    mstrServiceDefinition = objXMLHelper.GetSingleNodeText(strXMLFile, "/priceable_item/pipeline/service_definition")
    mstrProductView = objXMLHelper.GetSingleNodeText(strXMLFile, "/priceable_item/pipeline/product_view")
    
    ' charges (and the charge properties that love them)
    Set objNodeList = objXMLHelper.GetMultipleNodes(strXMLFile, "priceable_item/charges/charge")
    For Each objNode In objNodeList
      Set objCharge = New Charge
      objCharge.Name = objNode.selectSingleNode("name").Text
      objCharge.DisplayName = objNode.selectSingleNode("display_name").Text
      
      Set objPropertyNodeList = objNode.selectNodes("charge_property")
      For Each objPropertyNode In objPropertyNodeList
        objCharge.AddChargeProperty (objPropertyNode.selectSingleNode("name").Text)
      Next
      Call mcollCharges.Add(objCharge)
    Next
    
    ' adjustment types
    
    ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    'Populate stuff used by MPM
    Set objNodeList = objXMLHelper.GetMultipleNodes(strXMLFile, "priceable_item/adjustment_type")
    
    For Each objNode In objNodeList
      Set objATH = New AdjustmentTypeHelper
        
      objATH.Name = objNode.selectSingleNode("name").Text
      objATH.Description = objNode.selectSingleNode("description").Text
      objATH.DisplayName = objNode.selectSingleNode("displayname").Text
      
      If UCase(objNode.selectSingleNode("supportsBulk").Text) = "Y" Then
        objATH.SupportsBulk = True
      Else
        objATH.SupportsBulk = False
      End If
      
      ' If Not (objNode.selectSingleNode("DefaultAdjustmentDescription")) Is Nothing Then
      '   Dim defaultdesc As New AdjustmentDescription
      '   defaultdesc.DefaultDescription = objNode.selectSingleNode("DefaultAdjustmentDescription").Text
      '   objATH.DefaultDescription = defaultdesc
      '  End If
      
      objATH.CalculationEngine = CLng(objNode.selectSingleNode("CalculationEngine").Text)
      objATH.Kind = CLng(objNode.selectSingleNode("Kind").Text)
      
      
      strFormulaPart = objNode.selectSingleNode("formula").Text
      sEntireFormula = objNode.selectSingleNode("formula").Text
      
      'Try to avoid creating and reading unnecessary mpm_data node
      If objAdjustmentFormula Is Nothing Then
        Set objAdjustmentFormula = CreateObject("MetraTech.Adjustments.CalculationFormula")
      End If
      objAdjustmentFormula.Text = sEntireFormula
      
      strFormulaPart = objAdjustmentFormula.FormulaBody
      
      objATH.FormulaPart = strFormulaPart
      
      'Get the required inputs
      Dim objInputNodes As IXMLDOMNodeList
      Dim objInputNode As IXMLDOMNode
      Set objInputNodes = objNode.selectNodes("required_inputs/input_val")
      
      For Each objInputNode In objInputNodes
        Call objATH.AddRequiredInput(objInputNode.Attributes.getNamedItem("name").Text, _
                                     objInputNode.Attributes.getNamedItem("displayname").Text, _
                                     objInputNode.Attributes.getNamedItem("type").Text)
      Next
      
      
      objAdjustmentFormula.Compile
      
      'Instead of trying to rely on mpm_data node,
      'which doesn't exist in the XML file unless Adjustment type was generated with MPM
      'initially (chicken/egg problem), assume that a non-required input is a parameter
      'that exists in the formula, but is missing "required_inputs" meta data entry
      
      Dim ajFormulaParam As Object 'MetraTech_MTSQL.Parameter
      
      Dim objRequiredInput As AdjustmentIO
      Dim bIsNonRequiredInput As Boolean
      Dim objParams As mscorlib.IEnumerable
      
      
      Set objParams = objAdjustmentFormula.Parameters.Values
      
      
      'just iterate via required inputs. There is only a few of them
      For Each ajFormulaParam In objParams
        bIsNonRequiredInput = True
      
        For Each objRequiredInput In objATH.RequiredInputs
           If (objRequiredInput.Name = ajFormulaParam.Name Or _
                ajFormulaParam.Direction = MetraTech_MTSQL.ParameterDirection_Out) Then
               bIsNonRequiredInput = False
           End If
        Next
        If bIsNonRequiredInput = True And _
            ajFormulaParam.Direction = MetraTech_MTSQL.ParameterDirection_In Then
            Call objATH.AddNonRequiredInput(ajFormulaParam.Name, "[none]", GetAdjustmentFormulaDataType(ajFormulaParam.dataType))
        End If
      Next
      
      ''''''''''''''''''''''''''''''''''''''''
      'MPM USE ONLY  -- Non-Required inputs
      'Set objInputNodes = objNode.selectNodes("mpm_data/non_required_inputs/input_val")
      
      'For Each objInputNode In objInputNodes
      '  Call objATH.AddNonRequiredInput(objInputNode.Attributes.getNamedItem("name").Text, _
      '                                  objInputNode.Attributes.getNamedItem("displayname").Text, _
      '                                  objInputNode.Attributes.getNamedItem("type").Text)
      'Next
      ''''''''''''''''''''''''''''''''''''''''
      
      'Get the outputs
      Dim objOutputNodes As IXMLDOMNodeList
      Dim objOutputNode As IXMLDOMNode
      Set objOutputNodes = objNode.selectNodes("outputs/output_val")
      
      For Each objOutputNode In objOutputNodes
        Dim bRequired As Boolean
        
        bRequired = True
        
        If Not objOutputNode.Attributes.getNamedItem("optional") Is Nothing Then
          If UCase(objOutputNode.Attributes.getNamedItem("optional").Text) = "TRUE" Then
            bRequired = False
          End If
        End If
        
        If bRequired Then
          Call objATH.AddRequiredOutput(objOutputNode.Attributes.getNamedItem("name").Text, _
                                      objOutputNode.Attributes.getNamedItem("displayname").Text, _
                                      objOutputNode.Attributes.getNamedItem("type").Text)
        Else
          Call objATH.AddNonRequiredOutput(objOutputNode.Attributes.getNamedItem("name").Text, _
                                      objOutputNode.Attributes.getNamedItem("displayname").Text, _
                                      objOutputNode.Attributes.getNamedItem("type").Text)
        End If
      Next
      
      '''''''''''''''''''''''''''''''''''''''
      ' MPM USE ONLY -- Procedure name
      If Not objNode.selectSingleNode("mpm_data/formula_proc_name") Is Nothing Then
        objATH.ProcedureName = objNode.selectSingleNode("mpm_data/formula_proc_name").Text
      End If
      
      If Len(objATH.ProcedureName) = 0 Then
        objATH.ProcedureName = "CalculateAdjustment"
      End If
      '''''''''''''''''''''''''''''''''''''''
      
      '''''''''''''''''''''''''''''''''''''''
      'Applicability Rules
      Dim objARNodes As IXMLDOMNodeList
      Dim objARNode As IXMLDOMNode
      
      Set objARNodes = objNode.selectNodes("applicabilityrules/rule")
      For Each objARNode In objARNodes
        Call objATH.AddApplicabilityRule(objARNode.Text)
      Next
            
      '''''''''''''''''''''''''''''''''''''''
      'Reason Codes
      Dim objRCNodes As IXMLDOMNodeList
      Dim objRCNode As IXMLDOMNode
      
      Set objRCNodes = objNode.selectNodes("reasoncodes/reasoncode")
      For Each objRCNode In objRCNodes
        Call objATH.AddReasonCode(objRCNode.Text)
      Next
      
      'Add the ATH
      Call AddAdjustmentType(objATH)
    Next
                                      
      
    ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    'Reading the CompositeAdjustment and setting them in the PriceableItem
    Set objNodeList = objXMLHelper.GetMultipleNodes(strXMLFile, "priceable_item/composite_adjustment_type")
    SettingTheCompositeAdjustment objNodeList
    ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    
    ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    'Populate stuff used by synchronization
    Set objNodeList = objXMLHelper.GetMultipleNodes(strXMLFile, "priceable_item/adjustment_type")
    For Each objNode In objNodeList
      Set objAdjustmentType = New AdjustmentType
      
      objAdjustmentType.Name = objNode.selectSingleNode("name").Text
      objAdjustmentType.Description = objNode.selectSingleNode("description").Text
      objAdjustmentType.DisplayName = objNode.selectSingleNode("displayname").Text
      adjustTypeBool = objNode.selectSingleNode("supportsBulk").Text = "Y" Or objNode.selectSingleNode("supportsBulk").Text = "TRUE"
      If Not objNode.selectSingleNode("DefaultAdjustmentDescription") Is Nothing Then
        Dim defaultdesc As IAdjustmentDescription
        Set defaultdesc = New AdjustmentDescription
        defaultdesc.DefaultDescription = objNode.selectSingleNode("DefaultAdjustmentDescription").Text
        Set objAdjustmentType.DefaultAdjustmentDescription = defaultdesc
      End If
      objAdjustmentType.SupportsBulk = adjustTypeBool
      objAdjustmentType.AdjustmentFormula.EngineType = CLng(objNode.selectSingleNode("CalculationEngine").Text)

      'get applicability rules for this adjustment type
      Set objApplicNode = objNode.selectSingleNode("applicabilityrules")


      If Not objApplicNode Is Nothing Then
        Set objApplicNodeList = objApplicNode.selectNodes("rule")
        For Each objRuleNode In objApplicNodeList
            Dim Name
            Dim ar As IApplicabilityRule
            Name = objRuleNode.Text
            Set ar = applicrulereader.FindApplicabilityRuleByName(ctx, Name)
            objAdjustmentType.AddApplicabilityRule ar
        Next
      End If
      
      'get reason codes for this adjustment type
      Set objReasonCodesNode = objNode.selectSingleNode("reasoncodes")
      Dim pireasoncodes As New MTCollection


      If Not objReasonCodesNode Is Nothing Then
        Set objReasonCodeNodeList = objReasonCodesNode.selectNodes("reasoncode")
        For Each objReasonCodeNode In objReasonCodeNodeList
            Dim RCName
            Dim rc As IReasonCode
            RCName = objReasonCodeNode.Text
            Set rc = reasoncodereader.FindReasonCodeByName(ctx, RCName)
            pireasoncodes.Add rc
        Next
      End If

      objAdjustmentType.AdjustmentFormula.Text = objNode.selectSingleNode("formula").Text
      objAdjustmentType.Kind = CLng(objNode.selectSingleNode("Kind").Text)

      Dim col As IMTPropertyMetaDataSet
      Dim propMetaData As IMTPropertyMetaData
      Dim inputNode As IXMLDOMNode
      Dim inputNodesList As IXMLDOMNodeList
      Dim inputAttrs As IXMLDOMAttribute

      Set col = objAdjustmentType.RequiredInputs
      Set inputNodesList = objNode.selectNodes("required_inputs/input_val")
      For Each inputNode In inputNodesList
        With inputNode.Attributes
          Set propMetaData = col.CreateMetaData(.getNamedItem("name").Text)
          propMetaData.DisplayName = .getNamedItem("displayname").Text
          Select Case LCase(.getNamedItem("type").Text)
            Case "int32"
            Case "integer"
              propMetaData.dataType = PROP_TYPE_INTEGER
            Case "double"
              propMetaData.dataType = PROP_TYPE_DOUBLE
            Case "decimal"
              propMetaData.dataType = PROP_TYPE_DECIMAL
            Case "string"
              propMetaData.dataType = PROP_TYPE_STRING
            Case "timestamp"
              propMetaData.dataType = PROP_TYPE_TIME
            Case "boolean"
              propMetaData.dataType = PROP_TYPE_BOOLEAN
            Case "enum"
              ' how does this work?
              propMetaData.dataType = PROP_TYPE_ENUM
            Case "variant"
              propMetaData.dataType = PROP_TYPE_OPAQUE
            Case Else
              Call Err.Raise(-1, "MTServiceWizard::LoadFromXML", .getNamedItem("type").Text & " type not allowed on Adjustment input property")
          End Select
        End With
      Next

      'configure output properties

      Set col = objAdjustmentType.ExpectedOutputs
      Set inputNodesList = objNode.selectNodes("outputs/output_val")
      For Each inputNode In inputNodesList
        With inputNode.Attributes
          Set propMetaData = col.CreateMetaData(.getNamedItem("name").Text)
          propMetaData.DisplayName = .getNamedItem("displayname").Text
          Select Case LCase(.getNamedItem("type").Text)
            Case "int32"
            Case "integer"
              propMetaData.dataType = PROP_TYPE_INTEGER
            Case "double"
              propMetaData.dataType = PROP_TYPE_DOUBLE
            Case "decimal"
              propMetaData.dataType = PROP_TYPE_DECIMAL
            Case "string"
              propMetaData.dataType = PROP_TYPE_STRING
            Case "timestamp"
              propMetaData.dataType = PROP_TYPE_TIME
            Case "boolean"
              propMetaData.dataType = PROP_TYPE_BOOLEAN
            Case "enum"
              ' how does this work?
              propMetaData.dataType = PROP_TYPE_ENUM
            Case "variant"
              propMetaData.dataType = PROP_TYPE_OPAQUE
            Case Else
              Call Err.Raise(-1, "MTServiceWizard::LoadFromXML", .getNamedItem("type").Text & " type not allowed on Adjustment output property")
          End Select
        End With
      Next
      
      Call objAdjustmentType.SetSessionContext(ctx)
      Call mAdjustmentCol.Add(objAdjustmentType)
      
      'insert reason code map entry
      If mReasonCodeAJTypeMap.Exists(objAdjustmentType.Name) Then
        Call Err.Raise(-1, "MTServiceWizard::LoadFromXML", "Multiple adjustment types with the same name [" & objAdjustmentType.Name & "] were found.  The second was in file [" & strXMLFile & "]")
      End If
      
      Call mReasonCodeAJTypeMap.Add(objAdjustmentType.Name, pireasoncodes)
            
    Next
    
    'Parent
    mstrParent = objXMLHelper.GetSingleNodeText(strXMLFile, "/priceable_item/relationships/parent")
  
    'Children
    Set objNodeList = objXMLHelper.GetMultipleNodes(strXMLFile, "/priceable_item/relationships/child")
  
    For Each objNode In objNodeList
      Call mcollChildren.Add(objNode.Text)
    Next
  
    
    Call LoadParameterTableDataFromXML(strXMLFile, strExtension)
  End If
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadParameterTableDataFromXML(strExtension)                 '
' Description : Load data for the parameter tables from xml in the extension'
' Inputs      : strExtension - name of the extension                        '
'             : strXMLFile   - xml file with PI Type data
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function LoadParameterTableDataFromXML(ByVal strXMLFile As String, _
                                               ByVal strExtension As String)
  Dim objParameterTableData As ParameterTableData     'Parameter table data object
  Dim objXMLDoc As New DOMDocument                    'XML document
  
  Dim objNodeList As IXMLDOMNodeList                  'List of parameter table nodes
  Dim objNode As IXMLDOMNode                          'XML node
  
  Dim objDirectionNodeList As IXMLDOMNodeList         'List of Direction nodes in service to stage map
  Dim objDirectionNode As IXMLDOMNode                 'Iterate through each node in the list
  Dim objStageNode As IXMLDOMNode                     'Stage node
  
  Dim objXMLHelper As New XMLHelper                   'XML helper object
  Dim objRCD As New MTRcd                             'RCD object
  
  Dim strServiceToStageMapPath                        'path to servicetostagemap.xml
  
  Dim strStage                                        'Stage name
  Dim strStagePath                                    'Stage path
  Dim objFSO As New FileSystemObject                  'File system object
  Dim objFile As File                                 'File
  Dim objFolder As Object                             'Folder
  
  
  'Get the list of parameter table nodes
  objXMLDoc.async = False
  objXMLDoc.validateOnParse = False
  objXMLDoc.resolveExternals = False
  
  Call objXMLDoc.Load(strXMLFile)
  
  Set objNodeList = objXMLDoc.selectNodes("/priceable_item/parameter_table")
    
  'Get the list of stage nodes
  strServiceToStageMapPath = objRCD.ExtensionDir & "/" & strExtension & "/config/pipeline/servicetostagemap.xml"
  Set objDirectionNodeList = objXMLHelper.GetMultipleNodes(strServiceToStageMapPath, "/xmlconfig/direction")
    
  For Each objNode In objNodeList
    Set objParameterTableData = New ParameterTableData
      
    objParameterTableData.Name = objNode.Text
      
    'If an extension passed, get the rest of the data
    If Len(strExtension) > 0 Then
      'Get the first stage from the service to stage map
      For Each objDirectionNode In objDirectionNodeList
        If UCase(objDirectionNode.selectSingleNode("ServiceID").Text) = UCase(mstrServiceDefinition) Then
            
          'If the service name matches, get the stage
          Set objStageNode = objDirectionNode.selectSingleNode("stage")
          
          If Not objStageNode Is Nothing Then
            strStage = objStageNode.Text
            strStagePath = objRCD.ExtensionDir & "/" & strExtension & "/config/pipeline/" & strStage
            
            'Make sure everything exists
            If objFSO.FolderExists(strStagePath) Then
              Set objFolder = objFSO.GetFolder(strStagePath)
              
              For Each objFile In objFolder.Files
                If InStr(objFile.Name, "pcratelookup") > 0 Then
                  'If this the pcratelookup is the correct one, then load the other data
                  If UCase(objXMLHelper.GetSingleNodeText(objFile.Path, "/xmlconfig/mtconfigdata/processor/configdata/RateLookup/ParamTable")) = UCase(objParameterTableData.Name) Then
                    objParameterTableData.WeightOnKey = objXMLHelper.GetSingleNodeText(objFile.Path, "/xmlconfig/mtconfigdata/processor/configdata/RateLookup/WeightOnKey")
                    objParameterTableData.StartAt = objXMLHelper.GetSingleNodeText(objFile.Path, "/xmlconfig/mtconfigdata/processor/configdata/RateLookup/StartAt")
                    objParameterTableData.InSession = objXMLHelper.GetSingleNodeText(objFile.Path, "/xmlconfig/mtconfigdata/processor/configdata/RateLookup/InSession")
                  
                    'Got the data, exit the function
                  End If
                End If
              Next
            End If
          End If
        End If
      Next
    End If
  
    Call mcollParameterTables.Add(objParameterTableData)
  
  Next
 
End Function
'---------------------------------------------------------------------------'
' Function    : SaveToXML(strXMLFile)                                       '
' Description : Save the template priceable item to an XML file.            '
' Inputs      : strXMLFIle -- string containing path to the XML file.       '
' Outputs     : none                                                        '
'---------------------------------------------------------------------------'
Public Function SaveToXML(ByVal strXMLFile As String, _
                          Optional ByVal strExtension As String = "")
  Dim objXMLDoc As New DOMDocument          'new document
  Dim objNode As IXMLDOMNode                'General purpose node
  Dim objAttributeNode As IXMLDOMAttribute  'General purpose attribute
  Dim objMPMDataNode As IXMLDOMNode
  Dim objTempNode As IXMLDOMNode
  
  Dim objPINode As IXMLDOMNode            'Priceable item node
  Dim objEPNode As IXMLDOMNode            'Extended property node
  Dim objRelationshipsNode As IXMLDOMNode 'Node for the relationships
  Dim objPTNode As IXMLDOMNode            'Parameter table nodes (contains id)
  
  Dim objCountersNode As IXMLDOMNode      'Used for the counters section
  Dim objCounterSubNode As IXMLDOMNode    'Used for counters section
  Dim objParameterNode As IXMLDOMNode     'Parameters of counters
  
  Dim objChargesNode As IXMLDOMNode       'Used for the charges section
  Dim objChargeSubNode As IXMLDOMNode     'Used for charges section
  Dim objChargePropertyNode As IXMLDOMNode 'Used for charges section
  
  Dim objPipelineNode As IXMLDOMNode      'Pipeline node, used by MPM
  
  Dim objXMLHelper As New XMLHelper       'XML helper, used to pretty print
  
  Dim objPI As New MTPriceableItem        'Priceable item object
  Dim objProperty As MTProperty           'Item properties
  Dim objAttribute As MTAttribute         'Attributes of items
  
  'Counters
  Dim objCounter As Counter               'Counter object
  Dim objCPDef As CPDef                   'Counter property definition
  Dim objParameter As CounterParameter    'Parameters for counters
  
  Dim objParameterTableData As ParameterTableData   'Parameter Table Data object
  
  'Charges
  Dim objCharge As Charge                 'Charge object
  Dim objChargeProperty As ChargeProperty 'Charge Property object
  
  Dim strID As Variant                    'IDs
  
  Dim bFound As Boolean                   'Used to determine whether or not
                                          'to write a counter def.
  Dim objRCD As New MTRcd                 'RCD object
  Dim objFIlelist As New MTRcdFileList    'List of PI types
  Dim strFile As Variant
    
  Dim objPIPropertyAttribute As PIPropertyAttribute
  Dim objStage As Stage
  
  Dim objSWPI As New PriceableItem
  
  
  
    
  'Create the priceable item node, this is the document element
  Set objPINode = objXMLDoc.createNode(NODE_ELEMENT, "priceable_item", "")
  
  'Name
  Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "name", "")
  objNode.Text = mstrName
  Call objPINode.appendChild(objNode)
  
  'Description
  Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "description", "")
  objNode.Text = mstrDescription
  Call objPINode.appendChild(objNode)
  
  'Charge Type
  Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "item_type", "")

  Select Case meType
    Case PCENTITY_TYPE_DISCOUNT
      objNode.Text = "discount"
    Case PCENTITY_TYPE_NON_RECURRING
      objNode.Text = "non-recurring"
    Case PCENTITY_TYPE_RECURRING
      objNode.Text = "recurring"
    Case PCENTITY_TYPE_USAGE
      objNode.Text = "usage"
    Case PCENTITY_TYPE_AGGREGATE_CHARGE
      objNode.Text = "aggregate"
  End Select
  
  Call objPINode.appendChild(objNode)
  
  'Relationships
  Set objRelationshipsNode = objXMLDoc.createNode(NODE_ELEMENT, "relationships", "")
  
  'Parent
  Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "parent", "")
  objNode.Text = mstrParent
  Call objRelationshipsNode.appendChild(objNode)
  
  'Children
  For Each strID In mcollChildren
    Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "child", "")
    objNode.Text = strID
    Call objRelationshipsNode.appendChild(objNode)
    
    'Now, for each child, set the parent property of the corresponding
    ' priceable item
    If Len(strExtension) = 0 Then
      strExtension = Replace(strXMLFile, "\", "/")
      strExtension = Mid(strExtension, Len(objRCD.ExtensionDir) + 2)
      strExtension = Mid(strExtension, 1, InStr(strExtension, "/") - 1)
    End If
    
    Call objSWPI.LoadFromXML(objRCD.ExtensionDir & "/" & strExtension & "/config/PriceableItems/" & strID & ".xml")
    objSWPI.Parent = mstrName
    Call objSWPI.SaveToXML(objRCD.ExtensionDir & "/" & strExtension & "/config/PriceableItems/" & strID & ".xml")
    
  Next
  
  '''''''''''''''''''''''''''''''''''''''''''''''
  'Update any files that have this PI as parent, but shouldn't any longer
  Set objFIlelist = objRCD.RunQuery("config\PriceableItems\*.xml", True)
  
  For Each strFile In objFIlelist
    Call objSWPI.LoadFromXML(strFile)
    
    bFound = False
    
    If UCase(objSWPI.Parent) = UCase(mstrName) Then
      'See if this type still is a child
      For Each strID In mcollChildren
        If UCase(strID) = UCase(objSWPI.Name) Then
          bFound = True
          Exit For
        End If
      Next
      
      If Not bFound Then
        objSWPI.Parent = ""
        Call objSWPI.SaveToXML(strFile)
      End If
    End If
  Next
  '''''''''''''''''''''''''''''''''''''''''''''''
  
  'Append the relationship node
  Call objPINode.appendChild(objRelationshipsNode)
  
  
  'Parameter Tables
  For Each objParameterTableData In mcollParameterTables
    'Get the name
    strID = objParameterTableData.Name

    'Strip the extension name from the name of the parameter table
    'This is done by the ASP when the parameter tables are added
    'strID = Right(strID, Len(strID) - InStr(strID, "/"))
    Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "parameter_table", "")
    objNode.Text = strID
    Call objPINode.appendChild(objNode)
  Next
  
  'Make the counters node
  Set objCountersNode = objXMLDoc.createNode(NODE_ELEMENT, "counters", "")
  
  'Counter Property Definitions
  For Each objCPDef In mcollCounterPropertyDefinitions
    Set objCounterSubNode = objXMLDoc.createNode(NODE_ELEMENT, "cpd", "")
    
    'Name
    Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "name", "")
    objNode.Text = objCPDef.Name
    Call objCounterSubNode.appendChild(objNode)
    
    'Display Name
    Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "display_name", "")
    objNode.Text = objCPDef.DisplayName
    Call objCounterSubNode.appendChild(objNode)
    
    'Service Property
    Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "service_property", "")
    objNode.Text = objCPDef.ServiceProperty
    Call objCounterSubNode.appendChild(objNode)
    
    'Preferred counter type
    Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "preferred_counter_type", "")
    objNode.Text = objCPDef.PreferredCounterTypeName
    Call objCounterSubNode.appendChild(objNode)
    
    Call objCountersNode.appendChild(objCounterSubNode)
  Next
  
  'Counter Properties
  'Only add counters that are referenced by CPD objects
  For Each objCounter In mcollCounters
    
    Set objCounterSubNode = objXMLDoc.createNode(NODE_ELEMENT, "counter", "")
    
    'Name
    Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "name", "")
    objNode.Text = objCounter.Name
    Call objCounterSubNode.appendChild(objNode)
    
    'Type
    Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "type", "")
    objNode.Text = objCounter.CounterType
    Call objCounterSubNode.appendChild(objNode)
  
    'Parameters
    For Each objParameter In objCounter.Parameters
      Set objParameterNode = objXMLDoc.createNode(NODE_ELEMENT, "parameter", "")
      
      'name
      Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "name", "")
      objNode.Text = objParameter.Name
      Call objParameterNode.appendChild(objNode)
    
      'PV
      Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "product_view", "")
      
      
      'If the user chose properties from the product view during the wizard, set the
      ' product view name correctly.
      If objParameter.PV = "[temp_product_view]" Then
        objNode.Text = mstrServiceDefinition & "_temp"
      Else
        objNode.Text = objParameter.PV
      End If
      
      Call objParameterNode.appendChild(objNode)
      
      'Value
      Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "value", "")
      
      objNode.Text = Replace(objParameter.Value, "[temp_product_view]", mstrServiceDefinition & "_temp")
      Call objParameterNode.appendChild(objNode)
      
      'Kind
      Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "kind", "")
      objNode.Text = objParameter.Kind
      Call objParameterNode.appendChild(objNode)
      
      Call objCounterSubNode.appendChild(objParameterNode)
    Next
    
    Call objCountersNode.appendChild(objCounterSubNode)
  
  Next
  
  'Append the node
  Call objPINode.appendChild(objCountersNode)
  
  
  'Charges
  If mcollCharges.Count > 0 Then
    Set objChargesNode = objXMLDoc.createElement("charges")
    
    'Charge Definitions
    For Each objCharge In mcollCharges
      Set objChargeSubNode = objXMLDoc.createNode(NODE_ELEMENT, "charge", "")
      
      'Name
      Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "name", "")
      objNode.Text = objCharge.Name
      Call objChargeSubNode.appendChild(objNode)
      
      'Display Name
      Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "display_name", "")
      objNode.Text = objCharge.DisplayName
      Call objChargeSubNode.appendChild(objNode)
          
      For Each objChargeProperty In objCharge.ChargeProperties
        Set objChargePropertyNode = objXMLDoc.createNode(NODE_ELEMENT, "charge_property", "")
      
        ' Name
        Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "name", "")
        objNode.Text = objChargeProperty.Name
        Call objChargePropertyNode.appendChild(objNode)
        
        Call objChargeSubNode.appendChild(objChargePropertyNode)
      Next
      
      Call objChargesNode.appendChild(objChargeSubNode)
    Next
    
    ' Append all charges
    Call objPINode.appendChild(objChargesNode)
  End If
  
    
  'MPM Information
  Set objPipelineNode = objXMLDoc.createNode(NODE_ELEMENT, "pipeline", "")
  
  'Service Definition
  Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "service_definition", "")
  objNode.Text = mstrServiceDefinition
  Call objPipelineNode.appendChild(objNode)
  
  'Product View
  Set objNode = objXMLDoc.createNode(NODE_ELEMENT, "product_view", "")
  objNode.Text = mstrProductView
  Call objPipelineNode.appendChild(objNode)
  
  'Append the pipelinenode
  Call objPINode.appendChild(objPipelineNode)
  
  'Now add the adjustment types
  Dim objAT As AdjustmentTypeHelper
  Dim objATNode As IXMLDOMNode
       
  For Each objAT In mcollAdjustmentTypes
    Set objATNode = objXMLDoc.createElement("adjustment_type")
      
    'Name
    Set objNode = objXMLDoc.createElement("name")
    objNode.Text = objAT.Name
    Call objATNode.appendChild(objNode)
    
    'Description
    Set objNode = objXMLDoc.createElement("description")
    objNode.Text = objAT.Description
    Call objATNode.appendChild(objNode)
    
    'Display Name
    Set objNode = objXMLDoc.createElement("displayname")
    objNode.Text = objAT.DisplayName
    Call objATNode.appendChild(objNode)
    
    'Calculation engine
    Set objNode = objXMLDoc.createElement("CalculationEngine")
    objNode.Text = objAT.CalculationEngine
    Call objATNode.appendChild(objNode)
    
    'Supports Bulk
    Set objNode = objXMLDoc.createElement("supportsBulk")
    If objAT.SupportsBulk Then
      objNode.Text = "Y"
    Else
      objNode.Text = "N"
    End If
    Call objATNode.appendChild(objNode)
    
    'Formula
    Dim objCDATASec As IXMLDOMCDATASection
    Set objNode = objXMLDoc.createElement("formula")
    Set objCDATASec = objXMLDoc.createCDATASection(objAT.FormulaText & objAT.FormulaPart)
    
    Call objNode.appendChild(objCDATASec)
    'objNode.Text = "<![CDATA[" & objAT.FormulaText & objAT.FormulaPart & "]]>" 'objCDATASec.Text
    
    Call objATNode.appendChild(objNode)
    
    'Applicability rules
    Set objNode = objXMLDoc.createElement("applicabilityrules")
    
    Dim varAR
    For Each varAR In objAT.ApplicabilityRules
      Set objTempNode = objXMLDoc.createElement("rule")
      objTempNode.Text = varAR
      Call objNode.appendChild(objTempNode)
    Next
    Call objATNode.appendChild(objNode)
    
    'Only save reason codes for usage/aggregate
    If meType = PCENTITY_TYPE_USAGE Or meType = PCENTITY_TYPE_AGGREGATE_CHARGE Then
      'Reason codes
      Set objNode = objXMLDoc.createElement("reasoncodes")
      
      Dim varRC
      For Each varRC In objAT.ReasonCodes
        Set objTempNode = objXMLDoc.createElement("reasoncode")
        objTempNode.Text = varRC
        Call objNode.appendChild(objTempNode)
      Next
      Call objATNode.appendChild(objNode)
    End If
    
    'Kind
    Set objNode = objXMLDoc.createElement("Kind")
    objNode.Text = objAT.Kind
    Call objATNode.appendChild(objNode)
    
    'Add Inputs and Outputs
    Dim objInputsNode As IXMLDOMNode
    Dim objOutputsNode As IXMLDOMNode
    Dim objIONode As IXMLDOMNode
    Dim objIOAttr As IXMLDOMAttribute
    Dim objIO As AdjustmentIO
    
    Set objInputsNode = objXMLDoc.createElement("required_inputs")
    
    'Apparently ALL INPUTS are not required
    For Each objIO In objAT.RequiredInputs
      Set objIONode = objXMLDoc.createElement("input_val")
      
      'Name
      Set objIOAttr = objXMLDoc.createAttribute("name")
      objIOAttr.Value = objIO.Name
      Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Type
      Set objIOAttr = objXMLDoc.createAttribute("type")
      objIOAttr.Value = objIO.PropertyType
      Call objIONode.Attributes.setNamedItem(objIOAttr)
            
      'DisplayName
      Set objIOAttr = objXMLDoc.createAttribute("displayname")
      objIOAttr.Value = objIO.DisplayName
      Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Append
      Call objInputsNode.appendChild(objIONode)
    Next
    
    'Append the inputs node
    Call objATNode.appendChild(objInputsNode)
    
    '''''''''''''''''''''''''''''''''''''''''''''''
    'Create NODE for MPM ONLY data
    Set objMPMDataNode = objXMLDoc.createElement("mpm_data")
    
    'Create node for non-required inputs, which only go in the mpm_data section
    ' Set objInputsNode = objXMLDoc.createElement("non_required_inputs")
    
    'Add non required inputs to mpm_data node, but not to main adjustment XML
    'For Each objIO In objAT.NonRequiredInputs
    '  Set objIONode = objXMLDoc.createElement("input_val")
      
      'Name
    '  Set objIOAttr = objXMLDoc.createAttribute("name")
    '  objIOAttr.Value = objIO.Name
    '  Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Type
    ' Set objIOAttr = objXMLDoc.createAttribute("type")
    '  objIOAttr.Value = objIO.PropertyType
    '  Call objIONode.Attributes.setNamedItem(objIOAttr)
            
      'DisplayName
    '  Set objIOAttr = objXMLDoc.createAttribute("displayname")
    '  objIOAttr.Value = objIO.DisplayName
    '  Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Append
     '  Call objInputsNode.appendChild(objIONode)
    ' Next
    
    'Append to the MPM DATA
    'Call objMPMDataNode.appendChild(objInputsNode)
    
    
    'Add formula proc name
    Set objNode = objXMLDoc.createElement("formula_proc_name")
    objNode.Text = objAT.ProcedureName
    
    Call objMPMDataNode.appendChild(objNode)
    
    ''''''''''''''''''' END MPM_DATA NODE '''''''''''''''''''''''
    
    'Add ALL OUTPUTS
    Set objOutputsNode = objXMLDoc.createElement("outputs")
    
    For Each objIO In objAT.RequiredOutputs
      Set objIONode = objXMLDoc.createElement("output_val")
      
      'Name
      Set objIOAttr = objXMLDoc.createAttribute("name")
      objIOAttr.Value = objIO.Name
      Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Type
      Set objIOAttr = objXMLDoc.createAttribute("type")
      objIOAttr.Value = objIO.PropertyType
      Call objIONode.Attributes.setNamedItem(objIOAttr)
            
      'DisplayName
      Set objIOAttr = objXMLDoc.createAttribute("displayname")
      objIOAttr.Value = objIO.DisplayName
      Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Append
      Call objOutputsNode.appendChild(objIONode)
    Next
    
    For Each objIO In objAT.NonRequiredOutputs
      Set objIONode = objXMLDoc.createElement("output_val")
      
      'Optional
      Set objIOAttr = objXMLDoc.createAttribute("optional")
      objIOAttr.Value = "true"
      Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Name
      Set objIOAttr = objXMLDoc.createAttribute("name")
      objIOAttr.Value = objIO.Name
      Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Type
      Set objIOAttr = objXMLDoc.createAttribute("type")
      objIOAttr.Value = objIO.PropertyType
      Call objIONode.Attributes.setNamedItem(objIOAttr)
            
      'DisplayName
      Set objIOAttr = objXMLDoc.createAttribute("displayname")
      objIOAttr.Value = objIO.DisplayName
      Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Append
      Call objOutputsNode.appendChild(objIONode)
    Next
    
    'Append the outputs node
    Call objATNode.appendChild(objOutputsNode)
    
    ''''''''''''''
    ' APPEND MPM_DATA NODE -- NOTHING SHOULD BE APPENDED AFTER THIS
    Call objATNode.appendChild(objMPMDataNode)
    
    'That's it. Add the adjustment_type node
    Call objPINode.appendChild(objATNode)
  Next
  
  'Append the CompositeAdjustmentType node
  Call AppendCompositeAdjustmentType(objPINode)
  
  'Save the file
   Call objXMLDoc.appendChild(objPINode)
  
  'Save
  Call objXMLDoc.save(strXMLFile)
  
  'Pretty Print
  'Disable for now due to CDATA wackiness
 ' Call objXMLHelper.PrettyPrintXMLFile(strXMLFile, 2, 0)
    
End Function
'---------------------------------------------------------------------------'
' Function    : LoadFromDB(strID)                                           '
' Description : Load the priceable item from the database. If strID is      '
'             : empty, then just use data from a "stock" pi.                '
' Inputs      : strID -- string with the ID of the priceable item.          '
' Outputs     : none                                                        '
'---------------------------------------------------------------------------'
Public Function LoadFromDB(Optional ByVal strID As String = "")

End Function


'---------------------------------------------------------------------------'
'---------------------------------------------------------------------------'
' Properties                                                                '
'---------------------------------------------------------------------------'
'Name
Public Property Get Name() As String
  Let Name = mstrName
End Property

Public Property Let Name(ByVal strName As String)
  Let mstrName = strName
End Property

'Description
Public Property Get Description() As String
  Let Description = mstrDescription
End Property

Public Property Let Description(ByVal strDescription As String)
  Let mstrDescription = strDescription
End Property

'Parent
Public Property Get Parent() As String
  Let Parent = mstrParent
End Property

Public Property Let Parent(ByVal strParent As String)
  Let mstrParent = strParent
End Property

'Children
Public Property Get Children() As Collection
  Set Children = mcollChildren
End Property

Public Function RemoveAllChildren()
  Dim i As Integer
  
  For i = 1 To mcollChildren.Count
    Call mcollChildren.Remove(1)
  Next
  
End Function

Public Function RemoveChild(ByVal strName As String)
  Dim i As Integer
  
  For i = 1 To mcollChildren.Count
    If UCase(mcollChildren(i)) = UCase(strName) Then
      Call mcollChildren.Remove(i)
      Exit For
    End If
  Next
End Function

Public Function AddChild(ByVal strName As String)
  Dim i As Integer
  
  'Prevent addition of duplicates
  Call RemoveChild(strName)
  
  Call mcollChildren.Add(strName)
End Function
'Available (used for parents/children)
Public Property Get AvailableCompounds() As Collection
  Set AvailableCompounds = mcollAvailableCompounds
End Property
'Parameter Tables
Public Property Get ParameterTables() As Collection
  Set ParameterTables = mcollParameterTables
End Property


Public Function RemoveParameterTable(ByVal strName As String)
  Dim objParameterTableData As ParameterTableData
  Dim i As Integer
  
  
  For i = 1 To mcollParameterTables.Count
    Set objParameterTableData = mcollParameterTables(i)
    
    If UCase(objParameterTableData.Name) = UCase(strName) Then
      Call mcollParameterTables.Remove(i)
      Exit For
    End If
  Next

End Function

Public Function AddParameterTable(ByVal strName As String, _
                                  ByVal strExtension)
  Dim objParameterTableData As New ParameterTableData
  
  Call RemoveParameterTable(strName)
  
  objParameterTableData.Name = strName
  objParameterTableData.Extension = strExtension
  
  Call mcollParameterTables.Add(objParameterTableData)
End Function

Public Property Get AvailableParameterTables() As Collection
  Set AvailableParameterTables = mcollAvailableTables
End Property

'Property Attributes
Public Property Get PropertyAttributes() As Collection
  Set PropertyAttributes = mcollPropertyAttributes
End Property

'Item type
Public Property Get ItemType() As String
  Select Case meType
    Case PCENTITY_TYPE_DISCOUNT
      ItemType = "Discount"
    Case PCENTITY_TYPE_NON_RECURRING
      ItemType = "Non-recurring"
    Case PCENTITY_TYPE_RECURRING
      ItemType = "Recurring"
    Case PCENTITY_TYPE_USAGE
      ItemType = "Usage"
    Case PCENTITY_TYPE_AGGREGATE_CHARGE
      ItemType = "Aggregate"
  End Select
End Property

Public Property Get PCEntityType() As MTPCEntityType
  Let PCEntityType = meType
End Property

Public Property Let ItemType(ByVal strItemType As String)
  Select Case UCase(strItemType)
    Case "USAGE"
      meType = PCENTITY_TYPE_USAGE
    Case "RECURRING"
      meType = PCENTITY_TYPE_RECURRING
    Case "NON-RECURRING"
      meType = PCENTITY_TYPE_NON_RECURRING
    Case "DISCOUNT"
      meType = PCENTITY_TYPE_DISCOUNT
    Case "AGGREGATE"
      meType = PCENTITY_TYPE_AGGREGATE_CHARGE
  End Select
End Property
'Service
Public Property Let ServiceName(ByVal strServiceName As String)
  Let mstrServiceDefinition = strServiceName
End Property

Public Property Get ServiceName() As String
  Let ServiceName = mstrServiceDefinition
End Property

'ProductView
Public Property Let PVName(ByVal strPVName As String)
  Let mstrProductView = strPVName
End Property

Public Property Get PVName() As String
  Let PVName = mstrProductView
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Charges
Public Property Get Charges() As Collection
  Set Charges = mcollCharges
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'GetCharge
Public Function GetCharge(ByVal strName As String) As Charge
  Dim i As Integer      'Charge
  
  For i = 1 To mcollCharges.Count
    If UCase(mcollCharges.Item(i).Name) = UCase(strName) Then
      Set GetCharge = mcollCharges.Item(i)
      Exit Function
    End If
  Next

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'RemoveCharge
Public Function RemoveCharge(ByVal strName As String)
  Dim i As Integer      'Charge
  
  For i = 1 To mcollCharges.Count
    If UCase(mcollCharges.Item(i).Name) = UCase(strName) Then
      Call mcollCharges.Remove(i)
      Exit For
    End If
  Next

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'AddCharge
Public Function AddCharge(ByVal strName As String, _
                           ByVal strDisplayName As String)
  Dim objCharge As New Charge
  
  'First, remove, then add
  Call RemoveCharge(strName)
  
  'Now add
  objCharge.Name = strName
  objCharge.DisplayName = strDisplayName
  
  Call mcollCharges.Add(objCharge)
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Counters
Public Property Get CPDefs() As Collection
  Set CPDefs = mcollCounterPropertyDefinitions
End Property

Public Property Get Counters() As Collection
  Set Counters = mcollCounters
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'RemoveCPD
Public Function RemoveCPD(ByVal strName As String)
  Dim i As Integer      'Counter
  
  For i = 1 To mcollCounterPropertyDefinitions.Count
    If UCase(mcollCounterPropertyDefinitions.Item(i).Name) = UCase(strName) Then
      Call mcollCounterPropertyDefinitions.Remove(i)
      Exit For
    End If
  Next

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'AddCPD
Public Function AddCPD(ByVal strName As String, _
                       ByVal strDisplayName As String, _
                       ByVal strSDProperty As String, _
                       ByVal strPreferred As String)
  Dim objCPD As New CPDef
  
  'First, remove, then add
  Call RemoveCPD(strName)
  
  'Now add
  objCPD.Name = strName
  objCPD.DisplayName = strDisplayName
  objCPD.ServiceProperty = strSDProperty
  objCPD.PreferredCounterTypeName = strPreferred
  
  Call mcollCounterPropertyDefinitions.Add(objCPD)
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' GetCPD
Public Function GetCPD(ByVal strName As String) As CPDef
  Dim i As Integer      'Counter (get it?)
  
  For i = 1 To mcollCounterPropertyDefinitions.Count
    If UCase(mcollCounterPropertyDefinitions.Item(i).Name) = UCase(strName) Then
      Set GetCPD = mcollCounterPropertyDefinitions.Item(i)
      Exit Function
    End If
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'GetCounter
Public Function GetCounter(ByVal strName As String) As Counter
  Dim i As Integer      'Counter
  
  For i = 1 To mcollCounters.Count
    If UCase(mcollCounters.Item(i).Name) = UCase(strName) Then
      Set GetCounter = mcollCounters.Item(i)
      Exit Function
    End If
  Next

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'RemoveCounter
Public Function RemoveCounter(ByVal strName As String)
  Dim i As Integer      'Counter
  
  For i = 1 To mcollCounters.Count
    If UCase(mcollCounters.Item(i).Name) = UCase(strName) Then
      Call mcollCounters.Remove(i)
      Exit For
    End If
  Next

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'AddCounter
Public Function AddCounter(ByVal strName As String, _
                           ByVal strDescription As String, _
                           ByVal strType As String)
  Dim objCounter As New Counter
  
  'First, remove, then add
  Call RemoveCounter(strName)
  
  'Now add
  objCounter.Name = strName
  objCounter.Description = strDescription
  objCounter.CounterType = strType
  
  Call mcollCounters.Add(objCounter)
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Counter Types
Public Property Get CounterTypes() As Collection
  Set CounterTypes = mcollCounterTypes
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Adjustment Types
Public Function AddAdjustmentType(ByVal objAdjustmentType As AdjustmentTypeHelper)
  Call RemoveAdjustmentType(objAdjustmentType.Name)
  
  Call mcollAdjustmentTypes.Add(objAdjustmentType)
End Function

Public Function RemoveAdjustmentType(ByVal strName As String)
  Dim objAT As AdjustmentTypeHelper
  Dim intCount
  
  For intCount = 1 To mcollAdjustmentTypes.Count
    Set objAT = mcollAdjustmentTypes.Item(intCount)
    
    If UCase(objAT.Name) = UCase(strName) Then
      Call mcollAdjustmentTypes.Remove(intCount)
      Exit Function
    End If
  Next
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get AdjustmentTypes() As MTCollection
  Set AdjustmentTypes = mAdjustmentCol
End Property

Public Property Get ReasonCodes(ByVal strAJTypeName As String) As MTCollection
  Set ReasonCodes = mReasonCodeAJTypeMap.Item(strAJTypeName)
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get SWAdjustmentTypes() As Collection
  Set SWAdjustmentTypes = mcollAdjustmentTypes
End Property

Public Function GetAdjustmentType(ByVal strName As String)
  Dim objAT As AdjustmentTypeHelper

  For Each objAT In mcollAdjustmentTypes
    If UCase(objAT.Name) = UCase(strName) Then
      Set GetAdjustmentType = objAT
      Exit Function
    End If
  Next
End Function

Private Function GetAdjustmentFormulaDataType(aDataType As MetraTech_MTSQL.ParameterDataType) As String
    ' public __value enum ParameterDataType
    '        {
    '            Invalid = -1,
    '            Integer,
    '            Double,
    '            String,
    '            Boolean,
    '            Decimal,
    '            DateTime,
    '            Time,
    '            Enum,
    '            Null
    '        };
    Dim sDataType
    Select Case (aDataType)
    Case MetraTech_MTSQL.ParameterDataType.ParameterDataType_Boolean:
        GetAdjustmentFormulaDataType = "BOOLEAN"
        Exit Function
    Case MetraTech_MTSQL.ParameterDataType.ParameterDataType_DateTime:
        GetAdjustmentFormulaDataType = "DATETIME"
        Exit Function
    Case MetraTech_MTSQL.ParameterDataType.ParameterDataType_Decimal:
        GetAdjustmentFormulaDataType = "DECIMAL"
        Exit Function
    Case MetraTech_MTSQL.ParameterDataType.ParameterDataType_Double:
        GetAdjustmentFormulaDataType = "DOUBLE"
        Exit Function
    Case MetraTech_MTSQL.ParameterDataType.ParameterDataType_Enum
        GetAdjustmentFormulaDataType = "ENUM"
        Exit Function
    Case MetraTech_MTSQL.ParameterDataType.ParameterDataType_Integer
        GetAdjustmentFormulaDataType = "INTEGER"
        Exit Function
    Case MetraTech_MTSQL.ParameterDataType.ParameterDataType_String
        GetAdjustmentFormulaDataType = "VARCHAR"
        Exit Function
    End Select
    
    GetAdjustmentFormulaDataType = "UNKNOWN DATATYPE"

End Function
  

Private Function SettingTheCompositeAdjustment(objNodeList As IXMLDOMNodeList)
    Dim objNode As IXMLDOMNode
    Dim objATH As AdjustmentTypeHelper
    
    For Each objNode In objNodeList
      Set objATH = New AdjustmentTypeHelper
        
      objATH.Name = objNode.selectSingleNode("name").Text
      objATH.Description = objNode.selectSingleNode("description").Text
      objATH.DisplayName = objNode.selectSingleNode("displayname").Text
      
      'Get the required inputs
      Dim objInputNodes As IXMLDOMNodeList
      Dim objInputNode As IXMLDOMNode
      Set objInputNodes = objNode.selectNodes("required_inputs/input_val")
      
      For Each objInputNode In objInputNodes
        Call objATH.AddRequiredInput(objInputNode.Attributes.getNamedItem("name").Text, _
                                     objInputNode.Attributes.getNamedItem("displayname").Text, _
                                     objInputNode.Attributes.getNamedItem("type").Text)
      Next
      
      'Get the outputs
      Dim objOutputNodes As IXMLDOMNodeList
      Dim objOutputNode As IXMLDOMNode
      Set objOutputNodes = objNode.selectNodes("outputs/output_val")
      
      For Each objOutputNode In objOutputNodes
        Call objATH.AddRequiredOutput(objOutputNode.Attributes.getNamedItem("name").Text, _
                                      objOutputNode.Attributes.getNamedItem("displayname").Text, _
                                      objOutputNode.Attributes.getNamedItem("type").Text)

      Next
      
      'Adding the Child AdjustmentTypes
      Dim objChildAdjustmentNodes As IXMLDOMNodeList
      Dim objChildAdjustmentNode As IXMLDOMNode
      Set objChildAdjustmentNodes = objNode.selectNodes("ChildAdjustments/ChildAdjustment")
      For Each objChildAdjustmentNode In objChildAdjustmentNodes
        Dim objChildAdjustmentType As New ChildAdjTypeHelper
        objChildAdjustmentType.PIName = objChildAdjustmentNode.selectSingleNode("ChildPI").Text
        objChildAdjustmentType.AdjustmentTypeName = objChildAdjustmentNode.selectSingleNode("ChildAdjustmentType").Text
        Call objATH.AddChildAdjustmentTypes(objChildAdjustmentType)
        Set objChildAdjustmentType = Nothing
      Next
      
      'Add the ATH
      Call AddCompositeAdjustmentType(objATH)
    Next

End Function


Public Property Get SWCompositeAdjustmentTypes() As Collection
  Set SWCompositeAdjustmentTypes = mcollCompositeAdjustment
End Property


'Adjustment Types
Public Function AddCompositeAdjustmentType(ByVal objCompositeAdjustmentType As AdjustmentTypeHelper)
  Call RemoveCompositeAdjustmentType(objCompositeAdjustmentType.Name)
  
  Call mcollCompositeAdjustment.Add(objCompositeAdjustmentType)
End Function


Public Function GetCompositeAdjustmentType(ByVal strName As String)
  Dim objAT As AdjustmentTypeHelper

  For Each objAT In mcollCompositeAdjustment
    If UCase(objAT.Name) = UCase(strName) Then
      Set GetCompositeAdjustmentType = objAT
      Exit Function
    End If
  Next
End Function


Public Function RemoveCompositeAdjustmentType(ByVal strName As String)
  Dim objAT As AdjustmentTypeHelper
  Dim intCount
  
  For intCount = 1 To mcollCompositeAdjustment.Count
    Set objAT = mcollCompositeAdjustment.Item(intCount)
    
    If UCase(objAT.Name) = UCase(strName) Then
      Call mcollCompositeAdjustment.Remove(intCount)
      Exit Function
    End If
  Next
End Function


Private Function AppendCompositeAdjustmentType(ByRef piNode As IXMLDOMNode)
  'Now add the adjustment types
  Dim objAT As AdjustmentTypeHelper
  Dim objATNode As IXMLDOMNode
  Dim objXMLDoc As New DOMDocument          'new document
  Dim objNode As IXMLDOMNode                'General purpose node
  Dim objAttributeNode As IXMLDOMAttribute  'General purpose attribute
  
  For Each objAT In mcollCompositeAdjustment
    Set objATNode = objXMLDoc.createElement("composite_adjustment_type")
      
    'Name
    Set objNode = objXMLDoc.createElement("name")
    objNode.Text = objAT.Name
    Call objATNode.appendChild(objNode)
    
    'Description
    Set objNode = objXMLDoc.createElement("description")
    objNode.Text = objAT.Description
    Call objATNode.appendChild(objNode)
    
    'Display Name
    Set objNode = objXMLDoc.createElement("displayname")
    objNode.Text = objAT.DisplayName
    Call objATNode.appendChild(objNode)
    
    'Add Inputs and Outputs
    Dim objInputsNode As IXMLDOMNode
    Dim objOutputsNode As IXMLDOMNode
    Dim objIONode As IXMLDOMNode
    Dim objIOAttr As IXMLDOMAttribute
    Dim objIO As AdjustmentIO
    
    Set objInputsNode = objXMLDoc.createElement("required_inputs")
    
    'Apparently ALL INPUTS are not required
    For Each objIO In objAT.RequiredInputs
      Set objIONode = objXMLDoc.createElement("input_val")
      
      'Name
      Set objIOAttr = objXMLDoc.createAttribute("name")
      objIOAttr.Value = objIO.Name
      Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Type
      Set objIOAttr = objXMLDoc.createAttribute("type")
      objIOAttr.Value = objIO.PropertyType
      Call objIONode.Attributes.setNamedItem(objIOAttr)
            
      'DisplayName
      Set objIOAttr = objXMLDoc.createAttribute("displayname")
      objIOAttr.Value = objIO.DisplayName
      Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Append
      Call objInputsNode.appendChild(objIONode)
    Next
    
    'Append the inputs node
    Call objATNode.appendChild(objInputsNode)
    
    
    'Add ALL OUTPUTS
    Set objOutputsNode = objXMLDoc.createElement("outputs")
    
    For Each objIO In objAT.RequiredOutputs
      Set objIONode = objXMLDoc.createElement("output_val")
      
      'Name
      Set objIOAttr = objXMLDoc.createAttribute("name")
      objIOAttr.Value = objIO.Name
      Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Type
      Set objIOAttr = objXMLDoc.createAttribute("type")
      objIOAttr.Value = objIO.PropertyType
      Call objIONode.Attributes.setNamedItem(objIOAttr)
            
      'DisplayName
      Set objIOAttr = objXMLDoc.createAttribute("displayname")
      objIOAttr.Value = objIO.DisplayName
      Call objIONode.Attributes.setNamedItem(objIOAttr)
      
      'Append
      Call objOutputsNode.appendChild(objIONode)
    Next
    
    'Append the outputs node
    Call objATNode.appendChild(objOutputsNode)
    
    'Saving the Child Priceable Item and their Adjustment Type selected
    Dim objChildAdjustmentsNode As IXMLDOMNode
    Dim objChildAdjType As ChildAdjTypeHelper
    
    Set objChildAdjustmentsNode = objXMLDoc.createElement("ChildAdjustments")
    For Each objChildAdjType In objAT.ChildAdjustmentTypes
        Dim objChildNode As IXMLDOMNode
        Dim objChildAdjProps As IXMLDOMNode
        Set objChildNode = objXMLDoc.createElement("ChildAdjustment")
        
        Set objChildAdjProps = objXMLDoc.createElement("ChildPI")
        objChildAdjProps.Text = objChildAdjType.PIName
        objChildNode.appendChild objChildAdjProps
        
        Set objChildAdjProps = objXMLDoc.createElement("ChildAdjustmentType")
        objChildAdjProps.Text = objChildAdjType.AdjustmentTypeName
        objChildNode.appendChild objChildAdjProps
        
        objChildAdjustmentsNode.appendChild objChildNode
        
    Next
    
    Call objATNode.appendChild(objChildAdjustmentsNode)
    
    'That's it. Add the adjustment_type node
    Call piNode.appendChild(objATNode)
  Next

End Function
