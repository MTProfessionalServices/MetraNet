VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form frmMain 
   Caption         =   "VB Doc Builder"
   ClientHeight    =   2265
   ClientLeft      =   165
   ClientTop       =   735
   ClientWidth     =   5100
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   ScaleHeight     =   2265
   ScaleWidth      =   5100
   StartUpPosition =   3  'Windows Default
   Begin MSComDlg.CommonDialog cm 
      Left            =   1440
      Top             =   720
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin MSComctlLib.StatusBar StatusBar 
      Align           =   2  'Align Bottom
      Height          =   375
      Left            =   0
      TabIndex        =   0
      Top             =   1890
      Width           =   5100
      _ExtentX        =   8996
      _ExtentY        =   661
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   2
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            Alignment       =   1
            AutoSize        =   1
            Object.Width           =   4233
         EndProperty
         BeginProperty Panel2 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   4233
         EndProperty
      EndProperty
   End
   Begin VB.Menu mnuFile 
      Caption         =   "Files"
      Begin VB.Menu mnuBuildHTMLDOC 
         Caption         =   "Build Documentation for a file"
      End
      Begin VB.Menu mnuBUILDFODLER 
         Caption         =   "Build Documentation from a folder"
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private WithEvents objDocBuilder As CDocBuilder
Attribute objDocBuilder.VB_VarHelpID = -1
Private m_objIniFile As New cIniFile

Public Continue As Boolean

Private Sub Form_KeyPress(KeyAscii As Integer)
    Select Case KeyAscii
        Case 27
            Continue = False
    End Select
End Sub

Private Sub Form_Load()

    m_objIniFile.InitAutomatic App
    m_objIniFile.FormSaveRestore Me, False, True
End Sub

Private Sub Form_Unload(Cancel As Integer)
    m_objIniFile.FormSaveRestore Me, True, True
End Sub

Private Sub mnuBUILDFODLER_Click()

    Dim objWaitCursor As New CWaitCursor: objWaitCursor.Wait Screen
    Dim strPATH As String
    Dim objWinApi As New cWindows
    
    Continue = True
    
    strPATH = objWinApi.getBrowseDirectory(0)
    If Len(strPATH) Then
        Set objDocBuilder = New CDocBuilder
        DoEvents
        objDocBuilder.BuildDocumentations strPATH, App.Path & "\doc"
    End If
    Me.StatusBar.Panels(1).Text = ""
    Me.StatusBar.Panels(2).Text = ""
End Sub

Private Sub mnuBuildHTMLDOC_Click()
    
    Dim objWaitCursor As New CWaitCursor: objWaitCursor.Wait Screen
    Dim objToOl       As New cTool
    Dim strFileName   As String
    
    
    strFileName = objToOl.getUserOpenFile(cm, "File Name", "Class|*.cls|Form|*.frm|Module|*.bas", False)
    
    If (Len(strFileName)) Then
        Set objDocBuilder = New CDocBuilder
        DoEvents
        objDocBuilder.BuildDocumentation strFileName, App.Path & "\doc", True
    End If
    Me.StatusBar.Panels(1).Text = ""
    Me.StatusBar.Panels(2).Text = ""

    
End Sub

Private Sub objDocBuilder_Continue(booContinue As Boolean)

    booContinue = Me.Continue
End Sub

Private Sub objDocBuilder_ProcessFile(strFileName As String)
    Me.StatusBar.Panels(1).Text = "Processing file " & strFileName
    Me.StatusBar.Refresh
End Sub

Private Sub objDocBuilder_ProcessItem(strType As String, strItem As String)
    Me.StatusBar.Panels(2).Text = "Processing " & LCase(strType) & " " & strItem
    Me.StatusBar.Refresh

End Sub
