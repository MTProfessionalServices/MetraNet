VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "W3RunnerApplication"
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
'  DATE         : 12/xx/2001
'  DESCRIPTION  : IMPLEMENT THE SCREEN OBJECT AND THE W3RUNNER OBJECT!
'  VERSION      : none.
'
' ****************************************************************************************************************************************************

Option Explicit

Public Enum GET_WINDOWS_OBJECTS_FLAGS
    GET_WINDOWS_OBJECTS_FLAGS_NONE = 0
    GET_WINDOWS_OBJECTS_FLAGS_FOREGROUND_WINDOW = 1
End Enum


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Arguments(ByVal strName As String, Optional ByVal varDefaultValue As Variant) As Variant

    On Error GoTo errmgr
    Arguments = W3RunnerMod.Arguments(strName, varDefaultValue)
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Arguments"
End Property

Public Property Get WinApi() As cWindows
    Set WinApi = g_objWinApi
End Property

Public Property Get TextFile() As cTextFile
    Set TextFile = g_objTextFile
End Property

Public Property Get ClipBoard() As VB.ClipBoard
    Set ClipBoard = VB.ClipBoard
End Property

Public Property Get Width() As Long
    Width = Screen.Width
End Property

Public Property Get Height() As Long
    Height = Screen.Height
End Property

Public Property Get Fonts(ByVal lngIndex As Long) As String
    Fonts = Screen.Fonts(lngIndex)
End Property

Public Property Get TwipsPerPixelX() As Long
    TwipsPerPixelX = Screen.TwipsPerPixelX
End Property

Public Property Get TwipsPerPixelY() As Long
    TwipsPerPixelY = Screen.TwipsPerPixelY
End Property

Public Property Get FontCount() As Long
    FontCount = Screen.FontCount
End Property

Public Property Get CurrentX() As Long

    Dim objWin  As New cWindows
    Dim lngX    As Long
    Dim lngY    As Long
    
    objWin.cursorPos lngX, lngY
    CurrentX = lngX
End Property

Public Property Get CurrentY() As Long

    Dim objWin  As New cWindows
    Dim lngX    As Long
    Dim lngY    As Long
    
    objWin.cursorPos lngX, lngY
    CurrentY = lngY
End Property

Public Property Let CurrentX(ByVal lngX As Long)
    frmMain.TRACE PreProcess("Screen.CurrentX = [VALUE]", "VALUE", lngX), w3rMETHOD
    SetCursorPos lngX, CurrentY
End Property

Public Property Let CurrentY(ByVal lngY As Long)
    frmMain.TRACE PreProcess("Screen.CurrentY = [VALUE]", "VALUE", lngY), w3rMETHOD
    SetCursorPos CurrentX, lngY
End Property


