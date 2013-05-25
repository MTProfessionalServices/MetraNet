VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmEditTestSession 
   Caption         =   "Edit Test"
   ClientHeight    =   14085
   ClientLeft      =   2775
   ClientTop       =   4050
   ClientWidth     =   20985
   Icon            =   "frmEditTestSession.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   14085
   ScaleWidth      =   20985
   Begin VB.CheckBox chkAddTestAsTemplate 
      Caption         =   "Add As Template"
      Height          =   255
      Left            =   6900
      TabIndex        =   20
      Top             =   13260
      Width           =   2175
   End
   Begin VB.CommandButton butApply 
      Caption         =   "Apply"
      Height          =   375
      Left            =   17160
      TabIndex        =   19
      Top             =   12900
      Width           =   1215
   End
   Begin MSComctlLib.StatusBar StatusBar1 
      Align           =   2  'Align Bottom
      Height          =   375
      Left            =   0
      TabIndex        =   17
      Top             =   13710
      Width           =   20985
      _ExtentX        =   37015
      _ExtentY        =   661
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   1
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   36513
         EndProperty
      EndProperty
   End
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   200
      Left            =   19500
      Top             =   1680
   End
   Begin VB.CommandButton cmdAdd 
      Caption         =   "Add"
      Enabled         =   0   'False
      Height          =   375
      Left            =   6840
      TabIndex        =   12
      Top             =   12780
      Width           =   1000
   End
   Begin VB.TextBox Description 
      Height          =   2445
      Left            =   1560
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   11
      Top             =   180
      Width           =   11055
   End
   Begin VB.CommandButton cmdRemove 
      Caption         =   "Remove"
      Height          =   375
      Left            =   7920
      TabIndex        =   10
      Top             =   12780
      Width           =   1000
   End
   Begin VB.Frame frameTestParameters 
      Caption         =   "Test Parameters"
      Height          =   9315
      Left            =   13560
      TabIndex        =   3
      Top             =   3300
      Width           =   6795
      Begin VB.CheckBox ContinueTestSessionIfFailed 
         Caption         =   "Continue the Test Session if the test or test session fails"
         Height          =   315
         Left            =   100
         TabIndex        =   16
         Top             =   8400
         Width           =   6375
      End
      Begin VB.TextBox TestDescription 
         BackColor       =   &H80000004&
         BeginProperty Font 
            Name            =   "Microsoft Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   1875
         Left            =   60
         Locked          =   -1  'True
         MultiLine       =   -1  'True
         ScrollBars      =   3  'Both
         TabIndex        =   15
         Top             =   180
         Width           =   4635
      End
      Begin VB.CheckBox UseGlobalParameterInCommandLine 
         Caption         =   "Use Global Parameters in Command Line"
         Height          =   255
         Left            =   100
         TabIndex        =   8
         Top             =   8040
         Width           =   3195
      End
      Begin VB.CheckBox UseParameterNameInCommandLine 
         Caption         =   "Use Parameter Names in Command Line"
         Height          =   255
         Left            =   100
         TabIndex        =   7
         Top             =   7680
         Width           =   3375
      End
      Begin VB.CommandButton budAddParameter 
         Caption         =   "Add"
         Height          =   375
         Left            =   120
         TabIndex        =   6
         Top             =   6420
         Width           =   1000
      End
      Begin VB.CommandButton budRemoveParameter 
         Caption         =   "Remove"
         Height          =   375
         Left            =   2280
         TabIndex        =   5
         Top             =   6420
         Width           =   1000
      End
      Begin VB.CommandButton butEditParameter 
         Caption         =   "Edit"
         Height          =   375
         Left            =   1200
         TabIndex        =   4
         Top             =   6420
         Width           =   1000
      End
      Begin MSComctlLib.ListView Parameters 
         Height          =   4215
         Left            =   60
         TabIndex        =   9
         Top             =   2160
         Width           =   4755
         _ExtentX        =   8387
         _ExtentY        =   7435
         View            =   3
         LabelEdit       =   1
         LabelWrap       =   -1  'True
         HideSelection   =   0   'False
         FullRowSelect   =   -1  'True
         GridLines       =   -1  'True
         _Version        =   393217
         SmallIcons      =   "ImageList1"
         ForeColor       =   -2147483640
         BackColor       =   -2147483643
         BorderStyle     =   1
         Appearance      =   1
         NumItems        =   0
      End
   End
   Begin VB.CheckBox chkSendEmail 
      Caption         =   "Send Email"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   1260
      Width           =   1395
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   19680
      TabIndex        =   1
      Top             =   12900
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Height          =   375
      Left            =   18420
      TabIndex        =   0
      Top             =   12900
      Width           =   1215
   End
   Begin MSComctlLib.ImageList imlTreeListView 
      Left            =   7440
      Top             =   8940
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   16
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":058A
            Key             =   "ExternalFolder"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":06E4
            Key             =   "SkippedTestSession"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":0C7E
            Key             =   "CompareDef"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":1218
            Key             =   "SkippedTest"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":17B2
            Key             =   "IgnoredFolder"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":1D4C
            Key             =   "SuperTestSession"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":22E6
            Key             =   "GlobalTest"
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":4A98
            Key             =   "TestSession"
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":5032
            Key             =   "StaticFile"
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":5F0C
            Key             =   "SystemFolder"
         EndProperty
         BeginProperty ListImage11 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":6226
            Key             =   "Root"
         EndProperty
         BeginProperty ListImage12 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":67C0
            Key             =   "Folder"
         EndProperty
         BeginProperty ListImage13 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":6D5A
            Key             =   "FolderOpen"
         EndProperty
         BeginProperty ListImage14 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":950C
            Key             =   "people"
         EndProperty
         BeginProperty ListImage15 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":9DE6
            Key             =   "new"
         EndProperty
         BeginProperty ListImage16 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":A380
            Key             =   "Test"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ImageList ImageList1 
      Left            =   14460
      Top             =   1800
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   9
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":A91A
            Key             =   ""
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":AEB4
            Key             =   "RequiredUnknown"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":B44E
            Key             =   "ExternalFolder"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":B5A8
            Key             =   ""
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":BB42
            Key             =   "Required"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":C0DC
            Key             =   "Optional"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":C676
            Key             =   "Test"
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":CC10
            Key             =   "Session"
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmEditTestSession.frx":D1AA
            Key             =   "parameter"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.TreeView tvTests 
      Height          =   10035
      Left            =   0
      TabIndex        =   13
      Top             =   3060
      Width           =   6555
      _ExtentX        =   11562
      _ExtentY        =   17701
      _Version        =   393217
      Indentation     =   353
      LabelEdit       =   1
      LineStyle       =   1
      Style           =   7
      ImageList       =   "imlTreeListView"
      Appearance      =   1
   End
   Begin MSComctlLib.ListView lvTests 
      Height          =   4635
      Left            =   7260
      TabIndex        =   18
      Top             =   3060
      Width           =   4155
      _ExtentX        =   7329
      _ExtentY        =   8176
      View            =   3
      LabelEdit       =   1
      MultiSelect     =   -1  'True
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      Icons           =   "imlTreeListView"
      SmallIcons      =   "imlTreeListView"
      ColHdrIcons     =   "imlTreeListView"
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
   Begin VB.Label Label2 
      Caption         =   "Description:"
      Height          =   330
      Left            =   180
      TabIndex        =   14
      Top             =   180
      Width           =   1575
   End
   Begin VB.Menu mnuTests 
      Caption         =   "Tests"
      Begin VB.Menu mnuTestsCopy 
         Caption         =   "Copy"
         Shortcut        =   ^C
      End
      Begin VB.Menu mnuTestsCut 
         Caption         =   "Cut"
         Shortcut        =   ^X
      End
      Begin VB.Menu mnuTestsPaste 
         Caption         =   "Paste"
         Shortcut        =   ^V
      End
      Begin VB.Menu mnuTestsExecute 
         Caption         =   "Execute"
         Shortcut        =   {F5}
      End
      Begin VB.Menu mnuTestsEditScript 
         Caption         =   "Edit Script"
         Shortcut        =   ^S
      End
      Begin VB.Menu mnuTestSkipUnSkip 
         Caption         =   "Skip/UnSkip"
      End
      Begin VB.Menu mnuTestContinueDoNotContinue 
         Caption         =   "Continue the Test Session if the test fail"
      End
      Begin VB.Menu mnuTestsSelectAll 
         Caption         =   "Select All"
         Shortcut        =   ^A
      End
      Begin VB.Menu mnuTestDelete 
         Caption         =   "Delete"
      End
      Begin VB.Menu mnuTestCopyTextInfo 
         Caption         =   "Copy Text Information"
         Visible         =   0   'False
      End
   End
   Begin VB.Menu TreeViewContextMenu 
      Caption         =   "TreeViewContextMenu"
      Begin VB.Menu TreeViewContextMenuEditTest 
         Caption         =   "Edit"
      End
   End
