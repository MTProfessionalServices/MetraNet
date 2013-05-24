VERSION 5.00
Object = "{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}#1.1#0"; "shdocvw.dll"
Begin VB.Form frmDebug 
   Caption         =   "XML Trace"
   ClientHeight    =   7755
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   10065
   LinkTopic       =   "Form1"
   ScaleHeight     =   7755
   ScaleWidth      =   10065
   StartUpPosition =   3  'Windows Default
   Begin SHDocVwCtl.WebBrowser WebBrowser 
      Height          =   2775
      Left            =   1440
      TabIndex        =   0
      Top             =   960
      Width           =   3255
      ExtentX         =   5741
      ExtentY         =   4895
      ViewMode        =   0
      Offline         =   0
      Silent          =   0
      RegisterAsBrowser=   0
      RegisterAsDropTarget=   1
      AutoArrange     =   0   'False
      NoClientEdge    =   0   'False
      AlignLeft       =   0   'False
      NoWebView       =   0   'False
      HideFileNames   =   0   'False
      SingleClick     =   0   'False
      SingleSelection =   0   'False
      NoFolders       =   0   'False
      Transparent     =   0   'False
      ViewID          =   "{0057D0E0-3573-11CF-AE69-08002B2E1262}"
      Location        =   ""
   End
End
Attribute VB_Name = "frmDebug"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()
    g_objIniFile.FormSaveRestore Me, False, True
    
    Dim w As New cWindows
    
    If AppOptions("WatchWindowAlwaysOnTop", False) Then
    
        w.SetWinTopMost Me, True
    End If
    Clear
End Sub

Private Sub Form_Resize()
    WebBrowser.Left = 0
    WebBrowser.Top = 0
    WebBrowser.Width = Me.Width - (7 * Screen.TwipsPerPixelX)
    WebBrowser.Height = Me.Height - (25 * Screen.TwipsPerPixelX)
End Sub

Private Sub Form_Unload(Cancel As Integer)
    g_objIniFile.FormSaveRestore Me, True, True
End Sub

Public Function WriteLn(ByVal strText As String) As Boolean
    'WebBrowser.Document.WriteLn strText & "<br>"
    Dim objTextFile As New cTextFile
    Dim strS        As String
    
    'strText = Replace(strText, "<?xml", "<?xmltrace")
    
    If objTextFile.ExistFile(GetFileName()) Then strS = objTextFile.LoadFile(GetFileName())
    
    strS = Replace(strS, "</XMLTRACE>", "")
    strS = Replace(strS, "<XMLTRACE>", "")
    strS = "<XMLTRACE>" & strS & vbNewLine & strText & vbNewLine & "</XMLTRACE>" & vbNewLine
    objTextFile.LogFile GetFileName(), strS, True
    ReLoad
    WriteLn = True
End Function

Public Function Clear() As Boolean
    'WebBrowser.Document.Clear
    Dim objTextFile As New cTextFile
    objTextFile.DeleteFile GetFileName()
    Clear = True
    ReLoad
End Function

Public Function GetFileName() As String
    GetFileName = Replace(Environ("TEMP") & "\W3Runner.Trace.xml", "\\", "\")
End Function

Public Function ReLoad() As Boolean
    Dim objTextFile As New cTextFile
    If objTextFile.ExistFile(GetFileName()) Then
        WebBrowser.Navigate GetFileName()
        DoEvents
        Do While WebBrowser.Busy
            DoEvents
        Loop
        WebBrowser.Document.body.doScroll "PageDown"
    Else
        Me.WebBrowser.Navigate "about:blank"
        DoEvents
    End If
    ReLoad = True
End Function

Public Function CloseWindow() As Boolean
    Unload Me
    CloseWindow = True
End Function
