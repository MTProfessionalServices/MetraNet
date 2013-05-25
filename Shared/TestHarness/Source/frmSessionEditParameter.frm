VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmSessionEditParameter 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Edit Parameter"
   ClientHeight    =   4215
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   11955
   Icon            =   "frmSessionEditParameter.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4215
   ScaleWidth      =   11955
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin MSComctlLib.ImageList ImageList1 
      Left            =   8580
      Top             =   1380
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   1
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmSessionEditParameter.frx":0ECA
            Key             =   ""
         EndProperty
      EndProperty
   End
   Begin VB.Frame Frame1 
      Height          =   3735
      Left            =   0
      TabIndex        =   7
      Top             =   -60
      Width           =   11895
      Begin VB.TextBox Description 
         BackColor       =   &H80000000&
         Height          =   2415
         Left            =   180
         MultiLine       =   -1  'True
         TabIndex        =   8
         Top             =   1140
         Width           =   11475
      End
      Begin VB.ComboBox cboValue 
         Height          =   315
         Left            =   1380
         Style           =   2  'Dropdown List
         TabIndex        =   4
         Top             =   960
         Visible         =   0   'False
         Width           =   10200
      End
      Begin VB.TextBox Value 
         Height          =   335
         Left            =   1380
         TabIndex        =   3
         Top             =   600
         Width           =   10200
      End
      Begin VB.TextBox Name 
         Height          =   335
         Left            =   1380
         TabIndex        =   1
         Top             =   240
         Width           =   10200
      End
      Begin VB.Label Label2 
         Caption         =   "&Value:"
         Height          =   330
         Left            =   180
         TabIndex        =   2
         Top             =   600
         Width           =   915
      End
      Begin VB.Label Label1 
         Caption         =   "&Name:"
         Height          =   330
         Left            =   180
         TabIndex        =   0
         Top             =   240
         Width           =   1575
      End
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   10680
      TabIndex        =   6
      Top             =   3780
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   9420
      TabIndex        =   5
      Top             =   3780
      Width           =   1215
   End
End
Attribute VB_Name = "frmSessionEditParameter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_booOK                 As Boolean
Private m_EnumsDescriptions     As Collection
Private m_strUserMessage        As String

Private Function GetEnumDescrition(strValue As String) As String
    On Error Resume Next
    GetEnumDescrition = m_EnumsDescriptions("I" & strValue)
End Function


Private Function GetCboValue() As String
    Dim s As String
    Dim p As Long
    p = InStr(cboValue.Text, " - ")
    If (p) Then
        GetCboValue = Trim(Mid(cboValue.Text, 1, p - 1))
    Else
        GetCboValue = Trim(cboValue.Text)
    End If
End Function

Private Sub cboValue_Change()
    Me.Value = GetCboValue()
    Description.Text = vbNewLine & m_strUserMessage & vbNewLine & vbNewLine & "Enum " & Me.Value & ":" & GetEnumDescrition(Me.Value)
End Sub

Private Sub cboValue_Click()
    cboValue_Change
End Sub

Private Sub cboValue_KeyUp(KeyCode As Integer, Shift As Integer)
    cboValue_Change
End Sub


Private Sub cboValue_Validate(Cancel As Boolean)
    cboValue_Change
End Sub

Private Sub Form_Load()

    On Error GoTo ErrMgr

    m_booOK = False
    
    SetDescriptionFont Description

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmSessionEditParameter", "Form_Load"
End Sub

