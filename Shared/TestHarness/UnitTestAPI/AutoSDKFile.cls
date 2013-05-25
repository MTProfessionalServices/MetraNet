VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "AutoSDKFile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit


Public FileName As String
Public Name     As String
Public Inputs   As New CVariables

Public Function Initialize(ByVal strFileName As String) As Boolean

'    Dim objXMLDOM       As New MTVBLib.XMLDomMgr
'    Dim objXMLSession   As IXMLDOMNode
'    Dim objXMLConfig    As IXMLDOMNode
'    Dim objXMLInputs    As IXMLDOMNode
'
'    Dim objXMLProperties As IXMLDOMNodes
'    Dim objXMLProperty As IXMLDOMNode
'
'
'    Debug.Assert 0
'    If (objXMLDOM.LoadFile(strFileName)) Then
'
'        FileName = strFileName
'
'        Set objXMLConfig = objXMLDOM.FindXMLNodesInChild(objXMLDOM.XMLDoc, "xmlconfig").Item(1)
'        Set objXMLSession = objXMLDOM.FindXMLNodesInChild(objXMLConfig, "session").Item(1)
'
'        Name = objXMLDOM.Property(objXMLSession, "ServiceName")
'
'        Set objXMLInputs = objXMLDOM.FindXMLNodesInChild(objXMLSession, "inputs").Item(1)
'        Set objXMLProperties = objXMLDOM.FindXMLNodesInChild(objXMLInputs, "")
'
'        For Each objXMLProperty In objXMLProperties
'            Inputs.Add objXMLProperty.baseName, objXMLProperty.Text
'        Next
'        Initialize = True
'    End If
    
End Function

