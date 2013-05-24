VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ActionDatas"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Collection" ,"ActionData"
Attribute VB_Ext_KEY = "Member0" ,"ActionData"
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
'DESCRIPTION:   A Collection class for ActionData objects.  Handles normal
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
Public Property Get Item(ByVal iclngIndex As Long) As ActionData
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
Public Function Add(icobjActionData As ActionData, Optional iclngLocation As Long = -1) As ActionData

    If iclngLocation < 1 Then
        Call mcolList.Add(icobjActionData)
    ElseIf iclngLocation = 1 Then
        Call mcolList.Add(icobjActionData, , before:=1)
    Else
        Call mcolList.Add(icobjActionData, , after:=iclngLocation - 1)
    End If

    Set Add = icobjActionData
End Function



'----------------------------------------------------------------------------
'   Name: LoadFromPropSet
'   Description:  Loads a collection of actions from the propset passed in
'               Calls LoadFromPropSet for each Action.
'               Works in conjuction with SaveToPropSet
'   Parameters: iobjPropSet - the propset to use to populate the collection
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub LoadFromPropSet(ByVal iobjPropSet As MTConfigPropSet)
    Dim objPropSet2     As MTConfigPropSet
    Dim objAction       As ActionData
    
    If Not iobjPropSet Is Nothing Then
        Set objPropSet2 = iobjPropSet.NextSetWithName("Action")
        Do While Not objPropSet2 Is Nothing
            Set objAction = New ActionData
            Call objAction.LoadFromPropSet(objPropSet2)
            
            Call mcolList.Add(objAction)
            Set objPropSet2 = Nothing
            Set objPropSet2 = iobjPropSet.NextSetWithName("Action")
        Loop
    End If
    Set objPropSet2 = Nothing
    Set objAction = Nothing
End Sub


'----------------------------------------------------------------------------
'   Name: LoadFromParamTable
'   Description:  Loads a collection of actions from the propset passed in
'               Calls LoadActionFromParamTable for each condition.
'               Works in conjuction with SaveToPropSet
'   Parameters: mParTabDef - the parameter table reference to grab the conditions from
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub LoadFromParamTable(mParTabDef As MTParamTableDefinition)
    
    Dim mActionMD As IMTCollection
    Dim actionMeta As MTActionMetaData
    
    Set mActionMD = mParTabDef.ActionMetaData
    
    'Dim objPropSet2     As MTConfigPropSet
    Dim objAction    As ActionData
    
    For Each actionMeta In mActionMD
        Set objAction = New ActionData
        Call objAction.LoadActionFromParamTable(actionMeta) ' In ActionData
        Call mcolList.Add(objAction)
    Next
    Set objAction = Nothing

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
'   Description:  Save a collection of actions to the propset passed in
'               Calls SaveToPropSet for each Action.
'               Works in conjuction with LoadFromPropSet
'   Parameters: iobjPropSet - the propset to use to save the collection
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub SaveToPropSet(ByVal iobjPropSet As MTConfigPropSet)
    Dim objPropSet      As MTConfigPropSet
    Dim objAction       As ActionData

    For Each objAction In mcolList
        Set objPropSet = iobjPropSet.InsertSet("Action")
        Call objAction.SaveToPropSet(objPropSet)
    Next
End Sub



'----------------------------------------------------------------------------
'   Name: SetItem
'   Description:  Sets an item in the list.  Since collections can't switch out
'               items, you need to add and remove the item
'   Parameters: iobjPropSet - the propset to use to save the collection
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub SetItem(iobjAction As ActionData, ByVal iclngIndex As Long)
    Call Add(iobjAction, iclngIndex + 1)
    Call Remove(iclngIndex)
End Sub
