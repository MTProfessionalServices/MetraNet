VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CHWNDWindowsObject"
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
'  DATE         : 08/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Const W3RUNNER_VB6_CLIENT_PROTOCOL = "GetControlsInfo"

Const MAX_WINDOWS_STRING_ID = 256

Private m_lngHwnd           As Long
Private m_booTraceMethod    As Boolean
Private m_strName           As String

Public W3RunnerAX           As CHWNDWindowsObject ' W3Runner ActiveX For VB6
Public Connected            As Boolean
Public ControlsMap          As CVariables
Public VbType               As String

Public Function Initialize(ByVal lngHWND As Long, ByVal strName As String, ByVal strVBType As String) As Boolean
    HWND = lngHWND
    m_strName = strName
    VbType = UCase$(strVBType)
    Initialize = True
End Function

Public Property Get HWND() As Long
    HWND = m_lngHwnd
End Property

Public Property Let HWND(ByVal v As Long)
    m_lngHwnd = v
End Property

Public Function SendMessage(ByVal lngMESSAGE As Long, Optional ByVal lngWPARAM As Long, Optional ByVal lngLPARAM As Long, Optional booPost As Boolean = False, Optional booTrace As Boolean = True) As Long

    SendMessage = g_objW3RunnerObject.SendMessage(m_lngHwnd, lngMESSAGE, lngWPARAM, lngLPARAM, booPost, booTrace, Me.Name)
End Function

Public Property Get ClassName() As String

    ClassName = GetClassName(m_lngHwnd)
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Function

Public Function IsWindow() As Boolean

   IsWindow = CBool(cWindowsModule.IsWindow(m_lngHwnd))
   If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Function

Public Property Get Visible() As Boolean

   Visible = CBool(cWindowsModule.IsWindowVisible(m_lngHwnd))
   If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Property

Public Property Let Visible(ByVal vNewValue As Boolean)
    
    cWindowsModule.ShowWindow m_lngHwnd, IIf(vNewValue, SW_SHOWNORMAL, SW_HIDE)
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Property

Public Function Show(Optional eFlag As WINDOWS_API_SW = SW_SHOWNORMAL) As Boolean
    Visible = True
    Show = True
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Function
 
Public Property Get Text() As String

    Select Case Me.VbType
        Case "COMBOBOX"
        Case "LISTBOX"
        Case Else
            Text = GetText(m_lngHwnd)
    End Select
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Property

