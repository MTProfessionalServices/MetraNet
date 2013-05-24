VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Stage"
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

'---------------------------------------------------------------------------'
' Contains routines used for stagefile editing                              '
'---------------------------------------------------------------------------'
Option Explicit

'---------------------------------------------------------------------------'
' Global Variables                                                          '
'---------------------------------------------------------------------------'
Private mstrStageName As String         'the name of the stage
Private mbFirstStage As Boolean         'First stage flag
Private mbFinalStage As Boolean         'Final stage flag
Private mstrNextStage As String         'The next stage

Private mbRemoveable As Boolean         'If this stage is removeable

Private mcollDependencies As New Collection 'Plugin Collection

Dim mobjXML As New XMLHelper

'---------------------------------------------------------------------------'
' Function LoadFromFile(strXMLFile)                                         '
'                                                                           '
' Description: Load the stage file from the specified location.             '
'                                                                           '
' Inputs: strXMLFile -- the stage.xml file                                  '
'                                                                           '
' Outputs: None                                                             '
'---------------------------------------------------------------------------'
Public Function LoadFromFile(strXMLFile)
  Dim objXMLNodeList As IXMLDOMNodeList
  Dim objXMLDependsNodeList As IXMLDOMNodeList
  Dim objXMLNode As IXMLDOMNode
  Dim objXMLDependsNode As IXMLDOMNode
  Dim objXMLProcessorNode As IXMLDOMNode
  Dim objPlugin As StageDependency
  Dim bAdded As Boolean
  Dim strTemp
  Dim i, intDependCount
  
  Dim objFSO As New FileSystemObject
  
  
  'Check for file existence
  If Not objFSO.FileExists(strXMLFile) Then
    LoadFromFile = False
    Exit Function
  End If
  
  
  'Get the stage configuration
  'Stage name
  mstrStageName = mobjXML.GetSingleNodeText(strXMLFile, STAGE_NAME_QUERY)
    
  'First stage
  strTemp = mobjXML.GetSingleNodeText(strXMLFile, STAGE_START_QUERY)
  If UCase(strTemp) = "YES" Or UCase(strTemp) = "TRUE" Then
    mbFirstStage = True
  Else
    mbFirstStage = False
  End If
  
  'Final Stage
  strTemp = mobjXML.GetSingleNodeText(strXMLFile, STAGE_FINAL_QUERY)
  If UCase(strTemp) = "YES" Or UCase(strTemp) = "TRUE" Then
    mbFinalStage = True
  Else
    mbFinalStage = False
  End If
  
  'Next Stage
  mstrNextStage = mobjXML.GetSingleNodeText(strXMLFile, STAGE_NEXT_QUERY)
    
  'First, Clear the Plugin Collection
  intDependCount = mcollDependencies.Count
  
  For i = 1 To intDependCount
    Call mcollDependencies.Remove(1)
  Next
    
  'Get the plugins that don't have dependencies
  Set objXMLNodeList = mobjXML.GetMultipleNodes(strXMLFile, STAGE_DEPENDLESS_PLUGIN_QUERY)
  
  For Each objXMLNode In objXMLNodeList
    Set objPlugin = New StageDependency
    objPlugin.Name = objXMLNode.Text
    Call mcollDependencies.Add(objPlugin)
  Next
  
  'Now get the plugins that have dependencies
  Set objXMLNodeList = mobjXML.GetMultipleNodes(strXMLFile, STAGE_DEPEND_PLUGIN_QUERY)
  
  For Each objXMLNode In objXMLNodeList
    
    'Get the plugin name
    Set objXMLProcessorNode = objXMLNode.selectSingleNode("processor")
    
    'Determine if the node is already in the dependencies
    bAdded = False
    
    For Each objPlugin In mcollDependencies
      If objPlugin.Name = objXMLProcessorNode.Text Then
        bAdded = True
        'Get it's dependencies
        Set objXMLDependsNodeList = objXMLNode.selectNodes("dependson")
    
        For Each objXMLDependsNode In objXMLDependsNodeList
          Call objPlugin.AddDependency(objXMLDependsNode.Text)
        Next
        
        Exit For
        
      End If
    Next
    
    If Not bAdded Then
      Set objPlugin = New StageDependency
    
      objPlugin.Name = objXMLProcessorNode.Text
    
      'Get it's dependencies
      Set objXMLDependsNodeList = objXMLNode.selectNodes("dependson")
    
      For Each objXMLDependsNode In objXMLDependsNodeList
        Call objPlugin.AddDependency(objXMLDependsNode.Text)
      Next
       
      'Add the plugin to our collection
      Call mcollDependencies.Add(objPlugin)
    End If
  Next
  
  LoadFromFile = True

