VERSION 5.00
Object = "{65E121D4-0C60-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCHRT20.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmMain 
   Caption         =   "WebRunner"
   ClientHeight    =   6900
   ClientLeft      =   165
   ClientTop       =   735
   ClientWidth     =   9900
   Icon            =   "frmMain.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   ScaleHeight     =   6900
   ScaleWidth      =   9900
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer tmrStartScheduler 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   8400
      Top             =   3480
   End
   Begin MSComDlg.CommonDialog CM 
      Left            =   6960
      Top             =   3840
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
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
      Top             =   1260
      Visible         =   0   'False
      Width           =   72
   End
   Begin MSComctlLib.StatusBar sbStatusBar 
      Align           =   2  'Align Bottom
      Height          =   375
      Left            =   0
      TabIndex        =   1
      Top             =   6525
      Width           =   9900
      _ExtentX        =   17463
      _ExtentY        =   661
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   2
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   8467
         EndProperty
         BeginProperty Panel2 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   8467
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ImageList imlTreeListView 
      Left            =   3000
      Top             =   2160
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   10
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":030A
            Key             =   "TestSession"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":08A4
            Key             =   "GlobalTest"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":3056
            Key             =   "Root"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":35F0
            Key             =   "Folder"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":3B8A
            Key             =   "StaticFile"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":4A64
            Key             =   "SystemFolder"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":4D7E
            Key             =   "FolderOpen"
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":7530
            Key             =   "people"
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":7E0A
            Key             =   "new"
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":83A4
            Key             =   "Test"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ListView lvTrace 
      Height          =   1815
      Left            =   2280
      TabIndex        =   2
      Top             =   4440
      Width           =   2835
      _ExtentX        =   5001
      _ExtentY        =   3201
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      SmallIcons      =   "ImageListLvTrace"
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
   Begin MSComctlLib.ImageList ImageListLvTrace 
      Left            =   8040
      Top             =   5400
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
            Picture         =   "frmMain.frx":893E
            Key             =   "Error"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":8ED8
            Key             =   "Null"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":9472
            Key             =   "Succeed"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":98C4
            Key             =   "Method"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":9E5E
            Key             =   "JavaScript"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":A3F8
            Key             =   "Performance"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":A992
            Key             =   "Sql"
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":AF2C
            Key             =   "Internal"
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":BD7E
            Key             =   "Debug"
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":CC58
            Key             =   "Idea"
         EndProperty
         BeginProperty ListImage11 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":D0AA
            Key             =   "UrlDownLoaded"
         EndProperty
         BeginProperty ListImage12 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":D204
            Key             =   "Warning"
         EndProperty
         BeginProperty ListImage13 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":D79E
            Key             =   "Info"
         EndProperty
         BeginProperty ListImage14 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":DD38
            Key             =   ""
         EndProperty
         BeginProperty ListImage15 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":EC12
            Key             =   "Memory"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ImageList ImageList1 
      Left            =   9000
      Top             =   480
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   11
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":F1AC
            Key             =   "Start"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":F746
            Key             =   "StartScheduler"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":FCE0
            Key             =   "StopRecord"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":1027A
            Key             =   "Go"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":10814
            Key             =   "ObjectBrowser"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":10DAE
            Key             =   "WatchWindow"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":11348
            Key             =   "Record"
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":118E2
            Key             =   "Stop"
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":11E7C
            Key             =   "Open"
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":12416
            Key             =   "Options"
         EndProperty
         BeginProperty ListImage11 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":129B0
            Key             =   "Functions"
         EndProperty
      EndProperty
   End
   Begin MSChart20Lib.MSChart TransactionChart 
      Height          =   2235
      Left            =   240
      OleObjectBlob   =   "frmMain.frx":12F4A
      TabIndex        =   4
      Top             =   960
      Width           =   3735
   End
   Begin MSChart20Lib.MSChart TransactionPerSecondChart 
      Height          =   2235
      Left            =   4200
      OleObjectBlob   =   "frmMain.frx":15402
      TabIndex        =   3
      Top             =   720
      Width           =   3735
   End
   Begin MSComctlLib.Toolbar Toolbar 
      Align           =   1  'Align Top
      Height          =   360
      Left            =   0
      TabIndex        =   5
      Top             =   0
      Width           =   9900
      _ExtentX        =   17463
      _ExtentY        =   635
      ButtonWidth     =   609
      ButtonHeight    =   582
      AllowCustomize  =   0   'False
      Wrappable       =   0   'False
      Appearance      =   1
      Style           =   1
      ImageList       =   "ImageList1"
      _Version        =   393216
      BeginProperty Buttons {66833FE8-8583-11D1-B16A-00C0F0283628} 
         NumButtons      =   6
         BeginProperty Button1 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Open"
            Object.ToolTipText     =   "Open Script File"
            ImageKey        =   "Open"
         EndProperty
         BeginProperty Button2 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button3 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Start"
            Object.ToolTipText     =   "Run First Function - F5"
            ImageKey        =   "Start"
         EndProperty
         BeginProperty Button4 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "StartScheduler"
            ImageKey        =   "StartScheduler"
         EndProperty
         BeginProperty Button5 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Stop"
            Object.ToolTipText     =   "Stop"
            ImageKey        =   "Stop"
         EndProperty
         BeginProperty Button6 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Options"
            Object.ToolTipText     =   "Options Dialog"
            ImageKey        =   "Options"
         EndProperty
      EndProperty
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
   Begin VB.Menu mnuFile 
      Caption         =   "File"
      Begin VB.Menu mnuFileOpen 
         Caption         =   "Open"
         Shortcut        =   ^O
      End
      Begin VB.Menu mnuFileEdit 
         Caption         =   "Edit"
         Shortcut        =   ^E
      End
      Begin VB.Menu mnuFileQuit 
         Caption         =   "Quit"
         Shortcut        =   ^Q
      End
   End
   Begin VB.Menu mnuDebig 
      Caption         =   "Debug"
      Begin VB.Menu mnuTrace 
         Caption         =   "Trace"
         Begin VB.Menu mnuTraceClear 
            Caption         =   "Clear"
            Shortcut        =   {F6}
         End
         Begin VB.Menu mnuViewTrace 
            Caption         =   "View"
            Shortcut        =   ^L
         End
      End
   End
   Begin VB.Menu mnuRun 
      Caption         =   "Run"
      Begin VB.Menu mnuRunRun 
         Caption         =   "Run"
      End
      Begin VB.Menu mnuRunEnd 
         Caption         =   "End"
      End
      Begin VB.Menu mnuRunStatistic 
         Caption         =   "Statistic"
      End
      Begin VB.Menu mnuExport 
         Caption         =   "Export"
         Shortcut        =   {F5}
      End
   End
   Begin VB.Menu mnuTools 
      Caption         =   "Tools"
      Begin VB.Menu mnuOPtions 
         Caption         =   "Options"
      End
   End
   Begin VB.Menu mnuApp 
      Caption         =   "Applications"
      Begin VB.Menu mnuMAM 
         Caption         =   "MAM"
      End
      Begin VB.Menu mnuMCM 
         Caption         =   "MCM"
      End
      Begin VB.Menu mnuMPM 
         Caption         =   "MPM"
      End
      Begin VB.Menu mnuMPS 
         Caption         =   "MPS"
      End
      Begin VB.Menu mnuMOM 
         Caption         =   "MOM"
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

