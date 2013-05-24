VERSION 5.00
Object = "{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}#1.1#0"; "shdocvw.dll"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "Mscomctl.ocx"
Begin VB.Form frmMain 
   BackColor       =   &H8000000A&
   Caption         =   "W3Runner"
   ClientHeight    =   7380
   ClientLeft      =   165
   ClientTop       =   735
   ClientWidth     =   12735
   Icon            =   "frmMain.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   ScaleHeight     =   7380
   ScaleWidth      =   12735
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer tmrPOSTURL 
      Enabled         =   0   'False
      Interval        =   500
      Left            =   7140
      Top             =   5160
   End
   Begin SHDocVwCtl.WebBrowser ReportBrowser 
      Height          =   1815
      Left            =   9480
      TabIndex        =   7
      Top             =   420
      Visible         =   0   'False
      Width           =   2895
      ExtentX         =   5106
      ExtentY         =   3201
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
   Begin VB.Timer tmrCloseWindow 
      Enabled         =   0   'False
      Interval        =   10
      Left            =   10920
      Top             =   6120
   End
   Begin MSComctlLib.ImageList ImageListLvTrace2 
      Left            =   7140
      Top             =   4200
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
            Picture         =   "frmMain.frx":0E42
            Key             =   "Debug"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":1D1C
            Key             =   "WebService"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":1E76
            Key             =   "Succeed2"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":2410
            Key             =   "HTTP"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":256A
            Key             =   "JavaScript"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":2B04
            Key             =   "Internal"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":3956
            Key             =   "Sql"
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":3EF0
            Key             =   "Info"
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":448A
            Key             =   "Error"
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":4A24
            Key             =   "UrlDownLoaded"
         EndProperty
         BeginProperty ListImage11 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":4B7E
            Key             =   "Memory"
         EndProperty
         BeginProperty ListImage12 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":5118
            Key             =   "Method"
         EndProperty
         BeginProperty ListImage13 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":56B2
            Key             =   "Null"
         EndProperty
         BeginProperty ListImage14 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":5C4C
            Key             =   "Performance"
         EndProperty
         BeginProperty ListImage15 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":61E6
            Key             =   "Warning"
         EndProperty
      EndProperty
   End
   Begin VB.Timer tmrFullScreen 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   7920
      Top             =   6000
   End
   Begin MSComctlLib.ImageList ImageList2 
      Left            =   10260
      Top             =   4980
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   23
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":6780
            Key             =   ""
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":6AD4
            Key             =   ""
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":6E44
            Key             =   ""
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":71BC
            Key             =   ""
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":7539
            Key             =   ""
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":78BB
            Key             =   ""
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":7C3D
            Key             =   ""
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":7FBE
            Key             =   ""
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":833A
            Key             =   ""
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":86B2
            Key             =   ""
         EndProperty
         BeginProperty ListImage11 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":8A23
            Key             =   ""
         EndProperty
         BeginProperty ListImage12 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":8D8A
            Key             =   ""
         EndProperty
         BeginProperty ListImage13 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":90DE
            Key             =   ""
         EndProperty
         BeginProperty ListImage14 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":944E
            Key             =   ""
         EndProperty
         BeginProperty ListImage15 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":97C6
            Key             =   ""
         EndProperty
         BeginProperty ListImage16 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":9B43
            Key             =   ""
         EndProperty
         BeginProperty ListImage17 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":9EC5
            Key             =   ""
         EndProperty
         BeginProperty ListImage18 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":A247
            Key             =   ""
         EndProperty
         BeginProperty ListImage19 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":A5C8
            Key             =   ""
         EndProperty
         BeginProperty ListImage20 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":A944
            Key             =   ""
         EndProperty
         BeginProperty ListImage21 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":ACBC
            Key             =   ""
         EndProperty
         BeginProperty ListImage22 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":B02D
            Key             =   ""
         EndProperty
         BeginProperty ListImage23 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":B394
            Key             =   ""
         EndProperty
      EndProperty
   End
   Begin VB.TextBox TxtPosRef 
      Height          =   375
      Left            =   720
      TabIndex        =   6
      Top             =   6060
      Visible         =   0   'False
      Width           =   1635
   End
   Begin VB.Timer tmrCommandLineExecute 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   8580
      Top             =   5940
   End
   Begin VB.Timer tmrAnimation 
      Enabled         =   0   'False
      Interval        =   200
      Left            =   10860
      Top             =   2820
   End
   Begin VB.Timer TimerObjectClick 
      Enabled         =   0   'False
      Interval        =   50
      Left            =   8280
      Top             =   5160
   End
   Begin VB.Timer tmrWatchReadyState 
      Enabled         =   0   'False
      Interval        =   500
      Left            =   8880
      Top             =   5160
   End
   Begin VB.PictureBox picSplitter 
      BackColor       =   &H00808080&
      BorderStyle     =   0  'None
      FillColor       =   &H00808080&
      Height          =   3540
      Left            =   9180
      ScaleHeight     =   1541.468
      ScaleMode       =   0  'User
      ScaleWidth      =   780
      TabIndex        =   3
      Top             =   660
      Visible         =   0   'False
      Width           =   72
   End
   Begin MSComctlLib.ListView lvTrace 
      Height          =   1815
      Left            =   120
      TabIndex        =   0
      Top             =   4080
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
      ForeColor       =   0
      BackColor       =   16777215
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
   Begin VB.PictureBox ImageRunner 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   270
      Left            =   10440
      Picture         =   "frmMain.frx":B6E8
      ScaleHeight     =   240
      ScaleWidth      =   240
      TabIndex        =   2
      Top             =   2880
      Visible         =   0   'False
      Width           =   270
   End
   Begin MSComctlLib.ImageList ImageList1 
      Left            =   7440
      Top             =   840
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   12
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":BA2C
            Key             =   "Start"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":BFC6
            Key             =   "WebService"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":C120
            Key             =   "WelcomePage"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":C6BA
            Key             =   "StopRecord"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":CC54
            Key             =   "Go"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":D1EE
            Key             =   "ObjectBrowser"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":D788
            Key             =   "WatchWindow"
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":DD22
            Key             =   "Record"
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":E2BC
            Key             =   "Stop"
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":E856
            Key             =   "Open"
         EndProperty
         BeginProperty ListImage11 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":EDF0
            Key             =   "Options"
         EndProperty
         BeginProperty ListImage12 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":F38A
            Key             =   "Functions"
         EndProperty
      EndProperty
   End
   Begin VB.Timer tmrURL 
      Enabled         =   0   'False
      Interval        =   500
      Left            =   7680
      Top             =   5160
   End
   Begin MSComctlLib.StatusBar StatusBar1 
      Align           =   2  'Align Bottom
      Height          =   300
      Left            =   0
      TabIndex        =   1
      Top             =   7080
      Width           =   12735
      _ExtentX        =   22463
      _ExtentY        =   529
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   2
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   10954
         EndProperty
         BeginProperty Panel2 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   10954
         EndProperty
      EndProperty
   End
   Begin MSComDlg.CommonDialog cm 
      Left            =   9360
      Top             =   2280
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin SHDocVwCtl.WebBrowser WebBrowser 
      Height          =   2955
      Left            =   120
      TabIndex        =   5
      Top             =   480
      Width           =   5355
      ExtentX         =   9446
      ExtentY         =   5212
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
   Begin MSComctlLib.ListView lvInternal 
      Height          =   1815
      Left            =   3120
      TabIndex        =   4
      Top             =   4140
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
      ForeColor       =   0
      BackColor       =   16777215
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
   Begin MSComctlLib.Toolbar Toolbar1 
      Align           =   1  'Align Top
      Height          =   360
      Left            =   0
      TabIndex        =   8
      Top             =   0
      Width           =   12735
      _ExtentX        =   22463
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
         NumButtons      =   12
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
            Key             =   "Stop"
            Object.ToolTipText     =   "Stop"
            ImageKey        =   "Stop"
         EndProperty
         BeginProperty Button5 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Record"
            Object.ToolTipText     =   "Record Mode"
            ImageKey        =   "Record"
         EndProperty
         BeginProperty Button6 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "WatchWindow"
            Object.ToolTipText     =   "Watch Window"
            ImageKey        =   "WatchWindow"
         EndProperty
         BeginProperty Button7 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button8 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Options"
            Object.ToolTipText     =   "Options"
            ImageKey        =   "Options"
         EndProperty
         BeginProperty Button9 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Welcome"
            Object.ToolTipText     =   "Welcome Page"
            ImageKey        =   "WelcomePage"
         EndProperty
         BeginProperty Button10 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button11 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   4
            Object.Width           =   6900
            BeginProperty ButtonMenus {66833FEC-8583-11D1-B16A-00C0F0283628} 
               NumButtonMenus  =   1
               BeginProperty ButtonMenu1 {66833FEE-8583-11D1-B16A-00C0F0283628} 
               EndProperty
            EndProperty
         EndProperty
         BeginProperty Button12 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "GoUrl"
            Object.ToolTipText     =   "Go"
            ImageKey        =   "Go"
         EndProperty
      EndProperty
      Begin VB.ComboBox txtURL 
         Height          =   315
         Left            =   3540
         TabIndex        =   10
         Top             =   0
         Width           =   6075
      End
      Begin VB.TextBox txtAddress 
         BackColor       =   &H80000004&
         BorderStyle     =   0  'None
         Height          =   285
         Left            =   2820
         TabIndex        =   9
         Text            =   "Address"
         Top             =   60
         Width           =   615
      End
   End
   Begin VB.Image imgSplitter 
      Height          =   3525
      Left            =   6420
      MousePointer    =   9  'Size W E
      Stretch         =   -1  'True
      Top             =   720
      Width           =   210
   End
   Begin VB.Image imgSplitterDown 
      Height          =   165
      Left            =   5340
      MousePointer    =   7  'Size N S
      Top             =   4800
      Visible         =   0   'False
      Width           =   9390
   End
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuOpen 
         Caption         =   "&Open"
         Shortcut        =   ^O
      End
      Begin VB.Menu mnuEdit 
         Caption         =   "&Edit"
         Shortcut        =   ^E
      End
      Begin VB.Menu mnuSaveCrypted 
         Caption         =   "Save Crypted"
      End
      Begin VB.Menu mnuRien2 
         Caption         =   "-"
         Index           =   0
      End
      Begin VB.Menu mnuPreviousFileMain 
         Caption         =   "Previous Files"
         Begin VB.Menu mnuPreviousFile 
            Caption         =   ""
            Index           =   1
         End
         Begin VB.Menu mnuPreviousFile 
            Caption         =   ""
            Index           =   2
         End
         Begin VB.Menu mnuPreviousFile 
            Caption         =   ""
            Index           =   3
         End
         Begin VB.Menu mnuPreviousFile 
            Caption         =   ""
            Index           =   4
         End
         Begin VB.Menu mnuPreviousFile 
            Caption         =   ""
            Index           =   5
         End
         Begin VB.Menu mnuPreviousFile 
            Caption         =   ""
            Index           =   6
         End
      End
      Begin VB.Menu mnuRien22 
         Caption         =   "-"
      End
      Begin VB.Menu mnuQuit 
         Caption         =   "Quit"
         Shortcut        =   ^Q
      End
   End
   Begin VB.Menu mnuView 
      Caption         =   "&View"
      Begin VB.Menu mnuFullScreen 
         Caption         =   "&Full Screen"
         Shortcut        =   {F11}
      End
      Begin VB.Menu mnuViewStandard 
         Caption         =   "&Standard"
         Shortcut        =   {F12}
      End
      Begin VB.Menu mnuViewReport 
         Caption         =   "&Report"
         Shortcut        =   {F9}
      End
   End
   Begin VB.Menu mnuDebug 
      Caption         =   "&Debug"
      Begin VB.Menu mnuWatchWindow 
         Caption         =   "&Watch Window"
         Shortcut        =   ^W
      End
      Begin VB.Menu mnuProtocolWindow 
         Caption         =   "Protocol Window"
         Shortcut        =   ^P
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "&Trace"
         Begin VB.Menu mnuTraceCopy 
            Caption         =   "&Copy"
         End
         Begin VB.Menu mnuDebugClearTrace 
            Caption         =   "&Clear"
            Shortcut        =   {F6}
         End
         Begin VB.Menu mnuTraceViewLine 
            Caption         =   "&View line"
         End
         Begin VB.Menu mnuViewTrace 
            Caption         =   "View &Log File"
            Shortcut        =   ^L
         End
      End
      Begin VB.Menu mnuClearIECache 
         Caption         =   "&Clear IE Cache"
         Shortcut        =   ^{F6}
      End
      Begin VB.Menu mnuSkipWaitForDowload 
         Caption         =   "&Skip WaitForDowload"
      End
      Begin VB.Menu mnuMoveMouse 
         Caption         =   "Switch &Move Mouse On/Off"
         Shortcut        =   ^M
      End
   End
   Begin VB.Menu mnuRun 
      Caption         =   "&Run"
      Begin VB.Menu mnuStart 
         Caption         =   "&Start"
         Shortcut        =   {F5}
      End
      Begin VB.Menu mnuTest 
         Caption         =   "Tests"
         Begin VB.Menu mnuTestMethod 
            Caption         =   "main"
            Index           =   0
         End
      End
      Begin VB.Menu mnuCancelScript 
         Caption         =   "&End"
      End
      Begin VB.Menu mnuRecord 
         Caption         =   "&Record"
         Shortcut        =   ^R
      End
   End
   Begin VB.Menu mnuTool 
      Caption         =   "&Tools"
      Begin VB.Menu mnuOptions 
         Caption         =   "&Options"
      End
      Begin VB.Menu mnuInternetExplorerOptions 
         Caption         =   "&Internet Explorer Options"
      End
   End
   Begin VB.Menu mnuHelp 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelpContents 
         Caption         =   "&Contents"
         Shortcut        =   {F1}
      End
      Begin VB.Menu mnuW3RunnerWebSite 
         Caption         =   "Web Site"
      End
      Begin VB.Menu mnuWelcomePage 
         Caption         =   "Welcome Page"
         Shortcut        =   {F7}
      End
      Begin VB.Menu mnuAddShortcutToDesktop 
         Caption         =   "&Add shortcut to the DeskTop"
      End
      Begin VB.Menu mnuHelprien1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuAbout 
         Caption         =   "About"
      End
   End
   Begin VB.Menu mnuTestProc 
      Caption         =   "Test"
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Const sglSplitLimit = 2000

