VERSION 5.00
Begin VB.Form frmAddCondition 
   Caption         =   "Add Condition"
   ClientHeight    =   5970
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   3870
   LinkTopic       =   "Form2"
   ScaleHeight     =   5970
   ScaleWidth      =   3870
   StartUpPosition =   3  'Windows Default
   Begin VB.ComboBox cmbRequired 
      Height          =   315
      ItemData        =   "frmAddCondition.frx":0000
      Left            =   1440
      List            =   "frmAddCondition.frx":000A
      Style           =   2  'Dropdown List
      TabIndex        =   27
      Top             =   3840
      Width           =   2055
   End
   Begin VB.Frame grpPosition 
      Height          =   1095
      Left            =   120
      TabIndex        =   22
      Top             =   4200
      Width           =   3495
      Begin VB.CommandButton btnMoveUp 
         Caption         =   "Move Up"
         Height          =   255
         Left            =   120
         TabIndex        =   24
         Top             =   600
         Width           =   1455
      End
      Begin VB.CommandButton btnMoveDown 
         Caption         =   "Move Down"
         Height          =   255
         Left            =   1680
         TabIndex        =   23
         Top             =   600
         Width           =   1455
      End
      Begin VB.Label Label11 
         Caption         =   "Current Position:"
         Height          =   255
         Left            =   120
         TabIndex        =   26
         Top             =   240
         Width           =   1215
      End
      Begin VB.Label lblPosition 
         BorderStyle     =   1  'Fixed Single
         Height          =   255
         Left            =   1440
         TabIndex        =   25
         Top             =   240
         Width           =   1215
      End
   End
   Begin VB.CommandButton btnCancel 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   375
      Left            =   2160
      TabIndex        =   21
      Top             =   5400
      Width           =   1455
   End
   Begin VB.CommandButton btnOK 
      Caption         =   "&OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   600
      TabIndex        =   20
      Top             =   5400
      Width           =   1455
   End
   Begin VB.ComboBox cmbFilter 
      Height          =   315
      ItemData        =   "frmAddCondition.frx":0017
      Left            =   1440
      List            =   "frmAddCondition.frx":0021
      TabIndex        =   18
      Top             =   3480
      Width           =   2055
   End
   Begin VB.ComboBox cmbDisplayOperator 
      Height          =   315
      ItemData        =   "frmAddCondition.frx":002E
      Left            =   1440
      List            =   "frmAddCondition.frx":003B
      TabIndex        =   16
      Top             =   3120
      Width           =   2055
   End
   Begin VB.ComboBox cmbEditOperator 
      Height          =   315
      ItemData        =   "frmAddCondition.frx":0052
      Left            =   1440
      List            =   "frmAddCondition.frx":005C
      TabIndex        =   14
      Top             =   2760
      Width           =   2055
   End
   Begin VB.ComboBox cmbOperator 
      Height          =   315
      ItemData        =   "frmAddCondition.frx":0069
      Left            =   1440
      List            =   "frmAddCondition.frx":007F
      TabIndex        =   13
      Top             =   2400
      Width           =   2055
   End
   Begin VB.TextBox txtHeader 
      Height          =   285
      Left            =   1440
      TabIndex        =   11
      Top             =   2040
      Width           =   2055
   End
   Begin VB.TextBox txtEnumType 
      Height          =   285
      Left            =   1440
      TabIndex        =   9
      Top             =   1680
      Width           =   2055
   End
   Begin VB.TextBox txtEnumSpace 
      Height          =   285
      Left            =   1440
      TabIndex        =   7
      Top             =   1320
      Width           =   2055
   End
   Begin VB.ComboBox cmbPType 
      Height          =   315
      ItemData        =   "frmAddCondition.frx":0098
      Left            =   1440
      List            =   "frmAddCondition.frx":00B1
      TabIndex        =   5
      Top             =   960
      Width           =   2055
   End
   Begin VB.TextBox txtPropName 
      Height          =   285
      Left            =   1440
      TabIndex        =   3
      Top             =   600
      Width           =   2055
   End
   Begin VB.ComboBox cmbColumnType 
      Height          =   315
      ItemData        =   "frmAddCondition.frx":00CB
      Left            =   1440
      List            =   "frmAddCondition.frx":00D8
      TabIndex        =   1
      Top             =   240
      Width           =   2055
   End
   Begin VB.Label Label12 
      Caption         =   "Required"
      Height          =   255
      Left            =   120
      TabIndex        =   28
      Top             =   3840
      Width           =   1215
   End
   Begin VB.Label Label10 
      Caption         =   "Filterable"
      Height          =   255
      Left            =   120
      TabIndex        =   19
      Top             =   3480
      Width           =   1215
   End
   Begin VB.Label Label9 
      Caption         =   "Display Operator"
      Height          =   255
      Left            =   120
      TabIndex        =   17
      Top             =   3120
      Width           =   1215
   End
   Begin VB.Label Label8 
      Caption         =   "Edit Operator"
      Height          =   255
      Left            =   120
      TabIndex        =   15
      Top             =   2760
      Width           =   1215
   End
   Begin VB.Label Label7 
      Caption         =   "Operator"
      Height          =   255
      Left            =   120
      TabIndex        =   12
      Top             =   2400
      Width           =   1215
   End
   Begin VB.Label Label6 
      Caption         =   "Header"
      Height          =   255
      Left            =   120
      TabIndex        =   10
      Top             =   2040
      Width           =   1215
   End
   Begin VB.Label Label5 
      Caption         =   "Enum Type"
      Height          =   255
      Left            =   120
      TabIndex        =   8
      Top             =   1680
      Width           =   1215
   End
   Begin VB.Label Label4 
      Caption         =   "Enum Space"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   1320
      Width           =   1215
   End
   Begin VB.Label Label3 
      Caption         =   "PType"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   960
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "Property Name"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   600
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Type"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   240
      Width           =   1215
   End
