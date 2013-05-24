VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CW3RunnerWebServer"
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
'  DATE         : 09/xx/2000
'  DESCRIPTION  : Based on the same class of fLogViewer
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Private m_varIP As Variant

Private Const CW3RUNNER_WEBSERVER_DEFAULT_TIME_OUT = 6

Private Const IP_TAG = "W3RUNNERIP="

Private m_booInitialized As Boolean

Public Enum W3RUNNER_WEBSERVICE
    W3RUNNER_WEBSERVICE_WELCOME = 1
    W3RUNNER_WEBSERVICE_LOCAL_WELCOME = 2
    W3RUNNER_WEBSERVICE_SEND_START_INFO = 3
End Enum


Public Function Initialize() As Boolean
 
    If Not GetIP() Then Exit Function
    
'    If Not IsMyMachine() Then
    
        If Not g_static_booRegistered Then
            SendStartInfo
        End If
    
        Initialize = True
        m_booInitialized = True
 '   End If
End Function

Private Function GetIP() As Boolean

    Dim objParser       As New CByteSyntaxAnalyser
    Dim lngPos          As Long
    Dim strData         As Variant
    Dim strIp           As String
    
    strIp = W3RunnerMod.Arguments("-ip")
    If (Len(strIp)) Then
    
        IP = strIp
        GetIP = True
        Exit Function
    End If
    
    If HTTPGet(HTTP_W3RUNNER_SERVER_NAME, , strData) = CHTTP_ERROR_OK Then
    
        lngPos = InStr(UCase(strData), IP_TAG)
        
        If lngPos Then
        
            objParser.Init CStr(strData)
            objParser.lngBytesIndex = lngPos - 1 + Len(IP_TAG)
            If objParser.GetString(strIp) = rSUCCEED Then
            
                IP = strIp
                GetIP = True
            End If
        End If
    End If
 
End Function

