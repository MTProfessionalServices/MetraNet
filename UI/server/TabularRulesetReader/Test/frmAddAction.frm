VERSION 5.00
Begin VB.Form frmAddAction 
   Caption         =   "Add Action"
   ClientHeight    =   4980
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   3735
   LinkTopic       =   "Form3"
   ScaleHeight     =   4980
   ScaleWidth      =   3735
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame grpPosition 
      Height          =   1095
      Left            =   120
      TabIndex        =   18
      Top             =   3120
      Width           =   3495
      Begin VB.CommandButton btnMoveDown 
         Caption         =   "Move Down"
         Height          =   255
         Left            =   1680
         TabIndex        =   22
         Top             =   600
         Width           =   1455
      End
      Begin VB.CommandButton btnMoveUp 
         Caption         =   "Move Up"
         Height          =   255
         Left            =   120
         TabIndex        =   21
         Top             =   600
         Width           =   1455
      End
      Begin VB.Label lblPosition 
         BorderStyle     =   1  'Fixed Single
         Height          =   255
         Left            =   1440
         TabIndex        =   20
         Top             =   240
         Width           =   1215
      End
      Begin VB.Label Label8 
         Caption         =   "Current Position:"
         Height          =   255
         Left            =   120
         TabIndex        =   19
         Top             =   240
         Width           =   1215
      End
   End
   Begin VB.TextBox txtDefaultValue 
      Height          =   285
      Left            =   1440
      TabIndex        =   17
      Top             =   2640
      Width           =   2055
   End
   Begin VB.CommandButton btnCancel 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   375
      Left            =   2040
      TabIndex        =   15
      Top             =   4440
      Width           =   1455
   End
   Begin VB.CommandButton btnOK 
      Caption         =   "&OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   480
      TabIndex        =   14
      Top             =   4440
      Width           =   1455
   End
   Begin VB.ComboBox cmbEditable 
      Height          =   315
      ItemData        =   "frmAddAction.frx":0000
      Left            =   1440
      List            =   "frmAddAction.frx":000A
      Style           =   2  'Dropdown List
      TabIndex        =   12
      Top             =   2280
      Width           =   2055
   End
   Begin VB.TextBox txtHeader 
      Height          =   285
      Left            =   1440
      TabIndex        =   11
      Top             =   1920
      Width           =   2055
   End
   Begin VB.TextBox txtEnumType 
      Height          =   285
      Left            =   1440
      TabIndex        =   9
      Top             =   1560
      Width           =   2055
   End
   Begin VB.TextBox txtEnumSpace 
      Height          =   285
      Left            =   1440
      TabIndex        =   7
      Top             =   1200
      Width           =   2055
   End
   Begin VB.ComboBox cmbPType 
      Height          =   315
      ItemData        =   "frmAddAction.frx":0017
      Left            =   1440
      List            =   "frmAddAction.frx":0030
      Style           =   2  'Dropdown List
      TabIndex        =   5
      Top             =   840
      Width           =   2055
   End
   Begin VB.TextBox txtPropName 
      Height          =   285
      Left            =   1440
      TabIndex        =   3
      Top             =   480
      Width           =   2055
   End
   Begin VB.ComboBox cmbColumnType 
      Height          =   315
      ItemData        =   "frmAddAction.frx":004A
      Left            =   1440
      List            =   "frmAddAction.frx":0057
      Style           =   2  'Dropdown List
      TabIndex        =   1
      Top             =   120
      Width           =   2055
   End
   Begin VB.Label Label7 
      Caption         =   "Default Value"
      Height          =   255
      Left            =   120
      TabIndex        =   16
      Top             =   2640
      Width           =   1215
   End
   Begin VB.Label Label10 
      Caption         =   "Editable"
      Height          =   255
      Left            =   120
      TabIndex        =   13
      Top             =   2280
      Width           =   1215
   End
   Begin VB.Label Label6 
      Caption         =   "Header"
      Height          =   255
      Left            =   120
      TabIndex        =   10
      Top             =   1920
      Width           =   1215
   End
   Begin VB.Label Label5 
      Caption         =   "Enum Type"
      Height          =   255
      Left            =   120
      TabIndex        =   8
      Top             =   1560
      Width           =   1215
   End
   Begin VB.Label Label4 
      Caption         =   "Enum Space"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   1200
      Width           =   1215
   End
   Begin VB.Label Label3 
      Caption         =   "PType"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   840
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "Property Name"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   480
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Type"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1215
   End
