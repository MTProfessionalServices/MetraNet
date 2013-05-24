VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "COM SDK Client"
   ClientHeight    =   3825
   ClientLeft      =   45
   ClientTop       =   360
   ClientWidth     =   4590
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3825
   ScaleWidth      =   4590
   StartUpPosition =   3  'Windows Default
   Begin VB.CheckBox ckSessionSet 
      Caption         =   "Use Session Sets"
      Height          =   375
      Left            =   960
      TabIndex        =   10
      Top             =   3120
      Value           =   1  'Checked
      Width           =   1575
   End
   Begin VB.TextBox txtSessions 
      Height          =   375
      Left            =   240
      TabIndex        =   9
      Text            =   "10"
      Top             =   3120
      Width           =   615
   End
   Begin VB.ComboBox cbMeterType 
      Height          =   315
      Left            =   2640
      Style           =   2  'Dropdown List
      TabIndex        =   7
      Top             =   240
      Width           =   1815
   End
   Begin VB.TextBox txtUser 
      Height          =   495
      Left            =   2640
      TabIndex        =   5
      Text            =   "Username"
      Top             =   960
      Width           =   1695
   End
   Begin VB.TextBox txtPassword 
      Height          =   495
      Left            =   2640
      TabIndex        =   6
      Text            =   "Password"
      Top             =   1680
      Width           =   1695
   End
   Begin VB.TextBox txtAmount 
      Height          =   495
      Left            =   2640
      TabIndex        =   4
      Text            =   "Result"
      Top             =   2400
      Width           =   1695
   End
   Begin VB.CommandButton btMeter 
      Caption         =   "Meter"
      Default         =   -1  'True
      Height          =   495
      Left            =   2640
      TabIndex        =   8
      Top             =   3120
      Width           =   1695
   End
   Begin VB.TextBox txtUnits 
      Height          =   495
      Left            =   240
      TabIndex        =   3
      Text            =   "Units"
      Top             =   2400
      Width           =   2175
   End
   Begin VB.TextBox txtDescription 
      Height          =   495
      Left            =   240
      TabIndex        =   2
      Text            =   "Description"
      Top             =   1680
      Width           =   2175
   End
   Begin VB.TextBox txtAccount 
      Height          =   495
      Left            =   240
      TabIndex        =   1
      Text            =   "Account Name"
      Top             =   960
      Width           =   2175
   End
   Begin VB.TextBox txtServer 
      Height          =   495
      Left            =   240
      TabIndex        =   0
      Text            =   "Server Name"
      Top             =   240
      Width           =   2175
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'***************************************************************************
'* Copyright 2000-2006 by MetraTech Corporation
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corporation MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corporation,
'* and USER agrees to preserve the same.
'*
'***************************************************************************/

Option Explicit

Private objSessionSet As SessionSet
Private objSession As Session
Private objResultSession As Session
Private objParent As Session
Private objMeter As Meter

Private Sub Form_Load()
    With cbMeterType
        .AddItem "Atomic"
        .AddItem "Compound"
        .AddItem "Secure"
        .AddItem "Synchronous"
        .ListIndex = 0
    End With
End Sub

Private Sub cbMeterType_Click()
    txtUser.Visible = False
    txtPassword.Visible = False
    txtAmount.Visible = False
    txtSessions.Visible = False
    If cbMeterType.Text = "Atomic" Then Caption = "COM SDK Client: Atomic"
    If cbMeterType.Text = "Compound" Then Caption = "COM SDK Client: Compound"
    If cbMeterType.Text = "Secure" Then
        Caption = "COM SDK Client: Secure"
        txtUser.Visible = True
        txtPassword.Visible = True
    End If
    If cbMeterType.Text = "Synchronous" Then
        txtAmount.Visible = True
        Caption = "COM SDK Client: Synchronous"
    End If
    If ckSessionSet.Value = 1 Then
        Caption = Caption + " with " + txtSessions + "-Session Set"
        txtSessions.Visible = True
    End If
End Sub

Private Sub ckSessionSet_click()
   cbMeterType_Click
End Sub

Private Sub btMeter_Click()
   If Val(txtUnits) / 1 > 0 Then
      'nothing
   Else
      MsgBox "Will meter with 100 units.", vbInformation
      txtUnits.Text = "100"
      Me.Refresh
   End If
   If cbMeterType.Text = "Atomic" Then MeterAtomic
   If cbMeterType.Text = "Compound" Then MeterCompound
   If cbMeterType.Text = "Secure" Then MeterSecure
   If cbMeterType.Text = "Synchronous" Then MeterSynchronous
End Sub

Private Sub Initialize()
   ' Create the meter object
   Set objMeter = New Meter

   ' start up the SDK
   objMeter.Startup

   ' Set the timeout and number of server retries
   objMeter.HTTPTimeout = 30
   objMeter.HTTPRetries = 1
End Sub

Private Sub TestSession()
   ' create a test session
   Set objSession = objMeter.CreateSession("metratech.com/TestService")
   
   If cbMeterType.Text = "Synchronous" Then
  '   request a response session
      objSession.RequestResponse = True
   End If

   ' set the session properties
   objSession.InitProperty "AccountName", txtAccount.Text
   objSession.InitProperty "Description", txtDescription.Text
   objSession.InitProperty "Time", Now
   objSession.InitProperty "Units", CDbl(txtUnits.Text)
   If cbMeterType.Text <> "Compound" Then
   
   Else
      CallChildren
   End If
   
   ' Close the session
   objSession.Close

   ' Shutdown the SDK
   objMeter.Shutdown
