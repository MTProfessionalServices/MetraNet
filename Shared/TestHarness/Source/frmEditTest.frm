VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmEditTest 
   Caption         =   "Edit Test"
   ClientHeight    =   10455
   ClientLeft      =   2775
   ClientTop       =   3765
   ClientWidth     =   15030
   Icon            =   "frmEditTest.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   10455
   ScaleWidth      =   15030
   StartUpPosition =   2  'CenterScreen
   Begin MSComctlLib.StatusBar StatusBar1 
      Align           =   2  'Align Bottom
      Height          =   435
      Left            =   0
      TabIndex        =   19
      Top             =   10020
      Width           =   15030
      _ExtentX        =   26511
      _ExtentY        =   767
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   1
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   26009
         EndProperty
      EndProperty
   End
   Begin MSComDlg.CommonDialog CM 
      Left            =   8460
      Top             =   9540
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.Frame Frame1 
      Height          =   9135
      Left            =   60
      TabIndex        =   2
      Top             =   60
      Width           =   14895
      Begin VB.CheckBox UseParameterNameInCommandLine 
         Caption         =   "Use Parameters Name In Command Line"
         Height          =   195
         Left            =   2400
         TabIndex        =   18
         Top             =   3240
         Width           =   3495
      End
      Begin VB.CheckBox UseGlobalParameterInCommandLine 
         Caption         =   "Use Global Parameter In Command Line"
         Height          =   255
         Left            =   6240
         TabIndex        =   17
         Top             =   3240
         Width           =   3555
      End
      Begin VB.Frame Frame2 
         Caption         =   "Parameters"
         Height          =   3975
         Left            =   120
         TabIndex        =   10
         Top             =   3540
         Width           =   14535
         Begin VB.CommandButton butResetAllParameterFromDescription 
            Caption         =   "Reset All"
            Height          =   375
            Left            =   4080
            TabIndex        =   21
            Top             =   3480
            Width           =   1215
         End
         Begin VB.TextBox ParameterToolTip 
            BackColor       =   &H80000000&
            Height          =   1935
            Left            =   8940
            Locked          =   -1  'True
            MultiLine       =   -1  'True
            ScrollBars      =   2  'Vertical
            TabIndex        =   20
            Top             =   1560
            Width           =   3315
         End
         Begin VB.CommandButton butDownParameter 
            Caption         =   "Down"
            Enabled         =   0   'False
            Height          =   375
            Left            =   8220
            TabIndex        =   16
            Top             =   3540
            Visible         =   0   'False
            Width           =   1215
         End
         Begin VB.CommandButton butUpParameter 
            Caption         =   "Up"
            Enabled         =   0   'False
            Height          =   375
            Left            =   9900
            TabIndex        =   15
            Top             =   3600
            Visible         =   0   'False
            Width           =   1215
         End
         Begin VB.CommandButton butRemoveParameter 
            Caption         =   "Remove"
            Enabled         =   0   'False
            Height          =   375
            Left            =   2760
            TabIndex        =   14
            Top             =   3480
            Width           =   1215
         End
         Begin VB.CommandButton butEditParameter 
            Caption         =   "Edit"
            Enabled         =   0   'False
            Height          =   375
            Left            =   1440
            TabIndex        =   13
            Top             =   3480
            Width           =   1215
         End
         Begin VB.CommandButton butAddParameter 
            Caption         =   "Add"
            Height          =   375
            Left            =   180
            TabIndex        =   12
            Top             =   3480
            Width           =   1215
         End
         Begin MSComctlLib.ListView Parameters 
            Height          =   1815
            Left            =   60
            TabIndex        =   11
            Top             =   240
            Width           =   8835
            _ExtentX        =   15584
            _ExtentY        =   3201
            View            =   3
            LabelEdit       =   1
            LabelWrap       =   0   'False
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
      Begin MSComctlLib.ImageList ImageList1 
         Left            =   12180
         Top             =   7980
         _ExtentX        =   1005
         _ExtentY        =   1005
         BackColor       =   -2147483643
         ImageWidth      =   16
         ImageHeight     =   16
         MaskColor       =   12632256
         _Version        =   393216
         BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
            NumListImages   =   5
            BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
               Picture         =   "frmEditTest.frx":0442
               Key             =   ""
            EndProperty
            BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
               Picture         =   "frmEditTest.frx":09DC
               Key             =   ""
            EndProperty
            BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
               Picture         =   "frmEditTest.frx":0F76
               Key             =   "parameter"
            EndProperty
            BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
               Picture         =   "frmEditTest.frx":1510
               Key             =   "Required"
            EndProperty
            BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
               Picture         =   "frmEditTest.frx":1AAA
               Key             =   "Optional"
            EndProperty
         EndProperty
      End
      Begin VB.CommandButton butSelectTestExecutionFile 
         Caption         =   "..."
         Height          =   335
         Left            =   14220
         TabIndex        =   9
         ToolTipText     =   "Select test executable"
         Top             =   2760
         Width           =   335
      End
      Begin VB.TextBox Program 
         Height          =   335
         Left            =   2400
         TabIndex        =   8
         Top             =   2760
         Width           =   11715
      End
      Begin VB.TextBox Description 
         BackColor       =   &H80000004&
         Height          =   2000
         Left            =   2400
         Locked          =   -1  'True
         MultiLine       =   -1  'True
         ScrollBars      =   3  'Both
         TabIndex        =   6
         Top             =   660
         Width           =   12075
      End
      Begin VB.TextBox Caption 
         BackColor       =   &H8000000F&
         Height          =   335
         Left            =   2400
         Locked          =   -1  'True
         TabIndex        =   4
         Top             =   240
         Width           =   12135
      End
      Begin VB.Label Label3 
         Caption         =   "Exection file (vbs, exe, bat,...):"
         Height          =   330
         Left            =   195
         TabIndex        =   7
         Top             =   2820
         Width           =   2175
      End
      Begin VB.Label Label2 
         Caption         =   "Description:"
         Height          =   335
         Left            =   200
         TabIndex        =   5
         Top             =   600
         Width           =   1575
      End
      Begin VB.Label Label1 
         Caption         =   "Name:"
         Height          =   335
         Left            =   200
         TabIndex        =   3
         Top             =   240
         Width           =   1575
      End
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   12120
      TabIndex        =   1
      Top             =   9600
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Height          =   375
      Left            =   10800
      TabIndex        =   0
      Top             =   9600
      Width           =   1215
   End
