VERSION 5.00
Begin VB.Form frmBegin 
   AutoRedraw      =   -1  'True
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "#"
   ClientHeight    =   5025
   ClientLeft      =   1740
   ClientTop       =   1410
   ClientWidth     =   7110
   ClipControls    =   0   'False
   HasDC           =   0   'False
   Icon            =   "begin.frx":0000
   MaxButton       =   0   'False
   MinButton       =   0   'False
   NegotiateMenus  =   0   'False
   ScaleHeight     =   5025
   ScaleWidth      =   7110
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox Picture1 
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   2505
      Left            =   60
      ScaleHeight     =   2505
      ScaleWidth      =   2790
      TabIndex        =   8
      Top             =   120
      Width           =   2790
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&Next >"
      CausesValidation=   0   'False
      Default         =   -1  'True
      Height          =   375
      Left            =   4140
      TabIndex        =   0
      Top             =   4560
      Width           =   1395
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   5580
      Style           =   1  'Graphical
      TabIndex        =   1
      Top             =   4560
      Width           =   1395
   End
   Begin VB.TextBox txtmessage 
      BackColor       =   &H80000000&
      Height          =   2535
      Left            =   2940
      MultiLine       =   -1  'True
      TabIndex        =   7
      Top             =   120
      Width           =   4035
   End
   Begin VB.Frame fraDir 
      Caption         =   "#"
      Height          =   660
      Left            =   300
      TabIndex        =   5
      Top             =   3180
      Width           =   6510
      Begin VB.CommandButton cmdChDir 
         Caption         =   "#"
         Height          =   390
         Left            =   4230
         MaskColor       =   &H00000000&
         TabIndex        =   2
         Top             =   195
         Width           =   2070
      End
      Begin VB.Label lblDestDir 
         Caption         =   "#"
         Height          =   225
         Left            =   180
         TabIndex        =   6
         Top             =   270
         Width           =   3360
      End
   End
   Begin VB.Label lblInstallMsg 
      AutoSize        =   -1  'True
      Caption         =   "*"
      Height          =   195
      Left            =   11111
      TabIndex        =   4
      Top             =   915
      Visible         =   0   'False
      Width           =   5565
      WordWrap        =   -1  'True
   End
   Begin VB.Label lblBegin 
      AutoSize        =   -1  'True
      Caption         =   "#"
      Height          =   192
      Left            =   11111
      TabIndex        =   3
      Top             =   132
      Visible         =   0   'False
      Width           =   6456
      WordWrap        =   -1  'True
   End
End
Attribute VB_Name = "frmBegin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdChDir_Click()
    ShowPathDialog

    If gintRetVal = gintRET_CONT Then
        lblDestDir.Caption = gstrDestDir
        cmdOK.SetFocus
    End If
End Sub

Private Sub cmdExit_Click()
    ExitSetup Me, gintRET_EXIT
End Sub

Private Sub cmdOK_Click()
    TestAndShowUninstallMessage
    If IsValidDestDir(gstrDestDir) Then
        Unload Me
        DoEvents
    End If
    Debug.Print resDRVREAD
End Sub

Private Sub Form_Load()
    Dim intRes As Integer
    Dim yAdjust As Integer

    SetFormFont Me
    fraDir.Caption = ResolveResString(resFRMDIRECTORY)
    cmdChDir.Caption = ResolveResString(resBTNCHGDIR)
    cmdExit.Caption = ResolveResString(resBTNEXIT)
    lblBegin.Caption = ResolveResString(resLBLBEGIN)
    cmdOK.ToolTipText = ResolveResString(resBTNTOOLTIPBEGIN)
    
    Caption = gstrTitle
    If gfForceUseDefDest Then
        intRes = resSPECNODEST
    Else
        intRes = resSPECDEST
    End If
    lblInstallMsg.Caption = ResolveResString(intRes, gstrPIPE1, gstrAppName)
    lblDestDir.Caption = gstrDestDir

    If gfForceUseDefDest Then
'        'We are forced to use the default destination directory, so the user
'        '  will not be able to change it.
'        fraDir.Visible = False
'
'        'Close in the blank space on the form by moving the Exit button to where this frame
'        'currently is, and adjusting the size of the form respectively
'        yAdjust = cmdExit.Top - linTopOfExitButtonIfNoDestDir.Y1
'        cmdExit.Top = cmdExit.Top - yAdjust
'        Height = Height - yAdjust
    End If
    
    SetObjectsPos Me, CUST_MSG_0003
    
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    HandleFormQueryUnload UnloadMode, Cancel, Me
End Sub


Public Function TestAndShowUninstallMessage() As Boolean

    m_strInstallPath = lblDestDir
    m_strFlogViewerExeFileName = lblDestDir & APP_EXE_NAME
    
    If (FileExists(m_strFlogViewerExeFileName)) Then
                
        MsgBox CUST_MSG_0001, vbOKOnly + vbCritical, APP_TITLE
        End
    End If
    TestAndShowUninstallMessage = True
End Function




Public Function FileCopyMe(ByVal sourceFileName As String, ByVal destFileName As String) As Boolean

  On Error GoTo ErrMgr
  
  FileCopyMe = True
  VBA.FileCopy sourceFileName, destFileName
  Exit Function
  
ErrMgr:

  Err.Clear
  
End Function

