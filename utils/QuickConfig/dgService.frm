VERSION 5.00
Begin VB.Form dgService 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Edit Service"
   ClientHeight    =   2520
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   5475
   Icon            =   "dgService.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2520
   ScaleWidth      =   5475
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton btMSIX 
      Caption         =   "MSIXDEF File..."
      Height          =   495
      Left            =   120
      TabIndex        =   4
      Top             =   1920
      Width           =   975
   End
   Begin VB.CommandButton btAdd 
      Caption         =   "Add"
      Height          =   375
      Left            =   4080
      TabIndex        =   7
      Top             =   720
      Width           =   1215
   End
   Begin VB.CommandButton btRemove 
      Caption         =   "Remove"
      Height          =   375
      Left            =   4080
      TabIndex        =   8
      Top             =   1200
      Width           =   1215
   End
   Begin VB.TextBox txMSIX 
      Height          =   375
      Left            =   1200
      TabIndex        =   3
      Top             =   1920
      Width           =   2655
   End
   Begin VB.TextBox txSets 
      Height          =   375
      Left            =   1200
      TabIndex        =   2
      Top             =   1320
      Width           =   2655
   End
   Begin VB.TextBox txSync 
      Height          =   375
      Left            =   1200
      TabIndex        =   1
      Top             =   720
      Width           =   2655
   End
   Begin VB.TextBox txDN 
      Height          =   375
      Left            =   1200
      TabIndex        =   0
      Top             =   240
      Width           =   2655
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Close"
      Default         =   -1  'True
      Height          =   375
      Left            =   4080
      TabIndex        =   6
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label3 
      Caption         =   "Session Sets"
      Height          =   255
      Left            =   120
      TabIndex        =   10
      Top             =   1440
      Width           =   975
   End
   Begin VB.Label Label2 
      Caption         =   "Synchronous"
      Height          =   495
      Left            =   120
      TabIndex        =   9
      Top             =   840
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Name"
      Height          =   375
      Left            =   120
      TabIndex        =   5
      Top             =   240
      Width           =   975
   End
End
Attribute VB_Name = "dgService"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)
Private blAdded As Boolean
Public sk As Integer
Private oldsk As Integer

