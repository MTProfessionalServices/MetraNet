VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
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
   Begin MSComDlg.CommonDialog CM 
      Left            =   1800
      Top             =   5400
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
   Begin VB.TextBox txtTestDescription 
      BeginProperty Font 
         Name            =   "Fixedsys"
         Size            =   9
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1455
      Left            =   4320
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   3
      Top             =   1200
      Width           =   2535
   End
   Begin MSComctlLib.TreeView tvTests 
      Height          =   3495
      Left            =   -240
      TabIndex        =   2
      Top             =   720
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
      Left            =   2520
      Top             =   1680
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
   Begin MSComctlLib.ImageList imlToolbarIcons 
      Left            =   3120
      Top             =   480
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
            Picture         =   "frmMain.frx":893E
            Key             =   "New"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":8A50
            Key             =   "TestSession"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":8FEA
            Key             =   "Properties"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":90FC
            Key             =   "Execute"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":920E
            Key             =   "Macro"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":9320
            Key             =   "Open"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":9432
            Key             =   "Delete"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.Toolbar Toolbar 
      Align           =   1  'Align Top
      Height          =   360
      Left            =   0
      TabIndex        =   4
      Top             =   0
      Width           =   9900
      _ExtentX        =   17463
      _ExtentY        =   635
      ButtonWidth     =   609
      ButtonHeight    =   582
      AllowCustomize  =   0   'False
      Appearance      =   1
      Style           =   1
      ImageList       =   "imlToolbarIcons"
      _Version        =   393216
      BeginProperty Buttons {66833FE8-8583-11D1-B16A-00C0F0283628} 
         NumButtons      =   3
         BeginProperty Button1 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Open"
            Object.ToolTipText     =   "Open"
            ImageKey        =   "Open"
         EndProperty
         BeginProperty Button2 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button3 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Options"
            Object.ToolTipText     =   "Options"
            ImageKey        =   "Properties"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ImageList ImageListLvTrace2 
      Left            =   7860
      Top             =   4620
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   14
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":99CC
            Key             =   "Debug"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":A8A6
            Key             =   "WebService"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":AA00
            Key             =   "Sql"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":AF9A
            Key             =   "Succeed2"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":B534
            Key             =   "JavaScript"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":BACE
            Key             =   "Internal"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":C920
            Key             =   "Info"
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":CEBA
            Key             =   "Error"
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":D454
            Key             =   "UrlDownLoaded"
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":D5AE
            Key             =   "Memory"
         EndProperty
         BeginProperty ListImage11 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":DB48
            Key             =   "Method"
         EndProperty
         BeginProperty ListImage12 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":E0E2
            Key             =   "Null"
         EndProperty
         BeginProperty ListImage13 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":E67C
            Key             =   "Performance"
         EndProperty
         BeginProperty ListImage14 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":EC16
            Key             =   "Warning"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ListView lvTrace 
      Height          =   1815
      Left            =   840
      TabIndex        =   5
      Top             =   4500
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
      SmallIcons      =   "ImageListLvTrace2"
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
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
      Begin VB.Menu mnuFileOPen 
         Caption         =   "Open"
         Shortcut        =   ^O
      End
      Begin VB.Menu mnuFileQuit 
         Caption         =   "Quit"
         Shortcut        =   ^Q
      End
   End
   Begin VB.Menu mnuGenerator 
      Caption         =   "Generator"
      Begin VB.Menu mnuGeneratorStdTest 
         Caption         =   "Standard Test"
         Shortcut        =   {F5}
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

Private m_strFileName As String

Private m_strClipBoard As String ' Contains the name of the object to copy and paste