End
Attribute VB_Name = "frmEditTestSession"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'************************************************************************************************
'File: EditTestSession.frm
'Description: Handles the event code for the edit test session form of the test harness
'Authors: Frederic Torres, Anagha Rangarajan
'Date: 03/14/2001
'Modifications: 04/04/2001 Added Edit Parameter function.
'                          Added Move test up/down functions
'http://perso.wanadoo.fr/mnfauvel/Kb/html/comment2.htm
'***********************************************************************************************



Option Explicit


Const SKIPPED_TEST_COLOR = 128


Private m_booOK             As Boolean
Private m_objTestSession    As CTDBItem

Private m_fX As Single, m_fY As Single
Private m_oNode As Node
Private m_iScrollDir As Integer
Private m_bFlag As Integer




Private m_booUserClick As Boolean









Private Sub chkSendEmail_Click()

    On Error GoTo ErrMgr

Dim olapp As Object
Dim oitem As Object
Dim mystr As String


'Set olapp = CreateObject("Outlook.Application")
'Set oitem = olapp.CreateItem(0)
'With oitem
 ' .Subject = "Test Email Using VB and Outlook Object"
'  mystr = AppOptions("TxtEmail")
  '.To = mystr
  '.Body = "This message was sent from VB"
  '.send
'End With
'Set olapp = Nothing
'Set oitem = Nothing

m_objTestSession.PopulateInstance Me, chkSendEmail
    

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "chkSendEmail_Click"
End Sub










Private Sub ContinueTestSessionIfFailed_Click()

    On Error GoTo ErrMgr


    Dim lngID   As Long
    Dim objTest As CTDBItem

    If Not m_booUserClick Then Exit Sub
    
    If IsValidTestSelected() Then
        
        Set objTest = GetSelectedTest()
        objTest.PopulateInstance Me, ContinueTestSessionIfFailed
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "ContinueTestSessionIfFailed_Click"
End Sub

Private Sub Form_Load()

    On Error GoTo ErrMgr

    lvTests.BackColor = vbWhite

    g_objIniFile.FormSaveRestore Me, False, True
    m_booOK = False
    g_objTDB.FillTreeView Me.tvTests, True, True, True
    TreeViewReadState Me.tvTests, TreeViewStateFileName()
    mnuTests.Visible = False
    TreeViewContextMenu.Visible = False
    m_booUserClick = True
    
    
    SetDescriptionFont Description
    SetDescriptionFont TestDescription
    SetDescriptionFont tvTests
    SetDescriptionFont lvTests
    

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "Form_Load"
End Sub


Private Sub Form_Unload(Cancel As Integer)
    g_objIniFile.FormSaveRestore Me, True, True
End Sub

















Private Sub lvTests_KeyDown(KeyCode As Integer, Shift As Integer)

    Debug.Print KeyCode
    
    If Shift And vbCtrlMask And KeyCode <> 17 Then
    
        Select Case UCase$(Chr(KeyCode))
            Case "S"
                mnuTestsEditScript_Click
            Case "C"
                Debug.Print "COPY"
                mnuTestsCopy_Click
            Case "V"
                Debug.Print "PASTE"
                mnuTestsPaste_Click
            Case "A"
                mnuTestsSelectAll_Click
            Case "X"
                mnuTestsCut_Click
        End Select
    Else
        
        Select Case KeyCode
        
            Case vbKeyDelete
                CmdRemove_Click
                
            Case vbKeyF5
                mnuTestsExecute_Click
        End Select
    End If

    
End Sub

Private Sub lvTests_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
    Debug.Print Button
    If Button = 2 Then
        Debug.Print "POPUP:" + Me.mnuTests.Caption
        Me.PopupMenu Me.mnuTests
    End If
End Sub



Private Sub mnuTestDelete_Click()
    CmdRemove_Click
End Sub












'Private Sub SkipTestInSession_Click()
'
'    On Error GoTo ErrMgr
'
'    Dim lngID   As Long
'    Dim objTest As CTDBItem
'    Dim strCaption As String
'
'    If Not m_booUserClick Then Exit Sub
'
'    If m_booUserClick Then
'
'        If IsValidTestSelected() Then
'
'            Set objTest = GetSelectedTest()
'
'            objTest.PopulateInstance Me, SkipTestInSession
'
'            lvTests.List(lvTests.ListIndex) = SetTestListItemInfo(objTest)
'        End If
'    End If
'
'    Exit Sub
'ErrMgr:
'        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "SkipTestInSession_Click"
'End Sub



