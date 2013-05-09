VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Cache"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
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
'  Cache.cls                                                                '
'  Handles interaction between hierarchy cache and hierarchy database.      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mobjCacheXML As New DOMDocument30

Private mobjDB As New DB

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Class Initialize()                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Class_Initialize()
  'Init the document
  mobjCacheXML.async = False
  mobjCacheXML.validateOnParse = False
  mobjCacheXML.resolveExternals = False
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : Clear()                                                   '
' Description   : Clear all elements in the cache.                          '
' Inputs        : none                                                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function Clear()
  Call mobjCacheXML.loadXML("<" & ACCOUNT_XML_TOP & " />")
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : LoadTopLevelEntities()                                    '
' Description   : Load the top level items of the hierarchy.                '
' Inputs        : none                                                      '
' Outputs       : boolean                                                   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function LoadTopLevelEntities() As Boolean
  Dim objRootNode As IXMLDOMNode
  
  'DUMMY CODE TO GET ROOT
  Set objRootNode = mobjDB.LoadEntity("1", "BY_ID")
  Call mobjCacheXML.documentElement.appendChild(objRootNode)
  
  
  'Call Update("LOAD", "1", False)
  
  
  LoadTopLevelEntities = True
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : Update(strAction, strID, bDeep)                           '
' Description   : Update the cache, depending on the action to take.        '
' Inputs        : strAction -- LOAD, UNLOAD, SHOW, HIDE, REFRESH            '
'               :   LOAD    -- load the selected item into the cache.       '
'               :   UNLOAD  -- remove the selected item from the cache.     '
'               :   SHOW    -- load and show the selected entity.           '
'               :   HIDE    -- hide the selected entity.                    '
'               :   REFRESH -- reload the item from the database.           '
'               : strID     -- ID of the item to work with.                 '
'               : bDeep     -- recurse through child elements.              '
' Outputs       : boolean                                                   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function Update(ByVal strAction As String, _
                       ByVal strID As String, _
                       ByVal bDeep As Boolean) As Boolean
  
  Dim objEntity As IXMLDOMNode              'XML representation of the entity to get
  Dim objDBEntity As IXMLDOMNode            'Matching entity from DB
  Dim objDBChildEntity As IXMLDOMNode       'Children of the database entity
  Dim strQuery As String                    'XPath
  Dim strParentID As String                 'ID of the parent
  Dim objAttribute As IXMLDOMAttribute      'XML attribute
  
  
  Select Case UCase(strAction)
    'Load an item from the database
    Case "LOAD"
      
      'When loading, the task is to get the children of the node to load
      strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strID)
      Set objEntity = mobjCacheXML.selectSingleNode(strQuery)
            
      'Get children from the database, if none found
      Set objAttribute = objEntity.Attributes.getNamedItem(CHILDREN_ATTRIBUTE)
      
      'If children are supposed to exist
      If Not objAttribute Is Nothing Then
        If UCase(objAttribute.Value) = "Y" Then
          'CHeck for the children
          If objEntity.selectNodes(ENTITY_CHILD_NODES).length = 0 Then
            Set objDBEntity = mobjDB.LoadEntity(strID, "BY_ID")
            
            For Each objDBChildEntity In objDBEntity.selectNodes(ENTITY_CHILD_NODES)
              Call objEntity.appendChild(CloneEntity(objDBChildEntity))
            Next
          End If
        End If
      End If
      
      
    'Remove an item from the cache
    Case "UNLOAD"
      'Find the item in the cache
      strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strID)
      
      Set objEntity = mobjCacheXML.selectSingleNode(strQuery)
      
      'Remove the item
      Call objEntity.parentNode.removeChild(objEntity)
      
    'Load an item from the database, and make it visible
    Case "SHOW"
      'Set the visible attribute
      strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strID)
      
      Set objEntity = mobjCacheXML.selectSingleNode(strQuery)
      
      Call SetAttribute(objEntity, VISIBLE_ATTRIBUTE, "true", bDeep)
    
    'Hide the selected entity (but don't remove from cache)
    Case "HIDE"
      strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strID)
      
      Set objEntity = mobjCacheXML.selectSingleNode(strQuery)
      
      Call SetAttribute(objEntity, VISIBLE_ATTRIBUTE, "false", bDeep)
    
    'reload the selected entity from the database, but keep any visibility attributes
    Case "REFRESH"
      
  
  End Select
                       
  Update = True
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : MoveEntity(strSrcID, strNewParentID)                      '
' Description   : Move an entity from its position in the hierarchy to a    '
'               : position under a new parent.                              '
' Inputs        : strSrcID      --  ID of entity to move.                   '
'               : strParentID   --  ID of new parent of the entity to move. '
' Outputs       : New parent of item.                                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function MoveEntity(ByVal strSrcID As String, _
                           ByVal strNewParentID As String) As IXMLDOMNode
  
  Dim objSrcNode As IXMLDOMNode           'Node to move
  Dim objParentNode As IXMLDOMNode        'Parent of node to move
  
  Dim objNewNode As IXMLDOMNode           'Clone of node to move
  Dim objNewParentNode As IXMLDOMNode     'New parent of node to move
  Dim objParentIDNode As IXMLDOMNode      'Used to update the parent id of the moved node
  
  Dim objAttr As IXMLDOMAttribute         'Used to set has children flag of parent
  
  Dim strQuery As String                  'XPath
  
  'Assumes nodes involved are part of the cache (i.e. if in the menu, then
  ' they've already been loaded into the cache.
  
  If CheckMove(strSrcID, strNewParentID) Then
    'Get the nodes involved
    strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strSrcID)
    'Set objSrcNode = mobjCacheXML.selectSingleNode("//entity[id = '" & strSrcID & "']")
    Set objSrcNode = mobjCacheXML.selectSingleNode(strQuery)
    
    Set objParentNode = objSrcNode.parentNode
    
    strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strNewParentID)
    Set objNewParentNode = mobjCacheXML.selectSingleNode(strQuery)
    'Set objNewParentNode = mobjCacheXML.selectSingleNode("//entity[id = '" & strNewParentID & "']")
        
    'Now move the node
    Set objAttr = mobjCacheXML.createAttribute(CHILDREN_ATTRIBUTE)
    objAttr.Value = "Y"
    Call objNewParentNode.Attributes.setNamedItem(objAttr)
        
    'Clone the node
    Set objNewNode = objSrcNode.cloneNode(True)
    
    'Update the parent id
    Set objParentIDNode = objNewNode.selectSingleNode(ENTITY_PARENT_ID)
    objParentIDNode.Text = strNewParentID
    
    'Append the new node to the new parent
    Call objNewParentNode.appendChild(objNewNode)
    
    'Remove the original
    Call objSrcNode.parentNode.removeChild(objSrcNode)
    
    
    'Set the Children flag of the old parent
    Set objAttr = mobjCacheXML.createAttribute(CHILDREN_ATTRIBUTE)
    
    If objParentNode.selectNodes(ENTITY_CHILD_NODES).length > 0 Then
      objAttr.Value = "Y"
    Else
      objAttr.Value = "N"
    End If
    
    Call objParentNode.Attributes.setNamedItem(objAttr)
    
    'Return
    Set MoveEntity = objNewParentNode
  Else
    Set MoveEntity = Nothing
  End If
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : FindEntity(strSearchType, strValue)                       '
' Description   : Find an entity based on the search criteria.              '
' Inputs        : strSearchType -- Type of search to perform.               '
'               : strValue      -- Value to search for.                     '
' Outputs       : Found entity                                              '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function FindEntity(ByVal strSearchType As String, _
                           ByVal strValue As String) As IXMLDOMNode
  
  Dim objDBEntity As IXMLDOMNode    'Entity to find (DB)
  Dim objEntity As IXMLDOMNode      'Entity to find
  Dim strSearchString As String     'String to search for, id, name, etc
  Dim strXSLPattern As String       'XSL search pattern
  
  'Get the entity to find from the database
  Set objDBEntity = mobjDB.LoadEntity(strValue, strSearchType)
  
  'Set values based on search type
  Select Case UCase(strSearchType)
    Case "USERNAME"
      strSearchString = ENTITY_NAME
    
    Case "ID"
      strSearchString = ENTITY_ID
      
  End Select
  
  'strXSLPattern = "//entity[" & strSearchString & " = '" & strValue & "']"
  strXSLPattern = ANY_ENTITY_CHILD_NODES & "[" & strSearchString & " = '" & strValue & "']"
  
  'Make sure the item was found in the DB
  If Not objDBEntity Is Nothing Then
    Set objEntity = mobjCacheXML.selectSingleNode(strXSLPattern)
    
    'Handle case where item is not in cache
    If objEntity Is Nothing Then
      
      'Walk towards the root, until an item is found in the cache (make sure a parent exists)
