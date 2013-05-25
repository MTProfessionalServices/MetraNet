VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CConsoleWindow"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_lngConsoleHandle  As Long
Private m_hOutPutConsole    As Long
Private m_hInPutConsole     As Long
Private m_Caption           As String
Private m_booOpen           As Boolean
Public hwnd                 As Long
Public KeyBoard             As New CConsoleKeyBoard

Public Function Initialize(strCaption As String) As Boolean
    
    If (Not m_booOpen) Then
    
        m_lngConsoleHandle = AllocConsole()
        
        Set KeyBoard.Parent = Me
        
        If (KeyBoard.Load()) Then
            
            If (InitStdOuput()) Then
            
                InitHWND
                Caption = strCaption
                
                'SetConsoleMode
                
'Public Const ENABLE_LINE_INPUT = &H2
'Public Const ENABLE_ECHO_INPUT = &H4
'Public Const ENABLE_MOUSE_INPUT = &H10
'Public Const ENABLE_PROCESSED_INPUT = &H1
'Public Const ENABLE_WINDOW_INPUT = &H8
                
                Initialize = True
            End If
        End If
    End If
    m_booOpen = True
    Exit Function
ErrMgr:
    Debug.Assert 0
End Function

Public Function WriteText(strText As String, Optional booNewLine As Boolean = True) As Boolean

    Dim lngWrittenChar As Long
    
    WriteConsole m_hOutPutConsole, strText, Len(strText), lngWrittenChar, vbNullString
    
    If (booNewLine) Then WriteText vbCrLf, False
    
    WriteText = True
End Function

Public Function UnLoad() As Boolean

    If (m_booOpen) Then
        KeyBoard.UnLoad
        CloseHandle m_hOutPutConsole
        FreeConsole
    End If
    UnLoad = True
    Exit Function
ErrMgr:
    Debug.Assert 0
End Function

Public Property Get Caption() As String
    Caption = m_Caption
End Property

Public Property Let Caption(ByVal vNewValue As String)
    m_Caption = vNewValue
    'SetWindowText hwnd, m_Caption
    SetConsoleTitle m_Caption
End Property

Public Function Show() As Boolean
    ShowWindow Me.hwnd, SW_SHOW
    Show = True
End Function

Public Function Hide() As Boolean
    ShowWindow Me.hwnd, SW_HIDE
    Hide = True
End Function

Public Function Minimize() As Boolean
    ShowWindow Me.hwnd, SW_SHOWMINIMIZED
    Minimize = True
End Function

Public Function Restore() As Boolean
    ShowWindow Me.hwnd, SW_SHOWNORMAL
    Restore = True
End Function

Public Function Maximize() As Boolean
    ShowWindow Me.hwnd, SW_SHOWMAXIMIZED
    Maximize = True
End Function

Public Function Execute(strApp As String) As Boolean
    On Error GoTo ErrMgr
    Shell strApp
    Execute = True
    Exit Function
ErrMgr:
    Debug.Assert 0
End Function

Public Function InitStdOuput() As Boolean

    m_hOutPutConsole = GetStdHandle(STD_OUTPUT_HANDLE)
    m_hInPutConsole = GetStdHandle(STD_INPUT_HANDLE)

    InitStdOuput = (m_hOutPutConsole <> 0)
End Function

Public Function InitHWND() As Boolean

        DoEvents
        hwnd = GetForegroundWindow()
        InitHWND = hwnd <> 0
End Function

Public Function SendChar(strS As String, Optional booSync As Boolean = False) As Boolean
    Const WM_CHAR = &H102
    Dim i As Long
    
    For i = 1 To Len(strS)
        If (booSync) Then
            SendMessage hwnd, WM_CHAR, Asc(Mid(strS, i, 1)), 0
        Else
            PostMessage hwnd, WM_CHAR, Asc(Mid(strS, i, 1)), 0
        End If
    Next
    SendChar = True
End Function

Private Sub Class_Terminate()
    UnLoad
End Sub


Public Function ReadLn() As String

    Dim sUserInput As String
    sUserInput = Space(255)
    
    Dim lngChars As Long
    
    ReadConsole m_hInPutConsole, sUserInput, Len(sUserInput), lngChars, vbNull
        
    'Trim off the NULL charactors and the CRLF.
    sUserInput = Left$(sUserInput, InStr(sUserInput, Chr$(13)) - 1)
    
    
    ReadLn = sUserInput
End Function
