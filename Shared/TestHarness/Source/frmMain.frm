VERSION 5.00
Object = "{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}#1.1#0"; "shdocvw.dll"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form frmMain 
   Caption         =   "MetraTech Test Harness"
   ClientHeight    =   7290
   ClientLeft      =   165
   ClientTop       =   735
   ClientWidth     =   14040
   Icon            =   "frmMain.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   ScaleHeight     =   7290
   ScaleWidth      =   14040
   StartUpPosition =   3  'Windows Default
   Begin SHDocVwCtl.WebBrowser txtTestDescription 
      Height          =   1575
      Left            =   9300
      TabIndex        =   6
      Top             =   1080
      Width           =   1875
      ExtentX         =   3307
      ExtentY         =   2778
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
   Begin VB.Timer tmrEditSessionAction 
      Enabled         =   0   'False
      Interval        =   100
      Left            =   11280
      Top             =   5460
   End
   Begin VB.Timer tmrExecutionPopUpMenu 
      Enabled         =   0   'False
      Interval        =   11
      Left            =   840
      Top             =   5160
   End
   Begin MSComctlLib.ProgressBar ProgressBar1 
      Height          =   495
      Left            =   10980
      TabIndex        =   5
      Top             =   4860
      Visible         =   0   'False
      Width           =   1575
      _ExtentX        =   2778
      _ExtentY        =   873
      _Version        =   393216
      Appearance      =   1
   End
   Begin MSComctlLib.ImageList ImageListlvlog 
      Left            =   2520
      Top             =   5400
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   7
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":030A
            Key             =   "Error"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":08A4
            Key             =   "Idea"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":0CF6
            Key             =   "Operation"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":1290
            Key             =   "Info"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":182A
            Key             =   "Remember"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":1C7C
            Key             =   "Succeed"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":20CE
            Key             =   "Warning"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ListView lvlog 
      Height          =   2055
      Left            =   6840
      TabIndex        =   4
      Top             =   3840
      Width           =   2295
      _ExtentX        =   4048
      _ExtentY        =   3625
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      SmallIcons      =   "ImageListlvlog"
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
   Begin VB.PictureBox picSplitter 
      BackColor       =   &H00808080&
      BorderStyle     =   0  'None
      FillColor       =   &H00808080&
      Height          =   3540
      Left            =   5520
      ScaleHeight     =   1541.468
      ScaleMode       =   0  'User
      ScaleWidth      =   780
      TabIndex        =   0
      Top             =   2520
      Visible         =   0   'False
      Width           =   72
   End
   Begin MSComctlLib.TreeView tvTests 
      Height          =   3495
      Left            =   0
      TabIndex        =   2
      Top             =   480
      Width           =   2175
      _ExtentX        =   3836
      _ExtentY        =   6165
      _Version        =   393217
      HideSelection   =   0   'False
      Indentation     =   353
      LabelEdit       =   1
      LineStyle       =   1
      Style           =   7
      FullRowSelect   =   -1  'True
      ImageList       =   "imlTreeListView"
      Appearance      =   1
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin MSComctlLib.StatusBar sbStatusBar 
      Align           =   2  'Align Bottom
      Height          =   375
      Left            =   0
      TabIndex        =   1
      Top             =   6915
      Width           =   14040
      _ExtentX        =   24765
      _ExtentY        =   661
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   2
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   12118
         EndProperty
         BeginProperty Panel2 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   12118
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ImageList imlTreeListView 
      Left            =   2640
      Top             =   2640
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   15
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":2668
            Key             =   "GlobalTest"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":4E1A
            Key             =   "CompareDef"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":53B4
            Key             =   "IgnoredFolder"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":594E
            Key             =   "ExternalFolder"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":5AA8
            Key             =   "Warning"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":6042
            Key             =   "Root"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":65DC
            Key             =   "Folder"
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":6B76
            Key             =   "StaticFile"
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":6FC8
            Key             =   "SystemFolder"
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":72E2
            Key             =   "SuperTestSession"
         EndProperty
         BeginProperty ListImage11 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":787C
            Key             =   "TestSession"
         EndProperty
         BeginProperty ListImage12 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":7E16
            Key             =   "FolderOpen"
         EndProperty
         BeginProperty ListImage13 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":A5C8
            Key             =   "people"
         EndProperty
         BeginProperty ListImage14 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":AEA2
            Key             =   "new"
         EndProperty
         BeginProperty ListImage15 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":B43C
            Key             =   "Test"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ImageList imlToolbarIcons 
      Left            =   4320
      Top             =   3210
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   7
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":B9D6
            Key             =   "New"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":BAE8
            Key             =   "TestSession"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":C082
            Key             =   "Properties"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":C194
            Key             =   "Execute"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":C2A6
            Key             =   "Macro"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":C3B8
            Key             =   "Open"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":C4CA
            Key             =   "Delete"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.Toolbar Toolbar 
      Align           =   1  'Align Top
      Height          =   360
      Left            =   0
      TabIndex        =   3
      Top             =   0
      Width           =   14040
      _ExtentX        =   24765
      _ExtentY        =   635
      ButtonWidth     =   609
      ButtonHeight    =   582
      AllowCustomize  =   0   'False
      Appearance      =   1
      Style           =   1
      ImageList       =   "imlToolbarIcons"
      _Version        =   393216
      BeginProperty Buttons {66833FE8-8583-11D1-B16A-00C0F0283628} 
         NumButtons      =   9
         BeginProperty Button1 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "NewTest"
            Object.ToolTipText     =   "New Test"
            ImageKey        =   "New"
         EndProperty
         BeginProperty Button2 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "NewSession"
            Object.ToolTipText     =   "New Test Session"
            ImageKey        =   "TestSession"
         EndProperty
         BeginProperty Button3 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Enabled         =   0   'False
            Object.Visible         =   0   'False
            Key             =   "OpenDB"
            Object.ToolTipText     =   "Open Tests Database"
            ImageKey        =   "Open"
         EndProperty
         BeginProperty Button4 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button5 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "ExecuteTest"
            Object.ToolTipText     =   "Execute Test Or Test Session"
            ImageKey        =   "Execute"
         EndProperty
         BeginProperty Button6 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
            Object.Width           =   2800
         EndProperty
         BeginProperty Button7 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Delete"
            Object.ToolTipText     =   "Delete Test Or Test Session"
            ImageKey        =   "Delete"
         EndProperty
         BeginProperty Button8 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button9 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Options"
            Object.ToolTipText     =   "Options"
            ImageKey        =   "Properties"
         EndProperty
      EndProperty
      BorderStyle     =   1
   End
   Begin VB.Image imgSplitterDown 
      Height          =   165
      Left            =   120
      MousePointer    =   7  'Size N S
      Top             =   4440
      Width           =   9390
   End
   Begin VB.Image imgSplitter 
      Height          =   3585
      Left            =   2160
      MousePointer    =   9  'Size W E
      Top             =   720
      Width           =   135
   End
   Begin VB.Menu mnuTest 
      Caption         =   "Test"
      Begin VB.Menu mnuTestExecute 
         Caption         =   "Execute"
         Shortcut        =   {F5}
      End
      Begin VB.Menu mnuEditTestMnuOPtion 
         Caption         =   "Edit"
         Begin VB.Menu mnuTestEdit 
            Caption         =   "Test Information"
            Shortcut        =   ^E
         End
         Begin VB.Menu mnuTestEditScript 
            Caption         =   "Script"
            Shortcut        =   ^S
         End
         Begin VB.Menu mnuTestEditDescription 
            Caption         =   "Description"
            Shortcut        =   ^D
         End
      End
      Begin VB.Menu mnuTestAdvanced 
         Caption         =   "Advanced"
         Begin VB.Menu mnuCreateExternalDescription 
            Caption         =   "Create External Description"
         End
         Begin VB.Menu mnuTestCopy 
            Caption         =   "Copy"
         End
         Begin VB.Menu mnuTestCloneAs 
            Caption         =   "Clone As"
         End
         Begin VB.Menu mnuTestCopyCommandLine 
            Caption         =   "Copy Command Line"
         End
      End
      Begin VB.Menu mnuTestDelete 
         Caption         =   "Delete"
      End
      Begin VB.Menu mnuRien 
         Caption         =   "-"
      End
      Begin VB.Menu mnuRefreshDatabase 
         Caption         =   "Refresh All"
      End
      Begin VB.Menu mnuRienX 
         Caption         =   "-"
      End
      Begin VB.Menu mnuQuit 
         Caption         =   "Quit"
         Shortcut        =   ^Q
      End
   End
   Begin VB.Menu mnuTestSession 
      Caption         =   "Test Session"
      Begin VB.Menu mnuTestSessionExecute 
         Caption         =   "Execute"
      End
      Begin VB.Menu mnuTestSessionEdit 
         Caption         =   "Edit"
      End
      Begin VB.Menu mnuTestSessionDelete 
         Caption         =   "Delete"
      End
      Begin VB.Menu mnuSessionAdvanced 
         Caption         =   "Advanced"
         Begin VB.Menu mnuTestSessionEditDescription 
            Caption         =   "Edit Description"
         End
         Begin VB.Menu mnuDocSession 
            Caption         =   "Documentation"
            Begin VB.Menu mnuGenerateSessionSummaryDoc 
               Caption         =   "Generate HTML Summary"
            End
            Begin VB.Menu mnuGenerateSessionSummaryDocTXT 
               Caption         =   "Generate TEXT Summary"
               Visible         =   0   'False
            End
         End
         Begin VB.Menu mnuTestSessionCopyCommandLine 
            Caption         =   "Copy Command Line"
         End
      End
      Begin VB.Menu mnuQARepository 
         Caption         =   "QA Repository"
         Begin VB.Menu mnuSessionReportToQARepository 
            Caption         =   "Report"
         End
         Begin VB.Menu mnuQARepositoryRegister 
            Caption         =   "Register"
         End
         Begin VB.Menu mnuQARepositoryWebUI 
            Caption         =   "Web UI"
         End
         Begin VB.Menu mnuSystem 
            Caption         =   "System"
            Begin VB.Menu mnuQARepositoryRegisterSystenName 
               Caption         =   "Register"
            End
            Begin VB.Menu mnuUpdateSystem 
               Caption         =   "Update"
            End
         End
         Begin VB.Menu mnuEngineer 
            Caption         =   "Engineer"
            Begin VB.Menu mnuRegisterEngineer 
               Caption         =   "Register"
            End
            Begin VB.Menu mnuDeleteEngineer 
               Caption         =   "Delete"
            End
         End
      End
   End
   Begin VB.Menu mnuTestTestsDashBoard 
      Caption         =   "Tests DashBoard"
      Begin VB.Menu mnuTestStatusView 
         Caption         =   "View"
         Shortcut        =   ^V
      End
   End
   Begin VB.Menu mnuFolder 
      Caption         =   "Folder"
      Begin VB.Menu mnuFolderExecuteAll 
         Caption         =   "Execute All"
      End
      Begin VB.Menu mnuNewTest 
         Caption         =   "New Test"
         Shortcut        =   {F2}
      End
      Begin VB.Menu mnuNewTestSession 
         Caption         =   "New Test Session"
         Shortcut        =   {F3}
      End
      Begin VB.Menu mnuNewFolder 
         Caption         =   "New Folder"
      End
      Begin VB.Menu mnuFolderPaste 
         Caption         =   "Paste"
      End
      Begin VB.Menu mnuDeleteFolder 
         Caption         =   "Delete"
      End
      Begin VB.Menu mnuFolderFind 
         Caption         =   "Find"
         Shortcut        =   ^F
      End
      Begin VB.Menu mnuOPenFolderInExplorer 
         Caption         =   "Explorer"
      End
      Begin VB.Menu mnuFolderAdvanced 
         Caption         =   "Advanced"
         Begin VB.Menu mnuFolderEditDescription 
            Caption         =   "Edit Description"
         End
         Begin VB.Menu mnuReorderAllTests 
            Caption         =   "Re-Order"
         End
      End
      Begin VB.Menu mnuTestSessionRien1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuFolderCloseAll 
         Caption         =   "Close All"
      End
   End
   Begin VB.Menu mnuMainTools 
      Caption         =   "Tools"
      Begin VB.Menu mnuOptions 
         Caption         =   "Options"
      End
      Begin VB.Menu mnuValidateintegrity 
         Caption         =   "Validate Integrity"
      End
      Begin VB.Menu mnuExportSessionDescriptionToTextFile 
         Caption         =   "Export Session Description To Text File"
         Enabled         =   0   'False
      End
      Begin VB.Menu mnuReloadDictionary 
         Caption         =   "Reload Dictionary"
      End
      Begin VB.Menu mnuShowDic 
         Caption         =   "Show Dictionary"
      End
      Begin VB.Menu VerifyAllVBSComment 
         Caption         =   "Verify all vbs comment"
         Enabled         =   0   'False
      End
   End
   Begin VB.Menu mnuLog 
      Caption         =   "Log Window"
      Begin VB.Menu mnuLogClear 
         Caption         =   "Clear"
         Shortcut        =   {F6}
      End
      Begin VB.Menu mnuLogWindowCopy 
         Caption         =   "Copy"
      End
      Begin VB.Menu mnuLogWindowEdit 
         Caption         =   "Edit"
      End
   End
   Begin VB.Menu mnuHelp 
      Caption         =   "Help"
      Begin VB.Menu mnuHelpContent 
         Caption         =   "Contents"
      End
      Begin VB.Menu mnuShowTop 
         Caption         =   "Show Tips"
      End
      Begin VB.Menu mnuDBInfo 
         Caption         =   "Database Info"
      End
      Begin VB.Menu mnuCreateShortCut 
         Caption         =   "Create a ShortCut on the DeskTop"
      End
      Begin VB.Menu mnuRienAbout 
         Caption         =   "-"
      End
      Begin VB.Menu mnuAbout 
         Caption         =   "&About"
      End
   End
   Begin VB.Menu ExecutionPopUpMenu 
      Caption         =   "mnuExecutionPopUp"
      Begin VB.Menu mnuExecutionPopUpItem 
         Caption         =   "mnuExecutionPopUpItem0"
         Index           =   0
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' **************************************************************************************************************************************************************************************
' * Class : frmMain
' * Application : Me
' * Version : 1.0
' * Author : Frederic Torres
' * Creation Date :
' *
' *
' *
' *
' *
' *
' *
' **************************************************************************************************************************************************************************************