Private Sub OKButton_Click()

    On Error GoTo ErrMgr

    m_booOK = True
    Hide

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "OKButton_Click"
End Sub




Private Sub CancelButton_Click()

    On Error GoTo ErrMgr

    Hide

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "CancelButton_Click"
End Sub




Public Function OpenDialog(objTestSession As CTDBItem, Root As CTDBItem) As Boolean

    On Error GoTo ErrMgr

    
    Load Me
    
    m_booUserClick = False
    
    Set m_objTestSession = objTestSession
    
    m_objTestSession.PopulateDialog Me ' Popupate the dialog with the test session info
    FillTestListBox                    ' Populate the list box Tests with all the test associated with the Test session
    
    
    Description.Text = ReplaceTab(objTestSession.Description)
    
    Caption = Replace(TESTHARNESS_MESSAGE_7002, "[NAME]", m_objTestSession.Name)
    
    m_booUserClick = True
    If lvTests.ListItems.Count Then Set lvTests.SelectedItem = lvTests.ListItems.Item(1)
    lvTests_ItemClick Nothing
        
    Do
        m_booOK = False
        Me.Show vbModal
        
        If (m_booOK) Then
            
            m_objTestSession.PopulateInstance Me
            
            If m_objTestSession.ValidateIntegrity(False) Then
            
                OpenDialog = True
                Exit Do
            End If
        Else
            Exit Do
        End If
    Loop
    Unload frmEditTestSession
    Set frmEditTestSession = Nothing
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "OpenDialog"
End Function



Public Function GetSelectedObject() As CTDBItem

    On Error GoTo ErrMgr


    Dim objTest As CTDBItem

    If (IsValidObject(tvTests.SelectedItem)) Then
    
        Set objTest = g_objTDB.Find(tvTests.SelectedItem.key)
        
        If (IsValidObject(objTest)) Then
        
            Set GetSelectedObject = objTest
        End If
    End If

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "GetSelectedObject"
End Function







Private Sub tvTests_DblClick()

    On Error GoTo ErrMgr

    cmdADD_Click

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "tvTests_DblClick"
End Sub





Private Function FillTestListBox(Optional ByVal booRememberSelected As Boolean, Optional ByVal lngLongID As Long) As Boolean

    On Error GoTo ErrMgr

    Dim objTest         As CTDBItem
    Dim RootNode        As Node
    Dim l               As ListItem
    Dim lngNewIndex     As Long
    Dim lngColor        As Long
    Dim lngCurrentSelection As Long
    
    
    If booRememberSelected And IsValidObject(lvTests.SelectedItem) Then
    
        lngCurrentSelection = Mid(lvTests.SelectedItem.key, 3)
    End If
    
    m_booUserClick = False
    
    Debug.Print "FillTestListBox()"
        
    'lvTests.Clear
    
    lvTests.ListItems.Clear
    lvAddColumn lvTests, "Test/Session", True, 400 * 15
    
    For Each objTest In m_objTestSession.Tests
        
'        If objTest.SkipTestInSession Then
'
'            lngColor = SKIPPED_TEST_COLOR
'        Else
'            lngColor = vbBlack
'        End If
        'lvTests.AddItem SetTestListItemInfo(objTest)
        'lngNewIndex = lvTests.NewIndex
        'lvTests.itemData(lngNewIndex) = objTest.LongID
        Set l = lvTests.ListItems.Add(, "id" & objTest.LongID, "")
        SetTestListItemInfo objTest, l
        
        
        
    Next
    lvTestsUnSelectAll
    Parameters.ListItems.Clear
        
    ' Ask to select a specific one
    If lngLongID Then
    
        For Each l In lvTests.ListItems
        
            If lngLongID = CLng(Mid(l.key, 3)) Then
            
                Set lvTests.SelectedItem = l
            End If
        Next
    End If
    
    ' Ask to remember and restore the current selected
    If booRememberSelected And (lngCurrentSelection <> 0) Then
        
        Set lvTests.SelectedItem = lvTests.ListItems.Item("id" & lngCurrentSelection)
    End If
    m_booUserClick = True
    FillTestListBox = True
    
    On Error Resume Next
    lvTests.SetFocus
    
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "FillTestListBox"
        Debug.Print "ERROR-Adding:" & Format(objTest.LongID, "00000000") & " " & objTest.Name
End Function

Private Function SetTestListItemInfo(objTest As CTDBItem, l As ListItem) As String

    Dim strCaption      As String
    Dim strIcon         As String
    Dim lngColor        As Long
    
    If objTest.SkipTestInSession Then
    
        strCaption = objTest.Caption
        lngColor = SKIPPED_TEST_COLOR
        l.smallIcon = IIf(objTest.ItemType = TEST_ITEM, "SkippedTest", "SkippedTestSession")
    Else
        strCaption = objTest.Caption
        lngColor = vbBlack
        l.smallIcon = IIf(objTest.ItemType = TEST_ITEM, "Test", "TestSession")
    End If
    
    l.ForeColor = lngColor
    l.Text = strCaption
    
End Function


'Public Function GetSelectedTest() As CTDBItem
'
'    On Error GoTo ErrMgr
'
'
'    Dim lngID As Long
'
'    If IsValidTestSelected() Then
'
'        frameTestParameters.Visible = True
'
'        Set GetSelectedTest = m_objTestSession.Tests.Item(lvTests.SelectedItem.key)
'    End If
'
'    Exit Function
'ErrMgr:
'        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "GetSelectedTest"
'End Function

Public Function RefreshUI() As Boolean

    On Error GoTo ErrMgr
 
    lvTests_ItemClick Nothing

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "RefreshUI"
End Function




Private Sub UseGlobalParameterInCommandLine_Click()

    On Error GoTo ErrMgr

    Dim lngID   As Long
    Dim objTest As CTDBItem
    
    If Not m_booUserClick Then Exit Sub
    
    If IsValidTestSelected() Then
        
        Set objTest = GetSelectedTest()
        objTest.PopulateInstance Me, UseGlobalParameterInCommandLine
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "UseGlobalParameterInCommandLine_Click"
End Sub

Private Sub UseParameterNameInCommandLine_Click()

    On Error GoTo ErrMgr

    Dim lngID   As Long
    Dim objTest As CTDBItem
    
    If Not m_booUserClick Then Exit Sub
    
    If IsValidTestSelected() Then
        
        Set objTest = GetSelectedTest()
        objTest.PopulateInstance Me, UseParameterNameInCommandLine
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "UseParameterNameInCommandLine_Click"
End Sub




