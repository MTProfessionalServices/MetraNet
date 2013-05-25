VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXMeteredInformation"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'<timestamp>2002-06-06T01:57:15Z</timestamp>
'<version>2.0</version>
'<uid>wKgBzYjsBnsFnF/viVczag==</uid>
'<entity>192.168.1.205</entity>
'<sessioncontext>PHNlY3VyaXR5Y29udGV4dD48aWRfYWNjPjEyOTwvaWRfYWNjPjxyb2xlcy8+PGNvbXBvc2l0ZWNhcGFiaWxpdGllcz48Y29tcG9zaXRlY2FwYWJpbGl0eT48bmFtZT5VbmxpbWl0ZWQgQ2FwYWJpbGl0eTwvbmFtZT48cHJvZ2lkPk1ldHJhdGVjaC5NVEFsbENhcGFiaWxpdHk8L3Byb2dpZD48ZGJpZD4xPC9kYmlkPjwvY29tcG9zaXRlY2FwYWJpbGl0eT48L2NvbXBvc2l0ZWNhcGFiaWxpdGllcz48L3NlY3VyaXR5Y29udGV4dD4

Public TimeStamp        As String
Public Version          As String
Public uID              As String
Public entity           As String
Public SessionContext   As String


Public Property Get XML() As String

    On Error GoTo ErrMgr
    Dim strXML As String
    
    strXML = strXML & InTag("timestamp", Me.TimeStamp)
    strXML = strXML & InTag("version", Me.Version)
    strXML = strXML & InTag("uid", Me.uID)
    strXML = strXML & InTag("entity", Me.entity)
    If Len(Me.SessionContext) Then strXML = strXML & InTag("sessioncontext", Me.SessionContext)
    XML = strXML
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "XML Get", LOG_ERROR
End Property

' We expect the XML that the xml has been validated
Public Property Let XML(strXML As String)

    On Error GoTo ErrMgr
    
    Dim m_XMLDoc    As New MSXML2.DOMDocument30
    Dim objPP       As New CPreProcessor
    
    m_XMLDoc.loadXML strXML
        
'     <timestamp>2002-06-06T01:57:15Z</timestamp>
'  <version>2.0</version>
'  <uid>wKgBzYjsBnsFnF/viVczag==</uid>
'  <entity>192.168.1.205</entity>
'  <sessioncontext>
    
    TimeStamp = m_XMLDoc.selectSingleNode("/msix/timestamp").Text
    Version = m_XMLDoc.selectSingleNode("/msix/version").Text
    uID = m_XMLDoc.selectSingleNode("/msix/uid").Text
    entity = m_XMLDoc.selectSingleNode("/msix/entity").Text
    If IsValidObject(m_XMLDoc.selectSingleNode("/msix/sessioncontext")) Then
        Me.SessionContext = m_XMLDoc.selectSingleNode("/msix/sessioncontext").Text
    End If
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "XML Let", LOG_ERROR
End Property


Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub
