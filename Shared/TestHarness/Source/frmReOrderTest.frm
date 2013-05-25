VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmReOrderTest 
   Caption         =   "Form1"
   ClientHeight    =   9855
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   13095
   LinkTopic       =   "Form1"
   ScaleHeight     =   9855
   ScaleWidth      =   13095
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Height          =   9255
      Left            =   60
      TabIndex        =   2
      Top             =   60
      Width           =   12975
      Begin VB.CommandButton butReOrderAndView 
         Caption         =   "Re Order"
         Height          =   375
         Left            =   10620
         TabIndex        =   10
         Top             =   1800
         Width           =   1395
      End
      Begin VB.TextBox SubTestCaseNumberInc 
         Height          =   285
         Left            =   11760
         TabIndex        =   9
         Text            =   "10"
         Top             =   1200
         Width           =   1095
      End
      Begin VB.TextBox SubTestCaseNumber 
         Height          =   285
         Left            =   11760
         TabIndex        =   7
         Text            =   "0"
         Top             =   780
         Width           =   1095
      End
      Begin VB.TextBox TestCaseNumber 
         Height          =   285
         Left            =   11760
         TabIndex        =   5
         Top             =   360
         Width           =   1095
      End
      Begin MSComctlLib.ListView lvTests 
         Height          =   8895
         Left            =   120
         TabIndex        =   3
         Top             =   240
         Width           =   9525
         _ExtentX        =   16801
         _ExtentY        =   15690
         View            =   3
         LabelEdit       =   1
         MultiSelect     =   -1  'True
         LabelWrap       =   -1  'True
         HideSelection   =   0   'False
         FullRowSelect   =   -1  'True
         GridLines       =   -1  'True
         _Version        =   393217
         Icons           =   "ImageList"
         SmallIcons      =   "ImageList"
         ForeColor       =   -2147483640
         BackColor       =   -2147483643
         BorderStyle     =   1
         Appearance      =   1
         NumItems        =   0
      End
      Begin VB.Label Label3 
         Caption         =   "Increment:"
         Height          =   435
         Left            =   9720
         TabIndex        =   8
         Top             =   1200
         Width           =   1995
      End
      Begin VB.Label Label2 
         Caption         =   "Start With Sub Test Case Number:"
         Height          =   435
         Left            =   9720
         TabIndex        =   6
         Top             =   780
         Width           =   1995
      End
      Begin VB.Label Label1 
         Caption         =   "Test Case Number:"
         Height          =   315
         Left            =   9660
         TabIndex        =   4
         Top             =   360
         Width           =   1575
      End
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   11820
      TabIndex        =   1
      Top             =   9420
      Width           =   1215
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   10500
      TabIndex        =   0
      Top             =   9420
      Width           =   1215
   End
   Begin MSComctlLib.ImageList ImageList 
      Left            =   7140
      Top             =   9480
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   3
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmReOrderTest.frx":0000
            Key             =   "Optional"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmReOrderTest.frx":059A
            Key             =   "Test"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmReOrderTest.frx":0B34
            Key             =   "Required"
         EndProperty
      EndProperty
   End
End
Attribute VB_Name = "frmReOrderTest"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_OK As Boolean
Private m_objFolder As CTDBItem

Private Sub butReOrderAndView_Click()
    Dim ll          As ListItem
    Dim strNewName  As String
    Dim p           As Long
    
    Dim TestCaseSubIndex    As Long
    Dim TestCaseSubInc      As Long
    
    If Len(SubTestCaseNumber.Text) = 0 Or Len(SubTestCaseNumber.Text) = 0 Or Len(SubTestCaseNumberInc.Text) = 0 Then
        Beep
        Exit Sub
    End If
    
    TestCaseSubIndex = CLng(SubTestCaseNumber.Text)
    TestCaseSubInc = CLng(SubTestCaseNumberInc.Text)
    
    For Each ll In Me.lvTests.ListItems
    
        If ll.Selected Then
            strNewName = ll.Text
            p = InStr(strNewName, " ")
            If p > 0 Then
                strNewName = Mid(strNewName, p)
                strNewName = TestCaseNumber.Text & "." & Format(TestCaseSubIndex, "000") & strNewName
                TestCaseSubIndex = TestCaseSubIndex + TestCaseSubInc
                ll.Text = strNewName
            End If
        End If
    Next
End Sub

Private Function ReOrderForGood() As Boolean

    Dim ll              As ListItem
    Dim Test            As CTDBItem
    Dim strOldFullName  As String
    Dim t               As New cTextFile
    Dim booIsExternalDescriptionFileNameExist As Boolean
    
    For Each ll In Me.lvTests.ListItems
    
        Set Test = g_objTDB.Find(ll.key)
        
        If IsValidObject(Test) Then
        
            If Test.Name <> ll.Text Then
            
                strOldFullName = Test.FullName
                booIsExternalDescriptionFileNameExist = Test.IsExternalDescriptionFileNameExist()
                
                Test.Name = ll.Text
                t.RenameFile strOldFullName, Test.FullName
                If booIsExternalDescriptionFileNameExist Then
                    t.RenameFile strOldFullName & ".description", Test.FullName & ".description"
                End If
                Test.UpdateNameInSession g_objTDB
            End If
        End If
    Next
    ReOrderForGood = True
End Function

Private Sub cmdCancel_Click()
    Hide
End Sub

Private Sub cmdOK_Click()
    m_OK = True
    Hide
End Sub

Public Function OpenDialog(objFolder As CTDBItem) As Boolean

    On Error GoTo ErrMgr
    
    Set m_objFolder = objFolder
    
    Me.Caption = PreProcess(TESTHARNESS_MESSAGE_7055, "NAME", objFolder.Name)
    
    PopulateListView
    
    Me.Show vbModal
    If m_OK Then
    
        If MsgBox(PreProcess(TESTHARNESS_MESSAGE_7056), vbQuestion + vbYesNo) = vbYes Then
        
            ReOrderForGood
            OpenDialog = True
        End If
    End If
    Unload Me
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), Me, "OpenDialog"
End Function


Private Function PopulateListView()
    
    Dim C               As CTDBItem
    Dim p               As Long
    Dim strNameNoIndex  As String
    Dim l       As ListItem
    
    lvAddColumn Me.lvTests, "Name", True, Me.lvTests.Width - (10 * Screen.TwipsPerPixelX)
    
    For Each C In m_objFolder.children
    
        If C.ItemType = TEST_ITEM Then
        
            Set l = Me.lvTests.ListItems.Add(, C.id, C.Name, , "Test")
            l.Tag = C.id
        End If
    Next
End Function


Private Sub SubTestCaseNumber_KeyPress(KeyAscii As Integer)
    KeyPressNumeric KeyAscii
End Sub

Private Sub SubTestCaseNumberInc_KeyPress(KeyAscii As Integer)
    KeyPressNumeric KeyAscii
End Sub

Private Sub KeyPressNumeric(KeyAscii As Integer)

    
    If InStr("01234567890" + (vbBack), Chr(KeyAscii)) = 0 Then KeyAscii = 0
End Sub

Private Sub TestCaseNumber_KeyPress(KeyAscii As Integer)

    If InStr("ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890 _-" + (vbBack), UCase$(Chr(KeyAscii))) = 0 Then KeyAscii = 0
End Sub
