VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CHelp"
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
'  DATE         : 09/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Private Declare Function HtmlHelp Lib "hhctrl.ocx" Alias "HtmlHelpA" (ByVal hwndCaller As Long, ByVal pszFile As String, ByVal uCommand As Long, ByVal dwData As Long) As Long

Private Const HH_DISPLAY_TOPIC = &H0
Private Const HH_CLOSE_ALL = &H12
Private Const HH_HELP_CONTEXT = &HF

Private m_booOpened As Boolean
Private m_lngHwnd As Long

Public Enum APP_HELP_TOPIC
 Default = 0
 GeneralTab = 1
 VBScriptTab = 2
 TraceTab = 3
 AdvancedTuningTab = 4
 JavaScriptTab = 5
 RecordModeTab = 6
 ExternalToolTab = 7
End Enum


Public Function Initialize(lngHWND As Long) As Boolean
    
    m_lngHwnd = m_lngHwnd
    Initialize = True
End Function




Public Sub HelpShow(Optional TopicID As APP_HELP_TOPIC = Default)

    m_booOpened = True

    If TopicID = 0 Then
    
        Call HtmlHelp(frmMain.HWND, App.path & "\help\W3Runner.CHM", HH_DISPLAY_TOPIC, 0)
    Else
       Call HtmlHelp(frmMain.HWND, App.path & "\help\W3Runner.CHM", HH_HELP_CONTEXT, TopicID)
   End If
End Sub


Private Sub Class_Terminate()
'    CloseWindow
End Sub

Public Function CloseWindow() As Boolean
    If m_booOpened Then
        m_booOpened = False
        Call HtmlHelp(m_lngHwnd, "", HH_CLOSE_ALL, 0)
    End If
    CloseWindow = True
End Function