Private m_boolMoving                As Boolean

Private m_lngLvTraceHeightSize      As Long
Private m_lngLvTraceWidthSize       As Long

Private m_objWinApi                 As New cWindows
Private m_lngScriptPublicMethod     As Long
Private m_strAsyncURL               As String
Private m_CanQuit                   As Boolean
Private m_strSessionID              As String
Private m_lngImageRunnerIndex       As Long
Private m_lngClientToHostWindow_cx As Long
Private m_lngClientToHostWindow_cy As Long
Private m_strCommandLineFunctionToExecute As String
Private m_booShiftKeyDown           As Boolean
Private m_booCtrlKeyDown           As Boolean
Public m_objWebLoad                As New CWebLoad

Public ChildIndex                   As Long
Public PreviousDownLoadPage         As String
Public NickName                     As String
Public VBScriptEngine               As New CVBScript

Public HTMLDoc                      As HTMLDocument
'Public WithEvents HTMLWindow2       As MSHTML.HTMLWindow2

Private m_booShowReportBrowser          As Boolean


Public IsChild                      As Boolean
Public m_objW3RunnerPage           As New W3RunnerPage
Public m_objW3RunnerPageGUID       As String
Public ObjectToClick                As Object


Private m_SelectedTraceListView As ListView

Private Sub Form_Initialize()

    On Error GoTo errmgr
    m_CanQuit = True
    
    mnuTestProc.Visible = False
    mnuSaveCrypted.Visible = False
    
    ' Set to find the real pos os the browser
    TxtPosRef.Left = 0
    TxtPosRef.Top = 0
    
    ' Default values
    m_lngLvTraceHeightSize = 200 * Screen.TwipsPerPixelY
    m_lngLvTraceWidthSize = Me.Width / 2
    
    lvResize

    txtAddress.BackColor = Me.BackColor

    
   ' Me.ReportBrowser.Navigate "about:blank"
    
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Form_Initialize"
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)

    Select Case KeyCode
        Case vbKeyShift: m_booShiftKeyDown = True
        Case vbKeyControl: m_booCtrlKeyDown = True
    End Select
End Sub





Public Function LoadInfoAtStartTime() As Boolean

    On Error GoTo errmgr

    Dim strF                As String
    Dim strValue            As String
    Dim objTextFile         As New cTextFile
    
    Const MIN_FRM_SIZE = 400

    frmSplash.Message = W3RUNNER_MSG_07021
    
    mnuProtocolWindow.Visible = False
    g_objIniFile.FormSaveRestore frmMain, False, True
    
    If Me.Left < 0 Then Me.Left = 0
    If Me.Top < 0 Then Me.Top = 0
    
    If Me.Width < MIN_FRM_SIZE * Screen.TwipsPerPixelX Then Me.Width = MIN_FRM_SIZE * Screen.TwipsPerPixelX
    If Me.Height < MIN_FRM_SIZE * Screen.TwipsPerPixelX Then Me.Height = MIN_FRM_SIZE * Screen.TwipsPerPixelX

    m_lngImageRunnerIndex = 1
    
    LB_Read txtURL, GetW3RunnerComboBoxURLHistoryFileName()
    txtURL.Text = AppOptions("EditTime", , "URL")
    
    SetUIRunMode False
    strF = AppOptions("LastFile", , "Script")
    
    frmMain.WebBrowser.Navigate "about:blank"
    
    If (Len(strF)) Then
    
        If objTextFile.ExistFile(strF) Then
        
            OpenNewScript strF, False
        End If
    End If
    
    ' Read Object position and apply some basic controls
    m_lngLvTraceHeightSize = AppOptions("m_lngLvTraceHeightSize", m_lngLvTraceHeightSize, "RESIZE")
    m_lngLvTraceWidthSize = AppOptions("m_lngLvTraceWidthSize", m_lngLvTraceWidthSize, "RESIZE")
    CheckControlSizing
    
    InitFileToPreviousFilesList
    
    
    tmrURL.Interval = AppOptionsLong("advancedURLTime", DEFAULT_ADVANCED_URL_TIME)
    tmrPOSTURL.Interval = tmrURL.Interval
    'tmrWatchReadyState.Interval = AppOptionsLong("advancedWatchReadyStateTime", DEFAULT_ADVANCED_WATCH_READY_STATE_TIME)
    TimerObjectClick.Interval = AppOptionsLong("advancedClickTime", DEFAULT_ADVANCED_CLICK_TIME)
        
    frmSplash.Message = W3RUNNER_MSG_07020
        
    TraceSystemInfo
    
    LoadInfoAtStartTime = True

    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Form_Load"
End Function


Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)
    Select Case KeyCode
        Case vbKeyShift: m_booShiftKeyDown = False
        Case vbKeyControl: m_booCtrlKeyDown = False
    End Select
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

    On Error GoTo errmgr

    If (Not m_CanQuit) Then
    
        FShowError W3RUNNER_MSG_07002
        Cancel = True
    End If

    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Form_QueryUnload"
End Sub

Public Sub Form_Resize()

    On Error Resume Next

    If Me.WindowState = 1 Then Exit Sub
    
    If (IsChild) Then
    
        Me.WebBrowser.Left = 0
        ' we use the size of the tool bar of the main window because the current toolbar was not drawed
        ' at all and has a wrong size
        Me.WebBrowser.Top = IIf(Toolbar1.Visible, frmMain.Toolbar1.Height, 0)
            
        Me.WebBrowser.Width = Me.Width - (RESIZE_BORDER_WIDTH * Screen.TwipsPerPixelX) '+++
        Me.WebBrowser.Height = Me.Height - StatusBar1.Height - IIf(Toolbar1.Visible, Toolbar1.Height, 0) - (CAPTION_HEIGHT_PIXEL * Screen.TwipsPerPixelX)
        Me.lvTrace.Visible = False
    Else
    
        Me.lvTrace.Height = IIf(Me.lvTrace.Visible, m_lngLvTraceHeightSize, 0)
        Me.lvTrace.Width = IIf(Me.lvTrace.Visible, m_lngLvTraceWidthSize, 0)

        Me.WebBrowser.Left = 0
        Me.WebBrowser.Top = IIf(Toolbar1.Visible, Toolbar1.Height, 0)
        Me.WebBrowser.Width = Me.Width - (RESIZE_BORDER_WIDTH * Screen.TwipsPerPixelX)
        Me.WebBrowser.Height = Me.Height - Me.lvTrace.Height - (RESIZE_BORDER_HEIGHT * Screen.TwipsPerPixelX) - (GetCaptionMenuHeight(Me) * Screen.TwipsPerPixelX) - IIf(StatusBar1.Visible, StatusBar1.Height, 0) - IIf(Toolbar1.Visible, Toolbar1.Height, 0)
        
        Me.lvTrace.Left = 0
        Me.lvTrace.Top = Me.WebBrowser.Top + Me.WebBrowser.Height + (RESIZE_BORDER_HEIGHT * Screen.TwipsPerPixelX)
        
        imgSplitter.Left = Me.lvTrace.Width
        imgSplitter.Top = 0
        imgSplitter.Height = Me.Height
        imgSplitter.Width = (RESIZE_BORDER_HEIGHT * Screen.TwipsPerPixelX) * 2 ' We just multiply by 2 so when we resize the rubber bar has good size;
        
        Me.lvInternal.Top = Me.lvTrace.Top
        Me.lvInternal.Width = Me.Width - Me.lvTrace.Width - ((RESIZE_BORDER_HEIGHT * 3) * Screen.TwipsPerPixelX)
        Me.lvInternal.Height = Me.lvTrace.Height
        Me.lvInternal.Left = Me.lvTrace.Left + Me.lvTrace.Width + (RESIZE_BORDER_HEIGHT * Screen.TwipsPerPixelX)
        
        imgSplitterDown.Left = 0
        imgSplitterDown.Width = Me.Width
        imgSplitterDown.Top = Me.lvTrace.Top - (RESIZE_BORDER_HEIGHT * Screen.TwipsPerPixelX)
        imgSplitterDown.Height = Me.Height
        imgSplitterDown.Visible = True
        
        If ShowReportBrowser Then
            
            Me.WebBrowser.Width = lvTrace.Width
            Me.ReportBrowser.Width = Me.Width - Me.WebBrowser.Width - ((RESIZE_BORDER_WIDTH + 3) * Screen.TwipsPerPixelX)
            
            Me.ReportBrowser.Top = Me.WebBrowser.Top
            Me.ReportBrowser.Height = Me.WebBrowser.Height
            Me.ReportBrowser.Left = Me.WebBrowser.Left + Me.WebBrowser.Width + ((RESIZE_BORDER_HEIGHT + 1) * Screen.TwipsPerPixelX)
            
            Me.ReportBrowser.Visible = True
        End If
        lvResize
    End If
    ImageRunner.Top = (4 * Screen.TwipsPerPixelY)
    ImageRunner.Left = Me.Width - ImageRunner.Width - (10 * Screen.TwipsPerPixelX)
        
    Exit Sub
