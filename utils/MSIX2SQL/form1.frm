VERSION 5.00
Begin VB.Form form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "MSIX2SQL"
   ClientHeight    =   2970
   ClientLeft      =   45
   ClientTop       =   3750
   ClientWidth     =   5760
   Icon            =   "form1.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   OLEDropMode     =   1  'Manual
   ScaleHeight     =   2970
   ScaleWidth      =   5760
   StartUpPosition =   2  'CenterScreen
   Begin VB.CheckBox ckAll 
      Caption         =   "Generate for All Files"
      Height          =   255
      Left            =   240
      TabIndex        =   4
      Top             =   1920
      Width           =   2535
   End
   Begin VB.ComboBox txMSIX 
      Height          =   315
      Left            =   240
      OLEDropMode     =   1  'Manual
      TabIndex        =   2
      Top             =   1530
      Width           =   4215
   End
   Begin VB.CommandButton btBrowseMSIX 
      Caption         =   "Browse..."
      Height          =   375
      Left            =   4635
      OLEDropMode     =   1  'Manual
      TabIndex        =   3
      Top             =   1485
      Width           =   975
   End
   Begin VB.TextBox txConfig 
      Height          =   320
      Left            =   240
      OLEDropMode     =   1  'Manual
      TabIndex        =   0
      Top             =   600
      Width           =   4215
   End
   Begin VB.CommandButton btBrowseConfig 
      Caption         =   "Browse..."
      Default         =   -1  'True
      Height          =   375
      Left            =   4630
      TabIndex        =   1
      Top             =   600
      Width           =   975
   End
   Begin VB.CheckBox ckOpen 
      Caption         =   "Open File"
      Height          =   375
      Left            =   2450
      TabIndex        =   6
      Top             =   2400
      Value           =   1  'Checked
      Width           =   1050
   End
   Begin VB.CommandButton btParse 
      Caption         =   "Generate SQL Table"
      Height          =   405
      Left            =   3600
      TabIndex        =   5
      Top             =   2400
      Width           =   2025
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Close"
      Height          =   375
      Left            =   240
      TabIndex        =   7
      Top             =   2400
      Width           =   1215
   End
   Begin VB.Label lbReg 
      Caption         =   "Optional: Specify an MSIXDEF file (if no DB config file)"
      Height          =   315
      Left            =   240
      TabIndex        =   10
      Top             =   1200
      Width           =   4500
   End
   Begin VB.Label Label1 
      Caption         =   "Recommended: Specify a MetraConnect-DB config file"
      Height          =   255
      Left            =   240
      TabIndex        =   9
      Top             =   285
      Width           =   4215
   End
   Begin VB.Label lbFileName 
      ForeColor       =   &H80000008&
      Height          =   330
      Index           =   1
      Left            =   510
      TabIndex        =   8
      Top             =   2890
      Width           =   2145
   End
End
Attribute VB_Name = "form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
'© 2005 by MetraTech Corp.
'
'Author: Michael Ross
'MSIXDEF parsing by Simon Morton
'Last Update: 08-08-05
'
'Sorry, no time to comment this code yet...
'**************************************************

Option Explicit

Private Declare Function GetOpenFileName Lib "comdlg32.dll" Alias _
  "GetOpenFileNameA" (pOpenfilename As OPENFILENAME) As Long

Private Type OPENFILENAME
  lStructSize As Long
  hwndOwner As Long
  hInstance As Long
  lpstrFilter As String
  lpstrCustomFilter As String
  nMaxCustFilter As Long
  nFilterIndex As Long
  lpstrFile As String
  nMaxFile As Long
  lpstrFileTitle As String
  nMaxFileTitle As Long
  lpstrInitialDir As String
  lpstrTitle As String
  flags As Long
  nFileOffset As Integer
  nFileExtension As Integer
  lpstrDefExt As String
  lCustData As Long
  lpfnHook As Long
  lpTemplateName As String
End Type

Private VR As Variant
Private Button As Integer
Private blFalseCommand As Boolean
Private blKeyShift As Boolean
Private blCommand As Boolean

Private Sub CancelButton_Click()
    Form_Unload (0)
End Sub

Private Sub btParse_Click()
On Error GoTo FileError

   If Len(txConfig) > 0 And ckAll.Value = 1 Then
       StartParse
   Else
      If Len(txMSIX) = 0 Then
         MsgBox "Cannot proceed without a valid MSIXDEF file.", vbCritical
         Exit Sub
      End If
      
      If FileExists(txMSIX) = False Then
         MsgBox "The MSIXDEF file does not exist in this location.", vbCritical
         Exit Sub
      End If
      
