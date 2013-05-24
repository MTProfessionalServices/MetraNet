VERSION 5.00
Begin VB.Form frmSendKeys 
   Caption         =   "Form1"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   10
      Left            =   2280
      Top             =   1020
   End
End
Attribute VB_Name = "frmSendKeys"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_strKeys As String

Public Function SendKeys(strKeys As String, lngTimeToWait As Long) As Boolean
    Load Me
    m_strKeys = strKeys
    Timer1.Interval = lngTimeToWait
    Timer1.Enabled = True
End Function

Private Sub Timer1_Timer()
    Timer1.Enabled = False
    VBA.SendKeys m_strKeys, False
    DoEvents
    Unload Me
End Sub
