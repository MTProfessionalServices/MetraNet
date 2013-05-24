VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "AutoSDK"
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
' This module contains error codes used by the service wizard for setting up
' AutoSDK files
'----------------------------------------------------------------------------
Option Explicit
'---------------------------------------------------------------------------'
'Global Variables                                                           '
'---------------------------------------------------------------------------'
Dim mobjXML As New XMLHelper          'XML helper object

Dim mcollInputs As New Collection     'Collection of AutoSDK inputs
Dim mcollOutputs As New Collection    'Colleciton of AutoSDK outputs

Dim marrDefaultValues                 'Default values for ptypes
Dim marrPtypeStrings                  'String names for ptypes

'Ptypes
Const PTYPE_INTEGER = 2
Const PTYPE_DOUBLE = 3
Const PTYPE_STRING = 4
Const PTYPE_DATETIME = 5
Const PTYPE_TIME = 6
Const PTYPE_BOOLEAN = 7
Const PTYPE_ENUM = 10
Const PTYPE_DECIMAL = 11
'---------------------------------------------------------------------------'
' Sub PopulateOutputsFromMSIXDEF(strMPMWorkingDir)                          '
'                                                                           '
' Description: Populate the AutoSDK files from the service definition and   '
'              product view definition files.                               '
'                                                                           '
' Inputs: strMPMWorkingDir - The MPM working directory.                     '
'                                                                           '
' Outputs: None                                                             '
'---------------------------------------------------------------------------'
Sub PopulateOutputsFromMSIXDEF(strMPMWorkingDir)
Dim arrNames                        'array of property names
  Dim arrTypes                      'array of property types
  Dim arrDefaultValues              'array of property default values
  Dim strXMLFile As String          'filename of the msixdef file
  Dim objAutoSDKIO As autoSDKIO     'input/output property
  Dim i
  
  'Remove the existing outputs
  Call RemoveAll("outputs")
    
  'Get the outputs from the product view definition
  strXMLFile = strMPMWorkingDir & "/" & BLANK_PV_MSIXDEF
  
  arrNames = mobjXML.GetMultipleNodeText(strXMLFile, SERVICE_DN_NODE_QUERY)
  arrTypes = mobjXML.GetMultipleNodeText(strXMLFile, SERVICE_TYPE_NODE_QUERY)
  arrDefaultValues = mobjXML.GetMultipleNodeText(strXMLFile, SERVICE_DEFAULT_VALUE_NODE_QUERY)
  
  'Check for valid responses, we should have an equal ubound for each
  If UBound(arrNames) <> UBound(arrTypes) Or UBound(arrNames) <> UBound(arrDefaultValues) Then
    'Ubounds are different, can't tell correlation between the arrays
    Exit Sub
  End If
  
  'Now get all the properties
  For i = 0 To UBound(arrNames)
    If arrNames(i) <> "" Then        'don't populate with empty properties
      Set objAutoSDKIO = New autoSDKIO
      
      objAutoSDKIO.Name = arrNames(i)
      
      'Must translate from SD types to ptypes
      'Need to translate from MSIX types to ptypes
      ' Int32 --> Integer
      If UCase(arrTypes(i)) = "INT32" Then
        objAutoSDKIO.Ptype = PTYPE_INTEGER
      
      'Boolean --> bool
      ElseIf UCase(arrTypes(i)) = "BOOLEAN" Then
        objAutoSDKIO.Ptype = PTYPE_BOOLEAN
      
      'timestamp --> Datetime
      ElseIf UCase(arrTypes(i)) = "TIMESTAMP" Then
        objAutoSDKIO.Ptype = PTYPE_DATETIME
        
      'float --> double
      ElseIf UCase(arrTypes(i)) = "FLOAT" Then
        objAutoSDKIO.Ptype = PTYPE_DOUBLE
      
      'Unistring --> String
      ElseIf UCase(arrTypes(i)) = "UNISTRING" Then
        objAutoSDKIO.Ptype = PTYPE_STRING
        
      Else
        objAutoSDKIO.PtypeAsString = arrTypes(i)
      End If
      
      objAutoSDKIO.Value = arrDefaultValues(i)
      
      Call mcollOutputs.Add(objAutoSDKIO)
    End If
  Next
  
