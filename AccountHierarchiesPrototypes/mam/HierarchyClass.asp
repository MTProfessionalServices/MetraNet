<%
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' HierarchyClass.asp                                                      '
  ' Routines for help with hierarchies.                                     '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Const g_BaseDir = "c:\development\AccountHierarchies\prototypes\mam\"    '"
  
  Class CHierarchy
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Member Variables
    Private mstrXSLPath               'Path to XSL for menu rendering
    Private mstrXSL                   'XSL to use for rendering
    Private mbUseXSLString            'Indicates whether to use XSL string or path
    Private mstrXML                   'XML describing the hierarchy
    
    Private mobjXML                   'XML dom object
    Private mobjXSL                   'XSL dom object
    
    Private mobjCacheXML              'XML for the hierarchy cache
    
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Private Methods

    Private Sub Class_Initialize()
      Set mobjXML = server.CreateObject("Msxml2.DOMDocument.3.0")
      Set mobjXSL = server.CreateObject("Msxml2.DOMDocument.3.0")

            
      mobjXML.async             = false
      mobjXSL.async             = false
      mobjXML.validateOnParse   = false
      mobjXSL.validateOnParse   = false
      mobjXML.resolveExternals  = false
      mobjXSL.resolveExternals  = false
      
      mbUseXSLString = false
      
      if isobject(session("HIERARCHY_CACHE")) then
        Set mobjCacheXML = session("HIERARCHY_CACHE")
      end if
    End Sub
  
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Public Methods
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : CheckMove(strSrcID, strParentID)                        '
  ' Description   : Check for a valid move.                                 '
  ' Inputs        : strSrcID    -- ID of item to move.                      '
  ' Outputs       : strParentID -- Parent of item to move.                  '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function CheckMove(strSrcID, strParentID)
    Dim objSrcEntity            'Entity to check
    Dim objChildEntity          'Entities
    
    'response.write "<br>Checking: " & strSrcID & " --> " & strParentID
    'Check for moving to parent
    Set objSrcEntity = mobjCacheXML.selectSingleNode("//entity[id = '" & strSrcID & "']")
    
    if objSrcEntity.parentNode.selectSingleNode("id").text = strParentID then
      CheckMove = false
      exit function
    end if
    
    'Check for moveing to self
    if strSrcID = strParentID then
      CheckMove = false
'      response.write " NO!"
      exit function
    end if
    
    'Now check for child nodes
    Set objSrcEntity = mobjCacheXML.selectSingleNode("//entity[id = '" & strSrcID & "']")
    
    for each objChildEntity in objSrcEntity.selectNodes("entity")
      if not CheckMove(objChildEntity.selectSingleNode("id").text, strParentID) then
        CheckMove = false
'        response.write " NO!"
        exit function
      end if
    next
    