Option Explicit
    
Const sglSplitLimit = 3000

Private mbMoving As Boolean

Private m_strClipBoard As String ' Contains the name of the object to copy and paste



Private objSelectedItemPopUp As CTDBItem


Private Sub SizeControls(X As Long, lngLostHeight As Long)

    On Error Resume Next
    
    lvlog.Height = lngLostHeight
    
    
    tvTests.Left = 0
    lvlog.Left = 0
    
    ' Set the width
    If X < sglSplitLimit Then X = sglSplitLimit
    If X > (Me.Width - sglSplitLimit) Then X = Me.Width - sglSplitLimit
    
    ' Test TreeView
    tvTests.Width = X
    tvTests.Top = Toolbar.Height + (0 * Screen.TwipsPerPixelX)
    tvTests.Height = Me.ScaleHeight - (sbStatusBar.Height + Toolbar.Height + lvlog.Height + (5 * Screen.TwipsPerPixelY))
    
    ' Details TextBox
    txtTestDescription.Top = tvTests.Top
    txtTestDescription.Left = tvTests.Left + tvTests.Width + (4 * Screen.TwipsPerPixelX)
    txtTestDescription.Width = Me.Width - (tvTests.Width + (10 * Screen.TwipsPerPixelX))
    txtTestDescription.Height = tvTests.Height + (0 * Screen.TwipsPerPixelY)
    
    ' Log ListBox
    lvlog.Width = Me.Width - (Screen.TwipsPerPixelX * 8)
    lvlog.Top = tvTests.Top + tvTests.Height + (3 * Screen.TwipsPerPixelY)
    
    imgSplitterDown.Left = 0
    imgSplitterDown.Width = Me.Width
    imgSplitterDown.Top = tvTests.Top + tvTests.Height - (1 * Screen.TwipsPerPixelY)
    
    imgSplitter.Left = X
    imgSplitter.Top = tvTests.Top
    imgSplitter.Height = tvTests.Height
    
    

    Exit Sub
