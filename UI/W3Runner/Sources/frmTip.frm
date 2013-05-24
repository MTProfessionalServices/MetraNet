VERSION 5.00
Begin VB.Form frmTip 
   Caption         =   "Tip of the Day"
   ClientHeight    =   3105
   ClientLeft      =   2370
   ClientTop       =   2400
   ClientWidth     =   7710
   Icon            =   "frmTip.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3105
   ScaleWidth      =   7710
   StartUpPosition =   2  'CenterScreen
   WhatsThisButton =   -1  'True
   WhatsThisHelp   =   -1  'True
   Begin VB.CheckBox chkLoadTipsAtStartup 
      Caption         =   "&Show Tips at Startup"
      Height          =   315
      Left            =   60
      TabIndex        =   3
      Top             =   2700
      Width           =   2055
   End
   Begin VB.CommandButton cmdNextTip 
      Caption         =   "&Next Tip"
      Height          =   375
      Left            =   6480
      TabIndex        =   2
      Top             =   540
      Width           =   1215
   End
   Begin VB.PictureBox Picture1 
      BackColor       =   &H00FFFFFF&
      Height          =   2595
      Left            =   60
      Picture         =   "frmTip.frx":0442
      ScaleHeight     =   2535
      ScaleWidth      =   6315
      TabIndex        =   1
      Top             =   60
      Width           =   6375
      Begin VB.Label Label1 
         BackColor       =   &H00FFFFFF&
         Caption         =   "Did you know..."
         Height          =   255
         Left            =   540
         TabIndex        =   5
         Top             =   180
         Width           =   2655
      End
      Begin VB.Label lblTipText 
         BackColor       =   &H00FFFFFF&
         Height          =   1935
         Left            =   60
         TabIndex        =   4
         Top             =   540
         Width           =   6195
      End
   End
   Begin VB.CommandButton cmdOK 
      Cancel          =   -1  'True
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   6480
      TabIndex        =   0
      Top             =   60
      Width           =   1215
   End
End
Attribute VB_Name = "frmTip"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Dim Tips As New Collection ' The in-memory database of tips.
Const TIP_FILE = "FredRunner.tips.txt" ' Name of tips file
Dim CurrentTip As Long ' Index in collection of tip currently being displayed.

Private Sub DoNextTip()

    CurrentTip = CurrentTip + 1
    If Tips.Count < CurrentTip Then CurrentTip = 1
    frmTip.DisplayCurrentTip
    
    
End Sub

Function LoadTips(sFile As String) As Boolean

    Dim NextTip As String    ' Each tip read in from file.
    Dim InFile  As Integer   ' Descriptor for file.
    
    InFile = FreeFile ' Obtain the next free file descriptor.
    
    ' Make sure a file is specified.
    If sFile = "" Then
        LoadTips = False
        Exit Function
    End If
    
    ' Make sure the file exists before trying to open it.
    If Dir(sFile) = "" Then
        LoadTips = False
        Exit Function
    End If
    
    ' Read the collection from a text file.
    Open sFile For Input As InFile
    While Not EOF(InFile)
        Line Input #InFile, NextTip
        Tips.Add PreProcess(NextTip, "CRLF", vbNewLine, "TAB", vbTab)
    Wend
    Close InFile

    ' Display a tip at random.
    
    LoadTips = True
End Function
 

Private Sub cmdNextTip_Click()
    DoNextTip
End Sub

Private Sub cmdOK_Click()
    Unload Me
End Sub

Public Sub DisplayCurrentTip()
    If Tips.Count > 0 Then lblTipText.Caption = Tips.Item(CurrentTip)
End Sub

Private Sub Form_Unload(Cancel As Integer)
    AppOptions("ShowTips") = chkLoadTipsAtStartup.Value
End Sub

Public Function OpenDialog(Optional lngTipIndex As Long, Optional strTitle As String) As Boolean

    Dim ShowAtStartup As Long

    Load frmTip
    If (Len(strTitle)) Then
    
        frmTip.Caption = strTitle
    End If
    
    Randomize Timer
    
    If LoadTips(App.Path & "\" & TIP_FILE) = False Then ' Read in the tips file and display a tip at random.
        Exit Function
    End If
    
    chkLoadTipsAtStartup.Value = AppOptions("ShowTips", 1)
    
    CurrentTip = Int((Tips.Count * Rnd) + 1)
    
    If (lngTipIndex) Then CurrentTip = lngTipIndex
    
    frmTip.DisplayCurrentTip
    
    frmTip.Show vbModal
    Unload frmTip
End Function
