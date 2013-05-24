VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "StageDependency"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'----------------------------------------------------------------------------
' Copyright 1998, 1999 by MetraTech Corporation
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

'---------------------------------------------------------------------------'
' Stage Dependencies                                                        '
'---------------------------------------------------------------------------'
'collection of dependencies for the plugin

Private mstrDependencyName As String            'The name of the dependency
Private mcollDependencyList As New Collection   'The dependencies for this plugin


'''''''''''''''''
'Add a dependency
Public Function AddDependency(strDependency)
  Call RemoveDependencyByName(strDependency)
  Call mcollDependencyList.Add(strDependency)
End Function

'''''''''''''''''
'Remove a dependency
Public Function RemoveDependency(intIndex)
  If intIndex > 0 And intIndex <= mcollDependencyList.Count Then
    mcollDependencyList.Remove (intIndex)
  End If
End Function
''''''''''''''''''
' Remove by name
Public Function RemoveDependencyByName(ByVal strName As String)
  Dim i As Integer      'counter
  
  For i = 1 To mcollDependencyList.Count
    If UCase(mcollDependencyList.Item(i)) = UCase(strName) Then
      Call mcollDependencyList.Remove(i)
      Exit Function
    End If
  Next
End Function
'''''''''''''''''''
' DependName
Public Property Get Name() As String
  Let Name = mstrDependencyName
End Property

Public Property Let Name(ByVal Val As String)
  Let mstrDependencyName = Val
End Property

'''''''''''''''''''
'DependencyCount
Public Property Get DependencyCount() As Integer
  Let DependencyCount = mcollDependencyList.Count
End Property

'''''''''''''''''''
'DependencyItem
Public Property Get DependencyItem(intIndex)
  
  If intIndex > 0 And intIndex <= mcollDependencyList.Count Then
    Let DependencyItem = mcollDependencyList.Item(intIndex)
  Else
    Let DependencyItem = ""
  End If

End Property