ErrMgr:
   
End Sub



Private Sub Toolbar1_ButtonClick(ByVal Button As MSComctlLib.Button)
    On Error Resume Next
    Select Case Button.key
        Case "New"
            'ToDo: Add 'New' button code.
            MsgBox "Add 'New' button code."
        Case "Properties"
            'ToDo: Add 'Properties' button code.
            MsgBox "Add 'Properties' button code."
        Case "Forward"
            'ToDo: Add 'Forward' button code.
            MsgBox "Add 'Forward' button code."
        Case "Macro"
            'ToDo: Add 'Macro' button code.
            MsgBox "Add 'Macro' button code."
        Case "Open"
            'ToDo: Add 'Open' button code.
            MsgBox "Add 'Open' button code."
    End Select
End Sub



Private Sub Form_Activate()
    On Error Resume Next
    tvTests.SetFocus
End Sub

Private Sub Form_Click()

    On Error GoTo ErrMgr

'    MsgBox ":"

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "Form_Click"
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)

    On Error GoTo ErrMgr
    
    
    Debug.Print KeyCode & " " & Shift
    

    Select Case KeyCode
        Case vbKeyDelete
            mnuTestDelete_Click
        Case vbKeyF1
            mnuHelpContent_Click
    End Select

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "Form_KeyDown"
End Sub



Public Function LoadAll() As Boolean

    On Error GoTo ErrMgr

    'mnuFolder.Visible = False
    'mnuLog.Visible = False
    'mnuTest.Visible = False
    'mnuTestSession.Visible = False
    'mnuEditTestInNotePad.Visible = False

    ExecutionPopUpMenu.Visible = False
    mnuTestTestsDashBoard.Visible = False
    

    InitScreenSize LOAD_DATA
    
    TestVirtualLink
    
    RefreshUI
    
    
    mnuFolderExecuteAll.Visible = False

    mnuTestCopy.Visible = False
    mnuFolderPaste.Visible = False
    'mnuEditTestInNotePad.Visible = False
        
    'mnuTest.Visible = False
    'mnuFolder.Visible = False
    'mnuLog.Visible = False
  
    

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "LoadAll"
End Function


Private Sub Form_Load()

    Me.txtTestDescription.Navigate "about:blank"
    mnuTestEdit.Caption = mnuTestEdit.Caption
    mnuHelpContent.Visible = False
    
End Sub

Private Sub Form_Resize()

    On Error Resume Next
    
    If Me.Width < 3000 Then Me.Width = 3000
    
    SizeControls tvTests.Width, Me.lvlog.Height
    
    'lvAddColumn lvlog, "Time", False, 85 * (Screen.TwipsPerPixelX)
    lvAddColumn lvlog, "Message", False, Me.Width - (Screen.TwipsPerPixelX * 30) '- (80 * (Screen.TwipsPerPixelX))
    
    'tmrResize.Enabled = True
End Sub

 

Private Sub Form_Unload(Cancel As Integer)

    On Error GoTo ErrMgr

    InitScreenSize SAVE_DATA
    SaveTreeViewState
    CloseTDB

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "Form_Unload"
End Sub

Private Sub imgSplitter_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)

    On Error GoTo ErrMgr

    With imgSplitter
        picSplitter.Move .Left, .Top, .Width \ 2, .Height - 20
    End With
    picSplitter.Visible = True
    mbMoving = True

    Exit Sub
ErrMgr:
   
End Sub


