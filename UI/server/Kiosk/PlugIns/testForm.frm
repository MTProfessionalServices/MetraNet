VERSION 5.00
Begin VB.Form testForm 
   Caption         =   "Form1"
   ClientHeight    =   2565
   ClientLeft      =   45
   ClientTop       =   270
   ClientWidth     =   3750
   LinkTopic       =   "Form1"
   ScaleHeight     =   2565
   ScaleWidth      =   3750
   StartUpPosition =   3  'Windows Default
End
Attribute VB_Name = "testForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()

'Dim myAuth As New MTPres.Authenticator
Dim myCred As New COMCredentials

Set myAuth = CreateObject("MTPres.Authenticator")

myCred.loginID = "foo"
myCred.password = "foo"
myCred.name_space = "foo"

isAuth = myAuth.checkbug(myCred)
If isAuth Then
    MsgBox "it is authentic..."
Else
    MsgBox "it is not authentic..."
End If

End Sub