Public Function Status(Optional ByVal strMessage As String, Optional lngIndex As Long = 1) As Boolean
    Me.sbStatusBar.Panels(lngIndex).Text = strMessage
End Function

Private Sub SizeControls(x As Long, lngLostHeight As Long)

    On Error Resume Next
    
    lvTrace.Height = lngLostHeight
    
    TransactionChart.Left = 0
    lvTrace.Left = 0
    
    ' Set the width
    If x < sglSplitLimit Then x = sglSplitLimit
    If x > (Me.Width - sglSplitLimit) Then x = Me.Width - sglSplitLimit
    
    ' Test TreeView
    TransactionChart.Width = x
    TransactionChart.Top = Toolbar.Height + (0 * Screen.TwipsPerPixelX)
    TransactionChart.Height = Me.ScaleHeight - (sbStatusBar.Height + Toolbar.Height + lvTrace.Height + (5 * Screen.TwipsPerPixelY))
    
    ' Details TextBox
    TransactionPerSecondChart.Top = TransactionChart.Top
    TransactionPerSecondChart.Left = TransactionChart.Left + TransactionChart.Width + (2 * Screen.TwipsPerPixelX)
    TransactionPerSecondChart.Width = Me.Width - (TransactionChart.Width + (10 * Screen.TwipsPerPixelX))
    TransactionPerSecondChart.Height = TransactionChart.Height + (0 * Screen.TwipsPerPixelY)
    
    ' Log ListBox
    lvTrace.Width = Me.Width - (Screen.TwipsPerPixelX * 8)
    lvTrace.Top = TransactionChart.Top + TransactionChart.Height + (3 * Screen.TwipsPerPixelY)
    
    imgSplitterDown.Left = 0
    imgSplitterDown.Width = Me.Width
    imgSplitterDown.Top = TransactionChart.Top + TransactionChart.Height - (1 * Screen.TwipsPerPixelY)
    
    imgSplitter.Left = x
    imgSplitter.Top = TransactionChart.Top
    imgSplitter.Height = TransactionChart.Height
    
    Exit Sub
