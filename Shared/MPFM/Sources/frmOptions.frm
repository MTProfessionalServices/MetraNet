VERSION 5.00
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "tabctl32.ocx"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form frmOptions 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Options"
   ClientHeight    =   4890
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   9930
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4890
   ScaleWidth      =   9930
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin MSComDlg.CommonDialog cm 
      Left            =   2520
      Top             =   4560
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin TabDlg.SSTab SSTab1 
      Height          =   4215
      Left            =   120
      TabIndex        =   2
      Top             =   120
      Width           =   9735
      _ExtentX        =   17171
      _ExtentY        =   7435
      _Version        =   393216
      Style           =   1
      TabsPerRow      =   6
      TabHeight       =   520
      TabCaption(0)   =   "General"
      TabPicture(0)   =   "frmOptions.frx":0000
      Tab(0).ControlEnabled=   -1  'True
      Tab(0).Control(0)=   "Label1"
      Tab(0).Control(0).Enabled=   0   'False
      Tab(0).Control(1)=   "editor"
      Tab(0).Control(1).Enabled=   0   'False
      Tab(0).Control(2)=   "cmdTextEditor"
      Tab(0).Control(2).Enabled=   0   'False
      Tab(0).ControlCount=   3
      TabCaption(1)   =   "VBScript"
      TabPicture(1)   =   "frmOptions.frx":001C
      Tab(1).ControlEnabled=   0   'False
      Tab(1).Control(0)=   "CVBScript_ErrorLineInfo"
      Tab(1).Control(1)=   "VBScriptEngineEnableDebugger"
      Tab(1).ControlCount=   2
      TabCaption(2)   =   "Application"
      TabPicture(2)   =   "frmOptions.frx":0038
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "Label2"
      Tab(2).Control(0).Enabled=   0   'False
      Tab(2).Control(1)=   "WebServer"
      Tab(2).Control(1).Enabled=   0   'False
      Tab(2).ControlCount=   2
      Begin VB.TextBox WebServer 
         Height          =   335
         Left            =   -72840
         TabIndex        =   8
         Top             =   480
         Width           =   6975
      End
      Begin VB.CheckBox VBScriptEngineEnableDebugger 
         Caption         =   "Enable Debugger"
         Height          =   255
         Left            =   -74760
         TabIndex        =   7
         Top             =   600
         Width           =   1695
      End
      Begin VB.CheckBox CVBScript_ErrorLineInfo 
         Caption         =   "Add Error Line Information to the Scripts"
         Height          =   255
         Left            =   -74760
         TabIndex        =   6
         Top             =   960
         Width           =   4575
      End
      Begin VB.CommandButton cmdTextEditor 
         Caption         =   "..."
         Height          =   335
         Left            =   9240
         TabIndex        =   5
         Top             =   600
         Width           =   335
      End
      Begin VB.TextBox editor 
         Height          =   335
         Left            =   2160
         TabIndex        =   3
         Top             =   600
         Width           =   6975
      End
      Begin VB.Label Label2 
         Caption         =   "Web Server :"
         Height          =   375
         Left            =   -74760
         TabIndex        =   9
         Top             =   480
         Width           =   2895
      End
      Begin VB.Label Label1 
         Caption         =   "Text Editor :"
         Height          =   375
         Left            =   240
         TabIndex        =   4
         Top             =   600
         Width           =   2895
      End
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   8640
      TabIndex        =   1
      Top             =   4440
      Width           =   1215
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   7320
      TabIndex        =   0
      Top             =   4440
      Width           =   1215
   End
End
Attribute VB_Name = "frmOptions"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Private m_booOK As Boolean

Private Sub cmdCancel_Click()
    Hide
End Sub

Private Sub cmdOK_Click()
    m_booOK = True
    Hide
End Sub

Private Sub cmdTextEditor_Click()
    Dim objTool     As New cTool
    Dim strEditor   As String
    
    strEditor = objTool.getUserOpenFile(cm, "Text Editor", "Program Files (*.exe)|*.exe", False)
    If (Len(strEditor)) Then
        editor.Text = strEditor
    End If
    
End Sub

'Private Sub Command1_Click()
'    Dim objWinApi   As New cWindows
'    Dim strPath     As String
'
'    strPath = objWinApi.getBrowseDirectory(0, TESTHARNESS_MESSAGE_7006)
'    If (Len(strPath)) Then
'        DatabasePath.Text = strPath
'
'    End If
'End Sub

Private Sub Form_Load()
    m_booOK = False
End Sub

Public Function OpenDialog(objIniFile As cIniFile) As Boolean
    
    Dim objVBScriptEngine As New CVBScript
    
    objIniFile.getForm Me
    
    VBScriptEngineEnableDebugger.Value = Abs(CBool(objVBScriptEngine.DebugMode))
    
    Me.Show vbModal
    
    If (m_booOK) Then
        objIniFile.setForm Me
        objVBScriptEngine.DebugMode = Abs(VBScriptEngineEnableDebugger.Value)
        OpenDialog = True
    End If
    Unload Me
    Set frmOptions = Nothing
    
End Function



Private Sub Label4_Click()

End Sub

