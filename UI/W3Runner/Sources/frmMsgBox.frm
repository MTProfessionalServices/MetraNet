VERSION 5.00
Begin VB.Form frmMsgbox 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Caption"
   ClientHeight    =   1605
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   10005
   Icon            =   "frmMsgBox.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1605
   ScaleWidth      =   10005
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox Label 
      BackColor       =   &H80000004&
      Height          =   1035
      Left            =   60
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   1
      Top             =   60
      Width           =   9915
   End
   Begin VB.Timer Timer2 
      Interval        =   1000
      Left            =   1140
      Top             =   1200
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Height          =   375
      Left            =   4560
      TabIndex        =   0
      Top             =   1200
      Width           =   1215
   End
End
Attribute VB_Name = "frmMsgbox"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_strTitle          As String
Private lngSecondCounter    As Long
Private m_lngTimeOut        As Long

Public Function OpenDialog(ByVal strMessage As String, Optional ByVal strTitle As String) As Boolean
    
    m_lngTimeOut = g_objW3RunnerObject.MsgBoxTimeOut
    
    lngSecondCounter = 0
    
    
    Timer2.Enabled = True

    CloseSplashWindowIfOpen

    m_strTitle = IIf(Len(strTitle), strTitle, W3RUNNER_EXE_FILE_NAME)
    Me.Caption = m_strTitle
    Me.Label.Text = strMessage
        
    On Error Resume Next
    Me.Show vbModal
    If (Err.Number) Then
        MsgBox strMessage, , m_strTitle
        Err.Clear
    End If
    
    
    Timer2.Enabled = False
    Unload Me
End Function



Private Sub OKButton_Click()
    Hide
End Sub

Private Sub Timer2_Timer()
    Me.Caption = m_strTitle & " " & Now
    lngSecondCounter = lngSecondCounter + 1
    If lngSecondCounter > m_lngTimeOut Then
        OKButton_Click
    End If
End Sub
