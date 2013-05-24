VERSION 5.00
Begin VB.Form frmLicense 
   AutoRedraw      =   -1  'True
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "#"
   ClientHeight    =   5025
   ClientLeft      =   540
   ClientTop       =   6000
   ClientWidth     =   7110
   ClipControls    =   0   'False
   HasDC           =   0   'False
   Icon            =   "frmLicense.frx":0000
   MaxButton       =   0   'False
   MinButton       =   0   'False
   NegotiateMenus  =   0   'False
   ScaleHeight     =   5025
   ScaleWidth      =   7110
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtmessage 
      BackColor       =   &H80000000&
      Height          =   3795
      Left            =   60
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   2
      Top             =   480
      Width           =   6975
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   5580
      TabIndex        =   1
      Top             =   4560
      Width           =   1395
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "I Accept"
      Default         =   -1  'True
      Height          =   375
      Left            =   4140
      TabIndex        =   0
      Top             =   4560
      Width           =   1395
   End
   Begin VB.Label lblPleaseReadAgreement 
      Height          =   435
      Left            =   60
      TabIndex        =   3
      Top             =   0
      Width           =   6975
   End
End
Attribute VB_Name = "frmLicense"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdExit_Click()
    
    ExitSetup Me, gintRET_EXIT
End Sub

Private Sub cmdOK_Click()
    Unload Me
End Sub



Private Sub Form_Load()

    Me.Caption = CUST_MSG_0005
    
    SetObjectsPos Me, "" ' CUST_MSG_0006
    lblPleaseReadAgreement.Caption = CUST_MSG_0010
    
    SetLicenseText Me.txtmessage
    txtmessage.BorderStyle = 1
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    HandleFormQueryUnload UnloadMode, Cancel, Me
End Sub

Private Sub rbAgree_Click(Index As Integer)
    cmdOK.Enabled = CBool(Index = 0)
End Sub