End
Attribute VB_Name = "frmEditTest"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit


Private m_booOK As Boolean

Private m_objTestItem As CTDBItem




Private Sub Form_Unload(Cancel As Integer)
    g_objIniFile.FormSaveRestore Me, True, True
End Sub

Private Sub Parameters_DblClick()

    On Error GoTo ErrMgr
    
    butEditParameter_Click


'    Dim objSelectedParameter As New CVariable
'    Dim Index As Integer
'
'    'get current selection from listview
'
'   If (IsValidObject(Parameters.SelectedItem)) Then
'      Index = Parameters.SelectedItem.Index
'
'      objSelectedParameter.Name = Parameters.SelectedItem.key
'      objSelectedParameter.Value = Parameters.SelectedItem.ListSubItems(1).Text
'
'      If (frmEditParameter.OpenDialog(objSelectedParameter, UseParameterNameInCommandLine.Value, False)) Then
'         'This is adding the changed name/value pair at the end of the list...Not good
'         m_objTestItem.Parameters.Remove Parameters.SelectedItem.key
'         m_objTestItem.Parameters.Add objSelectedParameter.Name, objSelectedParameter.Value
'         Me.RefreshUI
'      End If
'
'   End If


    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTest", "Parameters_DblClick"
End Sub

Private Sub Parameters_ItemClick(ByVal Item As ListItem)

    On Error GoTo ErrMgr

    butEditParameter.Enabled = True
    'butUpParameter.Enabled = True
    'butDownParameter.Enabled = True
    butRemoveParameter.Enabled = True
    'ParameterToolTip.Visible = False
    ParameterToolTip.Text = ""
    
    Dim objSelectedParameter As CTDBParameter
    Dim Index As Integer
  
    If (IsValidObject(Parameters.SelectedItem)) Then
   
        Index = Parameters.SelectedItem.Index
        Set objSelectedParameter = m_objTestItem.Parameters.Item(Parameters.SelectedItem.key)
        
        If Len(objSelectedParameter.DescriptionWithEnumsType) Then
            
            ParameterToolTip.Text = ReplaceTab(objSelectedParameter.DescriptionWithEnumsType)
        Else
            Status PreProcess(TESTHARNESS_MESSAGE_7033, "P", Parameters.Name)
            
        End If
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTest", "Parameters_ItemClick"
End Sub

