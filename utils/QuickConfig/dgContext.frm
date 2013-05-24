VERSION 5.00
Begin VB.Form dgContext 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Serialized Context String"
   ClientHeight    =   2385
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   6570
   Icon            =   "dgContext.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2385
   ScaleWidth      =   6570
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.TextBox txSerial 
      Height          =   2055
      Left            =   2280
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      TabIndex        =   4
      TabStop         =   0   'False
      Top             =   120
      Width           =   2535
   End
   Begin VB.CommandButton btRequest 
      Caption         =   "Request"
      Default         =   -1  'True
      Height          =   495
      Left            =   5040
      TabIndex        =   3
      Top             =   120
      Width           =   1335
   End
   Begin VB.TextBox txServer 
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   360
      Width           =   1935
   End
   Begin VB.TextBox txUsername 
      Height          =   375
      Left            =   120
      TabIndex        =   1
      Top             =   1080
      Width           =   1935
   End
   Begin VB.TextBox txPassword 
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   1800
      Width           =   1935
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Close"
      Height          =   495
      Left            =   5040
      TabIndex        =   5
      Top             =   1680
      Width           =   1335
   End
   Begin VB.Label Label2 
      Caption         =   "Password"
      Height          =   255
      Left            =   120
      TabIndex        =   8
      Top             =   1560
      Width           =   1695
   End
   Begin VB.Label Label1 
      Caption         =   "Username"
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   840
      Width           =   1695
   End
   Begin VB.Label Label6 
      Caption         =   "Pipeline Server Name"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   120
      Width           =   1815
   End
End
Attribute VB_Name = "dgContext"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit


Private Sub btRequest_Click()
On Error GoTo errmsg

    If Len(txServer) = 0 Then
      MsgBox "You must specify a server name.", vbInformation
      Exit Sub
    End If
    
    Dim objSession As Session
    Dim objResult As Session
    Dim objMeter As Meter
    
    Dim mtc_dt_string As VariantTypeConstants
    
    ' Create the meter object
    Set objMeter = New Meter
    
    ' start up the SDK
    objMeter.Startup
    
    ' Set the timeout and number of server retries
    objMeter.HTTPTimeout = 30
    objMeter.HTTPRetries = 1
    
    ' priority, servername, port, secure, username, password
    objMeter.AddServer 0, txServer, DEFAULT_HTTP_PORT, False, "", ""
    
    ' create a test session
    Set objSession = objMeter.CreateSession("metratech.com/login")
    
    ' Request a response session
    objSession.RequestResponse = True

    objSession.InitProperty "username", txUsername.Text
    objSession.InitProperty "password_", txPassword.Text
    objSession.InitProperty "namespace", "system_user"
 
'    objsession.
   
    ' close the session
    objSession.Close
    
        ' Get the result session
    Set objResult = objSession.ResultSession
    
    
    ' Get the result session
     dgData.strSerial = objResult.getProperty("SessionContext", mtc_dt_string)
     txSerial = dgData.strSerial
   
    objMeter.Shutdown
    
    Exit Sub
    
errmsg:

    ' close the session
'    objSession.Close
'    objMeter.Shutdown
    
   MsgBox Err.Description, vbExclamation
      
subErrLog "dgContext:btRequest_Click"
End Sub

Private Sub CancelButton_Click()
   dgData.ContextStatus
   Unload Me
End Sub

Private Sub Form_Load()
   If Len(dgData.strSerial) > 0 Then
      txSerial = dgData.strSerial
   End If
   txServer = dgData.txServer
   txUsername = dgData.txUser
   txPassword = dgData.txPswd
End Sub

Private Sub txPassword_Change()
   txPassword.SelLength = Len(txPassword)
End Sub

Private Sub txSerial_Change()
   txSerial.SelLength = Len(txSerial)
   If Len(txSerial) > 0 Then
      txSerial.TabStop = True
   Else
      txSerial.TabStop = False
   End If
End Sub

Private Sub txUsername_Change()
   txUsername.SelLength = Len(txUsername)
End Sub

Private Sub txServer_Change()
   txServer.SelLength = Len(txServer)
End Sub
