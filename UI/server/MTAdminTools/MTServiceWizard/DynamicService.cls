VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "DynamicService"
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
' $Workfile: DynamicService.cls$
' $Date: 01/18/2002 6:41:39 PM$
' $Author: Noah Cushing$
' $Revision: 27$
'
'
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
' This class is used by the service wizard ASP pages to faciliate creating
' a service through modifying the proper files and putting them in the
' correct location.  Specific methods for creating Dynamic Services are
' included.
'----------------------------------------------------------------------------
Option Explicit


Private mobjSW As New ServiceWizard           'service wizard helper object
Private mobjFSO As New FileSystemObject       'file system object

'Following properties are used for basic services setup
'These are used to map session properties to tax values
Private mstrPayer As String
Private mstrNamespace As String
Private mstrAmount As String
Private mstrFederaltax As String
Private mstrStateTax As String
Private mstrCountyTax As String
Private mstrLocalTax As String
Private mstrOtherTax As String
  

'-----------------------------------------------------------------------------'
' Function Init()                                                             '
'                                                                             '
' Description: Initialize the Service object and set up properties used by    '
'              the dynamic service object.                                    '
'                                                                             '
' Inputs: None                                                                '
'                                                                             '
' Outputs: None                                                               '
'-----------------------------------------------------------------------------'
Public Function Init(ByVal strExtensionName As String, _
                     ByVal strWorkingDir As String, _
                     ByVal strTemplateDir As String)
  
  'Init the Service Wizard object
  If Not mobjSW Is Nothing Then
    Call mobjSW.Init(strExtensionName, strWorkingDir, strTemplateDir)
  Else
    Err.Raise -1
  End If
  
  If mobjFSO Is Nothing Then
    Err.Raise -1
  End If
  
  'Replace strings with blanks
  mstrPayer = ""
  mstrNamespace = ""
  mstrAmount = ""
  mstrFederaltax = ""
  mstrStateTax = ""
  mstrCountyTax = ""
  mstrLocalTax = ""
  mstrOtherTax = ""
  
End Function
'-----------------------------------------------------------------------------'
' Function InitWorkingDirectory()                                             '
'                                                                             '
' Description: Clear the files in the MPM working directory and copy the      '
'              template files.                                                '
'                                                                             '
' Inputs: None                                                                '
'                                                                             '
' Outputs: None                                                               '
'-----------------------------------------------------------------------------'
Public Function InitWorkingDirectory()
  Call mobjSW.InitWorkingDirectory
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
  GetServiceDefinitionProperties = mobjSW.GetServiceDefinitionProperties()
End Function
'---------------------------------------------------------------------'
' Function CopyWorkingServiceToProduct()                              '
'                                                                     '
' Description: Copy the service def to the product view in the        '
'              MPM working area.                                      '
'                                                                     '
' Inputs: None:                                                       '
'                                                                     '
' Outputs: None                                                       '
'---------------------------------------------------------------------'

Public Function CopyWorkingServiceToProduct()
  Call mobjSW.CopyWorkingServiceToProduct
End Function
'---------------------------------------------------------------------'
' Function CopyServiceDefinitionTemplateToWorkingArea()               '
'                                                                     '
' Description: Get the service definition and product view files to   '
'              be used as templates and copy them to the working dir. '
'                                                                     '
' Inputs: None:                                                       '
'                                                                     '
' Outputs: None                                                       '
'---------------------------------------------------------------------'
Public Function CopyServiceDefinitionTemplateToWorkingArea()
  Dim strFilename
      
  If Not IsNumeric(mobjSW.ServiceTemplate) Then
    Err.Raise -1
  End If
    
  strFilename = mobjSW.ServiceDefinitions(CLng(ServiceTemplate) - 1)
  
  If Len(strFilename) > 0 Then
    Call mobjFSO.CopyFile(strFilename, mobjSW.WorkingDir & "/" & BLANK_SERVICE_MSIXDEF, True)
  End If
  
  
End Function
'---------------------------------------------------------------------'
' Function CopyProductViewTemplateToWorkingArea()                     '
'                                                                     '
' Description: Get the service definition and product view files to   '
'              be used as templates and copy them to the working dir. '
'                                                                     '
' Inputs: None:                                                       '
'                                                                     '
' Outputs: None                                                       '
'---------------------------------------------------------------------'
Public Function CopyProductViewTemplateToWorkingArea()
  Dim strFilename
      
  If Not IsNumeric(mobjSW.ProductViewTemplate) Then
    Err.Raise -1
  End If
    
  strFilename = mobjSW.GetProductViewPaths(CLng(ProductViewTemplate) - 1)
  
  If Len(strFilename) > 0 Then
    Call mobjFSO.CopyFile(strFilename, mobjSW.WorkingDir & "/" & BLANK_PV_MSIXDEF, True)
  End If
  
  
