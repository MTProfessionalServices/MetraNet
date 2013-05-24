Attribute VB_Name = "ParseMSIX"
'**************************************************
'© 2005 by MetraTech Corp.
'
'Author: Michael Ross
'MSIXDEF parsing by Simon Morton
'Last Update: 08-08-05
'
'Sorry, no time to comment this code yet...
'**************************************************

Option Explicit

Public oXMLDoc As New DOMDocument
Public oXMLNodes As Object
Public blFirst As Boolean
Public blLast As Boolean
Public blCheckParentKeys As Boolean


'*******************************************************************************
'*** Load an XML file into a DOM object
'*******************************************************************************
Public Function LoadXMLDoc(ByRef oXMLDoc, sFile)
  LoadXMLDoc = False
  On Error Resume Next


  If CheckErrors("creating XML DOM object") Then
      MsgBox "A parsing error occurred. " + vbNewLine + _
             "See " + App.Path + "\QuickConfig.log" + " for details.", vbCritical
      Exit Function
  End If

  oXMLDoc.async = False
  oXMLDoc.validateOnParse = False
  oXMLDoc.preserveWhiteSpace = True
  oXMLDoc.resolveExternals = False

  oXMLDoc.Load (sFile)
  If CheckErrors("loading XML file " & sFile) Then
    Set oXMLDoc = Nothing
  End If

  LoadXMLDoc = True
End Function
'*******************************************************************************
  

'*******************************************************************************
'*** Get the value of a tag from an XML document
'*******************************************************************************
Public Function GetXMLTag(oXMLDoc, sTagName, ByRef sElementValue)
  Dim oXMLNode

  GetXMLTag = False
  On Error Resume Next

  Set oXMLNode = oXMLDoc.selectSingleNode(sTagName)
'  Err.Raise 1
  If CheckErrors("getting tag " & sTagName) Then
      MsgBox "A parsing error occurred. " + vbNewLine + _
             "See " + App.Path + "\QuickConfig.log" + " for details.", vbCritical
      Exit Function
  End If
  If oXMLNode Is Nothing Then
'    WriteLog "<*** Error: Tag " & sTagName & " not found"
    Exit Function
  End If

  sElementValue = oXMLNode.Text
  GetXMLTag = True
End Function
'*******************************************************************************
  

'*******************************************************************************
'*** Get a list of nodes matching a tag
'*******************************************************************************
Public Function GetXMLNodes(oXMLDoc, sTagName, ByRef oNodeList)
  GetXMLNodes = False
  On Error Resume Next

  Set oNodeList = oXMLDoc.selectNodes(sTagName)
  If CheckErrors("getting tag " & sTagName) Then
      MsgBox "A parsing error occurred. " + vbNewLine + _
             "See " + App.Path + "\QuickConfig.log" + " for details.", vbCritical
      Exit Function
  End If
  If oNodeList Is Nothing Then
    CheckErrors ("<*** Error: Tag " & sTagName & " not found.")
    MsgBox "A parsing error occurred. " + vbNewLine + _
          "See " + App.Path + "\QuickConfig.log" + " for details.", vbCritical
    Exit Function
  End If

  GetXMLNodes = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** If error occurred, logs message and returns TRUE, else returns FALSE
'*******************************************************************************
Public Function CheckErrors(ptext As String)
  CheckErrors = False
  If Err.Number <> 0 Then
    If Len(ptext) > 0 Then
'      Dim sMsg
'      sMsg = "<*** [" & Err.Source & "] (" & Err.Number & ") " & Err.Description
'      Debug.Print "<*** Error " & stext
'      Debug.Print sMsg
      Call subErrLog("CheckErrors", ptext)
      CheckErrors = True
      Err.Clear
    End If
  End If
End Function
'*******************************************************************************

