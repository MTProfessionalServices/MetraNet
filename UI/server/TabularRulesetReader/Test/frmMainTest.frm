VERSION 5.00
Begin VB.Form frmMainTest 
   Caption         =   "Tabular Ruleset MetaFile Tester"
   ClientHeight    =   10110
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   13080
   LinkTopic       =   "Form1"
   ScaleHeight     =   10110
   ScaleWidth      =   13080
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton btnEditAction 
      Caption         =   "Edit Action"
      Height          =   375
      Left            =   9960
      TabIndex        =   24
      Top             =   8040
      Width           =   1695
   End
   Begin VB.CommandButton btnEditGlobal 
      Caption         =   "Edit Global Action"
      Height          =   375
      Left            =   6720
      TabIndex        =   23
      Top             =   8040
      Width           =   1695
   End
   Begin VB.CommandButton btnEditCondition 
      Caption         =   "Edit Condition"
      Height          =   375
      Left            =   3360
      TabIndex        =   22
      Top             =   8040
      Width           =   1695
   End
   Begin VB.CommandButton btnChangeProperties 
      Caption         =   "Change Properties"
      Height          =   375
      Left            =   120
      TabIndex        =   21
      Top             =   6720
      Width           =   1695
   End
   Begin VB.CommandButton btnSave 
      Caption         =   "Save"
      Height          =   375
      Left            =   9840
      TabIndex        =   20
      Top             =   120
      Width           =   1455
   End
   Begin VB.ComboBox cmbActions 
      Height          =   315
      Left            =   11760
      Style           =   2  'Dropdown List
      TabIndex        =   19
      Top             =   6720
      Width           =   735
   End
   Begin VB.ComboBox cmbGlobals 
      Height          =   315
      Left            =   8640
      Style           =   2  'Dropdown List
      TabIndex        =   18
      Top             =   6720
      Width           =   735
   End
   Begin VB.ComboBox cmbConditions 
      Height          =   315
      Left            =   5160
      Style           =   2  'Dropdown List
      TabIndex        =   17
      Top             =   6720
      Width           =   735
   End
   Begin VB.CommandButton btnDelAction 
      Caption         =   "Delete Action"
      Height          =   375
      Left            =   9960
      TabIndex        =   16
      Top             =   7560
      Width           =   1695
   End
   Begin VB.CommandButton btnDelGlobal 
      Caption         =   "Delete Global Action"
      Height          =   375
      Left            =   6720
      TabIndex        =   15
      Top             =   7560
      Width           =   1695
   End
   Begin VB.CommandButton btnDelCondition 
      Caption         =   "Delete Condition"
      Height          =   375
      Left            =   3360
      TabIndex        =   14
      Top             =   7560
      Width           =   1695
   End
   Begin VB.CommandButton btnAddAction 
      Caption         =   "Add Action"
      Height          =   375
      Left            =   9960
      TabIndex        =   13
      Top             =   7080
      Width           =   1695
   End
   Begin VB.CommandButton btnAddGlobal 
      Caption         =   "Add Global Action"
      Height          =   375
      Left            =   6720
      TabIndex        =   12
      Top             =   7080
      Width           =   1695
   End
   Begin VB.CommandButton btnAddCondition 
      Caption         =   "Add Condition"
      Height          =   375
      Left            =   3360
      TabIndex        =   11
      Top             =   7080
      Width           =   1695
   End
   Begin VB.ListBox lstErrors 
      Height          =   1035
      ItemData        =   "frmMainTest.frx":0000
      Left            =   120
      List            =   "frmMainTest.frx":0002
      TabIndex        =   9
      Top             =   8880
      Width           =   12855
   End
   Begin VB.ListBox lstActions 
      Height          =   5325
      ItemData        =   "frmMainTest.frx":0004
      Left            =   9840
      List            =   "frmMainTest.frx":0006
      TabIndex        =   7
      Top             =   1200
      Width           =   3135
   End
   Begin VB.ListBox lstGlobalActions 
      Height          =   5325
      ItemData        =   "frmMainTest.frx":0008
      Left            =   6600
      List            =   "frmMainTest.frx":000A
      TabIndex        =   5
      Top             =   1200
      Width           =   3135
   End
   Begin VB.ListBox lstConditions 
      Height          =   5325
      ItemData        =   "frmMainTest.frx":000C
      Left            =   3360
      List            =   "frmMainTest.frx":000E
      TabIndex        =   3
      Top             =   1200
      Width           =   3135
   End
   Begin VB.ListBox lstProperties 
      Height          =   5325
      ItemData        =   "frmMainTest.frx":0010
      Left            =   120
      List            =   "frmMainTest.frx":0012
      TabIndex        =   1
      Top             =   1200
      Width           =   3135
   End
   Begin VB.CommandButton btnLoad 
      Caption         =   "Load"
      Height          =   375
      Left            =   11400
      TabIndex        =   0
      Top             =   120
      Width           =   1455
   End
   Begin VB.Label Label8 
      Caption         =   "Selected Action:"
      Height          =   255
      Left            =   9960
      TabIndex        =   27
      Top             =   6720
      Width           =   1695
   End
   Begin VB.Label Label7 
      Caption         =   "Selected Action:"
      Height          =   255
      Left            =   6720
      TabIndex        =   26
      Top             =   6720
      Width           =   1695
   End
   Begin VB.Label Label6 
      Caption         =   "Selected Condition:"
      Height          =   255
      Left            =   3360
      TabIndex        =   25
      Top             =   6720
      Width           =   1695
   End
   Begin VB.Label Label5 
      Caption         =   "Errors:"
      Height          =   255
      Left            =   120
      TabIndex        =   10
      Top             =   8520
      Width           =   2055
   End
   Begin VB.Label Label4 
      Caption         =   "Actions"
      Height          =   255
      Left            =   9960
      TabIndex        =   8
      Top             =   960
      Width           =   2055
   End
   Begin VB.Label Label3 
      Caption         =   "Global Actions"
      Height          =   255
      Left            =   6720
      TabIndex        =   6
      Top             =   960
      Width           =   2055
   End
   Begin VB.Label Label2 
      Caption         =   "Conditions"
      Height          =   255
      Left            =   3480
      TabIndex        =   4
      Top             =   960
      Width           =   2055
   End
   Begin VB.Label Label1 
      Caption         =   "MetaFile Properties"
      Height          =   255
      Left            =   240
      TabIndex        =   2
      Top             =   960
      Width           =   2055
   End
