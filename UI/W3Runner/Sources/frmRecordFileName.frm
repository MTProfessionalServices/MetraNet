VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form frmRecordFileName 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Record File Name"
   ClientHeight    =   1425
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   7785
   Icon            =   "frmRecordFileName.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1425
   ScaleWidth      =   7785
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin MSComDlg.CommonDialog cm 
      Left            =   6300
      Top             =   960
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.CheckBox chkOverWrite 
      Caption         =   "Overwrite"
      Height          =   195
      Left            =   1800
      TabIndex        =   3
      Top             =   600
      Width           =   2535
   End
   Begin VB.CommandButton butSetEditor 
      Caption         =   "..."
      Height          =   315
      Left            =   7320
      TabIndex        =   2
      Top             =   120
      Width           =   375
   End
   Begin VB.TextBox txtRecordFileName 
      Height          =   315
      Left            =   1740
      TabIndex        =   1
      Top             =   120
      Width           =   5535
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   4080
      TabIndex        =   5
      Top             =   960
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   2820
      TabIndex        =   4
      Top             =   960
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Record File Name :"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   180
      Width           =   1515
   End
End
Attribute VB_Name = "frmRecordFileName"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_booOK As Boolean

Private Sub butSetEditor_Click()
   Dim t As New cTool
    Dim s As String
    
    s = t.getUserOpenFile(cm, W3RUNNER_MSG_07050, W3RUNNER_MSG_07033, True, App.path)
    If (Len(s)) Then
        Me.txtRecordFileName.Text = s
    End If
End Sub

Private Sub CancelButton_Click()
    Hide
End Sub

Private Sub Form_Load()
    m_booOK = False
    Me.Caption = W3RUNNER_MSG_07050
    Me.txtRecordFileName.Text = AppOptions("RecordFileName")
    txtRecordFileName_Change
End Sub

Private Sub OKButton_Click()
    m_booOK = True
    Hide
End Sub

Public Function OpenDialog() As Boolean

    Dim objTextFile         As New cTextFile
    
    Load Me
    
    Me.Show vbModal
    If m_booOK Then
    
        OpenDialog = True
        RecordFileName = Me.txtRecordFileName.Text
        If chkOverWrite.Value Then
        
            objTextFile.LogFile RecordFileName, GetRecordFileCommentHeader(), True
        End If
        AppOptions("RecordFileName") = Me.txtRecordFileName.Text
    End If
    Unload Me
End Function

Private Sub txtRecordFileName_Change()
    OKButton.Enabled = Len(txtRecordFileName.Text)
End Sub
