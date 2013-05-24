VERSION 5.00
Begin VB.Form Form3 
   BorderStyle     =   0  'None
   Caption         =   "Form3"
   ClientHeight    =   345
   ClientLeft      =   2655
   ClientTop       =   4620
   ClientWidth     =   3120
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form3"
   MouseIcon       =   "Form3.frx":0000
   MousePointer    =   99  'Custom
   ScaleHeight     =   345
   ScaleWidth      =   3120
   ShowInTaskbar   =   0   'False
End
Attribute VB_Name = "Form3"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Click()
    Dim sh As New Shell
    sh.Open App.Path + "\MetraConnect\MetraConnect 6.0.2.msi"
End Sub

Private Sub Command1_Click()
    End
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
    If vbKeyEscape Then End
End Sub