'    response.write " YES!"
    CheckMove = true
  
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : RemoveHighlights()                                      '
  ' Description   : Remove highlighting from all elements in the hierarchy. '
  ' Inputs        : none                                                    '
  ' Outputs       : none                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function RemoveHighlights()
    Dim objEntityList         'List of entity nodes
    Dim objEntityNode         'Each node in the list
    Dim objAttr               'Attribute to add
    
    Set objEntityList = mobjCacheXML.selectNodes("//entity[@highlight = 'true']")

    for each objEntityNode in objEntityList
      Set objAttr = mobjCacheXML.createAttribute("highlight")
      objAttr.value = "false"
      
      Call objEntityNode.attributes.setNamedItem(objAttr)
    next
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : HighlightNode(objNode, bRecurse)                        '
  ' Description   : Highlight the selected node, recursing if desired.      '
  ' Inputs        : objNode   --  Node to highlight.                        '
  '               : bRecurse  --  Boolean to recurse through the nodes.     '
  ' Outputs       : none                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function HighlightNode(objNode, bRecurse)
    Dim objEntityList     'List of entities, when recursing
    Dim objEntityNode     'Used to iterate through list
    Dim objAttr           'attribute
    
    Set objAttr = mobjCacheXML.createAttribute("highlight")
    objAttr.value = "true"
    Call objNode.attributes.setNamedItem(objAttr)
    
    if bRecurse then
      Set objEntityList = objNode.selectNodes("entity")
      
      for each objEntityNode in objEntityList
        Call HighlightNode(objEntityNode, bRecurse)
      next
    end if
          
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : DisableEntity(objEntity)                                '
  ' Description   : Disable the entity, but still show it in the hierarchy. '
  ' Inputs        : objEntity -- Entity to disable.                         '
  ' Outputs       : none                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Function DisableEntity(objEntity)
    Dim objEntityList       'list of child nodes
    Dim objChildEntity      'each entity
    
    Dim objAttr             'Attribute

    Set objAttr = mobjCacheXML.createAttribute("disabled")
    objAttr.value = "true"
    Call objEntity.attributes.setNamedItem(objAttr)
    
    objEntity.selectSingleNode("id").text = objEntity.selectSingleNode("id").text & ":disabled"
    
    Set objEntityList = objEntity.selectNodes("entity")
    
    for each objChildEntity in objEntityList
      Call DisableEntity(objChildEntity)
    next    
  
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : MoveEntity(strSrcID, strParentID)                       '
  ' Description   : Move and entity, identified by its unique ID to a new   '
  '               : place in the hierarchy, identified by the new parent's  '
  '               : unique ID.                                              '
  ' Inputs        : strSrcID    -- Unique ID of entity to move.             '
  '               : strParentID -- Unique ID of entity's new parent.        '
  ' Outputs       : none                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function MoveEntity(strSrcID, strParentID)
    Dim objSrcNode          'Node to move
    Dim objParentNode       'New parent of the source
    Dim objPrevParentNode   'Previous parent

    Dim objNewNode          'Clone of src
    Dim objAttr             'Set the has children attribute correctly
    
    Call RemoveHighlights()

