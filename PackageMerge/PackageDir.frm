VERSION 5.00
Begin VB.Form PackageDir 
   Caption         =   "Platform extension directory"
   ClientHeight    =   3735
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4635
   LinkTopic       =   "Package directory"
   ScaleHeight     =   3735
   ScaleWidth      =   4635
   StartUpPosition =   3  'Windows Default
   Begin VB.DirListBox Dir1 
      Height          =   2565
      Left            =   120
      TabIndex        =   1
      Top             =   240
      Width           =   4335
   End
   Begin VB.TextBox Text1 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "Text1"
      Top             =   3120
      Width           =   4335
   End
End
Attribute VB_Name = "PackageDir"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Dir1_Change()

End Sub