Private Sub SizeControls(x As Long, lngLostHeight As Long)

    On Error Resume Next
    
    lvTrace.Height = lngLostHeight
    
    
    tvTests.Left = 0
    lvTrace.Left = 0
    
    ' Set the width
    If x < sglSplitLimit Then x = sglSplitLimit
    If x > (Me.Width - sglSplitLimit) Then x = Me.Width - sglSplitLimit
    
    ' Test TreeView
    tvTests.Width = x
    tvTests.Top = Toolbar.Height + (0 * Screen.TwipsPerPixelX)
    tvTests.Height = Me.ScaleHeight - (sbStatusBar.Height + Toolbar.Height + lvTrace.Height + (5 * Screen.TwipsPerPixelY))
    
    ' Details TextBox
    txtTestDescription.Top = tvTests.Top
    txtTestDescription.Left = tvTests.Left + tvTests.Width + (2 * Screen.TwipsPerPixelX)
    txtTestDescription.Width = Me.Width - (tvTests.Width + (10 * Screen.TwipsPerPixelX))
    txtTestDescription.Height = tvTests.Height + (0 * Screen.TwipsPerPixelY)
    
    ' Log ListBox
    lvTrace.Width = Me.Width - (Screen.TwipsPerPixelX * 8)
    lvTrace.Top = tvTests.Top + tvTests.Height + (3 * Screen.TwipsPerPixelY)
    
    imgSplitterDown.Left = 0
    imgSplitterDown.Width = Me.Width
    imgSplitterDown.Top = tvTests.Top + tvTests.Height - (1 * Screen.TwipsPerPixelY)
    
    imgSplitter.Left = x
    imgSplitter.Top = tvTests.Top
    imgSplitter.Height = tvTests.Height
    
    

    Exit Sub
ErrMgr:
   
End Sub



Private Sub Toolbar1_ButtonClick(ByVal Button As MSComctlLib.Button)
    On Error Resume Next
    Select Case Button.Key
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





Private Sub Form_Load()

    InitScreenSize LOAD_DATA
    
    'InitTreeViewData Me.tvTests
    
    
    
    
    'mnuTest.Visible = False
    'mnuFolder.Visible = False
    'mnuLog.Visible = False
'    Dim o As CVariables
 '   o.Add "BillFormat", 1, vbLong, , "Bill Format", "Tag"
    
  Dim strF As String
    
    g_objIniFile.FormSaveRestore Me, False, True
    Caption = WSG_MESSAGE_1000
    
    strF = AppOptions("File.Last.Name")
    If Len(strF) Then
        FileName = strF
    End If
    
End Sub


Private Sub Form_Resize()

    On Error Resume Next
    
    If Me.Width < 3000 Then Me.Width = 3000
    
    SizeControls tvTests.Width, Me.lvTrace.Height
    
    
    If lvTrace.ColumnHeaders.Count = 0 Then
        lvAddColumn lvTrace, "Message", True, (Me.Width / Screen.TwipsPerPixelX) - (32)
    End If
    
    'tmrResize.Enabled = True
End Sub

 

Private Sub Form_Unload(Cancel As Integer)
    InitScreenSize SAVE_DATA
    
    
End Sub

Private Sub imgSplitter_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo ErrMgr

    With imgSplitter
        picSplitter.Move .Left, .Top, .Width \ 2, .Height - 20
    End With
    picSplitter.Visible = True
    mbMoving = True

    Exit Sub
ErrMgr:
   
End Sub


Private Sub imgSplitter_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo ErrMgr

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
ErrMgr:
   
End Sub


Private Sub imgSplitter_MouseUp(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo ErrMgr

    SizeControls picSplitter.Left, Me.lvTrace.Height
    picSplitter.Visible = False
    mbMoving = False

    Exit Sub
ErrMgr:
   
End Sub




Private Sub imgSplitterDown_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo ErrMgr

    With imgSplitterDown
    
        picSplitter.Move .Left, .Top, .Width, .Height \ 2
    End With
    picSplitter.Visible = True
    mbMoving = True
    Exit Sub
ErrMgr:
   
   
End Sub

Private Sub imgSplitterDown_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)

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

