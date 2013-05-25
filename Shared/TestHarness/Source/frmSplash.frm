VERSION 5.00
Begin VB.Form frmSplash 
   BorderStyle     =   0  'None
   ClientHeight    =   5820
   ClientLeft      =   210
   ClientTop       =   1365
   ClientWidth     =   11460
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   Icon            =   "frmSplash.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5820
   ScaleWidth      =   11460
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   3390
      Left            =   480
      Picture         =   "frmSplash.frx":000C
      ScaleHeight     =   3360
      ScaleWidth      =   6780
      TabIndex        =   0
      Top             =   240
      Width           =   6810
      Begin VB.Label lblTestHarnessVersion 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   ".0"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   11.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000007&
         Height          =   255
         Left            =   4200
         TabIndex        =   3
         Top             =   2040
         Width           =   180
      End
      Begin VB.Label lblMessage 
         BackStyle       =   0  'Transparent
         BorderStyle     =   1  'Fixed Single
         Caption         =   "aaaaa"
         Height          =   195
         Left            =   60
         TabIndex        =   2
         Top             =   2280
         Width           =   6615
      End
      Begin VB.Label lblProductName 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   ".0"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   11.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000007&
         Height          =   255
         Left            =   4200
         TabIndex        =   1
         Top             =   1680
         Width           =   180
      End
   End
End
Attribute VB_Name = "frmSplash"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Private Sub Form_KeyPress(KeyAscii As Integer)

    On Error GoTo ErrMgr

    Unload Me

    Exit Sub
ErrMgr:
        
End Sub

Private Sub Form_Load()
    Dim QARepository As New CQARepository
    On Error GoTo ErrMgr
    Dim objTool As New cTool
    
    lblProductName.Caption = "MetraNet " & QARepository.GetMetraNetVersion()
    lblTestHarnessVersion.Caption = "TestHarness " & App.Major & "." & App.Minor & "." & App.Revision
    
    Picture1.Left = 0
    Picture1.Top = 0
    Me.Width = Picture1.Width
    Me.Height = Picture1.Height
    
    lblProductName.BorderStyle = 0
    Me.lblMessage.BorderStyle = 0
    
    
    Dim objWinApi As New cWindows
    
'    objWinApi.SetWinTopMost Me, True
    
    
    lblMessage.Caption = "Hi " & objWinApi.UserName


    Exit Sub
ErrMgr:
        
End Sub

Private Sub Frame1_Click()

    On Error GoTo ErrMgr

    Unload Me

    Exit Sub
ErrMgr:
        
End Sub

Private Sub lblCompany_Click()

    On Error GoTo ErrMgr

Frame1_Click

    Exit Sub
ErrMgr:
        
End Sub

Private Sub lblProductName_Click()

    On Error GoTo ErrMgr

Frame1_Click

    Exit Sub
ErrMgr:
        
End Sub

Private Sub Picture1_Click()

    On Error GoTo ErrMgr

Frame1_Click

    Exit Sub
ErrMgr:
        
End Sub

Public Function OpenWindow() As Boolean

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler

    Load Me
    
    Me.Show vbModal
    Unload Me

    Exit Function ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Function



Public Function About()
    Load Me
    lblMessage.Caption = TESTHARNESS_MESSAGE_7034
    Me.Show vbModal
    Unload Me
End Function
