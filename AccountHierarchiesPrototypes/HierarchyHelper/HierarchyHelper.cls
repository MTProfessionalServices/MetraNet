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

Private mobjCache As New Cache              'Hierarchy cache object
Private mobjDB As New DB                    'DB interaction object


'Date items
Dim mstrSnapshotDate As String              'Date for hierarchy snapshots

Dim mstrRangeStartDate As String            'Start date for ranges
Dim mstrRangeEndDate As String              'End date for ranges

'Display flags
Dim mbHighlightParentOnMove As Boolean      'Highlight parents on moves
Dim mbHighlightEntityOnMove As Boolean      'Highlight moved element on move
Dim mbHighlightChildrenOnMove As Boolean    'Highlight movee's children on moves

Dim mbOpenParentOnMove As Boolean           'When moving, open new parent
Dim mbOpenEntityOnMove As Boolean           'Open the entity moved
Dim mbOpenChildrenOnMove As Boolean         'Open child entities on move


Private mstrMenuXSL As String               'XSL to use for transforms

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Class_Initialize()
  mbHighlightParentOnMove = True
  mbHighlightEntityOnMove = True
  mbHighlightChildrenOnMove = True
  
  mbOpenParentOnMove = False
  mbOpenEntityOnMove = False
  mbOpenChildrenOnMove = False
  
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
' Function      : MoveEntity(strSrcID, strNewParentID)                      '
' Description   : Move an entity from its position in the hierarchy to a    '
'               : position under a new parent.                              '
' Inputs        : strSrcID      --  ID of entity to move.                   '
'               : strParentID   --  ID of new parent of the entity to move. '
' Outputs       : boolean                                                   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function MoveEntity(ByVal arrSrcIDs As Variant, _
                           ByVal strNewParentID As String) As Boolean
  
  Dim strSrcID As Variant           'ID of entity to move
  Dim objNewParent As IXMLDOMNode   'Parent that node was moved to
  Dim strQuery As String            'XPath
  
  Call mobjCache.ClearHighlights
  
  'Handle array case
  If IsArray(arrSrcIDs) Then
    If Not IsEmpty(arrSrcIDs) Then
    
      '1) Check moves
      For Each strSrcID In arrSrcIDs
        If Not mobjCache.CheckMove(strSrcID, strNewParentID) Then
          MoveEntity = False
          Exit Function
        End If
      Next
      
      '2) Perform the moves
      For Each strSrcID In arrSrcIDs
        'Do Move
        Set objNewParent = mobjCache.MoveEntity(strSrcID, strNewParentID)
        
        'Check Result
        If objNewParent Is Nothing Then
          MoveEntity = False
          Exit Function
        Else
          
          strQuery = Replace(CHILD_WITH_ID, "[ID]", strSrcID)
          
          'Do highlighting & opening
          If mbHighlightEntityOnMove Then
            Call SetAttribute(objNewParent.selectSingleNode(strQuery), "highlight", "true", mbHighlightChildrenOnMove)
          End If
          
          If mbOpenEntityOnMove Then
            Call SetAttribute(objNewParent.selectSingleNode(strQuery), "visible", "true", mbOpenChildrenOnMove)
          End If
        End If
      Next
    End If
  'Handle single item case
  Else
    strSrcID = CStr(arrSrcIDs)
    
    'Check Move
    If Not mobjCache.CheckMove(strSrcID, strNewParentID) Then
      MoveEntity = False
      Exit Function
    Else
      'Do Move
      Set objNewParent = mobjCache.MoveEntity(strSrcID, strNewParentID)
      
      'Check Result
      If objNewParent Is Nothing Then
        MoveEntity = False
        Exit Function
      Else
        strQuery = Replace(CHILD_WITH_ID, "[ID]", strSrcID)
          
        'Do highlighting & opening
        If mbHighlightEntityOnMove Then
          Call SetAttribute(objNewParent.selectSingleNode(strQuery), "highlight", "true", mbHighlightChildrenOnMove)
        End If
        
        If mbOpenEntityOnMove Then
          Call SetAttribute(objNewParent.selectSingleNode(strQuery), "visible", "true", mbOpenChildrenOnMove)
        End If
      End If
    End If
  End If
  
  'Set parent highlighting & opening
  If mbHighlightParentOnMove Then
    Call SetAttribute(objNewParent, "highlight", "true", False)
  End If
  
  If mbOpenParentOnMove Then
    Call SetAttribute(objNewParent, "visible", "true", False)
  End If
  
  MoveEntity = True
  
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
' HighlightParentOnMove
Public Property Let HighlightParentOnMove(ByVal bHighlight As Boolean)
  Let mbHighlightParentOnMove = bHighlight
End Property

Public Property Get HighlightParentOnMove() As Boolean
  Let HighlightParentOnMove = mbHighlightParentOnMove
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' HighlightEntityOnMove
Public Property Let HighlightEntityOnMove(ByVal bHighlight As Boolean)
  Let mbHighlightEntityOnMove = bHighlight
End Property

Public Property Get HighlightEntityOnMove() As Boolean
  Let HighlightEntityOnMove = mbHighlightEntityOnMove
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' HighlightChildrenOnMove
Public Property Let HighlightChildrenOnMove(ByVal bHighlight As Boolean)
  Let mbHighlightChildrenOnMove = bHighlight
End Property

Public Property Get HighlightChildrenOnMove() As Boolean
  Let HighlightChildrenOnMove = mbHighlightChildrenOnMove
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' OpenParentOnMove
Public Property Let OpenParentOnMove(ByVal bOpen As Boolean)
  Let mbOpenParentOnMove = bOpen
End Property

Public Property Get OpenParentOnMove() As Boolean
  Let OpenParentOnMove = mbOpenParentOnMove
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' OpenEntityOnMove
Public Property Let OpenEntityOnMove(ByVal bOpen As Boolean)
  Let mbOpenEntityOnMove = bOpen
End Property

Public Property Get OpenEntityOnMove() As Boolean
  Let OpenEntityOnMove = mbOpenEntityOnMove
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' OpenChildrenOnMove
Public Property Let OpenChildrenOnMove(ByVal bOpen As Boolean)
  Let mbOpenChildrenOnMove = bOpen
End Property

Public Property Get OpenChildrenOnMove() As Boolean
  Let OpenChildrenOnMove = mbOpenChildrenOnMove
End Property
