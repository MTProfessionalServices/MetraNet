VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "TABCTL32.OCX"
Begin VB.Form frmOptions 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Options"
   ClientHeight    =   3945
   ClientLeft      =   2760
   ClientTop       =   3765
   ClientWidth     =   8730
   Icon            =   "frmOptions.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3945
   ScaleWidth      =   8730
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin MSComDlg.CommonDialog cm 
      Left            =   2520
      Top             =   4560
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   7440
      TabIndex        =   1
      Top             =   3540
      Width           =   1215
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   6120
      TabIndex        =   0
      Top             =   3540
      Width           =   1215
   End
   Begin TabDlg.SSTab SSTab1 
      Height          =   3435
      Left            =   120
      TabIndex        =   2
      Top             =   0
      Width           =   8595
      _ExtentX        =   15161
      _ExtentY        =   6059
      _Version        =   393216
      Style           =   1
      TabsPerRow      =   6
      TabHeight       =   520
      TabCaption(0)   =   "General"
      TabPicture(0)   =   "frmOptions.frx":030A
      Tab(0).ControlEnabled=   -1  'True
      Tab(0).Control(0)=   "Label1"
      Tab(0).Control(0).Enabled=   0   'False
      Tab(0).Control(1)=   "Label11"
      Tab(0).Control(1).Enabled=   0   'False
      Tab(0).Control(2)=   "Label8"
      Tab(0).Control(2).Enabled=   0   'False
      Tab(0).Control(3)=   "Label9"
      Tab(0).Control(3).Enabled=   0   'False
      Tab(0).Control(4)=   "LabelEmail"
      Tab(0).Control(4).Enabled=   0   'False
      Tab(0).Control(5)=   "editor"
      Tab(0).Control(5).Enabled=   0   'False
      Tab(0).Control(6)=   "cmdTextEditor"
      Tab(0).Control(6).Enabled=   0   'False
      Tab(0).Control(7)=   "IconizeWhenRunATest"
      Tab(0).Control(7).Enabled=   0   'False
      Tab(0).Control(8)=   "ShowStaticFile"
      Tab(0).Control(8).Enabled=   0   'False
      Tab(0).Control(9)=   "IgnorePaths"
      Tab(0).Control(9).Enabled=   0   'False
      Tab(0).Control(10)=   "cmdDescriptionFont"
      Tab(0).Control(10).Enabled=   0   'False
      Tab(0).Control(11)=   "FontInfo"
      Tab(0).Control(11).Enabled=   0   'False
      Tab(0).Control(12)=   "DescriptionTabSize"
      Tab(0).Control(12).Enabled=   0   'False
      Tab(0).Control(13)=   "EMAIL"
      Tab(0).Control(13).Enabled=   0   'False
      Tab(0).ControlCount=   14
      TabCaption(1)   =   "Scripting Engine"
      TabPicture(1)   =   "frmOptions.frx":0326
      Tab(1).ControlEnabled=   0   'False
      Tab(1).Control(0)=   "DebugScriptEngineMode"
      Tab(1).Control(1)=   "ShowScriptEngineWindow"
      Tab(1).Control(2)=   "ScriptingExecutable"
      Tab(1).Control(3)=   "Label2"
      Tab(1).ControlCount=   4
      TabCaption(2)   =   "Repository"
      TabPicture(2)   =   "frmOptions.frx":0342
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "RepositoryWebURL"
      Tab(2).Control(1)=   "RepositoryPassWord"
      Tab(2).Control(2)=   "RepositoryLogIn"
      Tab(2).Control(3)=   "RepositoryDatabase"
      Tab(2).Control(4)=   "RepositoryServer"
      Tab(2).Control(5)=   "Label7"
      Tab(2).Control(6)=   "Label6"
      Tab(2).Control(7)=   "Label5"
      Tab(2).Control(8)=   "Label4"
      Tab(2).Control(9)=   "Label3"
      Tab(2).ControlCount=   10
      Begin VB.TextBox RepositoryWebURL 
         Height          =   335
         Left            =   -72660
         TabIndex        =   29
         Top             =   1980
         Width           =   5415
      End
      Begin VB.TextBox RepositoryPassWord 
         Height          =   335
         Left            =   -72660
         TabIndex        =   27
         Top             =   1620
         Width           =   5415
      End
      Begin VB.TextBox RepositoryLogIn 
         Height          =   335
         Left            =   -72660
         TabIndex        =   25
         Text            =   "sa"
         Top             =   1260
         Width           =   5415
      End
      Begin VB.TextBox RepositoryDatabase 
         Height          =   335
         Left            =   -72660
         TabIndex        =   23
         Text            =   "Tracker"
         Top             =   900
         Width           =   5415
      End
      Begin VB.TextBox RepositoryServer 
         Height          =   335
         Left            =   -72660
         TabIndex        =   21
         Text            =   "Berlin"
         Top             =   540
         Width           =   5415
      End
      Begin VB.TextBox EMAIL 
         Height          =   335
         Left            =   2280
         TabIndex        =   19
         Top             =   2940
         Width           =   5415
      End
      Begin VB.TextBox DescriptionTabSize 
         Height          =   335
         Left            =   2280
         TabIndex        =   17
         Text            =   "2"
         Top             =   2520
         Width           =   675
      End
      Begin VB.TextBox FontInfo 
         Height          =   335
         Left            =   2280
         TabIndex        =   15
         Text            =   "Font Sample"
         Top             =   2160
         Width           =   5415
      End
      Begin VB.CommandButton cmdDescriptionFont 
         Caption         =   "..."
         Height          =   335
         Left            =   7800
         TabIndex        =   14
         Top             =   2175
         Width           =   335
      End
      Begin VB.TextBox IgnorePaths 
         Height          =   335
         Left            =   2280
         TabIndex        =   12
         Top             =   960
         Width           =   5415
      End
      Begin VB.CheckBox ShowStaticFile 
         Caption         =   "Show static files"
         Height          =   315
         Left            =   2280
         TabIndex        =   11
         Top             =   1800
         Width           =   3135
      End
      Begin VB.CheckBox IconizeWhenRunATest 
         Caption         =   "Iconize when run a test or test session"
         Height          =   315
         Left            =   2280
         TabIndex        =   10
         Top             =   1440
         Width           =   3135
      End
      Begin VB.CheckBox DebugScriptEngineMode 
         Caption         =   "Debug Script Mode"
         Height          =   375
         Left            =   -72600
         TabIndex        =   7
         Top             =   1320
         Width           =   4575
      End
      Begin VB.CheckBox ShowScriptEngineWindow 
         Caption         =   "Show Script Engine Window"
         Height          =   375
         Left            =   -72600
         TabIndex        =   6
         Top             =   960
         Width           =   4575
      End
      Begin VB.TextBox ScriptingExecutable 
         Height          =   335
         Left            =   -72720
         TabIndex        =   5
         Text            =   "CScript.exe"
         Top             =   540
         Width           =   5415
      End
      Begin VB.CommandButton cmdTextEditor 
         Caption         =   "..."
         Height          =   335
         Left            =   7800
         TabIndex        =   4
         Top             =   550
         Width           =   335
      End
      Begin VB.TextBox editor 
         Height          =   335
         Left            =   2280
         TabIndex        =   3
         Top             =   540
         Width           =   5415
      End
      Begin VB.Label Label7 
         Caption         =   "Repository Web URL:"
         Height          =   375
         Left            =   -74820
         TabIndex        =   30
         Top             =   1980
         Width           =   2895
      End
      Begin VB.Label Label6 
         Caption         =   "Password:"
         Height          =   375
         Left            =   -74820
         TabIndex        =   28
         Top             =   1620
         Width           =   2895
      End
      Begin VB.Label Label5 
         Caption         =   "Login Name:"
         Height          =   375
         Left            =   -74820
         TabIndex        =   26
         Top             =   1260
         Width           =   2895
      End
      Begin VB.Label Label4 
         Caption         =   "Database:"
         Height          =   375
         Left            =   -74820
         TabIndex        =   24
         Top             =   900
         Width           =   2895
      End
      Begin VB.Label Label3 
         Caption         =   "Server:"
         Height          =   375
         Left            =   -74820
         TabIndex        =   22
         Top             =   540
         Width           =   2895
      End
      Begin VB.Label LabelEmail 
         Caption         =   "Email Address:"
         Height          =   255
         Left            =   720
         TabIndex        =   20
         Top             =   3000
         Width           =   1215
      End
      Begin VB.Label Label9 
         Caption         =   "Description TAB Size:"
         Height          =   375
         Left            =   240
         TabIndex        =   18
         Top             =   2520
         Width           =   2895
      End
      Begin VB.Label Label8 
         Caption         =   "Tree View Font:"
         Height          =   375
         Left            =   240
         TabIndex        =   16
         Top             =   2220
         Width           =   2895
      End
      Begin VB.Label Label11 
         Caption         =   "Ignore Paths:"
         Height          =   375
         Left            =   240
         TabIndex        =   13
         Top             =   960
         Width           =   2895
      End
      Begin VB.Label Label2 
         Caption         =   "VB Scripting Engine:"
         Height          =   375
         Left            =   -74880
         TabIndex        =   9
         Top             =   540
         Width           =   2895
      End
      Begin VB.Label Label1 
         Caption         =   "Text Editor:"
         Height          =   375
         Left            =   240
         TabIndex        =   8
         Top             =   600
         Width           =   2895
      End
   End
