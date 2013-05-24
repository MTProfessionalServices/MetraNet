VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "XMLDomMgr"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
'
'  Copyright 1998-2000 by MetraTech Corporation
'  All rights reserved.
'
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  CLASS        : XMLDomMgr
'  AUTHOR       : Frederic Torres
'  DATE         : 08/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit


Private m_XMLDoc            As DOMDocument
Private m_strFileName       As String

Public Property Get XMLDoc() As DOMDocument
    Set XMLDoc = m_XMLDoc
End Property

Public Function FindXMLAttributInNode(objXMLNode As IXMLDOMNode, strAttrName As String) As IXMLDOMNode

    Dim i As Long
    
    For i = 0 To objXMLNode.Attributes.Length - 1
    
        If (UCase(objXMLNode.Attributes(i).baseName) = UCase(strAttrName)) Then
            Set FindXMLAttributInNode = objXMLNode.Attributes(i)
            Exit Function
        End If
    Next
End Function

Public Function LoadFile(strFileName As String) As Boolean

    Dim f As New cTextFile
    
    m_strFileName = strFileName
    
    If (f.ExistFile(strFileName)) Then
    
        If (LoadXMLFile(strFileName)) Then
        
            LoadFile = True
        Else
            TRACE Replace(MTVBLIB_ERROR_03502, "[FILE]", strFileName), "XMLDomMgr.cls", "Parse", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
        End If
    Else
        TRACE Replace(MTVBLIB_ERROR_03503, "[FILE]", strFileName), "XMLDomMgr.cls", "Load", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
    End If
End Function

Public Function FindXMLNodesInChild(objXMLParentNode As IXMLDOMNode, Optional ByVal strBaseName As String) As IXMLDOMNodes

    Dim objXMLNodes As New IXMLDOMNodes
    Dim i           As Long
    
    strBaseName = UCase(strBaseName)
    
    For i = 0 To objXMLParentNode.childNodes.Length - 1
    
        If (Len(strBaseName) = 0) Then
        
            objXMLNodes.Add objXMLParentNode.childNodes(i)
        Else
            If (UCase(objXMLParentNode.childNodes(i).baseName) = strBaseName) Then
            
                objXMLNodes.Add objXMLParentNode.childNodes(i)
            End If
        End If
    Next
    Set FindXMLNodesInChild = objXMLNodes
End Function

Private Sub Class_Initialize()

    Set m_XMLDoc = New DOMDocument ' Alloc the ms xmldom
End Sub

Private Sub Class_Terminate()

    Set m_XMLDoc = Nothing
End Sub

Public Property Get Property(objXMLNode As IXMLDOMNode, ByVal strName As String) As Variant

    On Error GoTo ErrMgr
        
    Dim objProperty As IXMLDOMNodes
    
    Set objProperty = FindXMLNodesInChild(objXMLNode, strName)
    
    If (objProperty.Count = 1) Then
        Property = objProperty.Item(1).Text
    End If
    Exit Property
ErrMgr:
'  Debug.Assert 0
  Err.Raise Err.Number, Err.Source, Err.Description
End Property

Public Property Get XmlNode(objXMLNode As IXMLDOMNode, ByVal strName As String) As IXMLDOMNode

    On Error GoTo ErrMgr
        
    Dim objProperty As IXMLDOMNodes
    
    Set objProperty = FindXMLNodesInChild(objXMLNode, strName)
    
    If (objProperty.Count = 1) Then
        Set XmlNode = objProperty.Item(1)
    End If
    Exit Property
ErrMgr:
'  Debug.Assert 0
  Err.Raise Err.Number, Err.Source, Err.Description
End Property


Public Property Get AttributValue(objXMLNode As IXMLDOMNode, ByVal strName As String) As String

    On Error GoTo ErrMgr
    
    Dim i As Long
    
    If (objXMLNode.Attributes.Length) Then
    
        For i = 0 To objXMLNode.Attributes.Length - 1
        
            If (UCase(strName) = UCase(objXMLNode.Attributes.Item(i).baseName)) Then
            
                AttributValue = objXMLNode.Attributes.Item(i).Text
                Exit Property
            End If
        Next
    End If
    Exit Property
ErrMgr:
'  Debug.Assert 0
  Err.Raise Err.Number, Err.Source, Err.Description
End Property


Public Function Parse(strXML As String, Optional strFileName As String) As Boolean

        Dim strError As String
        Dim objPP    As New CPreProcessor
        
        m_XMLDoc.loadXML strXML
        If (m_XMLDoc.parseError) Then
            
            objPP.Add "FILENAME", strFileName
            objPP.Add "ERROR", m_XMLDoc.parseError.errorCode
            objPP.Add "FILEPOS", m_XMLDoc.parseError.filepos
            objPP.Add "LINE", m_XMLDoc.parseError.Line
            objPP.Add "LINEPOS", m_XMLDoc.parseError.linepos
            objPP.Add "REASON", m_XMLDoc.parseError.reason
            objPP.Add "TEXT", m_XMLDoc.parseError.srcText
            
            TRACE objPP.Process(MTVBLIB_ERROR_03504), "XMLDomMgr", "Parse", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
            
        Else
            Parse = True
        End If
End Function


Private Function LoadXMLFile(strFileName As String) As Boolean

    Dim strError As String
    Dim objPP    As New CPreProcessor

    If (m_XMLDoc.Load(strFileName)) Then
        LoadXMLFile = True
    Else
        objPP.Add "FILENAME", strFileName
        objPP.Add "ERROR", m_XMLDoc.parseError.errorCode
        objPP.Add "FILEPOS", m_XMLDoc.parseError.filepos
        objPP.Add "LINE", m_XMLDoc.parseError.Line
        objPP.Add "LINEPOS", m_XMLDoc.parseError.linepos
        objPP.Add "REASON", m_XMLDoc.parseError.reason
        objPP.Add "TEXT", m_XMLDoc.parseError.srcText

        TRACE objPP.Process(MTVBLIB_ERROR_03504), "XMLDomMgr", "Parse", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
    End If
End Function