errmgr:
    'FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(),me, "Form_Resize"
End Sub

Private Sub Form_Unload(Cancel As Integer)

    On Error GoTo errmgr

    If (Not IsChild) Then
        FreeData
        CloseAllFormExceptFrmMainForm
    End If
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Form_Unload"
End Sub



Private Sub ImageRunner_Click()
    AnimationStart False
End Sub

Private Sub lvInternal_DblClick()

    On Error GoTo errmgr
  
    mnuTraceViewLine_Click
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "lvInternal_DblClick"
End Sub

Private Sub lvInternal_ItemClick(ByVal Item As MSComctlLib.ListItem)
    lvInternal.ToolTipText = lvInternal.SelectedItem.Text
End Sub

Private Sub lvInternal_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Set m_SelectedTraceListView = lvInternal
    If Button = 2 Then Me.PopupMenu mnuTrace
End Sub

Private Sub lvTrace_DblClick()

    On Error GoTo errmgr

    Dim strText         As String
    Dim lngPos          As Long
    Dim objTextFile     As New cTextFile
    
    
'    ' COPY URL
'    lngPos = InStr(lvTrace.SelectedItem.Text, "URL=")
'    If (lngPos) Then
'        strText = Mid(lvTrace.SelectedItem.Text, lngPos + 4)
'        strText = Mid(strText, 1, Len(strText) - 1)
'        strText = GetURLFileName(strText)
'    Else
'        strText = lvTrace.SelectedItem.Text
'    End If

    mnuTraceViewLine_Click
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "lvTrace_DblClick"
End Sub

Private Sub lvTrace_ItemClick(ByVal Item As MSComctlLib.ListItem)
    lvTrace.ToolTipText = lvTrace.SelectedItem.Text
End Sub

Private Sub lvTrace_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)

    Set m_SelectedTraceListView = lvTrace
    If Button = 2 Then Me.PopupMenu mnuTrace
End Sub





Private Sub mnuAbout_Click()

    On Error GoTo errmgr
    TraceSystemInfo
    frmSplash.OpenWindow
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "mnuAbout_Click"
End Sub

Private Sub mnuAddShortcutToDesktop_Click()
    AddShortcutToDesktop
End Sub

Private Sub mnuCancelScript_Click()

    On Error GoTo errmgr
    
    Me.WebBrowser.Stop
    CancelScript = True
    Set VBScriptEngine = Nothing
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "mnuCancelScript_Click"
End Sub


Private Sub mnuClearIECache_Click()
    
    Dim objIEApi        As New CIEApi
    
    Status W3RUNNER_MSG_07043
    g_objW3RunnerObject.ClearCache
    Status
End Sub

Private Sub mnuDebugClearTrace_Click()
    lvTrace.ListItems.Clear
    lvInternal.ListItems.Clear
End Sub





Private Sub mnuDebugCode_Click()
    
    Dim o As New CWindowObjectMapper
    With WebBrowser
    o.GetWebBrowserShellEmbeddingHWND Me, .Left \ Screen.TwipsPerPixelX, (.Top - Me.Toolbar1.Height) \ Screen.TwipsPerPixelY, .Width \ Screen.TwipsPerPixelX, .Height \ Screen.TwipsPerPixelX
    End With
End Sub

Private Sub mnuEdit_Click()
    
    On Error GoTo errmgr
    
    Dim objTool As New cTool
    Dim strParameters As String
    strParameters = """" & Me.ScriptFileName & """"
    
    objTool.execPrg AppOptions("editor", DEFAULT_EDITOR), strParameters, vbNormalFocus
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "mnuEdit_Click"
End Sub

Private Sub mnuInternetExplorerOptions_Click()
    Dim objIE As New CIEApi
    objIE.OptionsDialogs
End Sub

 
Private Sub mnuRecord_Click()
    Toolbar1_ButtonClick Toolbar1.Buttons("Record")
End Sub

Private Sub mnuSaveCrypted_Click()

    On Error GoTo errmgr

    
    Dim objPoissonSuceur    As New CPoissonSuceur
    
    
    If InStr(LCase(Me.ScriptFileName), ".vbs") Then
    
        objPoissonSuceur.CrypteFile Me.ScriptFileName, Replace(LCase(Me.ScriptFileName), ".vbs", "." & W3RUNNER_CRYPTED_SCRIPT_EXTENSION)
    Else
        FShowError W3RUNNER_MSG_07052
    End If
    
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "mnuSaveCrypted_Click"
End Sub

Private Sub mnuW3RunnerWebSite_Click()
    GotoW3RunnerWebSite
End Sub

Private Sub mnuMoveMouse_Click()

    AppOptions("MoveMouseCursor") = Abs(Not CBool(AppOptions("MoveMouseCursor", True)))
    
    TRACE PreProcess(W3RUNNER_MSG_07031, "NAME", "MoveMouseCursor", "VALUE", AppOptions("MoveMouseCursor")), w3rINFO
End Sub



Private Sub mnuTraceCopy_Click()
    
    On Error GoTo errmgr

    If IsValidObject(m_SelectedTraceListView) Then
    
        If IsValidObject(m_SelectedTraceListView.SelectedItem) Then
        
            ClipBoard.Clear
            ClipBoard.SetText CStr(m_SelectedTraceListView.SelectedItem.Text)
        End If
    End If
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "mnuTraceCopy_Click"
End Sub

Private Sub mnuTraceViewLine_Click()

    On Error GoTo errmgr

    If IsValidObject(m_SelectedTraceListView) Then
    
        If IsValidObject(m_SelectedTraceListView.SelectedItem) Then
        
            frmMsgbox.OpenDialog (CStr(m_SelectedTraceListView.SelectedItem.Text))
        End If
    End If
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "mnuTraceCopy_Click"
End Sub

Private Sub mnuViewReport_Click()
    If g_objW3RunnerReportBrowser.Visible Then
        g_objW3RunnerReportBrowser.Hide
    Else
        g_objW3RunnerReportBrowser.Show
    End If
End Sub

Private Sub mnuViewStandard_Click()
    Me.FullScreen = False
    g_objW3RunnerReportBrowser.Visible = False
    
End Sub

Private Sub mnuViewTrace_Click()
On Error GoTo errmgr
    Dim objTool As New cTool
    objTool.execPrg AppOptions("TraceFileViewer", DEFAULT_EDITOR), """" & GetW3RunnerLogFileName() & """", vbNormalFocus
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "mnuEditTrace_Click"
End Sub

Private Sub mnuHelpContents_Click()
    'WebBrowser.ExecWB OLECMDID_SELECTALL, OLECMDEXECOPT_DODEFAULT
    'WebBrowser.ExecWB OLECMDID_COPY, OLECMDEXECOPT_DODEFAULT
    
    
'    Dim eQuery  As SHDocVwCtl.OLECMDID
'
'
'
'    eQuery = WebBrowser.QueryStatusWB(OLECMDID_SAVEAS)
'    If eQuery And OLECMDF_ENABLED Then
'        WebBrowser.ExecWB OLECMDID_SAVEAS, OLECMDEXECOPT_DONTPROMPTUSER, "h:\temp\h.htm", "h:\temp\h.htm"
'    End If
     'WebBrowser.ExecWB OLECMDID_PROPERTIES, OLECMDEXECOPT_DODEFAULT
     'WebBrowser.ExecWB(, OLECMDEXECOPT_DODEFAULT
     'WebBrowser.QueryStatusWB (
     'Dim x As Long, y As Long
     'WebBrowser.ClientToWindow x, y
     'MsgBox x & " " & y
     
     'MsgBox Me.HTMLDoc.documentElement.outerHTML

    g_objW3RunnerHelp.HelpShow
End Sub



Private Sub mnuOpen_Click()

    On Error GoTo errmgr

    Dim objTool     As New cTool
    Dim strF        As String
    
    strF = objTool.getUserOpenFile(cm, "Script File Name", W3RUNNER_FILE_OPEN_FILTER, False, AppOptions("LastPath", , "Script"))
    If (Len(strF)) Then
        OpenNewScript strF, True
    End If
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "mnuOpen_Click"
End Sub

Public Function RunScriptFunction(strFunction As String) As Boolean

    On Error GoTo errmgr
    
    Dim strErrorMessage As String
    
    mode = W3RUNNER_MODE_RUN
    m_CanQuit = False
    Me.CancelScript = False
    g_static_lngExecutionErrorCounter = 0
    g_static_lngExecutionWarningCounter = 0
    SetUIRunMode True
        
    If (Not VBScriptEngine.Execute(strFunction, strErrorMessage, AppOptions("VBScriptEnginTimeOut", W3RUNNER_DEFAULT_VBSCRIPT_TIME_OUT))) Then
    
        If (Not Me.CancelScript) Then
        
            If (Len(strErrorMessage)) Then
            
                FShowError strErrorMessage
            End If
        End If
    Else
        RunScriptFunction = True
    End If

    Set VBScriptEngine = New CVBScript ' Free the script engine but allocate a new one because we need it in the design/record mode
    Set m_objW3RunnerPage = New W3RunnerPage ' Get a new one clean
    
TheExit:
    
    SetUIRunMode False
    m_CanQuit = True
    mode = W3RUNNER_MODE_DESIGN
    
    Exit Function
errmgr:
    GoTo TheExit
    
End Function

Private Sub mnuOptions_Click()
    frmoptions.OpenDialog
End Sub



Private Sub mnuPreviousFile_Click(Index As Integer)

    If Len(mnuPreviousFile(Index).Caption) Then
    
        OpenNewScript mnuPreviousFile(Index).Caption, True
    End If
End Sub

