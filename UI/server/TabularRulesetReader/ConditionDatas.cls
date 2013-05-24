VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ConditionDatas"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Collection" ,"ConditionData"
Attribute VB_Ext_KEY = "Member0" ,"ConditionData"
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
'DESCRIPTION:   A Collection class for Condition objects.  Handles normal
'               collection stuff and moveup, movedown
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
' VARIABLES
'----------------------------------------------------------------------------
#If DebugMode Then
    'local variable to hold the serialized class ID that was created in Class_Initialize
    Private mlngClassDebugID As Long
#End If

Private mcolList As Collection




'----------------------------------------------------------------------------
' PROPERTIES
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: Item
'   Description:  Get - The default property for the object.  Returns an
'                   item from the collection.  Note that this collection is
'                   set up to only work with indexes, not keys
'   Parameters: iclngIndex - the index into the collection to retrieve
'   Return Value: The ActionData object at that index
'-----------------------------------------------------------------------------
Public Property Get Item(ByVal iclngIndex As Long) As ConditionData
Attribute Item.VB_UserMemId = 0
    Set Item = mcolList(iclngIndex)
End Property


'----------------------------------------------------------------------------
'   Name: Count
'   Description:  Get - Retrieves the number of elements in the collection
'   Parameters: none
'   Return Value: The number of elements
'-----------------------------------------------------------------------------
Public Property Get Count() As Long
    Count = mcolList.Count
End Property


'----------------------------------------------------------------------------
'   Name: NewEnum
'   Description:  Get - this property allows you to enumerate this collection
'                   with the For...Each syntax
'   Parameters: none
'   Return Value:
'-----------------------------------------------------------------------------
Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
Attribute NewEnum.VB_MemberFlags = "40"
    Set NewEnum = mcolList.[_NewEnum]
End Property



'----------------------------------------------------------------------------
' METHODS - INITIALIZE & TERMINATE
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: Class_Initialize
'   Description:  The intialize for the class.  Creates a new collection
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub Class_Initialize()
    Set mcolList = New Collection
    
    #If DebugMode Then
        'get the next available class ID, and print out
        'that the class was created successfully
        mlngClassDebugID = GetNextClassDebugID()
        Debug.Print "'" & TypeName(Me) & "' instance " & CStr(mlngClassDebugID) & " created"
    #End If
End Sub


'----------------------------------------------------------------------------
'   Name: Class_Terminate
'   Description:  The Terminate for the class.  destroys collection when this class is terminated
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub Class_Terminate()
    Set mcolList = Nothing
    
    #If DebugMode Then
        'the class is being destroyed
        Debug.Print "'" & TypeName(Me) & "' instance " & CStr(mlngClassDebugID) & " is terminating"
    #End If
End Sub





'----------------------------------------------------------------------------
' METHODS - Public
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: Add
'   Description:  Adds an ActionData object to the collection.  Takes an optional
'               parameter to specify the location of the new item.  Note that this
'               collection does not support keys!!!
'   Parameters: icobjActionData - the object to add to the collection
'               iclngLocation - the location to add the item
'   Return Value: The ActionData object that was added
'-----------------------------------------------------------------------------
Public Function Add(icobjConditionData As ConditionData, Optional iclngLocation As Long = -1) As ConditionData

    If iclngLocation < 1 Then
        Call mcolList.Add(icobjConditionData)
    ElseIf iclngLocation = 1 Then
        Call mcolList.Add(icobjConditionData, , before:=1)
    Else
        Call mcolList.Add(icobjConditionData, , after:=iclngLocation - 1)
    End If

    Set Add = icobjConditionData
End Function