End Sub
'---------------------------------------------------------------------------'
' Sub PopulateInputsFromMSIXDEF(strMPMWorkingDir)                           '
'                                                                           '
' Description: Populate the AutoSDK files from the service definition and   '
'              product view definition files.                               '
'                                                                           '
' Inputs: strMPMWorkingDir - The MPM working directory.                     '
'                                                                           '
' Outputs: None                                                             '
'---------------------------------------------------------------------------'
Public Sub PopulateInputsFromMSIXDEF(strMPMWorkingDir)
  Dim arrNames                      'array of property names
  Dim arrTypes                      'array of property types
  Dim arrDefaultValues              'array of property default values
  Dim strXMLFile As String          'filename of the msixdef file
  Dim objAutoSDKIO As autoSDKIO     'input/output property
  Dim i
  
  'Remove the existing inputs first
  Call RemoveAll("inputs")
  
  'Load all properties from the MSIXDef
  strXMLFile = strMPMWorkingDir & "/" & BLANK_SERVICE_MSIXDEF
  arrNames = mobjXML.GetMultipleNodeText(strXMLFile, SERVICE_DN_NODE_QUERY)
  arrTypes = mobjXML.GetMultipleNodeText(strXMLFile, SERVICE_TYPE_NODE_QUERY)
  arrDefaultValues = mobjXML.GetMultipleNodeText(strXMLFile, SERVICE_DEFAULT_VALUE_NODE_QUERY)
  
  'Check for valid responses, we should have an equal ubound for each
  If UBound(arrNames) <> UBound(arrTypes) Or UBound(arrNames) <> UBound(arrDefaultValues) Then
    'Ubounds are different, can't tell correlation between the arrays
    Exit Sub
  End If
  
  'Now get all the properties
  For i = 0 To UBound(arrNames)
    If arrNames(i) <> "" Then        'don't populate with empty properties
      Set objAutoSDKIO = New autoSDKIO
      objAutoSDKIO.Name = arrNames(i)
      
      'Need to translate from MSIX types to ptypes
      ' Int32 --> Integer
      If UCase(arrTypes(i)) = "INT32" Then
        objAutoSDKIO.Ptype = PTYPE_INTEGER
      
      'Boolean --> bool
      ElseIf UCase(arrTypes(i)) = "BOOLEAN" Then
        objAutoSDKIO.Ptype = PTYPE_BOOLEAN
      
      'timestamp --> Datetime
      ElseIf UCase(arrTypes(i)) = "TIMESTAMP" Then
        objAutoSDKIO.Ptype = PTYPE_DATETIME
        
      'float --> double
      ElseIf UCase(arrTypes(i)) = "FLOAT" Then
        objAutoSDKIO.Ptype = PTYPE_DOUBLE
      
      'Unistring --> String
      ElseIf UCase(arrTypes(i)) = "UNISTRING" Then
        objAutoSDKIO.Ptype = PTYPE_STRING
        
      Else
        objAutoSDKIO.PtypeAsString = arrTypes(i)
      End If
        
      objAutoSDKIO.PtypeAsString = arrTypes(i)
      objAutoSDKIO.Value = arrDefaultValues(i)
      
      Call mcollInputs.Add(objAutoSDKIO)
    End If
  Next
  
 End Sub
'---------------------------------------------------------------------------'
' Sub         : SaveToFile(strFilename, strServiceName)                     '
' Description : Save the autoSDK data to the autoSDK file.                  '
' Inputs      : strFilename     - name of the autoSDK file                  '
'             : strServiceName  - name of the service                       '
' Outputs     : None                                                        '
'---------------------------------------------------------------------------'
Sub SaveToFile(ByVal strFilename As String, _
               ByVal strServiceName As String)
  Dim objAutoSDKIO As autoSDKIO
  
  mobjXML.PrettyPrint = True
  
  Call mobjXML.SetSingleNodeText("/xmlconfig/session/ServiceName", strServiceName, strFilename)
  
  For Each objAutoSDKIO In mcollInputs
    Call mobjXML.AddNode(strFilename, _
                         "/xmlconfig/session/inputs", _
                         objAutoSDKIO.Name, _
                         objAutoSDKIO.Value, _
                         Array("ptype"), _
                         Array(objAutoSDKIO.PtypeAsString))
  Next
  
  For Each objAutoSDKIO In mcollOutputs
    Call mobjXML.AddNode(strFilename, _
                         "/xmlconfig/session/outputs", _
                         objAutoSDKIO.Name, _
                         objAutoSDKIO.Value, _
                         Array("ptype"), _
                         Array(objAutoSDKIO.PtypeAsString))
  Next
  
End Sub
'---------------------------------------------------------------------------'
' Sub RemoveAll()                                                           '
'                                                                           '
' Description: Remove all inputs and outputs.                               '
'                                                                           '
' Inputs:                                                                   '
'                                                                           '
' Outputs:                                                                  '
'---------------------------------------------------------------------------'
Public Sub RemoveAll(Optional strType As String = "all")
  Dim intInputCount
  Dim intOutputCount
  Dim i
  
  If strType = "inputs" Or strType = "all" Then
    'Remove all the inputs
    intInputCount = mcollInputs.Count
  
    For i = 1 To intInputCount
      Call mcollInputs.Remove(1)
    Next
  End If
  
  If strType = "ouputs" Or strType = "all" Then
    'Remove all the outputs
    intOutputCount = mcollOutputs.Count
    
    For i = 1 To intOutputCount
      Call mcollOutputs.Remove(1)
    Next
  End If
  
End Sub
'---------------------------------------------------------------------------'
' Lets & Gets                                                               '
'---------------------------------------------------------------------------'
'Inputs
Public Property Get Inputs() As Collection
  Set Inputs = mcollInputs
End Property

'Outputs
Public Property Get Outputs() As Collection
  Set Outputs = mcollOutputs
End Property
'---------------------------------------------------------------------------'
'---------------------------------------------------------------------------'
'---------------------------------------------------------------------------'
Private Sub Class_Initialize()
  'Set the values for the default values, so they can be indexed
  ' by ptype number
  
  marrDefaultValues = Array("", _
                            "", _
                            "0", _
                            "0.0", _
                            "(blank)", _
                            "1998-01-01T00:00:00Z", _
                            "NO", _
                            "", _
                            "", _
                            "", _
                            "0.0")
  
  marrPtypeStrings = Array("undefined", _
                          "undefined", _
                          "int32", _
                          "double", _
                          "string", _
                          "datetime", _
                          "boolean", _
                          "undefined", _
                          "undefined", _
                          "enum", _
                          "decimal")

End Sub