End Function
'-----------------------------------------------------------------------------'
' Function CopyWorkingFilesToExtension()                                      '
'                                                                             '
' Description: Create any directories necessary in the platform extension's   '
'              directory and copy the service files from the Platform Manager '
'              working area to the platform extension.                        '
'                                                                             '
' Inputs: None                                                                '
'                                                                             '
' Outputs: None                                                               '
'-----------------------------------------------------------------------------'
Public Function CopyWorkingFilesToExtension(ByVal bOverwriteService As Boolean, _
                                            ByVal bOverwriteProduct As Boolean, _
                                            ByVal bOverwriteStage As Boolean, _
                                            ByVal bOverwriteAutoSDK As Boolean, _
                                            Optional ByVal bOverwriteParamTables As Boolean = False, _
                                            Optional ByVal bOverwritePriceableItems As Boolean = False) As String
                                            
  Dim objRCD As New MTRcd
  Dim objFolder As Object         'Folder object for the working directory
  Dim objFiles As Files           'Files list object
  Dim objFile As File             'File object
  
  Dim objXMLHelper As New XMLHelper
  
  Dim strConfigPath As String     'Path of the extensions config directory
  Dim strTempPath As String       'used to store path names
  Dim strStageTempPath As String  'Used when copying stages
  Dim strSrcPath As String        'path of the src file when copying files
  Dim objStage As Stage           'Stage object
  Dim varName As Variant          'Used to loop
  Dim strExtension As String      'extension to put PTs in
  Dim strReturn As String         'Report Success/Failure of operations
  
  'Used for copying parameter tables
  Dim objParameterTableData As ParameterTableData   'Parameter table
  Dim strDomain As String         'Domain name
  Dim strDomainPath As String     'Domain Path
  Dim strName As String           'Name of the parameter table
  
  Dim bAggregate As Boolean       'Indicates an aggregate rated pi
  
  Dim arrNames
  Dim i As Integer
  Dim j As Integer
  
  On Error Resume Next
  
  'Set the config path
  strConfigPath = mobjSW.ExtensionPath & "\config"
  
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  'Create any needed directories
  'The "extension_name\config\service" directory must exist
  strReturn = strReturn & "<br>Copying service definition..."
  
  Set objFolder = mobjFSO.GetFolder(strConfigPath & "\service")
  
  If Not objFolder Is Nothing Then
    'create the domainname folder, fails if it exists, but that's okay
    strReturn = strReturn & "<br>   Creating Folder:" & strConfigPath & "\service\" & mobjSW.ServiceName
    
    strTempPath = strConfigPath & "\service"
    
    If InStr(mobjSW.ServiceName, "/") Then
      arrNames = Split(mobjSW.ServiceName, "/")
      
      For i = 0 To UBound(arrNames) - 1
        strTempPath = strTempPath & "\" & arrNames(i)
        
        Call mobjFSO.CreateFolder(strTempPath)
      Next
    End If
    strReturn = strReturn & " -- SUCCESS"
  Else
    strReturn = strReturn & " -- FAILED"
  End If
    
  'Check to see if the directory exists
  Set objFolder = mobjFSO.GetFolder(strTempPath)
  
  If objFolder Is Nothing Then
    strReturn = strReturn & " -- ERROR: Folder not created. Unable to proceed."
    Exit Function
  End If
    
  ''''''''''''''''''''''
  'Copy the service definition
  strTempPath = strConfigPath & "\service"
  strSrcPath = mobjSW.WorkingDir & "\" & BLANK_SERVICE_MSIXDEF
  Call mobjFSO.CopyFile(strSrcPath, _
                        strTempPath & "\" & mobjSW.ServiceName & ".msixdef", _
                        bOverwriteService)
  
  strReturn = strReturn & "<br>  Service copied to: " & strTempPath & "\" & mobjSW.ServiceName & ".msixdef"
  '''''''''''''''''''''''
    
  strReturn = strReturn & "<br>Copying product view..."
  
  'Create the product view directory
  Set objFolder = mobjFSO.GetFolder(strConfigPath & "\productview")
  
  If Not objFolder Is Nothing Then
    'create the domainname folder, fails if it exists, but that's okay
    strTempPath = strConfigPath & "\productview"
    
    If InStr(mobjSW.ServiceName, "/") Then
      arrNames = Split(mobjSW.PVName, "/")
      
      For i = 0 To UBound(arrNames) - 1
        strTempPath = strTempPath & "\" & arrNames(i)
        
        Call mobjFSO.CreateFolder(strTempPath)
      Next
    End If
  Else
    Err.Raise -1
  End If
    
  'Check to see if the directory exists
  Set objFolder = mobjFSO.GetFolder(strTempPath)
  
  If objFolder Is Nothing Then
    Err.Raise -1
  End If
  
  ''''''''''''''''''''''
  'Copy the productview definition
  strTempPath = strConfigPath & "\productview"
  strSrcPath = mobjSW.WorkingDir & "\" & BLANK_PV_MSIXDEF
  Call mobjFSO.CopyFile(strSrcPath, _
                        strTempPath & "\" & mobjSW.PVName & ".msixdef", _
                        bOverwriteProduct)
  '''''''''''''''''''''''
  'Create the stage directories
  For Each objStage In mobjSW.Stages
    
    strStageTempPath = mobjSW.FindStage(objStage.StageName)
    
    'If the stage exists in another extension, copy there, else create it
    If Len(strStageTempPath) = 0 Then
      strStageTempPath = strConfigPath & "\pipeline\" & objStage.StageName
    Else
      strStageTempPath = Mid(strStageTempPath, 1, InStrRev(strStageTempPath, "/") - 1)
    End If
    
    'Create the stage folder
    strReturn = strReturn & "<br>Creating stage directory: " & strStageTempPath
    Call mobjFSO.CreateFolder(strStageTempPath)
    
    'Check to see if the directory exists
    Set objFolder = mobjFSO.GetFolder(strStageTempPath)
    
    If objFolder Is Nothing Then
      Err.Raise -1
    End If
  
    strReturn = strReturn & "<br>Copying plug-ins for stage: " & objStage.StageName
    ''''''''''''''''''''''
    'Copy the plugins for the stages
    Set objFolder = mobjFSO.GetFolder(mobjSW.WorkingDir & "/Plugins")
    
    For i = 1 To objStage.Dependencies.Count
      If mobjFSO.FileExists(objFolder.Path & "/" & objStage.StageName & "__" & objStage.Dependencies(i).Name & ".xml") Then
        Call mobjFSO.CopyFile(objFolder.Path & "/" & objStage.StageName & "__" & objStage.Dependencies(i).Name & ".xml", _
                              strStageTempPath & "/" & objStage.Dependencies(i).Name & ".xml", _
                              bOverwriteStage)
      End If
      
      For j = 1 To objStage.Dependencies(i).DependencyCount
        varName = objStage.Dependencies(i).DependencyItem(j).Name
        If mobjFSO.FileExists(objFolder.Path & "/" & objStage.StageName & "__" & varName & ".xml") Then
          Call mobjFSO.CopyFile(objFolder.Path & "/" & objStage.StageName & "__" & varName & ".xml", _
                                strStageTempPath & "/" & varName & ".xml", _
                                bOverwriteStage)
        End If
      Next
    Next
    '''''''''''''''''''''''
    ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    'We're done creating directories, now copy the account resolution
    'plugins, etc. if they exist.  For the first stage
    'namespace
    If objStage.FirstStage Then
    
      'For aggregate rated priceable items, the first second pass stage resolves the
      'account from the ID, so use that plug-in, with no namespace
      '
      If Not mobjSW.PriceableItem Is Nothing Then
        If UCase(mobjSW.PriceableItem.ItemType) = "AGGREGATE" Then
          bAggregate = True
        Else
          bAggregate = False
        End If
      Else
        bAggregate = False
      End If
      
     'Handle services and product views with different names
     'Add the dependency to the stage
     'This is also necessary for the aggregate stage, which is metered as Service_temp, but goes
     'to PVname (no temp)
     'to stage_temp
      If UCase(mobjSW.ServiceName) <> UCase(mobjSW.PVName) Or bAggregate Then
        strReturn = strReturn & "<br>Copying set_pv_name plug-in."
      
        Call objStage.AddDependency("set_pv_name")
        
        strSrcPath = mobjSW.WorkingDir & "\" & BLANK_SET_PV_NAME_XML
        If mobjFSO.FileExists(strSrcPath) Then
          Call mobjFSO.CopyFile(strSrcPath, strStageTempPath & "\set_pv_name.xml", bOverwriteStage)
        End If
      End If
      
      'pcratelookup
      strSrcPath = mobjSW.WorkingDir & "\" & BLANK_PCRATELOOKUP_XML
      If mobjFSO.FileExists(strSrcPath) Then
        Call mobjFSO.CopyFile(strSrcPath, strStageTempPath & "\pcratelookup.xml", bOverwriteStage)
      End If
      
      'Copy namespace and normal account resolution if not aggregate
      If Not bAggregate Then
        
        'namespace
        strSrcPath = mobjSW.WorkingDir & "\" & BLANK_NAMESPACE_XML
        If mobjFSO.FileExists(strSrcPath) Then
          Call mobjFSO.CopyFile(strSrcPath, strStageTempPath & "\namespace.xml", bOverwriteStage)
        End If
      
        'accountresolution
        strSrcPath = mobjSW.WorkingDir & "\" & BLANK_ACCOUNT_RESOLUTION_XML
        If mobjFSO.FileExists(strSrcPath) Then
          Call mobjFSO.CopyFile(strSrcPath, strStageTempPath & "\accountresolution.xml", bOverwriteStage)
        End If
        
      
      'Else, use the alternate account resolution plugin (resolve by id)
      Else
        'accountresolution
        strSrcPath = mobjSW.WorkingDir & "\" & BLANK_ACCOUNT_RESOLUTION_XML2
        If mobjFSO.FileExists(strSrcPath) Then
          Call mobjFSO.CopyFile(strSrcPath, strStageTempPath & "\accountresolution2.xml", bOverwriteStage)
        End If
        
        'Copy overridetimestamp plugin
        strSrcPath = mobjSW.WorkingDir & "\" & BLANK_OVERRIDETIMESTAMP_XML
        If mobjFSO.FileExists(strSrcPath) Then
          Call mobjFSO.CopyFile(strSrcPath, strStageTempPath & "\overridetimestamp.xml", bOverwriteStage)
        End If
      End If
        
      
      'Copy PI type name for all priceable items
      If Not mobjSW.PriceableItem Is Nothing Then
         
        strReturn = strReturn & "<br>Copying set_pi_type_name plug-in."
        'Copy Set PI Type Name
        strSrcPath = mobjSW.WorkingDir & "\" & BLANK_SET_PI_TYPE_NAME_XML
        If mobjFSO.FileExists(strSrcPath) Then
          Call mobjFSO.CopyFile(strSrcPath, strStageTempPath & "\set_pi_type_name.xml", bOverwriteStage)
        End If

        strReturn = strReturn & "<br>Copying pi_lookup plug-in."
        'Copy pi_lookup
        strSrcPath = mobjSW.WorkingDir & "\" & BLANK_PI_LOOKUP_XML
        If mobjFSO.FileExists(strSrcPath) Then
          Call mobjFSO.CopyFile(strSrcPath, strStageTempPath & "\pi_lookup.xml", bOverwriteStage)
        End If
      End If
    End If
  