Public Function GetSelectedTest(Optional ByVal lngSpecificLongID As Long = -1) As CTDBItem

    On Error GoTo ErrMgr
    
    Dim lngLongID As Long
    
    If lngSpecificLongID = -1 Then
    
        If IsValidTestSelected() Then
            
            'Set GetSelectedTest = m_objTestSession.Tests.Item(lvTests.itemData(lvTests.ListIndex), , True)
            lngLongID = Mid(lvTests.SelectedItem.key, 3)
            Set GetSelectedTest = m_objTestSession.Tests.Item(lngLongID, , True)
        End If
    Else
        Set GetSelectedTest = m_objTestSession.Tests.Item(lngSpecificLongID, , True)
    End If
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "GetSelectedTest"
End Function


Private Sub CmdUp_Click()
    
    On Error GoTo ErrMgr
    
    'reorder the current test, move it up get the index of the selected item in the list
    
    '#PB
    
'    Dim Index       As Integer
'    Dim actualTest  As CTDBItem
'    Dim prevTest    As CTDBItem
'    Dim prevIndex   As Long
'    Dim prevId      As Long
'
'    Index = Tests.ListIndex
'
'    If (Index = 0) Or (Index = -1) Then 'if it is the first test, or not item is selected do nothing.
'        Exit Sub
'    Else
'
'        Set actualTest = Me.GetSelectedTest()
'
'        prevIndex = Index - 1
'        prevId = Tests.itemData(prevIndex)
'        Set prevTest = m_objTestSession.Tests.FindWithID(prevId)
'        m_objTestSession.Tests.MoveUpTestInTestSession actualTest, prevTest
'        FillTestListBox
'    End If
    
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "CmdUp_Click"
End Sub


Private Sub CmdDown_Click()
    
    On Error GoTo ErrMgr
    
'    'reorder the current test, move it down
'    Dim Index       As Integer
'    Dim count       As Long
'    Dim actualTest  As CTDBItem
'    Dim nextTest    As CTDBItem
'    Dim nextIndex   As Long
'    Dim nextId      As Long
'
'    count = Tests.ListCount
'    Index = Tests.ListIndex
'
'    'if it is the last test or no item is selected do nothing.
'    If (Index = count - 1) Or (Index = -1) Then
'        Exit Sub
'    Else
'        Set actualTest = Me.GetSelectedTest()
'
'        nextIndex = Index + 1
'        nextId = Tests.itemData(nextIndex)
'        Set nextTest = m_objTestSession.Tests.FindWithID(nextId)
'        m_objTestSession.Tests.MoveDownTestInTestSession actualTest, nextTest
'        FillTestListBox
'    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "CmdDown_Click"
End Sub


Private Sub Form_Resize()
    
    Dim w As Long
    Dim h As Long
    
    
    On Error GoTo ErrMgr
    
    Const Sepa = 2
    
    w = (Me.Width - (20 * Screen.TwipsPerPixelX)) / 3
    tvTests.Left = 0
    tvTests.Width = w
    tvTests.Height = Me.Height - (70 * Screen.TwipsPerPixelY) - Description.Height - Me.OKButton.Height - Me.StatusBar1.Height
    tvTests.Top = Me.Description.Top + Me.Description.Height + (10 * Screen.TwipsPerPixelY)
        
    lvTests.Left = tvTests.Left + tvTests.Width + (Sepa * Screen.TwipsPerPixelX)
    lvTests.Width = w
    lvTests.Height = tvTests.Height
    lvTests.Top = tvTests.Top
    
    frameTestParameters.Top = tvTests.Top
    frameTestParameters.Left = lvTests.Left + lvTests.Width + (Sepa * Screen.TwipsPerPixelX)
    frameTestParameters.Width = w
    frameTestParameters.Height = tvTests.Height
    
    Parameters.Width = frameTestParameters.Width - (10 * Screen.TwipsPerPixelX)
    TestDescription.Width = Parameters.Width
    
    Me.Description.Width = Me.Width - Me.Description.Left - (100 * Screen.TwipsPerPixelX)
    
    h = ((frameTestParameters.Height) / 3)
    
    TestDescription.Height = h
    Parameters.Top = TestDescription.Top + TestDescription.Height + (3 * Screen.TwipsPerPixelX)
    Parameters.Height = h
        
    budAddParameter.Top = Parameters.Top + Parameters.Height + (3 * Screen.TwipsPerPixelY)
    butEditParameter.Top = budAddParameter.Top
    budRemoveParameter.Top = budAddParameter.Top
    
    
    UseParameterNameInCommandLine.Top = budAddParameter.Top + budAddParameter.Height + (3 * Screen.TwipsPerPixelY)
    UseGlobalParameterInCommandLine.Top = UseParameterNameInCommandLine.Top + (UseParameterNameInCommandLine.Height * 1)
    ContinueTestSessionIfFailed.Top = UseParameterNameInCommandLine.Top + (UseParameterNameInCommandLine.Height * 2)
    'SkipTestInSession.Top = UseParameterNameInCommandLine.Top + (UseParameterNameInCommandLine.Height * 3)
    
    Me.CancelButton.Left = Me.Width - Me.CancelButton.Width - (20 * Screen.TwipsPerPixelX)
    Me.butApply.Left = Me.CancelButton.Left - Me.butApply.Width - (10 * Screen.TwipsPerPixelX)
    Me.OKButton.Left = Me.butApply.Left - Me.butApply.Width - (10 * Screen.TwipsPerPixelX)
    
    Me.CancelButton.Top = frameTestParameters.Top + frameTestParameters.Height + (10 * Screen.TwipsPerPixelY)
    Me.OKButton.Top = Me.CancelButton.Top
    Me.butApply.Top = Me.CancelButton.Top
    
    chkSendEmail.Left = Me.Description.Left + Me.Description.Width + (Sepa * Screen.TwipsPerPixelX)
    chkSendEmail.Top = Me.Description.Top
    
    lvTests.Height = lvTests.Height - cmdAdd.Height - (3 * Screen.TwipsPerPixelY)
    
    cmdAdd.Left = lvTests.Left + (3 * Screen.TwipsPerPixelX)
    cmdAdd.Top = lvTests.Top + lvTests.Height + (3 * Screen.TwipsPerPixelY)
    
    cmdRemove.Left = cmdAdd.Left + cmdAdd.Width + (3 * Screen.TwipsPerPixelX)
    cmdRemove.Top = cmdAdd.Top
    
    
    chkAddTestAsTemplate.Left = cmdAdd.Left
    chkAddTestAsTemplate.Top = cmdAdd.Top + cmdAdd.Height
    
    If lvTests.ColumnHeaders.Count Then
        lvTests.ColumnHeaders.Item(1).Width = lvTests.Width - (10 * Screen.TwipsPerPixelX)
    End If
    
    If Me.Height / Screen.TwipsPerPixelY < 700 Then
        Me.Height = 700 * Screen.TwipsPerPixelY
    End If
    
    If Me.Width / Screen.TwipsPerPixelX < 800 Then
        Me.Width = 800 * Screen.TwipsPerPixelX
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "Form_Resize"
    
