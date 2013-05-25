VERSION 5.00
Begin VB.Form frmRegisterSystemNameToQARepository 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Caption"
   ClientHeight    =   2550
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   8190
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2550
   ScaleWidth      =   8190
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Height          =   2055
      Left            =   60
      TabIndex        =   9
      Top             =   -60
      Width           =   8115
      Begin VB.CheckBox HyperThread 
         Caption         =   "Hyper Threaded"
         Height          =   375
         Left            =   2280
         TabIndex        =   6
         Top             =   1560
         Width           =   2775
      End
      Begin VB.TextBox RAM 
         Height          =   285
         Left            =   2000
         TabIndex        =   3
         Top             =   780
         Width           =   5000
      End
      Begin VB.TextBox PhysicalCPU 
         Height          =   285
         Left            =   2000
         TabIndex        =   5
         Text            =   "1"
         Top             =   1140
         Width           =   5000
      End
      Begin VB.TextBox CPU 
         Height          =   285
         Left            =   2000
         TabIndex        =   1
         Top             =   420
         Width           =   5000
      End
      Begin VB.Label Label7 
         Caption         =   "&RAM"
         Height          =   375
         Left            =   480
         TabIndex        =   2
         Top             =   780
         Width           =   1995
      End
      Begin VB.Label Label4 
         Caption         =   "&Physical CPU"
         Height          =   375
         Left            =   480
         TabIndex        =   4
         Top             =   1200
         Width           =   1995
      End
      Begin VB.Label Label1 
         Caption         =   "&CPU"
         Height          =   375
         Left            =   465
         TabIndex        =   0
         Top             =   420
         Width           =   1995
      End
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   6960
      TabIndex        =   8
      Top             =   2100
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   5640
      TabIndex        =   7
      Top             =   2100
      Width           =   1215
   End
End
Attribute VB_Name = "frmRegisterSystemNameToQARepository"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Private m_booOK As Boolean

Public Function OpenDialog(strSystemName As String, booUpdate As Boolean) As Boolean

    Dim strSessionName  As String
    Dim QARepository    As New CQARepository
    Dim r               As Variant
    
    If Not QARepository.OpenRepository(g_objIniFile) Then
    
        ShowError TESTHARNESS_ERROR_7043, Me, "OpenDialog"
        Exit Function
    End If
    
    If (booUpdate) Then
    
        
        Set r = QARepository.GetSystem(strSystemName)
        If IsValidObject(r) Then
            Me.CPU.Text = r.Fields("tx_CPU_speed").Value
            Me.RAM.Text = r.Fields("tx_RAM").Value
            Me.PhysicalCPU.Text = r.Fields("ct_physical_CPU").Value
            Me.HyperThread.Value = Abs(r.Fields("is_hyperthreaded").Value = "Y")
            
            Me.Caption = PreProcess(TESTHARNESS_MESSAGE_7051, "SYSTEM", strSystemName)
        Else
        End If
        
                
    Else
        Me.Caption = PreProcess(TESTHARNESS_MESSAGE_7045, "SYSTEM", strSystemName)
    End If
    
    OpenDialog = False
    
    Me.Show vbModal
    
    If m_booOK Then
    
        If QARepository.RegisterSystem(booUpdate, strSystemName, Me.CPU.Text, Me.RAM.Text, Me.PhysicalCPU.Text, IIf(Me.HyperThread.Value = vbChecked, "Y", "N")) Then
        
            OpenDialog = True
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