End
Attribute VB_Name = "frmMainTest"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'----------------------------------------------------------------------------
' Copyright 1998-2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
'
'----------------------------------------------------------------------------


'----------------------------------------------------------------------------
'
'DESCRIPTION:   A test driver for the MTTabRulesetReader
'
'ASSUMPTIONS: none
'
'CALLS (REQUIRES): none
'
'----------------------------------------------------------------------------
Option Base 0
Option Explicit



'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
'none

'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
Public mobjTRReader As RulesetHandler



'----------------------------------------------------------------------------
' METHODS - Public
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: Add Buttons
'   Description:  Used to open the windows to add a condition, global action,
'               or regular action.  Reload the page when complete
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub btnAddAction_Click()
    Load frmAddAction
    frmAddAction.bolGlobal = False
    Call frmAddAction.Show(1, Me)
    Call LoadData
End Sub

Private Sub btnAddCondition_Click()
    Load frmAddCondition
    Call frmAddCondition.Show(1, Me)
    Call LoadData
End Sub

Private Sub btnAddGlobal_Click()
    Load frmAddAction
    frmAddAction.bolGlobal = True
    Call frmAddAction.Show(1, Me)
    Call LoadData
End Sub


'----------------------------------------------------------------------------
'   Name: Delete Buttons
'   Description:  Used to delete a condition, global action or regular action
'                   Reload the page when complete
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub btnDelAction_Click()
    If Len(cmbActions) > 0 Then
        Call mobjTRReader.actionDatas.Remove(cmbActions)
        Call LoadData
    End If
