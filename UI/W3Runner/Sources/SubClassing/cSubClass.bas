Attribute VB_Name = "cSubClassModule"
Option Explicit

'Public DebugStrings As New CStrings
Public strLog As String

Public Const CSubClass_HOOK_COLLECTION_ID = "HOOK"
Public Const HOOK_KBD_EVENT_ALT_FLAG = 536870912


Public HookedControls As New Collection


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Function WindowProcHookKeyboardEx(ByVal ncode As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

    On Error Resume Next
    
    Static booRunning   As Boolean
    Dim aSubClass       As cSubClass
    
    If (booRunning) Then Exit Function
    booRunning = True
    
    Err.Clear
    
    ' Find the item in the class -  we handle only one hook here
    Set aSubClass = HookedControls.Item("HOOK" & WH_KEYBOARD)
        
    If ((Err.Number = 0) And (Not aSubClass Is Nothing)) Then
    
        ' Call the class item function
        If (aSubClass.WindowProcHookEx(WH_KEYBOARD, ncode, wParam, lParam)) Then
        
            WindowProcHookKeyboardEx = CallNextHookEx(aSubClass.OldWndProc, ncode, wParam, lParam)
        Else
            WindowProcHookKeyboardEx = 1 ' Return OK to WINDOWS
        End If
    Else
        Debug.Print "Cannot find the instance..."
        Err.Clear
    End If
    booRunning = False
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Function WindowProcHookMouseEx(ByVal ncode As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

    On Error Resume Next
    
    Static booRunning   As Boolean
    Dim aSubClass       As cSubClass
    
    If (booRunning) Then Exit Function
    booRunning = True
    
    Err.Clear
    
    ' Find the item in the class -  we handle only one hook here
    Set aSubClass = HookedControls.Item("HOOK" & WH_MOUSE)
        
    If ((Err.Number = 0) And (Not aSubClass Is Nothing)) Then
    
        ' Call the class item function
        If (aSubClass.WindowProcHookEx(WH_MOUSE, ncode, wParam, lParam)) Then
        
            WindowProcHookMouseEx = CallNextHookEx(aSubClass.OldWndProc, ncode, wParam, lParam)
        Else
            WindowProcHookMouseEx = 1 ' Return OK to WINDOWS
        End If
    Else
        Debug.Print "Cannot find the instance..."
        Err.Clear
    End If
    booRunning = False
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Function WindowProc(ByVal hw As Long, ByVal uMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

    On Error Resume Next
    
    Dim aSubClass As cSubClass
    
    Err.Clear
    
    Set aSubClass = HookedControls.Item("H" & hw)
    
    If (Err.Number = 0) Then
    
        If (aSubClass.WindowProcCall(hw, uMsg, wParam, lParam)) Then
        
            WindowProc = CallWindowProc(aSubClass.OldWndProc, hw, uMsg, wParam, lParam)
        Else
            WindowProc = 1 ' Return OK to WINDOWS
        End If
    Else
        Err.Clear
    End If
End Function