End Sub



Private Sub tvTests_NodeClick(ByVal Node As MSComctlLib.Node)

    On Error GoTo ErrMgr

    ' #3.7 in 3.7 we can add test session to session
    cmdAdd.Enabled = (Me.GetSelectedObject().ItemType) = TEST_ITEM Or (Me.GetSelectedObject().ItemType = TEST_SESSION_ITEM)
    
    
    tvTests.ToolTipText = Me.GetSelectedObject().Description

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "tvTests_NodeClick"
End Sub



Private Function IsValidTestSelected() As Boolean

'    Dim i As Long
'
'    IsValidTestSelected = 0
'
'    If lvTests.ListCount > 0 Then
'
'        For i = 0 To lvTests.ListCount - 1
'
'            If lvTests.Selected(i) Then
'
'                IsValidTestSelected = i + 1
'                Exit Function
'            End If
'        Next
'    End If

    ' Quick way to avoid a or and thefore to evaluate TestsMultiSelected() when condition 1 is true
    IsValidTestSelected = True
    If IsValidObject(lvTests.SelectedItem) Then Exit Function
    If TestsMultiSelected() Then Exit Function
    IsValidTestSelected = False
    
End Function


Private Sub mnuTestCopyTextInfo_Click()
    
    Dim objPasteAfter As CTDBItem
    
    If IsValidTestSelected() Then

        m_objTestSession.CopyTextInfoToClipBoard
    End If

End Sub








' this fonction does return the session in sessions
Private Function GetSelectedLvTestsListItems(Optional ItemType As TDB_ItemType = TEST_ITEM + TEST_SESSION_ITEM) As Collection

    Dim C       As New Collection
    Dim l       As ListItem
    Dim objTest As CTDBItem
    
    For Each l In lvTests.ListItems
        
        Set objTest = GetSelectedTest(Mid(l.key, 3))
        
        If (l.Selected) Then
        
            If CBool(ItemType And objTest.ItemType) Then
            
                C.Add l
            End If
        End If
    Next
    Set GetSelectedLvTestsListItems = C
End Function


Private Function TestsMultiSelected() As Boolean

    TestsMultiSelected = GetSelectedLvTestsListItems.Count > 1
End Function


Private Function GetSelectedTestsLongIdCsvString(Optional ItemType As TDB_ItemType = TEST_ITEM + TEST_SESSION_ITEM) As String

    Dim s As String
    Dim l As ListItem
    
    
    For Each l In GetSelectedLvTestsListItems(ItemType)
        
        s = s & Mid(l.key, 3) & ","
    Next
    GetSelectedTestsLongIdCsvString = s
End Function


Private Sub butEditParameter_Click()

    On Error GoTo ErrMgr

    Dim objSelectedParameter        As CTDBParameter
    Dim objSelectedTest             As CTDBItem
    Dim objOriginalSelectedTest     As CTDBItem
    Dim objOriginalSelectedParameter        As CTDBParameter
    Dim Index                       As Integer
    Dim strUserMsg                  As String
        
    If (IsValidObject(Parameters.SelectedItem)) Then
   
      Index = Parameters.SelectedItem.Index
      
      Set objSelectedTest = GetSelectedTest()
      Set objSelectedParameter = objSelectedTest.Parameters.Item(Parameters.SelectedItem.key)
      
      ' Retreive the original test+parameter and copy the enum value. So if the enumvalue has change the ui will show the updated list
      Set objOriginalSelectedTest = g_objTDB.Root.Find(objSelectedTest.id)
      Set objOriginalSelectedParameter = objOriginalSelectedTest.Parameters.Item(Parameters.SelectedItem.key)
      objSelectedParameter.EnumValue = objOriginalSelectedParameter.EnumValue
           
      strUserMsg = IIf(objSelectedParameter.Required, PreProcess(TESTHARNESS_MESSAGE_7031, "P", objSelectedParameter.Name), PreProcess(TESTHARNESS_MESSAGE_7032, "DEFAULTVALUE", objSelectedParameter.Value, "P", objSelectedParameter.Name))
      
      If (frmSessionEditParameter.OpenDialog(objSelectedParameter, Me.UseParameterNameInCommandLine, False, strUserMsg)) Then
            
            If TestsMultiSelected() Then
                        
                m_objTestSession.SetParameter GetSelectedTestsLongIdCsvString(), objSelectedParameter
                Me.RefreshUI
            Else
                GetSelectedTest().Parameters.Item(Index).Name = objSelectedParameter.Name
                GetSelectedTest().Parameters.Item(Index).Value = objSelectedParameter.Value
                Me.RefreshUI
            End If
      End If
   End If


    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "butEditParameter_Click"
End Sub


Private Sub mnuTestsSelectAll_Click()

    Dim i As Long
    Dim booSelectedStatus As Boolean
    
    If TestsMultiSelected Then
        booSelectedStatus = False
    Else
        booSelectedStatus = True
    End If
    
    Dim l As ListItem
    For Each l In lvTests.ListItems
        l.Selected = booSelectedStatus
    Next

    If booSelectedStatus Then
    
    Else
         Set lvTests.SelectedItem = lvTests.ListItems.Item(1)
    End If
    
    lvTests_ItemClick Nothing
    
End Sub

Private Sub Parameters_DblClick()
    butEditParameter_Click
End Sub