'    response.write "<br>Finding: " & strSrcID & " to move: " & strParentID

    'Get the Src Node
    Set objSrcNode = mobjCacheXML.selectSingleNode("//entity[id = '" & strSrcID & "']")
        
    if objSrcNode is nothing then
      Err.Description = "HierarchyClass.MoveEntity -- Unable to find src node with ID = " & strSrcID
      Err.Raise -1
    end if
    
    'Get the parent Node
    Set objParentNode = mobjCacheXML.selectSingleNode("//entity[id = '" & strParentID & "']")
    
    if objParentNode is nothing then
      Err.Description = "HierarchyClass.MoveEntity -- Unable to find parent node with ID = " & strParentID
      Err.Raise -1
    end if
    
    'Set the has children attribute of the previous parent
    Set objPrevParentNode = objSrcNode.parentNode
    
    Set objAttr = mobjCacheXML.createAttribute("HasChildren")
    
    if objPrevParentNode.selectNodes("entity").length > 1 then
      objAttr.value = "true"
    else
      objAttr.value = "false"
    end if
    
    Call objPrevParentNode.attributes.setNamedItem(objAttr)
    
    'Now move the node
    Set objAttr = mobjCacheXML.createAttribute("HasChildren")
    objAttr.value = "true"
    Call objParentNode.attributes.setNamedItem(objAttr)
    
    'Clone the node
    Set objNewNode = objSrcNode.cloneNode(true)
    
    'Expand by default
    Set objAttr = mobjCacheXML.createAttribute("visible")
    objAttr.value = "true"
    Call objNewNode.attributes.setNamedItem(objAttr)

    'Highlight parent
    Call HighlightNode(objParentNode, false)
    
    'Highlight moved nodes
    Call HighlightNode(objNewNode, true)

    Call objParentNode.appendChild(objNewNode)
    
    'Remove the original
    Call objSrcNode.parentNode.removeChild(objSrcNode)
    'Deactivate the original
    'Call DisableEntity(objSrcNode)
    
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : CommitToDB()                                            '
  ' Description   : Commit changes to the database.                         '
  ' Inputs        : none                                                    '
  ' Outputs       : none                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function CommitToDB()
    Dim objCacheEntityList      'List of cache entities
    Dim objCacheEntity          'Cache entities
    
    Dim objDBEntity
    Dim objDBParentEntity
    
    Dim objDisabledAttr         'Attribute indicating disabled account
    Dim bDisabled               'boolean indicating disabled
    
    Dim objDBXMLDoc             'temporary DB XML document
    
    Set objDBXMLDoc = server.CreateObject("Msxml2.DOMDocument.3.0")
    
    objDBXMLDoc.async             = false
    objDBXMLDoc.validateOnParse   = false
    objDBXMLDoc.resolveExternals  = false

    Call objDBXMLDoc.load(g_BaseDir & "hierarchy.xml")
    
    Set objCacheEntityList = mobjCacheXML.selectNodes("//entity")
    
    for each objCacheEntity in objCacheEntityList
      'Check for parent match

      'Do not place diabled items
      Set objDisabledAttr = objCacheEntity.attributes.getNamedItem("disabled")
      
      if objDisabledAttr is nothing then
        if objCacheEntity.selectSingleNode("id").text <> 0 then
        
          Set objDBEntity = objDBXMLDoc.selectSingleNode("//entity[id = '" & objCacheEntity.selectSingleNode("id").text & "']")
          if not CheckParent(objCacheEntity, objDBEntity) then
            
            'Move the entity to the new parent
            Set objDBParentEntity = objDBXMLDoc.selectSingleNode("//entity[id = '" & objCacheEntity.parentNode.selectSingleNode("id").text & "']")
            
            Call objDBParentEntity.appendChild(objDBEntity.cloneNode(true))
            
            Call objDBEntity.parentNode.removeChild(objDBEntity)
          end if
        end if
      end if
    next
    
    Call objDBXMLDoc.Save(g_BaseDir & "hierarchy.xml")
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : CheckParent(objCacheEntity, objDBEntity)                '
  ' Description   : Return true if the cache's parent maches the db         '
  '               : entity's parent.                                        '
  ' Inputs        : objCacheEntity  -- Cached data for the entity.          '
  '               : objDBEntity     -- DB data for the entity.              '
  ' Outputs       : true if the parent matches, false otherwise.            '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function CheckParent(objCacheEntity, objDBEntity)
    Dim objCacheParent        'Cache's parent entity
    Dim objDBParent           'DB object's parent entity
    
    Set objCacheParent  = objCacheEntity.parentNode
    Set objDBParent     = objDBEntity.parentNode
    
    'Check for the parent match
    if objCacheParent.selectSingleNode("id").text = objDBParent.selectSingleNode("id").text then
'      response.write "<br>True"
      CheckParent = true
    else
