VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "DB"
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
'  DB.cls                                                                   '
'  Handles calls to the database.                                           '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mobjXML As New DOMDocument30        'XML document

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Class_Initialize()
  mobjXML.async = False
  mobjXML.validateOnParse = False
  mobjXML.resolveExternals = False
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadEntity(strID)                                           '
' Description : Load an entity from the database, and return a reference to '
'             : an XML node for that entity.                                '
' Inputs      : strID -- Entity to load.                                    '
'             : strIDType -- Type of info the ID represents                 '
'             :         BY_NAME - Search by Name                            '
'             :         BY_ID   - Search by ID.                             '
' Outputs     : XML node for the entity                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function LoadEntity(ByVal strID As String, _
                           ByVal strIDType As String) As IXMLDOMNode
                           
  'Find the entity in the database, load the returned fragment with mobjXML
  'Calling functions


  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' What follows is dummy code, used for testing!
  Dim objDBNode As IXMLDOMNode
  Dim objHierarchyNode As IXMLDOMNode
  Dim objNode As IXMLDOMNode
  Dim objChildNode As IXMLDOMNode
  
  Dim strQuery As String
  
  Call mobjXML.Load("d:\temp\hierarchy.xml")
  
  Select Case UCase(strIDType)
    Case "BY_ID"
      strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strID)
      
    Case "BY_NAME"
      strQuery = Replace(ANY_ENTITY_WITH_NAME, "[NAME]", strID)
      
  End Select
'
'  'SPECIAL CASE FOR ROOT -- DUMMY CODE!
'  If strID = "1" Then
'    Dim objEntity As IXMLDOMNode
'    Dim objHierarchyNode As IXMLDOMNode
'    Dim ojbNode As IXMLDOMNode
'
'    Dim objAttr As IXMLDOMAttribute
'
'    Set objEntity = mobjXML.selectSingleNode(strQuery)
'
'    Set objHierarchyNode = mobjXML.createElement("hierarchy")
'
'    Set objNode = mobjXML.createElement("child")
'    objNode.Text = objEntity.selectSingleNode("parent_name").Text
'
'    Call objHierarchyNode.appendChild(objNode)
'
'    Set objNode = mobjXML.createElement("id_acc")
'    objNode.Text = objEntity.selectSingleNode("parent_id").Text
'    Call objHierarchyNode.appendChild(objNode)
'
'    Set objAttr = mobjXML.createAttribute("bChildren")
'    objAttr.Value = "Y"
'    Call objHierarchyNode.Attributes.setNamedItem(objAttr)
'
'    Set LoadEntity = objHierarchyNode
'
'    Exit Function
'  End If
'
   
  Set objDBNode = mobjXML.selectSingleNode(strQuery)
  
  'Clone the db node and it's children
  Set objHierarchyNode = CloneEntity(objDBNode)
  
  'Add any children
  For Each objChildNode In objDBNode.selectNodes(ENTITY_CHILD_NODES)
    Call objHierarchyNode.appendChild(CloneEntity(objChildNode))
  Next
  
  
  Set LoadEntity = objHierarchyNode

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : SaveEntity(objEntity)                                       '
' Description : Save the selected entity in the database.                   '
' Inputs      : objEntity -- Entity to save.                                '
' Outputs     : boolean                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function SaveEntity(ByRef objEntity As IXMLDOMNode) As Boolean

  'Check if parent changed?
  'Commit the change in the entity to the database. Each entity will have the format:
  ' <hierarchy>
  '   <parent_id />
  '   <child />
  '   <id_acc />
  ' </hiearchy>
  
End Function
