Attribute VB_Name = "W3RunnerMod"
Option Explicit

#If RECORD_MODE_ Then
    Public g_objIEEventFilter               As CIEEventFilter
#End If

Public g_objCryptor                     As New CPoissonSuceur
Public g_lngDownLoadResponseTimeDelay   As Long
Public g_objW3RunnerPostTempData        As New CW3RunnerPostTempData
Public g_objStack                       As New CVariantStack
Public g_objWinApi                      As New cWindows
Public g_objTextFile                    As New cTextFile
Public g_objCommandLine                 As New CCommandLine
Public g_objW3RunnerWebServer           As New CW3RunnerWebServer
Public g_strWelcomePageURL              As String
Public g_objW3RunnerHelp                As New CHelp
Public g_objHelper                      As New CUIHelper
Public g_objHTTP                        As New CHTTP
Public g_objW3RunnerObject              As New W3RunnerApplication
Public g_objIniFile                     As New cIniFile
Public g_objW3RunnerReportBrowser       As New W3RunnerReportBrowser
Public g_objIECache                     As New CIECache

' The mechanism to detect when a page is downloaded is very slow and it does not
' report correctly the download time! So I use this variable to store the result
' at the right moment
Public g_lngWaitForDownLoadArrivedTickCount As Long

Public g_static_booShowProtocolInfo                 As Boolean
Public g_static_lngDemoItemCount                    As Long
Public g_static_lngSlowMode                         As Long
Public g_static_HTMLObjectWindowOpened              As Boolean
Public g_static_strMode                             As String
Public g_static_lngRecordMode                       As Boolean
Public g_static_booCancelScriptIfTimeOut            As Boolean
Public g_static_ScriptFileName                      As String
Public g_static_strDownLoadingURL                   As String
Public g_static_lngMinChildWindowWidth              As Long
Public g_static_lngMinChildWindowHeight             As Long
Public g_static_booUpdateWatchWindow                As Boolean
Public g_static_lngGrabScreenCounter                As Long
Public g_static_strLastDownLoadedURL                As String
Public g_static_booCancelScript                     As Boolean
Public g_static_booRegistered                       As Boolean
Public g_static_strRegistrationInfo                 As String
Public g_static_strRecordFileName                   As String
Public g_static_strTraceEvent                       As String
Public g_static_booAutoFireEvent                    As Boolean
Public g_static_booRecordHTTPProtocol               As Boolean
Public g_static_lngExecutionErrorCounter            As Long
Public g_static_lngExecutionWarningCounter          As Long
Public g_static_strReportBrowserDownLoadingURL      As String



Public Function Wait(dblSecond As Double, Optional eFlags As w3rWAIT_MODE = w3rWAIT_MODE_DEFAULT) As Boolean

    On Error GoTo errmgr
    
    Dim objWinApi   As New cWindows
    Dim lngTime     As Long
    Dim objCursor   As New CWaitCursor: objCursor.Wait Screen
    Dim i           As Long
    
    If CBool(eFlags And w3rWAIT_MODE_NO_SLEEP_API_CALL) Or CBool(eFlags And w3rWAIT_MODE_NO_DOEVENTS_CALL) Then
    
        lngTime = GetTickCount()
        
        Do While GetTickCount() < (lngTime + (dblSecond * 1000))
        
            If Not CBool(eFlags And w3rWAIT_MODE_NO_DOEVENTS_CALL) Then DoEvents: DoEvents: DoEvents: DoEvents: DoEvents: DoEvents: DoEvents
        Loop
    
    Else
        If (dblSecond < 1) Then ' Wait less than one second without any DoEvents
        
            Sleep dblSecond * 1000 ' sleep less than once second
            GlobalDoEvents
        Else
            For i = 1 To CLng(dblSecond)
                W3RunnerWaitOneSecond
                If frmMain.CancelScript Then Exit For
            Next
        End If
    End If
    Wait = True
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), "W3Runner.bas", "Wait"
End Function

Public Function W3RunnerWaitOneSecond() As Boolean
    Dim i As Long
    For i = 1 To 10
        Sleep 100
        GlobalDoEvents
    Next
    W3RunnerWaitOneSecond = True
End Function