Public Sub mnuQuit_Click()

    On Error GoTo errmgr
    
    FreeData
    CloseAllFormExceptFrmMainForm
    Unload Me
    
    Exit Sub
errmgr:
        FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "mnuQuit_Click"
End Sub

Private Function FreeData() As Boolean
    
    Static booFreed As Boolean
    Dim i As Long
    
    If booFreed Then Exit Function
    booFreed = True
    
    WebBrowser.Navigate "about:blank"
    For i = 1 To 10
        DoEvents
        Sleep 1
    Next
    ReportBrowser.Navigate "about:blank"
    For i = 1 To 10
        DoEvents
        Sleep 1
    Next
        
    If (IsValidObject(m_objW3RunnerPage)) Then
        m_objW3RunnerPage.done
    End If
    
    g_objIniFile.FormSaveRestore Me, True, True
    
    Set VBScriptEngine = Nothing
    Set HTMLDoc = Nothing
    Set m_objW3RunnerPage = Nothing
    Set ObjectToClick = Nothing

    FreeGlobalObject
    
    FreeData = booFreed

End Function
 



Private Sub mnuSkipWaitForDowload_Click()
    DownLoadingURL = ""
End Sub

Private Sub mnuStart_Click()
    mnuTestMethod_Click 0
End Sub

Private Sub mnuTestMethod_Click(Index As Integer)

    On Error GoTo errmgr
    
    Dim i As Long
    
    Status ""
    
    If Not g_objTextFile.ExistFile(ScriptFileName) Then
        mnuOpen_Click
        If Not g_objTextFile.ExistFile(ScriptFileName) Then Exit Sub
    End If
    
    ' Reload the script in case of changes
    OpenNewScript ScriptFileName, False
    
    Status PreProcess(W3RUNNER_MSG_07000, "FUNCTION", mnuTestMethod(Index).Caption)
    
    RunScriptFunction mnuTestMethod(Index).Caption
    
    If (CancelScript) Then
        frmMain.TRACE W3RUNNER_ERROR_07001, w3rWARNING
    End If
TheExit:
    Status
    Exit Sub
errmgr:
    GoTo TheExit
End Sub

Public Sub mnuWatchWindow_Click()
    RefreshWatchWindow
End Sub

Private Sub mnuWelcomePage_Click()
    mnuViewStandard_Click
    InitWelcomePageURL
    LoadWelcomePage
End Sub



Private Sub mnuTestProc_Click()
    Dim i As Long
    
    Dim v As HTMLLinkElement
    
    For Each v In Me.HTMLDoc.links
        With v
            Debug.Print .tagName
        End With
    Next
    
    Dim s As HTMLStyleSheet
    
    For i = 0 To Me.HTMLDoc.styleSheets.Length - 1
        
        Debug.Print HTMLDoc.styleSheets.Item(i).href
    Next
    
    Dim vv As HTMLImg
    For Each vv In Me.HTMLDoc.images
        With vv
            Debug.Print .tagName & " " & .src
        End With
    Next
    
End Sub

Private Sub tmrAnimation_Timer()
    m_lngImageRunnerIndex = m_lngImageRunnerIndex + 1
    If (m_lngImageRunnerIndex > Me.ImageList2.ListImages.Count) Then m_lngImageRunnerIndex = 1
    Set Me.ImageRunner.Picture = Me.ImageList2.ListImages.Item(m_lngImageRunnerIndex).Picture
    
End Sub

Private Sub tmrPOSTURL_Timer()
On Error GoTo errmgr

    tmrPOSTURL.Enabled = False
    With g_objW3RunnerPostTempData
        WebBrowser.Navigate .URL, .Flags, .TargetFrame, .PostData, .Headers
    End With
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "tmrPOSTURL_Timer"
End Sub

Private Sub tmrURL_Timer()

    On Error GoTo errmgr

    tmrURL.Enabled = False
    WebBrowser.Navigate Me.AsyncURL
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "tmrURL_Timer"
End Sub




Public Sub Toolbar1_ButtonClick(ByVal Button As MSComctlLib.Button)

    Select Case UCase(Button.Key)
    
        Case "OPEN":            mnuOpen_Click
        Case "START":           mnuTestMethod_Click 0
        Case "STOP":            mnuCancelScript_Click
        Case "FUNCTIONS":       Me.PopupMenu mnuTest
        Case "OPTIONS":         mnuOptions_Click
        Case "WATCHWINDOW":     mnuWatchWindow_Click
        Case "GOURL":           txtURL_KeyPress 13
        Case "RECORD":          SwitchRecordMode
        Case "WELCOME":         mnuWelcomePage_Click
    End Select
End Sub


Private Sub txtURL_Change()
    AppOptions("EditTime", , "URL") = txtURL.Text
End Sub

Private Sub txtURL_Click()
    txtURL_KeyPress 13
End Sub

