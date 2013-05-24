VERSION 5.00
Begin VB.Form form2 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "QuickConfig"
   ClientHeight    =   6495
   ClientLeft      =   45
   ClientTop       =   360
   ClientWidth     =   4785
   Icon            =   "form2.frx":0000
   LinkTopic       =   "Form2"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   ScaleHeight     =   6495
   ScaleWidth      =   4785
   StartUpPosition =   1  'CenterOwner
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   1
      Left            =   2040
      Top             =   4440
   End
   Begin VB.CommandButton btData 
      Caption         =   "Data Source..."
      Height          =   375
      Left            =   120
      TabIndex        =   13
      Top             =   4080
      Width           =   1335
   End
   Begin VB.CommandButton btConfigBrowse 
      Caption         =   "New Filename..."
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   960
      Width           =   1335
   End
   Begin VB.TextBox txConfig 
      Height          =   315
      Left            =   1560
      TabIndex        =   3
      Top             =   960
      Width           =   3015
   End
   Begin VB.TextBox txLog 
      Height          =   315
      Left            =   1560
      TabIndex        =   12
      Top             =   3480
      Width           =   3015
   End
   Begin VB.TextBox txDataSource 
      Height          =   315
      Left            =   1560
      TabIndex        =   14
      Top             =   4095
      Width           =   3015
   End
   Begin VB.CommandButton btLogBrowse 
      Caption         =   "Log Filename..."
      Height          =   375
      Left            =   120
      TabIndex        =   11
      Top             =   3480
      Width           =   1335
   End
   Begin VB.CommandButton btPrefixes 
      Caption         =   "Prefixes..."
      Enabled         =   0   'False
      Height          =   375
      Left            =   240
      TabIndex        =   22
      Top             =   4920
      Width           =   1575
   End
   Begin VB.CommandButton btControlColumns 
      Caption         =   "Control Columns..."
      Enabled         =   0   'False
      Height          =   375
      Left            =   240
      TabIndex        =   21
      Top             =   5400
      Width           =   1575
   End
   Begin VB.CommandButton btCustom 
      Caption         =   "Custom..."
      Enabled         =   0   'False
      Height          =   375
      Left            =   240
      TabIndex        =   20
      Top             =   5880
      Width           =   1575
   End
   Begin VB.CommandButton btClose 
      Cancel          =   -1  'True
      Caption         =   "Close"
      Height          =   375
      Left            =   2280
      TabIndex        =   19
      Top             =   6000
      Width           =   2295
   End
   Begin VB.CommandButton btGenerate 
      Caption         =   "&Generate"
      Height          =   495
      Left            =   2280
      TabIndex        =   17
      Top             =   5400
      Width           =   2295
   End
   Begin VB.CheckBox ckOpen 
      Caption         =   "Open Generated File"
      Height          =   255
      Left            =   2280
      TabIndex        =   16
      Top             =   5040
      Value           =   1  'Checked
      Width           =   2175
   End
   Begin VB.CheckBox ckStartup 
      Caption         =   "Load Template on Startup"
      Height          =   255
      Left            =   2280
      TabIndex        =   15
      Top             =   4720
      Width           =   2175
   End
   Begin VB.CommandButton btParent 
      Caption         =   "Parent Service..."
      Height          =   375
      Left            =   120
      TabIndex        =   4
      Top             =   1680
      Width           =   1335
   End
   Begin VB.ComboBox txPrimaryKey 
      Height          =   315
      Left            =   1560
      TabIndex        =   10
      Top             =   2880
      Width           =   3015
   End
   Begin VB.CommandButton btPrimaryKey 
      Caption         =   "Primary Key(s)..."
      Height          =   375
      Left            =   120
      TabIndex        =   9
      Top             =   2880
      Width           =   1335
   End
   Begin VB.Frame Frame1 
      Caption         =   "Advanced"
      Height          =   1695
      Left            =   120
      TabIndex        =   8
      Top             =   4680
      Width           =   1815
   End
   Begin VB.CommandButton btTemplate 
      Caption         =   "Template..."
      Default         =   -1  'True
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   240
      Width           =   1335
   End
   Begin VB.TextBox txTemplate 
      Height          =   315
      Left            =   1560
      TabIndex        =   1
      Top             =   240
      Width           =   3015
   End
   Begin VB.ComboBox txChildServices 
      Height          =   315
      Left            =   1560
      TabIndex        =   7
      Top             =   2280
      Width           =   3015
   End
   Begin VB.CommandButton btChildServices 
      Caption         =   "Child Services..."
      Height          =   375
      Left            =   120
      TabIndex        =   6
      Top             =   2280
      Width           =   1335
   End
   Begin VB.TextBox txParentService 
      Height          =   315
      Left            =   1560
      Locked          =   -1  'True
      TabIndex        =   5
      Top             =   1680
      Width           =   3015
   End
   Begin VB.Label Label5 
      Caption         =   "(Default is MeterConfig.xml)"
      ForeColor       =   &H8000000D&
      Height          =   255
      Left            =   1560
      TabIndex        =   23
      Top             =   1320
      Width           =   2055
   End
   Begin VB.Label Label1 
      Caption         =   "(Any valid MetraConnect-DB config file)"
      ForeColor       =   &H8000000D&
      Height          =   255
      Left            =   1560
      TabIndex        =   18
      Top             =   600
      Width           =   3375
   End
