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

Public pk As Boolean, blMultiple As Boolean
Public TablePrefix As String, ColumnPrefix As String, ParentService As String
Public ServiceName As String, LogFileName As String
Public PrimaryKey() As String, KeyLength() As String, KeyType() As String, KeyRequired() As String
Public fnameonly As String, fpathonly As String, CurrentFile As String
Public MultList As String, sSync As String, sSets As String
Public blLastOne As Boolean, blParent As Boolean, PKExists As Boolean
Public ChildMSIX() As String, ChildSync() As String, ChildSets() As String, ChildName() As String
Public DBType As String, DBServer As String, DBName As String, DBUser As String, DBPswd As String
Private sc As Integer
Private blServiceProps As Boolean, blServiceChild As Boolean
Public ConfigOnly As String
Public blControlCols As Boolean
Public blUseParent As Boolean
Public oNode As Object

Public Function ConfigParse(sConfigFile As String)
On Error GoTo errlog

   Dim oXMLNodes
   Dim sServiceName
   Dim i
   Dim blnotvalid As Boolean
   Dim result As Boolean
   
   If Not LoadXMLDoc(oXMLDoc, sConfigFile) Then
       blnotvalid = True
       GoTo errlog
   End If
     
   
'   ***************************** parent service *****************************
   
   If Not GetXMLTag(oXMLDoc, "xmlconfig/Services/ServiceData/ServiceName", ServiceName) Then
      blnotvalid = True
      GoTo errlog       'don't proceed if missing
   End If
   
   result = GetXMLTag(oXMLDoc, "xmlconfig/Services/ServiceData/ServiceProperties/servicedefinitionfile", ParentService)
   result = GetXMLTag(oXMLDoc, "xmlconfig/Services/ServiceData/SynchronousService", sSync)
   result = GetXMLTag(oXMLDoc, "xmlconfig/Services/ServiceData/MaxSessionSet", sSets)
   
'   ***************************** child services *****************************

   result = GetXMLNodes(oXMLDoc, "xmlconfig/Services/ServiceData/ServiceChild", oXMLNodes)
   
   blMultiple = False
   
   For i = 0 To (oXMLNodes.Length - 1)
      Set oNode = oXMLNodes.Item(i)
      ReDim Preserve ChildMSIX(i)
      ReDim Preserve ChildName(i)
      ReDim Preserve ChildSync(i)
      ReDim Preserve ChildSets(i)
      result = GetXMLTag(oNode, "ServiceProperties/servicedefinitionfile", ChildMSIX(i))
      result = GetXMLTag(oNode, "ServiceName", ChildName(i))
      result = GetXMLTag(oNode, "SynchronousService", ChildSync(i))
      result = GetXMLTag(oNode, "MaxSessionSet", ChildSets(i))
      blMultiple = True
   Next i
   
'   ***************************** data source *****************************
   
   result = GetXMLTag(oXMLDoc, "xmlconfig/DatabaseConfig/DatabaseType", DBType)
   result = GetXMLTag(oXMLDoc, "xmlconfig/DatabaseConfig/DataServer", DBServer)
   result = GetXMLTag(oXMLDoc, "xmlconfig/DatabaseConfig/DataBase", DBName)
   result = GetXMLTag(oXMLDoc, "xmlconfig/DatabaseConfig/UserName", DBUser)
   result = GetXMLTag(oXMLDoc, "xmlconfig/DatabaseConfig/Password", DBPswd)
   

'   ***************************** prefixes *****************************

   result = GetXMLTag(oXMLDoc, "xmlconfig/TablePrefix", TablePrefix)
   
   result = GetXMLTag(oXMLDoc, "xmlconfig/ColumnPrefix", ColumnPrefix)
      
'   ***************************** primary keys *****************************
   
   
   If Not GetXMLNodes(oXMLDoc, "xmlconfig/Services/ServiceData/ServicePrimaryKey/ptype", oXMLNodes) Then
      blnotvalid = True
      GoTo errlog
   End If
   
   For i = 0 To (oXMLNodes.Length - 1)

      Set oNode = oXMLNodes.Item(i)
      ReDim Preserve PrimaryKey(i)
      result = GetXMLTag(oNode, "dn", PrimaryKey(i))
      If result Then
         ReDim Preserve KeyType(i)
         result = GetXMLTag(oNode, "type", KeyType(i))
         ReDim Preserve KeyLength(i)
         result = GetXMLTag(oNode, "length", KeyLength(i))
         ReDim Preserve KeyRequired(i)
         result = GetXMLTag(oNode, "required", KeyRequired(i))
      End If

   Next
   
'   ***************************** logging file  *****************************
   
   result = GetXMLTag(oXMLDoc, "xmlconfig/loggingConfig/logFileName", LogFileName)
   
   
   ConfigParse = True
   
errlog:

 If blnotvalid Or Len(ParentService) = 0 Then
    MsgBox "This is not a valid MetraConnect-DB configuration file." + vbNewLine + vbNewLine _
           + sConfigFile + "", vbCritical
    ConfigParse = False
 End If
    
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
      
'      Call subWriteSQL(stext, sLength, sType, blReqd)
      
   End If
   
   result = GetXMLTag(oNode, "BatchIdentification/BatchID/ptype/dn", stext)
   
   If result Then
   
      result = GetXMLTag(oNode, "BatchIdentification/BatchID/ptype/type", sType)

      result = GetXMLTag(oNode, "BatchIdentification/BatchID/ptype/length", sLength)
      
      result = GetXMLTag(oNode, "BatchIdentification/BatchID/ptype/required", sReqd)
      If LCase$(sReqd) = "y" Then blReqd = True
      
'      Call subWriteSQL(stext, sLength, sType, blReqd)
   End If
   
   result = GetXMLTag(oNode, "BatchIdentification/BatchNamespace/ptype/dn", stext)
   
   If result Then
   
      result = GetXMLTag(oNode, "BatchIdentification/BatchNamespace/ptype/type", sType)

      result = GetXMLTag(oNode, "BatchIdentification/BatchNamespace/ptype/length", sLength)
      
      result = GetXMLTag(oNode, "BatchIdentification/BatchNamespace/ptype/required", sReqd)
      If LCase$(sReqd) = "y" Then blReqd = True
      
'      Call subWriteSQL(stext, sLength, sType, blReqd)
   End If
   
   result = GetXMLTag(oNode, "SpecialFieldsToUpdate/SentTime/ptype/dn", stext)
   
   If result Then
   
      result = GetXMLTag(oNode, "SpecialFieldsToUpdate/SentTime/ptype/type", sType)

      result = GetXMLTag(oNode, "SpecialFieldsToUpdate/SentTime/ptype/length", sLength)
      
'      Call subWriteSQL(stext, sLength, sType, False)
   End If
   
   result = GetXMLTag(oNode, "SpecialFieldsToUpdate/ErrorMesg/ptype/dn", stext)
   
   If result Then
   
      result = GetXMLTag(oNode, "SpecialFieldsToUpdate/ErrorMesg/ptype/type", sType)

      result = GetXMLTag(oNode, "SpecialFieldsToUpdate/ErrorMesg/ptype/length", sLength)
      
      result = GetXMLTag(oNode, "SpecialFieldsToUpdate/ErrorMesg/ptype/required", sReqd)
      If LCase$(sReqd) = "y" Then blReqd = True
      
'      Call subWriteSQL(stext, sLength, sType, blReqd)
   End If

errlog:
  blControlCols = False
  subErrLog "ControlColumns"
End Sub

