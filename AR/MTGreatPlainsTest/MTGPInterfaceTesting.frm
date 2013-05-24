VERSION 5.00
Object = "{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}#1.1#0"; "shdocvw.dll"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Begin VB.Form MTGPInterfaceTesting 
   Caption         =   "MT GP Interface Testing"
   ClientHeight    =   10770
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   11805
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   10770
   ScaleWidth      =   11805
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton btnEnvironmentTest 
      Caption         =   "Environment Tests"
      Height          =   375
      Left            =   240
      TabIndex        =   24
      Top             =   120
      Width           =   1815
   End
   Begin VB.CommandButton btnCanDeleteBatches 
      Caption         =   "Can Delete Batches"
      Height          =   375
      Index           =   0
      Left            =   120
      TabIndex        =   23
      Top             =   6600
      Width           =   2055
   End
   Begin VB.CommandButton btnCanDeleteAdjustments 
      Caption         =   "Can Delete Adjustments"
      Height          =   375
      Index           =   0
      Left            =   4200
      TabIndex        =   22
      Top             =   6600
      Width           =   2055
   End
   Begin VB.CommandButton btnCanDeletePayments 
      Caption         =   "Can Delete Payments"
      Height          =   375
      Index           =   1
      Left            =   2160
      TabIndex        =   21
      Top             =   6600
      Width           =   2055
   End
   Begin VB.CommandButton btnDeleteBatches 
      Caption         =   "Delete Batches"
      Height          =   375
      Index           =   1
      Left            =   120
      TabIndex        =   20
      Top             =   6000
      Width           =   2055
   End
   Begin VB.CommandButton btnDeleteAdjustments 
      Caption         =   "Delete Adjustments"
      Height          =   375
      Index           =   1
      Left            =   4200
      TabIndex        =   19
      Top             =   6000
      Width           =   2055
   End
   Begin VB.CommandButton btnDeletePayments 
      Caption         =   "Delete Payments"
      Height          =   375
      Index           =   0
      Left            =   2160
      TabIndex        =   18
      Top             =   6000
      Width           =   2055
   End
   Begin SHDocVwCtl.WebBrowser WebBrowser1 
      Height          =   4335
      Left            =   6240
      TabIndex        =   17
      Top             =   960
      Width           =   5415
      ExtentX         =   9551
      ExtentY         =   7646
      ViewMode        =   0
      Offline         =   0
      Silent          =   0
      RegisterAsBrowser=   0
      RegisterAsDropTarget=   1
      AutoArrange     =   0   'False
      NoClientEdge    =   0   'False
      AlignLeft       =   0   'False
      NoWebView       =   0   'False
      HideFileNames   =   0   'False
      SingleClick     =   0   'False
      SingleSelection =   0   'False
      NoFolders       =   0   'False
      Transparent     =   0   'False
      ViewID          =   "{0057D0E0-3573-11CF-AE69-08002B2E1262}"
      Location        =   "http:///"
   End
   Begin VB.TextBox txtXML 
      Height          =   4335
      Left            =   120
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   16
      Top             =   960
      Width           =   5895
   End
   Begin VB.CommandButton btnMoveBalance 
      Caption         =   "Move Balances"
      Height          =   375
      Left            =   4200
      TabIndex        =   15
      Top             =   7200
      Width           =   2055
   End
   Begin VB.CommandButton btnGetBalanceDetails 
      Caption         =   "Get Balance Details"
      Height          =   375
      Left            =   8400
      TabIndex        =   14
      Top             =   6600
      Width           =   2055
   End
   Begin VB.CommandButton btnGetBalances 
      Caption         =   "Get Balances"
      Height          =   375
      Left            =   6360
      TabIndex        =   13
      Top             =   6600
      Width           =   2055
   End
   Begin VB.CommandButton btnApplyCredits 
      Caption         =   "Apply Credits"
      Height          =   375
      Left            =   2160
      TabIndex        =   10
      Top             =   7200
      Width           =   2055
   End
   Begin VB.CommandButton btnRunAging 
      Caption         =   "Run Aging"
      Height          =   375
      Left            =   120
      TabIndex        =   9
      Top             =   7200
      Width           =   2055
   End
   Begin VB.CommandButton btnCreateAdjustments 
      Caption         =   "Create Adjustments"
      Height          =   375
      Left            =   6240
      TabIndex        =   8
      Top             =   5520
      Width           =   1695
   End
   Begin VB.CommandButton btnCreatePayments 
      Caption         =   "Create Payments"
      Height          =   375
      Left            =   4200
      TabIndex        =   7
      Top             =   5520
      Width           =   2055
   End
   Begin VB.CommandButton btnCreateInvoices 
      Caption         =   "Create Invoices"
      Height          =   375
      Left            =   2160
      TabIndex        =   6
      Top             =   5520
      Width           =   2055
   End
   Begin VB.TextBox txtFileName 
      Height          =   375
      Left            =   4440
      TabIndex        =   3
      Top             =   600
      Width           =   6015
   End
   Begin MSComDlg.CommonDialog cmnDialog 
      Left            =   11160
      Top             =   3120
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.CommandButton btnLoad 
      Caption         =   "Load"
      Height          =   375
      Left            =   2160
      TabIndex        =   2
      Top             =   600
      Width           =   2175
   End
   Begin VB.CommandButton btnCreateUpdateAccounts 
      Caption         =   "Create/Update Accounts"
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   5520
      Width           =   2055
   End
   Begin VB.Image Image2 
      Height          =   435
      Left            =   10200
      Picture         =   "MTGPInterfaceTesting.frx":0000
      Top             =   120
      Width           =   1500
   End
   Begin VB.Image Image1 
      Height          =   435
      Left            =   8520
      Picture         =   "MTGPInterfaceTesting.frx":0CB1
      Stretch         =   -1  'True
      Top             =   120
      Width           =   1680
   End
   Begin VB.Label txtMessage 
      BorderStyle     =   1  'Fixed Single
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FF0000&
      Height          =   495
      Left            =   120
      TabIndex        =   12
      Top             =   10200
      Width           =   11535
      WordWrap        =   -1  'True
   End
   Begin VB.Label Label4 
      Caption         =   "Message"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   120
      TabIndex        =   11
      Top             =   9840
      Width           =   1935
   End
   Begin VB.Label Label2 
      Caption         =   "Error Message"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   7800
      Width           =   2775
   End
   Begin VB.Label Label1 
      Caption         =   "XML Document"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   720
      Width           =   1935
   End
   Begin VB.Label txtError 
      BorderStyle     =   1  'Fixed Single
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H000000C0&
      Height          =   1575
      Left            =   120
      TabIndex        =   1
      Top             =   8160
      Width           =   11535
      WordWrap        =   -1  'True
   End