Private Sub imgSplitter_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)

    On Error GoTo ErrMgr

    Dim sglPos As Single
    If mbMoving Then
        sglPos = X + imgSplitter.Left
        If sglPos < sglSplitLimit Then
            picSplitter.Left = sglSplitLimit
        ElseIf sglPos > Me.Width - sglSplitLimit Then
            picSplitter.Left = Me.Width - sglSplitLimit
        Else
            picSplitter.Left = sglPos
        End If
    End If

    Exit Sub
ErrMgr:
   
End Sub


Private Sub imgSplitter_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)

    On Error GoTo ErrMgr

    SizeControls picSplitter.Left, Me.lvlog.Height
    picSplitter.Visible = False
    mbMoving = False

    Exit Sub
ErrMgr:
   
End Sub




Private Sub imgSplitterDown_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)

    On Error GoTo ErrMgr

    With imgSplitterDown
    
        picSplitter.Move .Left, .Top, .Width, .Height \ 2
    End With
    picSplitter.Visible = True
    mbMoving = True
    Exit Sub
ErrMgr:
   
   
End Sub

Private Sub imgSplitterDown_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)

    On Error GoTo ErrMgr

    Dim sglPos As Single
    
    If mbMoving Then
        
        sglPos = imgSplitterDown.Top + Y
        
        If sglPos < sglSplitLimit Then
        
            picSplitter.Top = sglSplitLimit
            
        ElseIf sglPos > Me.Height Then
        
            picSplitter.Top = Me.Height
        Else
        
            picSplitter.Top = sglPos
        End If
    End If
    Exit Sub
ErrMgr:
   
End Sub

Private Sub imgSplitterDown_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)

    On Error GoTo ErrMgr

    Dim lnglvLogHeight As Long
    Dim lngSplitterPos  As Long
    
    lngSplitterPos = imgSplitterDown.Top + Y
    If lngSplitterPos < sglSplitLimit Then lngSplitterPos = sglSplitLimit
        
    
    lnglvLogHeight = (Me.Height - Me.Toolbar.Height - sbStatusBar.Height - lngSplitterPos - (35 * Screen.TwipsPerPixelY))
    
    
    Debug.Print "lnglvLogHeight " & lnglvLogHeight
    
    
    SizeControls tvTests.Width, lnglvLogHeight
    picSplitter.Visible = False
    mbMoving = False
    Exit Sub
ErrMgr:
   
End Sub


Private Function InitScreenSize(eA As eAPP_ACTION) As Boolean

    On Error GoTo ErrMgr


    Select Case eA
    
        Case eAPP_ACTION.SAVE_DATA
        
             g_objIniFile.SetVar "SlideBar", "tvTests.Width", tvTests.Width
             g_objIniFile.SetVar "SlideBar", "lvLog.Height", lvlog.Height
             g_objIniFile.FormSaveRestore Me, True, True
             
        Case eAPP_ACTION.LOAD_DATA
        
            If (IsNumeric(g_objIniFile.getVar("SlideBar", "tvTests.Width"))) Then tvTests.Width = g_objIniFile.getVar("SlideBar", "tvTests.Width")
            If (IsNumeric(g_objIniFile.getVar("SlideBar", "lvLog.Height"))) Then lvlog.Height = g_objIniFile.getVar("SlideBar", "lvLog.Height")
            g_objIniFile.FormSaveRestore Me, False, True
    End Select
    InitScreenSize = True
    Exit Function
   

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "InitScreenSize"
End Function



Private Sub lvlog_DblClick()

    If Not IsValidObject(lvlog.SelectedItem) Then Exit Sub
    MsgBox lvlog.SelectedItem.Text
End Sub

Private Sub lvLog_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)

    On Error GoTo ErrMgr

    If (Button = 2) Then
        Me.PopupMenu mnuLog
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "lvLog_MouseDown"
End Sub

Private Sub mnuAbout_Click()

    On Error GoTo ErrMgr

    frmSplash.About

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuAbout_Click"
End Sub


Private Sub mnuCreateExternalDescription_Click()

On Error GoTo ErrMgr

    Dim objSelectedItem As CTDBItem
    
    Set objSelectedItem = GetSelectedObject()
    
    If (IsValidObject(objSelectedItem)) Then
    
        If (GetSelectedObject.CreateExternalDescriptionFile()) Then
        
            mnuTestEditDescription_Click
        End If
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuCreateExternalDescription_Click"
End Sub

Private Sub mnuCreateShortCut_Click()
    AddShortcutToDesktop
End Sub

Private Sub mnuDBInfo_Click()
    g_objTDB.DBInfo.Show
    
End Sub

Private Sub mnuDeleteEngineer_Click()
    frmDeleteEngineerToQARepository.OpenDialog
End Sub

Private Sub mnuDeleteFolder_Click()

    On Error GoTo ErrMgr

    mnuTestDelete_Click

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuDeleteFolder_Click"
End Sub

Private Sub mnuEditTestInNotePad_Click()

    On Error GoTo ErrMgr


    GetSelectedObject.NotePad
    RefreshUI
    

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuEditTestInNotePad_Click"
End Sub




Private Sub mnuExportSessionDescriptionToTextFile_Click()
    Dim s As String
    s = InputBox("", "PassWord")
    If s = "123" Then
        g_objTDB.ExportDescriptionToTextFile Me
    Else
        MsgBox ":)", vbCritical
    End If
End Sub

Private Sub mnuFolderCloseAll_Click()
     TreeViewCloseALL tvTests
End Sub

Private Sub mnuFolderEditDescription_Click()
    mnuTestSessionEditDescription_Click
End Sub

Private Sub mnuFolderExecuteAll_Click()

    On Error GoTo ErrMgr

    mnuTestExecute_Click
    

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuFolderExecuteAll_Click"
End Sub

Private Sub mnuFolderFind_Click()
    Dim strQuery As String
    Dim objSelectedItem     As CTDBItem
    Dim objResultItem       As CTDBItem
    
    
    strQuery = InputBox("Support char * and .", "Find Test", AppOptions("DefaultFind"))
     
    If (Len(strQuery) = 0) Then Exit Sub
     
    Set objSelectedItem = GetSelectedObject()
    
    AppOptions("DefaultFind") = strQuery
    
    If InStr(strQuery, "*") = 0 Then strQuery = "*" + strQuery + "*"
    
    If Not IsValidObject(objSelectedItem) Then Set objSelectedItem = g_objTDB
    
    If objSelectedItem.ItemType <> FOLDER_ITEM Then
        Set objSelectedItem = objSelectedItem.Parent
    End If
    
    Dim List As New CVariables
    
