VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "HierarchyHelper"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' //==========================================================================
' // Copyright 1998-2001 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //==========================================================================

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  HierarchyHelper.cls                                                      '
'  Createable class for MTHierarchyHelper object.  Contains public          '
'  properties and methods.                                                  '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Private mobjCache As New Cache              'Hierarchy cache object
Dim mstrSnapshotDate As String              'Date for hierarchy snapshots
Dim mstrRootName As String

Private mstrMenuXSL As String               'XSL to use for transforms

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Class_Initialize()
  mobjCache.Clear
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : InitCache()                                               '
' Description   : Initialize (clear) the cache.                             '
' Inputs        : none                                                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function InitCache()
  Call mobjCache.Clear
  
  Call mobjCache.LoadTopLevelEntities
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : Show(strID)                                               '
' Description   : Show the selected entity.                                 '
' Inputs        : strID -- ID of the entity to show.                        '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function Show(ByVal strID As String)

  'If no strID, load from the top
  If Len(strID) = 0 Then
    Call mobjCache.LoadTopLevelEntities
  Else

    'Load the entity
    Call mobjCache.Update("LOAD", strID, False)
  
    'Show the entity
    Call mobjCache.Update("SHOW", strID, False)
  End If

End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function LoadEntity(ByVal strID As String, ByVal strIDType As String, Optional bGetChildren = True) As IXMLDOMNode
 
 Set LoadEntity = mobjCache.mobjDB.LoadEntity(strID, strIDType, bGetChildren)

End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : Hide(strID)                                               '
' Description   : Hide the selected entity.                                 '
' Inputs        : strID -- ID of the entity to hide.                        '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function Hide(strID)

  Call mobjCache.Update("HIDE", strID, False)

End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : FindEntity(strSearchType, strValue)                       '
' Description   : Find an entity based on the search criteria.              '
' Inputs        : strSearchType -- Type of search to perform.               '
'               : strValue      -- Value to search for.                     '
' Outputs       : Found entity                                              '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function FindEntity(ByVal strSearchType As String, _
                           ByVal strValue As String) As Boolean
  
  Dim objEntity As IXMLDOMNode      'Entity to find
  
  Set objEntity = mobjCache.FindEntity(strSearchType, strValue)
  
  If objEntity Is Nothing Then
    FindEntity = False
  Else
    FindEntity = True
    Call SetAttribute(objEntity, "highlight", "true", False)
    Call SetAttribute(objEntity, "visible", "true", False)
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PROPERTIES                                                                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' CacheXML
Public Property Get CacheXML() As String
  Let CacheXML = mobjCache.XML
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' snapShot
Public Property Let snapShot(ByVal d As Date)
  mobjCache.snapShot = d
End Property

Public Property Get snapShot() As Date
  snapShot = mobjCache.snapShot
End Property

' Actor Yaac
Public Property Set actorYaac(ByVal objYaac As MTYAAC)
  Set mobjCache.actorYaac = objYaac
End Property

Public Property Get actorYaac() As MTYAAC
  Set actorYaac = mobjCache.actorYaac
End Property

' RootName
Public Property Let RootName(ByVal strName As String)
  mobjCache.RootName = strName
End Property

Public Property Get RootName() As String
  RootName = mobjCache.RootName
End Property
