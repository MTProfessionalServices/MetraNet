VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ConditionData"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"39AD43FD0202"
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
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
' $Modified by: Fabricio Pettena 4/15/2001
' $Revision$
'
'
'----------------------------------------------------------------------------


'----------------------------------------------------------------------------
'
'DESCRIPTION:   Stores some extra information about Conditions that is
'               needed to correctly render a tabular ruleset screen.  Data stored
'               includes type information, display information, test conditions
'
'ASSUMPTIONS: none
'
'CALLS (REQUIRES): none
'
'----------------------------------------------------------------------------
Option Explicit



'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
#Const DebugMode = 0       'set this to 0 to disable debug code in this class



'----------------------------------------------------------------------------
' ENUMS
'----------------------------------------------------------------------------
'Public Enum String
'    NO_DISPLAY = 0
'    COLUMN_DISPLAY = 1
'    ROW_DISPLAY = 2
'End Enum



'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
#If DebugMode Then
    'local variable to hold the serialized class ID that was created in Class_Initialize
    Private mlngClassDebugID As Long
#End If

Private mstrColumnType          As String           ' the type (metered, synthetic, label, etc...)
Private mstrDisplayName         As String           'The display name for the action
Private mstrEnumSpace           As String           'The EnumSpace, if the PType is enum
Private mcolEnumValues          As Collection
Private mcolEnumStrings         As Collection
Private mstrEnumType            As String           'The EnumType, if the PType is Enum
Private mbolFilterable          As Boolean          ' A flag to indicate whether the condition can be used to filter.
'Private mlngIndex               As Long             'The index of the property (what order it appears)
Private mstrPropertyName        As String           'The property name of the action
Private mintPType               As PropValType           'The PType of the property
Private mstrOperator            As String           ' The conditional operator to use
Private mbolRequired            As Boolean
Private mstrDisplayOperator     As String           ' indicates if and where the operator should appear
Private mbolEditOperator        As Boolean          ' A flag to indicate whether the user can choose the operator
Private mintLength              As Integer
Private mvarDefaultValue        As Variant          'The default value for the action


'----------------------------------------------------------------------------
' PROPERTIES
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: ColumnType
'   Description:  Get and Let - the type (metered, synthetic, label, etc...)
'the operator
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get ColumnType() As String
   Let ColumnType = mstrColumnType
End Property

Public Property Let ColumnType(ByVal Value As String)
    Let mstrColumnType = Value
End Property


'----------------------------------------------------------------------------
'   Name: DefaultValue
'   Description:  Get and Let - The default value for the condition - assumes that
'                   the underlying Variant type is a simple data type
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get DefaultValue() As Variant
    Let DefaultValue = mvarDefaultValue
End Property

Public Property Let DefaultValue(ByVal Value As Variant)
    Let mvarDefaultValue = Value
End Property


'----------------------------------------------------------------------------
'   Name: DisplayName
'   Description:  Get and Let - The display name for the action
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get DisplayName() As String
    Let DisplayName = mstrDisplayName
End Property

Public Property Let DisplayName(ByVal Value As String)
    Let mstrDisplayName = Value
End Property


'----------------------------------------------------------------------------
'   Name: EnumSpace
'   Description:  Get and Let - The EnumSpace, if the PType is enum
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get EnumSpace() As String
    Let EnumSpace = mstrEnumSpace
End Property

Public Property Let EnumSpace(ByVal Value As String)
    Let mstrEnumSpace = Value
End Property


'----------------------------------------------------------------------------
'   Name: EnumType
'   Description: Get and Let - The EnumType, if the PType is Enum
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get EnumType() As String
    Let EnumType = mstrEnumType
End Property

Public Property Let EnumType(ByVal Value As String)
    Let mstrEnumType = Value
End Property


'----------------------------------------------------------------------------
'   Name: EnumValues
'   Description:  Get property - returns the collection of enum values
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get EnumValues() As Collection
    Set EnumValues = mcolEnumValues
End Property


'----------------------------------------------------------------------------
'   Name: EnumStrings
'   Description:  Get property - returns the collection of enum strings
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get EnumStrings() As Collection
    Set EnumStrings = mcolEnumStrings
End Property


'----------------------------------------------------------------------------
'   Name: Filterable
'   Description: Get and Let - A flag to indicate whether the condition can be
'                           used to filter.
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get Filterable() As Boolean
    Let Filterable = mbolFilterable
End Property

