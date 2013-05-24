VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "StaticDataService"
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
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
'
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
' This class is used by the service wizard ASP pages to faciliate creating
' a service through modifying the proper files and putting them in the
' correct location.  Specific methods for creating services based on the
' Static Data stage are included.
'----------------------------------------------------------------------------
Option Explicit


Private mobjSW As New ServiceWizard           'service wizard helper object
Private mobjFSO As New FileSystemObject       'file system object

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
  
  'Set the values specific to StaticData services
  Call mobjSW.AddStage("StaticData", "", False)
  
  
  
  If mobjFSO Is Nothing Then
    Err.Raise -1
  End If
  
  
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
Public Function CopyWorkingFilesToExtension()
  Dim objFolder As Object         'Folder object for the working directory
  Dim objFiles As Files           'Files list object
  Dim objFile As File             'File object
  Dim strConfigPath As String     'Path of the extensions config directory
  Dim strTempPath As String       'used to store path names
  Dim strSrcPath As String        'path of the src file when copying files
  Dim arrNames
  
  Dim strSummary                  'Summary text to return
  
  Dim i As Integer
    
  On Error Resume Next
  
  'Set the config path
  strConfigPath = mobjSW.ExtensionPath & "\config"
  
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  'Create any needed directories
  'The "extension_name\config\service" directory must exist
  Set objFolder = mobjFSO.GetFolder(strConfigPath & "\service")
  
  If Not objFolder Is Nothing Then
    'create the domainname folder, fails if it exists, but that's okay
    strTempPath = strConfigPath & "\service"
    
    If InStr(mobjSW.ServiceName, "/") Then
      arrNames = Split(mobjSW.PVName, "/")
      
      For i = 0 To UBound(arrNames) - 1
        strTempPath = strTempPath & "\" & arrNames(i)
        strSummary = strSummary & "<br>Creating folder: " & strTempPath
        
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
  'Copy the service definition
  strSrcPath = mobjSW.WorkingDir & "\" & BLANK_SERVICE_MSIXDEF
  Call mobjFSO.CopyFile(strSrcPath, _
                        strConfigPath & "\service\" & mobjSW.ServiceName & ".msixdef", _
                        True)
  '''''''''''''''''''''''
  strSummary = strSummary & "<br>Copying service defintion to: " & strConfigPath & "\service\" & mobjSW.ServiceName & ".msixdef"
  
  'Create the product view directory
  Set objFolder = mobjFSO.GetFolder(strConfigPath & "\productview")
  
  If Not objFolder Is Nothing Then
    'create the domainname folder, fails if it exists, but that's okay
    strTempPath = strConfigPath & "\productview"
    
    If InStr(mobjSW.PVName, "/") Then
      arrNames = Split(mobjSW.PVName, "/")
      
      For i = 0 To UBound(arrNames) - 1
        strTempPath = strTempPath & "\" & arrNames(i)
        strSummary = strSummary & "<br>Creating folder: " & strTempPath
        
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
  strSrcPath = mobjSW.WorkingDir & "\" & BLANK_PV_MSIXDEF
  Call mobjFSO.CopyFile(strSrcPath, _
                        strConfigPath & "\productview\" & mobjSW.PVName & ".msixdef", _
                        True)
                        
  strSummary = strSummary & "<br>Copying product view to: " & strConfigPath & "\productview\" & mobjSW.PVName & ".msixdef"
  '''''''''''''''''''''''
  
  
  CopyWorkingFilesToExtension = strSummary
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
'----------------------------------------------------------------------------
' Lets & Gets
'----------------------------------------------------------------------------

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
'PVParent
Public Property Get PVParent() As String
  Let PVParent = mobjSW.PVParent
End Property

Public Property Let PVParent(ByVal Val As String)
  Let mobjSW.PVParent = Val
End Property

'''''''''''''''''''
'Get PVName
Public Property Get PVName() As String
  Let PVName = mobjSW.PVName
End Property

'''''''''''''''''''
'ServiceName
Public Property Get ServiceName() As String
  Let ServiceName = mobjSW.ServiceName
End Property

Public Property Let ServiceName(ByVal Val As String)
  'For a static data service, the product view name is
  'the same as the service name
  Let mobjSW.ServiceName = Val
  Let mobjSW.PVName = Val
End Property

''''''''''''''''''''
' StageName -- get only
Public Property Get StageName() As String
  'There should be one item in the collection
  Let StageName = mobjSW.Stages(1).StageName
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

