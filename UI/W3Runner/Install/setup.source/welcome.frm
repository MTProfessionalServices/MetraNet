VERSION 5.00
Begin VB.Form frmWelcome 
   AutoRedraw      =   -1  'True
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "#"
   ClientHeight    =   5025
   ClientLeft      =   540
   ClientTop       =   6000
   ClientWidth     =   7110
   ClipControls    =   0   'False
   HasDC           =   0   'False
   Icon            =   "welcome.frx":0000
   MaxButton       =   0   'False
   MinButton       =   0   'False
   NegotiateMenus  =   0   'False
   ScaleHeight     =   5025
   ScaleWidth      =   7110
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtmessage 
      BackColor       =   &H80000000&
      Height          =   3975
      Left            =   2940
      MultiLine       =   -1  'True
      TabIndex        =   3
      Top             =   120
      Width           =   4035
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   5580
      TabIndex        =   2
      Top             =   4560
      Width           =   1395
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&Next >"
      Default         =   -1  'True
      Height          =   375
      Left            =   4140
      TabIndex        =   1
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
      Picture         =   "welcome.frx":0442
      ScaleHeight     =   2505
      ScaleWidth      =   2790
      TabIndex        =   0
      Top             =   120
      Width           =   2790
   End
End
Attribute VB_Name = "frmWelcome"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdExit_Click()
    ExitSetup Me, gintRET_EXIT
End Sub

Private Sub cmdOK_Click()
    Hide
    
    
        frmLicense.Show vbModal
    
    Unload Me
End Sub

Private Sub Form_Load()

'    MsgBox "App.Path=" & App.Path
'    MsgBox "Command=" & Command
    
    Me.Caption = ResolveResString(resWELCOME, gstrPIPE1, gstrAppName)
    
    SetObjectsPos Me, CUST_MSG_0002
    
        
    
    
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    HandleFormQueryUnload UnloadMode, Cancel, Me
End Sub