End Function
'---------------------------------------------------------------------------'
' Function SaveToFile(strXMLFile)                                           '
'                                                                           '
' Description: Save the stage file to the specified location.               '
'                                                                           '
' Inputs: strXMLFile -- the stage.xml file                                  '
'                                                                           '
' Outputs: None                                                             '
'---------------------------------------------------------------------------'
Public Function SaveToFile(strXMLFile)
  Dim objXMLNode As IXMLDOMNode
  Dim objXMLNodeList As IXMLDOMNodeList
  Dim objPlugin As StageDependency
  Dim arrNames()
  Dim arrValues()
  Dim intCount
  Dim i
  
  
  'First set the stage configuration properties
  Call mobjXML.SetSingleNodeText(STAGE_NAME_QUERY, mstrStageName, strXMLFile)
  
  If mbFirstStage Then
    Call mobjXML.SetSingleNodeText(STAGE_START_QUERY, "Yes", strXMLFile)
  Else
    Call mobjXML.SetSingleNodeText(STAGE_START_QUERY, "No", strXMLFile)
  End If
  
  If mbFinalStage Then
    Call mobjXML.SetSingleNodeText(STAGE_FINAL_QUERY, "Yes", strXMLFile)
  Else
    Call mobjXML.SetSingleNodeText(STAGE_FINAL_QUERY, "No", strXMLFile)
  End If

  Call mobjXML.SetSingleNodeText(STAGE_NEXT_QUERY, mstrNextStage, strXMLFile)
  
  
  'Since all dependencies are being rewritten, remove the existing ones
  Call mobjXML.RemoveMultipleNodes(strXMLFile, STAGE_DEPENDLESS_PLUGIN_QUERY)
  Call mobjXML.RemoveMultipleNodes(strXMLFile, STAGE_DEPEND_PLUGIN_QUERY)
  
    
  
  'Now save the plugins without dependencies
  intCount = 0
  ReDim arrNames(0)
  ReDim arrValues(0)
    
    
  'Loop through the collection of dependencies
  For Each objPlugin In mcollDependencies
    ReDim Preserve arrNames(intCount)
    ReDim Preserve arrValues(intCount)
      
    arrNames(intCount) = "dependson"
    arrValues(intCount) = objPlugin.Name
      
    intCount = intCount + 1
  Next
  
  'Write the dependency-less plugins to a file
  Call mobjXML.AddGroupOfNodes(strXMLFile, _
                               STAGE_DEPENDS_QUERY, _
                               arrNames, _
                               arrValues)
                               
  'Now write the plugins with dependencies
  'loop through the collection
  For Each objPlugin In mcollDependencies
    If objPlugin.DependencyCount > 0 Then
      intCount = objPlugin.DependencyCount
      
      'Set the processor
      ReDim arrNames(0)
      ReDim arrValues(0)
      
      arrNames(0) = "processor"
      arrValues(0) = objPlugin.Name
      
      'Set the dependson
      For i = 1 To intCount
        ReDim Preserve arrNames(i)
        ReDim Preserve arrValues(i)
        
        arrNames(i) = "dependson"
        arrValues(i) = objPlugin.DependencyItem(i)
      Next
        
      'Now add the dependency set
      Call mobjXML.AddSet(strXMLFile, _
                          STAGE_DEPENDS_QUERY, _
                          "dependency", _
                          arrNames, _
                          arrValues)
    End If
  Next
  
  
  'Finished
  