End
Attribute VB_Name = "frmAddCondition"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private mbolEditing As Boolean


Private Sub btnMoveUp_Click()
    Call frmMainTest.mobjTRReader.ConditionDatas.MoveItemUp(CLng(lblPosition))
    Unload Me
End Sub

Private Sub btnMoveDown_Click()
    Call frmMainTest.mobjTRReader.ConditionDatas.MoveItemDown(CLng(lblPosition))
    Unload Me
End Sub


Private Sub btnCancel_Click()
    Unload Me
End Sub

Private Sub btnOK_Click()
    Dim objCondition As New ConditionData
    
    objCondition.ColumnType = cmbColumnType
    objCondition.DisplayName = txtHeader
    objCondition.DisplayOperator = cmbDisplayOperator
    If cmbEditOperator = "Yes" Then
        objCondition.EditOperator = True
    Else
        objCondition.EditOperator = False
    End If
    objCondition.EnumSpace = txtEnumSpace
    objCondition.EnumType = txtEnumType
    If cmbFilter = "Yes" Then
        objCondition.Filterable = True
    Else
        objCondition.Filterable = False
    End If
    If cmbRequired = "Yes" Then
        objCondition.Required = True
    Else
        objCondition.Required = False
    End If
    
  '  objCondition.Index = ConditionList.Count + 1
    objCondition.Operator = cmbOperator
    objCondition.PropertyName = txtPropName
    objCondition.PType = cmbPType
    
     
    If mbolEditing Then
        Call frmMainTest.mobjTRReader.ConditionDatas.SetItem(objCondition, (CLng(lblPosition)))
    Else
        frmMainTest.mobjTRReader.ConditionDatas.Add objCondition
    End If
    Unload Me
End Sub




Private Sub Form_Load()
    Me.Caption = "Add Condition"
    grpPosition.Visible = False
    mbolEditing = False
End Sub

Public Sub EditCondition(ByVal iclngIndex As Long)
    
    cmbColumnType = frmMainTest.mobjTRReader.ConditionDatas(iclngIndex).ColumnType
    txtHeader = frmMainTest.mobjTRReader.ConditionDatas(iclngIndex).DisplayName
    cmbDisplayOperator = frmMainTest.mobjTRReader.ConditionDatas(iclngIndex).DisplayOperator
    cmbOperator = frmMainTest.mobjTRReader.ConditionDatas(iclngIndex).Operator
    txtEnumSpace = frmMainTest.mobjTRReader.ConditionDatas(iclngIndex).EnumSpace
    txtEnumType = frmMainTest.mobjTRReader.ConditionDatas(iclngIndex).EnumType
    txtPropName = frmMainTest.mobjTRReader.ConditionDatas(iclngIndex).PropertyName
    cmbPType = frmMainTest.mobjTRReader.ConditionDatas(iclngIndex).PType
    
    If frmMainTest.mobjTRReader.ConditionDatas(iclngIndex).EditOperator Then
        cmbEditOperator = "Yes"
    Else
        cmbEditOperator = "No"
    End If
    
    If frmMainTest.mobjTRReader.ConditionDatas(iclngIndex).Filterable Then
        cmbFilter = "Yes"
    Else
        cmbFilter = "No"
    End If
    If frmMainTest.mobjTRReader.ConditionDatas(iclngIndex).Required Then
        cmbRequired = "Yes"
    Else
        cmbRequired = "No"
    End If
    grpPosition.Visible = True
    lblPosition = iclngIndex
    mbolEditing = True
    Me.Caption = "Edit Condition"
End Sub
