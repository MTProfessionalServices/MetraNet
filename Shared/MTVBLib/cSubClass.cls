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
Attribute VB_Exposed = True
' ****************************************************************************************************************************************************
'
'  Copyright 1998-2000 by MetraTech Corporation
'  All rights reserved.
'
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 08/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
' PREVIOUS HISTORY
' ****************************************************************************************************************************************************
'
'                                           OoVbLib5
'
'                               Object Oriented Visual Basic Library
'
'                                     Visual Basic Version 5
'
'                                TORRES Frederic 1995,1996,1997
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' History :
'
'  From VbLib3 for Vb3 (Aix en pce)
'  From OoVbLib4 For Vb4 16b/32b (Marseille,xx/03/97)
'  From OoVbLib5 For Vb5 (Sophia,xx/01/1998)
'  From OoVbLib6 For Vb5 (Boston,21/11/1998)
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
'
' ******************************************************************************************************
Option Explicit



Public OldWndProc   As Long
Public hwnd         As Long
Public HookEx       As Boolean

Event WindowProcEvent(ByVal hw As Long, ByVal uMsg As Long, ByVal wParam As Long, ByVal lParam As Long, ByRef booCallOldWinProc As Boolean)
Event WindowProcHookExEvent(ByVal ncode As Long, ByVal wParam As Long, ByVal lParam As Long)

Private booRaiseOneEvent    As Boolean
Private frmCallBack         As Object

Private Function Hook(hw As Long, Optional DoHook As Boolean = True, Optional lngHINSTANCE As Long, Optional lngThreadId As Long) As Long

    If (HookEx) Then
        If DoHook Then
            OldWndProc = SetWindowsHookEx(WH_CALLWNDPROC, WindowProcHookExAddress(), lngHINSTANCE, lngThreadId)
            Hook = OldWndProc
        Else
            UnhookWindowsHookEx OldWndProc
        End If
    Else
        If DoHook Then
            OldWndProc = SetWindowLong(hw, GWL_WNDPROC, WindowProcAddress())
            Hook = OldWndProc
        Else
            Hook = SetWindowLong(hw, GWL_WNDPROC, OldWndProc)
        End If
    End If
End Function

Public Function Done() As Boolean
    On Error GoTo ErrMgr
    
    HookedControls.Remove "H" & hwnd
    Hook hwnd, False
    Done = True
    
    Exit Function
ErrMgr:

End Function

Public Function Init(ByVal lngHWND As Long, booRaiseEvent As Boolean, Optional objfrmCallBack As Object) As Boolean

    Dim mySelf As cSubClass
    
    Set mySelf = Me
    hwnd = lngHWND
    HookedControls.Add mySelf, "H" & hwnd
    Hook hwnd
    booRaiseOneEvent = booRaiseEvent
    Set frmCallBack = objfrmCallBack
    Init = True
End Function


Public Sub WindowProcCall(ByVal hw As Long, ByVal uMsg As Long, ByVal wParam As Long, ByVal lParam As Long, ByRef booCallOldWinProc As Boolean)
    If booRaiseOneEvent Then
        RaiseEvent WindowProcEvent(hw, uMsg, wParam, lParam, booCallOldWinProc)
    Else
        Dim i As ISubClass
        Set i = frmCallBack
        i.WindowProcCall hw, uMsg, wParam, lParam
    End If
End Sub

Function WindowProcHookEx(ByVal ncode As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
    If booRaiseOneEvent Then
        RaiseEvent WindowProcHookExEvent(ncode, wParam, lParam)
    Else
        
    End If
End Function

Public Function WindowProcAddress(Optional addr As Long) As Long
    If (addr = 0) Then
        WindowProcAddress = WindowProcAddress(AddressOf cSubClassModule.WindowProc)
    Else
        WindowProcAddress = addr
    End If
End Function


Public Function WindowProcHookExAddress(Optional addr As Long) As Long
    If (addr = 0) Then
        WindowProcHookExAddress = WindowProcHookExAddress(AddressOf cSubClassModule.WindowProcHookEx)
    Else
        WindowProcHookExAddress = addr
    End If
End Function

Public Function InitHook(booRaiseEvent As Boolean, lngHINSTANCE As Long, lngThreadId As Long) As Boolean

    Dim mySelf As cSubClass
    
    HookEx = True
    
    HookedControls.Add mySelf, "H1"
    
    Hook hwnd, , lngHINSTANCE, lngThreadId
    
    booRaiseOneEvent = booRaiseEvent
    
    InitHook = True
End Function