Private Sub txtURL_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        If Me.RecordMode Then
        
            #If RECORD_MODE_ Then
                frmViewHTMLObject.AddGeneratedText W3RUNNER_VBSCRIPT_GENERATED_INDENT_STRING & "Page.URL = """ & txtURL.Text & """"
            #End If
        End If
        LB_AddIfNotExist txtURL, txtURL.Text
        LB_Save txtURL, GetW3RunnerComboBoxURLHistoryFileName()
        Me.AsyncURL = txtURL.Text
        
        'Me.WebBrowser.Navigate2 txtURL.Text
    End If
End Sub

'
' Detect order the browser page to fred runner
'
Private Sub WebBrowser_BeforeNavigate2(ByVal pDisp As Object, URL As Variant, Flags As Variant, TargetFrameName As Variant, PostData As Variant, Headers As Variant, Cancel As Boolean)
    
    On Error GoTo errmgr
    
    'If g_static_booShowProtocolInfo Then
   '
   '     frmProtocol.AddHTTP m_objWebLoad.Record(WEBLOAD_MODE_GET_VBSCRIPT, URL, flags, TargetFrameName, PostData, Headers)
   ' End If
   
'
   
    ' When the user click on a Welcome Page ComboBox Blank entry - to avoid bad message
    If Right(URL, Len(WELCOME_PAGE_END_OF_BLANK_URL)) = WELCOME_PAGE_END_OF_BLANK_URL Then
        Cancel = True
        Exit Sub
    End If
   
    If mode = W3RUNNER_MODE_RUN Then
        
        If g_static_booRecordHTTPProtocol Then
        
            m_objWebLoad.Record WEBLOAD_MODE_RECORD, URL, Flags, TargetFrameName, PostData, Headers
        End If
    End If
    
    ' HTTP Trace but not in record mode I have some problem if
    If (IsTraceHTTPOn()) And (Not Me.RecordMode) Then
    
        m_objWebLoad.Record WEBLOAD_MODE_GET_TRACE, URL, Flags, TargetFrameName, PostData, Headers
    End If
    
    
    ' IP Processing
    If InStr(LCase(URL), W3RUNNER_HTTP_IP) Then
    
        AsyncURL = Replace(URL, W3RUNNER_HTTP_IP, "http://" & g_objW3RunnerWebServer.IP & "/")
        Cancel = True
    End If
    
    ' W3Runnerserver:// protocol
    If InStr(LCase(URL), W3RUNNER_HTTP_PROTOCOL) Then
    
        ' Reset the counter so the user can run all the demo
        g_static_lngDemoItemCount = 0
        DownLoadAndExecuteScript CStr(URL)
        Cancel = True
    End If
    Exit Sub
errmgr:
    Debug.Assert 0
End Sub


Public Sub WebBrowser_DocumentComplete(ByVal pDisp As Object, URL As Variant)

    On Error GoTo errmgr
         
    If Len(URL > 0) And (URL <> "http:///") Then
       Dim queueItem As New cQueueItem
       Set queueItem.HTMLDoc = WebBrowser.Document
       queueItem.URL = URL
       q.Enqueue queueItem
         
       If IsChild Then
         Form_Resize
       End If
       
       If Me.RecordMode Then
         Dim strText As String
         strText = GetURLFileName(URL)
         #If RECORD_MODE_ Then
           frmViewHTMLObject.AddGeneratedText W3RUNNER_VBSCRIPT_GENERATED_INDENT_STRING & "Page.WaitForDownLoad """ & strText & """"
         #End If
         mnuWatchWindow_Click
       End If
    End If
    
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "WebBrowser_DocumentComplete"
End Sub



Public Function WaitForDownLoad(Optional strURL As String) As Boolean

    On Error GoTo errmgr
    Dim lngTimeOut                              As Long
    Dim lngAdvancedWaitForDownLoadSleepTime     As Long
        
    Screen.MousePointer = vbArrowHourglass
    Me.MousePointer = vbArrowHourglass
    lngTimeOut = GetTickCount()
    
    lngAdvancedWaitForDownLoadSleepTime = AppOptions("advancedWaitForDownLoadSleepTime", DEFAULT_ADVANCED_WAITFORDOWNLOAD_SLEEP_TIME)
    
    TRACE "Page.WaitForDownLoad """ & strURL & """", w3rMETHOD
    TRACE "WaitForDownLoad().Start=" & GetTickCount(), w3rINTERNAL
    TRACE "WaitForDownLoad().TimeOut=" & Me.DownLoadTimeOut, w3rINTERNAL
    
    If (Len(strURL)) Then DownLoadingURL = strURL
  
    Do While Not Me.CancelScript And Not IsTimeOut(lngTimeOut)
        GlobalDoEvents
        Sleep lngAdvancedWaitForDownLoadSleepTime

        If q.Count > 0 Then
        
          Dim strDownloaded As String
          Dim queueItem As cQueueItem
          Set queueItem = q.Dequeue
          strDownloaded = queueItem.URL
          Set HTMLDoc = queueItem.HTMLDoc
          
          TRACE "QUEUE: " & q.Count & " peek: " & strDownloaded, w3rINFO
           
          If (Len(strDownloaded) > 0) And (Len(DownLoadingURL) > 0) And (InStr(UCase(strDownloaded), UCase(DownLoadingURL))) Then

            TRACE "Downloaded [" & strDownloaded & "] " & " Requested [" & DownLoadingURL & "]", w3rINFO
            
            If UCase(DownLoadingURL) = ".ASP" Then
              TRACE "Waiting for '.asp' is not safe!  Waiting for pages to queue up...", w3rWARNING
              q.Clear
              Wait 2
              Do While q.Count > 0
                TRACE "Getting last page in queue...", w3rINFO
                Set queueItem = q.Dequeue
                strDownloaded = queueItem.URL
                Set HTMLDoc = queueItem.HTMLDoc
                Wait 1
              Loop
            End If
            
            If Me.WebBrowser.Busy And Me.WebBrowser.ReadyState <> READYSTATE_COMPLETE And Not Me.CancelScript And Not IsTimeOut(lngTimeOut) Then
              TRACE "Finishing download for: " & strDownloaded, w3rINFO
              Wait 5
            End If
            
            g_static_strLastDownLoadedURL = strDownloaded
            
            Exit Do
          End If
        End If
    Loop
    
    If ((IsTimeOut(lngTimeOut))) Then
        TRACE PreProcess(W3RUNNER_ERROR_07045, "URL", m_objW3RunnerPage.URL), w3rERROR
        Me.CancelScript = CancelScriptIfTimeOut
    Else
        If Me.CancelScript Then ' If we cancel the script we return that the page has time out, that is better of the script writing... If Page.WaitForDownLoad("*.asp") Then
            WaitForDownLoad = False
        Else
            TRACE "Download Complete for " & strURL, w3rINFO
            WaitForDownLoad = True
        End If
    End If

    If (HTMLObjectWindowOpened) Then RefreshWatchWindow
    
TheExit:
    DoEvents
    Sleep 1
    AnimationStart False
    PreviousDownLoadPage = ""
    Screen.MousePointer = ssDefault
    Me.MousePointer = ssDefault
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "WaitForDownLoad"
End Function

Public Function GetProperty(obj As Object, strProperty As String) As Variant
    On Error Resume Next
    GetProperty = CallByName(obj, strProperty, VbGet)
    Err.Clear
End Function

Public Function GetHTMLObject(strID As String, strType As String, strProperty As String, Optional booContains As Boolean = False, Optional strFrameName As String, Optional booFShowError As Boolean = True, Optional lngIndex As Long = 1, Optional varValue As Variant) As Object

    On Error GoTo errmgr

    Dim eCollection         As IHTMLElementCollection
    Dim i                   As Long
    Dim a                   As Object
    Dim strPropertyValue    As String
    Dim booFound            As Boolean
    Dim lngIndexCounter     As Long
    
    If (Len(strFrameName)) Then
    
        On Error Resume Next
        Set eCollection = GetFrame(HTMLDoc, strFrameName).Document.All
        If Err.Number Then
            frmMain.TRACE PreProcess(W3RUNNER_WARNING_3000, "NAME", strFrameName, "DETAILS", GetVBErrorString()), w3rWARNING
            Exit Function
        End If
        On Error GoTo errmgr
    Else
        Set eCollection = HTMLDoc.All
    End If
        
    For i = 0 To eCollection.Length - 1
    
        'strName = GetHTMLObjectProperty(eCollection.Item(i), "name")
        'Debug.Print i & " " & strName
        
        If (UCase(TypeName(eCollection.Item(i))) = UCase(strType)) Or (strType = "*") Then
        
            Set a = eCollection.Item(i)
            
            If (UCase$(strProperty) = "NAME") Then
                strPropertyValue = g_objHelper.GetHTMLObjectName(a)
            Else
                strPropertyValue = g_objHelper.GetHTMLObjectProperty(a, strProperty)
            End If
            
            If (booContains) Then
                booFound = InStr(Trim(UCase(strPropertyValue)), UCase(strID))
            Else
                booFound = (Trim(UCase(strPropertyValue)) = Trim(UCase(strID)))
            End If
            
            If (booFound) Then
            
                If (Not IsMissing(varValue)) Then ' The object to found is a radio button so we have to mach the name and the value
                
                    If UCase$(varValue) = UCase$(a.Value) Then
                    
                        Set GetHTMLObject = a
                        Exit Function
                    Else
                        booFound = False
                    End If
                Else
            
                    lngIndexCounter = lngIndexCounter + 1
                    If (lngIndexCounter = lngIndex) Then ' Support object with index.
                    
                        Set GetHTMLObject = a
                        Exit Function
                    End If
                End If
            End If
        End If
    Next
    If (booFShowError) And (Not Me.CancelScript) Then

        GoTo errmgr
    End If
    Exit Function
errmgr:
    Err.Clear
    'If Not Me.CancelScript Then
    '    FShowError PreProcess(W3RUNNER_ERROR_07000, "NAME", strID, "TYPE", strType, "VALUE", IIf(IsMissing(varValue), "Missing", varValue), "INDEX", lngIndex, "FRAME", strFrameName)
    'End If
End Function



Public Property Get ScriptFileName() As String

    On Error GoTo errmgr

    ScriptFileName = g_static_ScriptFileName
    Exit Property
errmgr:
        FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "ScriptFileName"
End Property

Public Property Let ScriptFileName(ByVal vNewValue As String)

    On Error GoTo errmgr


    Dim objTextFile As New cTextFile
    
    g_static_ScriptFileName = vNewValue
    DisplayCaption
    mnuTest.Enabled = Len(g_static_ScriptFileName)
    InitVBScriptEngine
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "ScriptFileName"
End Property


Public Function LoadScriptFilePublicMethod() As Boolean

    Dim objTextFile As New cTextFile
    Dim strS        As String
    Dim objParser   As New CByteSyntaxAnalyser
    Dim strTok      As String
    Dim objPublicMethods As Collection
    Dim objPublicMethod  As Variant
    
    On Error GoTo errmgr
    
    Do While m_lngScriptPublicMethod
    
        If (m_lngScriptPublicMethod > 0) Then
            On Error Resume Next
            Unload mnuTestMethod(m_lngScriptPublicMethod)
            On Error GoTo errmgr
        End If
        m_lngScriptPublicMethod = m_lngScriptPublicMethod - 1
    Loop
    
    m_lngScriptPublicMethod = 0
    
    If (VBScriptEngine.LoadPublicMethods(objPublicMethods)) Then
    
        For Each objPublicMethod In objPublicMethods
        
            If (UCase(objPublicMethod) <> W3RUNNER_EVENT_W3RUNNER_ONTRACE) And (UCase(objPublicMethod) <> W3RUNNER_EVENT_W3RUNNER_ONERROR) Then
            
                If (m_lngScriptPublicMethod > 0) Then Load Me.mnuTestMethod(m_lngScriptPublicMethod)
                mnuTestMethod(m_lngScriptPublicMethod).Visible = True
                mnuTestMethod(m_lngScriptPublicMethod).Caption = objPublicMethod
                m_lngScriptPublicMethod = m_lngScriptPublicMethod + 1
            End If
        Next
    End If
    mnuStart.Caption = PreProcess(W3RUNNER_MSG_07004, "FUNCTION", mnuTestMethod(0).Caption)
    LoadScriptFilePublicMethod = True
    Exit Function
errmgr:
    
End Function

Public Function Status(Optional strMessage As String, Optional lngIndex As Long = 1)

    On Error GoTo errmgr

    Me.StatusBar1.Panels(lngIndex).Text = strMessage
    Me.StatusBar1.Refresh
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Status"
End Function

Public Property Get AsyncURL() As String

    On Error GoTo errmgr

    AsyncURL = m_strAsyncURL

    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "AsyncURL"
End Property

Public Property Let AsyncURL(ByVal vNewValue As String)

    On Error GoTo errmgr
    
    GlobalDoEvents
    m_strAsyncURL = vNewValue
    
    TRACE "Clearing queue... before getting: " & m_strAsyncURL, w3rINFO
    q.Clear
    
    Me.tmrURL.Enabled = True
    g_lngDownLoadResponseTimeDelay = Me.tmrURL.Interval
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "AsyncURL"
End Property




Private Function DisplayCaption() As Boolean

    On Error GoTo errmgr

    Dim objTextFile As New cTextFile
    Caption = objTextFile.GetFileName(ScriptFileName) & " - " & APP_TITLE & " [" & mode & "] "
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "DisplayCaption"
End Function

Public Function ExecutionTestFunction(strFunctionName As String) As Boolean

    Dim i As Long
    
    On Error GoTo errmgr
    
    strFunctionName = UCase(strFunctionName)
    
    For i = 0 To mnuTestMethod.Count - 1
    
        If (UCase(mnuTestMethod(i).Caption) = strFunctionName) Then
        
            mnuTestMethod_Click CInt(i)
            ExecutionTestFunction = True
            Exit Function
        End If
    Next
    Me.TRACE PreProcess(W3RUNNER_ERROR_07038, "FUNCTION", strFunctionName), w3rERROR
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "ExecutionTestFunction"
End Function

Private Function IsTimeOut(lngTimeMark As Long) As Boolean
    IsTimeOut = Not (lngTimeMark + (DownLoadTimeOut * 1000) > GetTickCount())
End Function

Public Function InitVBScriptEngine() As Boolean

    On Error GoTo errmgr
    
    Dim strDefaultCode As String

    Set VBScriptEngine = New CVBScript
    Set m_objW3RunnerPage = New W3RunnerPage
    
    m_objW3RunnerPage.Initialize Me, True
    
    VBScriptEngine.FileName = Me.ScriptFileName
    VBScriptEngine.BootStrapFileName = App.path & "\W3Runner.vbs"
    VBScriptEngine.OnErrorEvent = "W3Runner_OnError"
    
    VBScriptEngine.VBSEngine.AddObject "UI", m_objW3RunnerPage ' For compatibility reason with the past
    VBScriptEngine.VBSEngine.AddObject "Page", m_objW3RunnerPage
    
    'VBScriptEngine.VBSEngine.AddObject "Screen", Screen
    
    VBScriptEngine.VBSEngine.AddObject "Windows", g_objW3RunnerObject
    VBScriptEngine.VBSEngine.AddObject "W3Runner", g_objW3RunnerObject
    
    VBScriptEngine.VBSEngine.AddObject "HTTP", g_objHTTP

    VBScriptEngine.VBSEngine.AddObject "Report", g_objW3RunnerReportBrowser
    If g_objW3RunnerReportBrowser.Visible Then
        g_objW3RunnerReportBrowser.Visible = False
    End If
    
    m_objW3RunnerPage.SlowMode = AppOptions("SlowMode", 0)
    
    strDefaultCode = "PUBLIC CONST W3RUNNER_RUNNING = TRUE" & vbNewLine
    
    #If MTDATABASE Then ' ## HERE
        strDefaultCode = strDefaultCode & PreProcess("[CRLF]Private Function GetFredRunnerLibraryPath()[CRLF]GetFredRunnerLibraryPath = Page.Environ(""MetratechTestDatabase"") & ""\Development\ui\Application Tests\FredRunner.Library""[CRLF]End Function[CRLF]", "CRLF", vbNewLine)
        strDefaultCode = strDefaultCode & PreProcess("[CRLF]Private Function GetMetratechTestDatabase()[CRLF]GetMetratechTestDatabase = Page.Environ(""MetratechTestDatabase"")[CRLF]End Function[CRLF]", "CRLF", vbNewLine)
    #End If
    
    If (Not VBScriptEngine.AddCode(strDefaultCode)) Then Exit Function
    If (Not VBScriptEngine.AddMainCode) Then Exit Function
    
    If (Not LoadScriptFilePublicMethod) Then Exit Function
    InitVBScriptEngine = True
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "InitVBScriptEngine"
End Function


Private Sub WebBrowser_DownloadBegin()
    AnimationStart True
End Sub


Private Sub WebBrowser_DownloadComplete()
    AnimationStart False
    DoEvents
End Sub


Private Sub WebBrowser_StatusTextChange(ByVal Text As String)
    Status "Browser Status:" & Text, 2
End Sub


Private Sub WebBrowser_NewWindow2(ppDisp As Object, Cancel As Boolean)

   Dim objMDMChildTestDialog    As W3RunnerPage
   Dim frmWB                    As frmMain
   
   On Error GoTo errmgr
   
   Set frmWB = New frmMain ' Create a new child form
   
   frmWB.mnuFile.Visible = False
   frmWB.mnuView.Visible = False
   frmWB.mnuTool.Visible = False
   frmWB.mnuTest.Visible = False
   frmWB.mnuRun.Visible = False
   frmWB.mnuHelp.Visible = False
   frmWB.mnuDebug.Visible = False
      
   frmWB.txtURL.Visible = False
   frmWB.txtAddress.Visible = False
   frmWB.lvInternal.Visible = False
   frmWB.lvTrace.Visible = False
      
   frmWB.Toolbar1.Visible = True
   tbEnableAll frmWB.Toolbar1, False
   
   frmWB.Toolbar1.Buttons("WatchWindow").Enabled = True
      
   frmWB.NickName = "Child " & Now()
   frmWB.IsChild = True
   frmWB.WebBrowser.RegisterAsBrowser = True
   
   ' Default position and size
   frmWB.Left = 0 + (frmMain.m_objW3RunnerPage.Windows.Count * 300 * Screen.TwipsPerPixelX)
   frmWB.Top = 0 + (frmMain.m_objW3RunnerPage.Windows.Count * 300 * Screen.TwipsPerPixelY)
   frmWB.Width = 640 * Screen.TwipsPerPixelX
   frmWB.Height = 480 * Screen.TwipsPerPixelX
      
   ' The child is attached to the main window frmMAin
   Set objMDMChildTestDialog = frmMain.m_objW3RunnerPage.Windows.Add(frmMain.m_objW3RunnerPage)  ' Add to main form a W3RunnerPage Childs.
   frmWB.m_objW3RunnerPageGUID = objMDMChildTestDialog.GUID
   frmWB.ChildIndex = frmMain.m_objW3RunnerPage.Windows.Count
   
   objMDMChildTestDialog.Initialize frmWB, False ' Init the MDM Test dialog child with the new window and not as the primary dialog
   
   Set frmWB.m_objW3RunnerPage = objMDMChildTestDialog ' Give a pointer to objMDMChildTestDialog to the form
   Set ppDisp = frmWB.WebBrowser.Object ' return the pointer the web browser
   
   RaiseVBScriptEvent "WebBrowser_NewWindow2"
   
   frmWB.Show
   frmWB.RefreshWatchWindow frmWB.ChildIndex - 1
      
Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "WebBrowser_NewWindow2"
End Sub

'Public Function RefreshWatchWindowIsNeeded()
'    DoEvents
'    Sleep 1
'
'    If Me.IsChild And Me.RecordMode Then  ' Ask to update
'
'        tmrWatchWindow.Enabled = True
'   End If
'End Function
   


Public Function SetUIRunMode(booRunMode As Boolean) As Boolean
    
    On Error GoTo errmgr
    
    Me.StatusBar1.Panels(1).Picture = Me.ImageListLvTrace2.ListImages(IIf(booRunMode, "Method", "Null")).Picture
    Me.StatusBar1.Panels(2).Picture = Me.ImageListLvTrace2.ListImages(IIf(booRunMode, "Info", "Null")).Picture

    If Not booRunMode Then Me.StatusBar1.Panels(2).Text = ""
        
    'mnuRun.Enabled = Not booRunMode
    mnuStart.Enabled = Not booRunMode
    mnuWelcomePage.Enabled = Not booRunMode
    mnuTest.Enabled = Not booRunMode
    Me.mnuFile.Enabled = Not booRunMode
    mnuCancelScript.Enabled = booRunMode

    
    Toolbar1.Buttons("Start").Enabled = Not booRunMode
    Toolbar1.Buttons("Stop").Enabled = booRunMode
    Toolbar1.Buttons("Open").Enabled = Not booRunMode
    

    Toolbar1.Buttons("GoUrl").Enabled = Not booRunMode
    Toolbar1.Buttons("Record").Enabled = Not booRunMode
    Me.mnuRecord.Enabled = Not booRunMode
    txtURL.Enabled = Not booRunMode
    
    If Not booRunMode Then
        On Error Resume Next
        lvTrace.SetFocus
    End If
    
    #If Not RECORD_MODE_ Then
        Toolbar1.Buttons("Record").Enabled = False
        Toolbar1.Buttons("WatchWindow").Enabled = False
        Me.mnuRecord.Enabled = False
    #End If
    
    SetUIRunMode = True
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "SetUIRunMode"
End Function



Public Property Get HTMLObjectWindowOpened() As Long
    HTMLObjectWindowOpened = g_static_HTMLObjectWindowOpened
End Property

Public Property Let HTMLObjectWindowOpened(ByVal vNewValue As Long)
    g_static_HTMLObjectWindowOpened = vNewValue
End Property

Public Function RefreshWatchWindow(Optional lngChildIndex As Long = -1) As Boolean

    If Me.UpdateWatchWindow Then
    
        ' We do this for the first window open at record time...
        ' we do not want to generate the .window mode because it is not on yet
        If lngChildIndex = -1 Then lngChildIndex = ChildIndex
        
        #If RECORD_MODE_ Then
            frmViewHTMLObject.OpenDialog Me, lngChildIndex, Me.HTMLDoc, True
        #End If
    End If
    RefreshWatchWindow = True
End Function

Public Property Get mode() As String
    mode = g_static_strMode
End Property

Public Property Let mode(ByVal vNewValue As String)
    g_static_strMode = vNewValue
    DisplayCaption
End Property

Public Property Let RecordMode(ByVal vNewValue As Boolean)

    On Error GoTo errmgr
    
    g_static_lngRecordMode = vNewValue
    If (Me.RecordMode) Then
        Me.mode = W3RUNNER_MODE_RECORDING
    Else
        Me.mode = W3RUNNER_MODE_DESIGN
    End If
    DisplayCaption
    
    Toolbar1.Buttons("Start").Enabled = Not RecordMode
    Toolbar1.Buttons("Open").Enabled = Not RecordMode
    Toolbar1.Buttons("Options").Enabled = Not RecordMode

    Toolbar1.Buttons("Record").Image = IIf(Me.RecordMode, "StopRecord", "Record")
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "RecordMode"
End Property

Public Property Get RecordMode() As Boolean
    RecordMode = g_static_lngRecordMode
End Property


Public Function SwitchRecordMode() As Boolean

#If RECORD_MODE_ Then

    Dim objTool     As New cTool
    Dim objVBScript As New CVBScript
    
    Me.RecordMode = Not Me.RecordMode
    
    If (Me.RecordMode) Then
    
        If frmRecordFileName.OpenDialog() Then
        
            frmMain.m_objW3RunnerPage.Windows.Clear
            frmQuickMessage.OpenDialog W3RUNNER_MSG_07040, "07040"
        
            mnuWatchWindow_Click
            Set g_objIEEventFilter = New CIEEventFilter ' Start the filtering
            
            #If RECORD_MODE_ Then
                frmViewHTMLObject.PopulateGeneratedTextFileRecordFileName
            #End If
            
        Else
            Me.RecordMode = False
        End If
    Else
        Set g_objIEEventFilter = Nothing ' Stop the filtering
        #If RECORD_MODE_ Then
        frmViewHTMLObject.Hide
        Unload frmViewHTMLObject
        #End If
        WebBrowser.Stop
        
        If Len(RecordFileName) Then

            objVBScript.CommentWaitForDownLoad RecordFileName
            objTool.execPrg AppOptions("editor", DEFAULT_EDITOR), """" & RecordFileName & """", vbNormalFocus
        End If
    End If
#End If
End Function



Private Sub imgSplitterDown_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    With imgSplitterDown
    
        picSplitter.Move .Left, .Top, .Width, (5 * Screen.TwipsPerPixelY)
    End With
    picSplitter.Visible = True
    m_boolMoving = True
    Exit Sub
errmgr:
End Sub

Private Sub imgSplitterDown_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    Dim sglPos As Single
    
    If m_boolMoving Then
        
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

    Dim lngSplitterPos  As Long
    
    lngSplitterPos = imgSplitterDown.Top + (Y)
    
    If lngSplitterPos < sglSplitLimit Then lngSplitterPos = sglSplitLimit
    
    m_lngLvTraceHeightSize = (Me.Height - (GetCaptionMenuHeight(Me) * Screen.TwipsPerPixelY) - IIf(Toolbar1.Visible, Toolbar1.Height, 0)) - lngSplitterPos
    
    AppOptions("m_lngLvTraceHeightSize", , "RESIZE") = m_lngLvTraceHeightSize
    
    picSplitter.Visible = False
    m_boolMoving = False
    
    Form_Resize
    Exit Sub
errmgr:
End Sub

Public Function lvResize() As Boolean

    If lvTrace.ColumnHeaders.Count = 0 Then
    
        lvAddColumn lvTrace, "Trace"
        lvAddColumn lvInternal, "Script"
        lvResize
    End If

    If (lvTrace.ColumnHeaders.Count) Then
        lvTrace.ColumnHeaders.Item(1).Width = (lvTrace.Width) - (23 * Screen.TwipsPerPixelX)
    End If
    If (lvInternal.ColumnHeaders.Count) Then
        lvInternal.ColumnHeaders.Item(1).Width = (lvInternal.Width) - (23 * Screen.TwipsPerPixelX)
    End If
End Function


Public Function InitFileToPreviousFilesList(Optional ByVal strNewFileName As String) As Boolean

    On Error GoTo errmgr
    
    Dim i As Long
    
    For i = 1 To MAX_PREVIOUS_FILE
    
        Me.mnuPreviousFile(i).Caption = AppOptions("Files(" & i & ")", , "PreviousFiles")
        
    Next
    
    If (Len(strNewFileName)) Then
    
        If (Not IsFilePreviousFilesList(strNewFileName)) Then
            
            ' Decale
            For i = MAX_PREVIOUS_FILE To 2 Step -1
            
                Me.mnuPreviousFile(i).Caption = Me.mnuPreviousFile(i - 1).Caption
            Next
            
            ' Set the new file item 1
            Me.mnuPreviousFile(1).Caption = strNewFileName
            
            ' Save in the ini file
            For i = 1 To MAX_PREVIOUS_FILE
            
                AppOptions("Files(" & i & ")", , "PreviousFiles") = Me.mnuPreviousFile(i).Caption
            Next
            InitFileToPreviousFilesList ' Force to refresh
        End If
    End If
    
    On Error Resume Next
    For i = 1 To MAX_PREVIOUS_FILE
        Me.mnuPreviousFile(i).Visible = CBool(Len(Me.mnuPreviousFile(i).Caption))
    Next
    On Error GoTo errmgr
    
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "InitFileToPreviousFilesList"
End Function

Public Function IsFilePreviousFilesList(strNewFileName As String) As Boolean

    On Error GoTo errmgr

    Dim i As Long
    
    For i = 1 To MAX_PREVIOUS_FILE
    
        If (UCase$(Me.mnuPreviousFile(i).Caption) = UCase$(strNewFileName)) Then
        
            IsFilePreviousFilesList = True
            Exit Function
        End If
    Next
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "IsFilePreviousFilesList"
End Function


Public Function OpenNewScript(strFileName As String, booSetIniFile As Boolean) As Boolean
       
    Dim objTextFile As New cTextFile
    
    On Error GoTo errmgr
    
    If (booSetIniFile) Then
    
        AppOptions("LastPath", , "Script") = objTextFile.GetPathFromFileName(strFileName)
        AppOptions("LastFile", , "Script") = strFileName
        InitFileToPreviousFilesList strFileName
    End If
    ScriptFileName = strFileName
    OpenNewScript = True
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "OpenNewScript"
End Function

Public Property Get CancelScriptIfTimeOut() As Boolean
    CancelScriptIfTimeOut = g_static_booCancelScriptIfTimeOut
End Property

Public Property Let CancelScriptIfTimeOut(ByVal vNewValue As Boolean)
    g_static_booCancelScriptIfTimeOut = vNewValue
End Property

Public Property Get DownLoadingURL() As String
    DownLoadingURL = g_static_strDownLoadingURL
End Property

Public Property Let DownLoadingURL(ByVal vNewValue As String)
    g_static_strDownLoadingURL = vNewValue
End Property

Public Function TRACE(ByVal strMessage As String, eMode As eW3RunnerTraceMode, Optional booShowAutoCloseWindow As Boolean = True) As Boolean

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
    
    If eMode And w3rCLEAR_TRACE Then
        mnuDebugClearTrace_Click
        Exit Function
    ElseIf (Len(Trim(strMessage)) = 0) Then ' Why do we would like to log an empty message
        Exit Function
    ElseIf Not CBool(AppOptions("TraceType" & eMode, False)) Then ' Check if we have to log this message
        Exit Function
    ElseIf (IsChild) Then ' Trace with the parent only
        frmMain.TRACE strMessage, eMode
        Exit Function
    End If
    
    Set lv = lvTrace
    strTraceMode = "[" & GetW3RunnerTraceString(eMode) & "]"
    
    lngColor = vbBlack
        
    Select Case eMode
        Case w3rTRACEHTTP
            strIcon = "HTTP"
        Case w3rWEBSERVICE
            strIcon = "WebService"
        Case w3rINFO
            strIcon = "Info"
        Case w3rERROR
            strIcon = "Error"
            If CBool(AppOptions("TraceShowMessageBoxOnError", False)) And booShowAutoCloseWindow Then frmMsgbox.OpenDialog strMessage, "Trace Error"
            g_static_lngExecutionErrorCounter = g_static_lngExecutionErrorCounter + 1
        Case w3rWARNING
            strIcon = "Warning"
            g_static_lngExecutionWarningCounter = g_static_lngExecutionWarningCounter + 1
        Case w3rSQL
            strIcon = "Sql"
        Case w3rURL_DOWNLOADED
            strIcon = "UrlDownLoaded"
        Case w3rMEMORY
            strIcon = "Memory"
        Case w3rDEBUG
            strIcon = "Debug"
            Set lv = lvInternal
        Case w3rINTERNAL
            strIcon = "Internal"
            Set lv = lvInternal
        Case w3rMETHOD
            strIcon = "Method"
            Set lv = lvInternal
        Case w3rJAVASCRIPT
            strIcon = "JavaScript"
            Set lv = lvInternal
        Case w3rSUCCESS
            strIcon = "Succeed2"
        Case w3rPERFORMANCE
            strIcon = "Performance"
        Case w3rCLEAR_TRACE
            lvTrace.ListItems.Clear
            lvInternal.ListItems.Clear
            Exit Function
        Case Else
            strIcon = "Info"
    End Select

    strOnTraceMessage = Trim(strTraceMode) & Trim(strMessage)
    
    Set LVITEM = lvAddRow(lv, Time() & " " & strMessage, , , strIcon)
    LVITEM.ForeColor = lngColor
    LVITEM.Selected = True
    LVITEM.EnsureVisible
    lv.Refresh
    
    If eMode <> w3rPERFORMANCE Then
    
        'strMessage = Replace(strMessage, """", Chr(1))
        'strMessage = Replace(strMessage, Chr(1), """""")
        strMessage = Replace(strMessage, ",", Chr(1))
        strMessage = Replace(strMessage, Chr(1), ";")
    End If
    objTextFile.LogFile GetW3RunnerLogFileName(), Now() & "," & strTraceMode & "," & strMessage
    
    If AppOptions("ClearTraceWhenFull", False) Then
    
        If lvTrace.ListItems.Count > AppOptions("TraceListViewMaxSize", 1024) Then lvTrace.ListItems.Clear
        If lvInternal.ListItems.Count > AppOptions("TraceListViewMaxSize", 1024) Then lvInternal.ListItems.Clear
    End If
    
    ' Call the event
    If Len(W3RunnerMod.TraceEvent) Then
        frmMain.VBScriptEngine.ExecuteEvent W3RunnerMod.TraceEvent, eMode, strOnTraceMessage
    End If
        
    GlobalDoEvents
    Exit Function