Public Property Let Text(ByVal strText As String)

    Dim strAction As String

    strAction = Me.Name & PreProcess(".Text = [DC][TEXT][DC]", "TEXT", strText, "DC", """")
    frmMain.TRACE strAction, w3rMETHOD
    
    Select Case Me.VbType
        Case "COMBOBOX"
            SendMessageAny Me.HWND, CB_SELECTSTRING, 0, strText
        Case "LISTBOX"
            SendMessageAny Me.HWND, LB_SELECTSTRING, 0, strText
        Case Else
            SetText m_lngHwnd, strText
    End Select
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Show
End Property

Public Function SetText(ByVal lngHWND As Long, ByVal strText As String) As Boolean

    SendMessageAny HWND, WM_SETTEXT, 0, strText
End Function

Public Function GetText(ByVal lngHWND As Long) As String

'    Dim lngChar0Pos     As Long
'    Dim strString       As String
'
'    strString = Space(MAX_WINDOWS_STRING_ID)
'    cWindowsModule.GetWindowText lngHWND, strString, MAX_WINDOWS_STRING_ID
'    lngChar0Pos = InStr(strString, Chr$(0))
'    If lngChar0Pos Then
'        GetText = Left$(strString, lngChar0Pos - 1)
'    Else
'        GetText = strString
'    End If

    Dim Buffer              As M_SendMessageAnyByRefLParam
    Dim lngChar0Pos         As Long
    
    SendMessageAnyByRef Me.HWND, WM_GETTEXT, Len(Buffer), Buffer
    
    lngChar0Pos = InStr(Buffer.m_string, Chr$(0))
    
    If lngChar0Pos Then
    
        GetText = Left$(Buffer.m_string, lngChar0Pos - 1)
    End If
    
End Function

Public Property Get Controls(Optional strNameOrText As String, Optional ByVal strClassName As String, Optional ByVal strFrame As String, Optional ByVal lngIndex As Long = 1) As CHWNDWindowsObject

    Dim lngHwndPeer             As Long
    Dim lngResult               As Long
    Dim strChildrenClassName    As String
    Dim objChild                As CHWNDWindowsObject
    Dim booOk                   As Boolean
    Dim lngCurrentIndex         As Long
    Dim strNameID               As String
    Dim strVBType               As String
    Dim strVisualBasicIndex     As String
    
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    
    If Len(strNameOrText) And IsValidObject(ControlsMap) Then ' Name id defined we are dealing with a VB6 app + W3Runner Ax
    
        lngHwndPeer = Me.ControlsMap(strNameOrText).Value
        strVBType = Me.ControlsMap(strNameOrText).VbType
        strNameID = strNameOrText
        GoTo ReturnObject
    End If
    
    strClassName = UCase$(strClassName)
    strNameOrText = UCase$(strNameOrText)
    
    lngHwndPeer = GetWindow(m_lngHwnd, GW_CHILD)
    If lngHwndPeer = 0 Then
        FShowError PreProcess("The WindowsObjects [NAME] does not have any control[CRLF]ClassName=[CLASSNAME]; Text=[TEXT];", "NAME", Name, "CLASSNAME", Me.ClassName, "TEXT", Me.Text)
        Exit Property
    End If
    
    Do While (lngHwndPeer <> 0)
        
        If Len(strClassName) Then  ' Look up on class
        
            If InStr(UCase$(Me.GetClassName(lngHwndPeer)), strClassName) Then
                
                booOk = True
                If Len(strNameOrText) Then
                
                    booOk = InStr(UCase$(Me.GetText(lngHwndPeer)), strNameOrText)
                    If Not booOk Then booOk = InStr(UCase$(Me.GetWindowText(lngHwndPeer)), strNameOrText)
                End If
                
                If booOk Then lngCurrentIndex = lngCurrentIndex + 1
                
                If booOk And lngIndex = lngCurrentIndex Then
                    GoTo ReturnObject
                End If
            End If
        End If
        lngHwndPeer = GetWindow(lngHwndPeer, GW_HWNDNEXT)
    Loop
    Exit Property
ReturnObject:
    Set objChild = New CHWNDWindowsObject
    objChild.Initialize lngHwndPeer, strNameID, strVBType
    Set Controls = objChild
    Exit Property
End Property

Public Function SendChars(ByVal strChars As String) As Boolean

    SendChars = g_objW3RunnerObject.SendChars(Me.HWND, strChars, Me.Name)
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Function

Public Property Let Name(v As String)
    m_strName = v
End Property

Public Property Get Name() As String

    Dim strName As String
    Dim strText As String
    
    strName = m_strName
    
    If Len(strName) = 0 Then
        strText = Me.Text
        If Len(strText) Then
            strName = "WindowsObjects(""" & Me.ClassName & ":" & strText & """)"
        End If
        If Len(strName) = 0 Then strName = "WindowsObjects(""" & Me.ClassName & ":" & HWND & """)"
    End If
    Name = strName
End Property

Public Function SendKeys(ByVal strKeys As String, Optional booWait As Boolean = False, Optional booNewProcess As Boolean = False, Optional lngTimeToWait As Long = 1, Optional strTraceObject As String = "Screen") As Boolean

    SendKeys = g_objW3RunnerObject.SendKeys(strKeys, booWait, booNewProcess, lngTimeToWait, Me.Name)
    
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Function

Public Function PostMessage(ByVal lngMESSAGE As Long, Optional ByVal lngWPARAM As Long, Optional ByVal lngLPARAM As Long) As Boolean

    PostMessage = SendMessage(lngMESSAGE, lngWPARAM, lngLPARAM, True, True)
End Function

Private Sub Class_Initialize()
    m_booTraceMethod = True
End Sub

Public Property Get Caption() As String
    Caption = Me.Text
End Property

Public Property Let Caption(ByVal v As String)
    Text = v
End Property

Public Function Connect() As Boolean

    Set W3RunnerAX = Me.Controls("W3RunnerAx4VB6Lib", "THUNDERRT6USERCONTROLDC")
    
    If Not IsValidObject(W3RunnerAX) Then
        Set W3RunnerAX = Me.Controls("W3RunnerAx4VB6Lib", "ThunderUserControlDC") ' Control in VB IDE
    End If
    Connected = IsValidObject(W3RunnerAX)
    If Connected Then
    
        Connected = axGetControlsInfo()
        Connect = Connected
    End If
End Function

Public Function SetFocus() As Boolean

    frmMain.TRACE Me.Name & ".SetFocus", w3rMETHOD
    Me.SendMessage WM_SETFOCUS
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Function

Public Sub Click(Optional ByVal x As Long, Optional ByVal Y As Long, Optional eFlag As w3rITEM_CLICK_FLAG = w3rITEM_CLICK_FLAG_LEFT_CLICK + w3rITEM_CLICK_FLAG_WM_MOUSE_DOWN + w3rITEM_CLICK_FLAG_WM_MOUSE_UP)

    Dim lngWM_BUTTONDOWN    As Long
    Dim lngWM_BUTTONUP      As Long
    Dim nMousePosition      As Long
    
    If eFlag And w3rITEM_CLICK_FLAG_RIGHT_CLICK Then
    
        lngWM_BUTTONDOWN = WM_RBUTTONDOWN: lngWM_BUTTONUP = WM_RBUTTONUP
    Else
        lngWM_BUTTONDOWN = WM_LBUTTONDOWN: lngWM_BUTTONUP = WM_LBUTTONUP
    End If
    
    MakeLParam nMousePosition, Y, x
    
    SendMessage lngWM_BUTTONDOWN, MK_LBUTTON, ByVal nMousePosition, , False
    DoEvents
    SendMessage lngWM_BUTTONUP, MK_LBUTTON, ByVal nMousePosition, , False
    
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Sub


Public Function GetClassName(ByVal lngHWND As Long) As String

    Dim lngChar0Pos     As Long
    Dim strString       As String
    
    strString = Space(MAX_WINDOWS_STRING_ID)
    cWindowsModule.GetClassName lngHWND, strString, MAX_WINDOWS_STRING_ID
    lngChar0Pos = InStr(strString, Chr$(0))
    If lngChar0Pos Then
        GetClassName = Left$(strString, lngChar0Pos - 1)
    Else
        GetClassName = strString
    End If

    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Function

Public Function GetWindowText(ByVal lngHWND As Long) As String

    Dim lngChar0Pos     As Long
    Dim strString       As String

    strString = Space(MAX_WINDOWS_STRING_ID)
    cWindowsModule.GetWindowText lngHWND, strString, MAX_WINDOWS_STRING_ID
    lngChar0Pos = InStr(strString, Chr$(0))
    If lngChar0Pos Then
        GetWindowText = Left$(strString, lngChar0Pos - 1)
    Else
        GetWindowText = strString
    End If
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Function

Public Function SendCommandToW3RunnerAx(strCommand As String) As Boolean

    Dim objWin As New cWindows
    
    SendCommandToW3RunnerAx = objWin.SendCharString(Me.W3RunnerAX.HWND, strCommand & Chr(13))
    
    If (m_booTraceMethod) Then
        Sleep 10
        StuffToDoForAfterEachMethod
    End If
End Function

Public Function axGetControlsInfo() As Boolean

    Dim objTextFile As New cTextFile
    Dim strFileName As String
    Dim strName     As String
    Dim strHWND     As String
    Dim strType     As String
    Dim strIndex    As String
    
    strFileName = Environ("temp") & "\W3RunnerAx.txt"
    Set ControlsMap = New CVariables
    
    If SendCommandToW3RunnerAx(W3RUNNER_VB6_CLIENT_PROTOCOL) Then
        
        If objTextFile.OpenFile(strFileName) Then
        
            Do While Not objTextFile.EOF
            
                strName = UCase$(objTextFile.ReadLn())
                
                Select Case strName
                
                    Case "CONTROL"
                        strName = UCase$(objTextFile.ReadLn())
                        strType = UCase$(objTextFile.ReadLn())
                        strHWND = objTextFile.ReadLn()
                        strIndex = objTextFile.ReadLn()
                        
                        ControlsMap.Add strName, strHWND, strType, , strIndex ' index is set has a caption
                End Select
            Loop
            objTextFile.CloseFile
            axGetControlsInfo = True
        End If
    End If
End Function
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Wait(ByVal dblSecond As Double, Optional eFlags As w3rWAIT_MODE = w3rWAIT_MODE_DEFAULT) As Boolean

    On Error GoTo errmgr
    
    frmMain.TRACE Me.Name & ".Wait " & dblSecond, w3rMETHOD
    
    Wait = W3RunnerMod.Wait(dblSecond, eFlags)
    GlobalDoEvents
    Wait = True
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), "CHWNDWindowsObject.cls", "Wait"
End Function

Public Property Get Value() As Boolean

    Select Case Me.VbType
        Case "COMBOBOX"
        Case "LISTBOX"
        Case "CHECKBOX"
            Value = SendMessage(BM_GETCHECK, ByVal CLng(0), ByVal CLng(0)) = BST_CHECKED
        Case Else
    End Select
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Property

Public Property Let Value(ByVal v As Boolean)

    frmMain.TRACE Me.Name & PreProcess(".Value = [VALUE]", "VALUE", v, "DC", """"), w3rMETHOD
    
    Select Case Me.VbType
        Case "COMBOBOX"
        Case "LISTBOX"
        Case "CHECKBOX", "OPTIONBUTTON"
            SendMessage BM_SETCHECK, IIf(v, BST_CHECKED, BST_UNCHECKED), ByVal CLng(0)
        Case Else
    End Select
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Show
End Property

Public Property Get ListCount() As Long
    
    Select Case Me.VbType
        Case "COMBOBOX"
            ListCount = SendMessage(CB_GETCOUNT)
        Case "LISTBOX"
            ListCount = SendMessage(LB_GETCOUNT)
    End Select
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Property


Public Property Get Windows(Optional strNameOrText As String, Optional ByVal strClassName As String, Optional ByVal strFrame As String, Optional ByVal lngIndex As Long = 1) As CHWNDWindowsObject
    Set Windows = Controls(strNameOrText, strClassName, strFrame, lngIndex)
End Property

Public Function InitializeFromApplicationTitle(ByVal strTitle As String) As Boolean
    
    Dim lngHWND As Long
    
    
    lngHWND = FindWindow(vbNullString, strTitle)
    If lngHWND Then
        InitializeFromApplicationTitle = Initialize(lngHWND, strTitle, "Window")
    End If
End Function
