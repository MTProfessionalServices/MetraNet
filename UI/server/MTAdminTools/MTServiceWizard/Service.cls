VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ServiceWizard"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'----------------------------------------------------------------------------
' Copyright 1998-2000 by MetraTech Corporation
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
' correct location.
'----------------------------------------------------------------------------
Option Explicit


'----------------------------------------------------------------------------
' Global Varirables
'----------------------------------------------------------------------------

Private mstrExtensionName As String     ' The name of the extension where the service will be located
Private mstrExtensionPath As String     ' The path to the extension
Private mstrMPMWorkingDir As String     ' The MPM working (scratch) directory
Private mstrMPMTemplateDir As String    ' Location of template files
Private mstrInstallDir As String        ' Location of the platform installation

Private mobjRCD As New RCDLib.MTRcd     ' RCD object, used to get information about the running system
Private mobjFSO As New FileSystemObject ' file system object, used for copying/moving files
Private mobjXML As New XMLHelper        ' Service Wizard XML Helper Object

Private mcollStages As New Collection   ' Collection of stage objects

Private mobjPriceableItem As PriceableItem  'Priceable item for the service

'Variables used at various stages of the wizard
Private mstrPVName As String            'Name of the product view -- Currently the  extra logic
                                        ' to handle PVs with different names than the
                                        ' service defs is not provided by this object
Private mstrPVDisplayName As String     'Localized display name for the product view
Private mstrPVParent As String          'the product view parent

Private mintNumStages As Integer        'Number of stages
'Private mstrStageName As String         'Name of the stage this service will use

Private mstrServiceTemplate As String   'service definition used as a template
Private mstrProductViewTemplate As String 'template for prouct view

Private mstrServiceName As String       'service name

Private marrServiceDefinitionFiles()    'All service definition files for the extension
Private marrProductViewFiles()          'All product view files for the extension

'----------------------------------------------------------------------------
' Init
'----------------------------------------------------------------------------
Public Function Init(ByVal strExtensionName As String, _
                     ByVal strWorkingDir As String, _
                     ByVal strTemplateDir As String)
  'Set the extension name
  If Len(strExtensionName) > 0 Then
    mstrExtensionName = strExtensionName
  Else
    Err.Raise vbObjectError + 1, "MTServiceWizard.init()", "The extension name is null!"
  End If
  
  'Set the MPM working directory
  If Len(strWorkingDir) > 0 Then
    mstrMPMWorkingDir = strWorkingDir
  Else
    Err.Raise vbObjectError + 1, "MTServiceWizard.init()", "The working directory path is null!"
  End If
  
  'Set the MPM template directory
  If Len(strTemplateDir) > 0 Then
    mstrMPMTemplateDir = strTemplateDir
  Else
    Err.Raise vbObjectError + 1, "MTServiceWizard.init()", "The template directory path is null!"
  End If
   
    
  'Check to see if our RCD object is valid and set the extension path
  If Not mobjRCD Is Nothing Then
    Call mobjRCD.Init
    mstrExtensionPath = mobjRCD.ExtensionDir & "/" & mstrExtensionName
    mstrInstallDir = mobjRCD.InstallDir
  Else
    Err.Raise vbObjectError + 1, "MTServiceWizard.init()", "The RCD object is not valid."
  End If
  
  'See if our filesystem object is not nothing
  If mobjFSO Is Nothing Then
    Err.Raise vbObjectError + 1, "MTServiceWizard.init()", "The template directory path is null!"
  End If
    
  'Set the XML helper to pretty print
  mobjXML.PrettyPrint = True
    
  'Set some strings to be blank
  mstrPVName = ""
  mstrPVDisplayName = ""
  mstrPVParent = ""

  mintNumStages = 0

  mstrServiceTemplate = ""

  mstrServiceName = ""
  
End Function

