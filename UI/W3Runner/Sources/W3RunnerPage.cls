VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "W3RunnerPage"
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
'  DATE         : 12/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************

Option Explicit

Public MDMTestForm          As frmMain
Public Parent               As W3RunnerPage
Public Name                 As String
Public Windows              As New W3RunnerPages ' Must be allocated by default for the record mode
Public InputHeaders         As New CVariables
Public Parameters           As New CVariables

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

    On Error GoTo errmgr
    
    If (booMainForm) Then
        Set Windows = New W3RunnerPages
    End If
    Set MDMTestForm = frmTest
    Initialize = True
    
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Initialize"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get URL() As String

    On Error GoTo errmgr
    
    URL = m_strURL
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "URL"
End Property




' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Exist(Optional ByVal strID As String, Optional ByVal strType As String, Optional ByVal strFrame As String, Optional ByVal lngIndex As Long = 1, Optional ByVal varValue As Variant, Optional ByVal strHREF As String, Optional ByVal booShowError As Boolean = True) As Boolean

    Exist = IsValidObject(Controls(strID, strType, strFrame, lngIndex, varValue, strHREF, booShowError:=False))
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Exist"
End Function

Public Property Get Item(Optional ByVal strID As String, Optional ByVal strType As String, Optional ByVal strFrame As String, Optional ByVal lngIndex As Long = 1, Optional ByVal varValue As Variant, Optional ByVal strHREF As String, Optional ByVal booShowError As Boolean = True) As W3RunnerControl

    Set Item = Controls(strID, strType, strFrame, lngIndex, varValue, strHREF, booShowError)
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Controls(Optional ByVal strID As String, Optional ByVal strType As String, Optional ByVal strFrame As String, Optional ByVal lngIndex As Long = 1, Optional ByVal varValue As Variant, Optional ByVal strHREF As String, Optional ByVal booShowError As Boolean = True) As W3RunnerControl
Attribute Controls.VB_UserMemId = 0

    On Error Resume Next

    Dim o                       As Object
    Dim objW3RunnerControl    As W3RunnerControl
    Dim strS                    As String
    Dim strTrace                As String
    
    Dim objDummy                As Object
    
   ' CheckToEndTrialVersion
        
    strTrace = PreProcess("[METHOD]([DC][STRID][DC],[DC][STRTYPE][DC],[DC][STRFRAME][DC],[LNGINDEX],[DC][VARVALUE][DC],[DC][STRHREF][DC])", "STRID", strID, "STRTYPE", strType, "STRFRAME", strFrame, "LNGINDEX", IIf(lngIndex = 1, "", lngIndex), "VARVALUE", IIf(IsMissing(varValue), "", varValue), "STRHREF", strHREF, "METHOD", IIf(MDMTestForm.IsChild, "Page.Windows(" & MDMTestForm.ChildIndex & ").Controls", "Page.Controls"), "DC", """")
    strTrace = Replace(strTrace, ",""""", ",")
    
    Do While (InStr(strTrace, ",)"))
        strTrace = Replace(strTrace, ",)", ")")
    Loop
    
    TRACE strTrace, w3rMETHOD
    
    If (Len(strType) = 0) Then
        strType = "*"
    End If
    
    Dim LoopCounter As Long
    Do While LoopCounter < 20 And Not frmMain.CancelScript
    
        strType = UCase$(strType)
        
        Select Case strType
        
            Case "TEXTBOX"
                Set o = MDMTestForm.GetHTMLObject(strID, "HTMLInputElement", "name", , strFrame, False, lngIndex)
                If (o Is Nothing) Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLTextAreaElement", "name", , strFrame, booShowError, lngIndex)
                
            Case "RADIOBUTTON", "CHECKBOX", "SUBMIT", "INPUT", "HIDDEN"
                Set o = MDMTestForm.GetHTMLObject(strID, "HTMLInputElement", "name", , strFrame, False, lngIndex, varValue)
                If (o Is Nothing) Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLInputElement", "value", , strFrame, booShowError, lngIndex, varValue)
                
            Case "COMBOBOX", "LISTBOX"
                Set o = MDMTestForm.GetHTMLObject(strID, "HTMLSelectElement", "name", , strFrame, booShowError, lngIndex)
                
            Case "MAP"
                Set o = MDMTestForm.GetHTMLObject(strID, "HTMLMapElement", "name", , strFrame, booShowError, lngIndex)
                        
            Case "BUTTON"
            
                ' <INPUT Type="Button"> with a name
                Set o = MDMTestForm.GetHTMLObject(strID, "HTMLInputElement", "name", , strFrame, False, lngIndex)
                
                ' <INPUT Type="Button"> with a name
                If (Not IsValidObject(o)) Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLInputElement", "value", , strFrame, False, lngIndex)
                
                ' Support of the tag <BUTTON> with the name
                If (Not IsValidObject(o)) Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLButtonElement", "name", , strFrame, booShowError, lngIndex)
                
                ' Support of the tag <BUTTON> with the value
                If (Not IsValidObject(o)) Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLButtonElement", "value", , strFrame, booShowError, lngIndex)
                
            Case "IMAGE" ' Support <IMG> and <INPUT Type="Image">
                Set o = MDMTestForm.GetHTMLObject(strID, "HTMLImg", "src", True, strFrame, False, lngIndex)
                
                If (Not IsValidObject(o)) Then ' Try with the name
                
                    Set o = MDMTestForm.GetHTMLObject(strID, "HTMLImg", "name", , strFrame, False, lngIndex)
                    
                    If (Not IsValidObject(o)) Then ' Try as HTMLInputElement Type Image
                    
                        Set o = MDMTestForm.GetHTMLObject(strID, "HTMLInputElement", "name", , strFrame, booShowError, lngIndex)
                    End If
                End If
                
            Case "ANCHOR" ' Seach on the anchor text
            
                If Len(strID) Then ' Because when the id is not define and the tag has not name ""="", we want to avoid this case...
                
                    Set o = MDMTestForm.GetHTMLObject(strID, "HTMLAnchorElement", "innerText", False, strFrame, False, lngIndex)
                
                    If o Is Nothing Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLAnchorElement", "name", , strFrame, False, lngIndex) ' Try with the anchor name
                End If
                
                If (Len(strHREF)) And (o Is Nothing) Then
                
                    Set o = MDMTestForm.GetHTMLObject(strHREF, "HTMLAnchorElement", "href", True, strFrame, booShowError, lngIndex) ' Try with the anchor name
                End If
                
            Case "TD", "TABLECELL"
                Set o = MDMTestForm.GetHTMLObject(strID, "HTMLTableCell", "name", , strFrame, False, lngIndex) ' Name
                If o Is Nothing Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLTableCell", "innerText", False, strFrame, booShowError, lngIndex) ' InnerText
                
            Case "DIV"
                Set o = MDMTestForm.GetHTMLObject(strID, "HTMLDivElement", "name", , strFrame, False, lngIndex) ' Name
                If o Is Nothing Then Set o = MDMTestForm.GetHTMLObject(strID, "HTMLDivElement", "innerText", False, strFrame, booShowError, lngIndex) ' InnerText
                
                Dim div As HTMLDivElement
                Set div = o
                
            Case "HTMLWINDOW2"
                Set o = GetFrame(MDMTestForm.HTMLDoc, strID)
                
            Case "FRAME"
                Set o = MDMTestForm.GetHTMLObject(strID, "HTMLFrameElement", "name", , strFrame, booShowError, lngIndex)
                
            Case "OBJECT"
                Set o = MDMTestForm.GetHTMLObject(strID, "HTMLObjectElement", "name", , strFrame, booShowError, lngIndex)
                
            Case Else
                
                strType = "*" ' Joker
                
                ' Look up on the name
                Set o = MDMTestForm.GetHTMLObject(strID, strType, "name", , strFrame, False, lngIndex)
                
                ' Look up on the text
                If o Is Nothing Then Set o = MDMTestForm.GetHTMLObject(strID, strType, "innerText", , strFrame, False, lngIndex)
                            
                ' Look up on the href
                If o Is Nothing Then
                
                    If (Len(strHREF)) Then
                    
                        If o Is Nothing Then Set o = MDMTestForm.GetHTMLObject(strHREF, strType, "href", True, strFrame, booShowError, lngIndex) ' Try with the anchor name
                    End If
                End If
        End Select
        
        If (Not o Is Nothing) Then
        
            Set objW3RunnerControl = New W3RunnerControl
            
            objW3RunnerControl.Initialize strID, o, MDMTestForm, strType, strFrame
            Set objW3RunnerControl.frm = MDMTestForm
            Set Controls = objW3RunnerControl
            
            Dim strImageName As String
            
            If strType = "MAP" Then
            
                If GetImageNameAssociatedWithMap(Me.MDMTestForm.HTMLDoc, strID, strFrame, strImageName) Then
                
                    objW3RunnerControl.Image = strImageName
                End If
            End If
            
            If strType <> "HTMLWINDOW2" And strType <> "FRAME" And strType <> "*" Then
            
                If AppOptions("AutoFocus", False) Then objW3RunnerControl.SetFocus True
                
                If AppOptions("MoveMouseCursor", False) Then objW3RunnerControl.SetMouse True  ' Move the mouse if must
            End If
            Exit Property ' we found it
        Else
            TRACE "Control [" & strType & " - " & strID & "] was not found.  Forcing retry... [" & LoopCounter & "]", w3rWARNING
            LoopCounter = LoopCounter + 1
            DoEvents
            Sleep 1000
            DoEvents
        End If
    Loop
 
