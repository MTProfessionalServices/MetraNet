VERSION 5.00
Begin VB.Form frmDataBaseAccessLogin 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Login"
   ClientHeight    =   3060
   ClientLeft      =   2835
   ClientTop       =   3480
   ClientWidth     =   3780
   Icon            =   "frmDataBaseAccessLogin.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1807.949
   ScaleMode       =   0  'User
   ScaleWidth      =   3549.215
   StartUpPosition =   2  'CenterScreen
   Begin VB.CheckBox chkTrustedConnexion 
      Caption         =   "Trusted Connexion"
      Height          =   255
      Left            =   1320
      TabIndex        =   10
      Top             =   2160
      Width           =   1695
   End
   Begin VB.TextBox txtDatabase 
      Height          =   345
      Left            =   1305
      TabIndex        =   8
      Top             =   1560
      Width           =   2325
   End
   Begin VB.TextBox txtServerName 
      Height          =   345
      Left            =   1305
      TabIndex        =   6
      Top             =   1080
      Width           =   2325
   End
   Begin VB.TextBox txtUserName 
      Height          =   345
      Left            =   1290
      TabIndex        =   1
      Top             =   135
      Width           =   2325
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   390
      Left            =   735
      TabIndex        =   4
      Top             =   2580
      Width           =   1140
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   390
      Left            =   1920
      TabIndex        =   5
      Top             =   2580
      Width           =   1140
   End
   Begin VB.TextBox txtPassword 
      Height          =   345
      IMEMode         =   3  'DISABLE
      Left            =   1290
      PasswordChar    =   "*"
      TabIndex        =   3
      Top             =   600
      Width           =   2325
   End
   Begin VB.Label lblLabels 
      Caption         =   "Database"
      Height          =   270
      Index           =   3
      Left            =   120
      TabIndex        =   9
      Top             =   1560
      Width           =   1080
   End
   Begin VB.Label lblLabels 
      Caption         =   "Server"
      Height          =   270
      Index           =   2
      Left            =   120
      TabIndex        =   7
      Top             =   1080
      Width           =   1080
   End
   Begin VB.Label lblLabels 
      Caption         =   "&User Name"
      Height          =   270
      Index           =   0
      Left            =   105
      TabIndex        =   0
      Top             =   150
      Width           =   1080
   End
   Begin VB.Label lblLabels 
      Caption         =   "&Password:"
      Height          =   270
      Index           =   1
      Left            =   105
      TabIndex        =   2
      Top             =   540
      Width           =   1080
   End
End
Attribute VB_Name = "frmDataBaseAccessLogin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Public booOK As Boolean

Private IniFile As New cIniFile

Private Sub cmdCancel_Click()
    Me.Hide
End Sub

Private Sub cmdOK_Click()
    booOK = True
    Hide
End Sub

Public Function Run(strUserName As String, strPassWord As String, strServerName As String, strDataBase As String, booTrustedConnexion As Boolean, Optional strIniFileName As String) As Boolean

    Dim booIniFileOpen  As Boolean
    
    Load Me
    
    If (Len(strIniFileName) = 0) Then
        IniFile.InitAutomatic App
        strIniFileName = IniFile.iniFileName
    End If
                
    If (IniFile.Init(strIniFileName)) Then
        IniFile.getForm Me
        booIniFileOpen = True
    End If
    
    Me.Show vbModal
    If (booOK) Then
        strUserName = Me.txtUserName
        strPassWord = Me.txtPassword
        strServerName = Me.txtServerName
        strDataBase = Me.txtDatabase
        booTrustedConnexion = Me.chkTrustedConnexion.Value = vbChecked
        
        'If (booIniFileOpen) Then
            IniFile.setForm Me
        'End If
        Run = True
    End If
    
    Unload Me
    
End Function