errmgr:

    Debug.Assert 0
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "TRACE"
End Function

Public Property Get SlowMode() As Long
    SlowMode = g_static_lngSlowMode
End Property

Public Property Let SlowMode(ByVal vNewValue As Long)
    g_static_lngSlowMode = vNewValue
End Property

Public Property Get WebBrowserHWND(Optional ByVal strWindowsObjectClassName As String = CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_INTERNET_EXPORER_SERVER) As Long
    Dim om As New CWindowObjectMapper
    With Me.WebBrowser
        WebBrowserHWND = om.GetWebBrowserHwndFromWebBrowseControl(Me, .Left \ Screen.TwipsPerPixelX, (.Top - Me.Toolbar1.Height) \ Screen.TwipsPerPixelY, .Width \ Screen.TwipsPerPixelX, .Height \ Screen.TwipsPerPixelX, strWindowsObjectClassName)
    End With
End Property


Private Sub TimerObjectClick_Timer()

    On Error GoTo errmgr
    
    TimerObjectClick.Enabled = False
    
    If (IsValidObject(ObjectToClick)) Then
    
        ObjectToClick.Click
        Set ObjectToClick = Nothing
    End If
Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "TimerObjectClick_Timer"
    WebBrowser.s
End Sub


Public Property Get FullScreen() As Boolean
    FullScreen = Not lvTrace.Visible
