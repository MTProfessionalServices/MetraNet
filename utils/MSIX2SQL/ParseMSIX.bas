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

Private Declare Function CloseHandle Lib "kernel32" _
   (ByVal hfile As Long) As Long
   
Private Declare Function CreateFile Lib "kernel32" _
   Alias "CreateFileA" _
  (ByVal lpFileName As String, _
   ByVal dwDesiredAccess As Long, _
   ByVal dwShareMode As Long, _
   ByVal lpSecurityAttributes As Long, _
   ByVal dwCreationDisposition As Long, _
   ByVal dwFlagsAndAttributes As Long, _
   ByVal hTemplateFile As Long) As Long
   
Private Const FILE_SHARE_READ = &H1
Private Const FILE_SHARE_DELETE As Long = &H4
Private Const FILE_FLAG_BACKUP_SEMANTICS = &H2000000
Private Const OPEN_EXISTING = 3

Public oXMLDoc As New DOMDocument
Public oXMLNodes As Object
Public blFirst As Boolean
Public blLast As Boolean
Public servname As String
Public blCheckParentKeys As Boolean

Public Function MSIXParse(sXMLFile As String)
On Error GoTo errlog

  Dim sServiceName
  Dim i As Integer, sp As Integer
  Dim blnotvalid As Boolean
  
  Set oXMLDoc = New DOMDocument
  
  If Not LoadXMLDoc(oXMLDoc, sXMLFile) Then
      blnotvalid = True
      GoTo errlog
  End If

  If Not GetXMLTag(oXMLDoc, "defineservice/name", sServiceName) Then
      blnotvalid = True
      GoTo errlog
  End If

  servname = "Service Name: " & sServiceName

  If Not GetXMLNodes(oXMLDoc, "defineservice/ptype", oXMLNodes) Then
      blnotvalid = True
      GoTo errlog
  End If

'  WriteLog oXMLNodes.length & " properties found"
  
'  OpenPrintTable

  For i = 0 To (oXMLNodes.length - 1)
    Dim oNode As Variant
    Dim sName As String
    Dim sType As String
    Dim sLength As String
    Dim sReqd As String
    Dim blReqd As Boolean
    
    If i = 0 Then blFirst = True
    If i = oXMLNodes.length - 1 Then blLast = True

    Set oNode = oXMLNodes.Item(i)

    If Not GetXMLTag(oNode, "dn", sName) Then
      MsgBox "MSIXDEF file contains errors and cannot be parsed.", vbCritical
      Exit Function
    End If
    If Not GetXMLTag(oNode, "type", sType) Then
      MsgBox "MSIXDEF file contains errors and cannot be parsed.", vbCritical
      Exit Function
    End If
    Call GetXMLTag(oNode, "length", sLength)
    Call GetXMLTag(oNode, "required", sReqd)
    
    If LCase$(sReqd) = "y" Then
      blReqd = True
    Else
      blReqd = False
    End If
'    Debug.Print sName + " " + Str(blReqd)


    '*******************************Call subWriteSQL ********************************************************
        If blFirst Then
          If PKExists = False Then
            Call subWriteSQL("", "", "")   'First pass-through just for drop table and create - no columns.
            blFirst = False
          End If
        End If
        
        If blParent Then
           blLast = False
        Else
          If i = oXMLNodes.length - 1 Then
             If blMultiple Then
                blCheckParentKeys = True
             End If
          End If
        End If
        
        Call subWriteSQL(sName & ": " & sType, sLength, "", blReqd)      'Second pass-through for column body
         
        blCheckParentKeys = False
    
  Next i
    
  If blParent Then
      blCheckParentKeys = True
      Call subWriteSQL(sName & ": " & sType, sLength, "", blReqd)   'Third pass-through for parent - any extra columns not in the MSIXDEF
      blCheckParentKeys = False
  End If
  
  If blParent Then      'Fourth pass-through for control columns
     ControlColumns
     blLast = True
     Call subWriteSQL("", "", "")
  End If

'********************************************************************************************************


errlog:
   If blnotvalid Then
      MsgBox "This is not a valid MSIXDEF file." + vbNewLine + vbNewLine _
             + sXMLFile + "", vbCritical
      Exit Function
   End If
   subErrLog "MSIXParse"
End Function

'*******************************************************************************
'*** Load an XML file into a DOM object
'*******************************************************************************
Public Function LoadXMLDoc(ByRef oXMLDoc, sfile)
  LoadXMLDoc = False
  On Error Resume Next


  If CheckErrors("creating XML DOM object") Then
      MsgBox "A parsing error occurred. " + vbNewLine + _
             "See " + App.Path + "\MSIX2SQL.log" + " for details.", vbCritical
      Exit Function
  End If

  oXMLDoc.async = False
  oXMLDoc.validateOnParse = False
  oXMLDoc.preserveWhiteSpace = True
  oXMLDoc.resolveExternals = False

  oXMLDoc.Load (sfile)
  If CheckErrors("loading XML file " & sfile) Then
    Set oXMLDoc = Nothing
  End If

  LoadXMLDoc = True
End Function
'*******************************************************************************
  

'*******************************************************************************
'*** Get the value of a tag from an XML document
'*******************************************************************************
Public Function GetXMLTag(oXMLDoc, sTagName, ByRef sElementValue)
  Dim oXMLNode As Object

  GetXMLTag = False
  On Error Resume Next

  Set oXMLNode = oXMLDoc.selectSingleNode(sTagName)
'  Err.Raise 1
  If CheckErrors("getting tag " & sTagName) Then
'      MsgBox "A parsing error occurred. " + vbNewLine + _
'             "See " + App.Path + "\MSIX2SQL.log" + " for details.", vbCritical
'      Exit Function
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
             "See " + App.Path + "\MSIX2SQL.log" + " for details.", vbCritical
      Exit Function
  End If
  If oNodeList Is Nothing Then
    CheckErrors ("<*** Error: Tag " & sTagName & " not found.")
    MsgBox "A parsing error occurred. " + vbNewLine + _
          "See " + App.Path + "\MSIX2SQL.log" + " for details.", vbCritical
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


'don't want to use scripting object to avoid dependency
''*******************************************************************************
''*** Test for existence of a file
''*******************************************************************************
'Public Function FileExists(sFile)
'  Dim oFso
'  FileExists = False
'  Set oFso = CreateObject("Scripting.FileSystemObject")
'  If Not oFso.FileExists(sFile) Then
''    WriteLog "     File " & sFile & " not found"
'    Exit Function
'  End If
'  FileExists = True
'End Function
'*******************************************************************************

Public Function FileExists(ByVal sfile As String) As Boolean
On Error GoTo errlog

   Dim lFile As Long

   lFile = CreateFile(sfile, 0&, FILE_SHARE_READ, 0&, _
                      OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, 0&)
   
   If lFile > 0 Then
      FileExists = True
   End If
   
   Call CloseHandle(lFile)
   
errlog:
subErrLog ("modFileFuncs: DoesFileExist")
End Function


