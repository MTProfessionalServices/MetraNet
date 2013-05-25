VERSION 5.00
Begin VB.Form frmRegisterToQARepository 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Caption"
   ClientHeight    =   3900
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   8145
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3900
   ScaleWidth      =   8145
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Height          =   3375
      Left            =   60
      TabIndex        =   2
      Top             =   -60
      Width           =   7995
      Begin VB.ComboBox TestMode 
         Height          =   315
         Left            =   2340
         Style           =   2  'Dropdown List
         TabIndex        =   10
         Top             =   1020
         Width           =   5000
      End
      Begin VB.TextBox Description 
         Height          =   960
         Left            =   2460
         MaxLength       =   255
         MultiLine       =   -1  'True
         TabIndex        =   7
         Top             =   1680
         Width           =   5000
      End
      Begin VB.TextBox TestCases 
         Height          =   285
         Left            =   2355
         TabIndex        =   5
         Text            =   "0"
         Top             =   660
         Width           =   5000
      End
      Begin VB.ComboBox engineer 
         Height          =   315
         Left            =   2355
         Style           =   2  'Dropdown List
         TabIndex        =   4
         Top             =   300
         Width           =   5000
      End
      Begin VB.Label Label1 
         Caption         =   "Test Mode"
         Height          =   375
         Left            =   540
         TabIndex        =   9
         Top             =   960
         Width           =   1995
      End
      Begin VB.Label Label6 
         Caption         =   "Description"
         Height          =   375
         Left            =   540
         TabIndex        =   8
         Top             =   1680
         Width           =   1995
      End
      Begin VB.Label Label4 
         Caption         =   "Test Cases"
         Height          =   375
         Left            =   540
         TabIndex        =   6
         Top             =   660
         Width           =   1995
      End
      Begin VB.Label Label2 
         Caption         =   "Engineer"
         Height          =   375
         Left            =   525
         TabIndex        =   3
         Top             =   300
         Width           =   1995
      End
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   6840
      TabIndex        =   1
      Top             =   3480
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   5520
      TabIndex        =   0
      Top             =   3480
      Width           =   1215
   End
End
Attribute VB_Name = "frmRegisterToQARepository"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Private m_booOK As Boolean

Public Function OpenDialog(objSession As CTDBItem) As Boolean

    Dim strSessionName  As String
    Dim QARepository    As New CQARepository
    
    If Not QARepository.OpenRepository(g_objIniFile) Then
        
        ShowError TESTHARNESS_ERROR_7043, Me, "OpenDialog"
        Exit Function
    End If
    
    strSessionName = Mid(objSession.Name, 1, Len(objSession.Name) - Len(TESTHARNESS_TEST_SESSION_FILE_EXTENSION) - 1)
    
    
    If QARepository.IsRegister(strSessionName) Then
    
        ShowError TESTHARNESS_ERROR_7046, Me, "OpenDialog"
        Exit Function
    End If
    
    QARepository.PopulateEngineerComboBox Me.engineer
    QARepository.PopulateTestModeComboBox Me.TestMode
    
    Me.Caption = PreProcess(TESTHARNESS_MESSAGE_7043, "S", strSessionName)
    
    Me.Show vbModal
    
    If m_booOK Then
    
        If QARepository.RegisterInQARepository(strSessionName, Me.engineer.Text, Me.TestCases.Text, Me.Description, Me.TestMode.Text) Then
        
            OpenDialog = True
        Else
        
            ShowError TESTHARNESS_ERROR_7044, Me, "OpenDialog"
        End If
    
    End If
    Unload Me
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
    
    m_booOK = True
    Hide
End Sub


