VERSION 5.00
Begin VB.Form frmSplash 
   BorderStyle     =   0  'None
   ClientHeight    =   5985
   ClientLeft      =   210
   ClientTop       =   1365
   ClientWidth     =   10185
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   Icon            =   "frmSplash.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5985
   ScaleWidth      =   10185
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   3165
      Left            =   240
      Picture         =   "frmSplash.frx":000C
      ScaleHeight     =   3165
      ScaleWidth      =   7350
      TabIndex        =   0
      Top             =   60
      Width           =   7350
      Begin VB.Label lblCopyRight 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BorderStyle     =   1  'Fixed Single
         Caption         =   "Label1"
         ForeColor       =   &H00FFFFFF&
         Height          =   195
         Left            =   2940
         TabIndex        =   4
         Top             =   2880
         Visible         =   0   'False
         Width           =   4335
      End
      Begin VB.Label lblRegister 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BorderStyle     =   1  'Fixed Single
         Caption         =   "Register Info"
         ForeColor       =   &H00FFFFFF&
         Height          =   795
         Left            =   2940
         TabIndex        =   3
         Top             =   1800
         Width           =   4335
      End
      Begin VB.Label lblMessage 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BorderStyle     =   1  'Fixed Single
         Caption         =   "Label1"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   2940
         TabIndex        =   2
         Top             =   2580
         Visible         =   0   'False
         Width           =   4395
      End
      Begin VB.Label lblProductName 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "2.0"
         BeginProperty Font 
            Name            =   "Microsoft Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   300
         Left            =   4905
         TabIndex        =   1
         Top             =   1260
         Width           =   330
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

    On Error GoTo errmgr

    Unload Me

    Exit Sub
errmgr:
        
End Sub

Private Sub Form_Load()

    On Error GoTo errmgr

    Dim objTool As New cTool
    
    #If RECORD_MODE_ Then
        lblProductName.Caption = GetW3RunnerVersion(True)
    #Else
        lblProductName.Caption = GetW3RunnerVersion(True) & " RT "
    #End If
    
    
    lblRegister.BorderStyle = 0
    lblCopyRight.BorderStyle = 0
    lblMessage.BorderStyle = 0
    
    lblRegister.Caption = ""
    lblCopyRight.Caption = ""
    
    lblRegister.Caption = IIf(g_static_booRegistered, W3RUNNER_MSG_07026 & vbNewLine & g_static_strRegistrationInfo, W3RUNNER_MSG_07025)
    lblRegister.Caption = PreProcess(lblRegister.Caption, "CRLF", vbNewLine)
    lblCopyRight.Caption = W3RUNNER_MSG_07029
    lblCopyRight.Visible = True
    
    Picture1.Left = 0
    Picture1.Top = 0
    Me.Width = Picture1.Width
    Me.Height = Picture1.Height
    
    
    
    
'    labelShadow.Caption = lblProductName.Caption
 '   labelShadow.Left = lblProductName.Left + 15
  '  labelShadow.Top = lblProductName.Top + 15
   ' labelShadow.Width = lblProductName.Width
    'labelShadow.Height = lblProductName.Height
    
    Dim objWinApi As New cWindows
    
    objWinApi.SetWinTopMost Me, True
    


    Exit Sub
errmgr:
        
End Sub

Private Sub Frame1_Click()

    On Error GoTo errmgr

    Unload Me

    Exit Sub
errmgr:
        
End Sub

Private Sub lblCompany_Click()

    On Error GoTo errmgr

Frame1_Click

    Exit Sub
errmgr:
        
End Sub

Private Sub lblMessage_Click()
    Picture1_Click
End Sub

Private Sub lblProductName_Click()

    On Error GoTo errmgr

Frame1_Click

    Exit Sub
errmgr:
        
End Sub

Private Sub lblRegister_Click()
Picture1_Click
End Sub

Private Sub Picture1_Click()

    On Error GoTo errmgr

Frame1_Click

    Exit Sub
errmgr:
        
End Sub

Public Function OpenWindow() As Boolean

    On Error GoTo errmgr ' @VbAddCode.ErrorHandler

    Load Me
    
    Me.Show vbModal
    Unload Me

    Exit Function ' @VbAddCode.ErrorHandler
errmgr:     ' @VbAddCode.ErrorHandler

End Function

Public Property Let Message(ByVal vNewValue As String)
    If CanShowSplashWindow() Then
        Me.lblMessage.Visible = True
        Me.lblMessage.Caption = vNewValue
        Me.lblMessage.Refresh
        'Sleep 150
    End If
End Property

Private Sub Picture1_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
    If IsInArea(x / 15, Y / 15) And (Shift And vbShiftMask) = vbShiftMask Then
        MsgBox PreProcess(W3RUNNER_MSG_07046, "CRLF", vbNewLine)
    End If
End Sub

Private Function IsInArea(x As Single, Y As Single) As Boolean
    IsInArea = (x > 21) And (Y > 185) And (x < 161) And (Y < 198)
End Function
