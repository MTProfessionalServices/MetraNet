VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CXMLCompare"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

' http://www.gotdotnet.com/team/xmltools/xmldiff/default.aspx


#Const DEBUG_MODE = True

Public StartPath As String

Public Enum CXMLCOMPARE_RESULT
    CXMLCOMPARE_TYPE_OK = 0
    CXMLCOMPARE_TYPE_ERROR_NOT_EQUAL = 1
    CXMLCOMPARE_TYPE_CAN_FIND_NODE = 2
    CXMLCOMPARE_TYPE_UNKNOWN = 3
End Enum

Public Errors As New Collection

Public IgnorePropertyNames As String

Private varCXMLCOMPARE_RESULT As Variant

Public Enum CXMLCOMPARE_TYPE
    CXMLCOMPARE_TYPE_TEXT = 1
End Enum

Private Const MTPCIMPORTEXPORT_ERROR_1000 = "Unexpected run time error "
Private Const CXMLCOMPARE_ERROR_1002 = "MTPCImportExport_ERROR_1002-XMLDOM Parsing filename=[FILENAME] error=[ERROR] filepos=[FILEPOS] line=[LINE] linepos=[LINEPOS] reason=[REASON] scrtext=[TEXT]"

Private m_XMLDom(1 To 2)    As DOMDocument40

Private Function LoadXML(strXMLFileName As String, XMLDom As DOMDocument40) As Boolean

    Dim objPP       As New CPreProcessor
    Dim objTextFile As New cTextFile
    
    On Error GoTo ErrMgr
   
    If Not objTextFile.ExistFile(strXMLFileName) Then Exit Function
    
    Set XMLDom = New DOMDocument40
    
    If XMLDom.Load(strXMLFileName) Then
    
        LoadXML = True
    Else
        objPP.Add "FILENAME", strXMLFileName
        objPP.Add "ERROR", XMLDom.parseError.errorCode
        objPP.Add "FILEPOS", XMLDom.parseError.filepos
        objPP.Add "LINE", XMLDom.parseError.Line
        objPP.Add "LINEPOS", XMLDom.parseError.linepos
        objPP.Add "REASON", XMLDom.parseError.reason
        objPP.Add "TEXT", XMLDom.parseError.srcText
        
        MTGlobal_VB_MSG.TRACE objPP.Process(CXMLCOMPARE_ERROR_1002), "MTPCImportExportModule", "ImportProductOffering", LOG_ERROR
    End If
Exit Function
ErrMgr:
    MTGlobal_VB_MSG.TRACE MTPCIMPORTEXPORT_ERROR_1000 & GetVBErrorString(), Me, LoadXML, LOG_ERROR
End Function

Public Function Initialize(ByVal strFileName1 As String, ByVal strFileName2 As String) As Boolean

    TRACE "RefFile=" & strFileName1
    TRACE "ResultFile=" & strFileName2
    
    If Not LoadXML(strFileName1, m_XMLDom(1)) Then Exit Function
    If Not LoadXML(strFileName2, m_XMLDom(2)) Then Exit Function
    Initialize = True
End Function


