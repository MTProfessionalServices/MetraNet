VERSION 5.00
Begin VB.Form frmFind 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Found Dialog"
   ClientHeight    =   5160
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   8550
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5160
   ScaleWidth      =   8550
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.ListBox ListID 
      Height          =   450
      Left            =   8280
      TabIndex        =   4
      Top             =   2520
      Visible         =   0   'False
      Width           =   1455
   End
   Begin VB.Frame Frame1 
      Height          =   4335
      Left            =   120
      TabIndex        =   2
      Top             =   120
      Width           =   8295
      Begin VB.ListBox List1 
         Height          =   3765
         Left            =   120
         TabIndex        =   3
         Top             =   240
         Width           =   8055
      End
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Enabled         =   0   'False
      Height          =   375
      Left            =   5880
      TabIndex        =   1
      Top             =   4680
      Width           =   1215
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   7200
      TabIndex        =   0
      Top             =   4680
      Width           =   1215
   End
   Begin VB.Label lblMatch 
      Caption         =   "lblMatch"
      Height          =   375
      Left            =   120
      TabIndex        =   5
      Top             =   4680
      Width           =   5415
   End
End
Attribute VB_Name = "frmFind"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_booOK As Boolean

Public Function OpenDialog(strQuery As String, List As CVariables) As String

    Dim v As CVariable
    
    m_booOK = False
    
    For Each v In List
    
        List1.AddItem v.Name
        ListID.AddItem v.Value
    Next
    
    lblMatch.Caption = List1.ListCount & " Match(s) for query : " & strQuery
    
    Me.Show vbModal
    If (m_booOK) Then
        OpenDialog = ListID.List(List1.ListIndex)
    End If
    Unload Me
    
End Function

Private Sub CancelButton_Click()
    Hide
End Sub

Private Sub List1_Click()
    OKButton.Enabled = True
End Sub

Private Sub List1_DblClick()
    OKButton_Click
End Sub

Private Sub OKButton_Click()
    m_booOK = True
    Hide
End Sub
