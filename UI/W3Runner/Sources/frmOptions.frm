VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "tabctl32.ocx"
Begin VB.Form frmoptions 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Options"
   ClientHeight    =   5370
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   7425
   Icon            =   "frmOptions.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5370
   ScaleWidth      =   7425
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton butHelp 
      Caption         =   "&Help"
      Height          =   375
      Left            =   6135
      TabIndex        =   36
      Top             =   4980
      Width           =   1215
   End
   Begin TabDlg.SSTab SSTab1 
      Height          =   4875
      Left            =   60
      TabIndex        =   30
      Top             =   60
      Width           =   7305
      _ExtentX        =   12885
      _ExtentY        =   8599
      _Version        =   393216
      Style           =   1
      Tabs            =   7
      Tab             =   1
      TabsPerRow      =   8
      TabHeight       =   520
      TabCaption(0)   =   "General"
      TabPicture(0)   =   "frmOptions.frx":0E42
      Tab(0).ControlEnabled=   0   'False
      Tab(0).Control(0)=   "cm"
      Tab(0).Control(1)=   "butClearURLHistory"
      Tab(0).Control(2)=   "Frame4"
      Tab(0).Control(3)=   "Frame5"
      Tab(0).Control(4)=   "Frame6"
      Tab(0).Control(5)=   "butShowAdvice"
      Tab(0).ControlCount=   6
      TabCaption(1)   =   "VBScript"
      TabPicture(1)   =   "frmOptions.frx":0E5E
      Tab(1).ControlEnabled=   -1  'True
      Tab(1).Control(0)=   "lblDebugInfo"
      Tab(1).Control(0).Enabled=   0   'False
      Tab(1).Control(1)=   "Label3"
      Tab(1).Control(1).Enabled=   0   'False
      Tab(1).Control(2)=   "VBScriptEngineEnableDebugger"
      Tab(1).Control(2).Enabled=   0   'False
      Tab(1).Control(3)=   "CVBScript_ErrorLineInfo"
      Tab(1).Control(3).Enabled=   0   'False
      Tab(1).Control(4)=   "CVBScript_TraceFunctionCall"
      Tab(1).Control(4).Enabled=   0   'False
      Tab(1).Control(5)=   "MoveMouseCursor"
      Tab(1).Control(5).Enabled=   0   'False
      Tab(1).Control(6)=   "AutoFocus"
      Tab(1).Control(6).Enabled=   0   'False
      Tab(1).Control(7)=   "SlowMode"
      Tab(1).Control(7).Enabled=   0   'False
      Tab(1).ControlCount=   8
      TabCaption(2)   =   "Trace"
      TabPicture(2)   =   "frmOptions.frx":0E7A
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "TraceShowMessageBoxOnError"
      Tab(2).Control(1)=   "Frame1"
      Tab(2).Control(2)=   "Frame2"
      Tab(2).Control(3)=   "Frame3"
      Tab(2).ControlCount=   4
      TabCaption(3)   =   "Advanced Tuning"
      TabPicture(3)   =   "frmOptions.frx":0E96
      Tab(3).ControlEnabled=   0   'False
      Tab(3).Control(0)=   "Label1"
      Tab(3).Control(1)=   "Label5"
      Tab(3).Control(2)=   "Label6"
      Tab(3).Control(3)=   "Label11"
      Tab(3).Control(4)=   "advancedURLTime"
      Tab(3).Control(5)=   "advancedWatchReadyStateTime"
      Tab(3).Control(6)=   "advancedClickTime"
      Tab(3).Control(7)=   "butDefaultValue"
      Tab(3).Control(8)=   "advancedWaitForDownLoadSleepTime"
      Tab(3).ControlCount=   9
      TabCaption(4)   =   "JavaScript"
      TabPicture(4)   =   "frmOptions.frx":0EB2
      Tab(4).ControlEnabled=   0   'False
      Tab(4).Control(0)=   "AutoFireJavaScriptEvent"
      Tab(4).ControlCount=   1
      TabCaption(5)   =   "Record Mode"
      TabPicture(5)   =   "frmOptions.frx":0ECE
      Tab(5).ControlEnabled=   0   'False
      Tab(5).Control(0)=   "Frame7"
      Tab(5).Control(1)=   "WatchWindowAlwaysOnTop"
      Tab(5).Control(2)=   "RecordOnlyFromFrame"
      Tab(5).Control(3)=   "Label9"
      Tab(5).ControlCount=   4
      TabCaption(6)   =   "External Tools"
      TabPicture(6)   =   "frmOptions.frx":0EEA
      Tab(6).ControlEnabled=   0   'False
      Tab(6).Control(0)=   "Label8"
      Tab(6).Control(1)=   "Label7"
      Tab(6).Control(2)=   "TraceFileViewer"
      Tab(6).Control(3)=   "butSetTraceFileViewer"
      Tab(6).Control(4)=   "butSetEditor"
      Tab(6).Control(5)=   "Editor"
      Tab(6).ControlCount=   6
      Begin VB.Frame Frame7 
         Caption         =   "Specific HTML Tags"
         Height          =   1455
         Left            =   -74880
         TabIndex        =   66
         Top             =   1560
         Width           =   7035
         Begin VB.CheckBox RecordHTMLTagTDWithNoName 
            Caption         =   "Record HTML tag <TD> with no name"
            Height          =   375
            Left            =   180
            TabIndex        =   68
            Top             =   600
            Width           =   3495
         End
         Begin VB.CheckBox RecordHTMLTagDIVWithNoName 
            Caption         =   "Record HTML tag <DIV> with no name"
            Height          =   375
            Left            =   180
            TabIndex        =   67
            Top             =   240
            Width           =   3495
         End
      End
      Begin VB.CommandButton butShowAdvice 
         Caption         =   "Show Quick Info"
         Height          =   375
         Left            =   -71460
         TabIndex        =   65
         Top             =   4320
         Width           =   1575
      End
      Begin VB.Frame Frame6 
         Caption         =   "Registration"
         Height          =   1035
         Left            =   -74880
         TabIndex        =   62
         Top             =   3120
         Width           =   7095
         Begin VB.TextBox RK 
            Height          =   335
            Left            =   1560
            TabIndex        =   63
            Top             =   420
            Visible         =   0   'False
            Width           =   5355
         End
         Begin VB.Label lngRegistrationKey 
            Caption         =   "&Serial Number :"
            Height          =   375
            Left            =   180
            TabIndex        =   64
            Top             =   420
            Visible         =   0   'False
            Width           =   3195
         End
      End
      Begin VB.TextBox Editor 
         Height          =   335
         Left            =   -73380
         TabIndex        =   59
         Top             =   540
         Width           =   5000
      End
      Begin VB.CommandButton butSetEditor 
         Caption         =   "..."
         Height          =   315
         Left            =   -68280
         TabIndex        =   58
         Top             =   540
         Width           =   375
      End
      Begin VB.CommandButton butSetTraceFileViewer 
         Caption         =   "..."
         Height          =   315
         Left            =   -68280
         TabIndex        =   57
         Top             =   900
         Width           =   375
      End
      Begin VB.TextBox TraceFileViewer 
         Height          =   335
         Left            =   -73380
         TabIndex        =   56
         Top             =   900
         Width           =   5000
      End
      Begin VB.TextBox SlowMode 
         Height          =   335
         Left            =   3060
         TabIndex        =   54
         Text            =   "0"
         Top             =   2700
         Width           =   1035
      End
      Begin VB.Frame Frame5 
         Caption         =   "Time Out"
         Height          =   1275
         Left            =   -74880
         TabIndex        =   49
         Top             =   1800
         Width           =   7095
         Begin VB.TextBox MsgBoxTimeOut 
            Height          =   335
            Left            =   3180
            TabIndex        =   52
            Text            =   "20"
            Top             =   720
            Width           =   1035
         End
         Begin VB.TextBox URLDownLoadTimeOut 
            Height          =   335
            Left            =   3180
            TabIndex        =   50
            Text            =   "20"
            Top             =   300
            Width           =   1035
         End
         Begin VB.Label Label10 
            Caption         =   "&Message Box TimeOut in seconds :"
            Height          =   375
            Left            =   180
            TabIndex        =   53
            Top             =   720
            Width           =   3255
         End
         Begin VB.Label Label2 
            Caption         =   "&URL Download TimeOut (Seconds) :"
            Height          =   375
            Left            =   180
            TabIndex        =   51
            Top             =   300
            Width           =   3195
         End
      End
      Begin VB.Frame Frame4 
         Caption         =   "Welcome Page"
         Height          =   1335
         Left            =   -74880
         TabIndex        =   44
         Top             =   420
         Width           =   7095
         Begin VB.CommandButton cmdUseBlank 
            Caption         =   "Use Blank"
            Height          =   375
            Left            =   4260
            TabIndex        =   48
            Top             =   780
            Width           =   1095
         End
         Begin VB.CommandButton cmdUseDefault 
            Caption         =   "Use Default"
            Height          =   375
            Left            =   3120
            TabIndex        =   47
            Top             =   780
            Width           =   1095
         End
         Begin VB.TextBox HomePage 
            Height          =   335
            Left            =   1680
            TabIndex        =   46
            Top             =   300
            Width           =   5235
         End
         Begin VB.Label Label12 
            Caption         =   "Address:"
            Height          =   315
            Left            =   120
            TabIndex        =   45
            Top             =   300
            Width           =   1155
         End
      End
      Begin VB.TextBox advancedWaitForDownLoadSleepTime 
         Height          =   335
         Left            =   -71220
         TabIndex        =   40
         Top             =   1560
         Width           =   1035
      End
      Begin VB.CheckBox AutoFocus 
         Caption         =   "Auto Focus"
         Height          =   255
         Left            =   120
         TabIndex        =   39
         Top             =   1920
         Width           =   5535
      End
      Begin VB.CheckBox MoveMouseCursor 
         Caption         =   "Move Mouse Cursor"
         Height          =   255
         Left            =   120
         TabIndex        =   38
         Top             =   1560
         Width           =   5535
      End
      Begin VB.CheckBox CVBScript_TraceFunctionCall 
         Caption         =   "Trace sub, function and property call"
         Height          =   255
         Left            =   120
         TabIndex        =   37
         Top             =   3720
         Width           =   4575
      End
      Begin VB.CommandButton butClearURLHistory 
         Caption         =   "Clear URL History"
         Height          =   375
         Left            =   -73260
         TabIndex        =   35
         Top             =   4320
         Width           =   1575
      End
      Begin VB.CheckBox CVBScript_ErrorLineInfo 
         Caption         =   "Add error line information to the scripts"
         Height          =   255
         Left            =   120
         TabIndex        =   1
         Top             =   2280
         Width           =   4575
      End
      Begin VB.CheckBox WatchWindowAlwaysOnTop 
         Caption         =   "Watch Window Always On Top"
         Height          =   375
         Left            =   -72600
         TabIndex        =   27
         Top             =   960
         Width           =   3315
      End
      Begin VB.TextBox RecordOnlyFromFrame 
         Height          =   335
         Left            =   -72600
         TabIndex        =   26
         Top             =   540
         Width           =   3735
      End
      Begin VB.CheckBox AutoFireJavaScriptEvent 
         Caption         =   "AutoFire Missing JavaScript Events"
         Height          =   495
         Left            =   -74820
         TabIndex        =   24
         Top             =   360
         Value           =   1  'Checked
         Width           =   4335
      End
      Begin MSComDlg.CommonDialog cm 
         Left            =   -68220
         Top             =   4080
         _ExtentX        =   847
         _ExtentY        =   847
         _Version        =   393216
      End
      Begin VB.CommandButton butDefaultValue 
         Caption         =   "Reset default values"
         Height          =   375
         Left            =   -72180
         TabIndex        =   23
         Top             =   2880
         Width           =   1755
      End
      Begin VB.TextBox advancedClickTime 
         Height          =   335
         Left            =   -71220
         TabIndex        =   22
         Top             =   1200
         Width           =   1035
      End
      Begin VB.TextBox advancedWatchReadyStateTime 
         Height          =   335
         Left            =   -71220
         TabIndex        =   20
         Top             =   840
         Width           =   1035
      End
      Begin VB.TextBox advancedURLTime 
         Height          =   335
         Left            =   -71220
         TabIndex        =   18
         Top             =   480
         Width           =   1035
      End
      Begin VB.Frame Frame3 
         Caption         =   "List Views"
         Height          =   1335
         Left            =   -74940
         TabIndex        =   34
         Top             =   3360
         Width           =   7155
         Begin VB.TextBox TraceListViewMaxSize 
            Height          =   375
            Left            =   2520
            TabIndex        =   16
            Top             =   720
            Width           =   855
         End
         Begin VB.CheckBox ClearTraceWhenFull 
            Caption         =   "Clear the trace list view when full"
            Height          =   255
            Left            =   120
            TabIndex        =   14
            Top             =   300
            Width           =   3135
         End
         Begin VB.Label Label4 
            Caption         =   "Trace list view max line :"
            Height          =   255
            Left            =   120
            TabIndex        =   15
            Top             =   720
            Width           =   2175
         End
      End
      Begin VB.Frame Frame2 
         Caption         =   "Script Info"
         Height          =   1275
         Left            =   -74940
         TabIndex        =   33
         Top             =   2040
         Width           =   7155
         Begin VB.CheckBox TraceType128 
            Caption         =   "W3Runner Internal Message"
            Height          =   255
            Left            =   120
            TabIndex        =   13
            Top             =   720
            Width           =   2595
         End
         Begin VB.CheckBox TraceType256 
            Caption         =   "Script Interface Calls"
            Height          =   255
            Left            =   120
            TabIndex        =   11
            Top             =   300
            Width           =   2175
         End
         Begin VB.CheckBox TraceType512 
            Caption         =   "JavaScript events raised by W3Runner"
            Height          =   255
            Left            =   2880
            TabIndex        =   12
            Top             =   300
            Width           =   3495
         End
      End
      Begin VB.Frame Frame1 
         Caption         =   "Trace"
         Height          =   1215
         Left            =   -74940
         TabIndex        =   32
         Top             =   780
         Width           =   7155
         Begin VB.CheckBox TraceType4096 
            Caption         =   "Performance"
            Height          =   255
            Left            =   5760
            TabIndex        =   43
            Top             =   720
            Width           =   1300
         End
         Begin VB.CheckBox TraceType8192 
            Caption         =   "Web Service"
            Height          =   255
            Left            =   5760
            TabIndex        =   42
            Top             =   300
            Width           =   1300
         End
         Begin VB.CheckBox TraceType1024 
            Caption         =   "Succeed"
            Height          =   255
            Left            =   3840
            TabIndex        =   6
            Top             =   300
            Width           =   1635
         End
         Begin VB.CheckBox TraceType64 
            Caption         =   "Debug"
            Height          =   255
            Left            =   1200
            TabIndex        =   8
            Top             =   720
            Width           =   795
         End
         Begin VB.CheckBox TraceType16384 
            Caption         =   "HTTP"
            Height          =   255
            Left            =   120
            TabIndex        =   7
            Top             =   720
            Width           =   915
         End
         Begin VB.CheckBox TraceType16 
            Caption         =   "URL DownLoaded"
            Height          =   255
            Left            =   3840
            TabIndex        =   10
            Top             =   720
            Width           =   1635
         End
         Begin VB.CheckBox TraceType8 
            Caption         =   "SQL"
            Height          =   255
            Left            =   2460
            TabIndex        =   9
            Top             =   720
            Width           =   1095
         End
         Begin VB.CheckBox TraceType4 
            Caption         =   "Warning"
            Height          =   255
            Left            =   2460
            TabIndex        =   5
            Top             =   300
            Width           =   1095
         End
         Begin VB.CheckBox TraceType2 
            Caption         =   "Error"
            Height          =   255
            Left            =   1200
            TabIndex        =   4
            Top             =   300
            Width           =   795
         End
         Begin VB.CheckBox TraceType1 
            Caption         =   "Info"
            Height          =   255
            Left            =   120
            TabIndex        =   3
            Top             =   300
            Width           =   795
         End
      End
      Begin VB.CheckBox TraceShowMessageBoxOnError 
         Caption         =   "Show an auto-close message box on error"
         Height          =   255
         Left            =   -74820
         TabIndex        =   2
         Top             =   480
         Width           =   5535
      End
      Begin VB.CheckBox VBScriptEngineEnableDebugger 
         Caption         =   "Enable &Debugger"
         Height          =   255
         Left            =   120
         TabIndex        =   0
         Top             =   1200
         Width           =   1695
      End
      Begin VB.Label Label7 
         Caption         =   "&Editor :"
         Height          =   375
         Left            =   -74820
         TabIndex        =   61
         Top             =   540
         Width           =   3195
      End
      Begin VB.Label Label8 
         Caption         =   "&Trace File Viewer :"
         Height          =   375
         Left            =   -74820
         TabIndex        =   60
         Top             =   900
         Width           =   3195
      End
      Begin VB.Label Label3 
         Caption         =   "&Slow Mode (Wait time in milliseconds) :"
         Height          =   375
         Left            =   120
         TabIndex        =   55
         Top             =   2760
         Width           =   3195
      End
      Begin VB.Label Label11 
         Caption         =   "WaitForDownLoad() Sleep Time"
         Height          =   375
         Left            =   -74820
         TabIndex        =   41
         Top             =   1560
         Width           =   3675
      End
      Begin VB.Label Label9 
         Caption         =   "Record only from frame :"
         Height          =   375
         Left            =   -74820
         TabIndex        =   25
         Top             =   600
         Width           =   3195
      End
      Begin VB.Label Label6 
         Caption         =   "Wait time before a click :"
         Height          =   375
         Left            =   -74820
         TabIndex        =   21
         Top             =   1200
         Width           =   3675
      End
      Begin VB.Label Label5 
         Caption         =   "Wait time after a page is downloaded :"
         Height          =   375
         Left            =   -74820
         TabIndex        =   19
         Top             =   840
         Width           =   3255
      End
      Begin VB.Label Label1 
         Caption         =   "Wait time before executing an URL :"
         Height          =   375
         Left            =   -74820
         TabIndex        =   17
         Top             =   540
         Width           =   3255
      End
      Begin VB.Label lblDebugInfo 
         Appearance      =   0  'Flat
         BackColor       =   &H00E0E0E0&
         BackStyle       =   0  'Transparent
         BorderStyle     =   1  'Fixed Single
         ForeColor       =   &H80000008&
         Height          =   645
         Left            =   120
         TabIndex        =   31
         Top             =   480
         Width           =   6975
      End
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   4860
      TabIndex        =   29
      Top             =   4980
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   3600
      TabIndex        =   28
      Top             =   4980
      Width           =   1215
   End
