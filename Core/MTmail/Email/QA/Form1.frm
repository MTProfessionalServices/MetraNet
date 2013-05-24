VERSION 5.00
Begin VB.Form FrmEmailTest 
   Caption         =   "Email Test"
   ClientHeight    =   7500
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9420
   LinkTopic       =   "Form1"
   ScaleHeight     =   7500
   ScaleWidth      =   9420
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox MsgTemplateLanguage 
      Height          =   285
      Left            =   5520
      TabIndex        =   34
      Text            =   "english"
      Top             =   2760
      Width           =   3735
   End
   Begin VB.TextBox MsgTemplateName 
      Height          =   285
      Left            =   5520
      TabIndex        =   33
      Text            =   "sample"
      Top             =   2400
      Width           =   3735
   End
   Begin VB.TextBox MsgTemplateFile 
      Height          =   285
      Left            =   5520
      TabIndex        =   30
      Text            =   "d:\source\Core\MTmail\Email\QA\email_test.xml "
      Top             =   2040
      Width           =   3735
   End
   Begin VB.Frame Frame2 
      BorderStyle     =   0  'None
      Height          =   855
      Left            =   2040
      TabIndex        =   26
      Top             =   2280
      Width           =   1815
      Begin VB.OptionButton radBodyPlain 
         Caption         =   "Plain"
         Height          =   255
         Left            =   120
         TabIndex        =   28
         Top             =   480
         Width           =   975
      End
      Begin VB.OptionButton radBodyHTML 
         Caption         =   "HTML"
         Height          =   255
         Left            =   120
         TabIndex        =   27
         Top             =   120
         Width           =   855
      End
   End
   Begin VB.CheckBox chkUseAttachURL 
      Caption         =   "Check8"
      Enabled         =   0   'False
      Height          =   255
      Left            =   6960
      TabIndex        =   22
      Top             =   1080
      Width           =   255
   End
   Begin VB.CheckBox chkUseAttachFile 
      Caption         =   "Check7"
      Enabled         =   0   'False
      Height          =   255
      Left            =   6960
      TabIndex        =   21
      Top             =   240
      Width           =   255
   End
   Begin VB.TextBox txtAttachURL 
      Enabled         =   0   'False
      Height          =   285
      Left            =   5880
      TabIndex        =   20
      Text            =   "http://www.fatboys.org/images/welcome.gif"
      Top             =   1440
      Width           =   3375
   End
   Begin VB.TextBox txtAttachFile 
      Enabled         =   0   'False
      Height          =   285
      Left            =   5880
      TabIndex        =   18
      Text            =   "c:\temp\wecerr.txt"
      Top             =   600
      Width           =   3375
   End
   Begin VB.CheckBox chkUseMessageBody 
      Height          =   255
      Left            =   960
      TabIndex        =   16
      Top             =   3480
      Width           =   255
   End
   Begin VB.CheckBox chkUseBodyFormat 
      Caption         =   "Check5"
      Height          =   255
      Left            =   2880
      TabIndex        =   15
      Top             =   2040
      Width           =   255
   End
   Begin VB.CheckBox chkUseMailFormat 
      Caption         =   "Check4"
      Height          =   255
      Left            =   960
      TabIndex        =   14
      Top             =   2040
      Width           =   255
   End
   Begin VB.CheckBox chkUseMessageSubject 
      Caption         =   "Check3"
      Height          =   255
      Left            =   5040
      TabIndex        =   13
      Top             =   1200
      Width           =   255
   End
   Begin VB.CheckBox chkUseMessageFrom 
      Caption         =   "Check2"
      Height          =   255
      Left            =   5040
      TabIndex        =   12
      Top             =   720
      Width           =   255
   End
   Begin VB.CheckBox chkUseMessageTo 
      Height          =   255
      Left            =   5040
      TabIndex        =   11
      Top             =   240
      Width           =   255
   End
   Begin VB.TextBox MsgSubject 
      Height          =   285
      Left            =   1320
      TabIndex        =   8
      Text            =   "This is a test...Feel Free To Ignore"
      Top             =   1200
      Width           =   3615
   End
   Begin VB.TextBox MsgFrom 
      Height          =   285
      Left            =   1320
      TabIndex        =   7
      Text            =   "mefimov@metratech.com"
      Top             =   720
      Width           =   3615
   End
   Begin VB.TextBox MsgHTML 
      Height          =   2775
      Left            =   120
      MultiLine       =   -1  'True
      TabIndex        =   6
      Top             =   3840
      Width           =   9135
   End
   Begin VB.TextBox MsgTo 
      Height          =   285
      HideSelection   =   0   'False
      Left            =   1320
      TabIndex        =   4
      Text            =   "mefimov@metratech.com"
      Top             =   240
      Width           =   3615
   End
   Begin VB.CommandButton cmdSend 
      Caption         =   "Send Message"
      Height          =   495
      Left            =   3720
      TabIndex        =   0
      Top             =   6840
      Width           =   2055
   End
   Begin VB.Frame Frame1 
      BorderStyle     =   0  'None
      ForeColor       =   &H80000017&
      Height          =   735
      Left            =   0
      TabIndex        =   23
      Top             =   2400
      Width           =   1935
      Begin VB.OptionButton radMailPlain 
         Caption         =   "Plaintext"
         Height          =   255
         Left            =   360
         TabIndex        =   25
         Top             =   360
         Width           =   1095
      End
      Begin VB.OptionButton radMailMIME 
         Caption         =   "MIME"
         Height          =   255
         Left            =   360
         TabIndex        =   24
         Top             =   0
         Width           =   1095
      End
   End
   Begin VB.Label Label10 
      Caption         =   "Language"
      Height          =   255
      Left            =   4200
      TabIndex        =   32
      Top             =   2760
      Width           =   1215
   End
   Begin VB.Label Label9 
      Caption         =   "Template Name:"
      Height          =   255
      Left            =   4200
      TabIndex        =   31
      Top             =   2400
      Width           =   1215
   End
   Begin VB.Label Label8 
      Caption         =   "Template File:"
      Height          =   255
      Left            =   4200
      TabIndex        =   29
      Top             =   2040
      Width           =   1095
   End
   Begin VB.Line Line4 
      X1              =   4080
      X2              =   4080
      Y1              =   1920
      Y2              =   3240
   End
   Begin VB.Line Line3 
      X1              =   0
      X2              =   9480
      Y1              =   3240
      Y2              =   3240
   End
   Begin VB.Line Line2 
      X1              =   5640
      X2              =   5640
      Y1              =   1920
      Y2              =   0
   End
   Begin VB.Line Line1 
      X1              =   0
      X2              =   9480
      Y1              =   1920
      Y2              =   1920
   End
   Begin VB.Label Label7 
      Caption         =   "Attached URL:"
      Height          =   255
      Left            =   5760
      TabIndex        =   19
      Top             =   1080
      Width           =   1215
   End
   Begin VB.Label Label6 
      Caption         =   "Attached File:"
      Height          =   255
      Left            =   5760
      TabIndex        =   17
      Top             =   240
      Width           =   1335
   End
   Begin VB.Label Label5 
      Caption         =   "Body Format:"
      Height          =   255
      Left            =   1800
      TabIndex        =   10
      Top             =   2040
      Width           =   1095
   End
   Begin VB.Label Label4 
      Caption         =   "Mail Format:"
      Height          =   255
      Left            =   0
      TabIndex        =   9
      Top             =   2040
      Width           =   975
   End
   Begin VB.Label Label3 
      Caption         =   "Message:"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   3480
      Width           =   855
   End
   Begin VB.Label Label1 
      Caption         =   "Message To:"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   1
      Top             =   240
      Width           =   930
   End
   Begin VB.Label Label2 
      Caption         =   "Subject:"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   1200
      Width           =   615
   End
   Begin VB.Label Label1 
      Caption         =   "Message From:"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   2
      Top             =   720
      Width           =   1095
   End