'----------------------------------------------------------------------------
' InitWorkingDirectory
' Clear the working directory and copy the blank templates to it
'----------------------------------------------------------------------------
Public Function InitWorkingDirectory()
  Dim objFolder As Object       'Folder object for the working directory
  Dim objSubFolder As Object
  Dim objFiles As Files         'Files list object
  Dim objFile As File           'File object
  
  
  
  'Delete all the files in the MPM working directory
  'Delete all the files in subfolders of the MPM working directory
  Set objFolder = mobjFSO.GetFolder(mstrMPMWorkingDir)
  
  If Not objFolder Is Nothing Then            'we were able to open the directory
    Set objFiles = objFolder.Files()          'get the files collection
    
    If Not objFiles Is Nothing Then           'we got some files
      For Each objFile In objFiles            'for each file in the collection
        Call objFile.Delete                   'delete the file
      Next
    End If
    
    'Remove files from subfolders
    For Each objSubFolder In objFolder.SubFolders
      Set objFiles = objSubFolder.Files
      
      If Not objFiles Is Nothing Then
        For Each objFile In objFiles
          Call objFile.Delete
        Next
      End If
    Next
    
  Else
    Err.Raise vbObjectError + 1, "MTServiceWizard.InitWorkingDirectory()", "Can't open the MPM working directory."
  End If
  
  
  
  
  
  'Copy all files from the template directory to the working directory
  Set objFolder = mobjFSO.GetFolder(mstrMPMTemplateDir)
  
  If Not objFolder Is Nothing Then
    Set objFiles = objFolder.Files()
    
    If Not objFiles Is Nothing Then
      For Each objFile In objFiles
       Call objFile.Copy(mstrMPMWorkingDir & "/" & objFile.Name, True)   'copy to the working dir, overwrite existing
      Next
    Else
      Err.Raise vbObjectError + 1, "MTServiceWizard.InitWorkingDirectory()", "Can't copy files from MPM Template directory."
    End If
  Else
    Err.Raise vbObjectError + 1, "MTServiceWizard.InitWorkingDirectory()", "Can't copy files from MPM Template directory."
  End If

End Function
'---------------------------------------------------------------------'
' Function GetServiceDefinitionProperties()                           '
'                                                                     '
' Description: Return an array containing a list of service           '
'              definition properties.                                 '
'                                                                     '
' Inputs: None:                                                       '
'                                                                     '
' Outputs: None                                                       '
'---------------------------------------------------------------------'
Public Function GetServiceDefinitionProperties()
  
  GetServiceDefinitionProperties = _
    mobjXML.GetMultipleNodeText(mstrMPMWorkingDir & "/" & BLANK_SERVICE_MSIXDEF, _
    SERVICE_DN_NODE_QUERY)
                                                                
End Function
'-------------------------------------------------------------------------'
' Function WriteMSIXDEFFiles()                                            '
'                                                                         '
' Description: Populate the service definition and product view template  '
'              files with the names chosen by the user.                   '
'                                                                         '
' Inputs: None                                                            '
'                                                                         '
' Outputs: None                                                           '
'-------------------------------------------------------------------------'
Public Function WriteMSIXDEFFiles()
  Dim strName As String
  
  'Service Definition
  strName = mstrServiceName
  
  If Not mobjXML.SetSingleNodeText(SERVICE_NAME_NODE_QUERY, _
                                   strName, _
                                   mstrMPMWorkingDir & "/" & BLANK_SERVICE_MSIXDEF) Then
    Err.Raise -1
  End If


  'Product View Definition
  strName = mstrPVName
  
  If Not mobjXML.SetSingleNodeText(SERVICE_NAME_NODE_QUERY, _
                                   strName, _
                                   mstrMPMWorkingDir & "/" & BLANK_PV_MSIXDEF) Then
    Err.Raise -1
  End If
  
  'Set the product view name in the set_pv_name xml
  Call mobjXML.SetSingleNodeText("/xmlconfig/mtconfigdata/processor/configdata/default_actions/action[prop_name='_ProductViewID']/prop_value", _
                                 mstrPVName, _
                                 mstrMPMWorkingDir & "/" & BLANK_SET_PV_NAME_XML)
