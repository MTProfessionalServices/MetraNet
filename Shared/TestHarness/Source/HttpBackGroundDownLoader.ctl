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

Private Sub UserControl_AsyncReadComplete(AsyncProp As AsyncProperty)
    'Dim objTextFile As New cTextFile
    'objTextFile.LogFile AsyncProp.PropertyName, StrConv(AsyncProp.Value, vbUnicode), True
    m_strFileName = AsyncProp.Value
End Sub

Public Function DownLoad(strURL As String, ByRef strFileName As String) As Boolean

    On Error GoTo ErrMgr
    ' The error is catched by the caller
    UserControl.AsyncRead strURL, vbAsyncTypeFile, strFileName, vbAsyncReadResynchronize + vbAsyncReadSynchronousDownload
    strFileName = m_strFileName
    DownLoad = True
    Exit Function
ErrMgr:
End Function


Private Sub UserControl_Resize()
    UserControl.Width = 16 * Screen.TwipsPerPixelX
    UserControl.Height = 16 * Screen.TwipsPerPixelX
End Sub
