Attribute VB_Name = "ParseConfig"
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

Public PK As Boolean, blMultiple As Boolean, blMultParents As Boolean
Public TablePrefix As String, ColumnPrefix As String, ParentService As String
Public PrimaryKey() As String, KeyLength() As String, KeyType() As String
Public fnameonly As String, fpathonly As String, CurrentFile As String
Public MultList As String
Public blLastOne As Boolean, blParent As Boolean, PKExists As Boolean
Public ServiceChild() As String
Public ServiceParent() As String
Public TableName() As String
Private sc As Integer
Private blServiceProps As Boolean, blServiceChild As Boolean
Public ConfigOnly As String
Public blControlCols As Boolean
Public blUseParent As Boolean

Public Sub FoundFiles()
On Error GoTo errlog

   Dim SCstring As String, PCstring As String
   Dim scnt As Integer, pcnt As Integer
   Dim response As Integer
   Dim badones As Integer
       
   With form1
     .txMSIX.Clear
     ConfigOnly = Right$(.txConfig, Len(.txConfig) - InStrRev(.txConfig, "\"))
     fpathonly = Left$(.txConfig, Len(.txConfig) - Len(ConfigOnly))
     
'     If UBound(ServiceChild) > 0 Then blMultiple = True
     
     .txMSIX.AddItem fpathonly + ServiceParent(0)
     
'     If blMultParents Then
         For pcnt = 0 To UBound(ServiceParent)
           If Len(ServiceParent(pcnt)) > 0 Then
              .txMSIX.AddItem fpathonly + ServiceParent(pcnt)
              PCstring = PCstring + vbNewLine + "   " + ServiceParent(pcnt)
           End If
         Next pcnt
'     End If
     
     If blMultiple Then
         For scnt = 0 To UBound(TableName)
           If Len(TableName(scnt)) > 0 Then
              .txMSIX.AddItem fpathonly + TableName(scnt)
              SCstring = SCstring + vbNewLine + "   " + TableName(scnt)
           End If
         Next scnt
     End If
     
     .txMSIX.ListIndex = 0
   
   End With
   
   If blMultiple Then   'multiple parents & children
      response = MsgBox("Configuration file " + ConfigOnly + " contains:" _
      + vbNewLine + vbNewLine + Trim$(Str$(pcnt)) + " parent services:" _
      + vbNewLine + PCstring + vbNewLine + vbNewLine + "and " _
      + Trim$(Str$(UBound(TableName))) + " child services:" + vbNewLine + SCstring + vbNewLine + vbNewLine _
      + "Click Yes to generate service definition tables for all services (RECOMMENDED)." + vbNewLine _
      + "Click No to select them individually from the MSIXDEF dropdown list.", 68)
   Else
      If blMultParents = False Then   'single parent
        MsgBox "Configuration file " + ConfigOnly + " contains a single service:" + vbNewLine _
        + vbNewLine + ServiceParent(0), vbInformation
        response = vbYes
      Else    'multiple parents, no children
        response = MsgBox("Configuration file " + ConfigOnly + " contains:" _
        + vbNewLine + vbNewLine + Trim$(Str$(pcnt)) + " parent services:" _
        + vbNewLine + PCstring + vbNewLine + vbNewLine _
        + "Click Yes to generate service definition tables for all services (RECOMMENDED)." + vbNewLine _
        + "Click No to select them individually from the MSIXDEF dropdown list.", 68)
      End If
   End If

   If response = vbYes Then
      ChDir fpathonly
      
      For pcnt = 0 To UBound(ServiceParent)
        If FileExists(ServiceParent(pcnt)) Then
           CurrentFile = ServiceParent(pcnt)
           blUseParent = True
           blParent = True
           MSIXParse (ServiceParent(pcnt))
           blParent = False
           MultList = MultList + vbNewLine + CurrentFile + ".sql"
        Else
           MsgBox "Parent Service " + ServiceParent(pcnt) + " cannot be found." + vbNewLine + vbNewLine _
           + "Copy " + ParentService + " to the same folder as " + ConfigOnly + ".", vbExclamation
           badones = badones + 1
        End If
      Next
      If blMultiple Then
         For scnt = 0 To UBound(ServiceChild)
            If Len(TableName(scnt)) = 0 Then GoTo nextone
            If InStr(TableName(scnt), ".msixdef") = 0 Then
              fnameonly = TableName(scnt) + ".msixdef"
            Else
              fnameonly = TableName(scnt)
            End If
            If FileExists(ServiceChild(scnt)) Then
               If scnt = UBound(TableName) Then blLastOne = True
               If InStr(TableName(scnt), ".msixdef") = 0 Then
                CurrentFile = TableName(scnt) + ".msixdef"
               Else
                CurrentFile = TableName(scnt)
               End If
               MSIXParse (ServiceChild(scnt))
               MultList = MultList + vbNewLine + CurrentFile + ".sql"
            Else
              MsgBox "Child Service " + ServiceChild(scnt) + " cannot be found." + vbNewLine + vbNewLine _
              + "Copy " + ServiceChild(scnt) + " to the same folder as " + ConfigOnly + ".", vbExclamation
              badones = badones + 1
            End If
nextone:
         Next scnt
      End If
   Else
      form1.ckAll.Value = 0
      GoTo errlog
   End If
   
   If blMultiple Then
      If UBound(ServiceChild) > 0 Then
         If badones < UBound(ServiceChild) + 2 Then
            MsgBox "Generated in: " + fpathonly + vbNewLine + MultList, vbInformation
   '      Else
   '         MsgBox "MSIXDEF files could not be found in " + fpathonly + vbNewLine + vbNewLine _
   '         + "Try browsing to the correct location of these files.", vbCritical
         End If
      End If
   End If
   
errlog:
   MultList = vbNullString
   blMultiple = False
   blMultParents = False
   blLastOne = False
   Erase ServiceChild()
   ParentService = vbNullString
   sc = 0
   If Err.Number > 0 Then
     MsgBox Err.Description
   End If
   subErrLog ("FoundFiles")
End Sub

Public Function ConfigParse(sConfigFile As String)
On Error GoTo errlog

   Dim oXMLNodes As Variant, t1XMLNodes As Variant, t2XMLNodes As Variant
   Dim sServiceName As String, scName As String, test As String
   Dim i As Integer, ip As Integer, ic As Integer, sc As Integer, exs As Integer
   Dim blnotvalid As Boolean
   Dim oNode As Variant, pNode As Variant
   Dim result As Boolean, result1 As Boolean, result2 As Boolean, result3 As Boolean
   Dim blnew As Boolean
   Dim upbound As Long
   
   If Not LoadXMLDoc(oXMLDoc, sConfigFile) Then
       blnotvalid = True
       GoTo errlog
   End If
   
'   ***************************** prefixes *****************************

   result = GetXMLTag(oXMLDoc, "xmlconfig/TablePrefix", TablePrefix)
   
   result = GetXMLTag(oXMLDoc, "xmlconfig/ColumnPrefix", ColumnPrefix)
      
'   ***************************** primary key *****************************
   
   If Not GetXMLNodes(oXMLDoc, "xmlconfig/Services/ServiceData/ServicePrimaryKey/ptype", oXMLNodes) Then
      blnotvalid = True
      GoTo errlog
   End If
   
   For i = 0 To (oXMLNodes.length - 1)

      Set oNode = oXMLNodes.Item(i)
      ReDim Preserve PrimaryKey(i)
      result = GetXMLTag(oNode, "dn", PrimaryKey(i))
      If result Then
         ReDim Preserve KeyType(i)
         result = GetXMLTag(oNode, "type", KeyType(i))
         ReDim Preserve KeyLength(i)
         result = GetXMLTag(oNode, "length", KeyLength(i))
      End If

   Next
   
'   ***************************** parent service *****************************
   
   result = GetXMLNodes(oXMLDoc, "xmlconfig/Services/ServiceData/ServiceProperties", oXMLNodes)
   
   blMultParents = False
   
   For ip = 0 To (oXMLNodes.length - 1)
      Set pNode = oXMLNodes.Item(ip)
      ReDim Preserve ServiceParent(ip)
      result = GetXMLTag(pNode, "servicedefinitionfile", ServiceParent(ip))
   Next
     
'   Call RemoveDupes(ServiceParent, upbound)
'   ReDim Preserve ServiceParent(upbound)
   
   If UBound(ServiceParent) = 0 Then
      blMultParents = False
   Else
      blMultParents = True
   End If
   
   Set oXMLNodes = Nothing
   
'   ***************************** child services/table names *****************************
' use tablenames in case they're different than service names, but need service names for msixdef files!
' !!! these can be at two levels, under ServiceChild and under ServiceChild/ServiceData !!!
      
   result = GetXMLNodes(oXMLDoc, "xmlconfig/Services/ServiceData/ServiceChild", oXMLNodes)
   
   blMultiple = False
   result1 = True
   
   i = 0
   Do Until result1 = False And result2 = False And result3 = False
   
      Set oNode = oXMLNodes.Item(i)
      ReDim Preserve ServiceChild(i)
      ReDim Preserve TableName(i)
      
      result1 = GetXMLNodes(oXMLDoc, "xmlconfig/Services/ServiceData/ServiceChild", oXMLNodes)
      result1 = GetXMLTag(oNode, "ServiceProperties/servicedefinitionfile", ServiceChild(i))
      
      result1 = GetXMLTag(oNode, "ServiceProperties/servicedefinitionfile", TableName(i))
      
      result2 = GetXMLNodes(oXMLDoc, "xmlconfig/Services/ServiceData/ServiceChild", oXMLNodes)
      result2 = GetXMLTag(oNode, "TableName", TableName(i))
      
      If Len(TableName(i)) = 0 Then
        result3 = GetXMLNodes(oXMLDoc, "xmlconfig/Services/ServiceData", oXMLNodes)
        result3 = GetXMLTag(oNode, "TableName", TableName(i))
      End If
      
'      Debug.Print TableName(i)
      i = i + 1
   Loop
   
   If UBound(ServiceChild) > 0 Then
      blMultiple = True
   End If
   
   Set oXMLNodes = Nothing
   Set t1XMLNodes = Nothing
   Set t2XMLNodes = Nothing

   
'   If UBound(TableName) = 0 Then    'cannot remove dupe services if there are different table names
'      Call RemoveDupes(ServiceChild, upbound)
'      ReDim Preserve ServiceChild(upbound)
'   End If
     
'    Call RemoveDupes(TableName, upbound)
'    ReDim Preserve TableName(upbound)
'    ReDim Preserve ServiceChild(UBound(TableName))
         
   With form1
      If blMultiple Then
         .ckAll.Enabled = True
         .ckAll.Value = 1
      Else
         .ckAll.Enabled = False
         .ckAll.Value = 0
      End If
   End With
   
'   **************************************************************************

   ConfigParse = True
errlog:
 If blnotvalid Then     'or UBound(ServiceParent) = 0
    MsgBox "This is not a valid MetraConnect-DB configuration file." + vbNewLine + vbNewLine _
           + sConfigFile + "", vbCritical
    ConfigParse = False
 End If
' MsgBox Err.Description
 subErrLog "ConfigParse"
End Function

Public Sub ControlColumns()
On Error GoTo errlog

   Dim oXMLNodes
   Dim oNode As Variant
   Dim blnotvalid As Boolean, result As Boolean, blReqd As Boolean
   Dim stext As String, sType As String, sLength As String, sReqd As String
   
   If Not LoadXMLDoc(oXMLDoc, ConfigOnly) Then
       blnotvalid = True
       GoTo errlog
   End If

   blControlCols = True
'   ***************************** control columns *****************************
   
   If Not GetXMLNodes(oXMLDoc, "xmlconfig/Services/ServiceData", oXMLNodes) Then
      blnotvalid = True
      GoTo errlog
   End If
   
   Set oNode = oXMLNodes.Item(0)
   
   result = GetXMLTag(oNode, "ServiceCriteriaField/CriteriaField/ptype/dn", stext)
      
   If result Then
   
      result = GetXMLTag(oNode, "ServiceCriteriaField/CriteriaField/ptype/type", sType)

      result = GetXMLTag(oNode, "ServiceCriteriaField/CriteriaField/ptype/length", sLength)
      
      result = GetXMLTag(oNode, "ServiceCriteriaField/CriteriaField/ptype/required", sReqd)
      If LCase$(sReqd) = "y" Then blReqd = True
      
      Call subWriteSQL(stext, sLength, sType, blReqd)
      
   End If
   
   result = GetXMLTag(oNode, "BatchIdentification/BatchID/ptype/dn", stext)
   
   If result Then
   
      result = GetXMLTag(oNode, "BatchIdentification/BatchID/ptype/type", sType)

      result = GetXMLTag(oNode, "BatchIdentification/BatchID/ptype/length", sLength)
      
      result = GetXMLTag(oNode, "BatchIdentification/BatchID/ptype/required", sReqd)
      If LCase$(sReqd) = "y" Then blReqd = True
      
      Call subWriteSQL(stext, sLength, sType, blReqd)
   End If
   
   result = GetXMLTag(oNode, "BatchIdentification/BatchNamespace/ptype/dn", stext)
   
   If result Then
   
      result = GetXMLTag(oNode, "BatchIdentification/BatchNamespace/ptype/type", sType)

      result = GetXMLTag(oNode, "BatchIdentification/BatchNamespace/ptype/length", sLength)
      
      result = GetXMLTag(oNode, "BatchIdentification/BatchNamespace/ptype/required", sReqd)
      If LCase$(sReqd) = "y" Then blReqd = True
      
      Call subWriteSQL(stext, sLength, sType, blReqd)
   End If
   
   result = GetXMLTag(oNode, "SpecialFieldsToUpdate/SentTime/ptype/dn", stext)
   
   If result Then
   
      result = GetXMLTag(oNode, "SpecialFieldsToUpdate/SentTime/ptype/type", sType)

      result = GetXMLTag(oNode, "SpecialFieldsToUpdate/SentTime/ptype/length", sLength)
      
      Call subWriteSQL(stext, sLength, sType, False)
   End If
   
   result = GetXMLTag(oNode, "SpecialFieldsToUpdate/ErrorMesg/ptype/dn", stext)
   
   If result Then
   
      result = GetXMLTag(oNode, "SpecialFieldsToUpdate/ErrorMesg/ptype/type", sType)

      result = GetXMLTag(oNode, "SpecialFieldsToUpdate/ErrorMesg/ptype/length", sLength)
      
      result = GetXMLTag(oNode, "SpecialFieldsToUpdate/ErrorMesg/ptype/required", sReqd)
      If LCase$(sReqd) = "y" Then blReqd = True
      
      Call subWriteSQL(stext, sLength, sType, blReqd)
   End If

errlog:
  blControlCols = False
  subErrLog "ControlColumns"
End Sub

Private Sub RemoveDupes(ByRef StringArray() As String, ByRef upbound As Long)
    Dim LowBound As Long
    Dim TempArray() As String, Cur As Long
    Dim A As Long, B As Long
    
    'check for empty array
    If (Not StringArray) = True Then Exit Sub
    
    'we need these often
    LowBound = LBound(StringArray)
    upbound = UBound(StringArray)
    
    'reserve check buffer
    ReDim TempArray(LowBound To upbound)
    
    'set first item
    Cur = LowBound
    TempArray(Cur) = StringArray(LowBound)
    'loop through all items
    For A = LowBound + 1 To upbound
        'make a comparison against all items
        For B = LowBound To Cur
            'if is a duplicate, exit array
            If LenB(TempArray(B)) = LenB(StringArray(A)) Then
                If InStrB(1, StringArray(A), TempArray(B), vbBinaryCompare) = 1 Then Exit For
            End If
        Next B
        'check if the loop was exited: add new item to check buffer if not
        If B > Cur Then Cur = B: TempArray(Cur) = StringArray(A)
    Next A
    
    'fix size
    ReDim Preserve TempArray(LowBound To Cur)
    'copy
    StringArray = TempArray
    upbound = Cur
End Sub




