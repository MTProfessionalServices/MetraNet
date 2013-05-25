VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CSaxParserPriceList"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Implements IVBSAXContentHandler

Public PriceList            As MTPriceList
Private m_strPropertyName   As String
Private m_strLastTag        As String

Private Sub IVBSAXContentHandler_startElement(strNamespaceURI As String, strLocalName As String, strQName As String, ByVal attributes As MSXML2.IVBSAXAttributes)
    
    Dim strName As String

    Select Case strLocalName
        Case "imtpricelist"
            strName = Int(Timer()) & SaxGetAttributeValue(attributes, "name")
            Set PriceList = ProductCatalog.CreatePriceList
            SetMTProperty PriceList, "name", strName
            PriceList.name = strName
            
        Case "imtproperty"
            m_strPropertyName = SaxGetAttributeValue(attributes, "name")
            m_strLastTag = strLocalName
    End Select
End Sub

Private Sub IVBSAXContentHandler_endElement(strNamespaceURI As String, strLocalName As String, strQName As String)
    
    Select Case strLocalName
        Case "imtpricelist"
            SaveMTObject PriceList
    End Select

End Sub

Private Sub IVBSAXContentHandler_characters(text As String)
    'text = Replace(text, vbLf, vbCrLf)
    text = Trim(text)
    If text <> vbLf And Len(text) Then
    
        Select Case m_strLastTag
            Case "imtproperty"
            SetMTProperty PriceList, m_strPropertyName, text
        End Select
    End If
End Sub

Private Property Set IVBSAXContentHandler_documentLocator(ByVal RHS As MSXML2.IVBSAXLocator)

End Property

Private Sub IVBSAXContentHandler_endDocument()

End Sub

Private Sub IVBSAXContentHandler_endPrefixMapping(strPrefix As String)

End Sub

Private Sub IVBSAXContentHandler_ignorableWhitespace(strChars As String)

End Sub

Private Sub IVBSAXContentHandler_processingInstruction(target As String, data As String)

End Sub

Private Sub IVBSAXContentHandler_skippedEntity(strName As String)

End Sub

Private Sub IVBSAXContentHandler_startDocument()

End Sub

Private Sub IVBSAXContentHandler_startPrefixMapping(strPrefix As String, strURI As String)

End Sub



