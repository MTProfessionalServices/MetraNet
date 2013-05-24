VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CHTTP"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 09/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Public Base64 As New CBase64

Private m_objIECache As New CIECache

Public Enum eURL_ENCODE
 URL_ESCAPE_SEGMENT_ONLY = &H2000     'Treat entire URL param as one URL segment
 URL_ESCAPE_PERCENT = &H1000
 URL_UNESCAPE_INPLACE = &H100000
 URL_INTERNAL_PATH = &H800000           'escape #'s in paths
 URL_DONT_ESCAPE_EXTRA_INFO = &H2000000
 URL_ESCAPE_SPACES_ONLY = &H4000000
 URL_DONT_SIMPLIFY = &H8000000
End Enum

Private Const PROG_ID_1 = "msxml2.ServerXMLHTTP"
Private Const PROG_ID_2 = "msxml2.XMLHTTP"

Private Const HTTP_DEFAULT_TIME_OUT = 6

#If COMPILE_IN_FLOGVIEWER Or W3RUNNER_MONITOR Or W3RUNNER_DEFINE Or W3Runner_DLL_DEFINE Or HTTP_RECORDER Then
    'Private m_XMLHTTP As msxml2.ServerXMLHTTP30
    'Private m_XMLHTTP As MSXML2.XMLHTTP30
    Private m_XMLHTTP As Object
#Else
    Private m_XMLHTTP As msxml2.XMLHTTP
#End If

Private m_strMethod                     As String
Private m_strURL                        As String
Private m_strUserName                   As String
Private m_strPassWord                   As String
Private m_strData                       As String
Private m_booSyncronous                 As Boolean
Private m_lngWaitForResponseSleepTime   As Long
Private m_lngTimeOut                    As Long
Private m_lngLastExecuteTime            As Long
Private m_lngPort                       As Long
Private m_objLastExecutionError         As New CError

Private Const TEXT_CONTENT_TYPE_1 = "text/"
Private Const TEXT_CONTENT_TYPE_2 = "application/octet-stream"
Private Const HTTP_STATUS_OK_CODE = 200

Public Enum CHTTP_ERROR
    CHTTP_ERROR_OK = 1
    CHTTP_ERROR_TIME_OUT = 2
    CHTTP_ERROR_MSXML2_XMLHTTP_NOT_FOUND = 4
    CHTTP_ERROR_WRITING_OUTPUT_FILE = 8
    CHTTP_ERROR_UNEXPECTED_RUN_TIME_ERROR = 16
    CHTTP_ERROR_HTTP_ERROR = 32
    CHTTP_ERROR_OBJECT_NOT_INITIALIZED = 64
    CHTTP_ERROR_CANNOT_OVERWRITE_FILE = 128
End Enum
Public CHTTP_ERROR_STRINGS As Variant



Public Enum XMLHTTP_READYSTATE

    XMLHTTP_READYSTATE_NOT_INITIALIZED = 0 ': The XMLHTTP object has been created but not initialised
    XMLHTTP_READYSTATE_OPENED = 1 ' : The Open method has been called but no data has been sent
    XMLHTTP_READYSTATE_RESPONSE_NOT_AVAILABLE = 2 ' : The Send method has been called but no response is available from the server
    XMLHTTP_READYSTATE_RESPONSE_BECOMING_AVAILABLE = 3 ' : The response is becoming available from the server
    XMLHTTP_READYSTATE_RESPONSE_COMPLETE = 4 ' : The response from the server is complete
End Enum

