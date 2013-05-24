VERSION 5.00
Begin VB.Form frmRegistration 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Registration"
   ClientHeight    =   3135
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   6885
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3135
   ScaleWidth      =   6885
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command1 
      Caption         =   "Close"
      Height          =   375
      Left            =   2760
      TabIndex        =   15
      Top             =   2700
      Width           =   1455
   End
   Begin VB.Frame Frame1 
      Caption         =   "Client"
      Height          =   2535
      Left            =   60
      TabIndex        =   0
      Top             =   60
      Width           =   6735
      Begin VB.TextBox email 
         BackColor       =   &H80000004&
         Height          =   315
         Left            =   1800
         Locked          =   -1  'True
         TabIndex        =   16
         Top             =   1740
         Width           =   4755
      End
      Begin VB.TextBox KeyDate 
         BackColor       =   &H80000004&
         Height          =   315
         Left            =   1800
         Locked          =   -1  'True
         TabIndex        =   14
         Top             =   2100
         Width           =   4755
      End
      Begin VB.TextBox Country 
         BackColor       =   &H80000004&
         Height          =   315
         Left            =   5100
         Locked          =   -1  'True
         TabIndex        =   12
         Top             =   1440
         Width           =   1455
      End
      Begin VB.TextBox Zip 
         BackColor       =   &H80000004&
         Height          =   315
         Left            =   1800
         Locked          =   -1  'True
         TabIndex        =   10
         Top             =   1380
         Width           =   1455
      End
      Begin VB.TextBox City 
         BackColor       =   &H80000004&
         Height          =   315
         Left            =   5100
         Locked          =   -1  'True
         TabIndex        =   8
         Top             =   1080
         Width           =   1455
      End
      Begin VB.TextBox State 
         BackColor       =   &H80000004&
         Height          =   315
         Left            =   1800
         Locked          =   -1  'True
         TabIndex        =   6
         Top             =   1020
         Width           =   1455
      End
      Begin VB.TextBox Address 
         BackColor       =   &H80000004&
         Height          =   315
         Left            =   1800
         Locked          =   -1  'True
         TabIndex        =   4
         Top             =   660
         Width           =   4755
      End
      Begin VB.TextBox CompanyName 
         BackColor       =   &H80000004&
         Height          =   315
         Left            =   1800
         Locked          =   -1  'True
         TabIndex        =   2
         Top             =   300
         Width           =   4755
      End
      Begin VB.Label Label10 
         Caption         =   "eMail"
         Height          =   255
         Left            =   180
         TabIndex        =   17
         Top             =   1800
         Width           =   1395
      End
      Begin VB.Label Label7 
         Caption         =   "Key Date"
         Height          =   255
         Left            =   180
         TabIndex        =   13
         Top             =   2160
         Width           =   1395
      End
      Begin VB.Label Label6 
         Caption         =   "Country :"
         Height          =   255
         Left            =   3480
         TabIndex        =   11
         Top             =   1440
         Width           =   1395
      End
      Begin VB.Label Label5 
         Caption         =   "Zip :"
         Height          =   255
         Left            =   180
         TabIndex        =   9
         Top             =   1380
         Width           =   1395
      End
      Begin VB.Label Label4 
         Caption         =   "City :"
         Height          =   255
         Left            =   3480
         TabIndex        =   7
         Top             =   1080
         Width           =   1395
      End
      Begin VB.Label Label3 
         Caption         =   "State :"
         Height          =   255
         Left            =   180
         TabIndex        =   5
         Top             =   1020
         Width           =   1395
      End
      Begin VB.Label Label2 
         Caption         =   "Address :"
         Height          =   255
         Left            =   180
         TabIndex        =   3
         Top             =   660
         Width           =   1395
      End
      Begin VB.Label Label1 
         Caption         =   "Company Name :"
         Height          =   255
         Left            =   180
         TabIndex        =   1
         Top             =   300
         Width           =   1395
      End
   End
End
Attribute VB_Name = "frmRegistration"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click()
    Hide
End Sub