End
Attribute VB_Name = "frmAddAction"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Public bolGlobal As Boolean
Private mbolEditing As Boolean

Private Sub btnCancel_Click()
    Unload Me
End Sub

Private Sub btnMoveUp_Click()
    If bolGlobal Then
        Call frmMainTest.mobjTRReader.GlobalActionDatas.MoveItemUp(CLng(lblPosition))
    Else
        Call frmMainTest.mobjTRReader.actionDatas.MoveItemUp(CLng(lblPosition))
    End If
    Unload Me
End Sub

Private Sub btnMoveDown_Click()
    If bolGlobal Then
        Call frmMainTest.mobjTRReader.GlobalActionDatas.MoveItemDown(CLng(lblPosition))
    Else
        Call frmMainTest.mobjTRReader.actionDatas.MoveItemDown(CLng(lblPosition))
    End If
    Unload Me
End Sub

Private Sub btnOK_Click()
    Dim objAction As New ActionData
        
    objAction.ColumnType = cmbColumnType
    objAction.DisplayName = txtHeader
    objAction.EnumSpace = txtEnumSpace
    objAction.EnumType = txtEnumType
   ' objAction.Index = ActionList.Count + 1
    objAction.PropertyName = txtPropName
    objAction.PType = cmbPType
    objAction.DefaultValue = txtDefaultValue
    If cmbEditable = "Yes" Then
        objAction.Editable = True
    Else
        objAction.Editable = False
    End If
    
    
    If mbolEditing Then
        If bolGlobal Then
            Call frmMainTest.mobjTRReader.GlobalActionDatas.SetItem(objAction, CLng(lblPosition))
        Else
            Call frmMainTest.mobjTRReader.actionDatas.SetItem(objAction, CLng(lblPosition))
        End If
    
    Else
    
        If bolGlobal Then
            frmMainTest.mobjTRReader.GlobalActionDatas.Add objAction
        Else
            frmMainTest.mobjTRReader.actionDatas.Add objAction
        End If
    End If
    Unload Me
End Sub


Private Sub Form_Load()
    Me.Caption = "Add Action"
    grpPosition.Visible = False
    mbolEditing = False
End Sub

Public Sub EditAction(ByVal iclngIndex As Long)
    If bolGlobal Then
    
        cmbColumnType = frmMainTest.mobjTRReader.GlobalActionDatas(iclngIndex).ColumnType
        txtHeader = frmMainTest.mobjTRReader.GlobalActionDatas(iclngIndex).DisplayName
        txtEnumSpace = frmMainTest.mobjTRReader.GlobalActionDatas(iclngIndex).EnumSpace
        txtEnumType = frmMainTest.mobjTRReader.GlobalActionDatas(iclngIndex).EnumType
        txtPropName = frmMainTest.mobjTRReader.GlobalActionDatas(iclngIndex).PropertyName
        cmbPType = frmMainTest.mobjTRReader.GlobalActionDatas(iclngIndex).PType
        txtDefaultValue = frmMainTest.mobjTRReader.GlobalActionDatas(iclngIndex).DefaultValue
        If frmMainTest.mobjTRReader.GlobalActionDatas(iclngIndex).Editable Then
            cmbEditable = "Yes"
        Else
            cmbEditable = "No"
        End If
    Else
    
        cmbColumnType = frmMainTest.mobjTRReader.actionDatas(iclngIndex).ColumnType
        txtHeader = frmMainTest.mobjTRReader.actionDatas(iclngIndex).DisplayName
        txtEnumSpace = frmMainTest.mobjTRReader.actionDatas(iclngIndex).EnumSpace
        txtEnumType = frmMainTest.mobjTRReader.actionDatas(iclngIndex).EnumType
        txtPropName = frmMainTest.mobjTRReader.actionDatas(iclngIndex).PropertyName
        cmbPType = frmMainTest.mobjTRReader.actionDatas(iclngIndex).PType
        txtDefaultValue = frmMainTest.mobjTRReader.actionDatas(iclngIndex).DefaultValue
        If frmMainTest.mobjTRReader.actionDatas(iclngIndex).Editable Then
            cmbEditable = "Yes"
        Else
            cmbEditable = "No"
        End If
    End If
    grpPosition.Visible = True
    lblPosition = iclngIndex
    mbolEditing = True
    Me.Caption = "Edit Action"
End Sub
