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
Private mobjCacheXML As New DOMDocument40

Public mobjDB As New DB

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
  
  Call Clear
  
  'GET ROOT
  Set objRootNode = mobjDB.LoadEntity("1", "BY_ID", False)
  Call mobjCacheXML.documentElement.appendChild(objRootNode)
  
  LoadTopLevelEntities = True
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : Update(strAction, strID, bDeep)                           '
' Description   : Update the cache, depending on the action to take.        '
' Inputs        : strAction -- LOAD, UNLOAD, SHOW, HIDE                     '
'               :   LOAD    -- load the selected item into the cache.       '
'               :   UNLOAD  -- remove the selected item from the cache.     '
'               :   SHOW    -- load and show the selected entity.           '
'               :   HIDE    -- hide the selected entity.                    '
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
      If Not objEntity Is Nothing Then
      Set objAttribute = objEntity.Attributes.getNamedItem(CHILDREN_ATTRIBUTE)
 
      'If children are supposed to exist
      If Not objAttribute Is Nothing Then
        If UCase(objAttribute.Value) = "Y" Then
          'Check for the children
          If objEntity.selectNodes(ENTITY_CHILD_NODES).length = 0 Then
            Set objDBEntity = mobjDB.LoadEntity(strID, "ID", True)
       
            If Not objDBEntity Is Nothing Then
                For Each objDBChildEntity In objDBEntity.selectNodes(ENTITY_CHILD_NODES)
                  Call objEntity.appendChild(CloneEntity(objDBChildEntity))
                Next
            End If
          End If
        End If
      End If
      
      End If
      
    'Load a single item from the database and all parents, make sure it is visible
    Case "LOAD_WITH_PARENTS"
      strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strID)
      Set objEntity = mobjDB.LoadEntity(strID, "ID", False)
      Call SetAttribute(objEntity, VISIBLE_ATTRIBUTE, "true", bDeep)
      
      If Not objEntity Is Nothing Then
          
          While (objEntity.selectSingleNode(ENTITY_PARENT_ID).Text <> "1")
            Call Update("LOAD_WITH_PARENTS", objEntity.selectSingleNode(ENTITY_PARENT_ID).Text, False)
            Call Update("LOAD", objEntity.selectSingleNode(ENTITY_PARENT_ID).Text, False)
            Set objEntity = mobjDB.LoadEntity(objEntity.selectSingleNode(ENTITY_PARENT_ID).Text, "ID", False)
          Wend
      
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
      
      ' Don't forget to show all parents
      If Not objEntity Is Nothing Then
          
          While (objEntity.selectSingleNode(ENTITY_PARENT_ID).Text <> "0")
            strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", objEntity.selectSingleNode(ENTITY_PARENT_ID).Text)
            Set objEntity = mobjCacheXML.selectSingleNode(strQuery)
            If Not objEntity Is Nothing Then
                Call SetAttribute(objEntity, VISIBLE_ATTRIBUTE, "true", bDeep)
            End If
            
          Wend
      
      End If
    
    'Hide the selected entity (but don't remove from cache)
    Case "HIDE"
      strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strID)
      
      Set objEntity = mobjCacheXML.selectSingleNode(strQuery)
      
      Call SetAttribute(objEntity, VISIBLE_ATTRIBUTE, "false", bDeep)
     
  
  End Select
                       
  Update = True
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
  
  'Get the entity to find from the database without it's children
  Set objDBEntity = mobjDB.LoadEntity(strValue, strSearchType, False)
  
  'Set values based on search type
  Select Case UCase(strSearchType)
    Case "USERNAME"
      strSearchString = ENTITY_NAME
    
    Case "ID"
      strSearchString = ENTITY_ID
      
  End Select
  
  strXSLPattern = ANY_ENTITY_CHILD_NODES & "[" & strSearchString & " = '" & strValue & "']"

  'Make sure the item was found in the DB
  If Not objDBEntity Is Nothing Then
    Set objEntity = mobjCacheXML.selectSingleNode(strXSLPattern)

    'Handle case where item is not in cache
    If objEntity Is Nothing Then

      If objDBEntity.selectSingleNode(ENTITY_PARENT_ID).Text = "1" Then
        Set FindEntity = Nothing
        Exit Function
      Else
        'Load entity
        Call Update("LOAD_WITH_PARENTS", objDBEntity.selectSingleNode(ENTITY_ID).Text, False)
        Call Update("SHOW", objDBEntity.selectSingleNode(ENTITY_PARENT_ID).Text, False)
        Set FindEntity = mobjCacheXML.selectSingleNode(strXSLPattern)
            
      End If

    Else

      'Make sure the parent is showing
      Call Update("SHOW", objDBEntity.selectSingleNode(ENTITY_PARENT_ID).Text, False)
      Set FindEntity = objEntity
      
    End If
  Else
    Set FindEntity = Nothing
  End If

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

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' snapShot
Public Property Let snapShot(ByVal d As Date)
  mobjDB.snapShot = d
End Property

Public Property Get snapShot() As Date
  snapShot = mobjDB.snapShot
End Property

' Actor Yaac
Public Property Set actorYaac(ByVal objYaac As MTYAAC)
  Set mobjDB.actorYaac = objYaac
End Property

Public Property Get actorYaac() As MTYAAC
  Set actorYaac = mobjDB.actorYaac
End Property

' RootName
Public Property Let RootName(ByVal strName As String)
  mobjDB.RootName = strName
End Property

Public Property Get RootName() As String
  RootName = mobjDB.RootName
End Property