End
Attribute VB_Name = "frmoptions"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Private m_booOK As Boolean
Private m_strPreviousRegistration As String

Public Function OpenDialog()

        Dim objVBScriptEngine As New CVBScript

        Load Me
        g_objIniFile.getForm Me
        
        m_strPreviousRegistration = Me.RK
        
        lblDebugInfo.Caption = W3RUNNER_MSG_07049
        
        If (Len(Editor.Text) = 0) Then
            Editor.Text = DEFAULT_EDITOR
        End If
        
        If (Len(advancedURLTime.Text) = 0) Then
            butDefaultValue_Click
        End If
                
        VBScriptEngineEnableDebugger.Value = Abs(CBool(objVBScriptEngine.DebugMode))
        
        If Not g_static_booRegistered Then
        
            HomePage.Text = W3RUNNER_DEFAULT_HOME_PAGE_COMMAND
            HomePage.Enabled = False
            cmdUseBlank.Enabled = False
            cmdUseDefault.Enabled = False
        End If
                
        Me.Show vbModal
        If (m_booOK) Then
            g_objIniFile.setForm Me
            objVBScriptEngine.DebugMode = Abs(VBScriptEngineEnableDebugger.Value)
            If m_strPreviousRegistration <> Me.RK Then
                frmQuickMessage.OpenDialog W3RUNNER_MSG_07041, "07041"
                RegistrationClearSerialNumberName ' Clear the serial number name so the user must re enter the serial number name
            End If
        End If
        Unload Me
