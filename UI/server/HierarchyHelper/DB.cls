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
Option Explicit

Private mobjXML As New DOMDocument40        'XML document

Private mSnapShot As Date
Private mActorYaac As MTYAAC
Private mstrRootName As String

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Class_Initialize()
  mobjXML.async = False
  mobjXML.validateOnParse = False
  mobjXML.resolveExternals = False
  mSnapShot = Date
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
' Find the entity in the database, load the returned fragment with mobjXML
'
' Sample Fragment:
'  <hierarchy bChildren="Y" bFolder="Y">
'    <parent_id>1</parent_id>
'    <child>Account Hierarchy Root</child>
'    <id_acc>1</id_acc>
'
'    <hierarchy bChildren="N" bFolder="N">
'      <parent_id>1</parent_id>
'      <child>MetraTech</child>
'      <id_acc>2</id_acc>
'    </hierarchy>
'
'  </hierarchy>
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Friend Function LoadEntity(ByVal strID As String, _
                           ByVal strIDType As String, Optional bGetChildren = True) As IXMLDOMNode
  
  Dim objDBNode As IXMLDOMNode
  Dim objHierarchyNode As IXMLDOMNode
  Dim objNode As IXMLDOMNode
  Dim objChildNode As IXMLDOMNode
  Dim strXML As String
  Dim strQuery As String
  Dim objSyntheticRoot As IXMLDOMNode
  Dim objTempNode As IXMLDOMNode
  Dim objCorporateNode As IXMLDOMNode
  
  ' If we are the synthetic root get the hierarcy root and children
  If strID = "1" Then
    strXML = mActorYaac.GetAncestorMgr().HierarchyRoot(CDate(mSnapShot)).GetChildListXML.XML
    
    Call mobjXML.loadXML(strXML) ' load fragment
    
    ' Change the sythetic roots parent_id to be 0 so we know when to stop
    strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strID)
    Set objSyntheticRoot = mobjXML.selectSingleNode(strQuery)
    Set objTempNode = objSyntheticRoot.selectSingleNode(ENTITY_PARENT_ID)
    objTempNode.Text = "0"
      
    Set objCorporateNode = mobjXML.createElement(ENTITY_NAME)
    objCorporateNode.Text = mstrRootName
    Call objSyntheticRoot.appendChild(objCorporateNode)
    
    Set objCorporateNode = mobjXML.createElement(HIERARCHY_NAME)
    objCorporateNode.Text = mstrRootName
    Call objSyntheticRoot.appendChild(objCorporateNode)

  Else
    If bGetChildren Then
      ' Get node with children
      strXML = mActorYaac.GetAncestorMgr().HierarchySlice(CLng(strID), CDate(mSnapShot)).GetChildListXML.XML
      
      Call mobjXML.loadXML(strXML) ' load fragment
      
      'Lookup parent and set id in XML
      strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strID)
      Set objSyntheticRoot = mobjXML.selectSingleNode(strQuery)
      Set objTempNode = objSyntheticRoot.selectSingleNode(ENTITY_PARENT_ID)
      objTempNode.Text = mActorYaac.GetAncestorMgr().HierarchySlice(CLng(strID), CDate(mSnapShot)).Parent

    Else
      ' Get node without children (FOR NOW LOAD CHILDREN TOO....)
      strXML = mActorYaac.GetAncestorMgr().HierarchySlice(CLng(strID), CDate(mSnapShot)).GetChildListXML.XML
      Call mobjXML.loadXML(strXML) ' load fragment
      
      'Lookup parent and set id in XML
      strQuery = Replace(ANY_ENTITY_WITH_ID, "[ID]", strID)
      Set objSyntheticRoot = mobjXML.selectSingleNode(strQuery)
      Set objTempNode = objSyntheticRoot.selectSingleNode(ENTITY_PARENT_ID)
      objTempNode.Text = mActorYaac.GetAncestorMgr().HierarchySlice(CLng(strID), CDate(mSnapShot)).Parent

    End If
  End If
 
   Set LoadEntity = mobjXML.documentElement

End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PROPERTIES                                                                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let snapShot(ByVal d As String)
    mSnapShot = d
End Property

Public Property Get snapShot() As String
    snapShot = mSnapShot
End Property

Public Property Set actorYaac(ByVal objYaac As MTYAAC)
    Set mActorYaac = objYaac
End Property

Public Property Get actorYaac() As MTYAAC
    Set actorYaac = mActorYaac
End Property

Public Property Let RootName(ByVal strName As String)
    mstrRootName = strName
End Property

Public Property Get RootName() As String
    RootName = mstrRootName
End Property