'      If FileExists(txMSIX) = False Then
'          MsgBox "The specified MSIXDEF file cannot be found.", vbCritical
'          Exit Sub
'      End If
      
      If Len(txConfig) > 0 Then
         On Error Resume Next
         If Len(PrimaryKey(0)) = 0 Then
         On Error GoTo 0
            MsgBox "Some data, including Primary and Foreign keys, will be missing " _
            + "when generating files individually.", vbExclamation
         Else
            Dim response As Integer
            response = MsgBox("Do you want to use the Primary Key found in " + ConfigOnly + "?", 68)
            If response = vbNo Then
               blUseParent = False
               PurgeVars
            Else
               blUseParent = True
            End If
         End If
      Else
         blUseParent = False
         PurgeVars
      End If
    
      MSIXParse (txMSIX)
      
   End If

FileError:
    subErrLog ("btParse_Click")
End Sub

Private Sub ckAll_Click()
   If ckAll.Value = 1 Then
      btParse.Caption = "Generate SQL Tables"
      ckOpen.Caption = "Open Files"
   Else
      btParse.Caption = "Generate SQL Table"
      ckOpen.Caption = "Open File"
   End If
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
   If Shift = 1 Then blKeyShift = True
End Sub

Private Sub StartParse()
On Error GoTo errlog
    If Len(txConfig) = 0 Then
       PurgeVars
    Else
      If FileExists(txConfig) = False Then
         MsgBox "The specified configuration file cannot be found.", vbCritical
         Exit Sub
      End If
'      LoadConfig (txConfig)
      If ConfigParse(txConfig) Then
         FoundFiles
      End If
    End If
errlog:
   subErrLog ("StartParse")
End Sub

Private Sub PurgeVars()
   Erase PrimaryKey
   Erase KeyType
   Erase KeyLength
   ColumnPrefix = vbNullString
   TablePrefix = vbNullString
   ParentKey = vbNullString
   blUseParent = False
End Sub

Private Sub Form_Load()
On Error GoTo errlog
    If Len(Command$) > 0 Then
      blCommand = True
      If InStr(Command$, ".msixdef") > 0 Then
         txMSIX = Command$
         'only needed with command$ (file drag-drop)
         If Left$(txMSIX, 1) = Chr$(34) Then txMSIX = Right$(txMSIX, Len(txMSIX) - 1)     'eliminate left quote if any
         If Right$(txMSIX, 1) = Chr$(34) Then txMSIX = Left$(txMSIX, Len(txMSIX) - 1)     'eliminate right quote if any
      Else
         txConfig = Command$
         'only needed with command$ (file drag-drop)
         If Left$(txConfig, 1) = Chr$(34) Then txConfig = Right$(txConfig, Len(txConfig) - 1)     'eliminate left quote if any
         If Right$(txConfig, 1) = Chr$(34) Then txConfig = Left$(txConfig, Len(txConfig) - 1)     'eliminate right quote if any
         StartParse
      End If
    End If

    ckOpen.Value = Val(GetSetting("MSIXSQL", "Settings", "Open"))

errlog:
blKeyShift = False
End Sub

Private Sub btBrowseMSIX_Click()
On Error GoTo closeit

'   If InStr(txMSIX, "\\") > 0 Or InStr(txMSIX, "//") > 0 Then
'      MsgBox "UNC paths are not supported for browsing." + vbNewLine + vbNewLine + "Please enter a mapped drive letter.", vbInformation
'      Exit Sub
'   End If

   Dim OpenFile As OPENFILENAME
   Dim lReturn As Long
   Dim sFilter As String
   With OpenFile
      .lStructSize = Len(OpenFile)
      .hwndOwner = form1.hWnd
      .hInstance = App.hInstance
      sFilter = "MSIXDEF files (*.msixdef)" & Chr$(0) & "*.msixdef" & Chr$(0)
      .lpstrFilter = sFilter
      .nFilterIndex = 1
      .lpstrFile = String(257, 0)
      .nMaxFile = Len(OpenFile.lpstrFile) - 1
      .lpstrFileTitle = OpenFile.lpstrFile
      .nMaxFileTitle = OpenFile.nMaxFile
      If Len(txMSIX) > 0 Then
         .lpstrInitialDir = txMSIX
      Else
         If Len(GetSetting("MSIXSQL", "Settings", "LastMSIXDir")) > 0 Then
            .lpstrInitialDir = GetSetting("MSIXSQL", "Settings", "LastMSIXDir")
         Else
            .lpstrInitialDir = App.Path
         End If
      End If
      .lpstrTitle = "Browse"
      .flags = &H4     'hide read-only

      lReturn = GetOpenFileName(OpenFile)
      If lReturn > 0 Then
         txConfig = ""
         ckAll.Value = 0
         txMSIX = Trim$(.lpstrFile)
         btParse.SetFocus
      End If
   End With
   
