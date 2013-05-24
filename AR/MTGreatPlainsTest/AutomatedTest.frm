VERSION 5.00
Begin VB.Form AutomatedTest 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Caption"
   ClientHeight    =   7725
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   15360
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7725
   ScaleWidth      =   15360
   ShowInTaskbar   =   0   'False
   Begin VB.TextBox txtOutput 
      Height          =   5895
      Left            =   8280
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   11
      Top             =   360
      Width           =   5895
   End
   Begin VB.Frame Frame1 
      Caption         =   "Frame1"
      Height          =   3495
      Left            =   480
      TabIndex        =   6
      Top             =   2760
      Width           =   7095
      Begin VB.TextBox tbeConnectComponentId 
         Height          =   285
         Left            =   120
         TabIndex        =   10
         Text            =   "ExecProcsXML.ExecStoredProcedure9"
         Top             =   480
         Width           =   6735
      End
      Begin VB.CheckBox cbeConnectDocumentSend 
         Caption         =   "Direct sending of eConnect document"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   0
         Value           =   1  'Checked
         Width           =   3015
      End
      Begin VB.TextBox txteConnectXML 
         Height          =   1935
         Left            =   120
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   8
         Text            =   "AutomatedTest.frx":0000
         Top             =   1200
         Width           =   6735
      End
      Begin VB.TextBox tbeConnectConnectionString 
         Height          =   285
         Left            =   120
         TabIndex        =   7
         Text            =   "Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;User ID=sa;Initial Catalog=MTGP;Data Source=localhost"
         Top             =   840
         Width           =   6735
      End
   End
   Begin VB.CheckBox cbTestCreationofGreatPlainsObjects 
      Caption         =   "Create specific Great Plains AR interface objects"
      Height          =   555
      Left            =   480
      TabIndex        =   5
      Top             =   1920
      Value           =   1  'Checked
      Width           =   3615
   End
   Begin VB.ListBox lbOutput 
      Height          =   1230
      Left            =   8640
      TabIndex        =   4
      Top             =   480
      Visible         =   0   'False
      Width           =   5415
   End
   Begin VB.CheckBox cbTestCreationOfARObjects 
      Caption         =   "Create generic AR interface objects"
      Height          =   195
      Left            =   480
      TabIndex        =   3
      Top             =   1560
      Value           =   1  'Checked
      Width           =   3615
   End
   Begin VB.CheckBox cbTestCreationOfeConnectObject 
      Caption         =   "Create eConnect object"
      Height          =   195
      Left            =   480
      TabIndex        =   2
      Top             =   1200
      Value           =   1  'Checked
      Width           =   3615
   End
   Begin VB.CommandButton CancelButton 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   8400
      TabIndex        =   1
      Top             =   7200
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Height          =   375
      Left            =   8400
      TabIndex        =   0
      Top             =   6720
      Width           =   1215
   End
End
Attribute VB_Name = "AutomatedTest"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Private Sub CancelButton_Click()

Close

End Sub

Private Sub lbOuput_Click()

End Sub

Private Sub OKButton_Click()

RunTests

End Sub

Private Sub RunTests()

lbOutput.Clear
txtOutput.Text = ""

If cbTestCreationOfeConnectObject.Value = 1 Then
  TestCreationOfeConnectObject
End If

If cbTestCreationOfARObjects.Value = 1 Then
  TestCreationOfARReaderWriterConfigObjects
End If

If cbTestCreationofGreatPlainsObjects.Value = 1 Then
  TestCreationOfGreatPlainsInstanceObjects
End If

If cbeConnectDocumentSend.Value = 1 Then
  TestSendingeConnectDocumentDirectly
End If


End Sub

Private Function TestCreationOfeConnectObject()
TestCreationOfeConnectObject = False
Dim sTestName
sTestName = "Creation of eConnect object"
AddMessage ("Start " & sTestName)

Dim oeConnect
Set oeConnect = CreateObject("ExecProcsXML.ExecStoredProcedure9")

AddMessage ("eConnect object created")
TestCreationOfeConnectObject = True