End Property

Public Property Let FullScreen(ByVal vNewValue As Boolean)

    If FullScreen <> vNewValue Then
        mnuFullScreen.Checked = vNewValue
        lvTrace.Visible = Not vNewValue
        lvInternal.Visible = Not vNewValue
        Toolbar1.Visible = Not vNewValue
        Me.StatusBar1.Visible = Not vNewValue
        Form_Resize
    End If
End Property



Private Sub mnuFullScreen_Click()
    FullScreen = Not FullScreen
    g_objW3RunnerReportBrowser.Hide
End Sub


Private Sub webBrowser_ClientToHostWindow(cx As Long, cy As Long)

    m_lngClientToHostWindow_cx = cx
    m_lngClientToHostWindow_cy = cy
    'Me.tmrResize.Enabled = True
    
    'Debug.Print "webBrowser_ClientToHostWindow " & cx & " " & cy
    
    If m_lngClientToHostWindow_cx < MinChildWindowWidth Then m_lngClientToHostWindow_cx = MinChildWindowWidth
    If m_lngClientToHostWindow_cy < MinChildWindowHeight Then m_lngClientToHostWindow_cy = MinChildWindowHeight

    ' NO TIMER
    If (m_lngClientToHostWindow_cx <> -1) Then
        Me.Width = (m_lngClientToHostWindow_cx + RESIZE_BORDER_HEIGHT) * Screen.TwipsPerPixelX
    End If
    If (m_lngClientToHostWindow_cy <> -1) Then
        Me.Height = ((m_lngClientToHostWindow_cy + CAPTION_HEIGHT_PIXEL) * Screen.TwipsPerPixelY) + frmMain.StatusBar1.Height
    End If
    Form_Resize
    
    RaiseVBScriptEvent "webBrowser_ClientToHostWindow"
        
End Sub



Public Property Get MinChildWindowWidth() As Long
    MinChildWindowWidth = g_static_lngMinChildWindowWidth
End Property

Public Property Let MinChildWindowWidth(ByVal v As Long)
    g_static_lngMinChildWindowWidth = v
End Property

Public Property Get MinChildWindowHeight() As Long
    MinChildWindowHeight = g_static_lngMinChildWindowHeight
End Property

Public Property Let MinChildWindowHeight(ByVal v As Long)
    g_static_lngMinChildWindowHeight = v
End Property

Public Property Get CommandLineFunctionToExecute() As String
    CommandLineFunctionToExecute = m_strCommandLineFunctionToExecute
End Property

Public Property Let CommandLineFunctionToExecute(ByVal vNewValue As String)
    m_strCommandLineFunctionToExecute = vNewValue
    tmrCommandLineExecute.Enabled = True
End Property

Private Sub tmrCommandLineExecute_Timer()

    tmrCommandLineExecute.Enabled = False
    
    Me.ExecutionTestFunction CommandLineFunctionToExecute
    
    If tmrCommandLineExecute.Tag = "quit" Then
    
        mnuQuit_Click
    Else
        tmrCommandLineExecute.Tag = ""
    End If
End Sub

Public Property Get UpdateWatchWindow() As Boolean

    UpdateWatchWindow = g_static_booUpdateWatchWindow
End Property

Public Property Let UpdateWatchWindow(ByVal vNewValue As Boolean)

    g_static_booUpdateWatchWindow = vNewValue
    
    If g_static_booUpdateWatchWindow Then
    
        frmMain.RefreshWatchWindow
    End If
End Property

Public Function AnimationStart(booStart As Boolean)
    tmrAnimation.Enabled = booStart
    ImageRunner.Visible = booStart
End Function

Public Function RaiseVBScriptEvent(strEventName As String) As Boolean

    Dim strErrorMessage As String
    
    RaiseVBScriptEvent = True
'
'    If (Not frmMain.VBScriptEngine.Execute(strEventName, strErrorMessage, 0)) Then
'        If (Len(strErrorMessage)) Then
'            FShowError strErrorMessage
'            RaiseVBScriptEvent = False
'        End If
'    End If
End Function

Public Property Get CancelScript() As Boolean
    CancelScript = g_static_booCancelScript
End Property

Public Property Let CancelScript(ByVal vNewValue As Boolean)
    g_static_booCancelScript = vNewValue
End Property

Public Function WebBrowserLeft() As Long
    WebBrowserLeft = HTMLDoc.parentWindow.screenLeft
End Function

Public Function WebBrowserTop() As Long
    WebBrowserTop = HTMLDoc.parentWindow.screenTop
End Function

Public Function WebBrowserWidth() As Long
    WebBrowserWidth = (Me.WebBrowser.Width) / Screen.TwipsPerPixelX
