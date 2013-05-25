VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "XMLLoader"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'****************************************************************************************************************************************************
'
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
' ****************************************************************************
' CLASS         :
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   : MetraTech Extentable Service.
'
'
'
' $Date$
' $Author$
' $Revision$
' $Workfile$
'
'
'*****************************************************************************
Option Explicit

Private m_objXMLDom As New XMLDomMgr

Private m_Translate As CVariables

Public Function LoadObjectModelData(objInstance As Object, strXMLFile As String, Optional objTranslate As CVariables, Optional strCOMObjectName As String) As Boolean

    On Error GoTo ErrMgr


    Dim objXMLNodes As IXMLDOMNodes
    
    Set m_Translate = objTranslate
    
    
    If (Len(strCOMObjectName) = 0) Then
        strCOMObjectName = TypeName(objInstance)
    End If
    
    
    If (m_objXMLDom.LoadFile(strXMLFile)) Then ' Load and parse the xml file
        
        ' Find the instance of the allocated COM object in the XML file
        ' We use the COM Object name to match the XML Tag.
        ' Every COM Name is used in lower case because VB force some
        ' name to be in upper/lower case. Sample Menu cannot be written menu
        ' because there is already a Menu name object in VB itself.
        Set objXMLNodes = m_objXMLDom.FindXMLNodesInChild(m_objXMLDom.XMLDoc, LCase(strCOMObjectName))
        If (objXMLNodes.Count = 1) Then
        
            LoadObjectModelData = LoadCOMInstanceFromNode(objInstance, objXMLNodes(1))
        Else
            TRACE Replace(MTVBLIB_ERROR_03500, "[FILE]", strXMLFile), "CObjectModelManager", "LoadObjectModelData", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
        End If
    Else
        TRACE Replace(MTVBLIB_ERROR_03501, "[FILE]", strXMLFile), "CObjectModelManager", "LoadObjectModelData", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
    End If

    Exit Function
ErrMgr:
  TRACE GetVBErrorString(), "XMLLoader.cls", "LoadObjectModelData", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
End Function





