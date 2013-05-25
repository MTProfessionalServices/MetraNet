Attribute VB_Name = "cSubClassModule"
'**************************************************************************
' Copyright 1998, 2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' NAME          :   CSubClass.bas.
' DESCRIPTION   :   The class CSubClass.cls allows to do regular sub classing
'                   and Hook subclassing. But for that we need a module...
'
'
'***************************************************************************
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

