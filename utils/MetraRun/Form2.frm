VERSION 5.00
Begin VB.Form Form2 
   BorderStyle     =   0  'None
   Caption         =   "Form2"
   ClientHeight    =   345
   ClientLeft      =   2655
   ClientTop       =   3945
   ClientWidth     =   3120
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form2"
   MouseIcon       =   "Form2.frx":0000
   MousePointer    =   99  'Custom
   ScaleHeight     =   345
   ScaleWidth      =   3120
   ShowInTaskbar   =   0   'False
End
Attribute VB_Name = "Form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Click()
    Dim sh As New Shell
    sh.Open App.Path + "\MetraNet\MetraNet.msi"
End Sub

Private Sub Command1_Click()
    End
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
    If vbKeyEscape Then End
End Sub


