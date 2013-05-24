VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "FilterCondition"
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
'DESCRIPTION:   This class is used to store a filtered condition.  This is
'               useful because the filtered condition contains both a RuleSet
'               SimpleCondition and some display information.  Otherwise, we
'               would have to do a bunch of work to display the filter data
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


Private mstrDisplayName                 As String       ' The string to display for this condition name
Private mstrDisplayValue                As String       ' The string to display for the value
Private mstrDisplayTest                 As String       ' The string to display for the test operator
Private mobjRSCondition                 As MTSimpleCondition       ' The actual Condition object


'----------------------------------------------------------------------------
' PROPERTIES
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: DisplayName
'   Description:  Get and Set - The string to display for this condition name
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get DisplayName() As String
    DisplayName = mstrDisplayName
End Property

Public Property Let DisplayName(ByVal vNewValue As String)
    mstrDisplayName = vNewValue
End Property


'----------------------------------------------------------------------------
'   Name: DisplayValue
'   Description:  Get and Set - The string to display for the value
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get DisplayValue() As String
    DisplayValue = mstrDisplayValue
End Property

Public Property Let DisplayValue(ByVal vNewValue As String)
    mstrDisplayValue = vNewValue
End Property


'----------------------------------------------------------------------------
'   Name: DisplayTest
'   Description:  Get and Set - The string to display for the test operator
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get DisplayTest() As String
    DisplayTest = mstrDisplayTest
End Property

Public Property Let DisplayTest(ByVal vNewValue As String)
    mstrDisplayTest = vNewValue
End Property


'----------------------------------------------------------------------------
'   Name: Condition
'   Description:  Get and Set - The actual Condition object
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get Condition() As MTSimpleCondition
    Set Condition = mobjRSCondition
End Property

Public Property Set Condition(ByVal vNewValue As MTSimpleCondition)
    Set mobjRSCondition = Nothing
    Set mobjRSCondition = vNewValue
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
    Set mobjRSCondition = Nothing
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
    Set mobjRSCondition = Nothing
    
    #If DebugMode Then
        'the class is being destroyed
        Debug.Print "'" & TypeName(Me) & "' instance " & CStr(mlngClassDebugID) & " is terminating"
    #End If
End Sub