Public Target           As String ' not used
Public Initialized      As Boolean
Public Parameters       As CVariables ' For load testing
Public InputHeaders     As CVariables
Public TraceMode        As Boolean
Public TextFile         As Boolean

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Initialize() As CHTTP_ERROR

    If CheckComObject() Then    ' Create the COM object
    
        Initialize = CHTTP_ERROR_OK
        Initialized = True
    Else
        Initialize = CHTTP_ERROR_MSXML2_XMLHTTP_NOT_FOUND
    End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Execute(Optional ByVal strMethod As String, Optional ByVal strURL As String, Optional ByVal strParameters As String, Optional ByRef varOutPut As Variant, Optional ByRef varHeaders As Variant, Optional booTextFile As Boolean = False) As CHTTP_ERROR
    
    On Error GoTo errmgr
    
    Dim eRetCode        As CHTTP_ERROR
    Dim objTextFile     As New cTextFile
    Dim varByteArray    As Variant
    Dim objInputHeader  As CVariable
    
    m_objLastExecutionError.Clear
    
    m_lngLastExecuteTime = GetTickCount()
        
    If Not IsValidObject(m_XMLHTTP) Then
    
        Execute = CHTTP_ERROR_OBJECT_NOT_INITIALIZED
        Exit Function
    End If
    
    strParameters = GetParametersString(strParameters)
    strURL = GetURL(strURL)
    strMethod = GetMethod(strMethod)
    booTextFile = GetTextFileMode(booTextFile)
        
    #If W3RUNNER_DEFINE Then
    
        ' Inc the counter even when we call a webservice
        ' The class CWebServer will decrease the counter
       ' CheckToEndTrialVersion
        
        If TraceMode Then
            frmMain.TRACE PreProcess("Http.Execute([DC][METHOD][DC],[DC][URL][DC],[DC][PARAM][DC],[DC][VAROUTPUT][DC],varHeaders,[TEXTFILE])", "METHOD", strMethod, "URL", strURL, "PARAM", strParameters, "VAROUTPUT", varOutPut, "DC", """", "TEXTFILE", booTextFile), w3rMETHOD
        End If
    #End If
    
    'objHTTP.SetTimeouts 1000, 1000, 1000, 1000
    
    strMethod = UCase$(strMethod)
    
    Debug.Print strMethod & " " & strURL & " " & strParameters
        
    Select Case strMethod
    
        Case "GET", "HEAD":
        
            'Debug.Assert strMethod <> "HEAD"
        
            m_XMLHTTP.Open strMethod, strURL & IIf(Len(strParameters), "?" & strParameters, ""), Not Syncronous, UserName, m_strPassWord
            If Len(Data) Then
                m_XMLHTTP.Send Data
            Else
                m_XMLHTTP.Send
            End If
            
        Case "POST":
        
            m_XMLHTTP.Open strMethod, strURL, Not Syncronous, UserName, m_strPassWord
            
            ' Set the headers or the default and required for a post if none are defined
            If InputHeaders.Count Then
            
                For Each objInputHeader In InputHeaders
                
                    m_XMLHTTP.setRequestHeader objInputHeader.Name, objInputHeader.Value
                Next
            Else
                m_XMLHTTP.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
            End If
            If Len(Data) Then
                m_XMLHTTP.Send Data
            Else
                m_XMLHTTP.Send IIf(Len(strParameters), strParameters, "")
            End If
    End Select
        
    eRetCode = WaitForResponse(Me.TimeOut)
    
    If eRetCode = CHTTP_ERROR_OK Then
    
        Debug.Print "HTTP Status:" & Me.Status & " " & Me.StatusText
        If m_XMLHTTP.Status = HTTP_STATUS_OK_CODE Then
        
            If Not IsMissing(varHeaders) Then varHeaders = m_XMLHTTP.getAllResponseHeaders()
        
            If strMethod <> "HEAD" Then
            
                If Not IsMissing(varOutPut) Then ' Return a string or a buffer
                
                    If IsEmpty(varOutPut) Then
                    
                        If IsHTTPTextResponse(booTextFile) Then
                            
                            varOutPut = m_XMLHTTP.ResponseText
                        Else
                            varOutPut = m_XMLHTTP.ResponseBody
                        End If
                        eRetCode = CHTTP_ERROR_OK
                    Else
                        If IsHTTPTextResponse(booTextFile) Then
                            ' Save as Text
                            eRetCode = IIf(objTextFile.LogFile(varOutPut, m_XMLHTTP.ResponseText, True), CHTTP_ERROR_OK, CHTTP_ERROR_WRITING_OUTPUT_FILE)
                        Else
                            ' Save As bin
                            eRetCode = IIf(SaveByteArrayIntoFileName(varOutPut, m_XMLHTTP.ResponseBody), CHTTP_ERROR_OK, CHTTP_ERROR_WRITING_OUTPUT_FILE)
                        End If
                    End If
                End If
            End If
        Else
            eRetCode = CHTTP_ERROR_HTTP_ERROR
        End If
    End If
    Execute = eRetCode
    m_lngLastExecuteTime = GetTickCount() - m_lngLastExecuteTime
TheExit:
    Exit Function
errmgr:
    m_objLastExecutionError.Save Err
    Execute = CHTTP_ERROR_UNEXPECTED_RUN_TIME_ERROR
    GoTo TheExit
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Abort() As Boolean

    m_XMLHTTP.Abort
    Abort = True
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function WaitForResponse(ByVal lngTimeOut As Long) As CHTTP_ERROR

    On Error GoTo errmgr

    Dim lngTime  As Long

    lngTime = GetTickCount()
    lngTimeOut = lngTimeOut * 1000

    Do While m_XMLHTTP.ReadyState <> XMLHTTP_READYSTATE_RESPONSE_COMPLETE

         Sleep m_lngWaitForResponseSleepTime
         DoEvents
         Debug.Print m_XMLHTTP.ReadyState & ".";
         If GetTickCount() > lngTime + lngTimeOut Then

            WaitForResponse = CHTTP_ERROR_TIME_OUT
            Exit Function
         End If
     Loop
     WaitForResponse = CHTTP_ERROR_OK

'    lngTimeOut = lngTimeOut * 1000
'
'    Do While m_XMLHTTP.ReadyState <> XMLHTTP_READYSTATE_RESPONSE_COMPLETE
'
'        m_XMLHTTP.WaitForResponse lngTimeOut
'        DoEvents
'        Debug.Print "#"
'    Loop
'    WaitForResponse = CHTTP_ERROR_OK

Exit Function
errmgr:
    WaitForResponse = CHTTP_ERROR_UNEXPECTED_RUN_TIME_ERROR
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function CheckComObject() As Boolean

    On Error Resume Next
    
    Dim strProgId As String
    
    strProgId = PROG_ID_1
    Set m_XMLHTTP = CreateObject(strProgId)
    If Err.Number Then
        #If W3RUNNER_DEFINE Then
            frmQuickMessage.OpenDialog PreProcess(W3RUNNER_ERROR_07044, "PROG_ID_1", PROG_ID_1, "PROG_ID_2", PROG_ID_2), "07044"
        #End If
        strProgId = PROG_ID_2
        Set m_XMLHTTP = CreateObject(strProgId)
    End If
    
    CheckComObject = Err.Number = 0
    Err.Clear
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Status() As String

    On Error GoTo errmgr
    
    Dim strStatus As String
    
    strStatus = m_XMLHTTP.Status
    
    If Len(strStatus) = 0 Then GoSub ReadRunTimeErrorStatus
TheExit:
    Status = strStatus
    Exit Property
ReadRunTimeErrorStatus:
    strStatus = m_objLastExecutionError.Number
Return
errmgr:
    GoSub ReadRunTimeErrorStatus
    GoTo TheExit
End Property

Public Property Get StatusText() As String

    On Error GoTo errmgr
    
    Dim strStatusText As String
    
    strStatusText = m_XMLHTTP.StatusText
    
    If Len(strStatusText) = 0 Then GoSub ReadRunTimeErrorStatusText
TheExit:
    StatusText = strStatusText
    Exit Property
ReadRunTimeErrorStatusText:
    If Len(m_objLastExecutionError.Description) Then
        strStatusText = m_objLastExecutionError.Description & "-" & m_objLastExecutionError.Source
    End If
Return
errmgr:
    GoSub ReadRunTimeErrorStatusText
    GoTo TheExit
End Property


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get OutputHeaders(Optional ByVal strHeaderName As String) As String

    OutputHeaders = m_XMLHTTP.getResponseHeader(strHeaderName)
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function IsHTTPTextResponse(ByVal booTextFile As Boolean) As Boolean

'Accept -Ranges: bytes
    If booTextFile Then
    
        IsHTTPTextResponse = True
    Else

        IsHTTPTextResponse = InStr(LCase(Me.OutputHeaders("Content-Type")), TEXT_CONTENT_TYPE_1) 'Or InStr(LCase(Me.OutputHeaders("Content-Type")), TEXT_CONTENT_TYPE_2)
    End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Initialize()
    'Set Info = New CHTTPInfo
    Set Parameters = New CVariables
    Set InputHeaders = New CVariables
    m_lngWaitForResponseSleepTime = 100
    m_lngPort = 0 ' No transform

    #If W3RUNNER_DEFINE Then
        TimeOut = AppOptions("HTTPDownLoadTimeOut", HTTP_DEFAULT_TIME_OUT)
    #Else
        TimeOut = HTTP_DEFAULT_TIME_OUT
    #End If
    CHTTP_ERROR_STRINGS = Array("Undefined", "OK", "Time Out", "MSXML2.XMLHTTP not found", "Error Writing Output File", "UnExpected Run Time Error", "HTTP Error", "Object Not Initialized", "Cannot OverWrite File")
    
    TraceMode = True
End Sub

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get WaitForResponseSleepTime() As Long

    WaitForResponseSleepTime = m_lngWaitForResponseSleepTime
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let WaitForResponseSleepTime(ByVal v As Long)

    m_lngWaitForResponseSleepTime = v
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get TimeOut() As Long

    TimeOut = m_lngTimeOut
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let TimeOut(ByVal v As Long)

    m_lngTimeOut = v
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function SaveByteArrayIntoFileName(ByVal strFileName As String, ByRef varByteArray As Variant) As CHTTP_ERROR

    Dim bytArr()    As Byte
    Dim objTextFile As New cTextFile
    Dim lngHandle   As Long
    
    bytArr = varByteArray
    SaveByteArrayIntoFileName = CHTTP_ERROR_HTTP_ERROR
    
    If objTextFile.ExistFile(strFileName) Then
    
        If Not objTextFile.DeleteFile(strFileName) Then
        
            SaveByteArrayIntoFileName = CHTTP_ERROR_CANNOT_OVERWRITE_FILE
            Exit Function
        End If
    End If
    
    lngHandle = FreeFile()
    Open strFileName For Binary Access Write As lngHandle
    Put #lngHandle, , bytArr()
    Close #lngHandle
    SaveByteArrayIntoFileName = CHTTP_ERROR_OK
Exit Function
errmgr:
    SaveByteArrayIntoFileName = CHTTP_ERROR_UNEXPECTED_RUN_TIME_ERROR
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function GetParametersString(ByVal strParameters As String) As String
        
    Dim objVariable As CVariable
        
    If Len(strParameters) Then
    
        GetParametersString = strParameters
        Exit Function
    End If
    
    If Me.Parameters.Count Then
        
        For Each objVariable In Me.Parameters
        
            strParameters = strParameters & objVariable.Name & "=" & EncodeUrl(objVariable.Value) & "&"
        Next
        If Len(strParameters) Then If Mid(strParameters, Len(strParameters), 1) = "&" Then strParameters = Mid(strParameters, 1, Len(strParameters) - 1)

        GetParametersString = strParameters
    End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function GetURL(strURL As String) As String

    Dim sUrl As String
    If Len(strURL) Then
        sUrl = strURL
    Else
        sUrl = URL
    End If
    If Right(sUrl, 1) = "#" Then sUrl = Mid(sUrl, 1, Len(sUrl) - 1)
    
    TransformURL sUrl, Port
    
    GetURL = sUrl
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function GetMethod(strMethod As String) As String
    If Len(strMethod) Then
        GetMethod = strMethod
    Else
        GetMethod = Method
    End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function ToString() As String

    Dim v       As CVariable
    Dim strS    As String
    
    strS = strS & Method & " " & URL
    
    If Parameters.Count Then
    
        strS = strS & "?" & Me.GetParametersString("")
    End If
    ToString = strS
End Function

' Just allow the client to trace the current error
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function TRACE(ByVal eMode As Object) As Boolean

    #If W3RUNNER_DEFINE Then
        frmMain.TRACE "HTTP Status " & Me.Status & " " & Me.StatusText, w3rERROR
    #End If
    TRACE = True
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Method() As String
    Method = m_strMethod
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let Method(ByVal vNewValue As String)

    TraceMethod PreProcess("Http.Method = [DC][VALUE][DC]", "VALUE", vNewValue, "DC", """")
    m_strMethod = vNewValue
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get URL() As String
    URL = m_strURL
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let URL(ByVal vNewValue As String)

    TraceMethod PreProcess("Http.URL =[DC][VALUE][DC]", "VALUE", vNewValue, "DC", """")
    m_strURL = vNewValue
    Me.Parameters.Clear
    Me.InputHeaders.Clear
    Data = ""
    TextFile = False
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get UserName() As String
    UserName = m_strUserName
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let UserName(ByVal vNewValue As String)
    
    TraceMethod PreProcess("Http.UserName =[DC][VALUE][DC]", "VALUE", vNewValue, "DC", """")
    m_strUserName = vNewValue
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
'Public Property Get PassWord() As String
'    PassWord = m_strPassWord
'End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let PassWord(ByVal vNewValue As String)
    
    TraceMethod PreProcess("Http.PassWord =[DC][VALUE][DC]", "VALUE", "blur", "DC", """")
    m_strPassWord = vNewValue
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Syncronous() As Boolean
    Syncronous = m_booSyncronous
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let Syncronous(ByVal vNewValue As Boolean)

    TraceMethod PreProcess("Http.Syncronous =[DC][VALUE][DC]", "VALUE", vNewValue, "DC", """")
    m_booSyncronous = vNewValue
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function TraceMethod(strMessage As String) As Boolean
    #If W3RUNNER_DEFINE Then
        If TraceMode Then frmMain.TRACE strMessage, w3rMETHOD
    #End If
    TraceMethod = True
End Function

Public Property Get Data() As String
    Data = m_strData
End Property

Public Property Let Data(ByVal vNewValue As String)
    m_strData = vNewValue
End Property

Public Property Get ResponseText() As String
    ResponseText = m_XMLHTTP.ResponseText
End Property

Public Property Get ResponseBody() As Variant
    ResponseBody = m_XMLHTTP.ResponseBody
End Property

Public Function StrConv(varString As Variant, Conversion As VbStrConv, Optional LocaleID As Long) As Variant
    StrConv = VBA.StrConv(varString, Conversion, LocaleID)
End Function

Public Property Get Port() As Long
    Port = m_lngPort
End Property

Public Property Let Port(ByVal vNewValue As Long)
    m_lngPort = vNewValue
End Property

Public Function GetTextFileMode(ByVal booTextFileMode As Boolean) As Boolean
    GetTextFileMode = IIf(booTextFileMode, booTextFileMode, TextFile)
End Function

Public Property Get LastExecuteTime() As Long
    LastExecuteTime = m_lngLastExecuteTime
End Property

Public Function TransformURL(ByRef URL As String, lngHTTPPort As Long) As Boolean

    Dim strURL          As String
    Dim lngPos          As Long
    Dim strURLServer    As String
    Dim strURLRest      As String
    
    On Error GoTo errmgr
    
    If lngHTTPPort = 0 Then Exit Function
    
    strURL = URL
    
    If Mid(LCase$(strURL), 1, Len(HTTP_PREFIX)) = HTTP_PREFIX Then
    
        ' Search the end of the server
        lngPos = InStr(Len(HTTP_PREFIX) + 1, strURL, "/") ' This is an address like http://www.flogviewer.com/default.asp we will transform it like this  http://www.flogviewer.com:8080/default.asp
            
        If lngPos Then
        
            strURLServer = Mid(strURL, Len(HTTP_PREFIX) + 1, lngPos - 1 - (Len(HTTP_PREFIX)))
            strURLRest = Mid(strURL, lngPos + 1)
        Else
            strURLServer = Mid(strURL, Len(HTTP_PREFIX) + 1)
            strURLRest = ""
        End If
        
        lngPos = InStr(strURLServer, ":")
        If lngPos Then ' The URL Server has already a port set remove it
            strURLServer = Mid(strURLServer, 1, lngPos - 1)
        End If
        strURLServer = strURLServer & ":" & lngHTTPPort
        
        URL = HTTP_PREFIX & strURLServer & IIf(Len(strURLRest), "/" & strURLRest, "")
    End If
    TransformURL = True
    Exit Function
errmgr:
    #If W3RUNNER_DEFINE Then
        FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "TransformURL"
    #End If
End Function

Public Property Get StatusString() As String
    StatusString = Status & "-" & StatusText
End Property

Public Property Get IECache() As Variant
    Set IECache = m_objIECache
End Property