End
Attribute VB_Name = "MTGPInterfaceTesting"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private parsed As parsedpath
Dim configState          'As Variant
Dim arInterfaceConfigObj 'As MTARConfig
Dim arInterfaceWriterObj 'As MTARWriter
Private Function GetTmpFile(FileName As String) As String

  If Len(FileName) = 0 Then
    FileName = "MTGPTest.txt"  ' Should change this to get a real temporary file name?
  End If

  Dim tmpDir As String
  tmpDir = Environ("TEMP")

  If (Len(tmpDir) > 0) Then
    If Mid(tmpDir, Len(tmpDir), 1) <> "\" And Mid(tmpDir, Len(tmpDir), 1) <> "/" Then
      tmpDir = tmpDir & "\"
    End If
    GetTmpFile = tmpDir & FileName
  Else
    GetTmpFile = FileName
  End If

End Function
Private Sub btnApplyCredits_Click()
    txtError.Caption = ""
    txtMessage.Caption = ""
    ApplyCredits
End Sub
Private Sub btnCanDeleteAdjustments_Click(Index As Integer)
    txtError.Caption = ""
    txtMessage.Caption = ""
    CanDeleteAdjustments
End Sub
Private Sub btnCanDeleteBatches_Click(Index As Integer)
    txtError.Caption = ""
    txtMessage.Caption = ""
    CanDeleteBatches
End Sub
Private Sub btnCanDeletePayments_Click(Index As Integer)
    txtError.Caption = ""
    txtMessage.Caption = ""
    CanDeletePayments
End Sub
Private Sub btnCreateAdjustments_Click()
    txtError.Caption = ""
    txtMessage.Caption = ""
    CreateAdjustments
