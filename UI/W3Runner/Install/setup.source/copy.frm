VERSION 5.00
Begin VB.Form frmCopy 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "#"
   ClientHeight    =   5025
   ClientLeft      =   870
   ClientTop       =   1530
   ClientWidth     =   7110
   ClipControls    =   0   'False
   HasDC           =   0   'False
   Icon            =   "copy.frx":0000
   MaxButton       =   0   'False
   MinButton       =   0   'False
   NegotiateMenus  =   0   'False
   ScaleHeight     =   5025
   ScaleWidth      =   7110
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdOK 
      Caption         =   "&Next >"
      Default         =   -1  'True
      Enabled         =   0   'False
      Height          =   375
      Left            =   4140
      TabIndex        =   6
      Top             =   4560
      Width           =   1395
   End
   Begin VB.PictureBox Picture1 
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   2505
      Left            =   60
      ScaleHeight     =   2505
      ScaleWidth      =   2790
      TabIndex        =   5
      Top             =   120
      Width           =   2790
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   5580
      TabIndex        =   4
      Top             =   4560
      Width           =   1395
   End
   Begin VB.TextBox txtmessage 
      BackColor       =   &H80000000&
      Height          =   2535
      Left            =   2940
      MultiLine       =   -1  'True
      TabIndex        =   3
      Top             =   120
      Width           =   4035
   End
   Begin VB.PictureBox picStatus 
      AutoRedraw      =   -1  'True
      ClipControls    =   0   'False
      FillColor       =   &H00FF0000&
      Height          =   435
      Left            =   705
      ScaleHeight     =   375
      ScaleWidth      =   5535
      TabIndex        =   2
      TabStop         =   0   'False
      Top             =   3525
      Width           =   5592
   End
   Begin VB.Label lblDestFile 
      Caption         =   "*"
      Height          =   195
      Left            =   705
      TabIndex        =   0
      Top             =   3120
      Width           =   5640
   End
   Begin VB.Label lblCopy 
      AutoSize        =   -1  'True
      Caption         =   "#"
      Height          =   195
      Left            =   885
      TabIndex        =   1
      Top             =   2460
      Width           =   105
   End
End
Attribute VB_Name = "frmCopy"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdExit_Click()
    ExitSetup Me, gintRET_EXIT
End Sub

Private Sub Form_Load()
    SetFormFont Me
    cmdExit.Caption = ResolveResString(resBTNCANCEL)
    lblCopy.Caption = ResolveResString(resLBLDESTFILE)
    lblDestFile.Caption = vbNullString
    Me.Caption = gstrTitle
    
    SetObjectsPos Me, CUST_MSG_0004
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    HandleFormQueryUnload UnloadMode, Cancel, Me
End Sub
Private Sub Form_Paint()
    Draw3DLine Me
End Sub
