Attribute VB_Name = "cSubClassModule"
Option Explicit

Declare Function PostMessage Lib "user32" Alias "PostMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal hwnd As Long, ByVal msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

'Public Const WM_MENUSELECT = &H11F
'
'Public Const WM_KEYFIRST = &H100
'Public Const WM_KEYDOWN = &H100
'Public Const WM_KEYUP = &H101
'Public Const WM_CHAR = &H102
'Public Const WM_DEADCHAR = &H103
'Public Const WM_SYSKEYDOWN = &H104
'Public Const WM_SYSKEYUP = &H105
'Public Const WM_SYSCHAR = &H106
'Public Const WM_SYSDEADCHAR = &H107
'Public Const WM_KEYLAST = &H108
'
'Public Const WM_MOUSEFIRST = &H200
'Public Const WM_MOUSEMOVE = &H200
'Public Const WM_LBUTTONDOWN = &H201
'Public Const WM_LBUTTONUP = &H202
'Public Const WM_LBUTTONDBLCLK = &H203
'Public Const WM_RBUTTONDOWN = &H204
'Public Const WM_RBUTTONUP = &H205
'Public Const WM_RBUTTONDBLCLK = &H206
'Public Const WM_MBUTTONDOWN = &H207
'Public Const WM_MBUTTONUP = &H208
'Public Const WM_MBUTTONDBLCLK = &H209


' Recorded window message
Type TRecWinMsg
    Name        As String
    hw          As Long
    uMsg        As Long
    wParam      As Long
    lParam      As Long
    timing      As Long
End Type

Public HookedControls As New Collection

'LRESULT CALLBACK CallWndProc(  int nCode,      // hook code
'  WPARAM wParam,  // current-process flag  LPARAM lParam   // message data);

Function WindowProcHookEx(ByVal ncode As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

    On Error Resume Next
    
    Dim aSubClass As cSubClass
    
    Err.Clear
    Set aSubClass = HookedControls.Item(1)
    If Err.Number = 0 Then
    
        aSubClass.WindowProcHookEx ncode, wParam, lParam
        WindowProcHookEx = CallNextHookEx(aSubClass.OldWndProc, ncode, wParam, lParam)
    Else
        Err.Clear
    End If

End Function

Function WindowProc(ByVal hw As Long, ByVal uMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

    On Error Resume Next
    
    Dim aSubClass           As cSubClass
    Dim booCallOldWinProc   As Boolean
    
     
    ' Debug.Print WindowMessageString(uMsg) & "; hwnd="
    
    Err.Clear
    Set aSubClass = HookedControls.Item("H" & hw)
    If Err.Number = 0 Then
        booCallOldWinProc = True
        aSubClass.WindowProcCall hw, uMsg, wParam, lParam, booCallOldWinProc
        If (booCallOldWinProc) Then
            WindowProc = CallWindowProc(aSubClass.OldWndProc, hw, uMsg, wParam, lParam)
        End If
    Else
        Err.Clear
    End If
    
End Function

Public Sub SendAMouseUp(hwnd As Long)
    
    Const WM_LBUTTONUP = &H2020
    SendMessage hwnd, WM_LBUTTONDOWN, 1111111, 1111
End Sub