Public Function OpenDialog(objParameter As CTDBParameter, booShowParameterNameTextBox As Boolean, booCanEditName As Boolean, strUserMessage As String) As Boolean

    On Error GoTo ErrMgr

    Dim WinApi                          As New cWindows
    Dim v                               As Variant
    Dim i                               As Long
    Dim strEnumDescription              As String
    Dim objOriginalSelectedTest         As CTDBItem
    Dim objOriginalSelectedParameter    As CTDBParameter

    Load Me
    m_strUserMessage = strUserMessage
    
    
    Me.Controls("Name").Text = objParameter.Name
    Me.Value.Text = objParameter.Value
    
    Set objOriginalSelectedTest = g_objTDB.Root.Find(objParameter.Parent.Parent.id)
    
    If Len(objParameter.EnumValue) Then
    
        Me.Value.Visible = False
        Me.cboValue.Visible = True
        Me.cboValue.Left = Me.Value.Left
        Me.cboValue.Top = Me.Value.Top
        
        Set m_EnumsDescriptions = New Collection
        
        For Each v In Split(objParameter.EnumValue, ",")
            
            strEnumDescription = ""
            
            If objOriginalSelectedTest.DescriptionParser.Parameters.Exist(objParameter.Name) Then
            
                If objOriginalSelectedTest.DescriptionParser.Parameters.ItemByName(objParameter.Name).Enums.Exist("" & v) Then
            
                    strEnumDescription = objOriginalSelectedTest.DescriptionParser.Parameters.ItemByName(objParameter.Name).Enums.ItemByName("" & v).Description
                    strEnumDescription = ReplaceTab(strEnumDescription)
                    strEnumDescription = Replace(strEnumDescription, vbNewLine, " ")
                    m_EnumsDescriptions.Add strEnumDescription, "I" & v
                End If
            End If
            If Len(strEnumDescription) Then
                Me.cboValue.AddItem v & " - " & strEnumDescription
            Else
                Me.cboValue.AddItem v
            End If
        Next
        ComboBoxSet cboValue, objParameter.Value
        
        ' Store the description of the parameter with the UserMessage - this is just a trick to display the comment of the parameter
        ' before the enum type description
        If objOriginalSelectedTest.DescriptionParser.Parameters.Exist(objParameter.Name) Then
        
            m_strUserMessage = m_strUserMessage & vbNewLine & vbNewLine & ReplaceTab(objOriginalSelectedTest.DescriptionParser.Parameters.ItemByName(objParameter.Name).Description)
        End If
        cboValue_Change ' call the event

    Else
        If objOriginalSelectedTest.DescriptionParser.Parameters.Exist(objParameter.Name) Then
        
            Description.Text = strUserMessage & vbNewLine & vbNewLine & ReplaceTab(objOriginalSelectedTest.DescriptionParser.Parameters.ItemByName(objParameter.Name).Description)
        Else
            Description.Text = strUserMessage
        End If
    End If
    
    Me.Controls("Name").Visible = booShowParameterNameTextBox
    Label1.Visible = booShowParameterNameTextBox
    If Not booShowParameterNameTextBox Then
        Me.Controls("Name").Text = WinApi.CreateGUIDKey()
    End If
    
    Me.Controls("Name").Locked = Not booCanEditName
    If Me.Controls("Name").Locked Then
        Me.Controls("Name").BackColor = &H80000004
    End If
        
    Me.Show vbModal
    If (m_booOK) Then
        objParameter.Name = Me.Controls("Name").Text
        objParameter.Value = Value.Text ' Even in the case of an enum the textbox Value contain the right value
        OpenDialog = True
    End If
    Unload Me
    Set frmEditParameter = Nothing
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmSessionEditParameter", "OpenDialog"
End Function

Private Sub Name_KeyPress(KeyAscii As Integer)

    On Error GoTo ErrMgr


    'check if the characters being entered are valid. Valid characters are a-z and 0-9
    If KeyAscii = Asc(vbBack) Then Exit Sub
    
    If (Not g_objTDB.IsValidParameterNameChar(Chr(KeyAscii))) Then
        KeyAscii = 0
        ShowError TESTHARNESS_ERROR_7009
    End If
    

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmSessionEditParameter", "Name_KeyPress"
End Sub


Private Sub OKButton_Click()

    On Error GoTo ErrMgr

    If (IsValueSet()) Then
        m_booOK = True
        Hide
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmSessionEditParameter", "OKButton_Click"
End Sub


Private Sub CancelButton_Click()

    On Error GoTo ErrMgr

    Hide

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmSessionEditParameter", "CancelButton_Click"
End Sub



Public Function IsValueSet() As Boolean

    On Error GoTo ErrMgr
   
    'check if the name field is set correctly
    If Len(Me.Controls("Name").Text) = 0 Then
        ShowError TESTHARNESS_ERROR_7013
        Me.Controls("Name").SetFocus
        IsValueSet = False
        
    'check if the name field is all numeric
    ElseIf (IsNumeric(Me.Controls("Name").Text)) Then
        ShowError TESTHARNESS_ERROR_7007
        Me.Controls("Name").SetFocus
        IsValueSet = False
                
    'check if the parameter field is not empty
    ElseIf Len(Me.Controls("Value").Text) = 0 Then
    
        ShowError TESTHARNESS_ERROR_7033
        Me.Controls("value").SetFocus
        IsValueSet = False

    Else
        IsValueSet = True
    End If

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmSessionEditParameter", "IsValueSet"
End Function
