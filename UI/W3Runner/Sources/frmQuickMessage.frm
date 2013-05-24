VERSION 5.00
Begin VB.Form frmQuickMessage 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Dialog Caption"
   ClientHeight    =   1770
   ClientLeft      =   2760
   ClientTop       =   3705
   ClientWidth     =   5865
   Icon            =   "frmQuickMessage.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1770
   ScaleWidth      =   5865
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Height          =   135
      Left            =   60
      TabIndex        =   3
      Top             =   1140
      Width           =   5715
   End
   Begin VB.CheckBox DoNotShow 
      Caption         =   "Do not show the message"
      Height          =   255
      Left            =   60
      TabIndex        =   2
      Top             =   1440
      Width           =   2595
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   5160
      TabIndex        =   0
      Top             =   1380
      Width           =   675
   End
   Begin VB.Label Label 
      Height          =   1035
      Left            =   60
      TabIndex        =   1
      Top             =   60
      Width           =   5775
      WordWrap        =   -1  'True
   End
End
Attribute VB_Name = "frmQuickMessage"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit


Private Function ShowQuickMessage(strID) As Boolean
     ShowQuickMessage = Not CBool(InStr(AppOptions("QuickMessage"), strID))
End Function

Private Function DoNotShowQuickMessage(strID) As Boolean

    Dim strText As String
    
    strText = AppOptions("QuickMessage") & "(" & strID & ")"
    AppOptions("QuickMessage") = strText
    
    DoNotShowQuickMessage = True
End Function

Public Function OpenDialog(strMessage As String, strID As String) As Boolean
    
    If ShowQuickMessage(strID) Then
    
        Screen.MousePointer = 0
    
        Me.DoNotShow.Value = vbUnchecked
        Me.Label.Caption = strMessage
        Me.Show vbModal
        If Abs((CBool(Me.DoNotShow.Value))) Then
            DoNotShowQuickMessage strID
        End If
        Unload Me
    End If
End Function

Private Sub Form_Load()
    Caption = W3RUNNER_MSG_07036
    DoNotShow.Caption = W3RUNNER_MSG_07037
    
    Dim w As New cWindows
    w.SetWinTopMost Me, True
End Sub

Private Sub OKButton_Click()
    
    Hide
End Sub