Private Sub butSelectTestExecutionFile_Click()

    On Error GoTo ErrMgr


    Dim objTool     As New cTool
    Dim strFileName As String
    Dim objTextFile As New cTextFile
   
    
    strFileName = objTool.getUserOpenFile(cm, TESTHARNESS_MESSAGE_7012, TESTHARNESS_EXECUTION_TEST_SELECTOR_STRING, False, m_objTestItem.Path)
    If (Len(strFileName)) Then
        Program.Text = objTextFile.GetFileName(strFileName)
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTest", "butSelectTestExecutionFile_Click"
End Sub

Private Sub CancelButton_Click()

    On Error GoTo ErrMgr

    Hide

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTest", "CancelButton_Click"
End Sub



Private Sub butAddParameter_Click()

    On Error GoTo ErrMgr


    Dim objNewParameter As New CTDBParameter
    
    If (frmEditParameter.OpenDialog(objNewParameter, UseParameterNameInCommandLine.Value, True)) Then

        m_objTestItem.Parameters.AddInstance objNewParameter
        Me.RefreshUI
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTest", "butAddParameter_Click"
End Sub




Private Sub Form_Load()

    On Error GoTo ErrMgr

    m_booOK = False
    g_objIniFile.FormSaveRestore Me, False, True
    SetDescriptionFont Description
    SetDescriptionFont ParameterToolTip


    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTest", "Form_Load"
End Sub

Private Sub OKButton_Click()

    On Error GoTo ErrMgr

    m_booOK = True
    Hide
    
    

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTest", "OKButton_Click"
End Sub


Public Function OpenDialog(objTestItem As CTDBItem) As Boolean

    On Error GoTo ErrMgr


    Dim objParametersBackUp As CTDBParameters

    Load Me
    
    Set objParametersBackUp = objTestItem.ParametersCopy()
    
    Set m_objTestItem = objTestItem
        
    Caption = Replace(TESTHARNESS_MESSAGE_7001, "[NAME]", m_objTestItem.Caption)
    
    DoEvents
    Form_Resize
    
    m_objTestItem.PopulateDialog Me
    
    Description.Text = ReplaceTab(Description.Text)
    
    
    
    Me.Show vbModal
    
    If (m_booOK) Then
    
        m_objTestItem.PopulateInstance Me
        'Set m_objTestItem.Parameters = m_objTestItem.ParametersCopy
        OpenDialog = True
        
    Else
        'objTestItem.Parameters.Populate objParametersBackUp, True
        objTestItem.ReLoad
        
    End If
    Unload frmEditTest
    Set frmEditTest = Nothing


    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTest", "OpenDialog"
End Function





Public Function RefreshUI() As Boolean

    On Error GoTo ErrMgr

    m_objTestItem.PopupateParametersListView Parameters, True, False
    RefreshUI = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTest", "RefreshUI"
End Function


Private Sub butRemoveParameter_Click()

    On Error GoTo ErrMgr

    If (IsValidObject(Parameters.SelectedItem)) Then
    
        m_objTestItem.Parameters.Remove Parameters.SelectedItem.key, , True
        RefreshUI
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTest", "butRemoveParameter_Click"
End Sub

