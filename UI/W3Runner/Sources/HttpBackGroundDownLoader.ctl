VERSION 5.00
Begin VB.UserControl HttpBGDownLoader 
   ClientHeight    =   540
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   915
   InvisibleAtRuntime=   -1  'True
   Picture         =   "HttpBackGroundDownLoader.ctx":0000
   ScaleHeight     =   540
   ScaleWidth      =   915
End
Attribute VB_Name = "HttpBGDownLoader"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_strFileName As String
Public TimeOut As Long

Private Sub UserControl_AsyncReadComplete(AsyncProp As AsyncProperty)

    On Error GoTo errmgr:
    
    'Dim objTextFile As New cTextFile
    'objTextFile.LogFile AsyncProp.PropertyName, StrConv(AsyncProp.Value, vbUnicode), True
    On Error Resume Next
    m_strFileName = AsyncProp.Value
    If (Err.Number) Then
        m_strFileName = ""
    End If
    Exit Sub
errmgr:
    FShowError IERUNNER_ERROR_07003 & " " & GetVBErrorString(), "HttpBackGroundDownLoader.ctl", "UserControl_AsyncReadComplete"
End Sub

Public Function DownLoad(strURL As String, ByRef varByRefFileName As Variant, ByVal lngTimeOut As Long) As Boolean

    Dim lngTime     As Long
    Dim lngTime2    As Long
    Dim strFileName As String
    
    
    On Error GoTo errmgr
    
    
    If lngTimeOut = 0 Then lngTimeOut = TimeOut
    lngTimeOut = lngTimeOut * 1000
    
    DEBUGLOG "DownLoad(" & strURL & ")"
            
    m_strFileName = ""
    ' The error is catched by the caller
    UserControl.AsyncRead strURL, vbAsyncTypeFile, strFileName, vbAsyncReadResynchronize + vbAsyncReadForceUpdate   '+ vbAsyncReadSynchronousDownload
    
    lngTime = GetTickCount()
    Do
        DoEvents
        'Debug.Print "."
        Sleep 300  ' Wait for a second
        If (Len(m_strFileName)) Then
            strFileName = m_strFileName
            DownLoad = True
            DEBUGLOG "DownLoad Succeed"
            Exit Do ' The file is received
        End If
        lngTime2 = GetTickCount()
        If lngTime2 > lngTime + lngTimeOut Then
        
            UserControl.CancelAsyncRead
            DEBUGLOG "DownLoad TimeOut"
            Exit Do ' Time out
        End If
    Loop
    varByRefFileName = strFileName
    Exit Function
errmgr:
    'FShowError IERUNNER_ERROR_07003 & " " & GetVBErrorString(), "HttpBackGroundDownLoader.ctl", "DownLoad"
End Function


Private Sub UserControl_Initialize()
    TimeOut = 5 * 1000
End Sub

Private Sub UserControl_Resize()
    UserControl.Width = 16 * Screen.TwipsPerPixelX
    UserControl.Height = 16 * Screen.TwipsPerPixelX
End Sub


