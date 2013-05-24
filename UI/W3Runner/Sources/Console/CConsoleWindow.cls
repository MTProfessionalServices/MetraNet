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
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_hOutPutConsole    As Long
Private m_Caption           As String
Private m_booOpen           As Boolean

Public hwnd                 As Long
Public KeyBoard             As New CConsoleKeyBoard

Public Function Load(strCaption As String) As Boolean

    Dim lngAllocConsoleRetCode As Long
    
    If (Not m_booOpen) Then
    
        
        lngAllocConsoleRetCode = AllocConsole()
        
        Set KeyBoard.Parent = Me
        
        If (KeyBoard.Load()) Then
            
            If (InitStdOuput()) Then
            
                InitHWND
                Caption = strCaption
                Load = True
            End If
        End If
    End If
    m_booOpen = True
    Exit Function
errmgr:
    Debug.Assert 0
End Function

Public Function WriteLn(strText As String, Optional booNewLine As Boolean = True) As Boolean

    Dim lngWrittenChar As Long
    
    WriteConsole m_hOutPutConsole, strText, Len(strText), lngWrittenChar, vbNullString
    
    If (booNewLine) Then WriteLn vbCrLf, False
    
    WriteLn = True
End Function

Public Function UnLoad() As Boolean

    If (m_booOpen) Then
        KeyBoard.UnLoad
        CloseHandle m_hOutPutConsole
        FreeConsole
        m_booOpen = False
    End If
    UnLoad = True
    Exit Function
errmgr:
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
    On Error GoTo errmgr
    Shell strApp
    Execute = True
    Exit Function
errmgr:
    Debug.Assert 0
End Function

Public Function InitStdOuput() As Boolean

    m_hOutPutConsole = GetStdHandle(STD_OUTPUT_HANDLE)
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