End
Attribute VB_Name = "FrmEmailTest"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdSend_Click()

Dim objMsg As New EMAILMESSAGELib.MTEmailMessage
Dim objMail As New EMAILLib.MTEmail

Dim val

On Error GoTo ErrorHandler

'Initialize our objects

objMail.init objMsg

'Set the template names
objMail.TemplateFileName = MsgTemplateFile
objMail.TemplateName = MsgTemplateName
objMail.TemplateLanguage = MsgTemplateLanguage


'Load and parse the template
objMail.LoadTemplate

'Set other message parameters, based on UI selections
If chkUseMessageTo.Value = 1 Then
    objMsg.MessageTo = MsgTo
End If

If chkUseMessageFrom.Value = 1 Then
    objMsg.MessageFrom = MsgFrom
End If

If chkUseMessageSubject.Value = 1 Then
    objMsg.MessageSubject = MsgSubject
End If

If chkUseMailFormat.Value = 1 Then
    If radMailMIME.Value = True Then
        objMsg.MessageMailFormat = 0
    Else
        objMsg.MessageMailFormat = 1
    End If
End If

If chkUseBodyFormat.Value = 1 Then
    If radBodyHTML.Value = True Then
        objMsg.MessageBodyFormat = 0
    Else
        objMsg.MessageBodyFormat = 1
    End If
End If

If chkUseAttachFile.Value = 1 Then
    objMail.AttachFile txtAttachFile
End If

If chkUseAttachURL.Value = 1 Then
    objMail.AttachURL txtURL, "welcome.gif"
End If

If chkUseMessageBody.Value = 1 Then
    objMsg.MessageBody = MsgHTML
End If

objMail.AddParam "%%AMOUNT%%", "$4,097,239.41"
objMail.AddParam "%%VICTIM%%", "Nacho Man"
objMail.AddParam "%%SUPERFLY%%", "TNT"
objMail.AddParam "%%THUG%%", "Anton the Mauler"
objMail.AddParam "%%SENDER%%", "Carlito S. Burrito"


objMail.Send


ErrorHandler:
If Err Then
  MsgBox "An Error Occurred: " & Err.Description & " in: " & Err.Source
End If

Set objMail = Nothing
Set objMsg = Nothing

End Sub