Public Property Let Filterable(ByVal Value As Boolean)
    Let mbolFilterable = Value
End Property


'----------------------------------------------------------------------------
'   Name: Index
'   Description:  Get and Let - The index of the property (what order it appears)
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
'Public Property Get Index() As Long
'   Index = mlngIndex
'End Property
'
'Public Property Let Index(ByVal Value As Long)
'    mlngIndex = Value
'End Property


'----------------------------------------------------------------------------
'   Name: PropertyName
'   Description:  Get and Let - The property name of the action
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get PropertyName() As String
    Let PropertyName = mstrPropertyName
End Property

Public Property Let PropertyName(ByVal Value As String)
    Let mstrPropertyName = Value
End Property


'----------------------------------------------------------------------------
'   Name: PType
'   Description:  Get and Let - The PType of the property
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get PType() As PropValType
    Let PType = mintPType
End Property

Public Property Let PType(ByVal Value As PropValType)
    Let mintPType = Value
End Property



'----------------------------------------------------------------------------
'   Name: Operator
'   Description:  Get and Let - The conditional operator to use
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get Operator() As String
    Let Operator = mstrOperator
End Property

Public Property Let Operator(ByVal Value As String)
    Let mstrOperator = Value
End Property


'----------------------------------------------------------------------------
'   Name: Required
'   Description: Get and Let - A flag to indicate whether the condition is required
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get Required() As Boolean
    Let Required = mbolRequired
End Property

Public Property Let Required(ByVal Value As Boolean)
    Let mbolRequired = Value
End Property



'----------------------------------------------------------------------------
'   Name: DisplayOperator
'   Description:  Get and Set - indicates if and where the operator should
'appear
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get DisplayOperator() As String
    Let DisplayOperator = mstrDisplayOperator
End Property

Public Property Let DisplayOperator(ByVal Value As String)
    Let mstrDisplayOperator = Value
End Property



'----------------------------------------------------------------------------
'   Name: EditOperator
'   Description:  Get and Let - A flag to indicate whether the user can choose
'the operator
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get EditOperator() As Boolean
   Let EditOperator = mbolEditOperator
End Property

Public Property Let EditOperator(ByVal Value As Boolean)
    Let mbolEditOperator = Value
End Property

'----------------------------------------------------------------------------
'   Name: Length
'   Description:  Get and Let - Maximum length of field
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get Length() As Integer
   Let Length = mintLength
End Property

Public Property Let Length(ByVal Value As Integer)
   Let mintLength = Value
End Property




'----------------------------------------------------------------------------
' METHODS - INITIALIZE & TERMINATE
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: Class_Initialize
'   Description:  The intialize for the class.  No actions at this time
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub Class_Initialize()
    Set mcolEnumValues = New Collection
    Set mcolEnumStrings = New Collection
    
    #If DebugMode Then
        'get the next available class ID, and print out
        'that the class was created successfully
        mlngClassDebugID = GetNextClassDebugID()
        Debug.Print "'" & TypeName(Me) & "' instance " & CStr(mlngClassDebugID) & " created"
    #End If
End Sub


'----------------------------------------------------------------------------
'   Name: Class_Terminate
'   Description:  The terminate for the class.
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub Class_Terminate()
    Set mcolEnumValues = Nothing
    
    #If DebugMode Then
        'the class is being destroyed
        Debug.Print "'" & TypeName(Me) & "' instance " & CStr(mlngClassDebugID) & " is terminating"
    #End If
End Sub



'----------------------------------------------------------------------------
' METHODS - Public
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: SetEnumValues
'   Description:  Sets the Enum values collection based on the enumspace and
'                   enum type stored in the object.  Stores the values and text in the
'                   two collections of strings
'   Parameters: icstrLocale - the language to use to load
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub SetEnumValues(Optional ByVal icstrLocale As String = "US")
    
    If Len(mstrEnumSpace) = 0 Or Len(mstrEnumType) = 0 Then
        Exit Sub
    End If
    
    Call LoadLocalizedEnumTypeData(icstrLocale, mstrEnumSpace, mstrEnumType, mcolEnumValues, mcolEnumStrings)
End Sub