End Sub
Private Sub btnCreatePayments_Click()
    txtError.Caption = ""
    txtMessage.Caption = ""
    CreatePayments
End Sub
Private Sub btnDeleteAdjustments_Click(Index As Integer)
    txtError.Caption = ""
    txtMessage.Caption = ""
    DeleteAdjustments
End Sub
Private Sub btnDeleteBatches_Click(Index As Integer)
    txtError.Caption = ""
    txtMessage.Caption = ""
    DeleteBatches
End Sub
Private Sub btnDeletePayments_Click(Index As Integer)
    txtError.Caption = ""
    txtMessage.Caption = ""
    DeletePayments
End Sub

Private Sub btnEnvironmentTest_Click()
    Dim environmentTest As New AutomatedTest
    environmentTest.Show

End Sub

Private Sub btnGetBalances_Click()
    txtError.Caption = ""
    txtMessage.Caption = ""
    GetBalances
End Sub
Private Sub btnGetBalanceDetails_Click()
    txtError.Caption = ""
    txtMessage.Caption = ""
    GetBalanceDetails
End Sub
Private Sub btnLoad_Click()
Dim sPathtemp As String
Dim result As String
Dim oXML As Object
Dim LastLoadedPath As String
On Error Resume Next
txtError.Caption = ""
txtMessage.Caption = ""
LastLoadedPath = "t:\Development\Core\AR\data"
    With cmnDialog
        .Filter = "*.XML"
        .DialogTitle = "Choose XML file to Load"
        .CancelError = True
        sPathtemp = LastLoadedPath
        If Right$(sPathtemp, 1) = "\" Then
            sPathtemp = Left$(LastLoadedPath, Len(LastLoadedPath) - 1)
        End If
        .InitDir = sPathtemp
        .FilterIndex = filterloadposition
        .Flags = cdlOFNFileMustExist Or _
            cdlOFNHelpButton Or cdlOFNHideReadOnly
        .ShowOpen
        '------------------------------------------
        'The picturebox gets destroyed when the dialog
        'exits, so unload its parent form
        '------------------------------------------
        result = .FileName
    End With
    If result = "" Then
        Exit Sub
    End If
    txtFileName.Text = result
    Set oXML = CreateObject("MSXML2.DOMDocument.4.0")
    oXML.Load txtFileName.Text
    txtXML.Text = oXML.xml
    Set oXML = Nothing
    'WebBrowser1.Navigate result
    
End Sub
Private Sub btnCreateInvoices_Click()
    txtError.Caption = ""
    txtMessage.Caption = ""
    CreateInvoices
End Sub
Private Sub btnCreateUpdateAccounts_Click()
    txtError.Caption = ""
    txtMessage.Caption = ""
    CreateOrUpdateAccounts
End Sub
Private Sub btnMoveBalance_Click()
    txtError.Caption = ""
    txtMessage.Caption = ""
    MoveBalance ' txtFileName.Text
End Sub
Private Sub btnRunAging_Click()
    txtError.Caption = ""
    txtMessage.Caption = ""
    RunAging ' txtFileName.Text