End Function
'-------------------------------------------------------------------------'
' Function WriteNamespaceFile(strNamespace)                               '
'                                                                         '
' Description: Write information to the namespace file.  Used in Basic    '
'              Processing.                                                '
'                                                                         '
' Inputs: strNamespace - the namespace to write in the file.              '
'                                                                         '
' Outputs: None                                                           '
'-------------------------------------------------------------------------'
Public Function WriteNamespaceFile(strNamespace As String)
  
  If Not mobjXML.SetSingleNodeText(NAMESPACE_NODE_QUERY, _
                                   strNamespace, _
                                   mstrMPMWorkingDir & "/" & BLANK_NAMESPACE_XML) Then
    Err.Raise -1
  End If
  
End Function
'-------------------------------------------------------------------------'
' Function WriteAccountResolutionFile(strPayer)                           '
'                                                                         '
' Description: Write payer name to use for account resolution in Basic    '
'              Processing.  Works in conjunction with namespace.          '
'                                                                         '
' Inputs: strPayer - the name to resolve the account with.                '
'                                                                         '
' Outputs: None                                                           '
'-------------------------------------------------------------------------'
Public Function WriteAccountResolutionFile(strPayer)
  
  If Not mobjXML.SetSingleNodeText(PAYER_NODE_QUERY, _
                                   strPayer, _
                                   mstrMPMWorkingDir & "/" & BLANK_ACCOUNT_RESOLUTION_XML) Then
    Err.Raise -1
  End If
  
End Function
'-------------------------------------------------------------------------'
' Function    : WriteSetPINameFile()                                      '
' Description : The pi name must be set for the first pass stage of       '
'             : aggregate rated priceable items.                          '
' Inputs      :                                                           '
' Outputs     :                                                           '
'-------------------------------------------------------------------------'
Public Function WriteSetPINameFile()

  If Not mobjPriceableItem Is Nothing Then
    Call mobjXML.SetSingleNodeText(PINAME_NODE_QUERY, _
                                   mobjPriceableItem.Name, _
                                   mstrMPMWorkingDir & "/" & BLANK_SET_PI_TYPE_NAME_XML)
  End If
End Function
'-------------------------------------------------------------------------'
' Function    : WritePCRateLookupFile()                                   '
' Description : Write to the pc rate lookup file.                         '
' Inputs      :                                                           '
' Outputs     :                                                           '
'-------------------------------------------------------------------------'
Public Function WritePCRateLookupFiles()
  
  Dim objPTData As ParameterTableData       'Parameter table data object
  Dim objStage As Stage                     'Find the first stage
  Dim strStageName                          'Name of the first stage
  Dim strPath                               'Path for PCRatelookup to modify
  Dim strPTName                             'Name of the parameter table
  
  'Remove counting mechanism, since multiple Paramtables can be
  'specified in PCRateLookup plugin files
  
  'Get the name of the first stage
  For Each objStage In mcollStages
    If objStage.FirstStage Then
      strStageName = objStage.StageName
      Exit For
    End If
  Next
  
  'Only work it if the stage name is specified
  If Len(strStageName) > 0 Then
    If Not mobjPriceableItem Is Nothing Then
    
      For Each objPTData In mobjPriceableItem.ParameterTables
        strPath = mstrMPMWorkingDir & "/" & BLANK_PCRATELOOKUP_XML
        
        strPTName = objPTData.Name
        
        'Edit
        'If it has an indexed property, write the additional data, else
        'just write the pT name
        If objPTData.HasIndexedProperty Then
          
          Call mobjXML.AddSet(strPath, _
                              "/xmlconfig/mtconfigdata/processor/configdata", _
                              "RateLookup", _
                              Array("ParamTable", "WeightOnKey", "StartAt", "InSession"), _
                              Array(strPTName, objPTData.WeightOnKey, objPTData.StartAt, objPTData.InSession))
                                      
        Else
          
          Call mobjXML.AddSet(strPath, _
                              "/xmlconfig/mtconfigdata/processor/configdata", _
                              "RateLookup", _
                              Array("ParamTable"), _
                              Array(strPTName))
        End If
      Next
    End If
  End If
