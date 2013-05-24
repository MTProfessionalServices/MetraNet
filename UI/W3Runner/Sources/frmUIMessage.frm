VERSION 5.00
Begin VB.Form frmUIMessage 
   BackColor       =   &H00FFFFFF&
   BorderStyle     =   0  'None
   Caption         =   "Form1"
   ClientHeight    =   855
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   5310
   LinkTopic       =   "Form1"
   ScaleHeight     =   855
   ScaleWidth      =   5310
   ShowInTaskbar   =   0   'False
   Begin VB.Label txtMessage 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      Caption         =   "-"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   780
      TabIndex        =   0
      Top             =   120
      Width           =   3375
      WordWrap        =   -1  'True
   End
End
Attribute VB_Name = "frmUIMessage"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()

    Dim w As New cWindows
    w.SetWinTopMost Me, True
  
End Sub

Private Sub Form_Paint()
    Border vbBlack, 0
End Sub

Public Function OpenDialog(Optional strMessage As String) As Boolean
    If (Len(strMessage) = 0) Then
        Unload frmUIMessage
    Else
        txtMessage.Caption = strMessage
        frmUIMessage.Show
        frmUIMessage.SetFocus
        
    End If
    GlobalDoEvents
    OpenDialog = True
End Function



Public Function Border(lngColor As Long, lngIndex As Long)
    Line (0 + (Screen.TwipsPerPixelX * lngIndex), 0 + (Screen.TwipsPerPixelX * lngIndex))-(Width - (Screen.TwipsPerPixelX * (lngIndex + 1)), Height - (Screen.TwipsPerPixelX * (lngIndex + 1))), lngColor, B
End Function

Private Sub Form_Resize()
  
    txtMessage.Left = (Screen.TwipsPerPixelX * 1)
    txtMessage.Top = (Screen.TwipsPerPixelX * 1)
    txtMessage.Width = Width - (Screen.TwipsPerPixelX * 2)
    txtMessage.Height = Height - (Screen.TwipsPerPixelX * 2)
End Sub
