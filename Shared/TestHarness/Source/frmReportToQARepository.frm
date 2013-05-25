VERSION 5.00
Begin VB.Form frmReportToQARepository 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Caption"
   ClientHeight    =   4590
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   8250
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4590
   ScaleWidth      =   8250
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Height          =   4095
      Left            =   60
      TabIndex        =   2
      Top             =   -60
      Width           =   8115
      Begin VB.ComboBox Build 
         Height          =   315
         Left            =   2295
         Style           =   2  'Dropdown List
         TabIndex        =   16
         Top             =   420
         Width           =   5000
      End
      Begin VB.ComboBox SystemName 
         Height          =   315
         Left            =   2295
         Style           =   2  'Dropdown List
         TabIndex        =   15
         Top             =   2400
         Width           =   5000
      End
      Begin VB.TextBox MetraNetVersion 
         Height          =   285
         Left            =   2295
         TabIndex        =   13
         Top             =   840
         Width           =   5000
      End
      Begin VB.TextBox Description 
         Height          =   960
         Left            =   2295
         MaxLength       =   255
         MultiLine       =   -1  'True
         TabIndex        =   11
         Top             =   2820
         Width           =   5000
      End
      Begin VB.TextBox FailedCases 
         Height          =   285
         Left            =   2295
         TabIndex        =   8
         Text            =   "0"
         Top             =   2040
         Width           =   5000
      End
      Begin VB.ComboBox Status 
         Height          =   315
         Left            =   2295
         Style           =   2  'Dropdown List
         TabIndex        =   7
         Top             =   1620
         Width           =   5000
      End
      Begin VB.ComboBox engineer 
         Height          =   315
         Left            =   2295
         Style           =   2  'Dropdown List
         TabIndex        =   5
         Top             =   1200
         Width           =   5000
      End
      Begin VB.Label Label7 
         Caption         =   "MetraNet Version"
         Height          =   375
         Left            =   495
         TabIndex        =   14
         Top             =   840
         Width           =   1995
      End
      Begin VB.Label Label6 
         Caption         =   "Description"
         Height          =   375
         Left            =   495
         TabIndex        =   12
         Top             =   2820
         Width           =   1995
      End
      Begin VB.Label Label5 
         Caption         =   "System Name"
         Height          =   375
         Left            =   495
         TabIndex        =   10
         Top             =   2400
         Width           =   1995
      End
      Begin VB.Label Label4 
         Caption         =   "Failed Cases"
         Height          =   375
         Left            =   495
         TabIndex        =   9
         Top             =   2040
         Width           =   1995
      End
      Begin VB.Label Label3 
         Caption         =   "Status"
         Height          =   375
         Left            =   495
         TabIndex        =   6
         Top             =   1560
         Width           =   1995
      End
      Begin VB.Label Label2 
         Caption         =   "Engineer"
         Height          =   375
         Left            =   495
         TabIndex        =   4
         Top             =   1200
         Width           =   1995
      End
      Begin VB.Label Label1 
         Caption         =   "MetraNet Build"
         Height          =   375
         Left            =   495
         TabIndex        =   3
         Top             =   420
         Width           =   1995
      End
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   6960
      TabIndex        =   1
      Top             =   4140
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   5640
      TabIndex        =   0
      Top             =   4140
      Width           =   1215
   End
End
Attribute VB_Name = "frmReportToQARepository"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_booOK As Boolean

Public Function OpenDialog(objSession As CTDBItem) As Boolean

    Dim strSessionName                      As String
    Dim QARepository                        As New CQARepository
    Dim strLastPatchAppliedOrBuildNumber    As String
    Dim strError                            As String
    
    On Error GoTo ErrMgr
    
    strError = "1"
        
    If Not QARepository.OpenRepository(g_objIniFile) Then
    
        ShowError TESTHARNESS_ERROR_7043, Me, "OpenDialog"
        Exit Function
    End If
    
    strError = "2"
    
    strLastPatchAppliedOrBuildNumber = QARepository.GetMetraNetLastPatch()
    
    
    strError = "3"
    
    If Len(strLastPatchAppliedOrBuildNumber) = 0 Then
    
        strError = "4"
        strLastPatchAppliedOrBuildNumber = QARepository.GetMetraNetBuild()
    End If
    
    strError = "5"
    
    QARepository.PopulateBuildComboBox Me.Build, strLastPatchAppliedOrBuildNumber
    
    strError = "6"
    
    QARepository.PopulateEngineerComboBox Me.engineer, AppOptions("QARepositoryDefaultEngineer")
    
    strError = "7"
    
    QARepository.PopulateSystemNameComboBox Me.SystemName, CreateObject("MTVBLIB.CWindows").ComputerName()
    
    strError = "8"
        
    Me.Status.AddItem "Passed"
    Me.Status.AddItem "Failed"
    Me.Status.ListIndex = 0
    
    strError = "9"
    
    Me.MetraNetVersion.Text = QARepository.GetMetraNetVersion()
    
    strError = "10"
    
    'Me.Description = "MetraNetVersion:" & QARepository.GetMetraNetVersion() & vbNewLine & "build:" & QARepository.GetMetraNetBuild() & vbNewLine & "patches-list:" & QARepository.GetMetraNetPatchList()
    
    strError = "11"
    
    strSessionName = Mid(objSession.Name, 1, Len(objSession.Name) - Len(TESTHARNESS_TEST_SESSION_FILE_EXTENSION) - 1)
    
    strError = "12"

    Me.Caption = PreProcess(TESTHARNESS_MESSAGE_7042, "S", strSessionName)
    
    strError = "13"
    
    Me.Show vbModal
    
    If m_booOK Then
        
        If QARepository.IsRegister(strSessionName) Then
        
            If QARepository.ReportToQARepository(strSessionName, Me.Build.Text, Me.engineer.Text, Me.FailedCases.Text, Me.Status, Me.Description, Me.SystemName) Then
            
                AppOptions("QARepositoryDefaultEngineer") = Me.engineer.Text
                OpenDialog = True
            Else
                ShowError TESTHARNESS_ERROR_7044, Me, "OpenDialog"
            End If
        Else
            ShowError TESTHARNESS_ERROR_7047, Me, "OpenDialog"
        End If
    End If
    Unload Me
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString() & " ErrorInfo:" & strError, Me, "OpenDialog"
End Function

Private Sub CancelButton_Click()
    Hide
End Sub

Private Sub Form_Load()
m_booOK = False
End Sub

Private Sub OKButton_Click()

    If Len(Me.Description.Text) = 0 Then

        ShowError TESTHARNESS_ERROR_7045, "me", "OKButton_Click"
        Exit Sub
    End If
    
    If Len(Me.Build.Text) = 0 Then

        ShowError TESTHARNESS_ERROR_7048, "me", "OKButton_Click"
        Exit Sub
    End If
        
    
    m_booOK = True
    Hide
End Sub