End Function

Private Sub advancedClickTime_KeyPress(KeyAscii As Integer)
    QuickLongFieldValidation advancedClickTime, KeyAscii, 3
End Sub

Private Sub advancedURLTime_KeyPress(KeyAscii As Integer)
    QuickLongFieldValidation advancedURLTime, KeyAscii, 3
End Sub

 


Private Sub advancedWaitForDownLoadSleepTime_KeyPress(KeyAscii As Integer)
    QuickLongFieldValidation advancedWaitForDownLoadSleepTime, KeyAscii, 3
End Sub

Private Sub advancedWatchReadyStateTime_KeyPress(KeyAscii As Integer)
    QuickLongFieldValidation advancedWatchReadyStateTime, KeyAscii, 3
End Sub

Private Sub butClearURLHistory_Click()
    Dim objTextFile As New cTextFile
    objTextFile.DeleteFile GetW3RunnerComboBoxURLHistoryFileName()
    frmMain.txtURL.Clear
    
    
End Sub

Private Sub butDefaultValue_Click()
    advancedURLTime.Text = DEFAULT_ADVANCED_URL_TIME
    advancedWatchReadyStateTime.Text = DEFAULT_ADVANCED_WATCH_READY_STATE_TIME
    advancedClickTime.Text = DEFAULT_ADVANCED_CLICK_TIME
    Me.advancedWaitForDownLoadSleepTime.Text = DEFAULT_ADVANCED_WAITFORDOWNLOAD_SLEEP_TIME