'      If Not objDBEntity.parentNode.selectSingleNode(strSearchString) Is Nothing Then
'        Call FindEntity(strSearchType, objDBEntity.parentNode.selectSingleNode(strSearchString).Text)
      Call FindEntity(strSearchType, objDBEntity.selectSingleNode(ENTITY_PARENT_ID).Text)
'      End If
    
      'Add the item to the cache
      Call Update("LOAD", objDBEntity.selectSingleNode(ENTITY_ID).Text, False)
    
      'Set return value
      Set FindEntity = FindEntity(strSearchType, strValue)
    Else
      Set FindEntity = objEntity
    End If
  Else
    Set FindEntity = Nothing
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : CheckMove(strSrcID, strNewParentID)                       '
' Description   : Check to ensure that the desired move is valid            '
' Inputs        : strSrcID  --  ID of entity to move.                       '
'               : strParentID --  Id of new parent.                         '
' Outputs       : boolean                                                   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function CheckMove(ByVal strSrcID As String, _
                           ByVal strNewParentID As String) As Boolean
  
  Dim objSrcEntity As IXMLDOMNode            'Entity to check
  Dim objChildEntity As IXMLDOMNode          'Entities
  
  Dim strQuery As String                      'XPath
    
  'Check for moving to parent
  'Set objSrcEntity = mobjCacheXML.selectSingleNode("//entity[id = '" & strSrcID & "']")
  strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strSrcID)
  Set objSrcEntity = mobjCacheXML.selectSingleNode(strQuery)
    
  If objSrcEntity.parentNode.selectSingleNode(ENTITY_ID).Text = strNewParentID Then
    CheckMove = False
    Exit Function
  End If
    
  'Check for moving to self
  If strSrcID = strNewParentID Then
    CheckMove = False
    Exit Function
  End If
    
  'Now check to see if a parent is to be dropped on a child
  strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strSrcID)
  Set objSrcEntity = mobjCacheXML.selectSingleNode(strQuery)
  'Set objSrcEntity = mobjCacheXML.selectSingleNode("//entity[id = '" & strSrcID & "']")
    
  For Each objChildEntity In objSrcEntity.selectNodes(ENTITY_CHILD_NODES)
    If Not CheckMove(objChildEntity.selectSingleNode(ENTITY_ID).Text, strNewParentID) Then
      CheckMove = False
      Exit Function
    End If
  Next
    
  CheckMove = True
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : Commit()                                                  '
' Description   : Commit changes to the database.  Writes the cache back to '
'               : the DB.                                                   '
' Inputs        : none                                                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function Commit() As Boolean
  Dim objEntityNode As IXMLDOMNode        'Entity node

  For Each objEntityNode In mobjCacheXML.selectNodes(ANY_ENTITY_CHILD_NODES)
    Call mobjDB.SaveEntity(objEntityNode)
  Next
  
  Commit = True

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : ClearHighlights()                                         '
' Description   : Clear all highlights from the hierarchy.                  '
' Inputs        : none                                                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function ClearHighlights()
  Dim objNode As IXMLDOMNode          'Used to iterate through nodes
  
  For Each objNode In mobjCacheXML.selectNodes(ANY_HIGHLIGHTED_ENTITY)
    Call SetAttribute(objNode, HIGHLIGHT_ATTRIBUTE, "false", False)
  Next

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'PROPERTIES
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Database object
Public Property Let DBObject(ByRef objDB As DB)
  Set mobjDB = objDB
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Cache XML
Public Property Get XML() As String
  Let XML = mobjCacheXML.XML
End Property

