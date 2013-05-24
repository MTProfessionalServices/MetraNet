VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cSubClass"
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
'  DATE         : 01/xx/1998
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit


Const str0 = "00000000000"

Public OldWndProc   As Long
Public HWND         As Long
Public HookEx       As Boolean


Public ControlKeyDown As Boolean

Public Event WindowProcEvent(ByVal hw As Long, ByVal uMsg As Long, ByVal wParam As Long, ByVal lParam As Long, ByRef lngRetCode As Long)
Public Event WindowProcHookExEvent(ByVal lngHookType As Long, ByVal ncode As Long, ByVal wParam As Long, ByVal lParam As Long, ByRef lngRetCode As Long)

Private m_lngHookType As Long

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Hook
' DESCRIPTION   : Set the WindowProc or the Hook CallBack function. Store the old WindowProc function or Hook Handle in
'                 OldWndProc. And return it too
' PARAMETERS    :
'                       lngHWND         : Is used only for regular subclassing...
'                       lngHINSTANCE    : Is used for hook subclassing
'                       lngThreadId     : Is used for hook subclassing
' RETURNS       :
Private Function Hook(lngHWND As Long, Optional DoHook As Boolean = True, Optional lngHINSTANCE As Long, Optional lngThreadId As Long) As Long
    If (HookEx) Then
        If DoHook Then
            ' For now hook only the keyboard
            
            Select Case m_lngHookType
            
                Case WH_KEYBOARD
                    OldWndProc = SetWindowsHookEx(m_lngHookType, AddressOf cSubClassModule.WindowProcHookKeyboardEx, 0, lngThreadId)
                    Hook = True
                    
                Case WH_MOUSE
                    OldWndProc = SetWindowsHookEx(m_lngHookType, AddressOf cSubClassModule.WindowProcHookMouseEx, 0, lngThreadId)
                    Hook = True
                    
                Case Else
                    Hook = False ' fails
            End Select
            
            Hook = OldWndProc
        Else
            UnhookWindowsHookEx OldWndProc
        End If
    Else
        If DoHook Then
            OldWndProc = SetWindowLong(lngHWND, GWL_WNDPROC, AddressOf cSubClassModule.WindowProc)
            Hook = OldWndProc
        Else
            Hook = SetWindowLong(lngHWND, GWL_WNDPROC, OldWndProc)
        End If
    End If
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Done
' DESCRIPTION   : Stop the call function mecanism. This call is mandatory else your application/machine will crash...
' PARAMETERS    :
' RETURNS       :
Public Function done() As Boolean

    On Error GoTo errmgr
    
    Hook HWND, False
    If (HookEx) Then
        HookedControls.Remove CSubClass_HOOK_COLLECTION_ID & m_lngHookType
    Else
        HookedControls.Remove "H" & HWND
    End If
    done = True
    
    Exit Function
errmgr:

End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : InitSubClass
' DESCRIPTION   : Init a regular subclassing to any Windows object.
' PARAMETERS    :
' RETURNS       :
Public Function InitSubClass(ByVal lngHWND As Long) As Boolean

    Dim mySelf As cSubClass
    
    Set mySelf = Me
    HWND = lngHWND
    HookedControls.Add mySelf, "H" & HWND
    Hook HWND
    InitSubClass = True
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : WindowProcCall
' DESCRIPTION   : This function is the call back function for the regular sub classing
' RETURNS       : This function must return a >0 value if ok
Public Function WindowProcCall(ByVal hw As Long, ByVal uMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

    Dim lngRetCode As Long
    
    RaiseEvent WindowProcEvent(hw, uMsg, wParam, lParam, lngRetCode)
    WindowProcCall = lngRetCode
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Function WindowProcHookEx(ByVal lngHookType As Long, ByVal ncode As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

    Dim lngRetCode As Long
    
    lngRetCode = 1 ' Default value must be OK because if the event is not implemented it would return 0
    
    RaiseEvent WindowProcHookExEvent(lngHookType, ncode, wParam, lParam, lngRetCode)
    WindowProcHookEx = lngRetCode
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : InitHook
' DESCRIPTION   : Init a hook for the application
' PARAMETERS    :
' RETURNS       :
Public Function InitHook(lngHookType As Long, lngHINSTANCE As Long, lngThreadId As Long) As Boolean

    HookEx = True
    m_lngHookType = lngHookType
    
    If (m_lngHookType <> WH_KEYBOARD) And (m_lngHookType <> WH_MOUSE) Then
    
        Exit Function
    End If
    
    HookedControls.Add Me, CSubClass_HOOK_COLLECTION_ID & m_lngHookType
    Hook HWND, , lngHINSTANCE, lngThreadId
    InitHook = True
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : kbdEventIsAltOn
' DESCRIPTION   : Return TRUE if the ALT flag is set. That for a Hook Keyboard Event only.
' PARAMETERS    :
' RETURNS       :
Public Function kbdEventIsAltOn(lParam As Long) As Boolean

    kbdEventIsAltOn = (lParam And HOOK_KBD_EVENT_ALT_FLAG) = HOOK_KBD_EVENT_ALT_FLAG
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : kbdEventIsKeyDown
' DESCRIPTION   : Return TRUE if the KEY DOWN flag is on...
'                 Since this flag is the bit 31  and vb does not support unsigned long.
'                 we have to test the sign...
' PARAMETERS    :
' RETURNS       :
Public Function kbdEventIsKeyDown(lParam As Long) As Boolean

    kbdEventIsKeyDown = Not (lParam < 0) ' The 31 bit is set
End Function

