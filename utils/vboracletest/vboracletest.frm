VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   2505
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   3750
   LinkTopic       =   "Form1"
   ScaleHeight     =   2505
   ScaleWidth      =   3750
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton TestOracleDriver 
      Caption         =   "TestOracleDriver"
      Height          =   372
      Left            =   480
      TabIndex        =   1
      Top             =   1320
      Width           =   2415
   End
   Begin VB.CommandButton TestMSDriver 
      Caption         =   "TestMSDriver"
      Height          =   372
      Left            =   480
      TabIndex        =   0
      Top             =   480
      Width           =   2415
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit


Dim objConn As ADODB.Connection
Dim rs As ADODB.Recordset
Dim strComplete As String
Dim Record As String

Private Sub Command1_Click()

    strComplete = "select * from test"
    
    Dim Ora_Conn As ADODB.Connection
    Dim Ora_ConnStr As String
    
    Set Ora_Conn = New ADODB.Connection
    Ora_ConnStr = "UID=rb;PWD=rb;DRIVER={Microsoft ODBC for Oracle};SERVER=netmeter.metratech.com;DSN=orcl"
    Ora_Conn.ConnectionString = Ora_ConnStr
    Ora_Conn.Open
    
    Ora_Conn.Close
    Set objConn = Nothing
    MsgBox ("Done!")

End Sub


Private Sub TestOracleDriver_Click()

    strComplete = "select * from test"
    
    Dim Ora_Conn As ADODB.Connection
    Dim Ora_ConnStr As String
    
    Set Ora_Conn = New ADODB.Connection
    Ora_ConnStr = "DRIVER={Oracle in OraDb10g_home1};SERVER=netmeter.metratech.com;DBQ=netmeter.metratech.com;DATABASE=NetMeterrb;UID=rb;PWD=rb"
    Ora_Conn.ConnectionString = Ora_ConnStr
    Ora_Conn.Open
    
    Ora_Conn.Close
    Set objConn = Nothing
    MsgBox ("Done!")
    
End Sub
