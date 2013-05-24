VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   5910
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   8385
   LinkTopic       =   "Form1"
   ScaleHeight     =   5910
   ScaleWidth      =   8385
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   435
      Left            =   1440
      TabIndex        =   0
      Top             =   840
      Width           =   1635
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit



      Private Const MK_LBUTTON = &H1
      Private Const WM_LBUTTONDOWN = &H201



      Private Sub Form_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
         
         Debug.Print "Position X:" & Str$(x / Screen.TwipsPerPixelX) & " Position Y:" & Str$(Y / Screen.TwipsPerPixelY)
         
      End Sub

      Private Sub Command1_Click()
         Dim nMousePosition As Long
         ' nMousePosition stores the x (hiword) and y (loword) values
         ' of the mouse cursor as measured in pixels.

         Let nMousePosition = MakeDWord(16, 18)
         Call SendMessage(Me.hwnd, WM_LBUTTONDOWN, MK_LBUTTON, ByVal nMousePosition)
         
      End Sub

