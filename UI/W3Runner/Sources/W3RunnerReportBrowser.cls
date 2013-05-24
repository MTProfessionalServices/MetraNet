VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "W3RunnerReportBrowser"
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
'  DATE         : 11/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************

Option Explicit

Private m_strURL  As String

Public Property Get WebBrowser() As WebBrowser

    Set WebBrowser = frmMain.ReportBrowser
End Property

Public Function Show() As Boolean

    frmMain.ShowReportBrowser = True
    Show = True
End Function

Public Function Hide() As Boolean

    frmMain.ShowReportBrowser = False
    Hide = True
End Function

Public Function WriteLn(ByVal strText As String) As Boolean

    Dim h As HTMLDocument
    Me.WebBrowser.Document.WriteLn strText
    WriteLn = True
End Function

Public Function Clear() As Boolean

    Me.WebBrowser.Navigate "about:blank"
    DoEvents
    Sleep 1500
    DoEvents
    
    Me.WebBrowser.Document.Close
    Me.WebBrowser.Document.Clear
    Me.WriteLn "<HTML><style>body {color:black; background-color:white;}</style></HTML>"
    Clear = True
End Function

Public Property Get Visible() As Boolean

    Visible = frmMain.ShowReportBrowser
End Property

Public Property Let Visible(ByVal vNewValue As Boolean)
    If vNewValue Then
        Show
    Else
        Hide
    End If
End Property



Public Property Get HTMLDocument() As HTMLDocument

    On Error GoTo errmgr
    Set HTMLDocument = Me.WebBrowser.Document
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "HTMLDocument"
End Property

Public Property Get URL() As String
    URL = m_strURL
End Property

Public Property Let URL(ByVal vNewValue As String)

    m_strURL = vNewValue
    WebBrowser.Navigate vNewValue
End Property


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function WaitForDownLoad(Optional ByVal strURL As String) As Boolean

    On Error GoTo errmgr
  
    WaitForDownLoad = frmMain.ReportBrowserWaitForDownLoad(strURL)
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "WaitForDownLoad"
End Function



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get DownLoadTimeOut() As Long
    DownLoadTimeOut = frmMain.DownLoadTimeOut
End Property

Public Property Let DownLoadTimeOut(ByVal vNewValue As Long)
    frmMain.TRACE "Page.DownLoadTimeOut = " & vNewValue, w3rMETHOD
    frmMain.DownLoadTimeOut = vNewValue
End Property


