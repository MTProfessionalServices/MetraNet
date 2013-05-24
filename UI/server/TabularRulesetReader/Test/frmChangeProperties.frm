VERSION 5.00
Begin VB.Form frmChangeProperties 
   Caption         =   "Change Ruleset Properties"
   ClientHeight    =   3405
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   3645
   LinkTopic       =   "Form1"
   ScaleHeight     =   3405
   ScaleWidth      =   3645
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox txtHelpID 
      Height          =   285
      Left            =   1440
      TabIndex        =   14
      Top             =   2280
      Width           =   2055
   End
   Begin VB.TextBox txtHelpFile 
      Height          =   285
      Left            =   1440
      TabIndex        =   12
      Top             =   1920
      Width           =   2055
   End
   Begin VB.TextBox txtActionsHeader 
      Height          =   285
      Left            =   1440
      TabIndex        =   10
      Top             =   1560
      Width           =   2055
   End
   Begin VB.TextBox txtConditionsHeader 
      Height          =   285
      Left            =   1440
      TabIndex        =   8
      Top             =   1200
      Width           =   2055
   End
   Begin VB.TextBox txtCaption 
      Height          =   285
      Left            =   1440
      TabIndex        =   6
      Top             =   840
      Width           =   2055
   End
   Begin VB.TextBox txtPlugIn 
      Height          =   285
      Left            =   1440
      TabIndex        =   4
      Top             =   480
      Width           =   2055
   End
   Begin VB.TextBox txtServiceDef 
      Height          =   285
      Left            =   1440
      TabIndex        =   2
      Top             =   120
      Width           =   2055
   End
   Begin VB.CommandButton btnOK 
      Caption         =   "&OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   480
      TabIndex        =   1
      Top             =   2880
      Width           =   1455
   End
   Begin VB.CommandButton btnCancel 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   375
      Left            =   2040
      TabIndex        =   0
      Top             =   2880
      Width           =   1455
   End
   Begin VB.Label Label7 
      Caption         =   "Help ID"
      Height          =   255
      Left            =   120
      TabIndex        =   15
      Top             =   2280
      Width           =   1335
   End
   Begin VB.Label Label6 
      Caption         =   "Help File"
      Height          =   255
      Left            =   120
      TabIndex        =   13
      Top             =   1920
      Width           =   1335
   End
   Begin VB.Label Label5 
      Caption         =   "Actions Header"
      Height          =   255
      Left            =   120
      TabIndex        =   11
      Top             =   1560
      Width           =   1335
   End
   Begin VB.Label Label4 
      Caption         =   "Conditions Header"
      Height          =   255
      Left            =   120
      TabIndex        =   9
      Top             =   1200
      Width           =   1335
   End
   Begin VB.Label Label3 
      Caption         =   "Caption"
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   840
      Width           =   1335
   End
   Begin VB.Label Label1 
      Caption         =   "Plug-In"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   480
      Width           =   1335
   End
   Begin VB.Label Label2 
      Caption         =   "Service Definition"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   120
      Width           =   1335
   End
End
Attribute VB_Name = "frmChangeProperties"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit


Private Sub btnCancel_Click()
    Unload Me
End Sub

Private Sub btnOK_Click()
    frmMainTest.mobjTRReader.ServiceDefinition = txtServiceDef
    frmMainTest.mobjTRReader.PlugIn = txtPlugIn
    frmMainTest.mobjTRReader.Caption = txtCaption
    frmMainTest.mobjTRReader.ConditionsHeader = txtConditionsHeader
    frmMainTest.mobjTRReader.ActionsHeader = txtActionsHeader
    frmMainTest.mobjTRReader.HelpFile = txtHelpFile
    frmMainTest.mobjTRReader.HelpID = txtHelpID
    Unload Me

End Sub

Private Sub Form_Load()
    txtServiceDef = frmMainTest.mobjTRReader.ServiceDefinition
    txtPlugIn = frmMainTest.mobjTRReader.PlugIn
    txtCaption = frmMainTest.mobjTRReader.Caption
    txtConditionsHeader = frmMainTest.mobjTRReader.ConditionsHeader
    txtActionsHeader = frmMainTest.mobjTRReader.ActionsHeader
    txtHelpFile = frmMainTest.mobjTRReader.HelpFile
    txtHelpID = frmMainTest.mobjTRReader.HelpID
End Sub
