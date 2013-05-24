VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Meter Demo"
   ClientHeight    =   9645
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9015
   LinkTopic       =   "Form1"
   ScaleHeight     =   9645
   ScaleWidth      =   9015
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton btnSessionSet 
      Caption         =   "Meter SessionSet"
      Height          =   975
      Left            =   5520
      TabIndex        =   23
      Top             =   8400
      Width           =   2775
   End
   Begin VB.CommandButton btnCompound 
      Caption         =   "Meter &Compound"
      Height          =   975
      Left            =   5520
      TabIndex        =   22
      Top             =   7080
      Width           =   2775
   End
   Begin VB.Frame Frame3 
      Caption         =   "Result Properties"
      Height          =   975
      Left            =   600
      TabIndex        =   13
      Top             =   7320
      Width           =   4335
      Begin VB.TextBox txtAmount 
         Enabled         =   0   'False
         Height          =   495
         Left            =   1440
         TabIndex        =   15
         Top             =   240
         Width           =   1575
      End
      Begin VB.Label Label3 
         Alignment       =   1  'Right Justify
         Caption         =   "Amount"
         Height          =   255
         Left            =   240
         TabIndex        =   14
         Top             =   360
         Width           =   735
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Metered Properties"
      Height          =   3135
      Left            =   600
      TabIndex        =   6
      Top             =   3600
      Width           =   4335
      Begin VB.TextBox txtUnits 
         Height          =   495
         Left            =   1440
         TabIndex        =   12
         Top             =   2280
         Width           =   1455
      End
      Begin VB.TextBox txtDescription 
         Height          =   495
         Left            =   1440
         TabIndex        =   8
         Top             =   1440
         Width           =   2655
      End
      Begin VB.TextBox txtAccount 
         Height          =   495
         Left            =   1440
         TabIndex        =   7
         Top             =   600
         Width           =   1455
      End
      Begin VB.Label Label4 
         Caption         =   "Units"
         Height          =   255
         Left            =   600
         TabIndex        =   11
         Top             =   2400
         Width           =   375
      End
      Begin VB.Label Label1 
         Alignment       =   1  'Right Justify
         Caption         =   "Account Name"
         Height          =   255
         Left            =   120
         TabIndex        =   10
         Top             =   720
         Width           =   1095
      End
      Begin VB.Label Label2 
         Alignment       =   1  'Right Justify
         Caption         =   "Description"
         Height          =   255
         Left            =   240
         TabIndex        =   9
         Top             =   1560
         Width           =   855
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Connection Info"
      Height          =   2895
      Left            =   600
      TabIndex        =   5
      Top             =   480
      Width           =   4335
      Begin VB.TextBox txtPassword 
         Height          =   525
         Left            =   1560
         TabIndex        =   21
         Top             =   2160
         Width           =   1815
      End
      Begin VB.TextBox txtUser 
         Height          =   495
         Left            =   1560
         TabIndex        =   20
         Top             =   1320
         Width           =   1575
      End
      Begin VB.TextBox txtServer 
         Height          =   525
         Left            =   1560
         TabIndex        =   19
         Top             =   480
         Width           =   1695
      End
      Begin VB.Label Label7 
         Caption         =   "Password"
         Height          =   255
         Left            =   240
         TabIndex        =   18
         Top             =   2280
         Width           =   855
      End
      Begin VB.Label Label6 
         Caption         =   "User Name"
         Height          =   255
         Left            =   240
         TabIndex        =   17
         Top             =   1440
         Width           =   855
      End
      Begin VB.Label Label5 
         Caption         =   "Server"
         Height          =   255
         Left            =   360
         TabIndex        =   16
         Top             =   600
         Width           =   495
      End
   End
   Begin VB.CommandButton btnFail 
      Caption         =   "Meter &Failover"
      Height          =   975
      Left            =   5520
      TabIndex        =   4
      Top             =   5760
      Width           =   2775
   End
   Begin VB.CommandButton btnLocalMode 
      Caption         =   "Meter &Local Mode"
      Height          =   975
      Left            =   5520
      TabIndex        =   3
      Top             =   4440
      Width           =   2775
   End
   Begin VB.CommandButton btnSynchronous 
      Caption         =   "Meter S&ynchronous"
      Height          =   975
      Left            =   5520
      TabIndex        =   2
      Top             =   3120
      Width           =   2775
   End
   Begin VB.CommandButton btnSecure 
      Caption         =   "Meter S&ecure"
      Height          =   975
      Left            =   5520
      TabIndex        =   1
      Top             =   1800
      Width           =   2775
   End
   Begin VB.CommandButton btnSimple 
      Caption         =   "Meter &Simple"
      Height          =   855
      Left            =   5520
      TabIndex        =   0
      Top             =   600
      Width           =   2775
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub MeterSimple()
    
    Dim objSession As Session
    Dim objMeter As Meter
    
    ' Create the meter object
    Set objMeter = New Meter
    
    ' start up the SDK
    objMeter.Startup
    
    ' Set the timeout and number of server retries
    objMeter.HTTPTimeout = 30
    objMeter.HTTPRetries = 1
    
    ' priority, servername, port, secure, username, password
    objMeter.AddServer 0, txtServer.Text, DEFAULT_HTTP_PORT, False, "", ""
    
    ' create a test session
    Set objSession = objMeter.CreateSession("metratech.com/TestService")
    
    ' set the session properties
    objSession.InitProperty "AccountName", txtAccount.Text
    objSession.InitProperty "Description", txtDescription.Text
    objSession.InitProperty "Units", CDbl(txtUnits.Text)
    objSession.InitProperty "Time", Now
    
    ' close the session
    objSession.Close
    
    ' shutdown the SDK
    objMeter.Shutdown