End
Attribute VB_Name = "frmOptions"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'************************************************************************************************
'File Name: Options.frm
'Author   : Frederic Torres
'Date     :
'Descriptions: Code for the options form of the test harness.  Options reads and writes to the
'testharness.ini file  and determines the behaviour of the test harness
'Modifications:  04/04 AR Took out the TestDatabase path Tab
'*************************************************************************************************


Option Explicit

Private m_booOK As Boolean

Private Sub cmdCancel_Click()

    On Error GoTo ErrMgr

    Hide

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmOptions", "cmdCancel_Click"
End Sub


Private Sub cmdOK_Click()

    On Error GoTo ErrMgr

    m_booOK = True
    Hide

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmOptions", "cmdOK_Click"
End Sub

Private Sub cmdTextEditor_Click()

    On Error GoTo ErrMgr

    Dim objTool     As New cTool
    Dim strEditor   As String
    
    strEditor = objTool.getUserOpenFile(cm, "Text Editor", "Program Files (*.exe)|*.exe", False)
    If (Len(strEditor)) Then
        editor.Text = strEditor
    End If
    

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmOptions", "cmdTextEditor_Click"
End Sub


Private Sub DebugScriptEngineMode_Click()

    On Error GoTo ErrMgr


    Dim strS As String
    
    strS = ScriptingExecutable.Text
    strS = Replace(strS, " /D", "")
    strS = Replace(strS, " /d", "")
    ScriptingExecutable.Text = strS
    If (DebugScriptEngineMode.Value = vbChecked) Then
        ScriptingExecutable.Text = ScriptingExecutable.Text & " /d"
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmOptions", "DebugScriptEngineMode_Click"
End Sub

