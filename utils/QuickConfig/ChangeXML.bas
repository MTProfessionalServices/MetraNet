Attribute VB_Name = "ChangeXML"
Option Explicit

Private Vars As String

Public Function CloneNode(ParentNode As String, ChildNode As String) As Boolean
On Error GoTo errlog

  CloneNode = True
  Dim oNewNode As Variant
  Dim root As Variant

  oXMLDoc.preserveWhiteSpace = True
  Set root = oXMLDoc.selectSingleNode(ParentNode + "/" + ChildNode)     'e.g. "xmlconfig/Services/ServiceData/ServiceChild"
  Set oNewNode = root.CloneNode(True)
  Set root = oXMLDoc.selectSingleNode(ParentNode)     'e.g. "xmlconfig/Services/ServiceData"
  root.appendChild (oNewNode)
  Exit Function
  
errlog:
  CloneNode = False
  Vars = ParentNode + ", " + ChildNode
  Call subErrLog("CloneNode", , Vars)
End Function

Public Function ChangeValue(SelectNode As String, NodeText As String, dn As String) As Boolean
On Error GoTo errlog

   Dim root As IXMLDOMElement
   Dim singlenode As IXMLDOMNode
  
   ChangeValue = True
  
   Set root = oXMLDoc.selectSingleNode(SelectNode)  'e.g. "xmlconfig/Services/ServiceData/ServiceName"
  
   Set singlenode = root.selectSingleNode(dn)
   singlenode.Text = NodeText
   
   Exit Function
  
errlog:
   ChangeValue = False
   Vars = SelectNode + ", " + NodeText + ", " + dn
   Call subErrLog("ChangeValue", , Vars)
End Function

Public Function KillNode(ParentNode As String, CurrentNode As String, NodeValue As String, NodeName As String) As Boolean
On Error GoTo errlog
  
  Dim root As IXMLDOMElement
  Dim oldnode As IXMLDOMNode
  Dim currnode As IXMLDOMNode
  
  Set root = oXMLDoc.selectSingleNode(ParentNode + "/" + CurrentNode + "[" + NodeName + "=" + Chr$(39) + NodeValue + Chr$(39) + "]")
  Set currnode = oXMLDoc.selectSingleNode(ParentNode)
'  Debug.Print root.Text
'  Debug.Print currnode.Text
  Set oldnode = currnode.removeChild(root)

  KillNode = True
  Exit Function
  
errlog:
  KillNode = False
  Vars = ParentNode + ", " + CurrentNode + ", " + NodeValue + ", " + NodeName
  Call subErrLog("KillNode", , Vars)
End Function

'Public Function DetermineWhichChild(theNode As String, DNname As String) As Integer
'
'   Dim root As Variant
'   If Not GetXMLNodes(oXMLDoc, theNode, oXMLNodes) Then
''      blnotvalid = True
'      GoTo errlog
'   End If
'   Dim i As Integer
'   Dim result As Boolean
'   Dim dntest
'   For i = 0 To (oXMLNodes.Length - 1)
'
'      Set oNode = oXMLNodes.Item(i)
'      result = GetXMLTag(oNode, "dn", dntest)
'      If dntest = DNname Then
'        Set root = oXMLDoc.selectSingleNode(theNode)
'        DetermineWhichChild = i + 1
'        Exit For
'      End If
'
'   Next
'
'errlog:
'End Function

''new node
'Dim objCurrNode, objNewNode, objNewText
'Set objNewNode = oXMLDoc.createElement("ServiceChild")
'Set objNewText = oXMLDoc.createTextNode("test")
'objNewNode.appendChild (objNewText)
'
'Set objCurrNode = oXMLDoc.selectSingleNode("xmlconfig/Services/ServiceData")
'objCurrNode.appendChild (objNewNode)
'Set objCurrNode = objCurrNode.lastChild



