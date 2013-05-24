VERSION 5.00
Begin VB.Form frmProtocol 
   Caption         =   "HTTP Protocol"
   ClientHeight    =   3330
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   5130
   Icon            =   "frmProtocols.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   3330
   ScaleWidth      =   5130
   StartUpPosition =   3  'Windows Default
   Begin VB.ListBox lstProtocol 
      Height          =   2985
      Left            =   60
      TabIndex        =   0
      Top             =   60
      Width           =   4995
   End
End
Attribute VB_Name = "frmProtocol"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()
    Dim w As New cWindows
    w.SetWinTopMost Me, True
    g_objIniFile.FormSaveRestore Me, False, True
End Sub

Public Function AddHTTP(strHTTP As String) As Boolean

    Dim varStrings
    Dim varString
    
    varStrings = Split(Replace(strHTTP, vbNewLine, Chr(1)), Chr(1))
    
    For Each varString In varStrings
    
        lstProtocol.AddItem CStr(varString)
    Next
    lstProtocol.ListIndex = lstProtocol.NewIndex
    lstProtocol.Refresh
End Function

Private Sub Form_Resize()
    lstProtocol.Left = 0
    lstProtocol.Top = 0
    lstProtocol.Width = Width - (Screen.TwipsPerPixelX * 10)
    lstProtocol.Height = Height - (Screen.TwipsPerPixelX * 32)
End Sub

Private Sub Form_Unload(Cancel As Integer)
    g_objIniFile.FormSaveRestore Me, True, True
End Sub

Private Sub lstProtocol_DblClick()
    MsgBox lstProtocol.Text
End Sub