'      response.write "<br>False"    
      CheckParent = false
    end if    
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : LoadXML()                                               '
  ' Description   : Load the XML and XSL documents.                         '
  ' Inputs        : none                                                    '
  ' Outputs       : none -- raises parse errors, etc.                       '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function LoadXML()
    
    'Load XML
    Call mobjXML.LoadXML(mstrXML)
    
    if mobjXML.parseError then
      Err.Description = "HierarchyClass.LoadXML -- Unable to load XML: " & mobjXML.parseError.reason & "(line " & mobjXML.parseError.line & "  column " & mobjXML.parseError.linepos
      Err.Raise - 1
    end if
    
    'Load XSL
    if mbUseXSLString then
      Call mobjXSL.LoadXML(mstrXSL)
    else
      Call mobjXSL.Load(mstrXSLPath)
    end if

    if mobjXSL.parseError then
      Err.Description = "HierarchyClass.LoadXML -- Unable to load stylesheet: " & mobjXSL.parseError.reason & "(line " & mobjXML.parseError.line & "  column " & mobjXML.parseError.linepos
      Err.Raise - 1
    end if

  End Function 
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : GetMenu()                                               '
  ' Description   : Return HTML for the hierarchy menu.                     '
  ' Inputs        : none                                                    '
  ' Outputs       : HTML for the menu                                       '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function GetMenu()
  
    GetMenu = mobjXML.transformNode(mobjXSL)
  
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : CloneEntity(objXMLDoc, objEntity, bDeep)                    '
  ' Description : Clone the passed in entity. If bDeep is true, the child     '
  '             : hiearchy is maintained.                                     '
  ' Inputs      : objEntity   --  Entity to clone.                            '
  '             : objXMLDoc   --  XML DOM document.                           '
  '             : bDeep       --  Clone children of the entity.               '
  ' Outputs     : Cloned entity.                                              '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function CloneEntity(objEntity, bDeep)
    Dim objClone          'Cloned entity
    
    Dim objName           'ID node
    Dim objID             'Name node
    
    Dim objNodeList
    Dim objNode           'GP node
    
    Dim objAttr           'Attribute node
'    response.write "<Br>CLoning"
    'Get the clone
    Set objClone = objEntity.cloneNode(bDeep)
    
    if not bDeep then
      Call objClone.appendChild(objEntity.selectSingleNode("name").cloneNode(true))
      Call objClone.appendChild(objEntity.selectSingleNode("id").cloneNode(true))    
    end if
    
    'response.write "<br><br><br>Clone: " & server.HTMLEncode(objEntity.XML) & "to " & "<br>" & server.HTMLEncode(objClone.xml)
    
    'Set the has child attributes for the XSL
    Set objNodeList = objEntity.selectNodes("entity")
    
    Set objAttr = mobjXML.createAttribute("HasChildren")
    
    if objNodelist.length > 0 then
      objAttr.value = "true"
    else
      objAttr.value = "false"
    end if
    
    Call objClone.attributes.setNamedItem(objAttr)
    
'    for each objNode in objNodeList
'      Set objAttr = mobjXML.createAttribute("HasChildren")
      
'      if objNode.selectSingleNode("entity") is nothing then
'        objAttr.value = "false"
'      else
'        objAttr.value = "true"
'      end if
      
'      Call objNode.attributes.setNamedItem(objAttr)
'    next
'    response.write server.HTMLEncode(objClone.xml)
    
    Set CloneEntity = objClone 
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : UpdateCache(strAction, strID)                           '
  ' Description   : Update the XML cache to add/remove an item.             '
  ' Inputs        : strAction -- Load/Unload                                '
  '               : strID     -- ID to Add/Remove                           '
  ' Outputs       : none                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function UpdateCache(strAction, strID)
    Dim objNodeList       'List of nodes
    Dim objNode           'Node in list
    
    Dim objDBNode         'Database node
    Dim objCacheNode      'Get the correct location
    Dim objCacheParent    'Parent of the cache node
    