On Error GoTo 0
'errmgr:
'    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Controls"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function WaitForDownLoad(Optional ByVal strURL As String, Optional ByRef varTime As Variant) As Boolean

    On Error GoTo errmgr
    
    Dim lngTime         As Long
    Dim strLastFileName As String
    
    lngTime = GetTickCount()

    WaitForDownLoad = MDMTestForm.WaitForDownLoad(strURL)
    
    ' -- Performance -- Because we do a delay when click or set an url we need to deduct this time to get the real performance
    lngTime = g_lngWaitForDownLoadArrivedTickCount - lngTime - IIf(g_lngDownLoadResponseTimeDelay, g_lngDownLoadResponseTimeDelay, 0)
    g_lngWaitForDownLoadArrivedTickCount = 0
    If g_lngDownLoadResponseTimeDelay Then g_lngDownLoadResponseTimeDelay = 0 ' No more used
    
    varTime = lngTime
    strLastFileName = Me.TextFile.GetFileName(g_static_strLastDownLoadedURL, "/")
    TRACE PreProcess("[DATE],[TIME],Page.WaitForDownLoad,[URLFILENAME],[STRURL],[LNGTIME]", "DATE", Format(Now(), "yyyy-mm-dd"), "TIME", Format(Now(), "hh:mm:ss"), "STRURL", g_static_strLastDownLoadedURL, "LNGTIME", lngTime, "DC", """", "URLFILENAME", strLastFileName), w3rPERFORMANCE
         
    ' Wait 2
    
    Exit Function
errmgr:
    TRACE "Error downloading page " & strURL, w3rERROR
    
End Function






' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function FindText(ByVal strSearchedText As String, Optional ByVal strFrameName As String, Optional ByVal strTextType As String = "innerText", Optional ByVal booIgnoreCase As Boolean = True, Optional booRegularExp As Boolean = False) As Long

    On Error GoTo errmgr
    
    TRACE PreProcess("FindText([DC][STRSEARCHEDTEXT][DC],[DC][STRFRAMENAME][DC],[DC][STRTEXTTYPE][DC],[BOOIGNORECASE],[REGEXP])", "DC", """", "STRSEARCHEDTEXT", strSearchedText, "STRFRAMENAME", strFrameName, "STRTEXTTYPE", strTextType, "BOOIGNORECASE", booIgnoreCase, "REGEXP", booRegularExp), w3rMETHOD
    'FindText = MDMTestForm.FindText(strSearchedText, strFrameName, strTextType, booIgnoreCase, booRegularExp)
    
    Dim objHTMLDoc  As Variant ' HTMLDocument - Do not type it so we can avoid problem with IE5.0
    Dim strText     As String
    Dim objRegExp   As New CRegExp
    
    If (Len(strFrameName)) Then
        Set objHTMLDoc = GetFrame(Me.HTMLDocument, strFrameName).Document
    Else
        Set objHTMLDoc = Me.HTMLDocument
    End If
    
    Select Case UCase$(strTextType)
        Case "INNERTEXT": strText = objHTMLDoc.body.innerText
        Case "OUTERTEXT": strText = objHTMLDoc.body.outerText
        Case "INNERHTML": strText = objHTMLDoc.body.innerHTML
        Case "OUTERHTML": strText = objHTMLDoc.body.outerHTML
    End Select
    
    If booRegularExp Then
    
        objRegExp.IgnoreCase = booIgnoreCase
        objRegExp.Pattern = strSearchedText
        FindText = objRegExp.Execute(strText)
    Else
    
        If (booIgnoreCase) Then
            FindText = InStr(UCase(strText), UCase(strSearchedText))
        Else
            FindText = InStr(strText, strSearchedText)
        End If
    End If
    
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "FindText"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Initialize()

    Name = WinApi.CreateGUIDKey()
Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Class_Initialize()"
End Sub

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Terminate()

    On Error GoTo errmgr
    Set MDMTestForm = Nothing
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Class_Terminate"
End Sub



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function done() As Boolean

    On Error GoTo errmgr

    Set MDMTestForm = Nothing
    done = True
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Done"
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Delete() As Boolean

    On Error GoTo errmgr
    
    frmMain.m_objW3RunnerPage.Windows.Remove Me.GUID
    Set Windows = Nothing
    Set Parent = Nothing
    Set MDMTestForm = Nothing
    Set m_objUIHelper = Nothing
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Delete"
End Function





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
Public Property Get DownLoadTimeOut() As Long
    DownLoadTimeOut = frmMain.DownLoadTimeOut
End Property

Public Property Let DownLoadTimeOut(ByVal vNewValue As Long)
    TRACE "Page.DownLoadTimeOut = " & vNewValue, w3rMETHOD
    frmMain.DownLoadTimeOut = vNewValue
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

    On Error GoTo errmgr
    
    TRACE "Page.MinChildWindowWidth = " & v, w3rMETHOD
    g_static_lngMinChildWindowWidth = v
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "MinChildWindowWidth"
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

    On Error GoTo errmgr
    
    TRACE "Page.MinChildWindowHeight = " & v, w3rMETHOD
    g_static_lngMinChildWindowHeight = v
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "MinChildWindowHeight"
End Property



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function SendKeys(ByVal strKeys As String, Optional booWait As Boolean = False, Optional booNewProcess As Boolean = False, Optional lngTimeToWait As Long = 1) As Boolean
    SendKeys = g_objW3RunnerObject.SendKeys(strKeys, booWait, booNewProcess, lngTimeToWait, "Page")
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

    On Error GoTo errmgr
    
    TRACE "Page.UpdateWatchWindow = " & vNewValue, w3rMETHOD
    
    g_static_booUpdateWatchWindow = vNewValue
    If g_static_booUpdateWatchWindow Then
        frmMain.RefreshWatchWindow
    End If
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "UpdateWatchWindow"
End Property




'Public Function GrabScreen() As Boolean
'
'    Dim screenGrabber As New CScreenGrabber
'
'    'ScreenGrabber.Grab eGRAB_MODE_FULL_SCREEN, Environ("temp") & "\W3RunnerScreen" & GrabScreenCounter & ".bmp"
'    screenGrabber.Grab eGRAB_MODE_WINDOW, Environ("temp") & "\W3RunnerScreen.bmp", frmMain.HWND, frmMain.Width / VB.Screen.TwipsPerPixelX, frmMain.Height / VB.Screen.TwipsPerPixelY
'
'    GrabScreen = True
'End Function



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Helper() As CUIHelper

    On Error GoTo errmgr

    If Not IsValidObject(m_objUIHelper) Then
    
        Set m_objUIHelper = New CUIHelper
    End If
    Set Helper = m_objUIHelper
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Helper"
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get HTMLDocument() As HTMLDocument

    On Error GoTo errmgr
    
    TRACE PreProcess("Page.HTMLDocument"), w3rMETHOD
    Set HTMLDocument = MDMTestForm.HTMLDoc
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "HTMLDocument"
End Property

Public Property Get Form() As Form

    On Error GoTo errmgr
    
    'TRACE PreProcess("Page.Form"), w3rMETHOD
    Set Form = Me.MDMTestForm
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Form"
End Property

Public Property Get WebBrowser() As WebBrowser

    On Error GoTo errmgr
    
    'TRACE PreProcess("Page.WebBrowser"), w3rMETHOD
    Set WebBrowser = MDMTestForm.WebBrowser
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "WebBrowser"
End Property


Public Property Get WebBrowserHWND(Optional ByVal strWindowsObjectClassName As String = CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_INTERNET_EXPORER_SERVER) As Long

    On Error GoTo errmgr
    
    WebBrowserHWND = MDMTestForm.WebBrowserHWND(strWindowsObjectClassName)
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "WebBrowserHWND"
End Property








Public Property Get AutoFireEvent() As Boolean
    AutoFireEvent = g_static_booAutoFireEvent
End Property

Public Property Let AutoFireEvent(ByVal vNewValue As Boolean)
    g_static_booAutoFireEvent = vNewValue
End Property





Public Function GetHTMLObjectName(ByVal o As Object) As String
    GetHTMLObjectName = g_objHelper.GetHTMLObjectName(o)
End Function

Public Function GetHTMLObjectProperty(ByVal o As Object, ByVal strPropertyName As String) As Variant
    GetHTMLObjectProperty = g_objHelper.GetHTMLObjectProperty(o, strPropertyName)
End Function







Public Function SendChars(ByVal strChars As String) As Boolean

    Dim objWin As New cWindows
    
    frmMain.TRACE PreProcess("Page.SendChars [DC][VALUE][DC]", "VALUE", strChars, "DC", """"), w3rMETHOD
    SendChars = objWin.SendCharString(Me.WebBrowserHWND, strChars)
End Function

Public Function BreakPoint() As Boolean

    Debug.Assert 0
    BreakPoint = True
End Function

Public Function ClearTrace() As Boolean
    Me.TRACE "", w3rCLEAR_TRACE
End Function










Public Function CloseWindow() As Boolean

    On Error GoTo errmgr

    Debug.Print "D>CloseWindow() Page=" & ObjPtr(Me) & " ParentForm=" & ObjPtr(MDMTestForm)

    TRACE "Page.CloseWindow", w3rMETHOD
    
    CloseWindow = MDMTestForm.CloseWindow()
    Me.Delete
    
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "CloseWindow"
End Function



' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' Functions implemented for compatibility reason
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Public Property Get VBScriptEngine() As Object
    Set VBScriptEngine = g_objW3RunnerObject.VBScriptEngine
End Property

Public Function Wait(ByVal dblSecond As Double, Optional eFlags As w3rWAIT_MODE = w3rWAIT_MODE_DEFAULT) As Boolean
    Wait = g_objW3RunnerObject.Wait(dblSecond, eFlags)
End Function

Public Function Environ(Optional ByVal varKey As Variant) As String
    Environ = g_objW3RunnerObject.Environ(varKey)
End Function
Public Function TRACE(ByVal strMessage As String, Optional ByVal eMode As eW3RunnerTraceMode = w3rINFO) As Boolean
    TRACE = g_objW3RunnerObject.TRACE(strMessage, eMode)
End Function
Public Property Get SlowMode() As Long
    SlowMode = g_objW3RunnerObject.SlowMode
End Property
Public Property Let SlowMode(ByVal vNewValue As Long)
    g_objW3RunnerObject.SlowMode = vNewValue
End Property
Public Function Failed(ByVal booExpression As Boolean, ByVal strMessage As String) As Boolean
    Failed = g_objW3RunnerObject.Failed(booExpression, strMessage)
End Function
Public Function Succeed(ByVal booExpression As Boolean, ByVal strMessage As String) As Boolean
    Succeed = g_objW3RunnerObject.Succeed(booExpression, strMessage)
End Function
Public Property Get CancelScript() As Boolean
    CancelScript = g_objW3RunnerObject.CancelScript
End Property
Public Property Let CancelScript(v As Boolean)
    g_objW3RunnerObject.CancelScript = v
End Property
Public Property Get ScriptFileName() As String
    ScriptFileName = g_objW3RunnerObject.ScriptFileName
End Property
Public Property Get ScriptFilePath() As String
    ScriptFilePath = g_objW3RunnerObject.ScriptFilePath
End Property
Public Property Get TextFile() As cTextFile
    Set TextFile = g_objW3RunnerObject.TextFile
End Property
Public Property Get WinApi() As cWindows
    Set WinApi = g_objW3RunnerObject.WinApi
End Property
Public Property Get CommandLine() As CCommandLine
    Set CommandLine = g_objCommandLine
End Property
Public Function Test(ByVal booExpression As Boolean, ByVal strMessage As String) As Boolean
    Test = g_objW3RunnerObject.Test(booExpression, strMessage)
End Function
Public Property Get Arguments(ByVal strName As String, Optional ByVal varDefaultValue As Variant) As Variant
    Arguments = g_objW3RunnerObject.Arguments(strName, varDefaultValue)
End Property

Public Function Post(ByVal strURL As String, Optional ByVal strTargetFrame As String, Optional ByVal lngFlags As Long) As Boolean

    Dim strHeaders      As String
    Dim objInputHeader  As CVariable
    Dim arrPostData()   As Byte
    
    TRACE PreProcess("Page.Post [DC][URL][DC],[DC][TARGET][DC],[DC][FLAGS][DC]", "DC", """", "URL", strURL, "TARGET", strTargetFrame, "FLAGS", lngFlags), w3rMETHOD
     
    If InputHeaders.Count Then
        
        For Each objInputHeader In InputHeaders
        
            strHeaders = strHeaders & objInputHeader.Name & ": " & objInputHeader.Value & vbNewLine
        Next
    Else
        strHeaders = "Content-Type: application/x-www-form-urlencoded" & vbNewLine ' Default value
    End If
    
    arrPostData = StrConv(GetPOSTParametersString(), vbFromUnicode)
    
    g_objHTTP.TransformURL strURL, g_objHTTP.Port
    
    With g_objW3RunnerPostTempData
        .URL = strURL
        .Flags = lngFlags
        .TargetFrame = strTargetFrame
        .PostData = arrPostData
        .Headers = strHeaders
    End With
    frmMain.tmrPOSTURL.Enabled = True
    Post = True

End Function

Public Property Let URL(ByVal vNewValue As String)

    On Error GoTo errmgr

    m_strURL = vNewValue
    
    TRACE PreProcess("Page.URL =[DC][VNEWVALUE][DC]", "DC", """", "VNEWVALUE", vNewValue), w3rMETHOD

    g_objHTTP.TransformURL m_strURL, g_objHTTP.Port

    MDMTestForm.AsyncURL = m_strURL
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "URL"
End Property


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function GetPOSTParametersString() As String
        
    Dim objVariable As CVariable
    Dim strParameters  As String
    
    If Me.Parameters.Count Then
        
        For Each objVariable In Me.Parameters
        
            strParameters = strParameters & objVariable.Name & "=" & EncodeUrl(objVariable.Value) & "&"
        Next
        If Len(strParameters) Then If Mid(strParameters, Len(strParameters), 1) = "&" Then strParameters = Mid(strParameters, 1, Len(strParameters) - 1)

        GetPOSTParametersString = strParameters
    End If
End Function

' NOT_USED
Public Function InitializeFromApplication(Optional strTitle As String, Optional strWindowsObjectClassName As String = CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_INTERNET_EXPORER_SERVER) As Boolean

'    Dim wo As New CHWNDWindowsObject
'    Dim om As New CWindowObjectMapper
'    Dim IEApi   As New CIEApi
'    Dim lngWebBrowserHWND As Long
'
'    If wo.InitializeFromApplicationTitle(strTitle) Then
'
'        lngWebBrowserHWND = om.GetWebBrowserHWNDFromHWNDParent(wo.HWND, strWindowsObjectClassName)
'
'        MsgBox TypeName(IEApi.IEDocument(lngWebBrowserHWND))
'
'        InitializeFromApplication = True
'    End If
End Function