Private Sub btMSIX_Click()
On Error GoTo closeit
   
  Dim OpenFile As OPENFILENAME
  Dim lReturn As Long
  Dim sFilter As String
  With OpenFile
     .lStructSize = Len(OpenFile)
     .hwndOwner = dgService.hWnd
     .hInstance = App.hInstance
     sFilter = "Service Defintion File (*.msixdef)" & Chr(0) & "*.msixdef" & Chr(0)
     .lpstrFilter = sFilter
     .nFilterIndex = 1
     .lpstrFile = String(257, 0)
     .nMaxFile = Len(OpenFile.lpstrFile) - 1
     .lpstrFileTitle = OpenFile.lpstrFile
     .nMaxFileTitle = OpenFile.nMaxFile
      If Len(GetSetting("QuickConfig", "Settings", "LastMSIXDir")) > 0 Then
         .lpstrInitialDir = GetSetting("QuickConfig", "Settings", "LastMXIXDir")
      Else
         .lpstrInitialDir = App.Path
      End If
     .lpstrTitle = "Browse for MSIXDEF file"
     .flags = &H4     'hide read-only
     lReturn = GetOpenFileName(OpenFile)
     If lReturn > 0 Then
        txMSIX = Trim$(.lpstrFile)
        SaveSetting "QuickConfig", "Settings", "LastMSIXDir", Left$(txMSIX, Len(txMSIX) - (Len(txMSIX) - InStrRev(txMSIX, "\")))
     End If
  End With
   
closeit:
'    If Err.Number = 32755 Then Exit Sub
    subErrLog ("btBrowseConfig_Click")
End Sub

Private Sub Form_Load()
On Error GoTo errlog

   If form2.blEditParent Then
      Me.Caption = "Edit Parent Service"
      txDN = form2.txParentService
      txSync = sSync
      txSets = sSets
      txMSIX = ParentService
      btAdd.Visible = False
      btRemove.Visible = False
   Else
      Me.Caption = "Edit Child Service"
      For sk = 0 To UBound(ChildName)
         If form2.txChildServices.Text = ChildName(sk) Then
            txDN = ChildName(sk)
            txSync = ChildSync(sk)
            txSets = ChildSets(sk)
            txMSIX = ChildMSIX(sk)
            btAdd.Visible = True
            btRemove.Visible = True
            Exit For
         End If
      Next
   End If

errlog:
   subErrLog ("dgService: Form_Load")
End Sub


Private Sub btAdd_Click()
On Error GoTo errlog

   Dim blFail As Boolean
   For sk = 0 To UBound(ChildMSIX)
'      If txDN = ChildMSIX(sk) Then Exit Sub
            
      Dim i As Integer
      i = form2.txChildServices.ListIndex
      If ChildName(i) = txDN Then
         MsgBox "A new service name is required.", vbInformation
         Exit Sub    'nothing has changed
      End If
      
      If Not CloneNode("xmlconfig/Services/ServiceData", "ServiceChild") Then
        blFail = True
      End If
      
      Dim newcnt As Integer
      newcnt = UBound(ChildName) + 1
      ReDim Preserve ChildName(newcnt)
      ChildName(newcnt) = txDN
      ReDim Preserve ChildSync(newcnt)
      ChildSync(newcnt) = txSync
      ReDim Preserve ChildSets(newcnt)
      ChildSets(newcnt) = txSets
      ReDim Preserve ChildMSIX(newcnt)
      ChildMSIX(newcnt) = txMSIX
      oldsk = sk
      Exit For
   Next

      form2.txChildServices.AddItem txDN
      form2.txChildServices.ListIndex = form2.txChildServices.ListCount - 1
      
errlog:
   blAdded = True
   CancelButton_Click
   subErrLog "dgKey:btAdd_click)"
End Sub

Private Sub btRemove_Click()
On Error GoTo errlog

   If form2.txChildServices.ListCount = 1 Then
      Dim response As Integer
      response = MsgBox("Once you delete the last child service, you will not be able to add a new " _
      + "child service without reloading the template.", 68)
      If response = vbNo Then
         Exit Sub
      End If
   End If
   With form2
      For sk = 0 To UBound(ChildName)
         If txDN = ChildName(sk) Then
            Dim delindx As Integer
            delindx = .txChildServices.ListIndex
            .txChildServices.RemoveItem (delindx)
            If .txChildServices.ListIndex > 1 Then
               .txChildServices.ListIndex = delindx - 1
            Else
               On Error Resume Next
               .txChildServices.ListIndex = 0
               On Error GoTo 0
            End If
            .Refresh
'            Call RemoveArrayElement(ChildMSIX, sk)
'            Call RemoveArrayElement(ChildSync, sk)
'            Call RemoveArrayElement(ChildSets, sk)
'            Call RemoveArrayElement(ChildName, sk)
            
            If KillNode("xmlconfig/Services/ServiceData", "ServiceChild", txDN, "ServiceName") = False Then
               MsgBox "An error occurred attempting to delete this child service.", vbInformation
               Exit For
            End If
            
            If .txChildServices.ListCount > 0 Then
               .txChildServices.ListIndex = 0
            Else
               .txChildServices.Enabled = False
               .btChildServices.Enabled = False
            End If
            Exit For
         End If
      Next
   End With
errlog:
   Unload Me
   subErrLog ("dgService:btRemove_Click")
End Sub

Private Sub CancelButton_Click()
On Error GoTo errlog:
      
   Dim ParentNode As String
   If form2.blEditParent Then
      ParentNode = "xmlconfig/Services/ServiceData"
      Call ChangeValue(ParentNode, txDN, "ServiceName")
      
      ParentNode = "xmlconfig/Services/ServiceData"
      Call ChangeValue(ParentNode, txSync, "SynchronousService")
      
      ParentNode = "xmlconfig/Services/ServiceData"
      Call ChangeValue(ParentNode, txSets, "MaxSessionSet")
      
      ParentNode = "xmlconfig/Services/ServiceData/ServiceProperties"
      Call ChangeValue(ParentNode, txMSIX, "servicedefinitionfile")
            
     'persist the vars before unloading
      form2.txParentService = txDN
      sSync = txSync
      sSets = txSets
      ParentService = txMSIX

   Else
      If blAdded Then
         sk = oldsk
         blAdded = False
'      Else
'         sk = form2.txChildServices.ListIndex
      End If
      ParentNode = "xmlconfig/Services/ServiceData/ServiceChild[ServiceName=" _
      + Chr$(39) + ChildName(sk) + Chr$(39) + "]"
      Call ChangeValue(ParentNode, txDN, "ServiceName")
      
      ParentNode = "xmlconfig/Services/ServiceData/ServiceChild[SynchronousService=" _
      + Chr$(39) + ChildSync(sk) + Chr$(39) + "]"
      Call ChangeValue(ParentNode, txSync, "SynchronousService")
      
      ParentNode = "xmlconfig/Services/ServiceData/ServiceChild[MaxSessionSet=" _
      + Chr$(39) + ChildSets(sk) + Chr$(39) + "]"
      Call ChangeValue(ParentNode, txSets, "MaxSessionSet")
      
      ParentNode = "xmlconfig/Services/ServiceData/ServiceChild/ServiceProperties[servicedefinitionfile=" _
      + Chr$(39) + ChildMSIX(sk) + Chr$(39) + "]"
      Call ChangeValue(ParentNode, txMSIX, "servicedefinitionfile")
      
     'persist the vars before unloading
      form2.txChildServices.List(form2.txChildServices.ListIndex) = txDN
      ChildName(sk) = txDN
      ChildSync(sk) = txSync
      ChildSets(sk) = txSets
      ChildMSIX(sk) = txMSIX

   End If
   
errlog:
   Unload Me
'   Me.Visible = False
   subErrLog ("dgService:CancelButton_Click")
End Sub

Private Sub txDN_Change()
   txDN.SelLength = Len(txDN)
End Sub

Private Sub txSync_Change()
   txSync.SelLength = Len(txSync)
End Sub

Private Sub txSets_Change()
   txSets.SelLength = Len(txSets)
End Sub

Private Sub txMSIX_Change()
   txMSIX.SelLength = Len(txMSIX)
End Sub
