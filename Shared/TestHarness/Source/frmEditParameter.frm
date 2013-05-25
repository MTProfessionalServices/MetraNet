VERSION 5.00
Begin VB.Form frmEditParameter 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Add/Edit Parameter"
   ClientHeight    =   2280
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   11955
   Icon            =   "frmEditParameter.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2280
   ScaleWidth      =   11955
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Height          =   1815
      Left            =   0
      TabIndex        =   9
      Top             =   -60
      Width           =   11895
      Begin VB.TextBox EnumValue 
         Height          =   335
         Left            =   1380
         TabIndex        =   6
         Top             =   1320
         Width           =   10305
      End
      Begin VB.CheckBox Required 
         Caption         =   "Required"
         Height          =   255
         Left            =   1380
         TabIndex        =   4
         Top             =   1020
         Width           =   1815
      End
      Begin VB.TextBox Value 
         Height          =   335
         Left            =   1380
         TabIndex        =   3
         Top             =   600
         Width           =   10305
      End
      Begin VB.TextBox Name 
         Height          =   335
         Left            =   1380
         TabIndex        =   1
         Top             =   240
         Width           =   10305
      End
      Begin VB.Label Label3 
         Caption         =   "&Enum Values:"
         Height          =   330
         Left            =   180
         TabIndex        =   5
         Top             =   1320
         Width           =   1275
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
      TabIndex        =   8
      Top             =   1860
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   9420
      TabIndex        =   7
      Top             =   1860
      Width           =   1215
   End
End
Attribute VB_Name = "frmEditParameter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit


Private m_booOK As Boolean


Private Sub Form_Load()

    On Error GoTo ErrMgr

    m_booOK = False

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditParameter", "Form_Load"
End Sub

Public Function OpenDialog(objParameter As CTDBParameter, booShowParameterNameTextBox As Boolean, booCanEditName As Boolean) As Boolean

    On Error GoTo ErrMgr

    Dim WinApi As New cWindows

    Load Me
    Me.Controls("Name").Text = objParameter.Name
    Me.Value.Text = objParameter.Value
    Me.Required.Value = IIf(objParameter.Required, vbChecked, vbUnchecked)
    Me.EnumValue.Text = objParameter.EnumValue
    
    
    Me.Controls("Name").Visible = booShowParameterNameTextBox
    Label1.Visible = booShowParameterNameTextBox
    If Not booShowParameterNameTextBox Then
        Me.Controls("Name").Text = WinApi.CreateGUIDKey()
    End If
    
    Me.Controls("Name").Enabled = booCanEditName
    Required_Click
    
    Me.Show vbModal
    If (m_booOK) Then
        objParameter.Name = Me.Controls("Name").Text
        objParameter.Value = Value.Text
        objParameter.Required = Me.Required.Value = vbChecked
        objParameter.EnumValue = Me.EnumValue.Text
        
        OpenDialog = True
    End If
    Unload Me
    Set frmEditParameter = Nothing
    

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditParameter", "OpenDialog"
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
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditParameter", "Name_KeyPress"
End Sub


Private Sub OKButton_Click()

    On Error GoTo ErrMgr

    If (IsValueSet()) Then
        m_booOK = True
        Hide
    End If

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditParameter", "OKButton_Click"
End Sub


Private Sub CancelButton_Click()

    On Error GoTo ErrMgr

    Hide

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditParameter", "CancelButton_Click"
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
    
    
        ' in 4.0 we accept that the value is blank
    
'        ShowError TESTHARNESS_ERROR_7013
'        Me.Controls("Value").SetFocus
'        IsValueSet = False

        IsValueSet = True

    Else
        IsValueSet = True
    End If

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "frmEditParameter", "IsValueSet"
End Function

Private Sub Required_Click()

    If Required.Value = vbChecked Then
    
        
        
    Else

        
    End If
End Sub