End Function
'---------------------------------------------------------------------------'
' Function    : CopyPlugins()                                               '
' Description : Copy plugins for the stage to the working directory.        '
' Inputs      : strExtension -- Path to the extension for the stage.        '
'             :
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function CopyPlugins(ByRef strStagePath As String, _
                            ByRef strWorkingDir As String)
  
  Dim objFSO As New FileSystemObject        'Filesystem object
  Dim varDependency As Variant              'Plug-ins to copy
  Dim varSubDependency As Variant           'Plug-ins to copy
  Dim i As Integer                          'counter
  Dim j As Integer                          'counter
  
  For i = 1 To mcollDependencies.Count
    varDependency = mcollDependencies(i).Name
    
    'Copy the file
    If objFSO.FileExists(strStagePath & "/" & varDependency & ".xml") Then
      Call objFSO.CopyFile(strStagePath & "/" & varDependency & ".xml", _
                           strWorkingDir & "/plugins/" & mstrStageName & "__" & varDependency & ".xml", _
                           True)
                           
    End If
    
    'Copy the sub-dependencies
    For j = 1 To mcollDependencies(i).DependencyCount
      varSubDependency = mcollDependencies(i).DependencyItem(j)
      
      If objFSO.FileExists(strStagePath & "/" & varSubDependency & ".xml") Then
        Call objFSO.CopyFile(strStagePath & "/" & varSubDependency & ".xml", _
                             strWorkingDir & "/plugins/" & mstrStageName & "__" & varSubDependency & ".xml", _
                             True)
                           
      End If
    Next
  Next
End Function
'''''''''''''''
'StageName
Public Property Get StageName() As String
  Let StageName = mstrStageName
End Property

Public Property Let StageName(ByVal Val As String)
  Let mstrStageName = Val
End Property

'''''''''''''''
'First Stage
Public Property Get FirstStage() As Boolean
  Let FirstStage = mbFirstStage
End Property

Public Property Let FirstStage(ByVal Val As Boolean)
  Let mbFirstStage = Val
End Property

'''''''''''''''
'Final Stage
Public Property Get FinalStage() As Boolean
  Let FinalStage = mbFinalStage
End Property

Public Property Let FinalStage(ByVal Val As Boolean)
  Let mbFinalStage = Val
End Property

'''''''''''''''
'Next Stage
Public Property Get NextStage() As String
  Let NextStage = mstrNextStage
End Property

Public Property Let NextStage(ByVal Val As String)
  Let mstrNextStage = Val
End Property

'''''''''''''''
'Dependencies
Public Property Get Dependencies() As Collection
  Set Dependencies = mcollDependencies
End Property

Public Function AddDependency(ByVal strName As String) As Collection
  Dim objDependency As New StageDependency
  
  Call RemoveDependency(strName)
  
  objDependency.Name = strName
  
  Call mcollDependencies.Add(objDependency)
  
End Function

Public Function RemoveDependency(ByVal strName As String)
  Dim i As Integer
  
  For i = 1 To mcollDependencies.Count
    If mcollDependencies(i).Name = strName Then
      Call mcollDependencies.Remove(i)
      Exit Function
    End If
  Next
End Function

Public Function GetDependency(ByVal strName As String) As StageDependency
  Dim objDependency As StageDependency
  
  For Each objDependency In mcollDependencies
    If objDependency.Name = strName Then
      Set GetDependency = objDependency
      Exit Function
    End If
  Next

End Function
'''''''''''''''
' RemoveAllDependencies
Public Function RemoveAllDependencies()
  Dim i As Integer
  
  For i = 1 To mcollDependencies.Count
    Call mcollDependencies.Remove(1)
  Next
  
End Function

Private Sub Class_Initialize()
  mobjXML.PrettyPrint = True
  mbFirstStage = True
  mbFinalStage = False
  mbRemoveable = True
End Sub

Public Property Get Removeable() As Boolean
  Let Removeable = mbRemoveable
End Property

Public Property Let Removeable(ByVal bRemoveable As Boolean)
  Let mbRemoveable = bRemoveable
End Property