'    response.write "<br>ID: " & strID
    strAction = UCase(strAction)    
    
    'if no ID is passed, then completely init the cache
    if len(strID) = 0 then
      Set mobjCacheXML = server.CreateObject("Msxml2.DOMDocument.3.0")

      mobjCacheXML.async            = false
      mobjCacheXML.validateOnParse  = false
      mobjCacheXML.resolveExternals = false
      
      Call mobjCacheXML.loadXML("<hierarchy />")
      
      'Get the top level items
      Call GetEntityFromDB("", "byid", true)
      
      Call SaveCache()
    end if
      
    'This should yield a list of ONE node
    Set objNodeList = mobjCacheXML.selectNodes("//entity[id ='" & strID & "']")
    for each objNode in objNodeList
      Set objCacheParent = objNode.parentNode

      if strAction = "LOAD" then
        'Find the node to load
        Set objDBNode = GetEntityFromDB(strID, "byid", true)

        Call CopyAttributes(objNode, objDBNode)
        
        Call objCacheParent.removeChild(objNode)

        'Add the node in the correct location
        'If loading, the node is actually already in the cache
        objCacheParent.appendChild(objDBNode)

        Call SetVisible(strID, true)
      else
        Call SetVisible(strID, false)
      end if
    next
    
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : FindEntity(strSearch, strValue)                         '
  ' Description   : Find an entity in the hierarchy based on the search     '
  '               : criteria.                                               '
  ' Inputs        : strSearch -- Method of seach.                           '
  '               : strValue  -- Value to search for.                       '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function FindEntity(strSearch, strValue)
    Dim objEntity         'Entity to find
    Dim strSearchString   'Search string
    Dim strXSLPattern     'Pattern

    if UCase(strSearch) = "USERNAME" then
      Set objEntity = GetEntityFromDB(strValue, "byname", false)
      strXSLPattern = "//entity[name = '" & strValue & "']"
      strSearchString = "name"
    else
      Set objEntity = GetEntityFromDB(strValue, "byid", false)
      strXSLPattern = "//entity[id = '" & strValue & "']"
      strSearchString = "id"
    end if
    
    if not objEntity is nothing then
      'If not in cache, search from parent
      if(mobjCacheXML.selectSingleNode(strSearch) is nothing) then
        if not objEntity.parentNode.selectSingleNode(strSearchString) is nothing then
          Call FindEntity(strSearch, objEntity.parentNode.selectSingleNode(strSearchString).text)
        end if
      end if  
    
      Call UpdateCache("LOAD", objEntity.selectSingleNode("id").text)
      Call RemoveHighlights()