'  assignvalues
'  strSrcPath = mobjSW.WorkingDir & "\" & BLANK_ASSIGN_VALUES_XML
'  If mobjFSO.FileExists(strSrcPath) Then
'    Call mobjFSO.CopyFile(strSrcPath, strTempPath & "\assignvalues.xml", bOverwriteStage)
'  End If
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  
  '''''''''''''''''''''''''''''''''''''''
  'Save the stage file
  Call objStage.SaveToFile(mobjSW.WorkingDir & "\" & BLANK_STAGE_XML)
    

  Call mobjFSO.CopyFile(mobjSW.WorkingDir & "\" & BLANK_STAGE_XML, _
                        strStageTempPath & "\" & "stage.xml", _
                        bOverwriteStage)
        
  
  Next
  
  
  
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  'Copy the parameter tables and priceable items if this is priceable item
  'based.
  If Not mobjSW.PriceableItem Is Nothing Then
    
    'Create the parameter tables directory if it does not exist
    '
    
    If Not mobjFSO.FolderExists(strTempPath) Then
      Call mobjFSO.CreateFolder(strTempPath)
    End If
    
    For Each objParameterTableData In mobjSW.PriceableItem.ParameterTables
      varName = objParameterTableData.Name
      
      strSrcPath = mobjSW.WorkingDir & "\ParameterTables"
      strSrcPath = strSrcPath & "\" & Replace(varName, "/", "_SLASH_") & ".msixdef"
      
      'strDomain is actually the domain in this case
      strDomain = Left(varName, InStr(varName, "/") - 1)
      strName = Right(varName, Len(varName) - InStr(varName, "/"))
      
      strTempPath = objRCD.ExtensionDir & "/" & objParameterTableData.Extension & PARAMETER_TABLE_DIR
      
      'Create the domain directory if necessary
      If InStr(varName, "/") > 0 Then
        strDomainPath = strTempPath & "/" & strDomain
        
        If Not mobjFSO.FolderExists(strDomainPath) Then
          strReturn = strReturn & "<br>Creating parameter table folder: " & strDomainPath
          Call mobjFSO.CreateFolder(strDomainPath)
        End If
        
        strTempPath = strDomainPath
      End If
      
      'Copy the file
      strTempPath = strTempPath & "/" & strName & ".msixdef"
      'strTempPath = objRCD.ExtensionDir & "/" & strExtension & PARAMETER_TABLE_DIR & "\" & varName & ".msixdef"
      
      strReturn = strReturn & "<br>Copying parameter table to: " & strTempPath
      
      Call mobjFSO.CopyFile(strSrcPath, strTempPath, bOverwriteParamTables)
      
      
    Next
    
    
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    'Priceable Item
    strSrcPath = mobjSW.WorkingDir & "\" & Replace(mobjSW.PriceableItem.Name, " ", "") & ".xml"
    
    'Create the priceable item directory if it does not exist
    strTempPath = mobjSW.ExtensionPath & PRICEABLE_ITEM_DIR
    
    If Not mobjFSO.FolderExists(strTempPath) Then
      Call mobjFSO.CreateFolder(strTempPath)
    End If
    
    strTempPath = mobjSW.ExtensionPath & PRICEABLE_ITEM_DIR & "\" & mobjSW.PriceableItem.Name & ".xml"
    strTempPath = Replace(strTempPath, " ", "")
    
    strReturn = strReturn & "<br>Copying priceable item XML to: " & strTempPath
    
    Call mobjFSO.CopyFile(strSrcPath, strTempPath, bOverwritePriceableItems)
  
  End If
  
  '''''''''''''''''''''''
  'AutoSDK File
  strTempPath = mobjSW.ExtensionPath & "\test\autoSDK"
  
  'Does the AutoSDK directory exist?  If not, there is a problem
  Set objFolder = mobjFSO.GetFolder(strTempPath)
  
  If Not objFolder Is Nothing Then
    'Create the directory for the domain
    
    If InStr(mobjSW.ServiceName, "/") Then
      arrNames = Split(mobjSW.ServiceName)
      
      For i = 0 To UBound(arrNames) - 1
        strTempPath = strTempPath & "\" & arrNames(i)
        strReturn = strReturn & "<br>Creating folder: " & strTempPath
        Call mobjFSO.CreateFolder(strTempPath)
      Next
    End If

    'Copy the file
    strSrcPath = mobjSW.WorkingDir & "\" & BLANK_AUTOSDK_XML
    strTempPath = mobjSW.ExtensionPath & "\test\autoSDK"
    
    strReturn = strReturn & "<br>Copying autoSDK to: " & strTempPath & "\" & mobjSW.ServiceName & ".xml"
    
    Call mobjFSO.CopyFile(strSrcPath, strTempPath & "\" & mobjSW.ServiceName & ".xml", bOverwriteAutoSDK)
  
  Else
    Err.Raise -1
  End If
   
  CopyWorkingFilesToExtension = strReturn
End Function
'---------------------------------------------------------------------'
' Function WriteDataToBasicProcessingFiles()                          '
'                                                                     '
' Description: Write data to the basic processing files.              '
'                                                                     '
' Inputs: None                                                        '
'                                                                     '
' Outputs: None                                                       '
'---------------------------------------------------------------------'
Public Function WriteDataToBasicProcessingFiles()

  'Account Resolution & PI information
  Call mobjSW.WriteNamespaceFile(mstrNamespace)
  Call mobjSW.WriteAccountResolutionFile(mstrPayer)
    
  Call mobjSW.WriteSetPINameFile
  Call mobjSW.WritePCRateLookupFiles
 
End Function
'---------------------------------------------------------------------'
' Function WriteDataToMSIXDEFFiles()                                  '
'                                                                     '
' Description: Take the information stored in the object and write    '
'              it to the files in the working directory.  Called when '
'              the wizards proceeds from step 1 to step 2.            '
'                                                                     '
' Inputs: None                                                        '
'                                                                     '
' Outputs: None                                                       '
'---------------------------------------------------------------------'
Public Function WriteDataToMSIXDEFFiles()
  
  'Service Name & Product View msix definition files
  Call mobjSW.WriteMSIXDEFFiles
  
End Function
'---------------------------------------------------------------------'
' Function WriteDataToExtensionFiles()                                '
'                                                                     '
' Description: Take the information stored in the object and write    '
'              it to the files in the extension directory. Called     '
'              when the wizard is completed.                          '
'                                                                     '
' Inputs: None                                                        '
'                                                                     '
' Outputs: None                                                       '
'---------------------------------------------------------------------'
Public Function WriteDataToExtensionFiles()
  
  'Modify the servicetostagemap.xml
  Call mobjSW.WriteServiceToStageMapFile
  
  'Modify the view_hierarchy.xml
  Call mobjSW.WriteViewHierarchyFile

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
  GetPVNames = mobjSW.GetPVNames()
End Function

Public Function GetProductViewPaths()
  GetProductViewPaths = mobjSW.GetProductViewPaths()
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
  GetServiceNames = mobjSW.GetServiceNames()
End Function

Public Function GetServicePaths()
  GetServicePaths = mobjSW.GetServicePaths()
End Function
'---------------------------------------------------------------------'
' Function CheckForDuplicateService()                                 '
'                                                                     '
' Description: Ensure that a service with the same name isn't in the  '
'              service to stage map.xml.                              '
'                                                                     '
' Inputs: None                                                        '
'                                                                     '
' Outputs: True if a duplicate found, otherwise false.                '
'---------------------------------------------------------------------'
Public Function CheckForDuplicateService(ByRef strStatus As Variant)
  CheckForDuplicateService = mobjSW.CheckForDuplicateService(strStatus)
End Function
'---------------------------------------------------------------------------'
' Function    : AddPriceableItem()                                          '
' Description : Create a priceable item.  For purposes of a dynamic service,'
'             : only one priceable item will be present per run through     '
'             : the priceable item wizard.                                  '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'---------------------------------------------------------------------------'
Public Function AddPriceableItem()
  Call mobjSW.AddPriceableItem
End Function
'---------------------------------------------------------------------------'
' Function    : CreateDerivedFiles()                                        '
' Description : Create the derived files necessary for aggregate rated      '
'             : priceable items.
'             : items.                                                      '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'---------------------------------------------------------------------------'
Public Function CreateDerivedFiles() As String
  Dim objXMLHelper As New XMLHelper       'XML helper object
  
  Dim objXMLDoc As New DOMDocument30      'XML DOM document
  Dim objNode As IXMLDOMNode              'XML dom node
  
  Dim objRCD As New MTRcd                 'RCD object
  
  Dim objCPDef As CPDef                   'Counter property definition
  
  Dim objStage As Stage
  
  Dim strName As String
  Dim strStage As String
  Dim strServiceName As String
  'Dim strPVName As String
  Dim strPath As String
  
  Dim strStatus As String                 'Status string to return
  
  'Init the XML object
  objXMLDoc.async = False
  objXMLDoc.validateOnParse = False
  objXMLDoc.resolveExternals = False
    
    
  strStatus = strStatus & "<br><br>Configuring aggregate temp service."
    
  'Copy the 1st pass service definition to the 1st pass product view.
  'Get the name of the first pass SD
  Call objXMLDoc.Load(mobjSW.WorkingDir & "/" & BLANK_SERVICE_MSIXDEF)
  
  Set objNode = objXMLDoc.selectSingleNode("/defineservice/name")
  
  strServiceName = objNode.Text & "_temp"
  
  'Set the name
  objNode.Text = strServiceName
  
  'Save the generated 1st pass product view
  strPath = mobjSW.ExtensionPath & "/config/service/" & strServiceName & ".msixdef"
  Call objXMLDoc.save(strPath)
  
  'Get the name of the product view
'  Call objXMLDoc.Load(mobjSW.WorkingDir & "/" & BLANK_PV_MSIXDEF)
  
  'Set objNode = objXMLDoc.selectSingleNode("/defineservice/name")
  
  'strPVName = objNode.Text
  
  '''
  strStatus = strStatus & "<br>Configuration second-pass service definition."
  'Add counter properties as decimals
  For Each objCPDef In mobjSW.PriceableItem.CPDefs
    Call objXMLHelper.AddSet(strPath, _
                             "/defineservice", _
                             "ptype", _
                             Array("dn", "type", "length", "required", "defaultvalue"), _
                             Array(objCPDef.ServiceProperty, "DECIMAL", "", "N", ""))
  Next
  
  'Add additional required data for the second pass SD
  'Account ID
  Call objXMLHelper.AddSet(strPath, _
                           "/defineservice", _
                           "ptype", _
                           Array("dn", "type", "length", "required", "defaultvalue"), _
                           Array("_AccountID", "INT32", "", "N", ""))
  'PriceableItem Instance ID
  Call objXMLHelper.AddSet(strPath, _
                           "/defineservice", _
                           "ptype", _
                           Array("dn", "type", "length", "required", "defaultvalue"), _
                           Array("_PriceableItemInstanceID", "INT32", "", "N", ""))
  
  'PriceableItem Template ID
  Call objXMLHelper.AddSet(strPath, _
                           "/defineservice", _
                           "ptype", _
                           Array("dn", "type", "length", "required", "defaultvalue"), _
                           Array("_PriceableItemTemplateID", "INT32", "", "N", ""))
    
  'Product Offering ID
  Call objXMLHelper.AddSet(strPath, _
                           "/defineservice", _
                           "ptype", _
                           Array("dn", "type", "length", "required", "defaultvalue"), _
                           Array("_ProductOfferingID", "INT32", "", "N", ""))
    
  'OriginalSessionTimeStamp
  Call objXMLHelper.AddSet(strPath, _
                           "/defineservice", _
                           "ptype", _
                           Array("dn", "type", "length", "required", "defaultvalue"), _
                           Array("OriginalSessionTimestamp", "timestamp", "", "Y", ""))
                           
  'First pass ID
  Call objXMLHelper.AddSet(strPath, _
                          "/defineservice", _
                          "ptype", _
                          Array("dn", "type", "length", "required", "defaultvalue"), _
                          Array("_FirstPassID", "int32", "", "Y", ""))
    
  'Save the generated 2nd pass service definition
  strPath = mobjSW.ExtensionPath & "/config/productview/" & strServiceName & ".msixdef"
  Call objXMLDoc.save(strPath)
  
  'The second-pass product view is generated by the user, so no need to copy it.
  
  'Now handle the derived stage
  
  'Create the stage if necessary
  'Get the name of the first stage, use that as the base
  For Each objStage In mobjSW.Stages
    If objStage.FirstStage Then
      strStage = objStage.StageName     'This is used to map in the servicetostagemap
    End If
  Next
  
  'Set the name of the stage
  strName = strStage & "_temp"
  
  strStatus = strStatus & "<br>Creating temp stage: " & strName
  
  'Check if the stage exists
  strPath = mobjSW.ExtensionPath & "/config/pipeline"
  
  'If the temp stage exists, write a warning
  If Not mobjFSO.FolderExists(strPath & "/" & strName) Then
    strPath = strPath & "/" & strName
    strStatus = strStatus & "<br>Creating first-pass stage..."
    
    Call mobjFSO.CreateFolder(strPath)
    
    'Create the stage and copy to the folder
    Set objStage = New Stage
    
    objStage.StageName = strName
    
    objStage.FirstStage = True
    objStage.FinalStage = False
    objStage.NextStage = "WriteProductView"
    
    Call objStage.AddDependency("accountresolution")
    Call objStage.GetDependency("accountresolution").AddDependency("namespace")
    
    Call objStage.AddDependency("pi_lookup")
    Call objStage.GetDependency("pi_lookup").AddDependency("set_pi_type_name")
    Call objStage.GetDependency("pi_lookup").AddDependency("accountresolution")
    
    Call objStage.AddDependency("set_pv_name")
    
    'Add a plugin to set the amount
    Call objStage.AddDependency("set_amount")
    
    'Copy the blank_stage
    Call mobjFSO.CopyFile(mobjSW.WorkingDir & "/" & BLANK_STAGE_XML, _
                          strPath & "/stage.xml", _
                          True)
                          
    Call objStage.SaveToFile(strPath & "/stage.xml")
    
    'Copy the necessary plug-ins
    'Account resolution
    Call mobjFSO.CopyFile(mobjSW.WorkingDir & "/" & BLANK_ACCOUNT_RESOLUTION_XML, _
                          strPath & "/accountresolution.xml", _
                          True)
    
    'Namespace
    Call mobjFSO.CopyFile(mobjSW.WorkingDir & "/" & BLANK_NAMESPACE_XML, _
                          strPath & "/namespace.xml", _
                          True)
                              
    'PILookup
    Call mobjFSO.CopyFile(mobjSW.WorkingDir & "/" & BLANK_PI_LOOKUP_XML, _
                          strPath & "/pi_lookup.xml", _
                          True)
                          
    'Set the product view name in the set_pv_name xml
    Call objXMLHelper.SetSingleNodeText("/xmlconfig/mtconfigdata/processor/configdata/default_actions/action[prop_name='_ProductViewID']/prop_value", _
                                        strServiceName, _
                                        mobjSW.WorkingDir & "/" & BLANK_SET_PV_NAME_XML)
                                    
    Call mobjFSO.CopyFile(mobjSW.WorkingDir & "/" & BLANK_SET_PV_NAME_XML, _
                          strPath & "/set_pv_name.xml", _
                          True)
                                        
                          
    'Set PI Type Name
    Call mobjFSO.CopyFile(mobjSW.WorkingDir & "/" & BLANK_SET_PI_TYPE_NAME_XML, _
                          strPath & "/set_pi_type_name.xml", _
                          True)
                              
    'Set amount
    Call mobjFSO.CopyFile(mobjSW.WorkingDir & "/" & BLANK_SET_AMOUNT_XML, _
                          strPath & "/set_amount.xml", _
                          True)
        
    'Add the entry for the new service and stage in the servicetostagemap
    Call objXMLHelper.AddSet(mobjSW.ExtensionPath & "/config/pipeline/servicetostagemap.xml", _
                             "/xmlconfig", _
                             "direction", _
                             Array("ServiceID", "stage"), _
                             Array(strServiceName, strStage), _
                             Array("ptype", ""), _
                             Array("ID", ""))
                             
    'Add an entry for the temp product view into the view_hierarchy XML
    'This is done by the ServiceWizard Object
   ' Call objXMLHelper.AddSet(mobjSW.ExtensionPath & VIEW_HIERARCHY_XML, _
   '                          VIEW_HIERARCHY_NODE_QUERY, _
   '                          "view", _
   '                          Array("id_view", "id_parent_view", "nm_view_type"), _
   '                          Array(strServiceName, "ProductOfferingParent", "Product"), _
   '                          Array("ptype", "ptype", ""), _
   '                          Array("ID", "ID", ""))
                             
    strStatus = strStatus & "<br>SUCCESS!"
  Else
    strStatus = strStatus & "<br>Unable to create first-pass stage:  The Stage <" & strName & "> already exists!"
  End If
  
  CreateDerivedFiles = strStatus
End Function


'----------------------------------------------------------------------------
' Lets & Gets
'----------------------------------------------------------------------------

'''''''''''''''''''
' Payer
Public Property Get Payer() As String
  Let Payer = mstrPayer
End Property

Public Property Let Payer(ByVal Val As String)
  Let mstrPayer = Val
End Property

''''''''''''''''''''
' Namespace
Public Property Get Namespace() As String
  Let Namespace = mstrNamespace
End Property

Public Property Let Namespace(ByVal Val As String)
  Let mstrNamespace = Val
End Property

''''''''''''''''''''
' Amount
Public Property Get Amount() As String
  Let Amount = mstrAmount
End Property

Public Property Let Amount(ByVal Val As String)
  Let mstrAmount = Val
End Property

'''''''''''''''''''''
' Federal Tax
Public Property Get FederalTax() As String
  Let FederalTax = mstrFederaltax
End Property

Public Property Let FederalTax(ByVal Val As String)
  Let mstrFederaltax = Val
End Property

'''''''''''''''''''''
' State Tax
Public Property Get StateTax() As String
  Let StateTax = mstrStateTax
End Property

Public Property Let StateTax(ByVal Val As String)
  Let mstrStateTax = Val
End Property

'''''''''''''''''''''
' County Tax
Public Property Get CountyTax() As String
  Let CountyTax = mstrCountyTax
End Property

Public Property Let CountyTax(ByVal Val As String)
  Let mstrCountyTax = Val
End Property

'''''''''''''''''''''
' Local Tax
Public Property Get LocalTax() As String
  Let LocalTax = mstrLocalTax
End Property

Public Property Let LocalTax(ByVal Val As String)
  Let mstrLocalTax = Val
End Property

'''''''''''''''''''''
' Other Tax
Public Property Get OtherTax() As String
  Let OtherTax = mstrOtherTax
End Property

Public Property Let OtherTax(ByVal Val As String)
  Let mstrOtherTax = Val
End Property


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Provide Pass-through methods to get/set properties of the service object
''''''''''''''''''
'PVDisplayName
Public Property Get PVDisplayName() As String
  Let PVDisplayName = mobjSW.PVDisplayName
End Property

Public Property Let PVDisplayName(ByVal Val As String)
  Let mobjSW.PVDisplayName = Val
End Property

'''''''''''''''''''
'PVName
Public Property Get PVName() As String
  Let PVName = mobjSW.PVName
End Property

Public Property Let PVName(ByVal Val As String)
  Let mobjSW.PVName = Val
End Property

'''''''''''''''''''
'PVParent
Public Property Get PVParent() As String
  Let PVParent = mobjSW.PVParent
End Property

Public Property Let PVParent(ByVal Val As String)
  Let mobjSW.PVParent = Val
End Property

'''''''''''''''''''
'Stages
Public Function Stages() As Collection
  Set Stages = mobjSW.Stages
End Function

Public Function AddStage(ByVal Val As String, _
                         Optional ByVal strXMLFile As String = "", _
                         Optional ByVal bRemoveable As Boolean = True)
  Call mobjSW.AddStage(Val, strXMLFile, bRemoveable)
End Function

Public Function RemoveStage(ByVal Val As String)
  Call mobjSW.RemoveStage(Val)
End Function

Public Function CopyPlugins(ByVal strStage As String)
  Dim objStage As Stage
  Dim strStagePath As String
  
  For Each objStage In mobjSW.Stages
    If objStage.StageName = strStage Then
      strStagePath = mobjSW.FindStage(strStage)
      
      If Len(strStagePath) > 0 Then
        strStagePath = Mid(strStagePath, 1, InStrRev(strStagePath, "/") - 1)
    
        Call objStage.CopyPlugins(strStagePath, mobjSW.WorkingDir)
        Exit For
      End If
    End If
  Next
  
End Function
'''''''''''''''''''
'ServiceTemplateFile
Public Property Get ServiceTemplate() As String
  Let ServiceTemplate = mobjSW.ServiceTemplate
End Property

Public Property Let ServiceTemplate(ByVal Val As String)
  Let mobjSW.ServiceTemplate = Val
End Property
'''''''''''''''''''
'Product View TEmplate
Public Property Get ProductViewTemplate() As String
  Let ProductViewTemplate = mobjSW.ProductViewTemplate
End Property

Public Property Let ProductViewTemplate(ByVal Val As String)
  Let mobjSW.ProductViewTemplate = Val
End Property

'''''''''''''''''''
'ServiceName
Public Property Get ServiceName() As String
  Let ServiceName = mobjSW.ServiceName
End Property

Public Property Let ServiceName(ByVal Val As String)
  Let mobjSW.ServiceName = Val
End Property

''''''''''''''''''''
' InstallDir -- get only
Public Property Get InstallDir() As String
  Let InstallDir = mobjSW.InstallDir
End Property

''''''''''''''''''''
'ExtensionPath -- get only
Public Property Get ExtensionPath() As String
  Let ExtensionPath = mobjSW.ExtensionPath
End Property
'''''''''''''''''''''
'Extension Name
Public Property Get ExtensionName() As String
  Let ExtensionName = mobjSW.ExtensionName
End Property

''''''''''''''''''''
'WorkingDir -- get only
Public Property Get WorkingDir() As String
  Let WorkingDir = mobjSW.WorkingDir
End Property
''''''''''''''''''''
'TemplateDir -- get only
Public Property Get TemplateDir() As String
  Let TemplateDir = mobjSW.TemplateDir
End Property


''''''''''''''''''''
'Stage -- get only
Public Function Stage(ByVal strName As String) As Stage
  Dim objStage As Stage
  
  For Each objStage In mobjSW.Stages
    If UCase(objStage.StageName) = UCase(strName) Then
      Set Stage = objStage
      Exit Function
    End If
  Next
  
  Set Stage = Nothing
  
End Function
'''''''''''''''''''''''
' PriceableItem -- get only
Public Property Get PriceableItem() As PriceableItem
  Set PriceableItem = mobjSW.PriceableItem
End Property
