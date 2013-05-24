VERSION 5.00
Begin VB.Form dgKey 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Edit Primary Key"
   ClientHeight    =   2445
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   5475
   Icon            =   "dgKey.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2445
   ScaleWidth      =   5475
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton btAdd 
      Caption         =   "Add"
      Height          =   375
      Left            =   4080
      TabIndex        =   5
      Top             =   720
      Width           =   1215
   End
   Begin VB.CommandButton btRemove 
      Caption         =   "Remove"
      Height          =   375
      Left            =   4080
      TabIndex        =   6
      Top             =   1200
      Width           =   1215
   End
   Begin VB.TextBox txReq 
      Height          =   375
      Left            =   1200
      TabIndex        =   3
      Top             =   1920
      Width           =   2655
   End
   Begin VB.TextBox txLen 
      Height          =   375
      Left            =   1200
      TabIndex        =   2
      Top             =   1320
      Width           =   2655
   End
   Begin VB.TextBox txType 
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
      TabIndex        =   4
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label4 
      Caption         =   "Required"
      Height          =   375
      Left            =   120
      TabIndex        =   10
      Top             =   1920
      Width           =   855
   End
   Begin VB.Label Label3 
      Caption         =   "Length"
      Height          =   255
      Left            =   120
      TabIndex        =   9
      Top             =   1440
      Width           =   975
   End
   Begin VB.Label Label2 
      Caption         =   "Type"
      Height          =   495
      Left            =   120
      TabIndex        =   8
      Top             =   840
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Name"
      Height          =   375
      Left            =   120
      TabIndex        =   7
      Top             =   240
      Width           =   975
   End
End
Attribute VB_Name = "dgKey"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Public pk As Integer
Private blAdded As Boolean
Private oldpk As Integer

Private Sub CancelButton_Click()
On Error GoTo errlog
      
   Dim ParentNode As String
   If blAdded Then
      pk = oldpk
      blAdded = False
'   Else
'      pk = form2.txPrimaryKey.ListIndex
   End If
   ParentNode = "xmlconfig/Services/ServiceData/ServicePrimaryKey/ptype[dn=" _
   + Chr$(39) + PrimaryKey(pk) + Chr$(39) + "]"
   Call ChangeValue(ParentNode, txDN, "dn")
   ParentNode = "xmlconfig/Services/ServiceData/ServicePrimaryKey/ptype[type=" _
   + Chr$(39) + KeyType(pk) + Chr$(39) + "]"
   Call ChangeValue(ParentNode, txType, "type")
   ParentNode = "xmlconfig/Services/ServiceData/ServicePrimaryKey/ptype[length=" _
   + Chr$(39) + KeyLength(pk) + Chr$(39) + "]"
   Call ChangeValue(ParentNode, txLen, "length")
   ParentNode = "xmlconfig/Services/ServiceData/ServicePrimaryKey/ptype[required=" _
   + Chr$(39) + KeyRequired(pk) + Chr$(39) + "]"
   Call ChangeValue(ParentNode, txReq, "required")
   
   'persist the vars before unloading
   form2.txPrimaryKey.List(form2.txPrimaryKey.ListIndex) = txDN
   PrimaryKey(pk) = txDN
   KeyType(pk) = txType
   KeyLength(pk) = txLen
   KeyRequired(pk) = txReq
   
errlog:
   Unload Me
   subErrLog "dgKey:CancelButton_Click"
End Sub

Private Sub Form_Load()
On Error GoTo errlog

   For pk = 0 To UBound(PrimaryKey)
      If form2.txPrimaryKey.Text = PrimaryKey(pk) Then
         txDN = PrimaryKey(pk)
         txType = KeyType(pk)
         txLen = KeyLength(pk)
         txReq = KeyRequired(pk)
         Exit For
      End If
   Next

errlog:
   subErrLog "dgKey:Form_Load"
End Sub

Private Sub btAdd_Click()
On Error GoTo errlog

   Dim blFail As Boolean
   For pk = 0 To UBound(PrimaryKey)
   
      Dim i As Integer
      i = form2.txPrimaryKey.ListIndex
      If PrimaryKey(i) = txDN Then
         MsgBox "A new primary key name is required.", vbInformation
         Exit Sub    'nothing has changed
      End If

      If Not CloneNode("xmlconfig/Services/ServiceData/ServicePrimaryKey", "ptype") Then
        blFail = True
      End If
            
      Dim newcnt As Integer
      newcnt = UBound(PrimaryKey) + 1
      ReDim Preserve PrimaryKey(newcnt)
      PrimaryKey(newcnt) = txDN
      ReDim Preserve KeyType(newcnt)
      KeyType(newcnt) = txType
      ReDim Preserve KeyLength(newcnt)
      KeyLength(newcnt) = txLen
      ReDim Preserve KeyRequired(newcnt)
      KeyRequired(newcnt) = txReq
      oldpk = pk
      Exit For
   Next
   
   form2.txPrimaryKey.AddItem txDN
   form2.txPrimaryKey.ListIndex = form2.txPrimaryKey.ListCount - 1
   
errlog:
   blAdded = True
   CancelButton_Click
   subErrLog "dgKey:btAdd_click)"
End Sub

Private Sub btRemove_Click()
On Error GoTo errlog

   If form2.txPrimaryKey.ListCount = 1 Then
      Dim response As Integer
      response = MsgBox("Once you delete the last primary key, you will not be able to add a new " _
      + "primary key without reloading the template.", 68)
      If response = vbNo Then
         Exit Sub
      End If
   End If
   With form2
      For pk = 0 To .txPrimaryKey.ListCount
         If txDN = .txPrimaryKey.List(pk) Then
             Dim delindx As Integer
             delindx = .txPrimaryKey.ListIndex
             .txPrimaryKey.RemoveItem (delindx)
             If .txPrimaryKey.ListIndex > 1 Then
               .txPrimaryKey.ListIndex = delindx - 1
             Else
                On Error Resume Next
                .txPrimaryKey.ListIndex = 0
                On Error GoTo 0
             End If
            .Refresh
            
            If KillNode("xmlconfig/Services/ServiceData/ServicePrimaryKey", "ptype", txDN, "dn") = False Then
               MsgBox "An error occurred attempting to delete this primary key.", vbInformation
               Exit For
            End If
            
            If .txPrimaryKey.ListCount > 0 Then
               .txPrimaryKey.ListIndex = 0
            Else
               .txPrimaryKey.Enabled = False
               .btPrimaryKey.Enabled = False
            End If
            Exit For
         End If
      Next
   End With
   
errlog:
   Unload Me
    subErrLog "dgKey:btRemove_Click"
End Sub

Private Sub txDN_Change()
   txDN.SelLength = Len(txDN)
End Sub

Private Sub txType_Change()
   txType.SelLength = Len(txType)
End Sub

Private Sub txLen_Change()
   txLen.SelLength = Len(txLen)
End Sub

Private Sub txReq_Change()
   txReq.SelLength = Len(txReq)
End Sub



 

