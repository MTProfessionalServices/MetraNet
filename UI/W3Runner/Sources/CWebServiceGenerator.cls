VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CWebServiceGenerator"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Name As String

Public XMLFileName  As String
Private m_objXMLDOM As XMLDomMgr



Public Function Initialize(strWSDLFileName As String) As Boolean
    Dim objTextFile As New cTextFile
    
    If Not objTextFile.ExistFile(strWSDLFileName) Then Exit Function

    XMLFileName = strWSDLFileName

    Set m_objXMLDOM = New XMLDomMgr
    
    ' Init generated text
    Generated "", True
    Generated PreProcess(Template("StandardTest.Comment"), "WSDL_FILE", strWSDLFileName)
    
    If m_objXMLDOM.LoadFile(XMLFileName) Then
    
        
        Initialize = AnalyseWSDL()
    End If
    
End Function

Public Function AnalyseWSDL() As Boolean

    Dim objDefinitions  As IXMLDOMNodes
    Dim objDefinition   As IXMLDOMNode
    Dim objParameters   As IXMLDOMNodes
    Dim objParameter    As IXMLDOMNode
    Dim objPortType     As IXMLDOMNode
    Dim objMessage      As IXMLDOMNode
    Dim objOperations   As IXMLDOMNodes
    Dim objOperation    As IXMLDOMNode
    Dim objOperationInputMessage    As IXMLDOMNodes
    Dim strMessageName              As String
    Dim strParameterType            As String
    Dim strOperation                As String
    Dim strParameterName            As String
    Dim objTextFile         As New cTextFile
    
'    Debug.Assert 0
    Set objDefinitions = m_objXMLDOM.FindXMLNodesInChild(m_objXMLDOM.XMLDoc, "definitions")
    
    If objDefinitions.Count > 0 Then
    
        Set objDefinition = objDefinitions(1)
        
        Name = m_objXMLDOM.AttributValue(objDefinition, "Name")
        Set objPortType = m_objXMLDOM.FindXMLNodesInChild(objDefinition, "porttype").Item(1)
        
        Generated PreProcess(Template("StandardTest.Init"), "WEB_SERVICE_NAME", Name, "WSDL_URL_SHORT", objTextFile.GetFileName(XMLFileName))
        
        Set objOperations = m_objXMLDOM.FindXMLNodesInChild(objPortType, "operation")
        For Each objOperation In objOperations
        
            strOperation = m_objXMLDOM.AttributValue(objOperation, "Name")
            
            Generated PreProcess(Template("StandardTest.Method"), "METHOD", strOperation)
             
            Set objOperationInputMessage = m_objXMLDOM.FindXMLNodesInChild(objOperation, "input")
            
            strMessageName = m_objXMLDOM.AttributValue(objOperationInputMessage(1), "Message")
            strMessageName = RemoveNameSpace(strMessageName)
            
            Set objMessage = GetMessage(objDefinition, strMessageName)
            
            Set objParameters = m_objXMLDOM.FindXMLNodesInChild(objMessage, "part")
            For Each objParameter In objParameters
            
                strParameterName = m_objXMLDOM.AttributValue(objParameter, "Name")
                strParameterType = UCase$(RemoveNameSpace(m_objXMLDOM.AttributValue(objParameter, "type")))
                Select Case strParameterType
                    Case "DOUBLE"
                    Case "FLOAT"
                    Case "DECIMAL"
                    Case "SHORT" ' int 16
                    Case "INT" ' int 32
                    Case "LONG" ' int 64
                    Case "STRING"
                    Case "BOOLEAN"
                    Case "DATETIME"
                    Case "BYTE"
                End Select
                
                Generated PreProcess(Template("StandardTest.Parameter"), "PARAMETER_NAME", strParameterName, "VALUE", "Empty")
            Next
            Generated PreProcess(Template("StandardTest.Execute"), "WEB_SERVICE_NAME", Name, "METHOD", strOperation)
        Next
        Generated PreProcess(Template("StandardTest.End"), "WEB_SERVICE_NAME", Name)
        AnalyseWSDL = True
    End If
End Function



Public Function GetMessage(objDefinition As IXMLDOMNode, ByVal strName As String) As IXMLDOMNode

    Dim objMessages     As IXMLDOMNodes
    Dim objMessage      As IXMLDOMNode
    
    strName = UCase$(strName)
    
    Set objMessages = m_objXMLDOM.FindXMLNodesInChild(objDefinition, "message")
    For Each objMessage In objMessages
    
        If UCase$(m_objXMLDOM.AttributValue(objMessage, "Name")) = strName Then
        
            Set GetMessage = objMessage
            Exit Function
        End If
    Next
End Function

Public Function RemoveNameSpace(strAttr As String) As String
    Dim lngPos As Long
    lngPos = InStr(strAttr, ":")
    If lngPos Then
        RemoveNameSpace = Mid(strAttr, lngPos + 1)
    Else
        RemoveNameSpace = strAttr
    End If
End Function

Private Function Generated(strText As String, Optional booClear As Boolean = False) As Boolean
    frmMain.Generated PreProcess(strText, "CRLF", vbNewLine, "TAB", vbTab), booClear
End Function


Public Property Get Template(strName As String) As String

    Dim s As String
    
    s = g_objIniFile.getVar("Generator", strName)
    Template = s
    
End Property