Private Function LoadCOMInstanceFromNode(ByVal objInstance As Object, ByVal objXMLNode As IXMLDOMNode) As Boolean

    On Error GoTo ErrMgr

    Dim strId                   As String
    Dim objXMLAttribute         As IXMLDOMNode
    Dim objXMLCollectionItem    As IXMLDOMNode
    Dim obj                     As IXMLDOMNode
    Dim objXMLCollectionItem2   As IXMLDOMNode
    Dim objXMLProperty          As IXMLDOMNode
    Dim objXMLProperty2         As IXMLDOMNode
    Dim objXMLCollectionItems   As IXMLDOMNodes
    Dim objXMLProperties        As IXMLDOMNodes
    Dim objCOMCollectionItem    As Object
    Dim objSubInstance          As Object
    Dim booFound                As Boolean
    Dim PropertyType            As String
    Dim strCollectionItemId     As String
    Dim strType                 As String
    Dim booNoKey                As Boolean
        
    ' First read the ID this is a mandatory property and it is defined as an attribute
    ' The id attr is not mandatory
    Set objXMLAttribute = m_objXMLDom.FindXMLAttributInNode(objXMLNode, "id")
    If (Not objXMLAttribute Is Nothing) Then
        strId = objXMLAttribute.Text
        ' This may raise an error if the object does implement the right interface
        ' to support the CObjectModelManager
        objInstance.id = strId
    End If
    
    'Debug.Print "LoadCOMInstanceFromNode " & TypeName(objInstance) & " " & objXMLNode.baseName & " id=" & strId
    
    ' If the COM Object is a collection we need to know it
    Set objXMLAttribute = m_objXMLDom.FindXMLAttributInNode(objXMLNode, "type")
    If (Not objXMLAttribute Is Nothing) Then
        PropertyType = LCase(objXMLAttribute.Text)
    End If
           
    ' Now load all the properties defined in the current node
    Set objXMLProperties = m_objXMLDom.FindXMLNodesInChild(objXMLNode)
    
    For Each objXMLProperty In objXMLProperties
    
        booFound = False
        ' If the property is a Text then we read the value
        
        If (objXMLProperty.childNodes.Length <= 1) And (objXMLProperty.nodeType = NODE_ELEMENT) Then ' only on child of type NODE_TEXT
            
            ' Check the type is not a collection - because the case of a collection with no item ends here...
            Set objXMLAttribute = m_objXMLDom.FindXMLAttributInNode(objXMLProperty, "type")
            If (IsValidObject(objXMLAttribute)) Then
                strType = objXMLAttribute.Text
            Else
                strType = ""
            End If
            
            If (strType <> "collection") Then
                If (objXMLProperty.childNodes.Length = 0) Then ' blank tag
                
                    'Debug.Print "Property " & objXMLProperty.baseName & "=" & objXMLProperty.Text
                    CallByName objInstance, objXMLProperty.baseName, VbLet, objXMLProperty.Text
                    booFound = True
                Else
                    ' Support xml tag contains in CDATA[]
                    If (objXMLProperty.childNodes(0).nodeType = tagDOMNodeType.NODE_TEXT) Or (objXMLProperty.childNodes(0).nodeType = tagDOMNodeType.NODE_CDATA_SECTION) Then
                    
                        'Debug.Assert Not (objXMLProperty.childNodes(0).nodeType = tagDOMNodeType.NODE_CDATA_SECTION)
                        'Debug.Print "Property " & objXMLProperty.baseName & "=" & objXMLProperty.Text
                        CallByName objInstance, objXMLProperty.baseName, VbLet, objXMLProperty.Text
                        booFound = True
                    End If
                End If
            End If
        End If
        
        ' If the property is a new node that means another sub COM instance
        ' We call recursively this function
        If (objXMLProperty.nodeType = NODE_ELEMENT) And (Not booFound) Then
            '
            If (PropertyType = "collection") Then
                
                ' Here we expect an id attribute
                Set obj = m_objXMLDom.FindXMLAttributInNode(objXMLProperty, "id")
                If (Not obj Is Nothing) Then
                    strCollectionItemId = obj.Text
                End If
                
                ' MTVBLIB V2
                ' An collection item may have an attribut nokey=true
                ' If true this mean we add all the item, we pass the id of the collection
                ' as an empty string
                booNoKey = False
                Set obj = m_objXMLDom.FindXMLAttributInNode(objXMLProperty, "nokey")
                If (Not obj Is Nothing) Then
                    If (UCase$(obj.Text) = "TRUE") Then booNoKey = True
                End If
                
                If (booNoKey) Then
                    Set objCOMCollectionItem = objInstance.Add(strCollectionItemId, booNoKey)
                Else
                    If (objInstance.Exist(strCollectionItemId)) Then
                        Set objCOMCollectionItem = objInstance.Item(strCollectionItemId)
                    Else
                        Set objCOMCollectionItem = objInstance.Add(strCollectionItemId)
                    End If
                End If
                
                ' Here I test if the name match so a collection can contains other tag then
                ' the item collection type. This tag are ignored!
                If (LCase(TypeName(objCOMCollectionItem)) = LCase(TranslateXMLTag(objXMLProperty.baseName))) Then
                
                    'Debug.Print "New Collection Item " & TypeName(objCOMCollectionItem) & " id=" & strCollectionItemId
                    strCollectionItemId = ""
                    ' At this point we have added an item to the collection
                    ' Now we call recursively the function to populate the item
                    ' Because objXMLCollectionItem2 is modified by the function LoadCOMInstanceFromNode()
                    ' we cannot pass objXMLCollectionItem which is the for each loop index
                    Set objXMLCollectionItem2 = objXMLProperty
                    LoadCOMInstanceFromNode objCOMCollectionItem, objXMLCollectionItem2
                End If
            Else
                Set objSubInstance = CallByName(objInstance, objXMLProperty.baseName, VbGet)
                Set objXMLProperty2 = objXMLProperty
                LoadCOMInstanceFromNode objSubInstance, objXMLProperty2
            End If
            booFound = True
        End If
    Next
    LoadCOMInstanceFromNode = True
    

    Exit Function
ErrMgr:
'Resume
  TRACE GetVBErrorString(), "XMLLoader.cls", "LoadCOMInstanceFromNode", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
End Function


Private Sub Class_Terminate()

    On Error GoTo ErrMgr

    Set m_Translate = Nothing

    Exit Sub
ErrMgr:
  TRACE GetVBErrorString(), "XMLLoader.cls", "Class_Terminate", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
End Sub

Private Function TranslateXMLTag(strTag As String) As String

    On Error GoTo ErrMgr


    TranslateXMLTag = strTag
    
    If (IsValidObject(m_Translate)) Then
    
        If (m_Translate.Exist(strTag)) Then
        
            TranslateXMLTag = m_Translate(strTag).Value
        End If
    End If

    Exit Function
ErrMgr:
  TRACE GetVBErrorString(), "XMLLoader.cls", "TranslateXMLTag", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
End Function