End Sub



Private Sub butHelp_Click()
    Select Case Me.SSTab1.Tab
    
        Case 0: g_objW3RunnerHelp.HelpShow GeneralTab
        Case 1: g_objW3RunnerHelp.HelpShow VBScriptTab
        Case 2: g_objW3RunnerHelp.HelpShow TraceTab
        Case 3: g_objW3RunnerHelp.HelpShow AdvancedTuningTab
        Case 4: g_objW3RunnerHelp.HelpShow JavaScriptTab
        Case 5: g_objW3RunnerHelp.HelpShow RecordModeTab
        Case 6: g_objW3RunnerHelp.HelpShow ExternalToolTab
        
    End Select
End Sub

Private Sub butSetEditor_Click()
    Dim t As New cTool
    Dim s As String
    s = t.getUserOpenFile(cm, W3RUNNER_ERROR_07015, "Program Files|*.exe", False, App.path)
    If (Len(s)) Then
        Me.Editor.Text = s
    End If
End Sub

Private Sub butSetTraceFileViewer_Click()
    Dim t As New cTool
    Dim s As String
    s = t.getUserOpenFile(cm, W3RUNNER_ERROR_07017, "Program Files|*.exe", False, App.path)
    If (Len(s)) Then
        Me.TraceFileViewer.Text = s
    End If