End Sub

Private Sub MeterSessionSet()
    
    Dim objSessionSet As SessionSet
    Dim objSession As Session
    Dim objMeter As Meter
    Dim nSessions As Integer
    
    ' Create the meter object
    Set objMeter = New Meter
    
    ' start up the SDK
    objMeter.Startup
    
    ' Set the timeout and number of server retries
    objMeter.HTTPTimeout = 30
    objMeter.HTTPRetries = 1
    
    ' priority, servername, port, secure, username, password
    objMeter.AddServer 0, txtServer.Text, DEFAULT_HTTP_PORT, False, "", ""
    
    ' create a session set to hold the test sessions
    Set objSessionSet = objMeter.CreateSessionSet()
    
    nSessions = 10
    
    For i = 1 To nSessions      ' Create the test sessions in the set
        Set objSession = objSessionSet.CreateSession("metratech.com/TestService")
        ' set the session properties
        objSession.InitProperty "AccountName", txtAccount.Text
        objSession.InitProperty "Description", txtDescription.Text
        objSession.InitProperty "Units", CDbl(txtUnits.Text)
        objSession.InitProperty "Time", Now
    Next
    
    ' close the session
    objSessionSet.Close
    
    ' shutdown the SDK
    objMeter.Shutdown

End Sub

Private Sub MeterSynchronous()
    
    Dim objSession As Session
    Dim objResult As Session
    Dim objMeter As Meter
    
    ' Create the meter object
    Set objMeter = New Meter
    
    ' start up the SDK
    objMeter.Startup
    
    ' Set the timeout and number of server retries
    objMeter.HTTPTimeout = 30
    objMeter.HTTPRetries = 1
    
    ' priority, servername, port, secure, username, password
    objMeter.AddServer 0, txtServer.Text, DEFAULT_HTTP_PORT, False, "", ""
    
    ' create a test session
    Set objSession = objMeter.CreateSession("metratech.com/TestService")
    
    ' Request a response session
    objSession.RequestResponse = True

    ' set the session properties
    objSession.InitProperty "AccountName", txtAccount.Text
    objSession.InitProperty "Description", txtDescription.Text
    objSession.InitProperty "Units", CDbl(txtUnits.Text)
    objSession.InitProperty "Time", Now
   
    ' close the session
    objSession.Close
    
    ' Get the result session
    Set objResult = objSession.ResultSession
    
    ' Get the property added by the test stage
    amount = objResult.GetProperty("_Amount", MTC_DT_DOUBLE)
        
    ' Display the property
    txtAmount.Text = amount
    
    ' shutdown the SDK
    objMeter.Shutdown

End Sub

Private Sub MeterSecure()
    
    Dim objSession As Session
    Dim objMeter As Meter
    
    ' Create the meter object
    Set objMeter = New Meter
    
    ' start up the SDK
    objMeter.Startup
    
    ' Set the timeout and number of server retries
    objMeter.HTTPTimeout = 30
    objMeter.HTTPRetries = 1
    
    ' priority, servername, port, secure, username, password
    objMeter.AddServer 0, txtServer.Text, DEFAULT_HTTPS_PORT, True, txtUser.Text, txtPassword.Text
    
    ' create a test session
    Set objSession = objMeter.CreateSession("metratech.com/TestService")
    
    ' set the session properties
    objSession.InitProperty "AccountName", txtAccount.Text
    objSession.InitProperty "Description", txtDescription.Text
    objSession.InitProperty "Units", CDbl(txtUnits.Text)
    objSession.InitProperty "Time", Now
    
    ' close the session
    objSession.Close
    
    ' shutdown the SDK
    objMeter.Shutdown

End Sub