End Function
'-------------------------------------------------------------------------'
' Function WriteAssignValuesFile(strFederalTax, strStateTax, strCountyTax,'
'                                strLocalTax, strOtherTax, strAmount)     '
'                                                                         '
' Description: Write Data to the assign values plugin used in Basic       '
'              processing.                                                '
'                                                                         '
' Inputs:                                                                 '
'                                                                         '
' Outputs: None                                                           '
'-------------------------------------------------------------------------'
Public Function WriteAssignValuesFile(strFederalTax As String, _
                                      strStateTax As String, _
                                      strCountyTax As String, _
                                      strLocalTax As String, _
                                      strOtherTax As String, _
                                      strAmount As String)
  Dim arrInputs           'inputs in array form
  Dim arrInputNodeNames(5)
  Dim arrNames(2)         'names of the set to add
  Dim arrValues(2)        'values to addd
  Dim arrAttrNames(2)     'names of the attributes
  Dim arrAttrValues(2)    'values of the attributes
  Dim strAssignValuesFile 'file to edit
  Dim i
    
  'Set the file name
  strAssignValuesFile = mstrMPMWorkingDir & "/" & BLANK_ASSIGN_VALUES_XML
  
  'Initialize some of the arrays
  arrNames(0) = "SourceProp"
  arrNames(1) = "type"
  arrNames(2) = "DestProp"
  
  arrAttrNames(0) = ""
  arrAttrNames(1) = "ptype"
  arrAttrNames(2) = ""
  
  arrAttrValues(0) = ""
  arrAttrValues(1) = "DECIMAL"
  arrAttrValues(2) = ""
  
  'Set the node names that correspond to the inputs
  arrInputNodeNames(0) = "_FedTax"
  arrInputNodeNames(1) = "_StateTax"
  arrInputNodeNames(2) = "_CountyTax"
  arrInputNodeNames(3) = "_LocalTax"
  arrInputNodeNames(4) = "_OtherTax"
  arrInputNodeNames(5) = "_Amount"
  
  'The value for the ptype node is ignored, but it must match the
  'set type
  arrValues(1) = 0
  
  'Put the inputs into an array
  arrInputs = Array(strFederalTax, strStateTax, strCountyTax, strLocalTax, strOtherTax, strAmount)

  'Loop through the inputs and add the necessary
  For i = 0 To UBound(arrInputs)
    If arrInputs(i) <> "N/A" Then
      
      arrValues(0) = arrInputs(i)
      arrValues(2) = arrInputNodeNames(i)
      
      If Not mobjXML.AddSet(strAssignValuesFile, _
                            ASSIGNPROPS_NODE_QUERY, _
                            "AssignProp", _
                            arrNames, _
                            arrValues, _
                            arrAttrNames, _
                            arrAttrValues) Then
        Err.Raise 1
      
      End If
    End If
  
  Next