Private Sub butEditParameter_Click()

    On Error GoTo ErrMgr


    Dim objSelectedParameter As CTDBParameter
    Dim Index As Integer
    
    'get current selection from listview
  
   If (IsValidObject(Parameters.SelectedItem)) Then
   
      Index = Parameters.SelectedItem.Index
      
      Set objSelectedParameter = m_objTestItem.Parameters.Item(Parameters.SelectedItem.key)
      
      'objSelectedParameter.Name = Parameters.SelectedItem.key
      'objSelectedParameter.Value = Parameters.SelectedItem.ListSubItems(1).Text
      
      If (frmEditParameter.OpenDialog(objSelectedParameter, UseParameterNameInCommandLine.Value, False)) Then
      
         'This is adding the changed name/value pair at the end of the list...Not good
         'm_objTestItem.Parameters.Remove Parameters.SelectedItem.key
         'm_objTestItem.Parameters.AddInstance objSelectedParameter
         Me.RefreshUI
      End If
      
   End If



    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditTest", "butEditParameter_Click"
End Sub



Private Sub Parameters_KeyDown(KeyCode As Integer, Shift As Integer)
   'Debug.Print KeyCode
    
    If Shift And vbCtrlMask And KeyCode <> 17 Then
    
        Select Case UCase$(Chr(KeyCode))
            Case "S"
            Case "C"
            Case "V"
            Case "A"
        End Select
    Else
    
        Select Case KeyCode
        
            Case vbKeyDelete
                butRemoveParameter_Click
        End Select
    End If
End Sub





Public Function Status(Optional ByVal strMessage As String, Optional lngIndex As Long = 1) As Boolean

    On Error GoTo ErrMgr


    Me.StatusBar1.Panels(lngIndex).Text = strMessage
    Me.StatusBar1.Refresh

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), Me, "Status"
End Function




Private Sub Form_Resize()

    On Error Resume Next
    
    If Me.Width < (900 * Screen.TwipsPerPixelX) Then
        Me.Width = (900 * Screen.TwipsPerPixelX)
        Exit Sub
    End If
    If Me.Height < (700 * Screen.TwipsPerPixelX) Then
        Me.Height = (700 * Screen.TwipsPerPixelX)
        Exit Sub
    End If

    CancelButton.Top = Me.Height - CancelButton.Height - (30 * Screen.TwipsPerPixelY) - Me.StatusBar1.Height
    CancelButton.Left = Me.Width - CancelButton.Width - (10 * Screen.TwipsPerPixelY)
    
    OKButton.Top = CancelButton.Top
    OKButton.Left = CancelButton.Left - OKButton.Width - (10 * Screen.TwipsPerPixelY)
    
    Frame1.Width = Me.Width - (15 * Screen.TwipsPerPixelY)
    Frame1.Height = Me.Height - (37 * Screen.TwipsPerPixelY) - CancelButton.Height - Me.StatusBar1.Height
    
    Frame2.Width = Me.Width - (2 * 15 * Screen.TwipsPerPixelY)
    Frame2.Height = Frame1.Height - Frame2.Top - (5 * Screen.TwipsPerPixelY)
    
    Dim cap
    Set cap = Me.Controls("Caption")
    
    cap.Width = Me.Width - cap.Left - (55 * Screen.TwipsPerPixelX)
    Me.Description.Width = cap.Width
    Me.Program.Width = cap.Width - (20 * Screen.TwipsPerPixelX)
    butSelectTestExecutionFile.Left = Me.Program.Left + Me.Program.Width + (2 * Screen.TwipsPerPixelX)
    
    ParameterToolTip.Left = Parameters.Left
    ParameterToolTip.Width = Parameters.Width
    ParameterToolTip.Height = Frame2.Height * 25 / 100
    
    Parameters.Width = Me.Width - (50 * Screen.TwipsPerPixelX)
    Parameters.Height = Frame2.Height * 60 / 100
    
    ParameterToolTip.Top = Parameters.Top + Parameters.Height
    
    'butAddParameter.Top = Frame2.Height - butAddParameter.Height - (10 * Screen.TwipsPerPixelY)
    butAddParameter.Top = ParameterToolTip.Top + ParameterToolTip.Height + (5 * Screen.TwipsPerPixelY)
    butEditParameter.Top = butAddParameter.Top
    butRemoveParameter.Top = butAddParameter.Top
    butUpParameter.Top = butAddParameter.Top
    butDownParameter.Top = butAddParameter.Top
    butResetAllParameterFromDescription.Top = butAddParameter.Top
End Sub




Private Sub butResetAllParameterFromDescription_Click()

    m_objTestItem.ReadTeamplate
    Me.RefreshUI
End Sub