Public Sub Main()

    On Error GoTo errmgr
    
    Dim strScriptFileName   As String
    Dim strFunctionName     As String
    Dim i                   As Long
    Dim objTextFile         As New cTextFile
    Dim objWaitCursor       As New CWaitCursor
        
    If ShowCommandLineInfo() Then Exit Sub
    
    Set AppOptionsModule.g_objAppOptionIniFile = g_objIniFile
        
    g_objIniFile.Init Replace(App.path & "\" & W3RUNNER_INI_FILENAME, "\\", "\")
    
    CheckRegistration
    AppInit
    
    objWaitCursor.Wait Screen
        
    If CanShowSplashWindow() Then
    
        frmSplash.Show: frmSplash.Refresh: DoEvents
        frmSplash.Message = W3RUNNER_MSG_07016
    End If
    
    g_objCommandLine.Init Command
    
    If ArgumentExist("-keys") Then ' -- Async SendKeys Mode --
        
        frmSendKeys.SendKeys Arguments("-keys"), CLng(Arguments("-timetowait"))
        Debug.Print "exit"
        Exit Sub
    End If
            
    If g_static_booRegistered Then ' Command line works only if registered
    
        strScriptFileName = Arguments("-file")
        strFunctionName = Arguments("-function")
    End If

    frmSplash.Message = W3RUNNER_MSG_07017
    
    InitApplication
    Load frmMain
    frmMain.LoadInfoAtStartTime
    frmMain.mode = W3RUNNER_MODE_DESIGN
        
    SetWelcomePage
        
    frmMain.Show
        
    If (Len(strScriptFileName)) Then
    
        If (objTextFile.ExistFile(strScriptFileName)) Then
        
            frmMain.OpenNewScript strScriptFileName, False
        Else
            frmMain.TRACE PreProcess(W3RUNNER_ERROR_07027, "FILE", strScriptFileName), w3rERROR
        End If
    End If
    If (Len(strFunctionName)) And (objTextFile.ExistFile(strScriptFileName)) Then
    
        frmMain.tmrCommandLineExecute.Tag = "quit"
        frmMain.CommandLineFunctionToExecute = strFunctionName
    End If
    
    If CanShowSplashWindow() Then
    
        frmSplash.Message = W3RUNNER_MSG_07019
        Unload frmSplash
    End If
    SetFrmMainWidthCommandLineArgument "Left", "Top", "Width", "Height", "FullScreen"
    
    ShowReleaseNote
    
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), "W3Runner.bas", "Main"
End Sub



Public Function FShowError(ByVal strMessage As String, Optional ByVal strModuleName As Variant, Optional strFunctionName As String) As Boolean

    On Error GoTo errmgr
    
    Dim strMessage2 As String
    
    If IsMissing(strModuleName) Then strModuleName = ""
    
    If IsObject(strModuleName) Then strModuleName = TypeName(strModuleName)

    strMessage2 = PreProcess(strMessage, "CRLF", vbNewLine)
    
    If (Len(strModuleName)) Then
    
        strMessage2 = strMessage2 & vbNewLine & "Module=" & strModuleName & " Function=" & strFunctionName
    End If
    Screen.MousePointer = 0
    frmMain.TRACE Replace(strMessage2, vbNewLine, "."), w3rERROR, False
    frmMsgbox.OpenDialog strMessage2
    
    Exit Function
errmgr:
    Dim strErrorErrorMessage As String
    
    strErrorErrorMessage = PreProcess(W3RUNNER_ERROR_07050, "CRLF", vbNewLine, "ERROR1", strMessage2, "ERROR2", GetVBErrorString())
    ClipBoard.Clear
    ClipBoard.SetText strErrorErrorMessage
    MsgBox strErrorErrorMessage, vbCritical + vbOKOnly, "FShowError() Error Handler"
End Function

'Public Function GetSlowMode() As Boolean
'    GetSlowMode = AppOptions("chkSlowMode") = "1"
'End Function

Public Function GlobalDoEvents() As Boolean
    'Dim i As Long
    'Sleep 1
    DoEvents
End Function

Public Function Arguments(ByVal strName As String, Optional ByVal varDefaultValue As Variant) As Variant

    Dim i As Long
    
    For i = 1 To g_objCommandLine.Count
    
        If UCase(g_objCommandLine.Item(i)) = UCase(strName) Then
            
            Arguments = g_objCommandLine.Item(i + 1)
            Exit Function
        End If
    Next
    If IsMissing(varDefaultValue) Then varDefaultValue = Empty ' because MISSING is not supported by VBScript
    Arguments = varDefaultValue
End Function


Public Function ArgumentExist(ByVal strName As String) As Boolean
        Dim i As Long
        For i = 1 To g_objCommandLine.Count
        
            If UCase(g_objCommandLine.Item(i)) = UCase(strName) Then
                
                ArgumentExist = True
                Exit Function
            End If
        Next