'    Debug.Assert 0
    objSelectedItem.Search strQuery, List
    
    If (List.Count = 0) Then
        MsgBox PreProcess(TESTHARNESS_MESSAGE_7024, "QUERY", strQuery)
        Exit Sub
    End If
    
    Dim f       As New frmFind
    Dim strID   As String
    
    
    
    If (List.Count = 1) Then
        strID = List(1).Value
    Else
    
        strID = f.OpenDialog(strQuery, List)
    End If
        
    If Len(strID) Then

        tvTests.Nodes.Item(strID).EnsureVisible
        tvTests.Nodes.Item(strID).Selected = True
        tvTests.SetFocus
    End If
        
    
    
End Sub

Private Sub mnuFolderPaste_Click()

    On Error GoTo ErrMgr


    If (Me.GetSelectedObject().Paste(m_strClipBoard)) Then
        Me.RefreshUI
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuFolderPaste_Click"
End Sub

Private Sub mnuGenerateSessionSummaryDoc_Click()

    On Error GoTo ErrMgr

    Dim objSelectedItem As CTDBItem
    
    Set objSelectedItem = GetSelectedObject()
    
    If (IsValidObject(objSelectedItem)) Then
    
        objSelectedItem.GenerateSessionSummaryDocumentation App.Path & "\doc\html", True
    End If
    Exit Sub
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuGenerateSessionSummaryDoc_Click"
End Sub

Private Sub mnuGenerateSessionSummaryDocTXT_Click()

    On Error GoTo ErrMgr

    Dim objSelectedItem As CTDBItem
    
    Set objSelectedItem = GetSelectedObject()
    
    If (IsValidObject(objSelectedItem)) Then
    
        objSelectedItem.GenerateSessionSummaryDocumentation App.Path & "\doc\text", False
    End If
    Exit Sub
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuGenerateSessionSummaryDoc_Click"
End Sub

Public Sub mnuHelpContent_Click()
    Dim objTool As New cTool
    objTool.ExecFile App.Path & "\help\TestHarness.htm"
    
End Sub

Private Sub mnuLogClear_Click()

    On Error GoTo ErrMgr

    Dim objTestApi  As Object
    Dim objTextFile As New cTextFile
    
    lvlog.ListItems.Clear
    
    Set objTestApi = GetNewTestApiInstance()
    
    objTextFile.DeleteFile objTestApi.GetTestLogFileName()

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuLogClear_Click"
End Sub

Private Sub mnuLogWindowCopy_Click()
    Clipboard.Clear
    Clipboard.SetText lvlog.SelectedItem.Text
End Sub

Private Sub mnuLogWindowEdit_Click()
    Dim objTestApi As Object
    
    Set objTestApi = GetNewTestApiInstance()
    Shell AppOptions("editor", "notepad.exe") & " " & objTestApi.GetTestLogFileName(), vbNormalFocus
End Sub

Private Sub mnuNewFolder_Click()

    On Error GoTo ErrMgr

    Dim strFolderName As String
    strFolderName = InputBox("", TESTHARNESS_MESSAGE_7003)
    
    If (Len(strFolderName)) Then
    
        Me.GetSelectedObject().CreateSubFolder strFolderName
    End If
    Me.RefreshUI

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuNewFolder_Click"
End Sub

Private Sub mnuNewTest_Click()

    On Error GoTo ErrMgr

    Dim objTest          As New CTDBItem
    Dim strTestSessionFileName  As String
    
    strTestSessionFileName = InputBox("", TESTHARNESS_MESSAGE_7011)
    
    If (Len(strTestSessionFileName)) Then
    
        
        strTestSessionFileName = strTestSessionFileName & "." & TESTHARNESS_TEST_FILE_EXTENSION
        
        objTest.ValidTestName strTestSessionFileName
        objTest.Initialize TEST_ITEM, GetSelectedObject.Path, strTestSessionFileName, , , True
        If (frmEditTest.OpenDialog(objTest)) Then
            objTest.Save
            Me.RefreshUI
        End If
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuNewTest_Click"
End Sub

Private Sub mnuNewTestSession_Click()

    On Error GoTo ErrMgr


    Dim objTestSession          As New CTDBItem
    Dim strTestSessionFileName  As String
    
    strTestSessionFileName = InputBox("", TESTHARNESS_MESSAGE_7007)
   
    If (Len(strTestSessionFileName)) Then
    
        strTestSessionFileName = strTestSessionFileName & "." & TESTHARNESS_TEST_SESSION_FILE_EXTENSION
        objTestSession.Initialize TEST_SESSION_ITEM, GetSelectedObject.Path, strTestSessionFileName, , , True
        If (frmEditTestSession.OpenDialog(objTestSession, g_objTDB)) Then
            objTestSession.Save
            Me.RefreshUI
        End If
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuNewTestSession_Click"
End Sub

Private Sub mnuOPenFolderInExplorer_Click()
    GetSelectedObject.Explorer
End Sub

Private Sub mnuOptions_Click()

    If (frmOptions.OpenDialog(g_objIniFile)) Then

        ResetFontForControls
    End If
End Sub





Private Sub RegisterCurrentSysteNameToQARepositoryIfNecessary(booShowError As Boolean)

    Dim QARepository As New CQARepository
    
    If QARepository.OpenRepository(g_objIniFile) Then
        
        If QARepository.CheckCurrentSystemNameExist() Then
            
            If booShowError Then
            
                MsgBox TESTHARNESS_MESSAGE_7046
            End If
        Else
        
            If MsgBox(PreProcess(TESTHARNESS_MESSAGE_7044, "SYSTEM", CreateObject("MTVBLIB.CWindows").ComputerName()), vbQuestion + vbYesNo) = vbYes Then
        
                frmRegisterSystemNameToQARepository.OpenDialog CreateObject("MTVBLIB.CWindows").ComputerName(), False
            End If
        End If
    End If
    DoEvents
End Sub

Private Sub mnuQARepositoryRegisterSystenName_Click()
    RegisterCurrentSysteNameToQARepositoryIfNecessary True
End Sub

Private Sub mnuQuit_Click()

    On Error GoTo ErrMgr

    QuitApp
    Unload Me

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuQuit_Click"
End Sub

Private Sub mnuRefreshDatabase_Click()

    On Error GoTo ErrMgr

    Me.RefreshUI

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuRefreshDatabase_Click"
End Sub

Private Sub mnuTestClone_Click()

    On Error GoTo ErrMgr



    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestClone_Click"
End Sub

Private Sub mnuRegisterEngineer_Click()
    frmRegisterEngineerToQARepository.OpenDialog
End Sub

Private Sub mnuReloadDictionary_Click()
    g_objTDB.LoadDictionary
End Sub