End
Attribute VB_Name = "form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Public blEditParent As Boolean
Public blTemplateLoaded As Boolean
Public blGenerated As Boolean
Private blloading As Boolean

Private Sub btClose_Click()
   Form_Unload (0)
End Sub

Private Sub btData_Click()
   If LoadMessages Then Exit Sub
   dgData.Show 1
End Sub

Private Sub btLogBrowse_Click()
On Error GoTo closeit
   If LoadMessages Then Exit Sub
   Dim OpenFile As OPENFILENAME
   Dim lReturn As Long
   Dim sFilter As String
   With OpenFile
      .lStructSize = Len(OpenFile)
      .hwndOwner = form2.hWnd
      .hInstance = App.hInstance
      .lpstrFilter = sFilter
      .nFilterIndex = 1
      .lpstrFile = String(257, 0)
      .nMaxFile = Len(OpenFile.lpstrFile) - 1
      .lpstrFileTitle = OpenFile.lpstrFile
      .nMaxFileTitle = OpenFile.nMaxFile
      If Len(txConfig) > 0 Then
         .lpstrInitialDir = txConfig
      Else
         .lpstrInitialDir = App.Path
      End If
      .lpstrTitle = "Select a folder (and type the log filename)"
      .flags = &H4     'hide read-only
      lReturn = GetOpenFileName(OpenFile)
      If lReturn > 0 Then
         txLog = Trim$(.lpstrFile)
      Else
         If Len(txLog) = 0 Then
            MsgBox "You must type the name of the log file after selecting the folder location.", vbInformation
         End If
      End If
   End With
   
closeit:
    subErrLog ("btLogBrowse_Click")
End Sub

Private Sub btParent_Click()
   If LoadMessages Then Exit Sub
   blEditParent = True
   dgService.Show 1
End Sub

Private Sub btPrimaryKey_Click()
   If LoadMessages Then Exit Sub
   dgKey.Show
End Sub

Private Sub btChildServices_Click()
   If LoadMessages Then Exit Sub
   blEditParent = False
   dgService.Show 1
End Sub

Private Sub btTemplate_Click()
On Error GoTo closeit
    
   blGenerated = False
   Dim OpenFile As OPENFILENAME
   Dim lReturn As Long
   Dim sFilter As String
   With OpenFile
      .lStructSize = Len(OpenFile)
      .hwndOwner = form2.hWnd
      .hInstance = App.hInstance
      sFilter = "Metering Config " + Chr(34) + "sdkconfig" + Chr(34) + " files (*.xml)" & Chr(0) & "*.xml" & Chr(0)
      .lpstrFilter = sFilter
      .nFilterIndex = 1
      .lpstrFile = String(257, 0)
      .nMaxFile = Len(OpenFile.lpstrFile) - 1
      .lpstrFileTitle = OpenFile.lpstrFile
      .nMaxFileTitle = OpenFile.nMaxFile
      If Len(txConfig) > 0 Then
         .lpstrInitialDir = txTemplate
      Else
         If Len(GetSetting("QuickConfig", "Settings", "LastTempDir")) > 0 Then
            .lpstrInitialDir = GetSetting("QuickConfig", "Settings", "LastTempDir")
         Else
            .lpstrInitialDir = "C:\Program Files\MetraTech\MetraConnect\Samples\Metering\DBMetering\"
         End If
      End If
      .lpstrTitle = "Browse for Template"
      .flags = &H4     'hide read-only
      lReturn = GetOpenFileName(OpenFile)
      If lReturn > 0 Then
         txTemplate = Trim$(.lpstrFile)
         If ConfigParse(txTemplate) = False Then Exit Sub
         ConfigPopulate
         blTemplateLoaded = True