End Function

Public Function WebBrowserHeight() As Long
    WebBrowserHeight = (Me.WebBrowser.Height) / Screen.TwipsPerPixelY
End Function

Public Function IsPointInWebBrowser(ByVal lngX As Long, ByVal lngY As Long) As Boolean

    If lngX >= WebBrowserLeft() And lngX <= WebBrowserLeft() + WebBrowserWidth() Then
    
        If lngY >= WebBrowserTop() And lngY <= WebBrowserTop() + WebBrowserHeight() Then
        
            IsPointInWebBrowser = True
        End If
    End If
End Function

Public Function GetBrowserInfo(eInfo As GetBrowserInfo) As Variant

    Dim WindowPos   As WINDOWPLACEMENT
    Dim lpPoint     As POINTAPI
    WindowPos.Length = Len(WindowPos)
    
    
'    If GetWindowPlacement(Me.TxtPosRef.hwnd, WindowPos) Then
'
'        lpPoint.x = WindowPos.rcNormalPosition.Left
'        lpPoint.Y = WindowPos.rcNormalPosition.Top
        
        lpPoint.x = 0
        lpPoint.Y = 0
        If ClientToScreen(Me.TxtPosRef.HWND, lpPoint) Then
        
            Select Case eInfo
                Case GetBrowserInfo_LEFT_POS
                    GetBrowserInfo = lpPoint.x
                    
                Case GetBrowserInfo_TOP_POS
                    GetBrowserInfo = lpPoint.Y + (IIf(Me.Toolbar1.Visible, Me.Toolbar1.Height, 0) / Screen.TwipsPerPixelY)
                    
                Case GetBrowserInfo_MENU_HEIGHT
                    GetBrowserInfo = lpPoint.Y - (Me.Top / Screen.TwipsPerPixelY)
                    
            End Select
        Else
            TRACE W3RUNNER_ERROR_07019, w3rERROR
        End If
'    Else
'        TRACE W3RUNNER_ERROR_07018, w3rERROR
'    End If
End Function

Public Function TraceSystemInfo() As Boolean

    On Error GoTo errmgr
    
    Dim objVBScriptEngine   As New CVBScript

    TRACE PreProcess(W3RUNNER_MSG_07014, "VERSION", GetW3RunnerVersion(True)), w3rINFO
    TRACE PreProcess(W3RUNNER_MSG_07030, "VERSION", objVBScriptEngine.WindowsVersion()), w3rINFO
    TRACE PreProcess(W3RUNNER_MSG_07010, "VERSION", objVBScriptEngine.WebBrowserVersion()), w3rINFO
    TRACE PreProcess(W3RUNNER_MSG_07011, "VERSION", objVBScriptEngine.WindowsScriptHostVersion), w3rINFO
    TRACE PreProcess(W3RUNNER_MSG_07012, "VERSION", objVBScriptEngine.VBScriptEngineVersion), w3rINFO
    TRACE PreProcess(W3RUNNER_MSG_07013, "VERSION", objVBScriptEngine.VBScriptControlVersion), w3rINFO
    TRACE PreProcess(W3RUNNER_MSG_07022, "MODE", IIf(objVBScriptEngine.DebugMode, "On", "Off")), w3rINFO
    TraceSystemInfo = True
    Exit Function
errmgr:
    Err.Clear
End Function


' #

Private Sub WebBrowser_NavigateComplete2(ByVal pDisp As Object, URL As Variant)

    Set HTMLDoc = WebBrowser.Document
         
    If IsValidObject(VBScriptEngine) Then
        If InStr(VBScriptEngine.WebBrowserVersion(), "6.") = 1 Then
            DoEvents
        End If
    End If
End Sub



Public Function DownLoadAndExecuteScript(ByVal strURL As String) As Boolean

    Dim strVBScript             As Variant
    Dim objTextFile             As New cTextFile
    Dim strScriptFileName       As String
    Dim strFunctionName             As String
    Dim lngPos                  As Long
    
    On Error GoTo errmgr
    
'    Debug.Assert 0
    
    If Len(g_objW3RunnerWebServer.IP) Then
    
        strURL = Replace(strURL, W3RUNNER_HTTP_PROTOCOL, "http://" & g_objW3RunnerWebServer.IP & "/")
        
        lngPos = InStr(strURL, "?")
        If lngPos Then
            strFunctionName = Mid(strURL, lngPos + 1)
            strURL = Mid(strURL, 1, lngPos - 1)
        Else
            strFunctionName = W3RUNNER_DEFAULT_FUNCTION_NAME
        End If
    
        If (g_objHTTP.Execute("GET", strURL, , strVBScript) = CHTTP_ERROR_OK) Then
            strVBScript = StrConv(strVBScript, vbUnicode)
            strScriptFileName = Environ("TEMP") & "\" & g_objTextFile.GetFileName(strURL, "/")
            If objTextFile.LogFile(strScriptFileName, strVBScript, True) Then
            
                OpenNewScript strScriptFileName, False
                CommandLineFunctionToExecute = strFunctionName
            Else
                FShowError PreProcess(W3RUNNER_ERROR_07024, "FILENAME", strScriptFileName)
            End If
        Else
            GoTo ErrorServerNotResponding
        End If
    Else
        GoTo ErrorServerNotResponding
    End If
    DownLoadAndExecuteScript = True
    Exit Function
ErrorServerNotResponding:
    FShowError W3RUNNER_ERROR_07023
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "DownLoadAndExecuteScript"
End Function

'
'
'Private Sub tmrWatchWindow_Timer()
'    tmrWatchWindow.Enabled = False
'    mnuWatchWindow_Click
'End Sub

Public Property Get DownLoadTimeOut() As Long
    DownLoadTimeOut = AppOptions("URLDownLoadTimeOut", W3RUNNER_DEFAULT_ASP_TIME_OUT)
End Property

Public Property Let DownLoadTimeOut(ByVal vNewValue As Long)
    AppOptions("URLDownLoadTimeOut") = vNewValue
End Property




Public Function CloseWindow() As Boolean
    On Error GoTo errmgr
    tmrCloseWindow.Enabled = True
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "CloseWindow"
End Function

Private Sub tmrCloseWindow_Timer()
    tmrCloseWindow.Enabled = False
    Unload Me
End Sub

Private Sub WebBrowser_WindowClosing(ByVal IsChildWindow As Boolean, Cancel As Boolean)

    On Error GoTo errmgr

    If (IsChildWindow) Then
        m_objW3RunnerPage.Delete
        Set m_objW3RunnerPage = Nothing
        Unload Me
    End If
Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "WebBrowser_WindowClosing"
End Sub

Public Property Get ShowReportBrowser() As Boolean
    ShowReportBrowser = m_booShowReportBrowser
End Property

Public Property Let ShowReportBrowser(ByVal vNewValue As Boolean)

    If m_booShowReportBrowser <> vNewValue Then
    
        m_booShowReportBrowser = vNewValue
        Me.ReportBrowser.Visible = vNewValue
        Me.Form_Resize
        DoEvents
    End If
End Property


Public Function ReportBrowserWaitForDownLoad(Optional strURL As String) As Boolean

    On Error GoTo errmgr
    
    Dim lngTimeOut                              As Long
    Dim lngAdvancedWaitForDownLoadSleepTime     As Long
        
    Screen.MousePointer = vbArrowHourglass
    Me.MousePointer = vbArrowHourglass
    lngTimeOut = GetTickCount()
    
    lngAdvancedWaitForDownLoadSleepTime = AppOptions("advancedWaitForDownLoadSleepTime", DEFAULT_ADVANCED_WAITFORDOWNLOAD_SLEEP_TIME)
    
    TRACE "Report.WaitForDownLoad """ & strURL & """", w3rMETHOD
    
    If (Len(strURL)) Then g_static_strReportBrowserDownLoadingURL = strURL

    'Do While Len(g_static_strReportBrowserDownLoadingURL) And (Not Me.CancelScript) And (Not IsTimeOut(lngTimeOut))
    Do While Me.WebBrowser.Busy And (Not Me.CancelScript) And (Not IsTimeOut(lngTimeOut))
    
        GlobalDoEvents
        Sleep lngAdvancedWaitForDownLoadSleepTime
    Loop
    
    If ((IsTimeOut(lngTimeOut))) Then
    
        TRACE PreProcess(W3RUNNER_ERROR_07045, "URL", m_objW3RunnerPage.URL), w3rERROR
        Me.CancelScript = CancelScriptIfTimeOut
    Else
        ReportBrowserWaitForDownLoad = Not Me.CancelScript ' If we cancel the script we return that the page has time out, that is better of the script writing... If Page.WaitForDownLoad("*.asp") Then
    End If
TheExit:
    Sleep 1
    GlobalDoEvents
    Screen.MousePointer = ssDefault
    Me.MousePointer = ssDefault
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "ReportBrowserWaitForDownLoad"
End Function


Private Sub ReportBrowser_DocumentComplete(ByVal pDisp As Object, URL As Variant)

    On Error GoTo errmgr
    
    Dim strText As String
    
    If (URL <> "http:///") And (URL <> "") Then
            
        TRACE PreProcess("Downloaded URL=[DC][URL][DC]", "DC", """", "URL", URL), w3rURL_DOWNLOADED ' Trace All MainForm and Children because every body call the event of the frmMain
        
        If (InStr(UCase(URL), UCase(g_static_strReportBrowserDownLoadingURL))) And (IsValidObject(pDisp)) Then ' If pDisp is nothing this is a child window telling the frmMain window to stop waiting for download
        
            TRACE "g_static_strReportBrowserDownLoadingURL url=" & URL & " Tick=" & GetTickCount(), w3rINTERNAL
            g_static_strReportBrowserDownLoadingURL = ""
        End If
    End If
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "ReportBrowser_DocumentComplete"
End Sub

Private Sub imgSplitter_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    With imgSplitter
        picSplitter.Move .Left, .Top, .Width \ 2, .Height - 20
    End With
    picSplitter.Visible = True
    m_boolMoving = True

    Exit Sub
errmgr:
   
End Sub

Private Sub imgSplitter_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    Dim sglPos As Single
    
    If m_boolMoving Then
    
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
    If m_boolMoving Then
        
        m_lngLvTraceWidthSize = x + imgSplitter.Left
        
        CheckControlSizing
        
        AppOptions("m_lngLvTraceWidthSize", , "RESIZE") = m_lngLvTraceWidthSize
        picSplitter.Visible = False
        m_boolMoving = False
        Form_Resize
    End If

    Exit Sub
errmgr:
   
End Sub


Private Function CheckControlSizing() As Boolean

    On Error GoTo errmgr

    ' Restore the a good position in case of mess
    If m_lngLvTraceHeightSize < sglSplitLimit Then m_lngLvTraceHeightSize = sglSplitLimit
    If m_lngLvTraceWidthSize > Me.Width - sglSplitLimit Then m_lngLvTraceWidthSize = Me.Width - sglSplitLimit
    CheckControlSizing = True
    Exit Function
errmgr:

    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "CheckControlSizing"
End Function