End Sub
Function CreateOrUpdateAccounts()
  
  On Error GoTo errorhandler
  
  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure

  Dim domDoc As MSXML2.DOMDocument
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//CreateOrUpdateAccount/ExtAccountID")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If

  Set arInterfaceWriterObj = CreateObject("MetraTech.MTARWriter")
  Call arInterfaceWriterObj.CreateOrUpdateAccounts(domDoc.xml, configState)

  CreateOrUpdateAccounts = True
  
  txtMessage.Caption = "CreateUpdateAccounts Completed Successfully !!"
  Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function CreateInvoices()

  On Error GoTo errorhandler

  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure

  Dim domDoc As MSXML2.DOMDocument
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//CreateInvoice/InvoiceID")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If

  Set arInterfaceWriterObj = CreateObject("MetraTech.MTARWriter")
  Call arInterfaceWriterObj.CreateInvoices(domDoc.xml, configState)
 
  txtMessage.Caption = "CreateInvoices Completed Successfully !!"
Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function CreatePayments()

  On Error GoTo errorhandler

  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure

  Dim domDoc As MSXML2.DOMDocument
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//CreatePayment/PaymentID")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If

  Set arInterfaceWriterObj = CreateObject("MetraTech.MTARWriter")
  Call arInterfaceWriterObj.CreatePayments(domDoc.xml, configState)

  txtMessage.Caption = "CreatePayments Completed Successfully !!"
Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function CreateAdjustments()

  On Error GoTo errorhandler

  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure

  Dim domDoc As MSXML2.DOMDocument
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//CreateAdjustment/AdjustmentID")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If

  Set arInterfaceWriterObj = CreateObject("MetraTech.MTARWriter")
  Call arInterfaceWriterObj.CreateAdjustments(domDoc.xml, configState)

  txtMessage.Caption = "CreateAdjustments Completed Successfully !!"
Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function ApplyCredits()
  
  On Error GoTo errorhandler
    
  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure

  Set arInterfaceWriterObj = CreateObject("MetraTech.MTARWriter")
  Call arInterfaceWriterObj.ApplyCredits(configState)

  txtMessage.Caption = "Apply Credits Completed Successfully !!"
Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function RunAging()
  
  On Error GoTo errorhandler

  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure

  Dim domDoc As MSXML2.DOMDocument
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//RunAging")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If

  Set arInterfaceWriterObj = CreateObject("MetraTech.MTARWriter")
  Call arInterfaceWriterObj.RunAging(domDoc.xml, configState)

  txtMessage.Caption = "RunAging Completed Successfully !!"
  
Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function GetBalances()
  Dim domDoc As MSXML2.DOMDocument

  On Error GoTo errorhandler

  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//GetBalance/ExtAccountID")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If
  
  Set arInterfaceReaderObj = CreateObject("MTGreatPlainsExec.MTGreatPlainsReader")

  Dim results As String
  results = arInterfaceReaderObj.GetBalances(domDoc.xml, configState)

  Dim tmpFile As String
  tmpFile = GetTmpFile("Balances.xml")

  Dim resultDoc As MSXML2.DOMDocument
  Set resultDoc = New MSXML2.DOMDocument40
  resultDoc.loadXML (results)
  resultDoc.save tmpFile
  WebBrowser1.Navigate tmpFile

  txtMessage.Caption = "Balances fetched Successfully !!"
 Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function GetBalanceDetails()
  Dim resultDoc As MSXML2.DOMDocument
  Dim domDoc As MSXML2.DOMDocument

  On Error GoTo errorhandler

  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//GetBalanceDetails/ExtAccountID")

  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If
  
  Dim resultXml As String
  Set arInterfaceReaderObj = CreateObject("MetraTech.MTARReader")
  resultXml = arInterfaceReaderObj.GetBalanceDetails(domDoc.xml, configState)

  Dim tmpFileName As String
  tmpFileName = GetTmpFile("BalanceDetails.xml")

  Set resultDoc = New MSXML2.DOMDocument40
  resultDoc.loadXML (resultXml)
  resultDoc.save tmpFileName
  WebBrowser1.Navigate tmpFileName
  txtMessage.Caption = "Balance Details fetched Successfully !!"
 Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function MoveBalance()
  Dim resultDoc As MSXML2.DOMDocument
  Dim domDoc As MSXML2.DOMDocument

  On Error GoTo errorhandler
  
  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure

  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//MoveBalance")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If

  Set arInterfaceWriterObj = CreateObject("MetraTech.MTARWriter")
  Dim resultXml As String
  resultXml = arInterfaceWriterObj.MoveBalances(domDoc.xml, configState)

  Dim tmpFileName As String
  tmpFileName = GetTmpFile("MoveBalance.xml")

  Set resultDoc = New MSXML2.DOMDocument40
  resultDoc.loadXML (resultXml)
  resultDoc.save tmpFileName
  WebBrowser1.Navigate tmpFileName
  txtMessage.Caption = "Move Balance completed Successfully !!"
  
Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
  
End Function
Function DeleteAdjustments()
  On Error GoTo errorhandler

  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure

  Dim domDoc As MSXML2.DOMDocument
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//DeleteAdjustment/AdjustmentID")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If

  Set arInterfaceWriterObj = CreateObject("MetraTech.MTARWriter")
  Call arInterfaceWriterObj.DeleteAdjustments(domDoc.xml, configState)

  txtMessage.Caption = "DeleteAdjustments Completed Successfully !!"

errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function DeleteBatches()
  On Error GoTo errorhandler

  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure

  Dim domDoc As MSXML2.DOMDocument
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//DeleteBatch/BatchID")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If

  Set arInterfaceWriterObj = CreateObject("MetraTech.MTARWriter")
  Call arInterfaceWriterObj.DeleteBatches(domDoc.xml, configState)

  txtMessage.Caption = "DeleteBatches Completed Successfully !!"

errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function CanDeleteAdjustments()
  Dim resultDoc As MSXML2.DOMDocument
  Dim domDoc As MSXML2.DOMDocument
  
  On Error GoTo errorhandler
  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//CanDeleteAdjustment")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If
  
  Set arInterfaceReaderObj = CreateObject("MTGreatPlainsExec.MTGreatPlainsReader")
  Set resultDoc = New MSXML2.DOMDocument40
  resultDoc.loadXML arInterfaceReaderObj.CanDeleteAdjustments(domDoc.xml, configState)

  Dim tmpFile As String
  tmpFile = GetTmpFile("MTGPTest.xml")

  resultDoc.save tmpFile
  WebBrowser1.Navigate tmpFile
  txtMessage.Caption = "CanDeleteAdjustments Success"
 Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function CanDeleteBatches()
  Dim resultDoc As MSXML2.DOMDocument
  Dim domDoc As MSXML2.DOMDocument
  
  On Error GoTo errorhandler
  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//CanDeleteBatch")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If
  
  Set arInterfaceReaderObj = CreateObject("MTGreatPlainsExec.MTGreatPlainsReader")
  Set resultDoc = New MSXML2.DOMDocument40
  resultDoc.loadXML arInterfaceReaderObj.CanDeleteBatches(domDoc.xml, configState)

  Dim tmpFile As String
  tmpFile = GetTmpFile("MTGPTest.xml")

  resultDoc.save tmpFile
  WebBrowser1.Navigate tmpFile
  txtMessage.Caption = "CanDeleteBatches Success"
 Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function DeletePayments()
  On Error GoTo errorhandler

  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure

  Dim domDoc As MSXML2.DOMDocument
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

'  Dim node As msxml2.IXMLDOMNode
'  Set node = domDoc.selectSingleNode("//DeletePayment/PaymentID")
'  If node Is Nothing Then
'      txtError.Caption = "Wrong XML Document Used for this operation"
'      Exit Function
' End If

  Set arInterfaceWriterObj = CreateObject("MetraTech.MTARWriter")
  Call arInterfaceWriterObj.DeletePayments(domDoc.xml, configState)

  txtMessage.Caption = "DeletePayments Completed Successfully !!"

errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function
Function CanDeletePayments()
  Dim resultDoc As MSXML2.DOMDocument
  Dim domDoc As MSXML2.DOMDocument
  
  On Error GoTo errorhandler
  Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
  Set configState = arInterfaceConfigObj.Configure
  Set domDoc = New MSXML2.DOMDocument40

  'Load the template XML
  domDoc.loadXML txtXML.Text
  
  'Make sure the file was loaded
  If domDoc.parseError Then
      txtError.Caption = "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError
      Exit Function
  End If

  Dim node As MSXML2.IXMLDOMNode
  Set node = domDoc.selectSingleNode("//CanDeletePayment")
  If node Is Nothing Then
      txtError.Caption = "Wrong XML Document Used for this operation"
      Exit Function
  End If
  
  Set arInterfaceReaderObj = CreateObject("MTGreatPlainsExec.MTGreatPlainsReader")
  Set resultDoc = New MSXML2.DOMDocument40
  resultDoc.loadXML arInterfaceReaderObj.CanDeletePayments(domDoc.xml, configState)

  Dim tmpFile As String
  tmpFile = GetTmpFile("MTGPTest.xml")

  resultDoc.save tmpFile
  WebBrowser1.Navigate tmpFile
  txtMessage.Caption = "CanDeletePayments Success"

 Exit Function
  
errorhandler:
  txtError.Caption = Err.Description
  Exit Function
End Function

Private Sub Form_Load()
   WebBrowser1.Navigate "about:blank"
End Sub