errmgr:
   
End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)
    Select Case KeyAscii
        Case vbKeyEscape
            g_objPerformanceScriptManager.CancelScript = MsgBox(MPFM_MSG_1005, vbQuestion + vbYesNo) = vbYes
    End Select
End Sub

Private Sub Form_Load()

    InitScreenSize LOAD_DATA
    Me.Caption = MPFM_MSG_1000
    
    Dim strScriptFileName  As String
    strScriptFileName = g_objIniFile.getVar("FILE", "VBScriptFileName")
    
    If Len(strScriptFileName) Then
    
        Me.ScriptFileName = strScriptFileName
    End If
    TransactionPerSecondChart_DblClick
End Sub

Private Sub Form_Resize()

    On Error Resume Next
    
    If Me.Width < 3000 Then Me.Width = 3000
    
    SizeControls TransactionChart.Width, Me.lvTrace.Height
    
   
   If lvTrace.ColumnHeaders.Count = 0 Then
        
        lvAddColumn lvTrace, "Message"
    End If
    lvTrace.ColumnHeaders.Item(1).Width = (lvTrace.Width) - (24 * Screen.TwipsPerPixelX)
    
    
End Sub

 

Private Sub Form_Unload(Cancel As Integer)
    InitScreenSize SAVE_DATA
End Sub

Private Sub imgSplitter_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    With imgSplitter
        picSplitter.Move .Left, .Top, .Width \ 2, .Height - 20
    End With
    picSplitter.Visible = True
    mbMoving = True

    Exit Sub
errmgr:
   
End Sub


Private Sub imgSplitter_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    Dim sglPos As Single
    If mbMoving Then
        sglPos = x + imgSplitter.Left
        If sglPos < sglSplitLimit Then
            picSplitter.Left = sglSplitLimit
        ElseIf sglPos > Me.Width - sglSplitLimit Then
            picSplitter.Left = Me.Width - sglSplitLimit
        Else
            picSplitter.Left = sglPos
        End If
    End If

    Exit Sub
errmgr:
   
End Sub