End Sub

Private Sub butShowAdvice_Click()
    AppOptions("QuickMessage") = ""
End Sub

Private Sub CancelButton_Click()
    Hide
End Sub



Private Sub cmdUseBlank_Click()
    HomePage.Text = ""
End Sub

Private Sub cmdUseDefault_Click()
    HomePage.Text = W3RUNNER_DEFAULT_HOME_PAGE_COMMAND
End Sub

Private Sub Form_Load()

    lblDebugInfo.BorderStyle = 0
    lngRegistrationKey.Visible = True
    RK.Visible = True
    Me.SSTab1.Tab = 0
    
    CVBScript_TraceFunctionCall.Visible = False
End Sub

Private Sub MsgBoxTimeOut_KeyPress(KeyAscii As Integer)
        QuickLongFieldValidation MsgBoxTimeOut, KeyAscii, 3
End Sub

Private Sub OKButton_Click()
    m_booOK = True
    Hide
End Sub

Private Sub SlowMode_KeyPress(KeyAscii As Integer)
    QuickLongFieldValidation SlowMode, KeyAscii, 4
End Sub



Private Sub TraceListViewMaxSize_KeyPress(KeyAscii As Integer)
    QuickLongFieldValidation TraceListViewMaxSize, KeyAscii, 4
End Sub

Private Sub URLDownLoadTimeOut_KeyPress(KeyAscii As Integer)
    QuickLongFieldValidation URLDownLoadTimeOut, KeyAscii, 3
End Sub

Private Sub VBScriptEngineEnableDebugger_Click()
    If (VBScriptEngineEnableDebugger.Value = vbChecked) Then

    Else
        
    End If
End Sub

