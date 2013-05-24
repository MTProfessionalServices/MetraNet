VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Send SMS"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdSubmit 
      Caption         =   "Submit"
      Height          =   495
      Left            =   1920
      TabIndex        =   0
      Top             =   1200
      Width           =   1215
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
'This code uploads a file to an ASP script using http post
'You need to add a reference to Microsoft XML, V26 to the project.
'Get this from http://www.microsoft.com/xml

Private Sub cmdSubmit_Click()
Dim strText As String
Dim strBody As String
Dim strFileName As String
Dim oHttp As XMLHTTP26

'make use of the XMLHTTPRequest object contained in msxml.dll
Set oHttp = New XMLHTTP26
'enter your data
strText = InputBox("Text:", "Upload a file", "<h1>Test2</h1>")
strFileName = InputBox("File Name:", "Upload a file", "dummy.htm")
'fire of an http request
oHttp.open "POST", "http://www.../upload.asp", False
oHttp.setRequestHeader "Content-Type", "multipart/form-data, boundary=AaB03x"
'assemble the body. send one field and one file
strBody = _
   "--AaB03x" & vbCrLf & _
   "content-disposition: form-data; name=""field1""" & vbCrLf & vbCrLf & _
   "test field" & vbCrLf & _
   "--AaB03x" & vbCrLf & _
   "content-disposition: form-data; name=""xyz""; filename=""" & strFileName & """" & vbCrLf & _
   "Content-Type: text/plain" & vbCrLf & vbCrLf & _
   strText & vbCrLf & _
   "--AaB03x--"
'send it
oHttp.send strBody
'check the feedback
Debug.Print oHttp.responseText

End Sub
