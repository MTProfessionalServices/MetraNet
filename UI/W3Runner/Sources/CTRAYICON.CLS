VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cTrayIcon"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private erg                     As Long
Private initied                 As Boolean
Private WithEvents pic          As PictureBox
Attribute pic.VB_VarHelpID = -1

Public Event MouseMove(X As Single, Y As Single)
Public Event MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
Public Event DblClick(Button As Integer, X As Single, Y As Single)

Public Function Done() As Boolean
    
    Dim Tic As NOTIFYICONDATA
    
    If initied Then
        Tic.cbSize = Len(Tic)
        Tic.hWnd = pic.hWnd
        Tic.uID = 1&
        erg = Shell_NotifyIcon(NIM_DELETE, Tic)
        initied = False
    End If
End Function

Public Function Init(Picture1 As PictureBox, toolTipText As String) As Boolean

    Dim Tic As NOTIFYICONDATA
    
    Set pic = Picture1
    
    Tic.cbSize = Len(Tic)
    Tic.hWnd = pic.hWnd
    Tic.uID = 1&
    Tic.uFlags = NIF_DOALL
    
    Tic.uCallbackMessage = WM_MOUSEMOVE
    Tic.hIcon = Picture1.Picture
    Tic.szTip = toolTipText & Chr$(0)
    erg = Shell_NotifyIcon(NIM_ADD, Tic)
    Init = True
    initied = True
End Function

Private Sub pic_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim msg As Long
    msg = X / Screen.TwipsPerPixelX
    'Debug.Print "msg=" & msg
    Select Case msg
             Case WM_MOUSEMOVE
                 RaiseEvent MouseMove(X, Y)
                 
             Case WM_LBUTTONDOWN
             Case WM_LBUTTONUP
                 RaiseEvent MouseDown(vbLeftButton, Shift, X, Y)
                 
             Case WM_RBUTTONDOWN
             Case WM_RBUTTONUP
                 RaiseEvent MouseDown(vbRightButton, Shift, X, Y)
                 
             Case WM_LBUTTONDBLCLK
                 RaiseEvent DblClick(vbLeftButton, X, Y)
                 
             Case WM_RBUTTONDBLCLK
                RaiseEvent DblClick(vbRightButton, X, Y)
    End Select
End Sub


