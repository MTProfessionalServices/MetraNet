VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MDMTestDialog"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public TextFile             As New MTVBLib.cTextFile
Public WinApi               As New MTVBLib.cWindows

Public MDMTestForm          As frmMain
Public Parent               As MDMTestDialog
Public Name                 As String
Public Windows              As MDMTestDialogs

Private m_strURL            As String
Private m_strLogFileName    As String
Private m_booDBOpened       As Boolean
Private m_strUserMessage    As String

Private m_objUIHelper       As CUIHelper

Public PerformanceMode     As Boolean
Public UserMessage          As String ' For old compatiblity with old script


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Initialize(frmTest As frmMain, booMainForm As Boolean) As Boolean

    On Error GoTo ErrMgr
    
    If (booMainForm) Then
        Set Windows = New MDMTestDialogs
    End If
    Set MDMTestForm = frmTest
    Initialize = True
    
    Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Initialize"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get url() As String

    On Error GoTo ErrMgr
    
    url = m_strURL
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "URL"
End Property


Public Property Let url(ByVal vNewValue As String)

    On Error GoTo ErrMgr

    m_strURL = vNewValue
    
    TRACE PreProcess("Page.URL =[DC][VNEWVALUE][DC]", "DC", """", "VNEWVALUE", vNewValue), w3rMETHOD
    
    MDMTestForm.AsyncURL = m_strURL
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "URL"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Exist(ByVal strID As String, ByVal strType As String, Optional ByVal strFrame As String, Optional ByVal lngIndex As Long = 1, Optional ByVal varValue As Variant, Optional ByVal booShowError As Boolean = True) As Boolean

    Exist = IsValidObject(Item(strID, strType, strFrame, lngIndex, varValue, booShowError:=False))
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Exist"
End Function

Public Property Get Item(Optional ByVal strID As String, Optional ByVal strType As String, Optional ByVal strFrame As String, Optional ByVal lngIndex As Long = 1, Optional ByVal varValue As Variant, Optional ByVal strHREF As String, Optional ByVal booShowError As Boolean = True) As FredRunnerControl

    Set Item = Controls(strID, strType, strFrame, lngIndex, varValue, strHREF, booShowError)
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Controls(Optional ByVal strID As String, Optional ByVal strType As String, Optional ByVal strFrame As String, Optional ByVal lngIndex As Long = 1, Optional ByVal varValue As Variant, Optional ByVal strHREF As String, Optional ByVal booShowError As Boolean = True) As FredRunnerControl
Attribute Controls.VB_UserMemId = 0

    On Error GoTo ErrMgr

    Dim o                       As Object
    Dim objFredRunnerControl    As FredRunnerControl
    Dim strS                    As String
    Dim strTrace                As String
    Dim strCounter              As String
    
        
    If Not g_static_booRegistered Then
    
        g_static_lngDemoItemCount = g_static_lngDemoItemCount + 1
        
        If g_static_lngDemoItemCount > GetMaxTrialItem() Then
        
            EndOfDemo
        End If
    End If
    
    If (Not g_static_booRegistered) Then
        
        If (DebugMode()) Then
        
             strCounter = "(" & g_static_lngDemoItemCount & "/" & GetMaxTrialItem() & ")"
        End If
    End If
    
    strTrace = PreProcess("[METHOD]([DC][STRID][DC],[DC][STRTYPE][DC],[DC][STRFRAME][DC],[LNGINDEX],[DC][VARVALUE][DC],[DC][STRHREF][DC]) [COUNTER]", "STRID", strID, "STRTYPE", strType, "STRFRAME", strFrame, "LNGINDEX", IIf(lngIndex = 1, "", lngIndex), "VARVALUE", IIf(IsMissing(varValue), "", varValue), "STRHREF", strHREF, "METHOD", IIf(MDMTestForm.IsChild, "Page.Windows(" & MDMTestForm.ChildIndex & ").Controls", "Page.Controls"), "DC", """", "COUNTER", strCounter)
                            
    strTrace = Replace(strTrace, ",""""", ",")
    
    Do While (InStr(strTrace, ",)"))
        strTrace = Replace(strTrace, ",)", ")")
    Loop
    
    TRACE strTrace, w3rMETHOD
    
    If (Len(strType) = 0) Then strType = "*"
    
    strType = UCase$(strType)
    
    Select Case strType
    
        Case "TEXTBOX"
            Set o = MDMTestForm.GetHTMLObject(strID, "HTMLInputElement", "name", , strFrame, False, lngIndex)
            If (o Is Nothing) Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLTextAreaElement", "name", , strFrame, booShowError, lngIndex)
            
        Case "RADIOBUTTON", "CHECKBOX", "SUBMIT", "INPUT", "HIDDEN"
            
            Set o = MDMTestForm.GetHTMLObject(strID, "HTMLInputElement", "name", , strFrame, booShowError, lngIndex, varValue)
            
        Case "COMBOBOX"
            Set o = MDMTestForm.GetHTMLObject(strID, "HTMLSelectElement", "name", , strFrame, booShowError, lngIndex)
            
        Case "MAP"
            Set o = MDMTestForm.GetHTMLObject(strID, "HTMLMapElement", "name", , strFrame, booShowError, lngIndex)
                    
            
        Case "BUTTON"
        
            ' Input type=button with a name
            Set o = MDMTestForm.GetHTMLObject(strID, "HTMLInputElement", "name", , strFrame, False, lngIndex)
            
            ' Input type=button with the value
            If (Not IsValidObject(o)) Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLInputElement", "value", , strFrame, False, lngIndex)
            
            ' Support of the tag <BUTTON> with the name
            If (Not IsValidObject(o)) Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLButtonElement", "name", , strFrame, booShowError, lngIndex)
            
            ' Support of the tag <BUTTON> with the value
            If (Not IsValidObject(o)) Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLButtonElement", "value", , strFrame, booShowError, lngIndex)
            
        Case "IMAGE"
            Set o = MDMTestForm.GetHTMLObject(strID, "HTMLImg", "src", True, strFrame, False, lngIndex)
            
            If (Not IsValidObject(o)) Then ' Try with the name
            
                Set o = MDMTestForm.GetHTMLObject(strID, "HTMLImg", "name", , strFrame, False, lngIndex)
                
                If (Not IsValidObject(o)) Then ' Try as HTMLInputElement Type Image
                    Set o = MDMTestForm.GetHTMLObject(strID, "HTMLInputElement", "name", , strFrame, booShowError, lngIndex)
                End If
            End If
            
        Case "ANCHOR" ' Seach on the anchor text
            Set o = MDMTestForm.GetHTMLObject(strID, "HTMLAnchorElement", "innerText", False, strFrame, False, lngIndex)
            If o Is Nothing Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLAnchorElement", "name", , strFrame, False, lngIndex) ' Try with the anchor name
            If (Len(strHREF)) Then
                If o Is Nothing Then Set o = MDMTestForm.GetHTMLObject(strHREF, "HTMLAnchorElement", "href", True, strFrame, booShowError, lngIndex) ' Try with the anchor name
            End If
            
        Case "TD", "TABLECELL"
            Set o = MDMTestForm.GetHTMLObject(strID, "HTMLTableCell", "name", , strFrame, False, lngIndex)
            If o Is Nothing Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLTableCell", "innerText", False, strFrame, booShowError, lngIndex)
            
        Case Else
            
            strType = "*" ' Joker
            Set o = MDMTestForm.GetHTMLObject(strID, strType, "innerText", , strFrame, False, lngIndex)
            If o Is Nothing Then Set o = MDMTestForm.GetHTMLObject(strID, strType, "name", , strFrame, booShowError, lngIndex)
    End Select
    
    If (Not o Is Nothing) Then
    
        Set objFredRunnerControl = New FredRunnerControl

        objFredRunnerControl.Initialize strID, o, MDMTestForm, strType, strFrame
        Set objFredRunnerControl.frm = MDMTestForm
        Set Controls = objFredRunnerControl
        
        If AppOptions("MoveMouseCursor", False) And (strType <> "HIDDEN") And (strType <> "MAP") Then
        
            SetHTMLObjectCursorPos MDMTestForm, o, strFrame
        End If
    End If
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Controls"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function WaitForDownLoad(Optional ByVal strURL As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim lngTime         As Long
    Dim strLastFileName As String
    
    lngTime = GetTickCount()

    MDMTestForm.WaitForDownLoad strURL
    
    ' Performance
    lngTime = GetTickCount() - lngTime
    
    strLastFileName = Me.TextFile.GetFileName(g_static_strLastDownLoadedURL, "/")
    
    TRACE PreProcess("[DATE],[TIME],UI.WaitForDownLoad,[URLFILENAME],[STRURL],[LNGTIME]", "DATE", Format(Now(), "yyyy-mm-dd"), "TIME", Format(Now(), "hh:mm:ss"), "STRURL", g_static_strLastDownLoadedURL, "LNGTIME", lngTime, "DC", """", "URLFILENAME", strLastFileName), w3rPERFORMANCE
    
    WaitForDownLoad = True
    Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "WaitForDownLoad"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Wait(ByVal dblSecond As Double, Optional ByVal booNoSleep As Boolean = False) As Boolean

    On Error GoTo ErrMgr
    
    TRACE "Page.Wait " & dblSecond, w3rMETHOD
    
    Wait = FredRunnerMod.Wait(dblSecond, booNoSleep)
    GlobalDoEvents
    Wait = True
    Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Wait"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function TRACE(ByVal strMessage As String, Optional ByVal eMode As eFredRunnerTraceMode = w3rINFO) As Boolean

    On Error GoTo ErrMgr

    MDMTestForm.TRACE strMessage, eMode
    TRACE = True
    Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "TRACE"
End Function

Public Property Get CancelScript() As Boolean
    CancelScript = g_static_booCancelScript
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function FindText(ByVal strSearchedText As String, Optional ByVal strFrameName As String, Optional strTextType As String = "innerText", Optional booIgnoreCase As Boolean = True) As Long

    On Error GoTo ErrMgr
    
    TRACE PreProcess("FindText([DC][STRSEARCHEDTEXT][DC],[DC][STRFRAMENAME][DC],[DC][STRTEXTTYPE][DC],[DC][BOOIGNORECASE][DC])", "DC", """", "STRSEARCHEDTEXT", strSearchedText, "STRFRAMENAME", strFrameName, "STRTEXTTYPE", strTextType, "BOOIGNORECASE", booIgnoreCase), w3rMETHOD
    FindText = MDMTestForm.FindText(strSearchedText, strFrameName, strTextType, booIgnoreCase)
    Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "FindText"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Initialize()

    Name = WinApi.CreateGUIDKey()
Exit Sub
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Class_Initialize()"
End Sub

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    Set MDMTestForm = Nothing
    Exit Sub
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Class_Terminate"
End Sub

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function MsgBox(ByVal strMessage As String, Optional strTitle As String)

    On Error GoTo ErrMgr

    TRACE PreProcess("Page.MsgBox([DC][STRMESSAGE][DC],[DC][STRTITLE][DC]", "DC", """", "STRMESSAGE", strMessage, "STRTITLE", strTitle), w3rMETHOD
    frmMsgbox.OpenDialog strMessage, strTitle
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "MsgBox"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function done() As Boolean

    On Error GoTo ErrMgr

    Set MDMTestForm = Nothing
    done = True
    Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Done"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Delete() As Boolean

    On Error GoTo ErrMgr
    
    Set Windows = Nothing
    Set Parent = Nothing
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Delete"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Arguments(ByVal strName As String, Optional ByVal varDefaultValue As Variant) As Variant

    On Error GoTo ErrMgr
    Arguments = FredRunnerMod.Arguments(strName, varDefaultValue)
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Arguments"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get SlowMode() As Long
    SlowMode = g_static_lngSlowMode
End Property

Public Property Let SlowMode(ByVal vNewValue As Long)
    TRACE "Page.SlowMode = " & vNewValue, w3rMETHOD
    g_static_lngSlowMode = vNewValue
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get GUID() As String
    GUID = Name
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get WaitAfterWaitForDownLoad() As Long
    WaitAfterWaitForDownLoad = g_static_lngWaitAfterWaitForDownLoad
End Property

Public Property Let WaitAfterWaitForDownLoad(ByVal vNewValue As Long)
    g_static_lngWaitAfterWaitForDownLoad = vNewValue
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get DownLoadTimeOut() As Long
    DownLoadTimeOut = g_static_lngDownLoadTimeOut
End Property

Public Property Let DownLoadTimeOut(ByVal vNewValue As Long)
    TRACE "Page.DownLoadTimeOut = " & vNewValue, w3rMETHOD
    g_static_lngDownLoadTimeOut = vNewValue
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

    TRACE "Page.CancelScriptIfTimeOut = " & vNewValue, w3rMETHOD
    g_static_booCancelScriptIfTimeOut = vNewValue
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Succeed(ByVal booExpression As Boolean, ByVal strMessage As String) As Boolean
    On Error GoTo ErrMgr
    
    Succeed = Test(booExpression, strMessage)
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Succeed"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Failed(ByVal booExpression As Boolean, ByVal strMessage As String) As Boolean

    On Error GoTo ErrMgr
    
    Failed = Not Test(booExpression, strMessage)
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Failed"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Test(ByVal booExpression As Boolean, ByVal strMessage As String) As Boolean

    On Error GoTo ErrMgr
    
    Test = booExpression
    If (booExpression) Then
        TRACE strMessage, w3rSUCCESS
    Else
        TRACE strMessage, w3rERROR
    End If
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Test"
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

    On Error GoTo ErrMgr
    
    Dim objTextFile As New cTextFile
    ScriptFilePath = objTextFile.GetPathFromFileName(g_static_ScriptFileName)
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "ScriptFilePath"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get FullScreen() As Boolean

    On Error GoTo ErrMgr
    
    FullScreen = frmMain.FullScreen
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "FullScreen"
End Property

Public Property Let FullScreen(ByVal vNewValue As Boolean)

    On Error GoTo ErrMgr
    
    TRACE "Page.FullScreen = " & vNewValue, w3rMETHOD
    frmMain.FullScreen = vNewValue
Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "FullScreen"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get MinChildWindowWidth() As Long
    MinChildWindowWidth = g_static_lngMinChildWindowWidth
End Property

Public Property Let MinChildWindowWidth(ByVal v As Long)

    On Error GoTo ErrMgr
    
    TRACE "Page.MinChildWindowWidth = " & v, w3rMETHOD
    g_static_lngMinChildWindowWidth = v
Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "MinChildWindowWidth"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get MinChildWindowHeight() As Long
    MinChildWindowHeight = g_static_lngMinChildWindowHeight
End Property

Public Property Let MinChildWindowHeight(ByVal v As Long)

    On Error GoTo ErrMgr
    
    TRACE "Page.MinChildWindowHeight = " & v, w3rMETHOD
    g_static_lngMinChildWindowHeight = v
Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "MinChildWindowHeight"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function DownLoad(ByVal strURL As String, ByRef varText As Variant) As Boolean


    Dim strText As String
    
    On Error GoTo ErrMgr
        
    TRACE PreProcess("Page.DownLoad([DC][STRURL][DC],varText)", "DC", """", "STRURL", strURL), w3rMETHOD

    If (FredRunnerMod.DownLoad(strURL, strText)) Then
        varText = strText
        DownLoad = True
    End If
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "DownLoad"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function SendKeys(ByVal strKeys As String, Optional booWait As Boolean = False, Optional booNewProcess As Boolean = False, Optional lngTimeToWait As Long = 1) As Boolean

    On Error GoTo ErrMgr
    
    TRACE PreProcess("Page.SendKeys([DC][STRKEYS][DC],[BOOWAIT],[BOONEWPROCESS],[LNGTIMETOWAIT]", "DC", """", "STRKEYS", strKeys, "BOOWAIT", booWait, "BOONEWPROCESS", booNewProcess, "LNGTIMETOWAIT", lngTimeToWait), w3rMETHOD
    
    If (booNewProcess) Then
        Shell App.Path & "\" & App.EXEName & ".exe -keys """ & strKeys & """ -timetowait " & (lngTimeToWait * 1000)
    Else
        VBA.SendKeys strKeys, booWait
    End If
    SendKeys = True
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "SendKeys"
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get UpdateWatchWindow() As Boolean
    UpdateWatchWindow = g_static_booUpdateWatchWindow
End Property

Public Property Let UpdateWatchWindow(ByVal vNewValue As Boolean)

    On Error GoTo ErrMgr
    
    TRACE "Page.UpdateWatchWindow = " & vNewValue, w3rMETHOD
    
    g_static_booUpdateWatchWindow = vNewValue
    If g_static_booUpdateWatchWindow Then
        frmMain.RefreshWatchWindow
    End If
Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "UpdateWatchWindow"
End Property


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : CheckVBScriptCode
' PARAMETERS    :
' DESCRIPTION   : Allow the FredRunner VBS function Include to show a good error message in case of syntax error.
'                 This is an internal, non documented function...
' RETURN        :
Public Function CheckVBScriptCode(ByVal strFileName As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim objVBEngine     As New CVBScript
    Dim objTextFile     As New cTextFile
    Dim strCodeSource   As String
    Dim lngLineCount    As Long
    
    If objTextFile.ExistFile(strFileName) Then
    
        objVBEngine.LoadAScript strFileName, strCodeSource, lngLineCount
        CheckVBScriptCode = objVBEngine.AddCode(strCodeSource)
    End If
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "CheckVBScriptCode"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadVBScriptCode
' PARAMETERS    :
' DESCRIPTION   : Load some VBScript code and add at the end of each line the line number and the file name
' RETURN        :
Public Function LoadVBScriptCode(ByVal strFileName As String, ByRef varCode As Variant) As Boolean

    On Error GoTo ErrMgr
        
    Dim objVBEngine     As New CVBScript
    Dim objTextFile     As New cTextFile
    Dim strCodeSource   As String
    Dim lngLineCount    As Long
    
    DEBUGLOG "LoadVBScriptCode " & strFileName
    
    If objTextFile.ExistFile(strFileName) Then
    
        objVBEngine.LoadAScript strFileName, strCodeSource, lngLineCount
        varCode = strCodeSource
        LoadVBScriptCode = True
    End If
Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "LoadVBScriptCode"
End Function

'
' Not Documented for now
'
Public Property Get GrabScreenCounter() As Long
    GrabScreenCounter = g_static_lngGrabScreenCounter
End Property
Public Property Let GrabScreenCounter(ByVal vNewValue As Long)
    g_static_lngGrabScreenCounter = vNewValue
End Property
Public Function GrabFullScreen() As Boolean
    DoEvents
    'Me.Helper.ScreenGrabber.Grab eGRAB_MODE_FULL_SCREEN, Environ("temp") & "\FredRunnerScreen" & GrabScreenCounter & ".bmp"
    Me.Helper.screenGrabber.Grab eGRAB_MODE_WINDOW, Environ("temp") & "\FredRunnerScreen" & Format(GrabScreenCounter, "000") & ".bmp", frmMain.hwnd, frmMain.Width / VB.Screen.TwipsPerPixelX, frmMain.Height / VB.Screen.TwipsPerPixelY
    GrabScreenCounter = GrabScreenCounter + 1
    GrabFullScreen = True
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Property Get VBScriptEngine() As Object

    On Error GoTo ErrMgr
    
    TRACE PreProcess("Page.VBScriptEngine"), w3rMETHOD
    Set VBScriptEngine = frmMain.VBScriptEngine.VBSEngine
Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "VBScriptEngine"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Helper() As CUIHelper

    On Error GoTo ErrMgr

    TRACE PreProcess("Page.Helper"), w3rMETHOD
    If Not IsValidObject(m_objUIHelper) Then
    
        'Debug.Assert 0
        Set m_objUIHelper = New CUIHelper
    End If
    Set Helper = m_objUIHelper
Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Helper"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get HTMLDoc() As HTMLDocument

    On Error GoTo ErrMgr
    
    TRACE PreProcess("Page.HTMLDoc"), w3rMETHOD
    Set HTMLDoc = MDMTestForm.HTMLDoc
Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "HTMLDoc"
End Property

Public Property Get Form() As Form

    On Error GoTo ErrMgr
    
    TRACE PreProcess("Page.Form"), w3rMETHOD
    Set Form = Me.MDMTestForm
Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Form"
End Property

Public Property Get WebBrowser() As WebBrowser

    On Error GoTo ErrMgr
    
    TRACE PreProcess("Page.WebBrowser"), w3rMETHOD
    Set WebBrowser = MDMTestForm.WebBrowser
Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "WebBrowser"
End Property


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Environ
' PARAMETERS    :
' DESCRIPTION   : Return an FredRunner environment variable value or a OS Environment Variable
' RETURN        :
Public Function Environ(Optional ByVal varKey As Variant) As String
    
    Dim objVBScriptEngine   As New CVBScript
    Dim objWinApi           As New cWindows
    Dim strTraceVarKeyValue As String
    
    On Error GoTo ErrMgr
    
    Debug.Print varKey
    
    If (IsNumeric(varKey)) Then
        strTraceVarKeyValue = eFredRunnerEnvironmentInfoStrings(CLng(varKey))
    Else
        strTraceVarKeyValue = varKey
    End If
    
    TRACE PreProcess("Page.Environ([VARKEY])", "VARKEY", strTraceVarKeyValue), w3rMETHOD
    
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
            Case w3rW3RUNNER_PATH: Environ = App.Path
            Case frFRED_REVERVED_FREDRUNNER_WEBSERVER_IP: Environ = g_objFredRunnerWebServer.IP
    
        End Select
    End If
    Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "Environ"
End Function

' Not documented
Public Property Get MoveMouseCursor() As Boolean

    On Error GoTo ErrMgr
    
    TRACE PreProcess("Page.MoveMouseCursor"), w3rMETHOD
    MoveMouseCursor = CBool(AppOptions("MoveMouseCursor", False))
Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "MoveMouseCursor"
End Property

Public Property Let MoveMouseCursor(ByVal vNewValue As Boolean)

    On Error GoTo ErrMgr
    
    TRACE PreProcess("Page.MoveMouseCursor = [VALUE]", "VALUE", vNewValue), w3rMETHOD
    AppOptions("MoveMouseCursor") = Abs(vNewValue)
Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "MDMTestDialog.cls", "MoveMouseCursor"
End Property

Public Property Get AutoFireEvent() As Boolean
    AutoFireEvent = g_static_booAutoFireEvent
End Property

Public Property Let AutoFireEvent(ByVal vNewValue As Boolean)
    g_static_booAutoFireEvent = vNewValue
End Property

Public Property Get Children() As MDMTestDialogs
    Set Children = Windows
End Property