closeit:
'    If Err.Number = 32755 Then Exit Sub
    subErrLog ("btBrowseMSIX_Click")
End Sub

Private Sub btBrowseConfig_Click()
On Error GoTo closeit
    
'   If InStr(txConfig, "\\") > 0 Or InStr(txConfig, "//") > 0 Then
'      MsgBox "UNC paths are not supported." + vbNewLine + vbNewLine + "Please enter a mapped drive letter.", vbInformation
'      Exit Sub
'   End If
   
   Dim OpenFile As OPENFILENAME
   Dim lReturn As Long
   Dim sFilter As String
   With OpenFile
      .lStructSize = Len(OpenFile)
      .hwndOwner = form1.hWnd
      .hInstance = App.hInstance
      sFilter = "Metering Config " + Chr(34) + "sdkconfig" + Chr(34) + " files (*.xml)" & Chr(0) & "*.xml" & Chr(0)
      .lpstrFilter = sFilter
      .nFilterIndex = 1
      .lpstrFile = String(257, 0)
      .nMaxFile = Len(OpenFile.lpstrFile) - 1
      .lpstrFileTitle = OpenFile.lpstrFile
      .nMaxFileTitle = OpenFile.nMaxFile
      If Len(txConfig) > 0 Then
         .lpstrInitialDir = txConfig
      Else
         If Len(GetSetting("MSIXSQL", "Settings", "LastConfigDir")) > 0 Then
            .lpstrInitialDir = GetSetting("MSIXSQL", "Settings", "LastConfigDir")
         Else
            .lpstrInitialDir = App.Path
         End If
      End If
      .lpstrTitle = "Browse"
      .flags = &H4     'hide read-only
      lReturn = GetOpenFileName(OpenFile)
      If lReturn > 0 Then
         txConfig = Trim$(.lpstrFile)
         ckAll.Value = 1
         StartParse
      End If
   End With
   
closeit:
'    If Err.Number = 32755 Then Exit Sub
    subErrLog ("btBrowseConfig_Click")
End Sub

Private Sub Form_Unload(Cancel As Integer)
On Error Resume Next
    If Len(txMSIX) > 0 Then
      SaveSetting "MSIXSQL", "Settings", "LastMSIXDir", Left$(txMSIX, Len(txMSIX) - (Len(txMSIX) - InStrRev(txMSIX, "\")))
    End If
    If Len(txConfig) > 0 Then
      SaveSetting "MSIXSQL", "Settings", "LastConfigDir", Left$(txConfig, Len(txConfig) - (Len(txConfig) - InStrRev(txConfig, "\")))
    End If
    SaveSetting "MSIXSQL", "Settings", "Open", CStr(ckOpen.Value)
'    Unload form1
    End
End Sub

'Private Sub txConfig_Change()
'   If Len(txConfig) > 0 Then
'      ckAll.Enabled = True
'   Else
'      ckAll.Enabled = False
'   End If
'End Sub

Private Sub txMSIX_KeyPress(KeyAscii As Integer)
   If KeyAscii = 1 Then
      txMSIX.SelStart = 0
      txMSIX.SelLength = Len(txMSIX.Text)
   End If
End Sub

Private Sub txConfig_KeyPress(KeyAscii As Integer)
   If KeyAscii = 1 Then
      txConfig.SelStart = 0
      txConfig.SelLength = Len(txConfig.Text)
   End If
End Sub

Private Sub txMSIX_KeyDown(KeyCode As Integer, Shift As Integer)
   If KeyCode = 16 Then
      blKeyShift = True
      If Len(txMSIX) > 0 Then
         btParse_Click
      End If
   End If
End Sub

Private Sub form1_KeyDown(KeyCode As Integer, Shift As Integer)
   If KeyCode = 16 Then
      blKeyShift = True
      If blCommand > 0 Then
         btParse_Click
      End If
   End If
End Sub

Private Sub txMSIX_OLEDragDrop(Data As DataObject, Effect As Long, Button As Integer, Shift As Integer, X As Single, Y As Single)
On Error GoTo OleQuit
    txMSIX.Text = Data.Files(1)
    If blKeyShift Then btParse_Click
OleQuit:
    blKeyShift = False
    blCommand = False
    subErrLog ("txMSIX_OLEDragDrop")
End Sub

Private Sub txConfig_OLEDragDrop(Data As DataObject, Effect As Long, Button As Integer, Shift As Integer, X As Single, Y As Single)
On Error GoTo OleQuit
    txConfig.Text = Data.Files(1)
    StartParse
OleQuit:
    subErrLog ("txConfig_OLEDragDrop")
End Sub