End Sub

Private Sub TestSessionSet()

   Dim nSessions As Integer
   Dim i As Integer

   ' create a session set to hold the test sessions
  Set objSessionSet = objMeter.CreateSessionSet()

  nSessions = Val(txtSessions.Text)
  
  For i = 1 To nSessions 'Create the test sessions in the set
    Set objSession = objSessionSet.CreateSession("metratech.com/TestService")
     ' set the session properties
      If cbMeterType.Text = "Synchronous" Then
      '   request a response session
          objSession.RequestResponse = True
      End If
    objSession.InitProperty "AccountName", txtAccount.Text
    objSession.InitProperty "Description", txtDescription.Text
    objSession.InitProperty "Units", CDbl(txtUnits.Text)
    objSession.InitProperty "Time", Now
  Next

   ' close the session
   objSessionSet.Close

   ' Shutdown the SDK
   objMeter.Shutdown
End Sub

Private Sub MeterAtomic()
On Error GoTo errmsg

   Initialize
   
   ' priority, servername, port, secure, username, password
   objMeter.AddServer 0, txtServer, DEFAULT_HTTP_PORT, False, "", ""

   If ckSessionSet.Value = 1 Then
      TestSessionSet
   Else
      TestSession
   End If

errmsg:
    If Err.Number > 0 Or Err.Number < 0 Then
        MsgBox Err.Description, vbExclamation
    Else
        MsgBox "Metering Complete", vbInformation
    End If
End Sub

Private Sub MeterCompound()
On Error GoTo errmsg

   Dim i As Integer

   Initialize

   ' priority, servername, port, secure, username, password
   objMeter.AddServer 0, txtServer.Text, DEFAULT_HTTP_PORT, False, "", ""

   ' create the parent session
   Set objParent = objMeter.CreateSession("metratech.com/testparent")

   If ckSessionSet.Value = 1 Then
      TestSessionSet
   Else
      TestSession
   End If
   
errmsg:
    If Err.Number > 0 Or Err.Number < 0 Then
        MsgBox Err.Description, vbExclamation
    Else
        MsgBox "Metering Complete", vbInformation
    End If
End Sub

Private Sub CallChildren()
   Dim objChild As Session
   Dim i As Integer
   ' create some test children
   For i = 1 To 5
      ' create a child session
      Set objChild = objParent.CreateChildSession("metratech.com/TestService")
   
      ' set the session properties
      objChild.InitProperty "AccountName", txtAccount.Text
      objChild.InitProperty "Description", txtDescription.Text
      objChild.InitProperty "Units", CDbl(txtUnits.Text)
      objChild.InitProperty "Time", Now
   Next
End Sub

Private Sub MeterSecure()
On Error GoTo errmsg

   Initialize

   ' priority, servername, port, secure, username, password
   objMeter.AddServer 0, txtServer.Text, DEFAULT_HTTPS_PORT, True, txtUser.Text, txtPassword.Text

   If ckSessionSet.Value = 1 Then
      TestSessionSet
   Else
      TestSession
   End If

errmsg:
    If Err.Number > 0 Or Err.Number < 0 Then
        MsgBox Err.Description, vbExclamation
    Else
        MsgBox "Metering Complete", vbInformation
    End If
End Sub


Private Sub MeterSynchronous()
On Error GoTo errmsg

'   Dim objMeter As Meter
   Dim amount As Double

   Initialize
   
   ' priority, servername, port, secure, username, password
   objMeter.AddServer 0, txtServer, DEFAULT_HTTP_PORT, False, "", ""

   If ckSessionSet.Value = 1 Then
      TestSessionSet
   Else
      TestSession
   End If

   ' Get the result session
   Set objResultSession = objSession.ResultSession

   ' Get the property added by the test stage
   amount = objResultSession.GetProperty("_Amount", MTC_DT_DOUBLE)

   ' Display the property
   txtAmount.Text = amount

errmsg:
    If Err.Number > 0 Or Err.Number < 0 Then
        MsgBox Err.Description, vbExclamation
    Else
        MsgBox "Metering Complete", vbInformation
    End If
End Sub

Private Sub txtAccount_GotFocus()
    txtAccount.SelLength = Len(txtAccount)
End Sub
Private Sub txtAmount_GotFocus()
    txtAmount.SelLength = Len(txtAmount)
End Sub
Private Sub txtDescription_GotFocus()
    txtDescription.SelLength = Len(txtDescription)
End Sub
Private Sub txtPassword_GotFocus()
    txtPassword.SelLength = Len(txtPassword)
End Sub
Private Sub txtServer_GotFocus()
    txtServer.SelLength = Len(txtServer)
End Sub
Private Sub txtSessions_Change()
   cbMeterType_Click
End Sub
Private Sub txtUnits_GotFocus()
    txtUnits.SelLength = Len(txtUnits)
End Sub
Private Sub txtUser_GotFocus()
    txtUser.SelLength = Len(txtUser)
End Sub