End Function
'-------------------------------------------------------------------------'
' Function WriteServiceToStageMapFile()                                   '
'                                                                         '
' Description: Link the service to a stage by writing to the              '
'              ServiceToStageMap.xml                                      '
'                                                                         '
' Inputs: None                                                            '
'                                                                         '
' Outputs: None                                                           '
'-------------------------------------------------------------------------'
Public Function WriteServiceToStageMapFile()
  Dim objStage As Stage
  Dim bAggregate As Boolean
  
  For Each objStage In mcollStages
    If objStage.FirstStage Then
    
    'Add the stage to the service-to-stage map
    'Make sure the stage is not already there
      If mobjXML.GetSingleNode(mstrExtensionPath & SERVICE_TO_STAGE_MAP_XML, _
                               XMLCONFIG_NODE_QUERY & "/direction[ServiceID=""" & mstrServiceName & """]") Is Nothing Then
  
        'If aggregate, the service name should point to the temp stage
        If Not mobjPriceableItem Is Nothing Then
          If UCase(mobjPriceableItem.ItemType) = "AGGREGATE" Then
            bAggregate = True
          Else
            bAggregate = False
          End If
        Else
          bAggregate = False
        End If
        
        
        If bAggregate Then
          If Not mobjXML.AddSet(mstrExtensionPath & SERVICE_TO_STAGE_MAP_XML, _
                                XMLCONFIG_NODE_QUERY, _
                                "direction", _
                                Array("ServiceID", "stage"), _
                                Array(mstrServiceName, objStage.StageName & "_temp"), _
                                Array("ptype", ""), _
                                Array("ID", "")) Then
            Err.Raise -1
          End If
        Else
          If Not mobjXML.AddSet(mstrExtensionPath & SERVICE_TO_STAGE_MAP_XML, _
                                XMLCONFIG_NODE_QUERY, _
                                "direction", _
                                Array("ServiceID", "stage"), _
                                Array(mstrServiceName, objStage.StageName), _
                                Array("ptype", ""), _
                                Array("ID", "")) Then
            Err.Raise -1
          End If
        End If
      End If
    End If
  Next
  
End Function
'-------------------------------------------------------------------------'
' Function WriteViewHierarcyFile()                                        '
'                                                                         '
' Description: Add the product view to the view hierarchy file            '
'                                                                         '
' Inputs: None                                                            '
'                                                                         '
' Outputs: None                                                           '
'-------------------------------------------------------------------------'
Public Function WriteViewHierarchyFile()
  
  'Check for existance of the view
  If mobjXML.GetSingleNode(mstrExtensionPath & VIEW_HIERARCHY_XML, _
                           VIEW_HIERARCHY_NODE_QUERY & "/view[id_view=""" & mstrServiceName & """]") Is Nothing Then
 
    'Add the product view
    If Not mobjXML.AddSet(mstrExtensionPath & VIEW_HIERARCHY_XML, _
                   VIEW_HIERARCHY_NODE_QUERY, _
                   "view", _
                   Array("id_view", "id_parent_view", "nm_view_type"), _
                   Array(mstrPVName, mstrPVParent, "Product"), _
                   Array("ptype", "ptype", ""), _
                   Array("ID", "ID", "")) Then
    '  Err.Raise -1
    '  Product Catalog Doesn't necessarily require the view_hierarchy
    End If
    
    'If aggregate, then add the first pass product view
    If Not mobjPriceableItem Is Nothing Then
      If UCase(mobjPriceableItem.ItemType) = "AGGREGATE" Then
        If Not mobjXML.AddSet(mstrExtensionPath & VIEW_HIERARCHY_XML, _
                              VIEW_HIERARCHY_NODE_QUERY, _
                              "view", _
                              Array("id_view", "id_parent_view", "nm_view_type"), _
                              Array(mstrPVName & "_temp", mstrPVParent, "Product"), _
                              Array("ptype", "ptype", ""), _
                              Array("ID", "ID", "")) Then
          'Err.Raise -1
        End If
      End If
    End If
  End If

End Function
'-------------------------------------------------------------------------'
' Function LocalizePVName()                                               '
'                                                                         '
' Description: Localize the product view display name.                    '
'                                                                         '
' Inputs: EnumObject to use -- passed in so the cached session object can '
'         be used, vastly improving performance.                          '
'                                                                         '
' Outputs: None                                                           '
'-------------------------------------------------------------------------'
Public Function LocalizePVName(objEnumHelper)



End Function
'---------------------------------------------------------------------'
' Function GetPVNames()                                               '
'                                                                     '
' Description: Return an array of product view names.                 '
'                                                                     '
' Inputs: None                                                        '
'                                                                     '
' Outputs: None                                                       '
'---------------------------------------------------------------------'
Public Function GetPVNames()
  Dim objFIlelist As RCDLib.MTRcdFileList
  Dim strFilename
  Dim arrRetVal()
  Dim intCount
  
  intCount = 0
  
  ReDim marrProductViewFiles(0)
  
  
  Set objFIlelist = mobjRCD.RunQueryInAlternateFolder("*.msixdef", _
                                                      True, _
                                                      mstrExtensionPath & PV_DIR)
  
  For Each strFilename In objFIlelist       'get the filename
    ReDim Preserve arrRetVal(intCount)
    ReDim Preserve marrProductViewFiles(intCount)
    
    arrRetVal(intCount) = mobjXML.GetSingleNodeText(strFilename, SERVICE_NAME_NODE_QUERY)
    
    marrProductViewFiles(intCount) = strFilename
    
    intCount = intCount + 1
  Next
  
  If intCount = 0 Then
    arrRetVal = Array("")
  End If
  
  GetPVNames = arrRetVal
    
End Function
'---------------------------------------------------------------------'
' Function GetServiceNames()                                          '
'                                                                     '
' Description: Return an array of service names.                      '
'                                                                     '
' Inputs: None                                                        '
'                                                                     '
' Outputs: None                                                       '
'---------------------------------------------------------------------'
Public Function GetServiceNames()
  Dim objFIlelist As RCDLib.MTRcdFileList
  Dim strFilename
  Dim arrRetVal()
  Dim intCount
  Dim objFile As File
  
  intCount = 0
  
  'Erase the data in the global sd file array
  ReDim arrServiceDefinitionFiles(0)
  
  Set objFIlelist = mobjRCD.RunQueryInAlternateFolder("*.msixdef", _
                                                      True, _
                                                      mstrExtensionPath & SERVICE_DIR)
  
  For Each strFilename In objFIlelist       'get the filename
    ReDim Preserve arrRetVal(intCount)
    ReDim Preserve marrServiceDefinitionFiles(intCount)
    
    Set objFile = mobjFSO.GetFile(strFilename)
    
    'If UCase(Replace(objFile.ParentFolder.Path, "\", "/")) <> UCase(Replace(mstrExtensionPath, "\", "/") & "/config/service") Then
    '  arrRetVal(intCount) = objFile.ParentFolder.Name & "/" & Left(objFile.Name, Len(objFile.Name) - Len("*.msixdef") + 1)
    'Else
    '  arrRetVal(intCount) = Left(objFile.Name, Len(objFile.Name) - Len("*.msixdef") + 1)
    'End If
    
    arrRetVal(intCount) = mobjXML.GetSingleNodeText(strFilename, SERVICE_NAME_NODE_QUERY)
    marrServiceDefinitionFiles(intCount) = strFilename
    
    intCount = intCount + 1
  Next
  
  If intCount = 0 Then
    arrRetVal = Array("")
  End If
  
  GetServiceNames = arrRetVal
    
End Function
'---------------------------------------------------------------------'
' Function CopyWorkingServiceToProduct()                              '
'                                                                     '
' Description: Copy the working service def. to the product view.     '
'                                                                     '
' Inputs: None                                                        '
'                                                                     '
' Outputs: None                                                       '
'---------------------------------------------------------------------'
Public Function CopyWorkingServiceToProduct()
  
  Call mobjFSO.CopyFile(mstrMPMWorkingDir & "/" & BLANK_SERVICE_MSIXDEF, _
                   mstrMPMWorkingDir & "/" & BLANK_PV_MSIXDEF, _
                   True)

End Function
'---------------------------------------------------------------------'
' Function CheckForDuplicateService()                                 '
'                                                                     '
' Description: Ensure that a service with the same name isn't in the  '
'              service to stage map.xml.                              '
'                                                                     '
' Inputs: None                                                        '
'                                                                     '
' Outputs: Returns false if no duplicate found.                       '
'---------------------------------------------------------------------'
Public Function CheckForDuplicateService(ByRef strStatus As Variant) As Boolean
  Dim strName As String
  Dim objFolder As Object
  Dim objFile As File
  Dim objStage As Stage
  Dim objParameterTableData As ParameterTableData
  Dim varName As Variant
  
  On Error Resume Next
  
  CheckForDuplicateService = False
  
  'Check the service directory for an existing service
  strName = mstrExtensionPath & "/config/service/" & mstrServiceName & ".msixdef"
    
  If mobjFSO.FileExists(strName) Then
    CheckForDuplicateService = True
    strStatus = "<br>A service definition file already exists."
  End If
  
  
  'Check the product view directory for existing product views
  strName = mstrExtensionPath & "/config/productview/" & mstrPVName & ".msixdef"
         
  If mobjFSO.FileExists(strName) Then
    CheckForDuplicateService = True
    strStatus = strStatus & "<br>A product view definiton file already exists."
  End If
                                                  
  'Check to see if the stage already exists for each stage
  'For Each objStage In mcollStages
  '  strName = FindStage(objStage.StageName)
    
  '  If Len(strName) > 0 Then
  '    CheckForDuplicateService = True
  '    strStatus = strStatus & "<br>The stage [" & objStage.StageName & "] already exists."
  '  End If
  'Next
  
  
  'Check for the priceable items and parameter tables
  If Not mobjPriceableItem Is Nothing Then
    If mobjFSO.FileExists(mstrExtensionPath & PRICEABLE_ITEM_DIR & "/" & Replace(mobjPriceableItem.Name, " ", "") & ".xml") Then
      CheckForDuplicateService = True
      strStatus = strStatus & "<br>The priceable item [" & mobjPriceableItem.Name & "] already exists."
    End If
    
    Set objFolder = mobjFSO.GetFolder(mstrMPMWorkingDir & "/ParameterTables")
    
    For Each objParameterTableData In mobjPriceableItem.ParameterTables
      varName = objParameterTableData.Name
    
      If mobjFSO.FileExists(mstrExtensionPath & PARAMETER_TABLE_DIR & "/" & Replace(varName, "_SLASH_", "/")) Then
        CheckForDuplicateService = True
        strStatus = strStatus & "<br>The parameter table [" & Replace(varName, "_SLASH_", "/") & "] already exists."
      End If
    Next
  End If
  
  
  'Check for the autosdk
  strName = mstrInstallDir & "/test/autoSDK/" & mstrServiceName & ".xml"
  
  If mobjFSO.FileExists(strName) Then
    CheckForDuplicateService = True
    strStatus = strStatus & "<br>An autoSDK file already exists."
  End If
                                                  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : FindStage(strStage)                                       '
' Description   : Based on the stage name, return the path to the stage.xml '
' Inputs        : strStage -- name of the stage.                            '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function FindStage(ByVal strStage As String) As String
  Dim objPipelineFolder As Object       'Pipeline folder
  Dim strExtension As Variant           'Extension

  For Each strExtension In mobjRCD.ExtensionList
    If mobjFSO.FolderExists(mobjRCD.ExtensionDir & "/" & strExtension & "/config/pipeline/" & strStage) Then
      If mobjFSO.FileExists(mobjRCD.ExtensionDir & "/" & strExtension & "/config/pipeline/" & strStage & "/stage.xml") Then
        FindStage = mobjRCD.ExtensionDir & "/" & strExtension & "/config/pipeline/" & strStage & "/stage.xml"
        Exit Function
      End If
    End If
  Next
End Function
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
' Let, Get for various properties
'----------------------------------------------------------------------------

''''''''''''''''''
'PVDisplayName
Public Property Get PVDisplayName() As String
  Let PVDisplayName = mstrPVDisplayName
End Property

Public Property Let PVDisplayName(ByVal Val As String)
  Let mstrPVDisplayName = Val
End Property

'''''''''''''''''''
'PVName
Public Property Get PVName() As String
  Let PVName = mstrPVName
End Property

Public Property Let PVName(ByVal Val As String)
  Let mstrPVName = Val
End Property

'''''''''''''''''''
'PVParent
Public Property Get PVParent() As String
  Let PVParent = mstrPVParent
End Property

Public Property Let PVParent(ByVal Val As String)
  Let mstrPVParent = Val
End Property

'''''''''''''''''''
'Stages
Public Property Get Stages() As Collection
  Set Stages = mcollStages
End Property

Public Function AddStage(ByVal Val As String, _
                         ByVal strXMLFile As String, _
                         ByVal bRemoveable As Boolean)
  Dim objStage As Stage
  
  For Each objStage In mcollStages
    If UCase(objStage.StageName) = UCase(Val) Then
      Exit Function
    End If
  Next
  
  Set objStage = New Stage
  
  'Load from file if requested
  If Len(strXMLFile) > 0 Then
    Call objStage.LoadFromFile(strXMLFile)
  End If
  
  If mcollStages.Count > 0 Then
    objStage.FirstStage = False
  End If
  
  objStage.Removeable = bRemoveable
  
  objStage.StageName = Val
  
  Call mcollStages.Add(objStage)
  
End Function

Public Function RemoveStage(ByVal Val As String)
  Dim objStage As Stage
  Dim strNewNext As String
  Dim i
  
  For i = 1 To mcollStages.Count
    Set objStage = mcollStages(i)
    
    If UCase(objStage.StageName) = UCase(Val) Then
      strNewNext = objStage.NextStage
      Call mcollStages.Remove(i)
      Exit For
    End If
  Next
  
  For i = 1 To mcollStages.Count
    Set objStage = mcollStages(i)
    
    If mcollStages.Count = 1 Then
      objStage.FirstStage = True
    End If
    
    If UCase(objStage.NextStage) = UCase(Val) Then
      objStage.NextStage = strNewNext
    End If
  Next
End Function

'''''''''''''''''''
'ServiceTemplateFile
Public Property Get ServiceTemplate() As String
  Let ServiceTemplate = mstrServiceTemplate
End Property

Public Property Let ServiceTemplate(ByVal Val As String)
  Let mstrServiceTemplate = Val
End Property
'''''''''''''''''''
'Product View Template
Public Property Get ProductViewTemplate() As String
  Let ProductViewTemplate = mstrProductViewTemplate
End Property

Public Property Let ProductViewTemplate(ByVal Val As String)
  Let mstrProductViewTemplate = Val
End Property

'''''''''''''''''''
'ServiceName
Public Property Get ServiceName() As String
  Let ServiceName = mstrServiceName
End Property

Public Property Let ServiceName(ByVal Val As String)
  Let mstrServiceName = Val
End Property

'''''''''''''''''''
'InstallDir -- Get Only
Public Property Get InstallDir() As String
  Let InstallDir = mstrInstallDir
End Property

''''''''''''''''''''
'ServiceDefinitions
Public Property Get ServiceDefinitions(ByVal intIndex As Integer) As String
  If intIndex < 0 Or intIndex > UBound(marrServiceDefinitionFiles) Then
    Let ServiceDefinitions = ""
  Else
    Let ServiceDefinitions = marrServiceDefinitionFiles(intIndex)
  End If
End Property
''''''''''''''''''''
'ServiceDefinitions
Public Function GetServicePaths()
  GetServicePaths = marrServiceDefinitionFiles
End Function
''''''''''''''''''''
'Product View
Public Function GetProductView()
  GetProductView = marrProductViewFiles
End Function

Public Function GetProductViewPaths()
  GetProductViewPaths = marrProductViewFiles
End Function
'''''''''''''''''''
'Extension Path
Public Property Get ExtensionPath() As String
  Let ExtensionPath = mstrExtensionPath
End Property

'''''''''''''''''''
'Extension Name
Public Property Get ExtensionName() As String
  Let ExtensionName = mstrExtensionName
End Property

'''''''''''''''''''
'Working Directory
Public Property Get WorkingDir() As String
  Let WorkingDir = mstrMPMWorkingDir
End Property

'''''''''''''''''''
'Template Directory
Public Property Get TemplateDir() As String
  Let TemplateDir = mstrMPMTemplateDir
End Property

'''''''''''''''''''
'PriceableItem
Public Property Get PriceableItem() As PriceableItem
  Set PriceableItem = mobjPriceableItem
End Property

Public Function AddPriceableItem()
  Set mobjPriceableItem = New PriceableItem
  
  Call mobjPriceableItem.Initialize(mstrExtensionPath)
End Function