Private Sub budAddParameter_Click()

    On Error GoTo ErrMgr


    Dim objNewParameter                 As New CTDBParameter
    Dim objParametersSetSelectedByUser  As New CTDBParameters
    Dim objSelectedTest                 As CTDBItem
    Dim objOriginalSelectedTest         As CTDBItem
    Dim objOriginalSelectedParameter    As CTDBParameter
    
    
    If TestsMultiSelected() Then
        
        If (frmSessionEditParameter.OpenDialog(objNewParameter, Me.UseParameterNameInCommandLine, True, "")) Then
        
            m_objTestSession.SetParameter GetSelectedTestsLongIdCsvString(), objNewParameter
            Me.RefreshUI
        End If
    Else
        Set objSelectedTest = GetSelectedTest()

        ' Retreive the original Test so we can have the full parameter description...
        Set objOriginalSelectedTest = g_objTDB.Root.Find(objSelectedTest.id)
        
        Set objParametersSetSelectedByUser = objSelectedTest.Parameters.Clone()
        
        If frmParameterPicker.OpenDialog(objOriginalSelectedTest, objParametersSetSelectedByUser) Then
        
            objSelectedTest.Parameters.UpdateParametersList objParametersSetSelectedByUser
            RefreshUI
        End If
    End If

    Exit Sub
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "budAddParameter_Click"
End Sub

Private Sub budRemoveParameter_Click()

    On Error GoTo ErrMgr

    If (IsValidObject(Parameters.SelectedItem)) Then
        
        If TestsMultiSelected() Then
            
            m_objTestSession.RemoveParameter GetSelectedTestsLongIdCsvString(), Parameters.SelectedItem.key
            Me.RefreshUI
        Else

            Dim t   As CTDBItem
            Dim rt  As CTDBItem
            Set t = GetSelectedTest()
            
            If t.Parameters.Item(Parameters.SelectedItem.key).Required Then
            
                Set rt = g_objTDB.Root.Find(t.id) ' retreive the test definition
                
                If IsValidObject(rt) Then
                
                    If rt.Parameters.Exist(Parameters.SelectedItem.key) Then ' make sure the parameter is still in the test
                    
                        If rt.Parameters.Item(Parameters.SelectedItem.key).Required Then
                        
                            MsgBox TESTHARNESS_ERROR_7049, vbCritical
                        Else
                            ' The required parameter is no more required in the test
                            ' we will allow to delete the required parameter from the session
                            t.Parameters.Remove Parameters.SelectedItem.key, , True
                        End If
                    Else
                        ' The required parameter has been removed from the test
                        ' we will allow to delete the required parameter from the session
                        t.Parameters.Remove Parameters.SelectedItem.key, , True
                    End If
                End If
            Else
                t.Parameters.Remove Parameters.SelectedItem.key
            End If
            
            RefreshUI
        End If
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "budRemoveParameter_Click"
End Sub





Private Sub CmdRemove_Click()

    On Error GoTo ErrMgr
    
    
    Dim i                    As Long
    Dim booContinue          As Boolean
    Dim l                    As ListItem

    If IsValidTestSelected() Then
        
        If TestsMultiSelected() Then
        
            booContinue = True
            Do While booContinue
            
                booContinue = False
                
                For Each l In GetSelectedLvTestsListItems()
                    
                    m_objTestSession.Tests.Remove Mid(l.key, 3), True
                    lvTests.ListItems.Remove l.Index
                    booContinue = True
                    Exit For
                Next
            Loop
            If lvTests.ListItems.Count Then ' Select the first item if exist
                Set lvTests.SelectedItem = lvTests.ListItems.Item(1)
            End If
        Else
            Set l = GetListItemBeforeSelected()
            m_objTestSession.Tests.Remove GetSelectedTest().LongID, True
            lvTests.ListItems.Remove lvTests.SelectedItem.Index
            Set lvTests.SelectedItem = l
            lvTests.SetFocus
        End If
    End If
    Exit Sub
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "CmdRemove_Click"
End Sub




Public Function Status(Optional ByVal strMessage As String, Optional lngIndex As Long = 1) As Boolean

    On Error GoTo ErrMgr

    
    Me.StatusBar1.Panels(lngIndex).Text = strMessage
    Me.StatusBar1.Refresh

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), Me, "Status"
End Function

Private Sub mnuTestsExecute_Click()

    Dim i As CTDBItem
    Dim C As Long
    Dim l As ListItem
    Dim wc As New CWaitCursor
    
    On Error GoTo ErrMgr
    
    wc.Wait Screen
    
    If IsValidTestSelected() Then
    
        If TestsMultiSelected() Then
        
            For Each l In GetSelectedLvTestsListItems()
                
                Set i = GetSelectedTest(Mid(l.key, 3))
                GoSub EXECUTE_I_TEST
            Next
        Else
            Set i = GetSelectedTest()
            i.OutputFileContext.Clear
            GoSub EXECUTE_I_TEST
        End If
    End If
    Exit Sub
    
EXECUTE_I_TEST:

    i.OutputFileContext.Clear
    
    Status PreProcess(TESTHARNESS_MESSAGE_7029, "NAME", i.Name)
    
    ' Execute the Session but pass the test long id
    If Not (m_objTestSession.Execute(AppOptions("ScriptingExecutable"), AppOptions("ShowScriptEngineWindow"), frmMain, , i.LongID)) Then
    
        ShowError PreProcess(TESTHARNESS_ERROR_7031, "NAME", i.Name)
    End If
    Status
Return
    
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "mnuTestsExecute_Click"
End Sub




Private Sub mnuTestsPaste_Click()

    Dim objPasteAfter As CTDBItem
    
    If IsValidTestSelected() Then
    
        Set objPasteAfter = GetSelectedTest()
        m_objTestSession.Tests.InsertTestsInToSession TestsClipBoard, objPasteAfter
        
    Else
    
        m_objTestSession.Tests.InsertTestsInToSession TestsClipBoard, Nothing
    End If
    FillTestListBox True
    lvTests.SetFocus
End Sub


Private Sub cmdADD_Click()

    On Error GoTo ErrMgr

