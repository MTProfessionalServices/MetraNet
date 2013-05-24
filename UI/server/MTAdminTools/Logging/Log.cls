VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Log"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'----------------------------------------------------------------------------
'  MEMBER VARIABLES
'----------------------------------------------------------------------------
Public m_objXMLDoc    As DOMDocument
Public m_strXMLFile   As String

'----------------------------------------------------------------------------
'  METHODS
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
'   Name: DoInit
'   Description: Loads xml file in url argument
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub DoInit(Optional strXMLFile As String)
On Error GoTo errHandler
    Dim strFile     As String
  
  
  If Len(strXMLFile) = 0 Then
    strFile = request.QueryString("xmlFile")
  Else
    strFile = strXMLFile
  End If
  
  
    If InStr(strFile, ":") = 0 Then
        m_strXMLFile = server.MapPath(strFile)
    Else
        m_strXMLFile = strFile
    End If
  
  ' load XML doc
  m_objXMLDoc.async = False
  m_objXMLDoc.Load (m_strXMLFile)
  
  Dim myErr As IXMLDOMParseError
  
  Set myErr = m_objXMLDoc.parseError
  
  If myErr.errorCode <> 0 Then
    Call WriteError(myErr.reason)
  End If
    
  Exit Sub
    
errHandler:
  Call WriteError(Err.Description)
End Sub

'----------------------------------------------------------------------------
'  EVENTS
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
'   Name: onstartpage
'   Description:  Set up the ASP variable.  Call during CreateObject
'   Parameters: sc As ScriptingContext
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub onstartpage(sc As ASPTypeLibrary.ScriptingContext)
       Set response = sc.response
       Set session = sc.session
       Set server = sc.server
       Set request = sc.request
       Set application = sc.application
End Sub


'----------------------------------------------------------------------------
'   Name: StartLogger
'   Description: kills old logger and starts new one based on filename in xml config file
'-----------------------------------------------------------------------------
Public Sub StartLogger()
    Dim strPath As String
    Dim Parent              As IXMLDOMNodeList
    
    Set Parent = m_objXMLDoc.selectNodes("//logfilename")
    
    strPath = "kill mtnclogger"
    Call ShellEx(strPath, True)
    

    strPath = "mtnclogger -L -p 9001 -e ""tail -n 200 -f " & Parent(0).childNodes(0).Text & """"
    Shell (strPath)
     
    Sleep (500)
     
End Sub
                   

'----------------------------------------------------------------------------
' GetFileSize
'----------------------------------------------------------------------------
Public Function GetFileSize()
On Error GoTo errHandler
    Dim LogFile              As IXMLDOMNode
    
    Set LogFile = m_objXMLDoc.selectSingleNode("//logfilename")
    
    If TypeName(LogFile) = "IXMLDOMNode" Then
       GetFileSize = CStr(FileLen(LogFile.Text))
    Else
       GetFileSize = "File does not exist."
    End If
    
    Exit Function
errHandler:
    Set LogFile = Nothing
    'Call WriteError(Err.Description)
    GetFileSize = "File does not exist."
End Function

'----------------------------------------------------------------------------
' GetFileName
'----------------------------------------------------------------------------
Public Function GetFileName()
On Error GoTo errHandler
    Dim strPath As String
    Dim LogFile              As IXMLDOMNode
    
    Set LogFile = m_objXMLDoc.selectSingleNode("//logfilename")
    
    If TypeName(LogFile) = "IXMLDOMNode" Then
       GetFileName = LogFile.Text
    Else
       GetFileName = ""
    End If
    
    Exit Function
errHandler:
    Set LogFile = Nothing
    'Call WriteError(Err.Description)
    GetFileName = ""
End Function


 '----------------------------------------------------------------------------
' GetFileDate
'----------------------------------------------------------------------------
Public Function GetFileDate()
On Error GoTo errHandler
    Dim strPath As String
    Dim LogFile              As IXMLDOMNode
    
    Set LogFile = m_objXMLDoc.selectSingleNode("//logfilename")
    
    If TypeName(LogFile) = "IXMLDOMNode" Then
       GetFileDate = FileDateTime(LogFile.Text)
    Else
       GetFileDate = "File does not exist."
    End If
    
    Exit Function
errHandler:
    Set LogFile = Nothing
    'Call WriteError(Err.Description)
    GetFileDate = "File does not exist."
End Function
   


'----------------------------------------------------------------------------
'  Initialize and cleanup
'----------------------------------------------------------------------------
Private Sub Class_Initialize()
   Set m_objXMLDoc = New DOMDocument
End Sub

Private Sub Class_Terminate()
   Set m_objXMLDoc = Nothing
End Sub
