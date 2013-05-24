VERSION 5.00
Begin VB.Form dgData 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Edit Data Source"
   ClientHeight    =   3735
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   5475
   Icon            =   "dgData.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3735
   ScaleWidth      =   5475
   ShowInTaskbar   =   0   'False
   Begin VB.CheckBox ckUse 
      Caption         =   "Use in Config File"
      Height          =   615
      Left            =   2400
      TabIndex        =   5
      Top             =   3000
      Value           =   1  'Checked
      Width           =   1455
   End
   Begin VB.CommandButton btCopy 
      Caption         =   "Copy to Clipboard"
      Height          =   495
      Left            =   3960
      TabIndex        =   6
      Top             =   3120
      Width           =   1335
   End
   Begin VB.CommandButton btContext 
      Caption         =   "Get Serialized Context..."
      Height          =   495
      Left            =   120
      TabIndex        =   4
      Top             =   3120
      Width           =   2055
   End
   Begin VB.ComboBox txDB 
      Height          =   315
      ItemData        =   "dgData.frx":0442
      Left            =   1200
      List            =   "dgData.frx":044C
      TabIndex        =   7
      Top             =   120
      Width           =   4095
   End
   Begin VB.TextBox txPswd 
      Height          =   375
      Left            =   1200
      TabIndex        =   3
      Top             =   2520
      Width           =   2655
   End
   Begin VB.TextBox txUser 
      Height          =   375
      Left            =   1200
      TabIndex        =   2
      Top             =   1920
      Width           =   2655
   End
   Begin VB.TextBox txServer 
      Height          =   375
      Left            =   1200
      TabIndex        =   1
      Top             =   1320
      Width           =   2655
   End
   Begin VB.TextBox txDN 
      Height          =   375
      Left            =   1200
      TabIndex        =   0
      Top             =   720
      Width           =   2655
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Close"
      Default         =   -1  'True
      Height          =   375
      Left            =   4080
      TabIndex        =   8
      Top             =   720
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "DB Type"
      Height          =   495
      Left            =   120
      TabIndex        =   13
      Top             =   120
      Width           =   975
   End
   Begin VB.Label Label5 
      Caption         =   "Password"
      Height          =   255
      Left            =   120
      TabIndex        =   12
      Top             =   2640
      Width           =   975
   End
   Begin VB.Label Label4 
      Caption         =   "Username"
      Height          =   255
      Left            =   120
      TabIndex        =   11
      Top             =   2040
      Width           =   855
   End
   Begin VB.Label Label3 
      Caption         =   "Server Name (Pipeline)"
      Height          =   495
      Left            =   120
      TabIndex        =   10
      Top             =   1320
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "DB Name"
      Height          =   375
      Left            =   120
      TabIndex        =   9
      Top             =   720
      Width           =   975
   End
End
Attribute VB_Name = "dgData"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Public strSerial As String

Private Sub btContext_Click()
   dgContext.Show 1
End Sub

Private Sub btCopy_Click()
On Error GoTo errlog
   Clipboard.Clear
   Clipboard.SetText strSerial
   Exit Sub
errlog:
   MsgBox "Could not copy to Clipboard.", vbExclamation
   subErrLog "dgData:btCopy_Click"
End Sub

Private Sub CancelButton_Click()
On Error GoTo errlog:
   
   Dim DT As String, PD As String
   Dim ParentNode As String
   
   ParentNode = "xmlconfig/DatabaseConfig"
   Call ChangeValue(ParentNode, txDN, "DatabaseType")
   
   If txDB.ListIndex = 0 Then
      DT = "Mssql"
      PD = "sqloledb"
   Else
      DT = "Sybase"
      PD = "Sybase ASE OLE DB Provider"
   End If
   ParentNode = "xmlconfig/DatabaseConfig"
   Call ChangeValue(ParentNode, DT, "DatabaseType")
   ParentNode = "xmlconfig/DatabaseConfig"
   Call ChangeValue(ParentNode, PD, "Provider")
   
   ParentNode = "xmlconfig/DatabaseConfig"
   Call ChangeValue(ParentNode, txServer, "DataServer")
   
   ParentNode = "xmlconfig/DatabaseConfig"
   Call ChangeValue(ParentNode, txDN, "DataBase")
   
   ParentNode = "xmlconfig/DatabaseConfig"
   Call ChangeValue(ParentNode, txUser, "UserName")
   
   ParentNode = "xmlconfig/DatabaseConfig"
   Call ChangeValue(ParentNode, txPswd, "Password")
   
   If ckUse.Value = 1 Then
      If Len(strSerial) > 0 Then
         ParentNode = "xmlconfig/SessionContext"
         Call ChangeValue(ParentNode, strSerial, "SerializedContextStr")
      End If
   End If
   
   'persist the vars before unloading
   form2.txDataSource = txDN
   If txDB.ListIndex = 0 Then
      DBType = "Mssql"
   Else
      DBType = "Sybase"
   End If
   DBServer = txServer
   DBUser = txUser
   DBPswd = txPswd
   
errlog:
   Unload Me
   subErrLog "dgData:CancelButton_Click"
End Sub

Private Sub Form_Load()
On Error GoTo errlog

   txDN = DBName
   If DBType = "Mssql" Then
      txDB.ListIndex = 0
   Else
      txDB.ListIndex = 1
   End If
   txServer = DBServer
   txUser = DBUser
   txPswd = DBPswd
   
   ContextStatus

errlog:
   subErrLog "dgData:Form_Load"
End Sub

Public Sub ContextStatus()
On Error GoTo errlog

   If Len(strSerial) > 0 Then
      ckUse.Enabled = True
      btCopy.Enabled = True
   Else
      ckUse.Enabled = False
      btCopy.Enabled = False
   End If
   
errlog:
   subErrLog "dgData:Form_Load"
End Sub
 
Private Sub txDN_Change()
   txDN.SelLength = Len(txDN)
End Sub

Private Sub txUser_Change()
   txUser.SelLength = Len(txUser)
End Sub

Private Sub txServer_Change()
   txServer.SelLength = Len(txServer)
End Sub

Private Sub txPswd_Change()
   txPswd.SelLength = Len(txPswd)
End Sub

