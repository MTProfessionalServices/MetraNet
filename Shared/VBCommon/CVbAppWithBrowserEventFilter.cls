VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CIEEventFilter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
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
' NAME          :   CVbAppWithBrowserFilter
' DESCRIPTION   :   This class is a full wrapper that filter and cancel some
'                   IE event like : F5, Alt left and right Arrow, Ctrl O, Ctrl N
'                   and the right mouse click.
'
'                   How to use it : just include
'
'
'***************************************************************************

Option Explicit

' This object is set to filter some window events at a very low level
' We cancel keystroke like F5,Alt Left Arrow, Alt Right Left Arrow, Ctrl-End, Ctrl-O
' Mouse Right Click If I can...F.TORRES!
Private WithEvents mobjKeyboardFilter   As cSubClass
Attribute mobjKeyboardFilter.VB_VarHelpID = -1
Private WithEvents mobjMouseFilter      As cSubClass
Attribute mobjMouseFilter.VB_VarHelpID = -1

' The Filter Debug Mode allows to print in the immediate windows some string info
' about the keysstroke and mouse event. In release mode the CallBack function or
' event should not lose time building debug string that are not used so I used
' Conditional Compilation to remove the code
' Always reset the flag to false before you check in in STAR TEAM.
' (If you forgot that's not a big deal)!
#Const DEBUG_FILTER_MODE = False

Private Sub Class_Initialize()
        
    ' Add a KEYBOARD Filter
    Set mobjKeyboardFilter = New cSubClass
    mobjKeyboardFilter.InitHook WH_KEYBOARD, App.hInstance, App.ThreadID
    
    ' Add a KEYBOARD Filter
    Set mobjMouseFilter = New cSubClass
    mobjMouseFilter.InitHook WH_MOUSE, App.hInstance, App.ThreadID
        
End Sub

Private Sub Class_Terminate()
    mobjKeyboardFilter.done
    Set mobjKeyboardFilter = Nothing
    
    mobjMouseFilter.done
    Set mobjMouseFilter = Nothing
End Sub



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   mobjKeyboardFilter_WindowProcHookExEvent
' DESCRIPTION   :   This event is raised when the Hook CallBack function is called!
' PARAMETERS    :   The parameters are the same as the CallBack Functionaaa
'
'                   Here is the definition for a KEYBOARD Event.
'                   LRESULT CALLBACK KeyboardProc(
'                       int code,       // hook code
'                       WPARAM wParam,  // virtual-key code
'                       LPARAM lParam   // keystroke-message information
'                   );
'
'                   Here is the definition for a mouse event
'                   LRESULT CALLBACK MouseProc(
'                        int nCode,      // hook code
'                        WPARAM wParam,  // message identifier RIGHT OR LEFT MOUSE DOWN,UP,MOVE...
'                        LPARAM lParam    // mouse coordinates
'                   );
'                   wParam contain the mouse button state!
'                   lParam is a pointer to the structure MOUSEHOOKSTRUCT! We do not use this structure
'
'                   lngRetCode : FALSE if the event must be canceled else TRUE.
' RETURNS       :
Private Sub mobjKeyboardFilter_WindowProcHookExEvent(ByVal lngHookType As Long, ByVal ncode As Long, ByVal wParam As Long, ByVal lParam As Long, lngRetCode As Long)

    Dim strS            As String
    Dim booAlt          As Boolean
    Dim booKeyIsDown    As Boolean
        
    Select Case lngHookType
    
        Case WH_KEYBOARD
            
                If (ncode = HC_ACTION) Then
                            
                            booKeyIsDown = mobjKeyboardFilter.kbdEventIsKeyDown(lParam)
                            booAlt = mobjKeyboardFilter.kbdEventIsAltOn(lParam)
                            
                            #If DEBUG_FILTER_MODE Then
                                strS = "HC_ACTION VKeyCode=" & wParam & " KeyInfo=" & lParam & " "
                                strS = strS & IIf(booAlt, "ALT", "")
                                strS = strS & IIf(booKeyIsDown, "DOWN", "UP")
                            #End If
                            
                            Select Case wParam
                            
                                Case vbKeyF5 ' If F5 cancel the keystroke by returning FALSE
                                    lngRetCode = False
                                    
                                Case vbKeyControl ' I have to monitor myself the status of CTRL key for the CTRL-END and CTRL-O keystroke that we have to cancel
                                    mobjKeyboardFilter.ControlKeyDown = booKeyIsDown
                                    
                                Case vbKeyLeft, vbKeyRight ' Alt+LeftArrow or Alt+RightArrow
                                    If (booAlt) Then lngRetCode = False
                                    
                                Case vbKeyN  ' CTRL+N
                                    If (mobjKeyboardFilter.ControlKeyDown) Then lngRetCode = False
                                    
                                Case vbKeyO '  CTRL+O
                                    If (mobjKeyboardFilter.ControlKeyDown) Then lngRetCode = False
                                    
                            End Select
                            
                            #If DEBUG_FILTER_MODE Then
                                If (Not CBool(lngRetCode)) Then strS = strS & " KEY CANCELED"
                                Debug.Print strS
                            #End If
                End If
    End Select
    
End Sub




' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   mobjMouseFilter_WindowProcHookExEvent
' DESCRIPTION   :   See sub mobjKeyboardFilter_WindowProcHookExEvent
' PARAMETERS    :
' RETURNS       :
Private Sub mobjMouseFilter_WindowProcHookExEvent(ByVal lngHookType As Long, ByVal ncode As Long, ByVal wParam As Long, ByVal lParam As Long, lngRetCode As Long)

    Dim strS            As String
    Dim booAlt          As Boolean
    Dim booKeyIsDown    As Boolean
        
    Select Case lngHookType
    
        Case WH_MOUSE
                If (ncode = HC_ACTION) Then
                
                    ' Cancel Right mouse client : MouseDown and MouseUp
                    If (wParam = WM_RBUTTONDOWN) Or (wParam = WM_RBUTTONUP) Then
                    
                            lngRetCode = False
                            #If DEBUG_FILTER_MODE Then
                                strS = vbCrLf & "RIGHT MOUSE CLICK DETECTED"
                                Debug.Print strS
                            #End If
                    End If
                End If
    End Select
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   Run()
' DESCRIPTION   :   This function does nothing! But can be called to force the class to be allocated.
'                   When we declare an instance with a new.
' PARAMETERS    :
' RETURNS       :
Public Function Run() As Boolean
    Run = True
    
End Function