'add a new test to the test session

    Dim objNewItem                      As CTDBItem
    Dim objItem                         As CTDBItem
    Dim objInsertAfterItem              As CTDBItem
    Dim objParameter                    As CTDBParameter
    Dim objParametersSetSelectedByUser  As New CTDBParameters
    Dim objOriginalSelectedTest         As CTDBItem
    
    Set objItem = Me.GetSelectedObject()
    
    If chkAddTestAsTemplate.Value = vbChecked Then ' Retrei

        Set objOriginalSelectedTest = g_objTDB.Root.Find(objItem.id)
        Set objItem = objOriginalSelectedTest.Clone(True, False)
        If Not objItem.ReadTeamplate() Then Exit Sub
    End If

    If (IsValidObject(objItem)) Then
    
        If IsValidTestSelected() Then
        
            If TestsMultiSelected() Then
            
                ShowError TESTHARNESS_ERROR_7032, "frmEditTestSession", "cmdADD_Click"
            Else
            
                If (objItem.ItemType = TEST_ITEM) Then
        
                    Set objInsertAfterItem = GetSelectedTest()
                    Set objNewItem = objItem.Clone(True, False)
                    
                    'GoSub PROCESS_PARAMETERS
                    
                    If frmParameterPicker.OpenDialog(objItem, objParametersSetSelectedByUser) Then
                    
                        objNewItem.Parameters.Populate objParametersSetSelectedByUser, True
                        m_objTestSession.Tests.InsertTestToSession objNewItem, objInsertAfterItem
                        FillTestListBox False, objNewItem.LongID ' Select the new one
                    End If
                    
                ElseIf (objItem.ItemType = TEST_SESSION_ITEM) Then
                
                
                    Set objInsertAfterItem = GetSelectedTest()
                    Set objNewItem = objItem.Clone(True, False)
                    
                    'GoSub PROCESS_PARAMETERS
                        
                    m_objTestSession.Tests.InsertTestToSession objNewItem, objInsertAfterItem
                    FillTestListBox False, objNewItem.LongID ' Select the new one
                End If
            End If
        Else
            Set objNewItem = objItem.Clone(True, False)
            
            If objNewItem.ItemType = TEST_ITEM Then
            
                If frmParameterPicker.OpenDialog(objNewItem, objParametersSetSelectedByUser) Then
                
                    objNewItem.Parameters.Populate objParametersSetSelectedByUser, True
                    m_objTestSession.Tests.AddTestToSession objNewItem
                    FillTestListBox
                End If
                
            ElseIf objNewItem.ItemType = TEST_SESSION_ITEM Then
            
                m_objTestSession.Tests.AddTestToSession objNewItem
                FillTestListBox , objNewItem.LongID
            End If
        End If
    End If
    Exit Sub

PROCESS_PARAMETERS: ' no more used

    For Each objParameter In objNewItem.Parameters
    
        If objParameter.Required Then
        
            If (frmSessionEditParameter.OpenDialog(objParameter, Me.UseParameterNameInCommandLine, False, TESTHARNESS_MESSAGE_7031)) Then
                
            Else
                Exit Sub ' Abandon adding the test to the session
            End If
        Else
            If (frmSessionEditParameter.OpenDialog(objParameter, Me.UseParameterNameInCommandLine, False, PreProcess(TESTHARNESS_MESSAGE_7032, "DEFAULTVALUE", objParameter.Value))) Then
                
            Else
                ' If the user we cancel and go on the the default value
            End If
        End If
    Next
Return
    
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "cmdADD_Click"
End Sub

Private Sub lvTests_ItemClick(ByVal Item As MSComctlLib.ListItem)

    On Error GoTo ErrMgr

    Dim lngID           As Long
    Dim objTest         As CTDBItem
    Dim objRealTest     As CTDBItem
    Dim strTestName     As String
    
    Debug.Print "lvTests_ItemClick"
    
    m_booUserClick = False
    
    If IsValidTestSelected() Then
        
        If TestsMultiSelected() Then
        
            Debug.Print "MULTI-Selected Detected"
        
            frameTestParameters.Caption = PreProcess(TESTHARNESS_MESSAGE_7026, "NUMBER", GetSelectedLvTestsListItems().Count)
            m_objTestSession.BuildInterSectionParameters GetSelectedTestsLongIdCsvString(TEST_ITEM) ' Here we want the TEST only no session

            m_objTestSession.PopupateParametersListView Me.Parameters, False, True
            
            SetVisiblePropertyFromFrame frameTestParameters, True
            GoSub HIDE_SOME_STUFF
            
        Else
        
            Debug.Print "MONO-Selected Detected"
            
            Set objTest = GetSelectedTest()
                       
            If objTest.ItemType = TEST_ITEM Then ' Select a Test
    
                objTest.PopupateParametersListView Me.Parameters, False, False
                objTest.PopulateDialog Me, ContinueTestSessionIfFailed
                objTest.PopulateDialog Me, UseParameterNameInCommandLine
                objTest.PopulateDialog Me, UseGlobalParameterInCommandLine
                
                frameTestParameters.Caption = PreProcess(TESTHARNESS_MESSAGE_7013, "NAME", objTest.Caption)
                
                ' Find the reals inplementation of the test and get the description....
                Set objRealTest = g_objTDB.Find(objTest.id)
                
                If IsValidObject(objRealTest) Then
                
                    TestDescription.Text = ReplaceTab(objRealTest.Description)
                    SetVisiblePropertyFromFrame frameTestParameters, True
                    GoSub HIDE_SOME_STUFF
                Else
                    ShowError PreProcess(TESTHARNESS_ERROR_7042, "NAME", objTest.Name), "frmEditTestSession", "Tests_Click"
                End If
                
            Else ' Select a session
            
                SetVisiblePropertyFromFrame frameTestParameters, False
                TestDescription.Visible = True
                ContinueTestSessionIfFailed.Visible = True
                objTest.PopulateDialog Me, ContinueTestSessionIfFailed
                frameTestParameters.Caption = PreProcess(TESTHARNESS_MESSAGE_7030, "NAME", objTest.Caption)
                
                ' Find the reals inplementation of the test and get the description....
                
                Set objRealTest = g_objTDB.Find(objTest.id)
                TestDescription.Text = ReplaceTab(objRealTest.Description)
                
            End If
        End If

    End If
    m_booUserClick = True
    Exit Sub
    
    
HIDE_SOME_STUFF:
    ' this controls are not available in multi selected mode
    TestDescription.Visible = Not TestsMultiSelected()
    UseParameterNameInCommandLine.Visible = Not TestsMultiSelected()
    UseGlobalParameterInCommandLine.Visible = Not TestsMultiSelected()
    ContinueTestSessionIfFailed.Visible = Not TestsMultiSelected()
    
Return
    
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "Tests_Click"
End Sub











Private Function lvTestsUnSelectAll() As Boolean

    Dim l       As ListItem
    
    For Each l In lvTests.ListItems
        
            l.Selected = False
    Next
End Function



Public Property Get TestsClipBoard() As CTDBItems
    Set TestsClipBoard = g_static_TestsClipBoard
End Property

Public Property Set TestsClipBoard(v As CTDBItems)
    Set g_static_TestsClipBoard = v
End Property





Private Sub butApply_Click()

    On Error GoTo ErrMgr

    m_objTestSession.ValidateIntegrity (False)
    m_objTestSession.PopulateInstance Me
    m_objTestSession.Save
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "butApply_Click"
End Sub



Private Function SelectNextTest() As Boolean

    Dim l       As ListItem
    Dim selItem As ListItem
    Dim booOK   As Boolean

    Set selItem = lvTests.SelectedItem
    lvTestsUnSelectAll
    
    For Each l In lvTests.ListItems
    
        If booOK Then
        
            Set lvTests.SelectedItem = l
            lvTests_ItemClick Nothing
            Exit Function
        End If
        
        If selItem Is l Then
        
            booOK = True
        End If
    Next