Private Sub MeterLocalMode()

    Dim objSession As Session
    Dim objMeter As Meter
    
    ' Create the meter object
    Set objMeter = New Meter
    
    ' start up the SDK
    objMeter.Startup
    
    ' Set the timeout and number of server retries
    objMeter.HTTPTimeout = 30
    objMeter.HTTPRetries = 1
    
    ' priority, servername, port, secure, username, password
    objMeter.AddServer 0, txtServer.Text, DEFAULT_HTTP_PORT, False, "", ""
    
    ' turn on local mode by setting a file
    objMeter.LocalModePath = "C:\temp\comlocalmode.dat"
    
    ' Meter 10 test sessions locally
    For i = 1 To 10
        ' create a test session
        Set objSession = objMeter.CreateSession("metratech.com/TestService")
    
        ' set the session properties
        objSession.InitProperty "AccountName", txtAccount.Text
        objSession.InitProperty "Description", txtDescription.Text
        objSession.InitProperty "Units", CDbl(txtUnits.Text)
        objSession.InitProperty "Time", Now
   
        ' close the session
        objSession.Close
    Next i
    
    ' turn off local mode
    objMeter.LocalModePath = ""

    ' set a journal for replay
    ' this is used to keep track of the status
    objMeter.MeterJournal = "c:\temp\meterstore.dat"

    ' play it back
    objMeter.MeterFile "C:\temp\comlocalmode.dat"

    ' shutdown the SDK
    objMeter.Shutdown
     
 
End Sub


Private Sub MeterFailover()
    
    Dim objSession As Session
    Dim objMeter As Meter
    
    ' Create the meter object
    Set objMeter = New Meter
    
    ' start up the SDK
    objMeter.Startup
    
    ' Set the timeout and number of server retries
    objMeter.HTTPTimeout = 30
    objMeter.HTTPRetries = 2
    
    ' add a primary server
    ' priority, servername, port, secure, username, password
    objMeter.AddServer 5, "myserver", DEFAULT_HTTP_PORT, False, "", ""
    
    ' add a backup server
    ' priority, servername, port, secure, username, password
    objMeter.AddServer 0, txtServer.Text, DEFAULT_HTTP_PORT, False, "", ""
    
    
    ' create a test session
    Set objSession = objMeter.CreateSession("metratech.com/TestService")
    
    ' set the session properties
    objSession.InitProperty "AccountName", txtAccount.Text
    objSession.InitProperty "Description", txtDescription.Text
    objSession.InitProperty "Units", CDbl(txtUnits.Text)
    objSession.InitProperty "Time", Now
    
    ' close the session
    objSession.Close
    
    ' shutdown the SDK
    objMeter.Shutdown

End Sub

Private Sub MeterCompound()
    
    Dim objParent As Session
    Dim objChild As Session
    Dim objMeter As Meter
    
    ' Create the meter object
    Set objMeter = New Meter
    
    ' start up the SDK
    objMeter.Startup
    
    ' Set the timeout and number of server retries
    objMeter.HTTPTimeout = 30
    objMeter.HTTPRetries = 1
    
    ' priority, servername, port, secure, username, password
    objMeter.AddServer 0, txtServer.Text, DEFAULT_HTTP_PORT, False, "", ""
    
    ' create the parent session
    Set objParent = objMeter.CreateSession("metratech.com/testparent")
   
    ' init the properties in the parent
    
    objParent.InitProperty "AccountName", txtAccount.Text
    objParent.InitProperty "Description", txtDescription.Text
    objParent.InitProperty "Time", Now
    
    ' create some test children
    For i = 1 To 5
        ' create a child session
        Set objChild = objParent.CreateChildSession("metratech.com/TestService")
    
        ' set the session properties
        objChild.InitProperty "AccountName", txtAccount.Text
        objChild.InitProperty "Description", txtDescription.Text
        objChild.InitProperty "Units", CDbl(txtUnits.Text)
        objChild.InitProperty "Time", Now
    
    Next i
    
    ' close the parent which will close all the children
    objParent.Close
    
    ' shutdown the SDK
    objMeter.Shutdown

End Sub
    
    
Private Sub btnCompound_Click()
    MeterCompound
    MsgBox "Compound metering completed"
End Sub

Private Sub btnFail_Click()
    MeterFailover
    MsgBox "Failover metering completed"
End Sub

Private Sub btnLocalMode_Click()
    MeterLocalMode
    MsgBox "Local Mode metering completed"
End Sub

Private Sub btnSecure_Click()
    MeterSecure
    MsgBox "Secure metering completed"
End Sub

Private Sub btnSessionSet_Click()
    MeterSessionSet
    MsgBox "SessionSet metering completed"
End Sub

Private Sub btnSimple_Click()
    MeterSimple
    MsgBox "Simple metering completed"
End Sub

Private Sub btnSynchronous_Click()
    MeterSynchronous
    MsgBox "Sychronous metering completed"
End Sub
