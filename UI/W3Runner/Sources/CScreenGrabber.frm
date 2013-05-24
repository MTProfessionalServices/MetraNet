VERSION 5.00
Begin VB.Form frmScreenGrabber 
   Caption         =   "Form1"
   ClientHeight    =   5145
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   8505
   Icon            =   "CScreenGrabber.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   5145
   ScaleWidth      =   8505
   StartUpPosition =   3  'Windows Default
   Begin VB.PictureBox Picture3 
      AutoSize        =   -1  'True
      Height          =   390
      Left            =   120
      Picture         =   "CScreenGrabber.frx":0E42
      ScaleHeight     =   330
      ScaleWidth      =   390
      TabIndex        =   3
      Top             =   600
      Width           =   450
   End
   Begin VB.PictureBox Picture2 
      AutoSize        =   -1  'True
      Height          =   300
      Left            =   120
      Picture         =   "CScreenGrabber.frx":1564
      ScaleHeight     =   240
      ScaleWidth      =   240
      TabIndex        =   2
      Top             =   240
      Width           =   300
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   495
      Left            =   720
      TabIndex        =   1
      Top             =   240
      Width           =   1095
   End
   Begin VB.PictureBox Picture1 
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      Height          =   3615
      Left            =   1920
      ScaleHeight     =   3555
      ScaleWidth      =   5835
      TabIndex        =   0
      Top             =   240
      Width           =   5895
   End
End
Attribute VB_Name = "frmScreenGrabber"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click()

    Dim screenGrabber As New CScreenGrabber
    
'    screenGrabber.Grab eGRAB_MODE_FULL_SCREEN, "c:\temp\a.bmp"
    
    screenGrabber.Grab eGRAB_MODE_WINDOW, "c:\temp\a.bmp", Me.HWND, Me.Width / Screen.TwipsPerPixelX, Me.Height / Screen.TwipsPerPixelY
End Sub

