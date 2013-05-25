VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3165
   ClientLeft      =   60
   ClientTop       =   375
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3165
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Test"
      Height          =   615
      Left            =   1200
      TabIndex        =   0
      Top             =   600
      Width           =   1575
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim objRoutingQueue As Object

Private Sub Command1_Click()
    Dim lngTime  As Long
    lngTime = objRoutingQueue.WaitUntilEmpty(, Me)
    MsgBox lngTime
End Sub

Private Sub Form_Load()
    Set objRoutingQueue = CreateObject("MTTestApi.MTRoutingQueue")
    objRoutingQueue.Initialize
End Sub

Public Function RoutingQueueRefreh() As Boolean
    Caption = "Waiting " & Now()
End Function
