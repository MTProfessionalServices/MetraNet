VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form frmParameterPicker 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Parameter Picker"
   ClientHeight    =   7260
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   10080
   Icon            =   "frmParameterPicker.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7260
   ScaleWidth      =   10080
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin MSComctlLib.ImageList ImageList 
      Left            =   5340
      Top             =   6840
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   2
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmParameterPicker.frx":058A
            Key             =   "Optional"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmParameterPicker.frx":0B24
            Key             =   "Required"
         EndProperty
      EndProperty
   End
   Begin VB.Frame Frame1 
      Height          =   6675
      Left            =   60
      TabIndex        =   2
      Top             =   60
      Width           =   9975
      Begin VB.CommandButton cmdUnSelect 
         Caption         =   "<<"
         Height          =   375
         Left            =   4380
         TabIndex        =   5
         Top             =   3360
         Width           =   1215
      End
      Begin VB.CommandButton cmdToSelected 
         Caption         =   ">>"
         Height          =   375
         Left            =   4380
         TabIndex        =   4
         Top             =   2940
         Width           =   1215
      End
      Begin MSComctlLib.ListView lvOptionalParameters 
         Height          =   5835
         Left            =   180
         TabIndex        =   7
         Top             =   600
         Width           =   4005
         _ExtentX        =   7064
         _ExtentY        =   10292
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
      Begin MSComctlLib.ListView lvSelectedParameters 
         Height          =   5835
         Left            =   5760
         TabIndex        =   8
         Top             =   600
         Width           =   4005
         _ExtentX        =   7064
         _ExtentY        =   10292
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
      Begin VB.Label Label2 
         Caption         =   "Selected Parameters"
         Height          =   255
         Left            =   5880
         TabIndex        =   6
         Top             =   360
         Width           =   3495
      End
      Begin VB.Label Label1 
         Caption         =   "Optional Parameters"
         Height          =   255
         Left            =   300
         TabIndex        =   3
         Top             =   300
         Width           =   3495
      End
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   7440
      TabIndex        =   0
      Top             =   6840
      Width           =   1215
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   8760
      TabIndex        =   1
      Top             =   6840
      Width           =   1215
   End
End
Attribute VB_Name = "frmParameterPicker"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit


Private m_booOK As Boolean

Public Function OpenDialog(objSourceTest As CTDBItem, ParametersSet As CTDBParameters) As Boolean

    Dim l       As ListItem
    Dim Param   As CTDBParameter
    
    Load Me
    m_booOK = False
    
    lvAddColumn Me.lvOptionalParameters, "Name", True, Me.lvOptionalParameters.Width - (5 * Screen.TwipsPerPixelX)
    lvAddColumn Me.lvSelectedParameters, "Name", True, Me.lvOptionalParameters.Width - (5 * Screen.TwipsPerPixelX)
    
    ' Populate based on the objSourceTest
    For Each Param In objSourceTest.Parameters
    
        If Param.Required Then
        
            Set l = Me.lvSelectedParameters.ListItems.Add(, Param.Name, Param.Name & " : " & Param.Value, , "Required")
            l.Tag = "Required"
        Else
            Set l = Me.lvOptionalParameters.ListItems.Add(, Param.Name, Param.Name & " : " & Param.Value, , "Optional")
            l.Tag = "Optional"
        End If
    Next
     
    ' Move to the Selected listview the optional parameter already selected, this is for the 'edit' mode
    For Each Param In ParametersSet
    
        If Not Param.Required Then
    
            Set l = Me.lvOptionalParameters.FindItem(Param.Name, lvwText)
            If IsValidObject(l) Then
            
                l.Selected = True
                cmdToSelected_Click
            Else
                Debug.Assert 0
            End If
        End If
    Next
    
    Me.Show vbModal
    If m_booOK Then
    
        ParametersSet.Clear
        For Each Param In objSourceTest.Parameters
        
            If IsParameterSelected(Param.Name) Then
            
                ParametersSet.AddInstance Param.Clone()
            End If
        Next
        OpenDialog = True
    End If
    Unload Me
End Function

Private Sub cmdCancel_Click()
    m_booOK = False
    Hide
End Sub

Private Sub cmdOK_Click()
    m_booOK = True
    Hide
End Sub

Private Sub cmdToSelected_Click()

    Dim l       As ListItem
    Dim ll      As ListItem
    Dim ItemsToDelete As New Collection

    For Each ll In Me.lvOptionalParameters.ListItems
    
        If ll.Selected Then
        
            Set l = Me.lvSelectedParameters.ListItems.Add(, ll.key, ll.Text, , "Optional")
            l.Tag = "Optional"
            ItemsToDelete.Add ll.key
        End If
    Next
    lvDeleteItem lvOptionalParameters, ItemsToDelete
End Sub

Private Sub cmdUnSelect_Click()

    Dim l   As ListItem
    Dim ll  As ListItem
    Dim ItemsToDelete As New Collection
       
    For Each ll In Me.lvSelectedParameters.ListItems

        If ll.Tag = "Optional" And ll.Selected Then
            
            Set l = Me.lvOptionalParameters.ListItems.Add(, ll.key, ll.Text, , "Optional")
            l.Tag = "Optional"
            ItemsToDelete.Add ll.key
        End If
    Next
    lvDeleteItem lvSelectedParameters, ItemsToDelete
    
End Sub



Private Sub Form_Load()

End Sub

Private Sub lvOptionalParameters_DblClick()
    cmdToSelected_Click
End Sub

Private Sub lvOptionalParameters_KeyDown(KeyCode As Integer, Shift As Integer)
If Shift And vbCtrlMask And KeyCode <> 17 Then
        Select Case UCase$(Chr(KeyCode))
            Case "A"
                lvSelectAll lvOptionalParameters, Not lvOptionalParameters.ListItems(1).Selected
        End Select
    End If
End Sub

Private Sub lvSelectedParameters_DblClick()
    cmdUnSelect_Click
End Sub

Private Sub lvSelectedParameters_KeyDown(KeyCode As Integer, Shift As Integer)
  
    If Shift And vbCtrlMask And KeyCode <> 17 Then
        Select Case UCase$(Chr(KeyCode))
            Case "A"
                lvSelectAll lvSelectedParameters, Not lvSelectedParameters.ListItems(1).Selected
        End Select
    End If
End Sub





Private Function IsParameterSelected(strName As String) As Boolean
    On Error Resume Next
    Dim l As ListItem
    Set l = Me.lvSelectedParameters.ListItems.Item(strName)
    IsParameterSelected = Err.Number = 0
    Err.Clear
End Function
