VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   1005
      Left            =   1620
      TabIndex        =   0
      Top             =   675
      Width           =   1725
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click()
    Dim strFirstNameUniCode As String
    Dim strFirstNameAscii As String
    
    strFirstNameUniCode = "Frédèric"
    
    Dim utf8 As New CUTF8
    
    Dim t As New cTextFile
    
    Dim s As String
    s = utf8.FromUTF8NotGood(strFirstNameUniCode)
    
    t.LogFile "C:\Temp\MultiByte\WideCharToMultiByte\\UTF8TEST.TXT", s, True
        
    
    
End Sub


' Returns an ANSI string from a pointer to a Unicode string.