Private Sub mnuReorderAllTests_Click()

    On Error GoTo ErrMgr

    If frmReOrderTest.OpenDialog(GetSelectedObject()) Then
        mnuRefreshDatabase_Click
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuReorderAllTests_Click"
End Sub

Private Sub mnuShowDic_Click()
    g_objTDB.ShowDictionary
End Sub

Private Sub mnuShowTop_Click()
    frmTip.Show vbModal
End Sub

Private Sub mnuTestCloneAs_Click()
    On Error GoTo ErrMgr


    Dim objTextFile     As New cTextFile
    Dim objWaitCursor   As New CWaitCursor
    Dim objSelectedItem As CTDBItem
    Dim strTestFileName As String
    
    objWaitCursor.Wait Screen
    
    Set objSelectedItem = GetSelectedObject()
    
    ' Can only execute Test and Test Session, Folder execution was removed for now!
    If (objSelectedItem.ItemType = TEST_ITEM) Then
    
        strTestFileName = InputBox("", TESTHARNESS_MESSAGE_7011, Mid(objSelectedItem.Name, 1, Len(objSelectedItem.Name) - Len(TESTHARNESS_TEST_FILE_EXTENSION) - 1))
        If (Len(strTestFileName)) Then
            objSelectedItem.CloneAs strTestFileName
            mnuRefreshDatabase_Click
        End If
    End If
    Exit Sub
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestExecute_Click"
End Sub

Private Sub mnuTestCopy_Click()

    On Error GoTo ErrMgr


    m_strClipBoard = GetSelectedObject.Name

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestCopy_Click"
End Sub


Private Sub mnuTestDelete_Click()

    On Error GoTo ErrMgr

    Dim objSelectedItem As CTDBItem
    
    Set objSelectedItem = GetSelectedObject()
    
    If (IsValidObject(objSelectedItem)) Then
        If (GetSelectedObject.Delete()) Then
            Me.RefreshUI
        End If
    Else
        MsgBox "Select a valid item to delete"
    End If


    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestDelete_Click"
End Sub

Private Sub mnuTestEdit_Click()

    On Error GoTo ErrMgr

    GetSelectedObject.DescriptionParserRefresh
    
    If GetSelectedObject.ItemType = TEST_SESSION_ITEM Then
    
        mnuTestSessionEdit_Click
    Else
    
        If (frmEditTest.OpenDialog(GetSelectedObject)) Then
        
            GetSelectedObject().Save
            'Me.RefreshUI
        End If
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestEdit_Click"
End Sub

Private Sub mnuTestNewTestSession_Click()

    On Error GoTo ErrMgr

    frmEditTestSession.Show vbModal
    

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestNewTestSession_Click"
End Sub





Private Sub mnuTestEditDescription_Click()
    mnuTestSessionEditDescription_Click
End Sub

Private Sub mnuTestEditScript_Click()

    On Error GoTo ErrMgr

    GetSelectedObject.EditScript AppOptions("editor", "notepad.exe"), False
    'RefreshUI
    
    Exit Sub
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuEditTestInNotePad_Click"
End Sub



 

Private Sub mnuTestSessionCopyCommandLine_Click()
    mnuTestCopyCommandLine_Click
End Sub

Private Sub mnuTestSessionDelete_Click()

    On Error GoTo ErrMgr

    mnuTestDelete_Click

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestSessionDelete_Click"
End Sub

Private Sub mnuTestSessionEdit_Action()

    On Error GoTo ErrMgr

    If GetSelectedObject().ItemType = TEST_ITEM Then
        mnuTestEdit_Click
        Exit Sub
    End If

    If (frmEditTestSession.OpenDialog(GetSelectedObject(), g_objTDB)) Then
    
        GetSelectedObject().Save
    End If
    GetSelectedObject().ReLoad
    
    'Me.RefreshUI ' We need to reload event if the user cancel the dialog
                 ' because the data in memory can be altered by the dialog
                 ' Specialy the parameters...

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestSessionEdit_Click"
End Sub

Private Sub mnuTestSessionEdit_Click()
    tmrEditSessionAction.Enabled = True
End Sub





Private Sub mnuTestSessionExecute_Click()

    On Error GoTo ErrMgr

mnuTestExecute_Click

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestSessionExecute_Click"
End Sub

Public Sub mnuTestStatusView_Click()
    OpenDashBoard
End Sub

Private Sub mnuTools_Click(Index As Integer)

    On Error GoTo ErrMgr


    Dim strProgram As String
    Dim objTool    As New cTool
    
    strProgram = AppOptions("Programs(" & Index + 1 & ")", "", "Tools")
    If (Len(strProgram)) Then
    
        If (InStr(UCase(strProgram), ".EXE")) Then
            Shell strProgram, vbNormalFocus
        Else
            objTool.ExecFile strProgram
        End If
    End If
    

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTools_Click"
End Sub



Public Sub RefreshTestUI()

    On Error GoTo ErrMgr


    Do While g_objUnitTestAPI.TraceStrings.Count
    
        User g_objUnitTestAPI.TraceStrings(1)
        g_objUnitTestAPI.TraceStrings.Remove 1

    Loop
    DoEvents

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "RefreshTestUI"
End Sub




Private Sub mnuUpdateSystem_Click()
    frmRegisterSystemNameToQARepository.OpenDialog CreateObject("MTVBLIB.CWindows").ComputerName(), True
End Sub

Private Sub mnuValidateintegrity_Click()
    g_objTDB.ValidateIntegrity (False)
End Sub

Private Sub tmrEditSessionAction_Timer()
    tmrEditSessionAction.Enabled = False
    mnuTestSessionEdit_Action

End Sub

Private Sub Toolbar_ButtonClick(ByVal Button As MSComctlLib.Button)

    On Error GoTo ErrMgr

    
    Select Case Button.key
        Case "Options"
            mnuOptions_Click
        Case "ExecuteTest"
            mnuFolderExecuteAll_Click
            
        Case "Delete"
            mnuTestDelete_Click
        Case "NewTest"
            mnuNewTest_Click
        Case "NewSession"
            mnuNewTestSession_Click
        Case Else
            MsgBox Button.key
            
    End Select

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "Toolbar_ButtonClick"
End Sub


Private Sub tvTests_Collapse(ByVal Node As MSComctlLib.Node)
    SaveTreeViewState
End Sub

Private Sub tvTests_Expand(ByVal Node As MSComctlLib.Node)
    SaveTreeViewState
End Sub