'----------------------------------------------------------------------------
'   Name: LoadFromPropSet
'   Description:  Loads a collection of conditions from the propset passed in
'               Calls LoadFromPropSet for each condition.
'               Works in conjuction with SaveToPropSet
'   Parameters: iobjPropSet - the propset to use to populate the collection
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub LoadFromPropSet(ByVal iobjPropSet As MTConfigPropSet)
    
    Dim objPropSet2     As MTConfigPropSet
    Dim objCondition    As ConditionData
    
    If Not iobjPropSet Is Nothing Then
        Set objPropSet2 = iobjPropSet.NextSetWithName("Condition")
        Do While Not objPropSet2 Is Nothing
            Set objCondition = New ConditionData
            Call objCondition.LoadFromPropSet(objPropSet2)
            
            Call mcolList.Add(objCondition)
            Set objPropSet2 = Nothing
            Set objPropSet2 = iobjPropSet.NextSetWithName("Condition")
        Loop
    End If
    Set objPropSet2 = Nothing
    Set objCondition = Nothing
End Sub

'----------------------------------------------------------------------------
'   Name: LoadFromParamTable
'   Description:  Loads a collection of conditions from the Parameter Table passed in
'               Calls LoadMetaConditionFromParamTable for each condition.
'               Works in conjuction with SaveToPropSet
'   Parameters: mParTabDef - the parameter table reference to grab the MetaData from
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub LoadFromParamTable(mParTabDef As MTParamTableDefinition)

    Dim mConditionMD As IMTCollection
    
    Dim conditionMeta As MTConditionMetaData
    
    Set mConditionMD = mParTabDef.ConditionMetaData
    
    Dim objCondition    As ConditionData
    
    For Each conditionMeta In mConditionMD
        Set objCondition = New ConditionData
        Call objCondition.LoadConditionFromParamTable(conditionMeta) ' This method is in ConditionData
        Call mcolList.Add(objCondition)
    Next
    Set objCondition = Nothing
End Sub



'----------------------------------------------------------------------------
'   Name: MoveItemDown
'   Description:  Moves an item in the collection down in the order.  Checks
'               to see if the index is valid first
'   Parameters: iclngIndex - the index of the item to move
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub MoveItemDown(ByVal iclngIndex As Long)
    If iclngIndex >= mcolList.Count Or iclngIndex < 1 Then
        Exit Sub
    Else
        Call Me.Add(mcolList(iclngIndex), iclngIndex + 2)
        Call Me.Remove(iclngIndex)
    End If
        
End Sub


'----------------------------------------------------------------------------
'   Name: MoveItemUp
'   Description:  Moves an item in the collection up in the order.  Checks
'               to see if the index is valid first
'   Parameters: iclngIndex - the index of the item to move
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub MoveItemUp(ByVal iclngIndex As Long)
    If iclngIndex > mcolList.Count Or iclngIndex <= 1 Then
        Exit Sub
    Else
        Call Me.Add(mcolList(iclngIndex), iclngIndex - 1)
        Call Me.Remove(iclngIndex + 1)
    End If
End Sub



'----------------------------------------------------------------------------
'   Name: Remove
'   Description:  Removes an item from the collection.  Note that this method
'               does not support keys, only indexes!!
'   Parameters: iclngIndex - the index of the item to move
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub Remove(ByVal iclngIndex As Long)
    mcolList.Remove iclngIndex
End Sub



'----------------------------------------------------------------------------
'   Name: SaveToPropSet
'   Description:  Save a collection of conditions to the propset passed in
'               Calls SaveToPropSet for each condition.
'               Works in conjuction with LoadFromPropSet
'   Parameters: iobjPropSet - the propset to use to save the collection
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub SaveToPropSet(ByVal iobjPropSet As MTConfigPropSet)
    Dim objPropSet      As MTConfigPropSet
    Dim objCondition    As ConditionData

    For Each objCondition In mcolList
        Set objPropSet = iobjPropSet.InsertSet("Condition")
        Call objCondition.SaveToPropSet(objPropSet)
    Next
End Sub



'----------------------------------------------------------------------------
'   Name: SetItem
'   Description:  Sets an item in the list.  Since collections can't switch out
'               items, you need to add and remove the item
'   Parameters: iobjPropSet - the propset to use to save the collection
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub SetItem(iobjCondition As ConditionData, ByVal iclngIndex As Long)
    Call Add(iobjCondition, iclngIndex + 1)
    Call Remove(iclngIndex)
End Sub