Public Function SendChars(ByVal lngHWND As Long, ByVal strChars As String, Optional ByVal strSender As String = "Screen") As Boolean

    Dim objWin As New cWindows
    
    frmMain.TRACE PreProcess(strSender & ".SendChars [DC][VALUE][DC]", "VALUE", strChars, "DC", """"), w3rMETHOD
    SendChars = objWin.SendCharString(lngHWND, strChars)
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function SendKeys(ByVal strKeys As String, Optional booWait As Boolean = False, Optional booNewProcess As Boolean = False, Optional lngTimeToWait As Long = 1, Optional strTraceObject As String = "Screen") As Boolean

    On Error GoTo errmgr
    
    frmMain.TRACE PreProcess(strTraceObject & ".SendKeys([DC][STRKEYS][DC],[BOOWAIT],[BOONEWPROCESS],[LNGTIMETOWAIT])", "DC", """", "STRKEYS", strKeys, "BOOWAIT", booWait, "BOONEWPROCESS", booNewProcess, "LNGTIMETOWAIT", lngTimeToWait), w3rMETHOD
    
    If (booNewProcess) Then
        Shell App.path & "\" & App.EXEName & ".exe -keys """ & strKeys & """ -timetowait " & (lngTimeToWait * 1000)
    Else
        VBA.SendKeys strKeys, booWait
    End If
    SendKeys = True
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "SendKeys"
End Function


Public Function AppActivate(ByVal strTitle As String, Optional booWait As Boolean = False) As Boolean

    VBA.AppActivate strTitle, booWait
    AppActivate = True
End Function

Public Function Execute(ByVal strProgram As String, Optional ByVal strParameters As String, Optional ByVal eAppWinStyle As VbAppWinStyle = vbNormalFocus, Optional ByVal booSynchronous As Boolean = False, Optional ByRef varAppId As Variant, Optional ByRef varAppHWND As Variant, Optional ByVal lngWaitTime As Long = 1, Optional ByVal strWindowClassName As String) As Boolean

    Dim objTool         As New cTool
    Dim lngProcessID    As Long
    Dim objWinApi       As New cWindows
    Dim strTrace        As String
    strTrace = PreProcess("Screen.Execute([DC][PROGRAM][DC],[PARAM],[EAPPWINSTYLE],[SYNCHRONOUS],[APPHWND])", "DC", """", "PROGRAM", strProgram, "PARAM", strParameters, "EAPPWINSTYLE", eAppWinStyle, "SYNCHRONOUS", booSynchronous, "APPHWND", IIf(IsMissing(varAppHWND), "", "varAppHWND"))
    strTrace = Replace(strTrace, ",)", ")")
    frmMain.TRACE strTrace, w3rMETHOD
    
    On Error GoTo errmgr
    
    If booSynchronous Then
        Execute = objTool.execPrgSyncrone(strProgram, strParameters, eAppWinStyle)
    Else
        lngProcessID = Shell(Trim(strProgram & " " & strParameters), eAppWinStyle)
        
        If Not IsMissing(varAppId) Then
            varAppId = lngProcessID
        End If
        
        ' Return the hwnd of the current app
        If Not IsMissing(varAppHWND) Then
        
            DoEvents
            cWindowsModule.Sleep lngWaitTime * 1000
            DoEvents
            varAppHWND = objWinApi.GetWinHandle(lngProcessID, strWindowClassName)
        End If
        Execute = True
    End If
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Execute"
End Function


Public Function SendMessage(ByVal lngHWND As Long, ByVal lngMESSAGE As Long, Optional ByVal lngWPARAM As Long, Optional ByVal lngLPARAM As Long, Optional booPost As Boolean = False, Optional booTrace As Boolean = True, Optional strName As String = "Screen") As Long

    On Error GoTo errmgr

    If booTrace Then
        frmMain.TRACE strName & PreProcess(".SendMessage([HWND],[MESSAGE],[WPARAM],[LPARAM],[POST])", "HWND", lngHWND, "MESSAGE", lngMESSAGE, "WPARAM", lngWPARAM, "LPARAM", lngLPARAM, "POST", booPost), w3rMETHOD
    End If
    
    If booPost Then
        
        SendMessage = PostMessage(lngHWND, lngMESSAGE, lngWPARAM, ByVal lngLPARAM)
    Else
        SendMessage = cWindowsModule.SendMessage(lngHWND, lngMESSAGE, lngWPARAM, ByVal lngLPARAM)
    End If
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "SendMessage"
End Function

Public Property Get Objects(ByVal lngHWND As Long, Optional ByVal eFlags As GET_WINDOWS_OBJECTS_FLAGS = GET_WINDOWS_OBJECTS_FLAGS_NONE) As CHWNDWindowsObject

    Dim o As CHWNDWindowsObject
    
    If eFlags And GET_WINDOWS_OBJECTS_FLAGS_FOREGROUND_WINDOW Then
    
        lngHWND = GetForegroundWindow()
    End If
    
    Set o = New CHWNDWindowsObject
    o.HWND = lngHWND
        
    'If o.Connect() Then ' the windows has a W3Runner ActiveX
   '
   '     o.axGetControlsInfo
   ' End If
    Set Objects = o
End Property


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Wait(ByVal dblSecond As Double, Optional eFlags As w3rWAIT_MODE = w3rWAIT_MODE_DEFAULT) As Boolean

    On Error GoTo errmgr
    
    If eFlags = w3rWAIT_MODE_DEFAULT Then
        TRACE "W3Runner.Wait " & dblSecond, w3rMETHOD
    Else
        TRACE "W3Runner.Wait " & dblSecond & "," & eFlags, w3rMETHOD
    End If
    
    Wait = W3RunnerMod.Wait(dblSecond, eFlags)
    GlobalDoEvents
    
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Wait"
End Function






Public Function Format(ByVal vExpression As Variant, ByVal vFormat As String, Optional ByVal firstdayofweek As VbDayOfWeek = vbSunday, Optional ByVal firstweekofyear As VbFirstWeekOfYear = vbFirstJan1) As Variant

    On Error GoTo errmgr

    Format = VBA.Format(vExpression, vFormat, firstdayofweek, firstweekofyear)

    Exit Function
errmgr:
    
End Function



Public Property Get AutoFocus() As Boolean

    On Error GoTo errmgr
    
    AutoFocus = CBool(AppOptions("AutoFocus", False))
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "AutoFocus"
End Property

Public Property Let AutoFocus(ByVal vNewValue As Boolean)

    On Error GoTo errmgr
    
    TRACE PreProcess("W3Runner.AutoFocus = [VALUE]", "VALUE", vNewValue), w3rMETHOD
    AppOptions("AutoFocus", , False) = Abs(vNewValue)
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "AutoFocus"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get CancelScriptIfTimeOut() As Boolean
    CancelScriptIfTimeOut = g_static_booCancelScriptIfTimeOut
End Property

Public Property Let CancelScriptIfTimeOut(ByVal vNewValue As Boolean)

    TRACE "W3Runner.CancelScriptIfTimeOut = " & vNewValue, w3rMETHOD
    g_static_booCancelScriptIfTimeOut = vNewValue
End Property


Public Property Get CommandLine() As CCommandLine
    Set CommandLine = g_objCommandLine
End Property


Public Property Get WarningCounter() As Long
        WarningCounter = g_static_lngExecutionWarningCounter
End Property

Public Property Let WarningCounter(ByVal v As Long)
    g_static_lngExecutionWarningCounter = v
End Property

Public Property Get ErrorCounter() As Long
        ErrorCounter = g_static_lngExecutionErrorCounter
End Property

Public Property Let ErrorCounter(ByVal v As Long)
    g_static_lngExecutionErrorCounter = v
End Property



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function MsgBox(ByVal strMessage As String, Optional strTitle As String, Optional ByVal booTrace As Boolean = True) As Boolean

    On Error GoTo errmgr
    If booTrace Then
        TRACE PreProcess("W3Runner.MsgBox([DC][STRMESSAGE][DC],[DC][STRTITLE][DC]", "DC", """", "STRMESSAGE", strMessage, "STRTITLE", strTitle), w3rMETHOD
    End If
    MsgBox = frmMsgbox.OpenDialog(strMessage, strTitle)
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "MsgBox"
End Function

Public Property Get MsgBoxTimeOut() As Long
    MsgBoxTimeOut = AppOptions("MsgBoxTimeOut", W3RUNNER_DEFAULT_MSGBOX_TIME_OUT)
End Property

Public Property Let MsgBoxTimeOut(ByVal v As Long)

    TRACE "W3Runner.MsgBoxTimeOut = " & v, w3rMETHOD
    AppOptions("MsgBoxTimeOut", , False) = v
End Property


Public Property Get MoveMouseCursor() As Boolean

    On Error GoTo errmgr
    
    MoveMouseCursor = CBool(AppOptions("MoveMouseCursor", False))
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "MoveMouseCursor"
End Property

Public Property Let MoveMouseCursor(ByVal vNewValue As Boolean)

    On Error GoTo errmgr
    
    TRACE PreProcess("W3Runner.MoveMouseCursor = [VALUE]", "VALUE", vNewValue), w3rMETHOD
    AppOptions("MoveMouseCursor", , False) = Abs(vNewValue)
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "MoveMouseCursor"
End Property

Public Property Get RecordHTTPProtocol() As Boolean
    RecordHTTPProtocol = g_static_booRecordHTTPProtocol
End Property

Public Property Let RecordHTTPProtocol(ByVal vNewValue As Boolean)

    TRACE PreProcess("W3Runner.RecordHTTPProtocol = [VALUE]", "VALUE", vNewValue), w3rMETHOD
    
    ' If we were asked to stop the record mode and the record mode was on we close
    ' the record file - the footer
    If RecordHTTPProtocol() = True And (vNewValue = False) Then
    
        frmMain.m_objWebLoad.StopRecording
    
    ElseIf RecordHTTPProtocol() = False And (vNewValue = True) Then
    
        frmMain.m_objWebLoad.StartRecording frmMain.ScriptFileName
    End If
    
    g_static_booRecordHTTPProtocol = vNewValue
    
End Property



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Environ
' PARAMETERS    :
' DESCRIPTION   : Return an W3Runner environment variable value or a OS Environment Variable
' RETURN        :
Public Function Environ(Optional ByVal varKey As Variant) As String
    
    Dim objVBScriptEngine   As New CVBScript
    Dim objWinApi           As New cWindows
    Dim strTraceVarKeyValue As String
    
    On Error GoTo errmgr
    
    Debug.Print varKey
    
    If (IsNumeric(varKey)) Then
        strTraceVarKeyValue = eW3RunnerEnvironmentInfoStrings(CLng(varKey))
    Else
        strTraceVarKeyValue = varKey
    End If
    
    TRACE PreProcess("W3Runner.Environ([VARKEY])", "VARKEY", strTraceVarKeyValue), w3rMETHOD
    
    If Not IsNumeric(varKey) Then
        Environ = VBA.Environ$(varKey)
    Else
        Select Case CLng(varKey)
        
            Case w3rW3RUNNER_VERSION: Environ = App.Major & "." & App.Minor & "." & App.Revision
            Case w3rWEB_BROWSER_VERSION: Environ = objVBScriptEngine.WebBrowserVersion()
            Case w3rWINDOWS_SCRIPT_HOST_VERSION: Environ = objVBScriptEngine.WindowsScriptHostVersion
            Case w3rVBSCRIPT_ENGINE_VERSION: Environ = objVBScriptEngine.VBScriptEngineVersion
            Case w3rVBSCRIPT_DEBUG_MODE: Environ = objVBScriptEngine.DebugMode
            Case w3rWINDOWS_VERSION: Environ = objWinApi.GetVersion32()
            Case w3rCOMPUTER_NAME: Environ = objWinApi.ComputerName()
            Case w3rUSER_NAME: Environ = objWinApi.UserName()
            Case w3rW3RUNNER_PATH: Environ = App.path
            Case w3rW3RUNNER_PROGRAM: Environ = App.EXEName & ".exe"
            Case w3rRESERVED_W3RUNNER_WEBSERVER_IP: Environ = g_objW3RunnerWebServer.IP
                
    
        End Select
    End If
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Environ"
End Function



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function TRACE(ByVal strMessage As String, Optional ByVal eMode As eW3RunnerTraceMode = w3rINFO) As Boolean

    On Error GoTo errmgr

    frmMain.TRACE strMessage, eMode
    TRACE = True
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "TRACE"
End Function


Public Property Get CancelScript() As Boolean
    CancelScript = g_static_booCancelScript
End Property
Public Property Let CancelScript(v As Boolean)
    g_static_booCancelScript = v
End Property


Public Function ClearCache() As Boolean

    Dim objWaitCursor   As New CWaitCursor
    
    objWaitCursor.Wait Screen
    TRACE PreProcess("W3Runner.ClearCache"), w3rMETHOD
    Me.IECache.DeleteAll , False
    ClearCache = True
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get SlowMode() As Long
    SlowMode = g_static_lngSlowMode
End Property

Public Property Let SlowMode(ByVal vNewValue As Long)
    TRACE "W3Runner.SlowMode = " & vNewValue, w3rMETHOD
    g_static_lngSlowMode = vNewValue
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Failed(ByVal booExpression As Boolean, ByVal strMessage As String) As Boolean

    On Error GoTo errmgr
    
    
    Failed = Not Test(booExpression, strMessage)
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Failed"
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Test(ByVal booExpression As Boolean, ByVal strMessage As String) As Boolean

    On Error GoTo errmgr
    
    Test = booExpression
    If (booExpression) Then
        TRACE strMessage, w3rSUCCESS
    Else
        TRACE strMessage, w3rERROR
    End If
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Test"
End Function



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Succeed(ByVal booExpression As Boolean, ByVal strMessage As String) As Boolean
    On Error GoTo errmgr
    
    Succeed = Test(booExpression, strMessage)
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Succeed"
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get ScriptFileName() As String
    ScriptFileName = g_static_ScriptFileName
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get ScriptFilePath() As String

    On Error GoTo errmgr
    
    Dim objTextFile As New cTextFile
    ScriptFilePath = objTextFile.GetPathFromFileName(g_static_ScriptFileName)
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "ScriptFilePath"
End Property


' UnDocumented - Allow access to the ini file
Public Property Get AppOptions(strName As String, Optional ByVal defaultValue As Variant, Optional ByVal booTrace As Boolean = True) As String

    AppOptions = AppOptionsModule.AppOptions(strName, defaultValue)
End Property

Public Property Let AppOptions(strName As String, Optional ByVal defaultValue As Variant, Optional ByVal booTrace As Boolean = True, ByVal v As String)

    If booTrace Then
    
        Dim strDefaultValue As String
        If Not IsMissing(defaultValue) Then strDefaultValue = defaultValue
            
        TRACE PreProcess("Page.AppOptions(""[NAME]"",""[DEFAULT]"") = ""[VALUE]""", "NAME", strName, "DEFAULT", strDefaultValue, "VALUE", v), w3rMETHOD
    End If
    AppOptionsModule.AppOptions(strName, defaultValue) = v
End Property


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function GMTNow(Optional ByVal strDateSeparator As String = "/", Optional ByVal strTimeSeparator As String = ":") As Variant
    
    GMTNow = GetCurrentGMTTime()
End Function






' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function PreProcess(ByVal strMessage As String, ParamArray defines() As Variant) As String

    Dim i As Long
    
    For i = 0 To UBound(defines()) Step 2
    
        strMessage = Replace(strMessage, "[" & defines(i) & "]", CStr(defines(i + 1)))
    Next
    PreProcess = strMessage
End Function



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Sleep(ByVal dblSecond As Double) As Boolean

    On Error GoTo errmgr
    
    TRACE "Page.Sleep " & dblSecond, w3rMETHOD
    
    cWindowsModule.Sleep CLng(dblSecond * 1000)
    GlobalDoEvents
    Sleep = True
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Sleep"
End Function


Public Property Get Stack() As CVariantStack
    Set Stack = g_objStack
End Property


Public Property Let Status(ByVal vNewValue As String)
    frmMain.Status vNewValue, 2
End Property


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get FullScreen() As Boolean

    On Error GoTo errmgr
    
    FullScreen = frmMain.FullScreen
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "FullScreen"
End Property

Public Property Let FullScreen(ByVal vNewValue As Boolean)

    On Error GoTo errmgr
    
    TRACE "Page.FullScreen = " & vNewValue, w3rMETHOD
    frmMain.FullScreen = vNewValue
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "FullScreen"
End Property


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : CheckVBScriptCode
' PARAMETERS    :
' DESCRIPTION   : Allow the W3Runner VBS function Include to show a good error message in case of syntax error.
'                 This is an internal, non documented function...
' RETURN        :
Public Function CheckVBScriptCode(ByVal strFileName As String, ByVal booCrypted As Boolean) As Boolean

    On Error GoTo errmgr
    
    Dim objVBEngine     As New CVBScript
    Dim objTextFile     As New cTextFile
    Dim strCodeSource   As String
    Dim lngLineCount    As Long
    
    If objTextFile.ExistFile(strFileName) Then
    
        objVBEngine.LoadAScript strFileName, strCodeSource, lngLineCount, booCrypted
        CheckVBScriptCode = objVBEngine.AddCode(strCodeSource)
    End If
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "CheckVBScriptCode"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadVBScriptCode
' PARAMETERS    :
' DESCRIPTION   : Load some VBScript code and add at the end of each line the line number and the file name
' RETURN        :
Public Function LoadVBScriptCode(ByVal strFileName As String, ByRef varCode As Variant) As Boolean

    On Error GoTo errmgr
        
    Dim objVBEngine     As New CVBScript
    Dim objTextFile     As New cTextFile
    Dim strCodeSource   As String
    Dim lngLineCount    As Long
    
    
    DEBUGLOG "LoadVBScriptCode " & strFileName
    
    If objTextFile.ExistFile(strFileName) Then
    
        objVBEngine.LoadAScript strFileName, strCodeSource, lngLineCount, objVBEngine.IsFileNameCrypted(strFileName)
        varCode = strCodeSource
        LoadVBScriptCode = True
    End If
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "LoadVBScriptCode"
End Function

Public Property Get Screen() As VB.Screen
    Set Screen = VB.Screen
End Property


Public Property Get TraceEvent() As String
    TraceEvent = W3RunnerMod.TraceEvent
End Property

Public Property Let TraceEvent(ByVal v As String)
    TRACE PreProcess("W3Runner.TraceEvent = [DC][VALUE][DC]", "VALUE", v, "DC", """"), w3rMETHOD
    W3RunnerMod.TraceEvent = v
End Property

Public Function SetFocusToListView() As Boolean
    frmMain.lvTrace.SetFocus
    SetFocusToListView = True
End Function

Public Function IEOptionsDialogs() As Boolean
    Dim objIE As New CIEApi
    objIE.OptionsDialogs
    IEOptionsDialogs = True
End Function

Public Function Quit(Optional ByVal strProgram As String, Optional ByVal strParameters As String, Optional ByVal eAppWinStyle As VbAppWinStyle = vbNormalFocus, Optional ByVal eMode As w3rQUIT_MODE = w3rQUIT_MODE_NORMAL) As Boolean
    
    Select Case eMode
        Case w3rQUIT_MODE_NORMAL
            If Len(strProgram) Then
                Shell strProgram & " " & strParameters, eAppWinStyle
            End If
        
        Case w3rQUIT_MODE_START_SAME_SCRIPT
            Shell App.EXEName & "\" & App.EXEName & ".exe " & Command, eAppWinStyle
    End Select
    DoEvents
    End ' Brutal End
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Quit"
End Function

Public Function GlobalInternalUnitTests(ByRef varInfo As Variant) As Boolean

    On Error GoTo errmgr
    
    Dim SerialKeyDecoding  As New CESellRate
    varInfo = TypeName(SerialKeyDecoding)
    If Not SerialKeyDecoding.UnitTest() Then Exit Function
    
    Dim Base64 As New CBase64
    Const STRING_TO_ENCODE = "ABCD123"
    varInfo = TypeName(Base64)
    If Base64.Decode(Base64.Encode(STRING_TO_ENCODE)) <> STRING_TO_ENCODE Then Exit Function

    Dim objPoissonSuceur As New CPoissonSuceur
    varInfo = TypeName(objPoissonSuceur)
    If Not objPoissonSuceur.UnitTest Then Exit Function
    

    GlobalInternalUnitTests = True
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), "W3Runner.bas", "GlobalInternalStartUnitTest"
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get VBScriptEngine() As Object

    On Error GoTo errmgr
    
    TRACE PreProcess("W3Runner.VBScriptEngine"), w3rMETHOD
    Set VBScriptEngine = frmMain.VBScriptEngine.VBSEngine
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "VBScriptEngine"
End Property


Public Property Get EnableDebugger() As Boolean
    Dim VBScriptEngine As New CVBScript
    EnableDebugger = VBScriptEngine.DebugMode
End Property

Public Property Let EnableDebugger(ByVal vNewValue As Boolean)
    Dim VBScriptEngine As New CVBScript
    VBScriptEngine.DebugMode = vNewValue
End Property

Public Property Get IECache() As CIECache
    Set IECache = g_objIECache
End Property