'         ckAll.Value = 1
'         StartParse
      End If
   End With
   btGenerate.Default = True
   txConfig.SetFocus
   
closeit:
'    If Err.Number = 32755 Then Exit Sub
    subErrLog ("btBrowseConfig_Click")
End Sub

Private Sub btConfigBrowse_Click()
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
      .hwndOwner = form2.hWnd
      .hInstance = App.hInstance
      sFilter = "Metering Config " + " files (*.xml)" & Chr(0) & "*.xml" & Chr(0)
      .lpstrFilter = sFilter
      .nFilterIndex = 1
      .lpstrFile = String(257, 0)
      .nMaxFile = Len(OpenFile.lpstrFile) - 1
      .lpstrFileTitle = OpenFile.lpstrFile
      .nMaxFileTitle = OpenFile.nMaxFile
      If Len(txConfig) > 0 Then
         .lpstrInitialDir = txConfig
      Else
         If Len(GetSetting("QuickConfig", "Settings", "LastGenDir")) > 0 Then
            .lpstrInitialDir = GetSetting("QuickConfig", "Settings", "LastGenDir")
         Else
            .lpstrInitialDir = App.Path
         End If
      End If
      .lpstrTitle = "Select a folder (and type the config filename)"
      .flags = &H4     'hide read-only
      lReturn = GetOpenFileName(OpenFile)
      If lReturn > 0 Then
         Dim fnameonly As String
         txConfig = Trim$(.lpstrFile)
         fnameonly = Right$(txConfig, Len(txConfig) - InStrRev(txConfig, "\"))
'         If Len(fnameonly) = 0 Then
'            MsgBox "You must type the name of the configuration file after selecting the folder location.", vbExclamation
'         End If
         form2.Caption = "QuickConfig: " + fnameonly
      Else
         If Len(txConfig) = 0 Then
            MsgBox "You must type the name of the configuration file after selecting the folder location.", vbInformation
         End If
      End If
   End With
   
closeit:
'    If Err.Number = 32755 Then Exit Sub
    subErrLog ("btBrowseConfig_Click")
End Sub

Private Sub ConfigPopulate()
   Dim pk As Integer
   txPrimaryKey.Clear
   For pk = 0 To UBound(PrimaryKey)
      txPrimaryKey.AddItem PrimaryKey(pk)
   Next
   txPrimaryKey.ListIndex = 0
   txParentService = ServiceName
   txDataSource = DBName
   txLog = LogFileName
   ServicePopulate
End Sub

Private Sub ServicePopulate()
On Error GoTo errlog

  Dim SCstring As String
  Dim scnt As Integer
  Dim response As Integer
  Dim badones As Integer
       
  txChildServices.Clear
'     ConfigOnly = Right$(.txConfig, Len(.txConfig) - InStrRev(.txConfig, "\"))
'     fpathonly = Left$(.txConfig, Len(.txConfig) - Len(ConfigOnly))
  
'     If UBound(ServiceChild) > 0 Then blMultiple = True
  
'  txChildServices.AddItem ParentService
  
  If blMultiple Then
      For scnt = 0 To UBound(ChildMSIX)
        If Len(ChildMSIX(scnt)) > 0 Then
           txChildServices.AddItem ChildName(scnt)
'              SCstring = SCstring + vbNewLine + "   " + ChildMSIX(scnt)
        End If
      Next scnt
      btChildServices.Enabled = True
      txChildServices.Enabled = True
      txChildServices.ListIndex = 0
  Else
     If blloading = False Then
         MsgBox "No child services were found." + vbNewLine + vbNewLine _
         + "This template can only be used to create atomic service configuration files.", vbInformation
     End If
     btChildServices.Enabled = False
     txChildServices.Enabled = False
  End If
  txPrimaryKey.Enabled = True
  btPrimaryKey.Enabled = True

errlog:
   subErrLog ("ServicePopulate")
End Sub

Private Sub Form_Load()
   blloading = True
   If Len(GetSetting("QuickConfig", "Settings", "Open")) > 0 Then
      ckOpen.Value = Val(GetSetting("QuickConfig", "Settings", "Open"))
   Else
      ckOpen.Value = 1
   End If
   If Len(GetSetting("QuickConfig", "Settings", "Startup")) > 0 Then
      ckStartup.Value = Val(GetSetting("QuickConfig", "Settings", "Startup"))
   End If
   
   Dim stemplate As String
   If FileExists(App.Path + "\TrainingTemplate.xml") Then
      ckStartup.Value = 1
      stemplate = App.Path + "\TrainingTemplate.xml"
      txConfig = "Enter name of config file to generate"
      Timer1.Enabled = True
   Else
      If Len(GetSetting("QuickConfig", "Settings", "Template")) > 0 Then
         stemplate = GetSetting("QuickConfig", "Settings", "Template")
      End If
   End If
   If ckStartup.Value = 1 Then
      If FileExists(stemplate) Then
         txTemplate = Trim$(stemplate)
         If ConfigParse(stemplate) = False Then Exit Sub
         ConfigPopulate
         blTemplateLoaded = True
      Else
         Timer1.Enabled = True
      End If
   End If
   blloading = False
End Sub

Private Sub Timer1_Timer()
On Error GoTo errlog
   If FileExists(App.Path + "\TrainingTemplate.xml") Then
      MsgBox "Training template loaded. To load other templates automatically, first delete the training template " + vbNewLine _
      + "(in " + App.Path + ").", vbInformation
   Else
      MsgBox "Last-used template was not found. Please select a new one.", vbInformation
   End If
errlog:
   Timer1.Enabled = False
End Sub

Private Sub Form_Unload(Cancel As Integer)
On Error Resume Next
   If Len(txTemplate) > 0 Then
      SaveSetting "QuickConfig", "Settings", "Template", txTemplate
   End If
   SaveSetting "QuickConfig", "Settings", "Startup", CStr(ckStartup.Value)
   SaveSetting "QuickConfig", "Settings", "Open", CStr(ckOpen.Value)
   SaveSetting "QuickConfig", "Settings", "LastTempDir", Left$(txTemplate, Len(txTemplate) - (Len(txTemplate) - InStrRev(txTemplate, "\")))
   SaveSetting "QuickConfig", "Settings", "LastGenDir", Left$(txConfig, Len(txConfig) - (Len(txConfig) - InStrRev(txConfig, "\")))
   Unload dgKey
   Unload dgService
   Unload dgData
   Unload dgContext
   Unload form2
   End
End Sub

Private Sub txConfig_Change()
   If InStr(txConfig, "\") > 0 Then
      Dim fnameonly As String
      fnameonly = Right$(txConfig, Len(txConfig) - InStrRev(txConfig, "\"))
      form2.Caption = "QuickConfig: " + fnameonly
   Else
      If Len(txConfig) > 0 Then
         form2.Caption = "QuickConfig: " + txConfig
'      Else
'         form2.Caption = "QuickConfig: (Unnamed)"
      End If
   End If
End Sub


Private Sub txDataSource_KeyDown(KeyCode As Integer, Shift As Integer)
   txDataSource.Locked = True
   If LoadMessages Then Exit Sub
   dgData.Show 1
   txDataSource.Locked = False
End Sub

Private Sub txLog_GotFocus()
   txLog.SelLength = Len(txLog)
End Sub

Private Sub txDataSource_GotFocus()
   txDataSource.SelLength = Len(txDataSource)
End Sub

Private Sub txTemplate_GotFocus()
   txTemplate.SelLength = Len(txTemplate)
End Sub

Private Sub txConfig_GotFocus()
   txConfig.SelLength = Len(txConfig)
End Sub

Private Sub txparentservice_GotFocus()
   txParentService.SelLength = Len(txParentService)
End Sub

Private Sub txLog_KeyDown(KeyCode As Integer, Shift As Integer)
   txLog.Locked = True
   If LoadMessages Then Exit Sub
   txLog.Locked = False
End Sub

Private Sub txPrimaryKey_KeyDown(KeyCode As Integer, Shift As Integer)
   txPrimaryKey.Locked = True
   If LoadMessages Then Exit Sub
   dgKey.Show 1
   txPrimaryKey.Locked = False
End Sub

Private Sub txParentService_KeyDown(KeyCode As Integer, Shift As Integer)
   txParentService.Locked = True
   If LoadMessages Then Exit Sub
   blEditParent = True
   dgService.Show 1
   txParentService.Locked = False
End Sub

Private Sub txChildServices_KeyDown(KeyCode As Integer, Shift As Integer)
   txChildServices.Locked = True
   If LoadMessages Then Exit Sub
   blEditParent = False
   dgService.Show 1
   txChildServices.Locked = False
End Sub

Private Sub ChangeOtherValues()
On Error GoTo errlog
  Set oXMLNodes = oXMLDoc.selectSingleNode("xmlconfig/loggingConfig/logFileName")
  oXMLNodes.Text = txLog
'  Set oXMLNodes = oXMLDoc.selectSingleNode("xmlconfig/DatabaseConfig/DataBase")
'  oXMLNodes.Text = txDataSource
'  Set oXMLNodes = oXMLDoc.selectSingleNode("xmlconfig/Services/ServiceData/ServiceName")
'  oXMLNodes.Text = txParentService
errlog:
 subErrLog ("ChangeOtherValues")
End Sub

Private Function LoadMessages() As Boolean
   LoadMessages = False
   If blTemplateLoaded = False Then
      MsgBox "Load a template first.", vbInformation
      LoadMessages = True
      Exit Function
   End If
   If blGenerated = True Then
      MsgBox "Reload the template or load a new template first.", vbInformation
      LoadMessages = True
   End If
End Function

Private Sub btGenerate_Click()
On Error GoTo errlog

   If blTemplateLoaded = False Then
      MsgBox "Load a template first.", vbInformation
      Exit Sub
   End If
   If blGenerated = True Then
      MsgBox "You must load or reload a template before generating again.", vbInformation
      Exit Sub
   End If

   'Determine dir + filename
   If Len(txConfig) = 0 Then
      If Len(GetSetting("QuickConfig", "Settings", "LastGenDir")) > 0 Then
         txConfig = GetSetting("QuickConfig", "Settings", "LastGenDir") + "MeterConfig.xml"
      Else
         txConfig = App.Path + "\MeterConfig.xml"
      End If
   ElseIf InStr(txConfig, "\") = 0 Then
      txConfig = App.Path + "\" + txConfig
   End If
   
   'Add an ext or causes folder err
   Dim fnameonly As String
   fnameonly = Right$(txConfig, Len(txConfig) - InStrRev(txConfig, "\"))
   If Len(fnameonly) > 0 Then
      If InStr(fnameonly, ".") = 0 Then
         txConfig = txConfig + ".xml"
      End If
   End If
   
   Dim strGenConfig As String

   strGenConfig = txConfig
   
   If strGenConfig = txTemplate Then
      MsgBox "You cannot overwrite your selected template.", vbExclamation
      Exit Sub
   End If
   
   ChangeOtherValues
   
'  **************************************************************************
   
   oXMLDoc.Save (strGenConfig)

'  **************************************************************************
   
   If ckOpen.Value = 1 Then
      Dim sh As New Shell
      sh.Open strGenConfig
   End If
   
'   Dim fnameonly As String
   fnameonly = Right$(strGenConfig, Len(strGenConfig) - InStrRev(strGenConfig, "\"))
   fpathonly = Left$(strGenConfig, Len(strGenConfig) - Len(fnameonly))
   
   MsgBox "Configuration file generated:" + vbNewLine + vbNewLine _
   + fnameonly + vbNewLine + vbNewLine _
   + "in " + fpathonly, vbInformation

   blGenerated = True
   Set oXMLDoc = Nothing
'  SaveXMLDoc = True

   Exit Sub
errlog:
   If Err.Number = -2147024893 Or -2147024773 Then
      MsgBox "The folder you specified does not exist, or the filename is invalid.", vbCritical
   Else
      subErrLog ("btGenerate")
   End If
End Sub