Public Function GetWebServiceURL(ByVal eWebService As W3RUNNER_WEBSERVICE) As String

    Select Case eWebService
    
        Case W3RUNNER_WEBSERVICE_WELCOME
            GetWebServiceURL = IIf(m_booInitialized, GetW3RunnerWebServicesURLFolder() & "/WebService.Welcome.asp", GetWebServiceURL(W3RUNNER_WEBSERVICE_LOCAL_WELCOME))
            
        Case W3RUNNER_WEBSERVICE_LOCAL_WELCOME
            GetWebServiceURL = Replace(App.path & "\W3Runner.Welcome.htm", "\\", "\")
            
        Case W3RUNNER_WEBSERVICE_SEND_START_INFO
            GetWebServiceURL = GetW3RunnerWebServicesURLFolder() & "/WebService.SendStartInfo.asp"
    End Select
End Function

Public Function GetW3RunnerWebServicesURLFolder() As String

    GetW3RunnerWebServicesURLFolder = "http://" & IP & "/W3Runner/WebServices"
End Function


Public Function CheckURL(strURL As String) As Boolean

    Dim strData         As Variant
    
    If HTTPGet(strURL, , strData) = CHTTP_ERROR_OK Then
    
        CheckURL = True
    End If
End Function


Public Function SendStartInfo() As Boolean

    On Error GoTo errmgr

    Dim objWinApi   As New cWindows
    Dim objTextFile As New cTextFile
    Dim strAspStart As String
    Dim strParam    As String
    Dim strUsage    As String
    Dim strData     As Variant
    Dim objPP       As New CPreProcessor
    Dim strMessage  As String
    Dim strVersion  As String
    Dim strStatus   As String
    Dim m_objUIHelper       As New CUIHelper
    
    strAspStart = GetWebServiceURL(W3RUNNER_WEBSERVICE_SEND_START_INFO)
    
    strUsage = AppOptions("UsageCounter", CLng(0))
    
    objPP.Add "USAGE", Replace(strUsage, " ", "_")
    objPP.Add "DATETIME", m_objUIHelper.GMTNow()
    objPP.Add "VERSION", Replace(App.Major & "." & App.Minor, " ", "_")
    objPP.Add "INSTALLID", Replace(AppOptions("INSTALLID"), " ", "_")
    objPP.Add "COUNTRY", Replace(GetCountry(), " ", "_")
    objPP.Add "REGISTER", Abs(g_static_booRegistered) ' to avoid true/false translation
    
    strParam = "[VERSION] [DATETIME] [USAGE] [COUNTRY] [INSTALLID] [REGISTER]"
    strParam = objPP.Process(strParam, "[", "]")
        
    If (Len(strAspStart)) Then
    
        If (HTTPGet(strAspStart, "p=" & EncodeUrl(strParam), strData) = CHTTP_ERROR_OK) Then
        
            strStatus = UCase(GetServerValue(CStr(strData), "Status"))
            
            If (strStatus = "OK") Then
                
                strMessage = GetServerValue(CStr(strData), "Message")
                If Len(strMessage) Then FShowError strMessage
                
                strVersion = GetServerValue(CStr(strData), "Version")
                
                If "" & strVersion > "" & GetW3RunnerVersion(True) Then
                
                    If GetServerValue(CStr(strData), "ForceToUpgrade") Then
                    
                        FShowError PreProcess(W3RUNNER_MSG_07039, "VERSION", strVersion)
                        End
                    Else
                        FShowError PreProcess(W3RUNNER_MSG_07038, "VERSION", strVersion)
                    End If
                End If
                'ProcessVersion strVersion
            End If
            SendStartInfo = True
        End If
    End If
Exit Function
errmgr:
    'In case of error we do nothing
    'FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "SendStartInfo"
End Function


Private Function GetServerValue(strResponse As String, strVariable As String) As String

    On Error GoTo errmgr
    
    Dim lngStart    As Long
    Dim lngStart2   As Long
    Dim lngEnd      As Long
    
    lngStart = InStr(UCase(strResponse), UCase(strVariable) & "=")
    If (lngStart) Then
    
        lngEnd = InStr(lngStart, UCase(strResponse), vbNewLine)
        lngStart2 = lngStart + Len(strVariable) + 1
        GetServerValue = Mid(strResponse, lngStart2, lngEnd - lngStart2)
    End If
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "GetServerValue"
End Function


Private Function IsMyMachine() As Boolean

    On Error GoTo errmgr
    
    Dim objWinApi As New cWindows
    
    IsMyMachine = UCase$(objWinApi.ComputerName()) = "PMS"
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "IsMyMachine"
End Function

Public Function TimeOut() As Long
    TimeOut = CLng(AppOptions("DownLoad.TimeOut", W3RUNNER_WEBSERVER_DEFAULT_TIMEOUT))
End Function


Private Function HTTPGet(ByVal strURL As String, Optional ByVal strParameters As String, Optional ByRef varOutPut As Variant, Optional ByRef varHeaders As Variant, Optional ByVal lngTimeOut As Long) As CHTTP_ERROR
    
    Dim varFileName As Variant
    Dim objTextFile As New cTextFile
    Dim varTimeOut As Variant
    
    HTTPGet = CHTTP_ERROR_HTTP_ERROR
'    Debug.Print strURL & "?" & strParameters
    
    If g_objHTTP.Initialized Then
    
        If lngTimeOut = 0 Then
            lngTimeOut = AppOptionsLong("CW3RUNNER_WEBSERVER_DEFAULT_TIME_OUT", CW3RUNNER_WEBSERVER_DEFAULT_TIME_OUT)
        End If
        g_objHTTP.TraceMode = False
        g_objHTTP.TimeOut = lngTimeOut
        HTTPGet = g_objHTTP.Execute("GET", strURL, strParameters, varOutPut)
        
        g_static_lngDemoItemCount = g_static_lngDemoItemCount - 1
        
        g_objHTTP.TraceMode = True
    Else
        HTTPGet = CHTTP_ERROR_OK
    End If
End Function

Public Property Get IP() As Variant
    If IsEmpty(m_varIP) Then
        Initialize
    End If
    IP = m_varIP
End Property

Public Property Let IP(ByVal v As Variant)
    m_varIP = v
End Property