Private Sub imgSplitter_MouseUp(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    SizeControls picSplitter.Left, Me.lvTrace.Height
    picSplitter.Visible = False
    mbMoving = False

    Exit Sub
errmgr:
   
End Sub




Private Sub imgSplitterDown_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    With imgSplitterDown
    
        picSplitter.Move .Left, .Top, .Width, .Height \ 2
    End With
    picSplitter.Visible = True
    mbMoving = True
    Exit Sub
errmgr:
   
   
End Sub

Private Sub imgSplitterDown_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

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
errmgr:
   
End Sub

Private Sub imgSplitterDown_MouseUp(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    Dim lngLstLogHeight As Long
    Dim lngSplitterPos  As Long
    
    lngSplitterPos = imgSplitterDown.Top + Y
    If lngSplitterPos < sglSplitLimit Then lngSplitterPos = sglSplitLimit
        
    
    lngLstLogHeight = (Me.Height - Me.Toolbar.Height - sbStatusBar.Height - lngSplitterPos - (35 * Screen.TwipsPerPixelY))
    
    
    Debug.Print "lngLstLogHeight " & lngLstLogHeight
    
    
    SizeControls TransactionChart.Width, lngLstLogHeight
    picSplitter.Visible = False
    mbMoving = False
    Exit Sub
errmgr:
   
End Sub


Private Function InitScreenSize(eA As eAPP_ACTION) As Boolean

    Select Case eA
    
        Case eAPP_ACTION.SAVE_DATA
        
             g_objIniFile.SetVar "SlideBar", "TransactionChart.Width", TransactionChart.Width
             g_objIniFile.SetVar "SlideBar", "lvTrace.Height", lvTrace.Height
             g_objIniFile.FormSaveRestore Me, True, True
             
        Case eAPP_ACTION.LOAD_DATA
        
            If (IsNumeric(g_objIniFile.getVar("SlideBar", "TransactionChart.Width"))) Then TransactionChart.Width = g_objIniFile.getVar("SlideBar", "TransactionChart.Width")
            If (IsNumeric(g_objIniFile.getVar("SlideBar", "lvTrace.Height"))) Then lvTrace.Height = g_objIniFile.getVar("SlideBar", "lvTrace.Height")
            g_objIniFile.FormSaveRestore Me, False, True
    End Select
    InitScreenSize = True
    Exit Function
   
End Function



Private Sub lvTrace_DblClick()
    VB.Clipboard.Clear
    VB.Clipboard.SetText lvTrace.SelectedItem.Text
End Sub

Private Sub mnuExport_Click()
    g_objPerformanceScriptManager.Export
    'UpDateTransactionPerHourGraph
End Sub

Private Sub tmrStartScheduler_Timer()
    tmrStartScheduler.Enabled = False
    g_objPerformanceScriptManager.Run 250 + CLng(Rnd * 250)
    UpDateTransactionPerHourGraph
    If Not g_objPerformanceScriptManager.CancelScript Then
        tmrStartScheduler.Enabled = True
    End If
End Sub

Private Sub TransactionPerSecondChart_DblClick()
    UpDateTransactionPerHourGraph
End Sub

Private Sub mnuFileEdit_Click()
    Shell AppOptions("editor") & " " & Me.ScriptFileName
    
End Sub

Private Sub mnuFileOpen_Click()

    Dim objTool             As New cTool
    Dim strScriptFileName   As String
    
    strScriptFileName = objTool.getUserOpenFile(cm, MPFM_MSG_1002, MPFM_MSG_1003)
    If Len(strScriptFileName) Then
    
        Me.ScriptFileName = strScriptFileName
    End If
End Sub

Private Sub mnuFileQuit_Click()
    Unload Me
End Sub

Private Sub mnuMAM_Click()
    LanchWebApp "mam"
End Sub

Private Sub mnuMCM_Click()
    LanchWebApp "mcm"
End Sub

Private Sub mnuMOM_Click()
    LanchWebApp "mom"
End Sub

Private Sub mnuMPM_Click()
    LanchWebApp "mpm"
End Sub

Private Sub mnuMPS_Click()
    LanchWebApp "samplesite"
End Sub

Private Sub mnuOPtions_Click()
    frmOptions.OpenDialog g_objIniFile
End Sub

Private Sub mnuRunEnd_Click()
    tmrStartScheduler.Enabled = False
    g_objPerformanceScriptManager.CancelScript = True
End Sub

Private Sub mnuRunRun_Click()
    g_objPerformanceScriptManager.Run
    UpDateTransactionPerHourGraph
End Sub

Private Sub mnuRunStatistic_Click()
        g_objPerformanceScriptManager.Statistic
        UpDateTransactionPerHourGraph
End Sub

Private Sub mnuTraceClear_Click()
lvTrace.ListItems.Clear
End Sub

Private Sub mnuViewTrace_Click()
    Shell AppOptions("editor") & " " & MPFMLogFileName()
End Sub

Private Sub Toolbar_ButtonClick(ByVal Button As MSComctlLib.Button)
    Select Case Button.key
        Case "Open"
            mnuFileOpen_Click
        Case "Options"
            frmOptions.OpenDialog g_objIniFile
        Case "Start"
            mnuRunRun_Click
        Case "Stop"
            mnuRunEnd_Click
        Case "StartScheduler"
            tmrStartScheduler.Enabled = True
    End Select
    
End Sub


Public Function TRACE(ByVal strMessage As String, eMode As MPFM_TRACE_MODE) As Boolean

    On Error GoTo errmgr

    Dim objTextFile     As New cTextFile
    Dim strIcon         As String
    Dim LVITEM          As ListItem
    Dim booError        As Boolean
    Dim lngColor        As Long
    Dim strTraceMode    As String
    Dim lv              As ListView
    Dim strOnTraceMessage As String
    
    TRACE = True
    
    Set lv = lvTrace
    
    lngColor = vbBlack

    Select Case eMode
        Case mpfmINFO
            strIcon = "Info"
        Case mpfmERROR
            strIcon = "Error"
        Case mpfmWARNING
            strIcon = "Warning"
        Case mpfmSQL
            strIcon = "Sql"
        Case mpfmDEBUG
            strIcon = "Debug"
        Case mpfmSUCCEED
            strIcon = "Succeed"
        Case mpfmPERFORMANCE
            strIcon = "Performance"
        Case mpfmCLEAR_TRACE
            lvTrace.ListItems.Clear
            Exit Function
        Case Else
            strIcon = "Info"
    End Select

    If (Len(Trim(strMessage)) = 0) Then Exit Function
    
    Set LVITEM = lvAddRow(lv, Now() & " " & strMessage, , , strIcon)
    LVITEM.ForeColor = lngColor
    LVITEM.Selected = True
    LVITEM.EnsureVisible
    lv.Refresh
    GlobalDoEvents
    
    objTextFile.LogFile MPFMLogFileName(), Now() & " " & strMessage
    
    Exit Function
errmgr:
    Debug.Assert 0
    AppShowError MPFM_ERROR_1001 & " " & GetVBErrorString(), "frmMain.frm", "TRACE"
End Function


Public Property Get ScriptFileName() As Variant
    ScriptFileName = g_objPerformanceScriptManager.ScriptFileName
End Property

Public Property Let ScriptFileName(ByVal v As Variant)
    
    
    g_objPerformanceScriptManager.ScriptFileName = v
    g_objIniFile.SetVar "FILE", "VBScriptFileName", v
    
    Me.Caption = MPFM_MSG_1000 & " [" & g_objPerformanceScriptManager.ScriptFileNameOnly & "]"
End Property

Public Function UpDateTransactionPerHourGraph() As Boolean
    g_objPerformanceScriptManager.DisplayTransactionPerHourGraph Me.TransactionPerSecondChart, Me.TransactionChart
End Function