'    If lvTests.ListIndex < lvTests.ListCount - 1 Then
'
'        lvTests.ListIndex = lvTests.ListIndex + 1
'    End If
End Function




Private Function GetListItemBeforeSelected() As ListItem

    Dim l       As ListItem
    Dim p       As ListItem
    
    For Each l In lvTests.ListItems
        
        If lvTests.SelectedItem Is l Then
        
            Set GetListItemBeforeSelected = p
            Exit Function
        End If
        Set p = l
    Next
End Function


Private Sub mnuTestsCopy_Click()

    If IsValidTestSelected() Then
    
        Set TestsClipBoard = New CTDBItems
        
        Dim t As CTDBItem
        Dim l As ListItem
                
        For Each l In GetSelectedLvTestsListItems()
            
            Set t = GetSelectedTest(Mid(l.key, 3))
            TestsClipBoard.AddTestToSession t.Clone(True, True)
        Next
    End If
End Sub



Private Sub mnuTestsCut_Click()

    If IsValidTestSelected() Then
    
        mnuTestsCopy_Click
        mnuTestDelete_Click
    End If
End Sub





Private Sub Parameters_ItemClick(ByVal Item As MSComctlLib.ListItem)

    Dim objSelectedParameter                As CTDBParameter
    Dim objSelectedTest                     As CTDBItem
    Dim objOriginalSelectedTest             As CTDBItem
    Dim objOriginalSelectedParameter        As CTDBParameter
    Dim Index                               As Integer
    Dim strUserMsg                          As String
        
    If (IsValidObject(Parameters.SelectedItem)) Then
   
        Index = Parameters.SelectedItem.Index
        Set objSelectedTest = GetSelectedTest()
        Set objSelectedParameter = objSelectedTest.Parameters.Item(Parameters.SelectedItem.key)
      
        ' Retreive the original test+parameter and copy the enum value. So if the enumvalue has change the ui will show the updated list
        Set objOriginalSelectedTest = g_objTDB.Root.Find(objSelectedTest.id)
        
        If IsValidObject(objOriginalSelectedTest) Then
        
            Set objOriginalSelectedParameter = objOriginalSelectedTest.Parameters.Item(Parameters.SelectedItem.key)
            
            If IsValidObject(objOriginalSelectedParameter) Then
            
                'objSelectedParameter.EnumValue = objOriginalSelectedParameter.EnumValue
                Me.TestDescription.Text = ReplaceTab(objOriginalSelectedParameter.DescriptionWithEnumsType)
            Else
                ShowError PreProcess(TESTHARNESS_ERROR_7039, "P", objSelectedParameter.Name), "frmEditTestSession", "Parameters_ItemClick"
            End If
        Else
            ShowError PreProcess(TESTHARNESS_ERROR_7042, "NAME", objSelectedTest.Name), "frmEditTestSession", "Parameters_ItemClick"
        End If
    End If
      
End Sub



Private Sub mnuTestsEditScript_Click()

    Dim i                           As CTDBItem
    Dim objOriginalSelectedTest     As CTDBItem
    
    
    On Error GoTo ErrMgr
    
    
    
    If IsValidTestSelected() Then
    
        If TestsMultiSelected() Then
            
        Else
            Set i = GetSelectedTest()
            Set objOriginalSelectedTest = g_objTDB.Root.Find(i.id)
            objOriginalSelectedTest.EditScript AppOptions("editor", "notepad.exe"), True
            objOriginalSelectedTest.DescriptionParserRefresh
            lvTests_ItemClick Nothing
        End If
    End If
    Exit Sub
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "mnuTestsEditScript_Click"
End Sub



Private Sub tvTests_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
    If Button = 2 Then
        Me.PopupMenu TreeViewContextMenu
    End If
End Sub




Private Sub TreeViewContextMenuEditTest_Click()

    Dim objNewItem          As CTDBItem
    Dim objItem             As CTDBItem
    Dim objInsertAfterItem  As CTDBItem
    Dim objParameter        As CTDBParameter
    Dim objParametersSetSelectedByUser As New CTDBParameters
    
    Set objItem = Me.GetSelectedObject()

    If (IsValidObject(objItem)) Then
    
        If objItem.ItemType = TEST_ITEM Then
    
            If (frmEditTest.OpenDialog(objItem)) Then
        
                GetSelectedObject().Save
            End If
        Else
            ShowError TESTHARNESS_ERROR_7036, "frmEditTestSession", "TreeViewContextMenuEditTest_Click"
        End If
    End If
End Sub



Private Sub mnuTestContinueDoNotContinue_Click()

    On Error GoTo ErrMgr

    Dim lngID   As Long
    Dim objTest As CTDBItem
    Dim strCaption As String
    
    If IsValidTestSelected() Then
    
        If TestsMultiSelected() Then
            

            m_objTestSession.ContinueDoNotContinueTestSessionIfFailed GetSelectedTestsLongIdCsvString()
            FillTestListBox
            lvTests.SetFocus
        Else
            Set objTest = GetSelectedTest()
            objTest.ContinueTestSessionIfFailed = Not objTest.ContinueTestSessionIfFailed
            
            'objTest.PopulateInstance Me, SkipTestInSession
            'lvTests.List(lvTests.ListIndex) = SetTestListItemInfo(objTest)
            'FillTestListBox True
            
            SetTestListItemInfo objTest, lvTests.SelectedItem
            
            'lvTests.SetFocus
        End If
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "mnuTestContinueDoNotContinue_Click"
End Sub



Private Sub mnuTestSkipUnSkip_Click()

    On Error GoTo ErrMgr

    Dim lngID   As Long
    Dim objTest As CTDBItem
    Dim strCaption As String
    
    If IsValidTestSelected() Then
    
        If TestsMultiSelected() Then
            
            m_objTestSession.SkipUnSkip GetSelectedTestsLongIdCsvString()
            FillTestListBox
            lvTests.SetFocus
        Else
            Set objTest = GetSelectedTest()
            objTest.SkipTestInSession = Not objTest.SkipTestInSession
            
            'objTest.PopulateInstance Me, SkipTestInSession
            'lvTests.List(lvTests.ListIndex) = SetTestListItemInfo(objTest)
            'FillTestListBox True
            
            SetTestListItemInfo objTest, lvTests.SelectedItem
            
            'lvTests.SetFocus
        End If
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTestSession", "mnuTestSkipUnSkip_Click"
End Sub

