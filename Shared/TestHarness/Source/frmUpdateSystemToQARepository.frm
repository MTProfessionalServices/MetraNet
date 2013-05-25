VERSION 5.00
Begin VB.Form frmUpdateSystemToQARepository 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Caption"
   ClientHeight    =   1575
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   8190
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1575
   ScaleWidth      =   8190
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Height          =   1095
      Left            =   60
      TabIndex        =   3
      Top             =   -60
      Width           =   8115
      Begin VB.ComboBox Engineers 
         Height          =   315
         Left            =   2040
         Style           =   2  'Dropdown List
         TabIndex        =   4
         Top             =   420
         Width           =   5000
      End
      Begin VB.Label Label1 
         Caption         =   "&Name"
         Height          =   375
         Left            =   465
         TabIndex        =   0
         Top             =   420
         Width           =   1995
      End
   End
   Begin VB.CommandButton CancelButton 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   6960
      TabIndex        =   2
      Top             =   1140
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Height          =   375
      Left            =   5640
      TabIndex        =   1
      Top             =   1140
      Width           =   1215
   End
End
Attribute VB_Name = "frmUpdateSystemToQARepository"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Private m_booOK As Boolean

Public Function OpenDialog() As Boolean

    Dim strSessionName  As String
    Dim QARepository    As New CQARepository
    
    If Not QARepository.OpenRepository(g_objIniFile) Then
    
        ShowError TESTHARNESS_ERROR_7043, Me, "OpenDialog"
        Exit Function
    End If
    
    Me.Caption = PreProcess(TESTHARNESS_MESSAGE_7049)
    
    QARepository.PopulateEngineerComboBox Me.Engineers, ""
    
    OpenDialog = False
    
    Me.Show vbModal
    
    If m_booOK Then
    
        If MsgBox(PreProcess(TESTHARNESS_MESSAGE_7050, "NAME", Engineers.Text), vbQuestion) = vbYes Then
        
            If QARepository.DeleteTable("t_engineers", "id_engineer", Me.Engineers.itemData(Me.Engineers.ListIndex)) Then
            
                OpenDialog = True
            End If
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

    
    
    m_booOK = True
    Hide
End Sub