End Sub

Private Sub btnDelCondition_Click()
    If Len(cmbConditions) > 0 Then
        Call mobjTRReader.ConditionDatas.Remove(cmbConditions)
        Call LoadData
    End If
End Sub

Private Sub btnDelGlobal_Click()
    If Len(cmbGlobals) > 0 Then
        Call mobjTRReader.GlobalActionDatas.Remove(cmbGlobals)
        Call LoadData
    End If
End Sub


'----------------------------------------------------------------------------
'   Name: Edit Buttons
'   Description:  Used to open the windows to edit a condition, global action,
'               or regular action.  Reload the page when complete
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub btnEditAction_Click()
    If Len(cmbActions) > 0 Then
        Load frmAddAction
        frmAddAction.bolGlobal = False
        Call frmAddAction.EditAction(CLng(cmbActions))
        Call frmAddAction.Show(1, Me)
        Call LoadData
    End If
End Sub

Private Sub btnEditCondition_Click()
    If Len(cmbConditions) > 0 Then
        Load frmAddCondition
        Call frmAddCondition.EditCondition(CLng(cmbConditions))
        Call frmAddCondition.Show(1, Me)
        Call LoadData
    End If
End Sub

Private Sub btnEditGlobal_Click()
    If Len(cmbGlobals) > 0 Then
        Load frmAddAction
        frmAddAction.bolGlobal = True
        Call frmAddAction.EditAction(CLng(cmbGlobals))
        Call frmAddAction.Show(1, Me)
        Call LoadData
    End If
End Sub

'----------------------------------------------------------------------------
'   Name: Change Properties button
'   Description:  Opens a window to change the properties for the plugin
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub btnChangeProperties_Click()
    Load frmChangeProperties
    frmChangeProperties.Show (1)
    Call LoadData
End Sub


'----------------------------------------------------------------------------
'   Name: Load button
'   Description:  Reloads the data from file.  Calls load data to do most of the work
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub btnLoad_Click()
    Set mobjTRReader = New RulesetHandler
    Call mobjTRReader.Initialize(App.Path & "\tabrulesettest.xml")
    Call mobjTRReader.LoadEnums("US")
    Call LoadData
End Sub


'----------------------------------------------------------------------------
'   Name: Save button
'   Description:  Saves the data to file
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub btnSave_Click()
    Call mobjTRReader.save
End Sub