'      response.write "highlight: " & objEntity.selectSingleNode("id").text
'      response.write server.HTMLEncode(mobjCacheXML.xml)
      Call HighlightNode(mobjCacheXML.selectSingleNode("//entity[id = '" & objEntity.selectSingleNode("id").text & "']"), true)
      
      FindEntity = true
    else
      Call RemoveHighlights()
      FindEntity = false
    end if
      
      
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : GetEntityFromDB(strID)                                  '
  ' Description   : Load the selected entity from the database              '
  ' Inputs        : strID   -- Entity to get                                '
  ' Outputs       : XML node.                                               '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function GetEntityFromDB(strID, strMethod, bClone)
    Dim objDBXML                'DOMdocument to parse data from the database
    Dim objDBEntityNode         'Entity Node
    Dim objDBEntityNodeList     'List of nodes
    
    Dim objClonedDBEntity
    Dim objClonedChild          'Cloned child entity
    
    Dim objChildNodeList
    Dim objChildNode
    
    Set objDBXML = server.CreateObject("Msxml2.DOMDocument.3.0")
  
    'Simulate getting the info for the node from the DB
    objDBXML.async = false
    objDBXML.validateOnParse = false
    objDBXML.resolveExternals = false

    Call objDBXML.Load(g_BaseDir & "hierarchy.xml")
    
    'If no ID passed, get the top level items
    if len(strID) = 0 then
      Set objDBEntityNodeList = objDBXML.selectNodes("/hierarchy/entity")
      
      for each objDBEntityNode in objDBEntityNodeList
        Call mobjCacheXML.documentElement.appendChild(CloneEntity(objDBEntityNode, false))
      next
      
    else
      if UCase(strMethod) = "BYNAME" then    
        Set objDBEntityNode = objDBXML.selectSingleNode("//entity[name = '" & strID & "']")
      else
        Set objDBEntityNode = objDBXML.selectSingleNode("//entity[id = '" & strID & "']")
      end if
    
      'Get the child list
      if not objDBEntityNode is nothing then
        Set objClonedDBEntity = CloneEntity(objDBEntityNode, false)
        
        Set objChildNodeList = objDBEntityNode.selectNodes("entity")
        
        for each objChildNode in objChildNodeList
          'If the child exists in the cache, use it. Otherwise, load it
          Set objClonedChild = mobjCacheXML.selectSingleNode("//entity[id = '" & objChildNode.selectSingleNode("id").text & "']")
          
          if not objClonedChild is nothing then
            Call objClonedDBEntity.appendChild(objClonedChild.cloneNode(true))
          else
            Call objClonedDBEntity.appendChild(CloneEntity(objChildNode, false))
          end if
        next
        
        if bClone then
          'Return the clone, with children
          Set GetEntityFromDB = objClonedDBEntity
        else
          'Return the actual node
          Set GetEntityFromDB = objDBEntityNode
        end if
        
      else
        Set GetEntityFromDB = nothing
      end if    
    end if
    
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : CopyAttributes(objSrc, objDest)                         '
  ' Description   : Copy display related attributes from the source to the  '
  '               : destination.                                            '
  ' Inputs        : objSrc  -- Node to get attributes from.                 '
  '               : objDest -- Node to copy attributes to.                  '
  ' Outputs       : none                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function CopyAttributes(objSrc, objDest)
    Dim objAttr         'Attribute item
    Dim objNewAttr      'New attribute
    Dim i               'Counter
    
    for i = 0 to objSrc.attributes.length - 1
      Set objAttr = objSrc.attributes(i)
      
      Set objNewAttr = mobjCacheXML.createAttribute(objAttr.name)
      objNewAttr.value = objAttr.value
      
      Call objDest.attributes.setNamedItem(objNewAttr)
    next

  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : GetName(strID)                                          '
  ' Description   : Get the entity name, based on the ID                    '
  ' Inputs        : strID -- ID of the entity to get the name for.          '
  ' Outputs       : Name of the item.                                       '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function GetName(strID)
    GetName = mobjCacheXML.selectSingleNode("//entity[id = '" & strID & "']/name").text
  End Function  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : SaveCache()                                             '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function SaveCache()
    Set session("HIERARCHY_CACHE") = mobjCacheXML
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : SetVisible(strID, bVisible)                             '
  ' Description   : Set visibility for an item.                             '
  ' Inputs        : ID of item to make visible                              '
  ' Outputs       : none                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function SetVisible(strID, bVisible)
    Dim objNodeList     'List of nodes
    Dim objNode         'Each node in the list
    Dim objAttr         'Attribute to add
    
    Set objNodeList = mobjCacheXML.selectNodes("//entity[id = '" & strID & "']")
    
    for each objNode in objNodeList
      Set objAttr = mobjCacheXML.createAttribute("visible")
      objAttr.value = CStr(bVisible)
      
      Call objNode.attributes.setNamedItem(objAttr)
      
'      response.write "<br>Setting: " & objNode.selectSingleNode("name").text & " : " & objAttr.value
    next  
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Public Properties
    Public Property Let XSL(strVal)
      mstrXSL = strVal
    End Property
    
    Public Property Get XSL()
      XSL = mstrXSL
    End Property
    
    Public Property Let UseXSLString(bVal)
      mbUseXSLString = bVal
    End Property
    
    Public Property Get UseXSLString()
      UseXSLString = mbUseXSLString
    End Property
    
    Public Property Let XSLPath(strVal)
      mstrXSLPath = strVal
      
      Call mobjXSL.Load(mstrXSLPath)
      
    End Property
    Public Property Get XSLPath()
      XSLPath = mstrXSLPath
    End Property
    
    Public Property Let XML(strVal)
      mstrXML = strVal
    End Property
    Public Property Get XML()
      XML = mstrXML
    End Property
    
    Public Function CacheXML()
      Set CacheXML = mobjCacheXML
    End Function
  
  End Class
  
%>