End Function

Private Sub AddMessage(sMessage)

lbOutput.AddItem (sMessage)
txtOutput.Text = txtOutput.Text & sMessage & vbNewLine
End Sub



Private Function TestCreationOfARReaderWriterConfigObjects()
TestCreationOfARReaderWriterConfigObjects = False
Dim sTestName
sTestName = "Creation of MetraTech.MTARWriter object"
AddMessage ("Start " & sTestName)

Dim oARWriter
Set oARWriter = CreateObject("MetraTech.MTARWriter")

AddMessage ("MetraTech.MTARWriter object created")

sTestName = "Creation of MetraTech.MTARWriter object"
AddMessage ("Start " & sTestName)

Dim oARReader
Set oARReader = CreateObject("MetraTech.MTARReader")

AddMessage ("MetraTech.MTARReader object created")

sTestName = "Creation of MetraTech.MTARWriter object"
AddMessage ("Start " & sTestName)

Dim oARConfig
Set oARConfig = CreateObject("MetraTech.MTARConfig")

AddMessage ("MetraTech.MTARConfig object created")

TestCreationOfARReaderWriterConfigObjects = True

End Function

Private Function TestCreationOfGreatPlainsInstanceObjects()
On Error GoTo errorhandler
TestCreationOfGreatPlainsInstanceObjects = False
Dim sTestName
sTestName = "Creation of MTGreatPlainsExec.MTGreatPlainsWriter object"
AddMessage ("Start " & sTestName)

Dim oARWriter
Set oARWriter = CreateObject("MTGreatPlainsExec.MTGreatPlainsWriterx")

AddMessage ("MTGreatPlainsExec.MTGreatPlainsWriter object created")

sTestName = "Creation of MTGreatPlainsExec.MTGreatPlainsReader object"
AddMessage ("Start " & sTestName)

Dim oARReader
Set oARReader = CreateObject("MTGreatPlainsExec.MTGreatPlainsReader")

AddMessage ("MTGreatPlainsExec.MTGreatPlainsReader object created")

sTestName = "Creation of MTGreatPlainsExec.MTGreatPlainsConfig object"
AddMessage ("Start " & sTestName)

Dim oARConfig
Set oARConfig = CreateObject("MTGreatPlainsExec.MTGreatPlainsConfig")

AddMessage ("MTGreatPlainsExec.MTGreatPlainsConfig object created")

TestCreationOfGreatPlainsInstanceObjects = True

errorhandler:
    AddMessage ("ERROR: [" & Err.Number & "][" & Err.Source & "][" & Err.Description & "]")
End Function

Private Function TestSendingeConnectDocumentDirectly()
   On Error GoTo errorhandler
   
   Dim strConnectionString, strXMLDoc
   Dim ErrorString As String
   Dim OutGoingMessage As String
   strConnectionString = tbeConnectConnectionString
   strXMLDoc = txteConnectXML
   ErrorString = ""
   OutGoingMessage = ""
   
   Dim status As Boolean
   Dim ErrorState As Long
   Dim oExecProcs As Object
   Set oExecProcs = CreateObject(tbeConnectComponentId)

   AddMessage "Executing eConnect stored procedure with connection string[" & strConnectionString & "]"
   'AddMessage "eConnect Document[" & vbNewLine & strXMLDoc & vbNewLine & "]"
   status = oExecProcs.ExecStoredProc(strXMLDoc, strConnectionString, ErrorState, ErrorString, OutGoingMessage)
   
   If status = False Then
    AddMessage ("eConnect Operation returned FALSE")
    Dim strErr
    For Each strErr In oExecProcs.ErrorCodes
         AddMessage "    eConnect error [" & strErr & "]"
    Next
   Else
    AddMessage ("eConnect Operation returned TRUE")
   End If
   TestSendingeConnectDocumentDirectly = status
   
   Exit Function
errorhandler:
    AddMessage ("ERROR: [" & Err.Number & "][" & Err.Source & "][" & Err.Description & "]")
    TestSendingeConnectDocumentDirectly = False
End Function
