VERSION 5.00
Begin VB.Form frmMsgbox 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Caption"
   ClientHeight    =   1890
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   9390
   Icon            =   "frmMsgBox.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1890
   ScaleWidth      =   9390
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Timer Timer2 
      Interval        =   1000
      Left            =   9480
      Top             =   540
   End
   Begin VB.Timer Timer1 
      Interval        =   15000
      Left            =   9540
      Top             =   1020
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   4440
      TabIndex        =   0
      Top             =   1440
      Width           =   1215
   End
   Begin VB.Label label 
      Height          =   1275
      Left            =   60
      TabIndex        =   1
      Top             =   0
      Width           =   9255
   End
End
Attribute VB_Name = "frmMsgbox"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_strTitle As String

Public Function OpenDialog(ByVal strMessage As String, Optional ByVal strTitle As String) As Boolean

    Timer1.Enabled = True
    Timer2.Enabled = True
    
    m_strTitle = IIf(Len(strTitle), strTitle, App.EXEName)
    Me.Caption = m_strTitle
    Me.label.Caption = strMessage
        
    Me.Show vbModal
    Timer1.Enabled = False
    Timer2.Enabled = False
    Unload Me
End Function

Private Sub Form_Load()
    Screen.MousePointer = 0
End Sub

Private Sub OKButton_Click()
    Hide
End Sub

Private Sub Timer1_Timer()
    OKButton_Click
End Sub

Private Sub Timer2_Timer()
    Me.Caption = m_strTitle & " " & Now
End Sub