Private Sub tvTests_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)

    On Error GoTo ErrMgr
    
    Dim objSelectedItem As CTDBItem


    If (Not IsValidObject(tvTests.SelectedItem)) Then Exit Sub
    If (Button = 2) Then
    
        Select Case tvTests.SelectedItem.Tag
        
            Case "GLOBAL_TEST", "TEST", "COMPAREDEF":
                
                Set objSelectedItem = GetSelectedObject()
                'mnuExecutionPopUp.Visible = Len(objSelectedItem.PopUpDefinition) > 0
                Me.PopupMenu mnuTest
                
            Case "FOLDER": Me.PopupMenu mnuFolder
            Case "TEST_SESSION": Me.PopupMenu mnuTestSession
        End Select
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "tvTests_MouseDown"
End Sub

Private Sub tvTests_NodeClick(ByVal Node As MSComctlLib.Node)

    On Error GoTo ErrMgr
    
    Dim t As CTDBItem
    
    Dim f As New cTextFile
    
    Status Node.key
    
    SelectUIObject GetSelectedObject()
    
    Set t = GetSelectedObject()
    
    If (t.ItemType = FOLDER_ITEM) Then
    
        SaveTreeViewState
    End If
    
    If (t.ItemType = FOLDER_ITEM) Then
    
        If f.ExistFile(t.DescriptionFileName) Then
        
            txtTestDescription_Text = ReplaceTab(f.LoadFile(t.DescriptionFileName))
        End If
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "tvTests_NodeClick"
End Sub

Public Function Status(Optional ByVal strMessage As String, Optional lngIndex As Long = 1) As Boolean

    On Error GoTo ErrMgr


    If g_booCommandLineMode Then Exit Function
    
    Me.sbStatusBar.Panels(lngIndex).Text = strMessage
    Me.sbStatusBar.Refresh

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "Status"
End Function


Public Function SelectUIObject(objTest As CTDBItem) As Boolean

    On Error GoTo ErrMgr


    If (IsValidObject(objTest)) Then
    
        objTest.DescriptionParserRefresh
        txtTestDescription_Text = ReplaceTab(objTest.Description)
    End If

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "SelectUIObject"
End Function

Public Function GetSelectedObject() As CTDBItem

    On Error GoTo ErrMgr


    Dim objTest As CTDBItem

    If (IsValidObject(tvTests.SelectedItem)) Then
    
        Set objTest = g_objTDB.Find(tvTests.SelectedItem.key)
        
        If (IsValidObject(objTest)) Then
        
            Set GetSelectedObject = objTest
        Else
            Set GetSelectedObject = Empty
        End If
    End If

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "GetSelectedObject"
End Function

Public Function RefreshUI() As Boolean

    On Error GoTo ErrMgr

    Dim objWaitCursor As New CWaitCursor
    
    Me.Show
    DoEvents
    objWaitCursor.Wait Screen
    
    If (Not OpenTDB()) Then
        
    End If
    
    Me.Status TESTHARNESS_MESSAGE_7028
    
    g_objTDB.FillTreeView Me.tvTests, True, True, True
    TreeViewReadState Me.tvTests, TreeViewStateFileName()
    
    ResetFontForControls
    
    Me.Status

    Exit Function
ErrMgr:

        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "RefreshUI"
End Function

Private Function ResetFontForControls()

    'SetDescriptionFont txtTestDescription
    SetDescriptionFont tvTests
End Function


Public Function SaveTreeViewState() As Boolean

    On Error GoTo ErrMgr

    Dim objWaitCursor As New CWaitCursor
    objWaitCursor.Wait Screen
    SaveTreeViewState = TreeViewSaveState(Me.tvTests, TreeViewStateFileName())

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "SaveTreeViewState"
End Function




Public Function User(ByVal strMessage As String, Optional strTag As String, Optional strIcon As String) As String

    On Error GoTo ErrMgr

    Dim LVITEM      As ListItem
    Dim booError    As Boolean

    If (Len(Trim(strMessage)) = 0) Then Exit Function
    
    If (Len(strIcon) = 0) Then
    
        If InStr(UCase(strMessage), "[FAILED") Then
            strIcon = "Error"
            booError = True
        ElseIf InStr(UCase(strMessage), "[SUCCEED") Then
            strIcon = "Succeed"
            
        ElseIf InStr(UCase(strMessage), "OPERATION:") Then
            strIcon = "Operation"
            
        ElseIf InStr(UCase(strMessage), "WARNING:") Then
        
            strIcon = "Warning"
        Else
            strIcon = "Info"
        End If
    End If
    
    Set LVITEM = lvAddRow(lvlog, Time() & " " & strMessage, , strTag, strIcon)
    LVITEM.EnsureVisible
    
    'If (booError) Then LVITEM.Bold = True
    If (booError) Then
        LVITEM.ForeColor = vbRed
        LVITEM.Bold = True
    End If
        
    lvlog.Refresh
    User = strMessage

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "User"
End Function




Private Sub mnuTestCopyCommandLine_Click()

    On Error GoTo ErrMgr

    Dim objTextFile     As New cTextFile
    Dim objSelectedItem As CTDBItem
    
    Set objSelectedItem = GetSelectedObject()
    
    ' Can only execute Test and Test Session, Folder execution was removed for now!
    If (objSelectedItem.ItemType <> TEST_ITEM) And (objSelectedItem.ItemType <> TEST_SESSION_ITEM) Then Exit Sub
    
    If (IsValidObject(objSelectedItem)) Then
    
        ' Do not execute but copy the command line
        objSelectedItem.Execute AppOptions("ScriptingExecutable"), AppOptions("ShowScriptEngineWindow"), Me, booCopyCommandLine:=True
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestExecute_Click"
End Sub

Public Function RefreshLoading(ByVal lngItemInitialized As Long, strText As String) As Boolean

    g_lngItemInitialized = lngItemInitialized
    
    If g_lngMaxItemInitializedInPreviousLoad Then
    
        On Error Resume Next

        Me.ProgressBar1.Value = Int(lngItemInitialized / g_lngMaxItemInitializedInPreviousLoad * 100)
        Me.Status TESTHARNESS_MESSAGE_7000 & " " & strText
    End If
End Function

Private Sub tmrExecutionPopUpMenu_Timer()
    tmrExecutionPopUpMenu.Enabled = False
    
    Dim v
    Dim i As Long
    
    Static MaxOptions As Long
    
    For i = 1 To MaxOptions
        On Error Resume Next
        Unload mnuExecutionPopUpItem(i)
    Next
    On Error GoTo 0
    
    i = 0
    For Each v In Split(objSelectedItemPopUp.PopUpDefinition, ";")
        If (i > 0) Then Load mnuExecutionPopUpItem(i)
        mnuExecutionPopUpItem(i).Visible = True
        mnuExecutionPopUpItem(i).Caption = v
        i = i + 1
    Next
    MaxOptions = i - 1
    Me.PopupMenu ExecutionPopUpMenu
    
