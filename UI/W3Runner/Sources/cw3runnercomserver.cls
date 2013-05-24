VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CW3RunnerComServer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public IP As String

Const HTTP_FRED_RUNNER_SERVER_NAME = "http://www.flogviewer.com"
Const HTTP_FRED_RUNNER_WEB_SITE = "http://www.W3Runner.com"

Public Function Initialize() As Boolean

    Dim o       As CPreProcessor
    Dim strHTML As String
    
    On Error GoTo ErrMgr
    
    'If (Not IsMyMachine()) Then
    
        If (Register()) Then
        
            Initialize = True
        End If
    'End If
    Exit Function
ErrMgr:
    FShowError W3Runner_ERROR_07003 & " " & GetVBErrorString(), "CW3RunnerComServer", "Initialize"
End Function

Public Function Register() As Boolean

    On Error GoTo ErrMgr

    Dim objWinApi   As New cWindows
    Dim objTextFile As New cTextFile
    Dim strAspStart As String
    Dim strParam    As String
    Dim strUsage    As String
    Dim strData     As String
    Dim objPP       As New CPreProcessor
    Dim strMessage  As String
    Dim strVersion  As String
    Dim strStatus   As String
    
    strAspStart = GetServerURL() & "/W3RunnerTrial.asp"
    
    strUsage = AppOptions("UsageCounter", CLng(0))
    
    objPP.Add "USAGE", Replace(strUsage, " ", "_")
    objPP.Add "DATETIME", GetCurrentGMTTime()
    
    objPP.Add "VERSION", Replace(App.Major & "." & App.Minor, " ", "_")
    objPP.Add "INSTALLID", Replace(AppOptions("INSTALLID"), " ", "_")
    objPP.Add "COUNTRY", Replace(GetCountry(), " ", "_")
        
    strParam = "[VERSION] [DATETIME] [USAGE] [COUNTRY] [INSTALLID]"
    strParam = objPP.Process(strParam, "[", "]")
        
    If (Len(strAspStart)) Then
    
        If (DownLoad(strAspStart & "?p=" & strParam, strData)) Then
        
            strStatus = UCase(GetServerValue(strData, "Status"))
            
            If (strStatus = "OK") Then
                
                strMessage = GetServerValue(strData, "Message")
                ProcessMessage strMessage
                
                'strVersion = GetServerValue(strData, "Version")
                'ProcessVersion strVersion
            End If
            Register = True
        End If
    End If
Exit Function
ErrMgr:
    FShowError W3Runner_ERROR_07003 & " " & GetVBErrorString(), "CW3RunnerComServer", "Register"
End Function

Private Function ProcessVersion(strNewVersion As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim strData     As String
    Dim strVersion  As String
    
    strVersion = App.Major & "." & App.Minor
    
    If (CDbl(strNewVersion) > CDbl(strVersion)) Then
       frmSplash.Hide
       
       If (MsgBox(PreProcess(W3Runner_MSG_07008, "VERSION", strNewVersion), vbYesNo + vbQuestion) = vbYes) Then
       
           Dim m_objtool As New cTool
           m_objtool.ExecFile HTTP_FRED_RUNNER_WEB_SITE
       End If
    End If
Exit Function
ErrMgr:
    FShowError W3Runner_ERROR_07003 & " " & GetVBErrorString(), "CW3RunnerComServer", "ProcessVersion"
End Function

Private Function GetServerURL() As String
    On Error GoTo ErrMgr
    GetServerURL = HTTP_FRED_RUNNER_SERVER_NAME & "/WebServices"
    Exit Function
ErrMgr:
    FShowError W3Runner_ERROR_07003 & " " & GetVBErrorString(), "CW3RunnerComServer", "Initialize"
End Function

Private Function IsMyMachine() As Boolean

    On Error GoTo ErrMgr
    
    Dim objWinApi As New cWindows
    
    IsMyMachine = UCase$(objWinApi.ComputerName()) = "PMS"
    Exit Function
ErrMgr:
    FShowError W3Runner_ERROR_07003 & " " & GetVBErrorString(), "CW3RunnerComServer", "IsMyMachine"
End Function

Private Function GetServerValue(strResponse As String, strVariable As String) As String

    On Error GoTo ErrMgr
    
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
ErrMgr:
    FShowError W3Runner_ERROR_07003 & " " & GetVBErrorString(), "CW3RunnerComServer", "GetServerValue"
End Function

Private Function ProcessMessage(strMessage As String) As Boolean

    Dim objTool     As New cTool
    Dim objWinApi   As New cWindows

    If (Len(strMessage)) Then
        If (InStr(strMessage, "http:")) Then
            objTool.ExecFile strMessage
            DoEvents
            objWinApi.Sleep 1000
        Else
            frmSplash.Hide
            MsgBox strMessage
        End If
    End If
End Function