'----------------------------------------------------------------------------
'   Name: LoadData button
'   Description:  Loads all the data from the object and puts it onto the screen
'                   writes all the errors to the error list box
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub LoadData()
On Error Resume Next

    Dim objCondition As ConditionData
    Dim objAction   As ActionData
    Dim i
    
    ' clear out the lists first
    lstProperties.Clear
    lstConditions.Clear
    lstGlobalActions.Clear
    lstActions.Clear
    
    ' clear the combo boxes
    cmbConditions.Clear
    cmbGlobals.Clear
    cmbActions.Clear
    
    
    
    ' read all the properties from the object and put them in the list
    
    lstProperties.AddItem "ServiceDefinition: " & mobjTRReader.ServiceDefinition
    lstProperties.AddItem "Caption: " & mobjTRReader.Caption
    lstProperties.AddItem "PlugIn: " & mobjTRReader.PlugIn
    lstProperties.AddItem "ConditionsHeader: " & mobjTRReader.ConditionsHeader
    lstProperties.AddItem "ActionsHeader: " & mobjTRReader.ActionsHeader
    lstProperties.AddItem "HelpFile: " & mobjTRReader.HelpFile
    lstProperties.AddItem "HelpID: " & mobjTRReader.HelpID
    If Err Then
        lstErrors.AddItem "err during property reading: " & Err.Description
    End If
    
    ' populate all the conditions
    i = 1
    For Each objCondition In mobjTRReader.ConditionDatas
        lstConditions.AddItem "Condition: " & i
        lstConditions.AddItem " " & "ColumnType: " & objCondition.ColumnType
        lstConditions.AddItem " " & "DisplayName: " & objCondition.DisplayName
        lstConditions.AddItem " " & "Operator: " & objCondition.Operator
        lstConditions.AddItem " " & "DisplayOperator: " & objCondition.DisplayOperator
        lstConditions.AddItem " " & "EditOperator: " & objCondition.EditOperator
        lstConditions.AddItem " " & "EnumSpace: " & objCondition.EnumSpace
        lstConditions.AddItem " " & "EnumType: " & objCondition.EnumType
       ' lstConditions.AddItem " " & "EnumValues: " & objCondition.EnumValues
        lstConditions.AddItem " " & "Filterable: " & objCondition.Filterable
        lstConditions.AddItem " " & "Required: " & objCondition.Required
     '   lstConditions.AddItem " " & "Index: " & objCondition.Index
        lstConditions.AddItem " " & "PropertyName: " & objCondition.PropertyName
        lstConditions.AddItem " " & "PType: " & objCondition.PType
        lstConditions.AddItem ""
        
        cmbConditions.AddItem i
        i = i + 1
        
        If Err Then
            lstErrors.AddItem "err during Conditions: " & Err.Description
        End If
    Next
    
    ' populate the global actions
    i = 1
    For Each objAction In mobjTRReader.GlobalActionDatas
        lstGlobalActions.AddItem " " & "Action: " & i
        lstGlobalActions.AddItem " " & "ColumnType: " & objAction.ColumnType
        lstGlobalActions.AddItem " " & "DefaultValue: " & objAction.DefaultValue
        lstGlobalActions.AddItem " " & "DisplayName: " & objAction.DisplayName
        lstGlobalActions.AddItem " " & "Editable: " & objAction.Editable
        lstGlobalActions.AddItem " " & "EnumSpace: " & objAction.EnumSpace
        lstGlobalActions.AddItem " " & "EnumType: " & objAction.EnumType
      '  lstGlobalActions.AddItem " " & "EnumValues: " & objAction.EnumValues
      '  lstGlobalActions.AddItem " " & "Index: " & objAction.Index
        lstGlobalActions.AddItem " " & "PropertyName: " & objAction.PropertyName
        lstGlobalActions.AddItem " " & "PType: " & objAction.PType
        lstGlobalActions.AddItem ""
        
        cmbGlobals.AddItem i
        i = i + 1
        
        If Err Then
            lstErrors.AddItem "err during Global Actions: " & Err.Description
        End If
    Next
    
    ' populate the regular actions
    i = 1
    For Each objAction In mobjTRReader.actionDatas
        lstActions.AddItem " " & "Action: " & i
        lstActions.AddItem " " & "ColumnType: " & objAction.ColumnType
        lstActions.AddItem " " & "DefaultValue: " & objAction.DefaultValue
        lstActions.AddItem " " & "DisplayName: " & objAction.DisplayName
        lstActions.AddItem " " & "Editable: " & objAction.Editable
        lstActions.AddItem " " & "EnumSpace: " & objAction.EnumSpace
        lstActions.AddItem " " & "EnumType: " & objAction.EnumType
      '  lstActions.AddItem " " & "EnumValues: " & objAction.EnumValues
     '   lstActions.AddItem " " & "Index: " & objAction.Index
        lstActions.AddItem " " & "PropertyName: " & objAction.PropertyName
        lstActions.AddItem " " & "PType: " & objAction.PType
        lstActions.AddItem ""
        
        cmbActions.AddItem i
        i = i + 1
        
        If Err Then
            lstErrors.AddItem "err during Actions: " & Err.Description
        End If
    Next
    
    cmbConditions.ListIndex = cmbConditions.ListCount - 1
    cmbGlobals.ListIndex = cmbGlobals.ListCount - 1
    cmbActions.ListIndex = cmbActions.ListCount - 1

End Sub

Private Sub Form_Load()
    Call btnLoad_Click
End Sub
