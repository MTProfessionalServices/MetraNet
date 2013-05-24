VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ConfigHelper"
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
' MTConfigHelper.ConfigHelper                                               '
'                                                                           '
' Description:  Controller object used to gather information about the      '
'               Metratech system.                                           '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mobjRCD As New MTRcd                'RCD object
Private mobjXML As New DOMDocument30        'XML document object
Private mobjFSO As New FileSystemObject     'Filesystem object

Private mstrExtension As String             'Name of extension to use

Private mbWait As Boolean


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Collections
Private mcollServiceDefinitions As Collection
Private mcollProductViews As Collection
Private mcollStages As Collection
Private mcollPITypes As Collection
Private mcollPerformanceResults As Collection
Private mcollApplicabilityRules As Collection
Private mcollReasonCodes As Collection


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      :   Initialize(bWait, strExtension)                         '
' Desccription  :   Initialized the object.                                 '
' Inputs        :   bWait -- If true, load data as needed, else load all    '
'                            data at once.                                  '
'               :   strExtension -- Optional.  Operate only in one          '
'               :                   extension.                              '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function Initialize(ByVal bWait As Boolean, _
                           Optional ByVal strExtension As String = "")
              
  'Store the extension name
  mstrExtension = strExtension
  
  mbWait = bWait
  
  'If not waiting, load the data
  If Not mbWait Then
    'Load all service definitions, properties, etc.
    Set mcollServiceDefinitions = Nothing
    Set mcollServiceDefinitions = New Collection
    Call LoadServiceDefinitions
    
    'Load all product view properties, etc.
    Set mcollProductViews = Nothing
    Set mcollProductViews = New Collection
    Call LoadProductViews
    
    'Load a collection of simple information about priceable item type
    'properties
    'Call LoadPITypeProperties
    
    'Load a collection of simple information about priceable items
    Call LoadPriceableItemTypes
    
    'Load stage information
    Set mcollStages = Nothing
    Set mcollStages = New Collection
    Call LoadStages
    
    'Load enumtype information
    'Call LoadEnumTypes
    
    'Load localization information
    'Call LoadLocalization
    
    'Load view-to-asp map information
    'LoadLoadViewToASPMap
    
    'Load performance results
    Set mcollPerformanceResults = Nothing
    Set mcollPerformanceResults = New Collection
    Call LoadPerformanceResults
    
    'Load applicability rules
    Set mcollApplicabilityRules = Nothing
    Set mcollApplicabilityRules = New Collection
    Call LoadApplicabilityRules
    
    'Load reason codes
    Set mcollReasonCodes = Nothing
    Set mcollReasonCodes = New Collection
    Call LoadReasonCodes
  End If
                           
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : LoadServiceDefinitions()                                '
' Description     : Load all service defintion data.                        '
' Inputs          : none                                                    '
' Outputs         : none                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function LoadServiceDefinitions()
  Dim objFileLIst As MTRcdFileList        'List of files returned by the RCD
  Dim varFile As Variant                  'Each file in the list
  Dim varExtension As Variant             'Each extension found by the RCD
  Dim objMSIX As MSIX                     'MSIX object
  
  For Each varExtension In mobjRCD.ExtensionList
   Set objFileLIst = mobjRCD.RunQueryInAlternateFolder("*.msixdef", True, mobjRCD.ExtensionDir & "/" & varExtension & "/config/service")
  
    For Each varFile In objFileLIst
      Set objMSIX = New MSIX
      
      Call objMSIX.LoadFromXML(varFile)
      
      'Simple check
      If Len(objMSIX.Name) > 0 Then
        Call mcollServiceDefinitions.Add(objMSIX)
      End If
    Next
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : LoadProductViews()                                      '
' Description     : Load all product view data.                             '
' Inputs          : none                                                    '
' Outputs         : none                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function LoadProductViews()
  Dim objFileLIst As MTRcdFileList          'List of files returned by the RCD
  Dim varFile As Variant                    'Each file in the list
  Dim varExtension As Variant               'Each extension found by the RCD
  Dim objMSIX As MSIX                       'MSIX object
  
  For Each varExtension In mobjRCD.ExtensionList
    Set objFileLIst = mobjRCD.RunQueryInAlternateFolder("*.msixdef", True, mobjRCD.ExtensionDir & "/" & varExtension & "/config/productview")
        
    For Each varFile In objFileLIst
      Set objMSIX = New MSIX
      
      Call objMSIX.LoadFromXML(varFile)
      
      'Simple Check
      If Len(objMSIX.Name) > 0 Then
        Call mcollProductViews.Add(objMSIX)
      End If
    Next
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : LoadStages()                                            '
' Description     : Load information about all stages into the object.      '
' Inputs          : none                                                    '
' Outputs         : none                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function LoadStages()
  Dim objFileLIst As MTRcdFileList      'RCD filelist
  Dim varFile As Variant                 'Each file
  
  Dim objNodeList As IXMLDOMNodeList
  Dim objNode As IXMLDOMNode
  
  Dim strService As String
  Dim strStage As String
  
  Dim objService As MSIX
  Dim objStage As Object
  
  'First step, load the stages from servicetostagemap.xml and update the
  'services.
  Set objFileLIst = mobjRCD.RunQuery("servicetostagemap.xml", True)
  
  For Each varFile In objFileLIst
    Call mobjXML.Load(varFile)
    
    If mobjXML.parseError Then
    
    
    Else
      'See if the servicedef has already been loaded.  If so, set the link to the stage name
      Set objNodeList = mobjXML.selectNodes("/xmlconfig/direction")
      
      For Each objNode In objNodeList
        strService = GetNodeText(objNode, "ServiceID")
        strStage = GetNodeText(objNode, "stage")
        
        For Each objService In mcollServiceDefinitions
          If UCase(strService) = UCase(objService.Name) Then
            Call objService.oName.SetAttributeValue("stage_name", strStage)
            Exit For
          End If
        Next
      Next
    End If
  
  Next
  
  
  'Now add the stages
  Set objFileLIst = mobjRCD.RunQuery("stage.xml", True)
  
  For Each varFile In objFileLIst
    Set objStage = CreateObject("MTServiceWizard.Stage")
    
    Call objStage.LoadFromFile(varFile)
    
    If Len(objStage.StageName) > 0 Then
      Call mcollStages.Add(objStage)
    End If
  Next

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetServiceStages(strService)                              '
' Description   : Return a collection of stages, based on a service.        '
' Inputs        : strService -- name of the service to get stages for.      '
' Outputs       : collection of stages.                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetServiceStages(ByVal strService As String) As Collection
  Dim objService As MSIX
  Dim collStages As New Collection
  Dim bFound As Boolean
  
  Dim objStage As Object
  
  bFound = False
  
  'First find the service
  For Each objService In mcollServiceDefinitions
    If UCase(objService.Name) = UCase(strService) Then
      bFound = True
      Exit For
    End If
  Next
  
  If bFound Then
    'Now that the service was found, get the stages
    Set objStage = GetStage(objService.oName.GetAttributeValue("stage_name"))
    
    'Add the stage to the collection
    If Not objStage Is Nothing Then
      Call collStages.Add(objStage)
      
      'Now loop and get all the stages
      Do While Not objStage Is Nothing
        Set objStage = GetStage(objStage.NextStage)
        
        If Not objStage Is Nothing Then
          Call collStages.Add(objStage)
        End If
      Loop
    End If
  End If
  
  Set GetServiceStages = collStages
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetStage(strStage)                                        '
' Description   : Get a stage with the matching name                        '
' Inputs        : strStage -- name of the stage to get.                     '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetStage(ByVal strStage As String) As Object
  Dim objStage As Object
  
  
  For Each objStage In mcollStages
    If UCase(objStage.StageName) = UCase(strStage) Then
      Set GetStage = objStage
      Exit Function
    End If
  Next
  
  Set GetStage = Nothing
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetStageList()                                            '
' Description   : Get a list of stages in the system.                       '
' Inputs        : None                                                      '
' Outputs       : Array containing a list of stages.                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetStageList()
  Dim arrStages() As Variant
  Dim objStage As Object
  Dim intCount As Integer
  
  intCount = 0
  
  For Each objStage In mcollStages
    ReDim Preserve arrStages(intCount)
    arrStages(intCount) = objStage.StageName
    
    intCount = intCount + 1
  Next
  
  If intCount > 0 Then
    GetStageList = arrStages
  Else
    GetStageList = ""
  End If
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetServiceDefinition(strService)                          '
' Description   : Return the service definition object for the service.     '
' Inputs        : strService -- Service name                                '
' Outputs       : MSIX object                                               '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetServiceDefinition(ByVal strService As String) As MSIX
  Dim objService As MSIX
  
  For Each objService In mcollServiceDefinitions
    If UCase(objService.Name) = UCase(strService) Then
      Set GetServiceDefinition = objService
      Exit Function
    End If
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetServiceCollection()                                    '
' Description   : Return the colleciton of service definition objects.      '
' Inputs        : none                                                      '
' Outputs       : Collection of service definitions.                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetServiceCollection()
  Set GetServiceCollection = mcollServiceDefinitions
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetProductViewCollection()                                '
' Description   : Return the colleciton of ProductView definition objects.  '
' Inputs        : none                                                      '
' Outputs       : Collection of ProductView definitions.                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetProductViewCollection()
  Set GetProductViewCollection = mcollProductViews
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetProductView(strProductView)                            '
' Description   : Return the product view object.                           '
' Inputs        : strProductView -- Product view name                       '
' Outputs       : MSIX object                                               '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetProductView(ByVal strProductView As String) As MSIX
  Dim objProductView As MSIX
  
  For Each objProductView In mcollProductViews
    If UCase(objProductView.Name) = UCase(strProductView) Then
      Set GetProductView = objProductView
      Exit Function
    End If
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetProductViewFromService(strService)                     '
' Description   : Attempt to figure out which product view is associated    '
'               : with a service.                                           '
' Inputs        : strService -- Name of the service                         '
' Outputs       : Collection of MSIX objects                                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetProductViewFromService(ByVal strService As String) As Collection
  Dim objProductView As MSIX
  Dim objStage As Object
  Dim objStageDependency As Object
    
  Dim collProductViews As New Collection       'Collection of product views to return
  
  Dim strPVName As String                      'PV Name
    
  Dim intCount As Integer                       'Counter
  
  
  
  'If the extension was not specified, then the stage can't be found
  If Len(mstrExtension) > 0 Then
  
    'Get the stages
    'Look for a plug-in that set's productview ID
    For Each objStage In GetServiceStages(strService)
      'Search all plug-ins for a ruleset that sets the productviewid
      
      For Each objStageDependency In objStage.Dependencies
        
        'Direct Dependencies
        strPVName = GetProductViewName(mobjRCD.ExtensionDir & "/" & mstrExtension & "/config/pipeline/" & objStage.StageName & "/" & objStageDependency.Name & ".xml")
        
        If Len(strPVName) > 0 Then
          Set objProductView = GetProductView(strPVName)
          
          If Not objProductView Is Nothing Then
            Call collProductViews.Add(objProductView)
          End If
        End If
        
        'Indirect Dependencies
        For intCount = 1 To objStageDependency.DependencyCount
          strPVName = GetProductViewName(mobjRCD.ExtensionDir & "/" & mstrExtension & "/config/pipeline/" & objStage.StageName & "/" & objStageDependency.DependencyItem(intCount) & ".xml")
            
          If Len(strPVName) > 0 Then
            Set objProductView = GetProductView(strPVName)
              
            If Not objProductView Is Nothing Then
              Call collProductViews.Add(objProductView)
            End If
          End If
        Next
      Next
    Next
  End If
              
        
  'If no _ProductViewID was found, or don't know extension assume service name
  If collProductViews.Count = 0 Or Len(mstrExtension) = 0 Then
    Set objProductView = GetProductView(strService)
    
    If Not objProductView Is Nothing Then
      Call collProductViews.Add(objProductView)
    End If
  End If
    
  Set GetProductViewFromService = collProductViews

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetProductViewName(strXMLPath)                            '
' Description   : Attempt to load the _ProductViewID field from a file      '
' Inputs        : strXMLPath -- XML path for the plug-in to check.          '
' Outputs       : string -- PV Name                                         '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function GetProductViewName(ByVal strXMLPath As String) As String
  Dim objActionNode As IXMLDOMNode        'action node
  Dim objValueNode As IXMLDOMNode         'prop_value node
  
  Call mobjXML.Load(strXMLPath)
  
  If Not mobjXML.parseError Then
    Set objActionNode = mobjXML.selectSingleNode("/action[prop_name='_ProductViewID'")
        
    If Not objActionNode Is Nothing Then
      Set objValueNode = objActionNode.selectSingleNode("prop_value")
          
      If Not objValueNode Is Nothing Then
        GetProductViewName = GetProductView(objValueNode.Text)
      End If
    End If
  End If
        
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : LoadPriceableItemTypes()                                  '
' Description   : Load cursory information about priceable items.           '
' Inputs        : none                                                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function LoadPriceableItemTypes()
  Dim objFileLIst As MTRcdFileList            'List of priceable item XML files
  Dim varFile As Variant                      'Each file in the list
  Dim varExtension As Variant                 'Used to iterate through extensions on the system
  Dim objPIType As PriceableItemType
  
  Set mcollPITypes = New Collection
  
  For Each varExtension In mobjRCD.ExtensionList
    Set objFileLIst = mobjRCD.RunQueryInAlternateFolder("*.xml", True, mobjRCD.ExtensionDir & "/" & varExtension & "/config/PriceableItems")
    
    For Each varFile In objFileLIst
      Set objPIType = New PriceableItemType
        
      Call objPIType.LoadFromXML(varFile)
        
      Call mcollPITypes.Add(objPIType)
    Next
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadPerformanceResults()                                    '
' Description : Load information about performance results and paths.       '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function LoadPerformanceResults()
  Dim objFSO As New FileSystemObject
  Dim objFolder As Folder
  Dim objFile As File
  Dim strName As String
  Dim objPerformanceResult As PerformanceResult
   
  On Error GoTo ErrorHandler
   
  Set objFolder = objFSO.GetFolder(mobjRCD.InstallDir & "/Tests Database/ASPPerformance")
  
  If Not objFolder Is Nothing Then
    For Each objFile In objFolder.Files
      If LCase(Right(objFile.Path, 4)) = ".xml" Then
        Set objPerformanceResult = New PerformanceResult
        
        strName = LCase(Replace(objFile.Path, "\", "/"))
        
        strName = Mid(strName, InStrRev(strName, "/") + 1)
        strName = Mid(strName, 1, InStrRev(strName, ".xml") - 1)
        
        objPerformanceResult.Name = strName
        objPerformanceResult.ResultPath = objFile.Path
        
        Call mcollPerformanceResults.Add(objPerformanceResult)
      End If
    Next
  End If
  
  'If error, do nothing
ErrorHandler:
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : GetPerformanceResults                                       '
' Description : Return the performance results collection.                  '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetPerformanceResults() As Collection
  Dim collResults As New Collection
  Dim objResult As PerformanceResult
  
  For Each objResult In mcollPerformanceResults
    Call collResults.Add(objResult)
  Next
  
  Set GetPerformanceResults = collResults

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadApplicabilityRules()                                    '
' Description : Load the applicability rule metadata for the system.        '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function LoadApplicabilityRules()
  Dim objFileLIst As MTRcdFileList                'List of applicability rules XML files
  Dim varFile As Variant                          'Each file in the list
  Dim varExtension As Variant                     'Used to iterate through list of extensions
  Dim objApplicabilityRule As ApplicabilityRule   'Applicability rule metadata container
  Dim objNodeList As IXMLDOMNodeList              'List of applicability rule nodes
  Dim objNode As IXMLDOMNode                      'Used to iterate through node list
  Dim objTempNode As IXMLDOMNode                  'Used to get node values
  
  Set mcollApplicabilityRules = Nothing
  Set mcollApplicabilityRules = New Collection
  
  For Each varExtension In mobjRCD.ExtensionList
    Set objFileLIst = mobjRCD.RunQueryInAlternateFolder("ApplicabilityRules.xml", True, mobjRCD.ExtensionDir & "/" & varExtension & "/config/Adjustments")
    
    For Each varFile In objFileLIst
      Call mobjXML.Load(varFile)
      
      If Not mobjXML.parseError Then
        Set objNodeList = mobjXML.selectNodes("/mt_config/applicabilityrule")
        
        For Each objNode In objNodeList
          Set objApplicabilityRule = New ApplicabilityRule
          
          'Name
          Set objTempNode = objNode.selectSingleNode("name")
          
          If Not objTempNode Is Nothing Then
            objApplicabilityRule.Name = objTempNode.Text
          Else
            objApplicabilityRule.Name = "##ERROR##"
          End If
          
          'Display Name
          Set objTempNode = objNode.selectSingleNode("displayname")
          
          If Not objTempNode Is Nothing Then
            objApplicabilityRule.DisplayName = objTempNode.Text
          Else
            objApplicabilityRule.DisplayName = "##ERROR##"
          End If
          
          'Description
          Set objTempNode = objNode.selectSingleNode("description")
          
          If Not objTempNode Is Nothing Then
            objApplicabilityRule.Description = objTempNode.Text
          Else
            objApplicabilityRule.Description = "##ERROR##"
          End If
          
          'Formula
          Set objTempNode = objNode.selectSingleNode("formula")
          
          If Not objTempNode Is Nothing Then
            objApplicabilityRule.Formula = objTempNode.Text
          Else
            objApplicabilityRule.Formula = "##ERROR##"
          End If
          
          'Calculation engine
          Set objTempNode = objNode.selectSingleNode("calculationengine")
          
          If Not objTempNode Is Nothing Then
            If IsNumeric(objTempNode.Text) Then
              objApplicabilityRule.CalculationEngine = CLng(objTempNode.Text)
            Else
              objApplicabilityRule.CalculationEngine = -1
            End If
          Else
            objApplicabilityRule.CalculationEngine = -1
          End If
          
          'Add the appliability rule metadata to the collection
          Call mcollApplicabilityRules.Add(objApplicabilityRule)
        Next
      End If
    Next
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : GetApplicabilityRules                                       '
' Description : Get the collection of applicability rule metadata objects.  '
' Inputs      : none                                                        '
' Outputs     : collection                                                  '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetApplicabilityRules() As Collection
  Dim collApplicabilityRules As New Collection
  Dim objApplicabilityRule As ApplicabilityRule
  
  'Load applicability rules to get newly created applicability rules
  Call LoadApplicabilityRules
  
  For Each objApplicabilityRule In mcollApplicabilityRules
    Call collApplicabilityRules.Add(objApplicabilityRule)
  Next
  
  Set GetApplicabilityRules = collApplicabilityRules
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadReasonCodes                                             '
' Description : Load all of the metadata for reason codes.                  '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function LoadReasonCodes()
  Dim objFileLIst As MTRcdFileList            'List of reason codes XML files
  Dim varFile As Variant                      'Each file in the list
  Dim varExtension As Variant                 'Used to iterate through extensions on the system
  Dim objReasonCode As ReasonCode
  Dim objNodeList As IXMLDOMNodeList          'Node list
  Dim objTempNode As IXMLDOMNode              'Node
  Dim objNode As IXMLDOMNode
  
  Set mcollReasonCodes = Nothing
  Set mcollReasonCodes = New Collection
  
  For Each varExtension In mobjRCD.ExtensionList
    Set objFileLIst = mobjRCD.RunQueryInAlternateFolder("ReasonCodes.xml", True, mobjRCD.ExtensionDir & "/" & varExtension & "/config/Adjustments")
    
    For Each varFile In objFileLIst
      Call mobjXML.Load(varFile)
      
      If Not mobjXML.parseError Then
        Set objNodeList = mobjXML.selectNodes("/mt_config/reasoncode")
        
        For Each objNode In objNodeList
          Set objReasonCode = New ReasonCode
          
          'Name
          Set objTempNode = objNode.selectSingleNode("name")
          
          If Not objTempNode Is Nothing Then
            objReasonCode.Name = objTempNode.Text
          Else
            objReasonCode.Name = "##ERROR##"
          End If
        
          'Display Name
          Set objTempNode = objNode.selectSingleNode("displayname")
          
          If Not objTempNode Is Nothing Then
            objReasonCode.DisplayName = objTempNode.Text
          Else
            objReasonCode.DisplayName = "##ERROR##"
          End If
          
                
          'Description
          Set objTempNode = objNode.selectSingleNode("description")
          
          If Not objTempNode Is Nothing Then
            objReasonCode.Description = objTempNode.Text
          Else
            objReasonCode.Description = "##ERROR##"
          End If
          
          'Add the reason code metadata to the collection
          Call mcollReasonCodes.Add(objReasonCode)
        Next
      End If
    Next
  Next


End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : GetReasonCodes                                              '
' Description : Return metadata for reason codes on the system              '
' Inputs      : none                                                        '
' Outputs     : collection                                                  '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetReasonCodes() As Collection
  Dim collReasonCodes As New Collection
  Dim objReasonCode As ReasonCode
  
  'Load the reason codes to pick up newly created reason codes
  Call LoadReasonCodes
  
  For Each objReasonCode In mcollReasonCodes
    Call collReasonCodes.Add(objReasonCode)
  Next

  Set GetReasonCodes = collReasonCodes

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : PrettyPrintXMLFile(strPath, intIndent, intStart)            '
' Description : PrettyPrint the selected XML file                           '
' Inputs      : strPath     --  Path to the XML                             '
'             : intIndent   --  Amount to indent each line                  '
'             : intStart    --  Column to start on                          '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function PrettyPrintXMLFile(ByVal strPath As String, _
                                   ByVal intIndent As Integer, _
                                   ByVal intStart As Integer, _
                                   Optional ByVal bStringOnly = False) As String
                                  
  PrettyPrintXMLFile = PrettyPrintXML(strPath, intIndent, intStart, bStringOnly)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Class_Initialize()
  mobjXML.async = False
  mobjXML.validateOnParse = False
  mobjXML.resolveExternals = False
End Sub