Public Function SelectTag(ByVal strPath1 As String, ByVal strPath2 As String, XMLNode1 As IXMLDOMNode, XMLNode2 As IXMLDOMNode) As Boolean

    
    Set XMLNode1 = m_XMLDom(1).selectSingleNode(strPath1)
    Set XMLNode2 = m_XMLDom(2).selectSingleNode(strPath2)
    
    If Not IsValidObject(XMLNode2) Then
        AddError "[ERROR]path """ & strPath2 & """ cannot be found in result file"
    End If
    
    SelectTag = IsValidObject(XMLNode1) And IsValidObject(XMLNode2)
        
End Function



Public Function ComparePropertiesTag(ByVal strPath As String, Optional ByVal booAddStartPath As Boolean = True) As CXMLCOMPARE_RESULT

    Dim XMLProperties   As IXMLDOMNodeList
    Dim XMLProperty     As IXMLDOMNode
    Dim XMLProperty2    As IXMLDOMNode
    Dim strPropertyPath As String
    Dim strPropertyName As String
    Dim strAttrName     As String
    Dim XMLNode1        As IXMLDOMNode
    Dim XMLNode2        As IXMLDOMNode
    
    
    On Error GoTo ErrMgr
    
'    Debug.Assert 0
    
    If booAddStartPath Then strPath = StartPath & strPath
'    Debug.Print strPath
    
    ComparePropertiesTag = CXMLCOMPARE_TYPE_UNKNOWN
    If Not SelectTag(strPath, strPath, XMLNode1, XMLNode2) Then Exit Function

    Set XMLProperties = XMLNode1.childNodes
    
    For Each XMLProperty In XMLProperties
    
        If XMLProperty.nodeName = "property" Then
        
            strPropertyName = XMLProperty.Attributes.getNamedItem("name").Text
            
            If UCase$(Right(strPropertyName, 2)) <> "ID" Then
            
                strPropertyPath = strPath & "/property[@name='" & strPropertyName & "']"
                
                Set XMLProperty2 = XMLNode2.selectSingleNode(strPropertyPath)
                
                If IsValidObject(XMLProperty2) Then
                    
                    #If DEBUG_MODE Then
                        TRACE strPropertyPath
                    #End If
                    
                    If Not MustIgnoreProperty(strPropertyName) Then
                    
                        If Not CompareString(XMLProperty.Text, XMLProperty2.Text) Then
                        
                            #If Not DEBUG_MODE Then
                                TRACE strPropertyPath
                            #End If
                            AddError "[ERROR]""" & strPropertyPath & """ "
                        End If
                    End If
                Else
                    AddError "[ERROR]""" & strPropertyPath & """ cannot be found in target file"
                End If
            End If
        Else

            '
            ' <ruleset> special case
            '
            If XMLProperty.nodeType = NODE_CDATA_SECTION Then
            
                If IsValidObject(XMLProperty.parentNode) Then
                
                    If XMLProperty.parentNode.nodeName = "ruleset" Then
                        
                        ' Get the rule set tag - we going to compare the xml at the <ruleset>
                        strPropertyPath = strPath
                        Set XMLProperty2 = XMLNode2.selectSingleNode(strPropertyPath)
             
                        #If DEBUG_MODE Then
                            TRACE strPropertyPath
                        #End If
                        
                        If Not CompareString(XMLProperty.parentNode.xml, XMLProperty2.xml, True) Then
             
                            #If Not DEBUG_MODE Then
                                TRACE strPropertyPath
                            #End If
                            AddError "[ERROR]""" & strPropertyPath & """ "
                        End If
                    End If
                End If
            End If
        
            If XMLProperty.nodeType = NODE_ELEMENT Then
            
                strAttrName = GetAttrName(XMLProperty)
                
                If XMLProperty.nodeName = "rateschedules" Then
'                    Debug.Assert 0
                End If
                
                strPropertyPath = strPath & "/" & XMLProperty.nodeName
                If Len(strAttrName) Then strPropertyPath = strPropertyPath & "[@name='" & strAttrName & "']"
                
                Set XMLProperty2 = XMLNode2.selectSingleNode(strPropertyPath)
                 
                If XMLProperty.childNodes.Length >= 1 Then ' Need to test in 2 if because of the VB If
                
                    If XMLProperty.childNodes(0).nodeType = NODE_TEXT Then
                        
                        If UCase$(Right(XMLProperty.nodeName, 2)) <> "ID" Then
                            
                            Set XMLProperty2 = XMLNode2.selectSingleNode(strPropertyPath)
                            
                            #If DEBUG_MODE Then
                                TRACE strPropertyPath
                            #End If
                            
                            If IsValidObject(XMLProperty.childNodes(0)) And IsValidObject(XMLProperty2.childNodes(0)) Then
                            
                                If Not MustIgnoreProperty(XMLProperty.nodeName) Then
                                
                                    If (Not CompareString(XMLProperty.childNodes(0).Text, XMLProperty2.childNodes(0).Text)) Then
                                    
                                        #If Not DEBUG_MODE Then
                                            TRACE strPropertyPath
                                        #End If
                                        AddError "[ERROR]""" & strPropertyPath & """ "
                                    End If
                                End If
                            Else
                                AddError "[ERROR]""" & strPropertyPath & """ "
                            End If
                        End If
                    Else
                        ComparePropertiesTag strPropertyPath, False
                    End If
                Else
                    ComparePropertiesTag strPropertyPath, False
                End If
            End If
        End If
    Next
    Exit Function
ErrMgr:
    Dim strErrMsg As String
    
    strErrMsg = "[ERROR]" & Err.Number & " description:" & Err.Description & ", source:" & Err.Source
    AddError "UnExpected RunTime Error " & strErrMsg

End Function

Private Function CompareString(ByVal s1 As String, ByVal s2 As String, Optional ByVal booRemoveCRLFTAB As Boolean) As Boolean

    If booRemoveCRLFTAB Then
        s1 = RemoveCRLFTAB(s1)
        s2 = RemoveCRLFTAB(s2)
  End If

  s1 = UCase$(s1)
  s2 = UCase$(s2)

    If Len(s1) <> Len(s2) Then
        TRACE PreProcess("Error Comparing String On The Len S1.Len=[S1.LEN] S1=[DC][S1][DC]; ", "S1.LEN", Format(Len(s1), "000000"), "S2.LEN", Format(Len(s2), "000000"), "S1", c(s1), "S2", c(s2), "DC", """")
        TRACE PreProcess("Error Comparing String On The Len S2.Len=[S2.LEN] S2=[DC][S2][DC]; ", "S1.LEN", Format(Len(s1), "000000"), "S2.LEN", Format(Len(s2), "000000"), "S1", c(s1), "S2", c(s2), "DC", """")
    End If
    Dim i As Long
    For i = 1 To Len(s1)
        If Mid(s1, i, 1) <> Mid(s2, i, 1) Then
            TRACE PreProcess("Error Comparing String At Char Position [I] S1.Char=[S1.CHAR]; S2.Char=[S2.CHAR]; S1=[DC][S1][DC]; S1=[DC][S2][DC]; ", "S2.CHAR", Mid(s2, i, 1), "S1.CHAR", Mid(s1, i, 1), "I", i, "S1", c(s1), "S2", c(s2), "DC", """")
            Exit Function
        End If
    Next
    CompareString = True
End Function

Private Function RemoveCRLFTAB(ByVal s As String) As String

    Dim ss As String
    ss = s
    ss = Replace(ss, Chr(13), "")
    ss = Replace(ss, Chr(10), "")
    ss = Replace(ss, vbTab, "")
    RemoveCRLFTAB = ss
End Function

Private Function c(ByVal s As String) As String
    Dim ss As String
    ss = Replace(s, Chr(13), "·13")
    c = Replace(ss, Chr(10), "·10")
End Function

Private Function TRACE(s As String) As Boolean
    Debug.Print s
    MTGlobal_VB_MSG.TRACE "[CXMLCompare]" & s, Me
End Function

Private Sub Class_Initialize()
    varCXMLCOMPARE_RESULT = Array("CXMLCOMPARE_TYPE_OK", "CXMLCOMPARE_TYPE_ERROR_NOT_EQUAL", "CXMLCOMPARE_TYPE_CAN_FIND_NODE", "CXMLCOMPARE_TYPE_UNKNOWN")
End Sub

Public Function GetErrorsString() As String
    Dim v As Variant
    Dim s As String
    
    TRACE Errors.Count & " ERROR(S)"
    For Each v In Errors
        s = s & v & vbNewLine
    Next
    GetErrorsString = s
End Function



Private Function GetAttrName(XMLNode As IXMLDOMNode) As String
    On Error Resume Next
    GetAttrName = XMLNode.Attributes.getNamedItem("name").Text
    Err.Clear
End Function

Private Function AddError(s As String) As Boolean
    Errors.Add s
    TRACE s
End Function

Private Function MustIgnoreProperty(strPName As String) As Boolean
    
    If InStr(UCase$(IgnorePropertyNames), "," & UCase$(strPName) & "") Then
'        Debug.Assert 0
        MustIgnoreProperty = True
    End If
End Function