End Function


Public Function GetFrame(ByVal objHTMLDoc As Variant, ByVal strFrameName As String) As Object

    On Error GoTo errmgr

    Dim i               As Long
    Dim objFrame        As Object
    Dim h               As HTMLWindow2
    
    Set GetFrame = Nothing
    strFrameName = UCase$(strFrameName)
    
    ' Search in the current doc
    For i = 0 To objHTMLDoc.frames.Length - 1
    
        Set h = objHTMLDoc.frames(i)
        If (UCase(objHTMLDoc.frames(i).Name) = strFrameName) Then
        
            Set GetFrame = objHTMLDoc.frames(i)
            Exit Function
        End If
    Next
    
    ' Search in each frame of the current doc
    For i = 0 To objHTMLDoc.frames.Length - 1
    
        If (objHTMLDoc.frames(i).Length) Then
        
            Set objFrame = GetFrame(objHTMLDoc.frames(i), strFrameName)
            
            If IsValidObject(objFrame) Then
            
                Set GetFrame = objFrame
                Exit Function
            End If
        End If
    Next
    Exit Function
errmgr:
    If Err.Number = W3RUNNER_ERROR_07029_COM_ERROR Then

        FShowError W3RUNNER_ERROR_07029
    Else
        FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), "W3RunnerMod.bas", "GetFrame(""" & strFrameName & """)"
    End If
    
End Function


Public Function tbEnableAll(t As ToolBar, booEnabled As Boolean) As Boolean

    Dim v As Variant
    
    For Each v In t.Buttons
    
        v.Enabled = booEnabled
    Next
    tbEnableAll = True
End Function



Public Function GetW3RunnerTraceString(eMode As eW3RunnerTraceMode) As String

    Dim s As String

    
    Select Case eMode
        Case w3rTRACEHTTP: s = "HTTP"
        Case w3rWEBSERVICE: s = "WEBSERVICE"
        Case w3rINFO: s = "INFO"
        Case w3rERROR: s = "ERROR"
        Case w3rWARNING: s = "WARNING"
        Case w3rSQL: s = "SQL"
        Case w3rURL_DOWNLOADED: s = "URL_DOWNLOADED"
        Case w3rMEMORY: s = "MEMORY"
        Case w3rDEBUG: s = "DEBUG"
        Case w3rINTERNAL: s = "INTERNAL"
        Case w3rMETHOD: s = "METHOD"
        Case w3rJAVASCRIPT: s = "JAVASCRIPT"
        Case w3rSUCCESS: s = "SUCCEED"
        Case w3rCLEAR_TRACE: s = "CLEAR_TRACE"
        Case w3rPERFORMANCE: s = "PERFORMANCE"
        Case Else
            s = "UNKNOWN"
    End Select
    GetW3RunnerTraceString = s

End Function




'   Public Const GW_HWNDNEXT = 2
'   Public Const GW_CHILD = 5
'   Public Declare Function GetWindow Lib "user32" (ByVal hwnd As Long, ByVal wCmd As Long) As Long
'   Public Declare Function GetClassName Lib "user32" Alias "GetClassNameA" (ByVal hwnd As Long, ByVal lpClassName As String, ByVal nMaxCount As Long) As Long



Public Function RunSlowMode() As Boolean

    If g_static_lngSlowMode Then Sleep g_static_lngSlowMode
    RunSlowMode = True
End Function



Public Function IsW3RunnerHTMLObjectSupported(o As Object) As Boolean
    'IsW3RunnerHTMLObjectSupported = InStr(UCase$(AppOptions("IEObjectsTypeSupported", W3RUNNER_IEOBJECTSTYPESUPPORTED)), UCase$(TypeName(o)))
    IsW3RunnerHTMLObjectSupported = True
End Function

Public Function SetHTMLObjectCursorPos(frm As frmMain, o As Object, Optional strFrame As String, Optional lngOffSetX As Long, Optional lngOffSetY As Long) As Boolean
    Dim x As Long
    Dim Y As Long
    
    On Error GoTo errmgr
    
    If lngOffSetX Or lngOffSetY Then

        If (GetHTMLObjectPos(x, Y, frm, o, strFrame, eGetHTMLObjectPosType_ABSOLUTE_LEFT_TOP)) Then
        
            If frm.IsPointInWebBrowser(x + lngOffSetX, Y + lngOffSetY) Then
            
                SetCursorPos x + lngOffSetX, Y + lngOffSetY
                SetHTMLObjectCursorPos = True
            End If
        End If
    Else
    
        If (GetHTMLObjectPos(x, Y, frm, o, strFrame, eGetHTMLObjectPosType_MIDDLE)) Then
        
            If frm.IsPointInWebBrowser(x, Y) Then
            
                SetCursorPos x, Y
                SetHTMLObjectCursorPos = True
            End If
        End If
    End If
    Exit Function
errmgr:

    Debug.Assert 0
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), "W3RunnerMod.bas", "SetHTMLObjectCursorPos"
End Function

Public Function GetHTMLObjectPos(ByRef x As Long, ByRef Y As Long, frm As frmMain, o As Object, strFrame As String, eType As eGetHTMLObjectPosType) As Boolean
    Dim r       As IHTMLRect
    Dim r2      As IHTMLRect
    
    Dim pLeft   As Long
    Dim pTop    As Long
    Dim a       As HTMLMapElement
    Dim objBody As HTMLBody
    
    ' getBoundingClientRect() does not return the right
    ' info for a HTMLAreaElement...
    
    Set r = o.getBoundingClientRect()
    If r.Left = 0 And r.Top = 0 Then
        'Debug.Assert 0
    End If
    
    ' Get the parent position if frame or not
    If Not GetHTMLObjectParentPosition(frm, frm.HTMLDoc, strFrame, pLeft, pTop) Then
        Exit Function
    End If
        
    Select Case eType
        
        Case eGetHTMLObjectPosType_ABSOLUTE_LEFT_TOP
            x = pLeft + r.Left
            Y = pTop + r.Top
            
        Case eGetHTMLObjectPosType_MIDDLE ' Screen Absolute Pos
            x = pLeft + r.Left + ((r.Right - r.Left) \ 2)
            Y = pTop + r.Top + ((r.Bottom - r.Top) \ 2)
            
        Case eGetHTMLObjectPosType_LEFT_TOP ' pos Relative to the parent
            x = pLeft + r.Left - frm.WebBrowserLeft()
            If x < 0 Then x = 0
            
            Y = pTop + r.Top - frm.WebBrowserTop()
            If Y < 0 Then Y = 0

    End Select
    GetHTMLObjectPos = True
End Function


Public Function EndOfDemo() As Boolean
    FShowError W3RUNNER_MSG_07027
    EndOfDemo = True
    End
End Function



Public Function QuickLongFieldValidation(t As TextBox, KeyAscii As Integer, Optional lngMaxSize As Long) As Boolean

    QuickLongFieldValidation = True

    If KeyAscii = Asc(vbBack) Then Exit Function
    If KeyAscii >= Asc("0") And KeyAscii <= Asc("9") Then
        If (lngMaxSize) Then
            If Len(t.Text) >= lngMaxSize Then
                GoTo CancelCHAR
            End If
        End If
    Else
        GoTo CancelCHAR
    End If
    Exit Function
CancelCHAR:
    KeyAscii = 0
    QuickLongFieldValidation = False
    Exit Function
End Function

Public Function GetW3RunnerLogFileName() As String
    GetW3RunnerLogFileName = Environ("TEMP") & "\" & W3RUNNER_EXE_FILE_NAME & ".log.csv"
End Function

Public Function InitApplication() As Boolean

    Dim lngUsage    As Long
    Dim objWinApi   As New cWindows
    
    'Debug.Assert 0
    lngUsage = AppOptions("UsageCounter", CLng(0))
    lngUsage = lngUsage + 1
    AppOptions("UsageCounter") = lngUsage
    
    If Len(AppOptions("InstallID")) = 0 Then
        AppOptions("InstallID") = objWinApi.CreateGUIDKey()
    End If
    If g_objHTTP.Initialize() <> CHTTP_ERROR_OK Then
    
        FShowError W3RUNNER_ERROR_07034, "W3RunnerMod", "InitApplication"
    End If
    InitApplication = True
'    #If DEMO Then
'        Dim objW3RunnerComServer As New CW3RunnerComServer
'        objW3RunnerComServer.Initialize
'    #End If
    
End Function



Public Function GetCountry() As String

   Dim lngLocale    As Long
   Dim strCountry   As String
   Dim iRet1        As Long
   
   strCountry = Space(255)
   
   lngLocale = GetUserDefaultLCID()
   iRet1 = GetLocaleInfo(lngLocale, LOCALE_SENGCOUNTRY, strCountry, Len(strCountry))
    GetCountry = Mid(strCountry, 1, iRet1 - 1)

End Function


Public Function CloseAllFormExceptFrmMainForm() As Boolean

    Dim booContinue  As Boolean
    Dim i As Long
    
    booContinue = True
    
    Do While booContinue
    
        booContinue = False
        
        For i = 0 To Forms.Count - 1
        
            If Forms(i).Name = "frmMain" Then

                If Forms(i).IsChild Then

                    GoSub UnloadForm
                    Exit For
                End If
            Else
                GoSub UnloadForm
                Exit For
            End If

        Next
    Loop
    CloseAllFormExceptFrmMainForm = True
    Exit Function
UnloadForm:
    Debug.Print "UNLOAD FORM " & Forms(i).Name
    Unload Forms(i)
    GlobalDoEvents
    booContinue = True
    Return
End Function

Public Function IsFormOpen(strName As String) As Boolean
        
    Dim i As Long
    
    For i = 0 To Forms.Count - 1
        If UCase$(strName) = UCase$(Forms(i).Name) Then
            IsFormOpen = True
        End If
    Next
End Function

Public Function CloseSplashWindowIfOpen() As Boolean
    If IsFormOpen("frmSplash") Then
        Unload frmSplash
    End If
    CloseSplashWindowIfOpen = True
End Function




Public Function GetURLFileName(ByVal strURL As String) As String
    Dim lngPos          As Long
    Dim objTextFile     As New cTextFile
    
    If InStr(strURL, "http") Then
    
        lngPos = InStr(strURL, "?")
        If (lngPos) Then
            strURL = Mid(strURL, 1, lngPos - 1) ' Remove the parameter
        End If
        If Right(strURL, 1) = "/" Then
            strURL = strURL
        Else
            strURL = objTextFile.GetFileName(strURL, "/")
        End If
    End If
    GetURLFileName = strURL
End Function

Public Function SetFrmMainWidthCommandLineArgument(ParamArray Properties() As Variant) As Boolean

    Dim i As Long
    Dim v As Variant
    
    For i = 0 To UBound(Properties())
    
        If ArgumentExist("-" & Properties(i)) Then
        
            Select Case UCase(Properties(i))
            
                Case "LEFT":
                    UnMaximizeFrmMain
                    frmMain.Left = CLng(Arguments("-" & Properties(i))) * Screen.TwipsPerPixelX
                Case "TOP":
                    UnMaximizeFrmMain
                    frmMain.Top = CLng(Arguments("-" & Properties(i))) * Screen.TwipsPerPixelY
                Case "WIDTH":
                    UnMaximizeFrmMain
                    frmMain.Width = CLng(Arguments("-" & Properties(i))) * Screen.TwipsPerPixelX
                Case "HEIGHT":
                    UnMaximizeFrmMain
                    frmMain.Height = CLng(Arguments("-" & Properties(i))) * Screen.TwipsPerPixelY
                Case "FULLSCREEN":
                    frmMain.FullScreen = Arguments("-" & Properties(i))
            End Select
        End If
    Next
End Function

Public Function GetCaptionMenuHeight(f As frmMain) As Long
    GetCaptionMenuHeight = f.GetBrowserInfo(GetBrowserInfo_MENU_HEIGHT)
End Function

Public Function CheckRegistration() As Boolean

    Dim objHelper   As New CUIHelper
    Dim objKey      As Object
    Dim strKey      As String
    Dim objESellRate As New CESellRate
    Dim strCompanyName As String
    Dim strCompanyNameCrypted As String
    
    

    g_static_booRegistered = False
    
    strKey = AppOptions("RK")
    
    If (Len(strKey)) Then
        
        strCompanyNameCrypted = AppOptions("CN")
        If Len(strCompanyNameCrypted) = 0 Then

            strCompanyName = InputBox(W3RUNNER_MSG_07044)
            If g_objCryptor.Crypte(strCompanyName, strCompanyNameCrypted) Then AppOptions("CN") = strCompanyNameCrypted
        End If
        
        If g_objCryptor.DeCrypte(strCompanyNameCrypted, strCompanyName) Then
        
            If objESellRate.Validate(strKey, strCompanyName, True) Then

                'AppOptions("CE") = strCompanyNameEMail
                g_static_booRegistered = True
                g_static_strRegistrationInfo = strCompanyName & vbNewLine & strKey

                ' Save the crypted serial number name value
                AppOptions("CN") = strCompanyNameCrypted
            Else
                RegistrationClearSerialNumberName
                FShowError W3RUNNER_ERROR_07021 'W3RUNNER_ERROR_07039
                Exit Function
            End If
        Else
            RegistrationClearSerialNumberName
            FShowError W3RUNNER_ERROR_07028 'W3RUNNER_ERROR_07039
            Exit Function
        End If
    End If

    CheckRegistration = True
End Function

Public Function CanShowSplashWindow() As Boolean
    CanShowSplashWindow = CBool(Len(Command) = 0) 'Or CBool(Trim(UCase(Command)) = "-I")
End Function



Public Function GetMaxTrialItem() As Long
    GetMaxTrialItem = TRIAL_MAX_UI_ITEM_BASE_2 + 2
End Function

Public Function AppDebugMode() As Boolean
    AppDebugMode = ArgumentExist("-appdebug")
End Function

Public Property Get RecordFileName() As String
    RecordFileName = g_static_strRecordFileName
End Property

Public Property Let RecordFileName(ByVal vNewValue As String)
    g_static_strRecordFileName = vNewValue
End Property

Public Function GetW3RunnerVersion(booFull As Boolean) As String
    GetW3RunnerVersion = App.Major & "." & App.Minor & IIf(booFull, "." & App.Revision, "")
End Function

Public Function GetRecordFileCommentHeader() As String
    Dim objWinApi           As New cWindows
    Dim objVBScript         As New CVBScript
    
    GetRecordFileCommentHeader = PreProcess(W3RUNNER_MSG_07032, "NOW", Now(), "AUTHOR", objWinApi.UserName, "OS", objVBScript.WindowsVersion(), "BROWSER", objVBScript.WebBrowserVersion(), "CRLF", vbNewLine, "LINE", String(64, "-"), "W3RUNNER_VERSION", GetW3RunnerVersion(True), "SMALLLINE", String(64, "."))
           
End Function

Public Function LoadWelcomePage() As Boolean

    
    frmMain.WebBrowser.Navigate g_strWelcomePageURL
    
    LoadWelcomePage = True
End Function

Public Function GotoW3RunnerWebSite()
    On Error GoTo errmgr
    Dim objTool As New cTool
    objTool.ExecFile W3RunnerWebSiteURL()
    Exit Function
errmgr:
End Function

Public Function W3RunnerWebSiteURL() As String
    W3RunnerWebSiteURL = HTTP_W3RUNNER_SERVER_NAME
End Function

Public Function DEBUGLOG(strS As String) As Boolean

    If AppDebugMode() Then frmMain.TRACE strS, w3rDEBUG
End Function

Private Function AppInit() As Boolean

    ReDim eW3RunnerEnvironmentInfoStrings(w3rENVIRONMENT_MAX_VALUE)
    
    eW3RunnerEnvironmentInfoStrings(w3rW3RUNNER_VERSION) = "w3rW3RUNNER_VERSION"
    eW3RunnerEnvironmentInfoStrings(w3rWEB_BROWSER_VERSION) = "w3rWEB_BROWSER_VERSION"
    eW3RunnerEnvironmentInfoStrings(w3rWINDOWS_SCRIPT_HOST_VERSION) = "w3rWINDOWS_SCRIPT_HOST_VERSION"
    eW3RunnerEnvironmentInfoStrings(w3rVBSCRIPT_ENGINE_VERSION) = "w3rVBSCRIPT_ENGINE_VERSION"
    eW3RunnerEnvironmentInfoStrings(w3rVBSCRIPT_DEBUG_MODE) = "w3rVBSCRIPT_DEBUG_MODE"
    eW3RunnerEnvironmentInfoStrings(w3rWINDOWS_VERSION) = "w3rWINDOWS_VERSION"
    eW3RunnerEnvironmentInfoStrings(w3rCOMPUTER_NAME) = "w3rCOMPUTER_NAME"
    eW3RunnerEnvironmentInfoStrings(w3rUSER_NAME) = "w3rUSER_NAME"
    eW3RunnerEnvironmentInfoStrings(w3rW3RUNNER_PATH) = "w3rW3RUNNER_PATH"
    eW3RunnerEnvironmentInfoStrings(w3rRESERVED_W3RUNNER_WEBSERVER_IP) = "w3rRESERVED"

    g_static_booAutoFireEvent = True
    g_static_booUpdateWatchWindow = True
    g_static_booCancelScriptIfTimeOut = True
    g_static_lngSlowMode = 1
    g_lngWaitForDownLoadArrivedTickCount = -1
    AppInit = True
    
End Function

Public Function GetW3RunnerComboBoxURLHistoryFileName() As String
    GetW3RunnerComboBoxURLHistoryFileName = App.path & "\W3Runner.URL.History.txt"
End Function

Public Function InitWelcomePageURL() As Boolean

    ' The global page is downloaded
    If g_objW3RunnerWebServer.CheckURL(g_objW3RunnerWebServer.GetWebServiceURL(W3RUNNER_WEBSERVICE_WELCOME)) Then
    
        g_strWelcomePageURL = g_objW3RunnerWebServer.GetWebServiceURL(W3RUNNER_WEBSERVICE_WELCOME)
    Else
        g_strWelcomePageURL = g_objW3RunnerWebServer.GetWebServiceURL(W3RUNNER_WEBSERVICE_LOCAL_WELCOME)
    End If
    InitWelcomePageURL = True
End Function

Public Function GetImageNameAssociatedWithMap(HTMLDoc As HTMLDocument, ByVal strMapName As String, strFrameName As String, ByRef strImageName As String) As Boolean
            
    Dim eCollection             As IHTMLElementCollection
    Dim strMapNameWithImage     As String
    Dim i                       As Long
    Dim a                       As Object
    
    
    strMapName = UCase$(strMapName)
    
    If (Len(strFrameName)) Then
    
        Set eCollection = GetFrame(HTMLDoc, strFrameName).Document.All
    Else
        Set eCollection = HTMLDoc.All
    End If
    
    For i = 0 To eCollection.Length - 1
    
        Set a = eCollection.Item(i)
        
        If UCase$(TypeName(a)) = "HTMLIMG" Then
            
            strMapNameWithImage = UCase$(g_objHelper.GetHTMLObjectProperty(a, "useMap"))
            If "#" & strMapName = strMapNameWithImage Then
            
                strImageName = g_objHelper.GetHTMLObjectName(a)
                GetImageNameAssociatedWithMap = True
                Exit Function
            End If
        End If
    Next
        
End Function

Public Function GetHTMLObjectParentPosition(frm As frmMain, HTMLDoc As HTMLDocument, strFrame As String, ByRef pLeft As Long, ByRef pTop As Long) As Boolean

    Dim f As HTMLWindow2

    If Len(strFrame) Then

        Set f = GetFrame(HTMLDoc, strFrame) ' Always start from the top - so here we use frmMain
            
        If IsValidObject(f) Then
        
            pTop = f.screenTop
            pLeft = f.screenLeft
            GetHTMLObjectParentPosition = True
            
            ' #FRAME
            
            If IsValidObject(f.Parent) Then ' -- test if the frame has a parent --
            
                If LCase(f.Parent.location.href) = LCase(HTMLDoc.location.href) Then
                    ' The frame belong to the top
                Else
                    ' The frame belong to another frame
                    'Debug.Assert 0
                End If
            End If
            
        End If
    Else
        pLeft = frm.WebBrowserLeft()
        pTop = frm.WebBrowserTop()
        GetHTMLObjectParentPosition = True
    End If
    

End Function

Public Function ShowReleaseNote() As Boolean

    Dim t               As New cTool
    Dim objTextFile     As New cTextFile
    Dim strFileName     As String
    
    DoEvents
    
    strFileName = Replace(App.path & "\ReleaseNotes.htm", "\\", "\")
    
    If AppOptions("ReleaseNotesViewed", "0") = "0" Then
    
        AddShortcutToDesktop
        
        If objTextFile.ExistFile(strFileName) Then
        
            t.ExecFile strFileName
            ShowReleaseNote = True
            AppOptions("ReleaseNotesViewed") = True
            
        Else
            FShowError PreProcess(W3RUNNER_ERROR_07032, "FILE", strFileName), "W3RunnerMod.bas", "ShowReleaseNote"
        End If
    End If
    ShowReleaseNote = True

End Function


Public Property Get TraceEvent() As String
    TraceEvent = g_static_strTraceEvent
End Property

Public Property Let TraceEvent(ByVal v As String)
    g_static_strTraceEvent = v
End Property

Public Function LOG_DEBUG_STRING(s As String) As Boolean

    #If DEBUG_ Then
        Dim objTextFile As New cTextFile
        objTextFile.LogFile App.path & "\W3Runner.Debug.log", s
        Debug.Print s
    #End If
End Function



Public Function StuffToDoForAfterEachMethod() As Boolean
    GlobalDoEvents
    RunSlowMode
End Function

Public Function ShowCommandLineInfo() As Boolean
        
    If Command = "?" Or Command = "/?" Or Command = "/h" Or Command = "/H" Then ' -- Chech for help
    
        MsgBox PreProcess(W3RUNNER_MSG_07003, "APP_TITLE", APP_TITLE)
        ShowCommandLineInfo = True
        Exit Function
    End If
End Function

Public Function UnMaximizeFrmMain() As Boolean
    If frmMain.WindowState = vbMaximized Then
        frmMain.WindowState = vbNormal
    End If
    UnMaximizeFrmMain = True
End Function


Public Function RegistrationClearSerialNumberName() As Boolean
    AppOptions("CN") = "" ' Force to reset the serial number name
    RegistrationClearSerialNumberName = True
End Function



Public Function AddShortcutToDesktop() As Boolean

    Dim WshShell, oShellLink
    Dim strDesktop          As String
    Dim strLnkFileName      As String
    
    On Error GoTo errmgr
    
    AddShortcutToDesktop = True
    
    If (MsgBox(W3RUNNER_MSG_07047, vbYesNo + vbQuestion) = vbNo) Then Exit Function
    
    Set WshShell = CreateObject("Wscript.Shell")
    strDesktop = WshShell.SpecialFolders("Desktop")
    
    strLnkFileName = strDesktop + "\W3Runner " & GetW3RunnerVersion(True) & ".lnk"
    
    Set oShellLink = WshShell.CreateShortcut(strLnkFileName) 'Create a WshShortcut Object
    
    oShellLink.TargetPath = Replace(App.path & "\" & App.EXEName & ".exe", "\\", "\")
        
    'Set the additional parameters for the shortcut
    'oShellLink.Arguments = App.Path & "\" & App.EXEName & ".exe"
    
    'Save the shortcut
    oShellLink.Save
    
    If Not g_objTextFile.ExistFile(strLnkFileName) Then
        FShowError PreProcess(W3RUNNER_ERROR_07053, "FILENAME", strLnkFileName), "W3RunnerMod.bas", "AddShortcutToDesktop"
    End If
    
    'Clean up the WshShortcut Object
    Set oShellLink = Nothing
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), "W3Runner.bas", "AddShortcutToDesktop"
End Function





Public Function FreeGlobalObject() As Boolean

On Error GoTo errmgr

    #If RECORD_MODE_ Then
        Set g_objIEEventFilter = Nothing
    #End If
    
    Set g_objTextFile = Nothing
    Set g_objCommandLine = Nothing
    Set g_objW3RunnerWebServer = Nothing
    Set g_objW3RunnerHelp = Nothing
    Set g_objHelper = Nothing
    Set g_objHTTP = Nothing
    Set g_objW3RunnerObject = Nothing
    Set g_objIniFile = Nothing
    
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), "W3RunnerMod.bas", "FreeGlobalObject"
End Function


Public Function IsTraceHTTPOn() As Boolean
    IsTraceHTTPOn = AppOptions("TraceType" & w3rTRACEHTTP, "") = "1"
End Function


Public Function SetWelcomePage() As Boolean
    
    If g_static_booRegistered Then  ' If the guy paid we do not bother him with the welcome page...
    
        If AppOptions("HomePage") = "" Then
        
            g_strWelcomePageURL = "about:blank"
            
        ElseIf AppOptions("HomePage") = W3RUNNER_DEFAULT_HOME_PAGE_COMMAND Then
            
            GoSub ShowLoadWelcomePage
            InitWelcomePageURL
        Else
            GoSub ShowLoadWelcomePage
            g_strWelcomePageURL = AppOptions("HomePage")
        End If
    Else
        GoSub ShowLoadWelcomePage
        
        If Not IsEmpty(g_objW3RunnerWebServer.IP) Then
            
            InitWelcomePageURL
        Else
            g_strWelcomePageURL = g_objW3RunnerWebServer.GetWebServiceURL(W3RUNNER_WEBSERVICE_LOCAL_WELCOME)
        End If
    End If
    LoadWelcomePage
    Exit Function
    
ShowLoadWelcomePage:
    frmSplash.Message = W3RUNNER_MSG_07018
Return
End Function


Public Function CheckToEndTrialVersion() As Boolean
       
    If Not g_static_booRegistered Then
    
        g_static_lngDemoItemCount = g_static_lngDemoItemCount + 1
        
        If g_static_lngDemoItemCount > GetMaxTrialItem() Then
        
            EndOfDemo
        End If
    End If
End Function