Private Sub imgSplitterDown_MouseUp(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo ErrMgr

    Dim lngLstLogHeight As Long
    Dim lngSplitterPos  As Long
    
    lngSplitterPos = imgSplitterDown.Top + Y
    If lngSplitterPos < sglSplitLimit Then lngSplitterPos = sglSplitLimit
        
    
    lngLstLogHeight = (Me.Height - Me.Toolbar.Height - sbStatusBar.Height - lngSplitterPos - (35 * Screen.TwipsPerPixelY))
    
    
    Debug.Print "lngLstLogHeight " & lngLstLogHeight
    
    
    SizeControls tvTests.Width, lngLstLogHeight
    picSplitter.Visible = False
    mbMoving = False
    Exit Sub
ErrMgr:
   
End Sub


Private Function InitScreenSize(eA As eAPP_ACTION) As Boolean

    Select Case eA
    
        Case eAPP_ACTION.SAVE_DATA
        
             g_objIniFile.SetVar "SlideBar", "tvTests.Width", tvTests.Width
             g_objIniFile.SetVar "SlideBar", "lvTrace.Height", lvTrace.Height
             g_objIniFile.FormSaveRestore Me, True, True
             
        Case eAPP_ACTION.LOAD_DATA
        
            If (IsNumeric(g_objIniFile.getVar("SlideBar", "tvTests.Width"))) Then tvTests.Width = g_objIniFile.getVar("SlideBar", "tvTests.Width")
            If (IsNumeric(g_objIniFile.getVar("SlideBar", "lvTrace.Height"))) Then lvTrace.Height = g_objIniFile.getVar("SlideBar", "lvTrace.Height")
            g_objIniFile.FormSaveRestore Me, False, True
    End Select
    InitScreenSize = True
    Exit Function
   
End Function














Private Sub mnuFileQuit_Click()
    Unload Me
End Sub

Private Sub mnuGeneratorStdTest_Click()
    Dim objWST As New CWebServiceGenerator
    Status WSG_MESSAGE_1004
    objWST.Initialize FileName
    Status
End Sub

Private Sub Toolbar_ButtonClick(ByVal Button As MSComctlLib.Button)
    Select Case Button.Key
        Case "Options"
        Case "Open"
            mnuFileOpen_Click
    End Select
    
End Sub




Private Sub mnuFileOpen_Click()
    Dim objTool     As New cTool
    Dim strF        As String
    Dim objTextFile As New cTextFile
    
    strF = objTool.getUserOpenFile(CM, WSG_MESSAGE_1001, WSG_MESSAGE_1002, False, AppOptions("File.Last.Path", App.path))
    If Len(strF) Then
        AppOptions("File.Last.Path") = objTextFile.GetPathFromFileName(strF)
        AppOptions("File.Last.Name") = strF
        FileName = strF
    End If
End Sub

 

Private Sub tmrSecond_Timer()
Status Now() & " ", 3
End Sub



Public Property Get FileName() As String
    FileName = m_strFileName
    
End Property

Public Property Let FileName(ByVal vNewValue As String)
    Dim objTextFile As New cTextFile
    m_strFileName = vNewValue
    
    Caption = objTextFile.GetFileName(m_strFileName) & " - " & WSG_MESSAGE_1000
End Property


Public Function Status(Optional strMessage As String, Optional lngIndex As Long = 1)

    On Error GoTo ErrMgr

    sbStatusBar.Panels(lngIndex).Text = strMessage
    sbStatusBar.Refresh
    Exit Function
ErrMgr:
    
End Function




Public Function TRACE(ByVal strMessage As String, eMode As WSG_TRACE) As Boolean

    On Error GoTo ErrMgr

    Dim objTextFile     As New cTextFile
    Dim strIcon         As String
    Dim LVITEM          As ListItem
    Dim booError        As Boolean
    Dim lngColor        As Long
    Dim strTraceMode    As String
    Dim lv              As ListView
    Dim strOnTraceMessage As String
    
    TRACE = True
    
    If eMode And w3rCLEAR_TRACE Then
        
        Exit Function
    End If
    
    Set lv = lvTrace
    strTraceMode = "[" & GetW3RunnerTraceString(eMode) & "]"
    
    lngColor = vbBlack
    
        
    Select Case eMode
        
        Case w3rINFO
            strIcon = "Info"
        Case w3rERROR
            strIcon = "Error"
            
        Case w3rWARNING
            strIcon = "Warning"

        
        Case w3rDEBUG
            strIcon = "Debug"
            
        Case w3rINTERNAL
            strIcon = "Internal"
        
        Case w3rCLEAR_TRACE
            lvTrace.ListItems.Clear
            Exit Function
        Case Else
            strIcon = "Info"
    End Select

    If (Len(Trim(strMessage)) = 0) Then Exit Function
    
    strOnTraceMessage = Trim(strTraceMode) & Trim(strMessage)
    
    Set LVITEM = lvAddRow(lv, Time() & " " & strMessage, , , strIcon)
    LVITEM.ForeColor = lngColor
    LVITEM.Selected = True
    LVITEM.EnsureVisible
    lv.Refresh
    DoEvents
    Exit Function
ErrMgr:
    
End Function


Public Function Generated(strText As String, Optional booClear As Boolean = False) As Boolean
    If booClear Then
        txtTestDescription.Text = ""
    Else
        txtTestDescription.Text = txtTestDescription.Text & strText
    End If
End Function