'----------------------------------------------------------------------------
'   Name: LoadFromPropSet
'   Description:  Loads a the conditions from a propset into the object
'               Works in conjuction with SaveToPropSet
'   Parameters: iobjPropSet - the propset to use to populate the collection
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub LoadFromPropSet(ByVal iobjPropSet As MTConfigPropSet)

    If Not iobjPropSet Is Nothing Then
        mstrColumnType = iobjPropSet.NextStringWithName("Type")
        mstrPropertyName = iobjPropSet.NextStringWithName("prop_name")
        mintPType = CInt(iobjPropSet.NextStringWithName("ptype"))
        mstrEnumSpace = iobjPropSet.NextStringWithName("EnumSpace")
        mstrEnumType = iobjPropSet.NextStringWithName("EnumType")
        mstrDisplayName = iobjPropSet.NextStringWithName("Header")
        mstrOperator = iobjPropSet.NextStringWithName("operator")
        If UCase$(iobjPropSet.NextStringWithName("edit_operator")) = "YES" Then
            mbolEditOperator = True
        Else
            mbolEditOperator = False
        End If
        mstrDisplayOperator = iobjPropSet.NextStringWithName("display_operator")
        If UCase$(iobjPropSet.NextStringWithName("filter")) = "YES" Then
            mbolFilterable = True
        Else
            mbolFilterable = False
        End If
        If UCase$(iobjPropSet.NextStringWithName("required")) = "YES" Then
            mbolRequired = True
        Else
            mbolRequired = False
        End If
        
    End If
End Sub

'----------------------------------------------------------------------------
'   Name: LoadConditionFromParamTable
'   Description:  Loads a the actions from a propset into the object
'               Works in conjuction with SaveToPropSet
'   Parameters: conditionMeta As MTConditionMetaData
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub LoadConditionFromParamTable(conditionMeta As MTConditionMetaData)
    
    mstrColumnType = conditionMeta.DataType
    mstrPropertyName = conditionMeta.PropertyName
    
    mintPType = conditionMeta.DataType
    mstrEnumSpace = conditionMeta.EnumSpace
    mstrEnumType = conditionMeta.EnumType
    mstrDisplayName = conditionMeta.DisplayName
    mstrOperator = conditionMeta.Operator
    mintLength = conditionMeta.Length
    
    mbolEditOperator = conditionMeta.OperatorPerRule
    ' Note that the DisplayOperator from the ParameterTable Definition is a Boolean.
    ' We have to set this property correctly based on it's value
    If conditionMeta.DisplayOperator Then
        mstrDisplayOperator = "ROW"
    Else
        mstrDisplayOperator = "COLUMN"
    End If
    
    mbolFilterable = conditionMeta.Filterable
    mbolRequired = conditionMeta.Required
    mvarDefaultValue = conditionMeta.DefaultValue
     
End Sub

'----------------------------------------------------------------------------
'   Name: SaveToPropSet
'   Description:  Save a set of conditions from the object into a propset
'               Works in conjuction with LoadFromPropSet
'   Parameters: iobjPropSet - the propset to use to save the collection
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub SaveToPropSet(ByVal iobjPropSet As MTConfigPropSet)

    Call iobjPropSet.InsertProp("Type", PROP_TYPE_STRING, mstrColumnType)
    Call iobjPropSet.InsertProp("prop_name", PROP_TYPE_STRING, mstrPropertyName)
    Call iobjPropSet.InsertProp("ptype", PROP_TYPE_STRING, mintPType)
    Call iobjPropSet.InsertProp("EnumSpace", PROP_TYPE_STRING, mstrEnumSpace)
    Call iobjPropSet.InsertProp("EnumType", PROP_TYPE_STRING, mstrEnumType)
    Call iobjPropSet.InsertProp("Header", PROP_TYPE_STRING, mstrDisplayName)
    Call iobjPropSet.InsertProp("operator", PROP_TYPE_STRING, mstrOperator)
    If mbolEditOperator Then
        Call iobjPropSet.InsertProp("edit_operator", PROP_TYPE_STRING, "Yes")
    Else
        Call iobjPropSet.InsertProp("edit_operator", PROP_TYPE_STRING, "No")
    End If
    Call iobjPropSet.InsertProp("display_operator", PROP_TYPE_STRING, mstrDisplayOperator)
    If mbolFilterable Then
        Call iobjPropSet.InsertProp("filter", PROP_TYPE_STRING, "Yes")
    Else
        Call iobjPropSet.InsertProp("filter", PROP_TYPE_STRING, "No")
    End If
    If mbolRequired Then
        Call iobjPropSet.InsertProp("required", PROP_TYPE_STRING, "Yes")
    Else
        Call iobjPropSet.InsertProp("required", PROP_TYPE_STRING, "No")
    End If
End Sub