End Sub

Private Sub mnuExecutionPopUp_Click()

    On Error GoTo ErrMgr

    Dim objTextFile     As New cTextFile
    Dim objWaitCursor   As New CWaitCursor
    Dim objSelectedItem As CTDBItem
    
    
    objWaitCursor.Wait Screen
    
    Set objSelectedItem = GetSelectedObject()
    
    ' Can only execute Test and Test Session, Folder execution was removed for now!
    If (objSelectedItem.ItemType <> TEST_ITEM) Then Exit Sub
    
    If (IsValidObject(objSelectedItem)) Then
    
        Set objSelectedItemPopUp = objSelectedItem
        tmrExecutionPopUpMenu.Enabled = True
    

    Else
        MsgBox "Need to select a valid test to execute"
    End If
    Exit Sub
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestExecute_Click"
End Sub





Private Sub mnuTestExecute_Click()

    On Error GoTo ErrMgr


    Dim objTextFile     As New cTextFile
    Dim objWaitCursor   As New CWaitCursor
    Dim objSelectedItem As CTDBItem
    
    objWaitCursor.Wait Screen
    
    Set objSelectedItem = GetSelectedObject()
    
    
    ' Can only execute Test and Test Session, Folder execution was removed for now!
    If (objSelectedItem.ItemType <> TEST_ITEM) And (objSelectedItem.ItemType <> TEST_SESSION_ITEM) And (objSelectedItem.ItemType <> COMPARE_DEF_ITEM) Then Exit Sub
    
    Set objSelectedItemPopUp = objSelectedItem
    
    ExecuteTest
    
    Exit Sub
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestExecute_Click"
End Sub

'Private Sub ExecuteTest(Optional strExecuteFunction As String)
Private Sub ExecuteTest()

    On Error GoTo ErrMgr

    Dim objTextFile     As New cTextFile
    Dim objWaitCursor   As New CWaitCursor
    
    objWaitCursor.Wait Screen
    
    Dim s
    
    If (IsValidObject(objSelectedItemPopUp)) Then

        Status Replace(TESTHARNESS_MESSAGE_7004, "[NAME]", objSelectedItemPopUp.Caption)
        
        objSelectedItemPopUp.OutputFileContext.Clear
                
        If (AppOptions("IconizeWhenRunATest", False)) Then Me.WindowState = vbMinimized: DoEvents

        If (Not objSelectedItemPopUp.Execute(AppOptions("ScriptingExecutable"), AppOptions("ShowScriptEngineWindow"), Me)) Then
        
        End If
        
        If (AppOptions("IconizeWhenRunATest", False)) Then Me.WindowState = vbNormal: DoEvents
         
        RefreshTestUI
        
        Status Replace(TESTHARNESS_MESSAGE_7005, "[NAME]", objSelectedItemPopUp.Name)
    Else
        MsgBox "Need to select a valid test to execute"
    End If
    Exit Sub
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestExecute_Click"
End Sub


Private Sub mnuTestSessionEditDescription_Click()

    On Error GoTo ErrMgr

    Dim objSelectedItem As CTDBItem
    
    Set objSelectedItem = GetSelectedObject()
    
    If (IsValidObject(objSelectedItem)) Then
    
        If (GetSelectedObject.EditDescription(AppOptions("editor", "notepad.exe"))) Then
        
            SelectUIObject objSelectedItem
        End If
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuTestSessionEditDescription_Click"
End Sub

Private Sub VerifyAllVBSComment_Click()

    Dim s As String
    s = InputBox("", "PassWord")
    If s = "123" Then
        g_objTDB.VerifyAllVBScriptComment Me
    Else
        MsgBox ":)", vbCritical
    End If
End Sub


Private Sub mnuSessionReportToQARepository_Click()


    On Error GoTo ErrMgr

    Dim objTextFile     As New cTextFile
    Dim objSelectedItem As CTDBItem
    
    Set objSelectedItem = GetSelectedObject()
    
    ' Can only execute Test and Test Session, Folder execution was removed for now!
    If (objSelectedItem.ItemType <> TEST_SESSION_ITEM) Then Exit Sub
    
    If (IsValidObject(objSelectedItem)) Then
            
        Dim QARepository As New CQARepository
        
        RegisterCurrentSysteNameToQARepositoryIfNecessary False
        
        If QARepository.OpenRepository(g_objIniFile) Then
        
            frmReportToQARepository.OpenDialog objSelectedItem
        Else
            ShowError TESTHARNESS_ERROR_7043, Me, "OpenDialog"
        End If
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuSessionReportToQARepository_Click"

End Sub



Private Sub mnuQARepositoryRegister_Click()
    On Error GoTo ErrMgr

    Dim objTextFile     As New cTextFile
    Dim objSelectedItem As CTDBItem
    
    Set objSelectedItem = GetSelectedObject()
    
    ' Can only execute Test and Test Session, Folder execution was removed for now!
    If (objSelectedItem.ItemType <> TEST_SESSION_ITEM) Then Exit Sub
    
    If (IsValidObject(objSelectedItem)) Then
    
            frmRegisterToQARepository.OpenDialog objSelectedItem
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmMain", "mnuQARepositoryRegister_Click"

End Sub


Private Sub mnuQARepositoryWebUI_Click()

    Dim t As New cTool
    
    t.ExecFile AppOptions("RepositoryWebURL")
    
End Sub


Public Property Let txtTestDescription_Text(ByVal vNewValue As String)

    Dim t                   As New cTextFile
    Dim strFileName         As String
    Dim strHTML             As String
    Dim v                   As Variant
    Dim arrDescriptionsLine As Variant
    Dim strDescription      As String
    Dim booHTMLDisplay      As Boolean
        
    booHTMLDisplay = InStr(LCase$(vNewValue), "<html>")
    
    strFileName = Environ("temp") & "\TestHarness.Description.htm"
    strHTML = t.LoadFile(App.Path & "\doc\TestTestSession.View.htm")
        
        
    If booHTMLDisplay Then
        arrDescriptionsLine = Split(vNewValue, vbNewLine)
        For Each v In arrDescriptionsLine
        
            If Len("" & v) > 1 Then
                If Mid(v, Len(v), 1) = ">" Then
                    strDescription = strDescription & v & vbNewLine
                Else
                    strDescription = strDescription & v & "<br>" & vbNewLine
                End If
            End If
        Next
    Else
        strDescription = "<pre>" & vbNewLine & vNewValue
    End If
    
    strHTML = PreProcess(strHTML, "DESCRIPTION", strDescription)
        
    t.LogFile strFileName, strHTML, True
    
    txtTestDescription.Navigate "file://" & strFileName

End Property




