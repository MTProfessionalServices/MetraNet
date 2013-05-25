VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXSessionMeteredInformation"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit



'<dn>metratech.com/addcharge</dn>
'  <uid>wKgBzYjsBnsuPPOXiFczag==</uid>
'  <commit>Y</commit>
'  <insert>Y</insert>


Public Dn           As String
Public uID          As String
Public Commit       As String
Public Insert       As String
Public ParentID     As String

Public Property Get XML() As String

    On Error GoTo ErrMgr
    Dim strXML As String
    
    strXML = strXML & InTag("dn", Me.Dn)
    strXML = strXML & InTag("uid", Me.uID)
    strXML = strXML & InTag("commit", Me.Commit)
    strXML = strXML & InTag("insert", Me.Insert)
    
    If Len(Me.ParentID) Then strXML = strXML & InTag("parentid", Me.ParentID)
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
'<dn>metratech.com/addcharge</dn>
'  <uid>wKgBzYjsBnsuPPOXiFczag==</uid>
'  <commit>Y</commit>
'  <insert>Y</insert>
    
    Dn = m_XMLDoc.selectSingleNode("/beginsession/dn").Text
    uID = m_XMLDoc.selectSingleNode("/beginsession/uid").Text
    Commit = m_XMLDoc.selectSingleNode("/beginsession/commit").Text
    Insert = m_XMLDoc.selectSingleNode("/beginsession/insert").Text
    If IsValidObject(m_XMLDoc.selectSingleNode("/beginsession/parentid")) Then
        ParentID = m_XMLDoc.selectSingleNode("/beginsession/parentid").Text
    End If
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "XML Let", LOG_ERROR
End Property



Public Property Get IsChildren() As Boolean
    IsChildren = Len(ParentID)
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

