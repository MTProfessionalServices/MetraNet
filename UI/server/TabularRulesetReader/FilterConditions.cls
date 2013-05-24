VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "FilterConditions"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
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
' $Revision$
'
'
'----------------------------------------------------------------------------


'----------------------------------------------------------------------------
'
'DESCRIPTION:   A Collection class for FilterCondition objects.  Handles normal
'               collection stuff
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
'   Description:  Get - The default property for the object.  R
'                   used when referencing an element in the collection
'                   vntIndexKey contains either the Index or Key to the collection,
'                   this is why it is declared as a Variant
'                   Syntax: Set foo = x.Item(xyz) or Set foo = x.Item(5)
'   Parameters: vntIndexKey - the index or key into the collection to retrieve
'   Return Value: The FilterCondition object at that index
'-----------------------------------------------------------------------------
Public Property Get Item(vntIndexKey As Variant) As FilterCondition
Attribute Item.VB_UserMemId = 0
    Set Item = mcolList(vntIndexKey)
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
'   Description:  NewEnum - this property allows you to enumerate this collection
'                   with the For...Each syntax
'   Parameters: none
'   Return Value:
'-----------------------------------------------------------------------------
Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
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
'   Description:  Adds an FilterCondition object to the collection.  Takes an optional
'               parameter to specify the key for the new item.
'   Parameters: icobjFilter - the object to add to the collection
'               sKey - the key for the new item
'   Return Value: The FilterCondition object that was added
'-----------------------------------------------------------------------------
Public Function Add(icobjFilter As FilterCondition, Optional sKey As String) As FilterCondition

    If Len(sKey) = 0 Then
        Call mcolList.Add(icobjFilter)
    Else
        Call mcolList.Add(icobjFilter, sKey)
    End If

    Set Add = icobjFilter
End Function


'----------------------------------------------------------------------------
'   Name: Clear
'   Description:  Clears all items from the collection (creates a new collection)
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub Clear()
    Set mcolList = New Collection
End Sub



'----------------------------------------------------------------------------
'   Name: Remove
'   Description:  Removes an item from the collection.
'                   used when removing an element from the collection
'                   vntIndexKey contains either the Index or Key, which is why
'                   it is declared as a Variant
'                   Syntax: x.Remove(xyz)
'   Parameters: vntIndexKey - the index or key of the item to remove
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub Remove(vntIndexKey As Variant)
    mcolList.Remove vntIndexKey
End Sub