Private Sub Form_Load()

    On Error GoTo ErrMgr

    m_booOK = False
    SSTab1.Tab = 0

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmOptions", "Form_Load"
End Sub

Public Function OpenDialog(objIniFile As cIniFile) As Boolean

    On Error GoTo ErrMgr


    objIniFile.FontSaveRestore "DescriptionFont", Me.FontInfo.Font, False
    
    objIniFile.getForm Me
    Me.Show vbModal
    
    If (m_booOK) Then
        objIniFile.setForm Me
        objIniFile.FontSaveRestore "DescriptionFont", Me.FontInfo.Font, True
        OpenDialog = True
    End If
    Unload Me
    Set frmOptions = Nothing
    

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmOptions", "OpenDialog"
End Function



Private Sub Label10_Click()

End Sub

Private Sub SSTab1_Click(PreviousTab As Integer)
'    If SSTab1.Tab = 4 Then
 '       MsgBox "This feature is not yet available"
  '      SSTab1.Tab = 1
   ' End If
End Sub


Private Sub cmdDescriptionFont_Click()
    GetFontName cm, "Font"

End Sub

Public Function GetFontName(CommonDialog1 As CommonDialog, Optional strTitle As String) As Boolean

    Dim t As New cTool
    
    On Error Resume Next
    
    CommonDialog1.CancelError = True
    
    If Len(strTitle) Then CommonDialog1.DialogTitle = strTitle
    
    Dim e As FontsConstants
    e = cdlCFScreenFonts Or cdlCFFixedPitchOnly Or cdlCFForceFontExist Or cdlCFANSIOnly
    e = cdlCFScreenFonts Or cdlCFForceFontExist Or cdlCFANSIOnly
    
    CommonDialog1.Flags = e
    
    CommonDialog1.FontBold = FontInfo.Font.Bold
    CommonDialog1.FontItalic = FontInfo.Font.Italic
    CommonDialog1.FontName = FontInfo.Font.Name
    CommonDialog1.FontSize = FontInfo.Font.Size
    CommonDialog1.Flags = e

    CommonDialog1.ShowFont
    
    If Err.Number = 0 Then
    
        FontInfo.Font.Bold = CommonDialog1.FontBold
        FontInfo.Font.Italic = CommonDialog1.FontItalic
        FontInfo.Font.Name = CommonDialog1.FontName
        FontInfo.Font.Size = CommonDialog1.FontSize
        GetFontName = True
        
    End If
End Function


