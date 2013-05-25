VERSION 5.00
Begin VB.Form frmTip 
   Caption         =   "Tip of the Day"
   ClientHeight    =   2715
   ClientLeft      =   2370
   ClientTop       =   2400
   ClientWidth     =   5100
   Icon            =   "frmTip.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2715
   ScaleWidth      =   5100
   StartUpPosition =   2  'CenterScreen
   WhatsThisButton =   -1  'True
   WhatsThisHelp   =   -1  'True
   Begin TestHarness.HttpBGDownLoader HttpBGDownLoader 
      Left            =   4440
      Top             =   1800
      _ExtentX        =   423
      _ExtentY        =   423
   End
   Begin VB.CheckBox chkLoadTipsAtStartup 
      Caption         =   "&Show Tips at Startup"
      Height          =   315
      Left            =   60
      TabIndex        =   3
      Top             =   2340
      Width           =   2055
   End
   Begin VB.CommandButton cmdNextTip 
      Caption         =   "&Next Tip"
      Height          =   375
      Left            =   3840
      TabIndex        =   2
      Top             =   540
      Width           =   1215
   End
   Begin VB.PictureBox Picture1 
      BackColor       =   &H00FFFFFF&
      Height          =   2235
      Left            =   60
      Picture         =   "frmTip.frx":0442
      ScaleHeight     =   2175
      ScaleWidth      =   3675
      TabIndex        =   1
      Top             =   60
      Width           =   3735
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
         Height          =   1635
         Left            =   360
         TabIndex        =   4
         Top             =   480
         Width           =   3195
      End
   End
   Begin VB.CommandButton cmdOK 
      Cancel          =   -1  'True
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   3840
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
Const TIP_FILE = "tip.txt" ' Name of tips file
Dim CurrentTip As Long ' Index in collection of tip currently being displayed.

Private Sub DoNextTip()

    CurrentTip = CurrentTip + 1
    If Tips.count < CurrentTip Then CurrentTip = 1
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
        Tips.Add NextTip
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

Private Sub Form_Load()

    Dim ShowAtStartup As Long
    Randomize Timer
    
    ' Read in the tips file and display a tip at random.
    If LoadTips(App.Path & "\" & TIP_FILE) = False Then
        
    End If
    
    chkLoadTipsAtStartup.Value = AppOptions("ShowTips", 1)
    
    CurrentTip = Int((Tips.count * Rnd) + 1)
    frmTip.DisplayCurrentTip
    
End Sub

Public Sub DisplayCurrentTip()
    If Tips.count > 0 Then lblTipText.Caption = Tips.Item(CurrentTip)
End Sub

Private Sub Form_Unload(Cancel As Integer)
    AppOptions("ShowTips") = chkLoadTipsAtStartup.Value
End Sub
