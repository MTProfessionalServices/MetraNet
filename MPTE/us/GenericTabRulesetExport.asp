<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Here we use functions to do a binary read of the Form
' variables.  We have to do this because the data may be
' longer than the length supported in Request().  So, instead
' of using the Request() syntax in this file we use
' FormFields.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Session.CodePage = 65001
Response.CharSet = "utf-8"

Dim FormFields
Set FormFields = GetForm
%>
<!-- #INCLUDE VIRTUAL = "/mpte/auth.asp" -->
<!-- #INCLUDE VIRTUAL = "/mpte/shared/CheckConnected.asp" -->
<%

Response.Buffer = False

'Response.Write("Preparing to export file<BR>")

dim sBuffer
dim sErrorMessage
  
if FormFields("ImportExportAction")="" then
  '// Get the ruleset xml from the ruleset currently in session
  dim objRuleSet
  set objRuleSet = session("RuleSet")
  
  dim objConfigPropSet
  if IsObject(objRuleSet) then
    'response.write("We HAVE the rule set<BR>")
    set objConfigPropSet = objRuleSet.WriteToSet
    if IsObject(objConfigPropSet) then
      'response.write("We HAVE the config prop set<BR>")
      sBuffer = objConfigPropSet.WriteToBuffer
     end if
  else
    'response.write("We DO NOT have the the rule set<BR>")
  end if
else
  '// Get the ruleset xml from the ruleset currently on the form
  sBuffer = Trim(FormFields("RulesXML"))
end if

'// See if we want to download the file
if UCase(Request.QueryString("ExportDownload")) = "TRUE" then
    dim strFilename
    dim nParameterTableID
    dim objMTProductCatalog
    dim objParamTable

    nParameterTableID = session("CurrMTRateSchedule").Properties("ParameterTableID").value
    Set objMTProductCatalog = GetProductCatalogObject
    Set objParamTable = objMTProductCatalog.GetParamTableDefinition(nParameterTableID)
    
    strFilename = "export_" & Replace(objParamTable.name, ".", "_") & ".txt"
    strFilename = Replace(strFilename, "/", "_")
    strFilename = Replace(strFilename, "\", "_")

  	response.contentType = "application/save"
    response.addheader "Content-Disposition", "filename=" & strFilename
    response.write(sBuffer)
    response.end
else

if lcase(FormFields("ImportExportAction"))="import" then
	
  dim objTempRuleSet
  set objTempRuleSet = session("CurrMTRateSchedule").RuleSet 'CreateObject("MTRuleSet.MTRuleSet.1")
  
  dim objTempConfig
  dim objTempConfigPropSet
  set objTempConfig = CreateObject("MetraTech.MTConfig.1")
  
  on error resume next
  set objTempConfigPropSet = objTempConfig.ReadConfigurationFromString(sBuffer, false)
  
  if err then
    sErrorMessage = "Unable to read configuration from input. Error returned is:<BR>[" & Hex(err.number) & "] " & err.description
  else
    objTempRuleSet.ReadFromSet objTempConfigPropSet
    if err then
      sErrorMessage = "Unable to create ruleset from propset object. Error returned is:<BR>[" & Hex(err.number) & "] " & err.description
    else
      '//Success
      set session("RuleSet")=objTempRuleSet
      session("UnsavedChanges") = true
      '//This refresh will also close our popup window
			response.write("<script LANGUAGE=""JavaScript1.2"">if(window.opener)window.opener.location=""gotoRuleEditor.asp?AfterEdit=TRUE&page=1"";</script>")
      response.end
    end if
  end if
 
  
  
end if

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET1")%>">
  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET2")%>">
  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET3")%>">
  <script language="JavaScript1.2" src="/mpte/shared/browsercheck.js"></script>    
  <script language="JavaScript1.2" src="/mpte/shared/PopupModalDialog.js"></script>

<script language="javascript">
  function RunExport()
  {
    document.all._export.src='<%=FormFields("SCRIPT_NAME") & "?loadpage=GENERICTABRULESETEXPORT.ASP"%>&ExportDownload=TRUE';
  }
</script>
</head>
     
<body onBlur="javascript:LostFocus();" onFocus="javascript:GotFocus('window');" onLoad="javascript:SizeWindow();"> 
<table border="0" cellpadding="1" cellspacing="0" width="100%"><tr><td Class='CaptionBar' nowrap>
XML Import/Export Of Current Rule Set
</td></tr></table>

<%
if len(sErrorMessage)>0 then
    response.write "<TABLE style=""BACKGROUND-COLOR: #FFCC00"" width=""100%"" BORDER=""1"" BORDERCOLOR=""Black"" CELLSPACING=""0"" CELLPADDING=""0"">" & vbNewline
    response.write "  <TR>" & vbNewline
    response.write "    <TD>" & vbNewline
    response.write "      <TABLE style=""BACKGROUND-COLOR: #FFCC00"" BORDER=""0"">" & vbNewline
    response.write "        <TR>" & vbNewline
    response.write "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""" & "/mcm/default/localized/us" & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
    response.write "          <TD VALIGN=""top""><IMG SRC=""" & "/mcm/default/localized/us" &  "/images/icons/warningSmall.gif"" align=""center"" BORDER=""0"" >&nbsp;</TD>" & vbNewline
    response.write "          <TD class=""clsWizardErrorText"">"
    response.write sErrorMessage
    
    response.write "</TD>" & vbNewline
    response.write "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""" & "/mcm/default/localized/us" & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
    response.write "        </TR>" & vbNewline
    response.write "      </TABLE>" & vbNewline
    response.write "    </TD>" & vbNewline
    response.write "  </TR>" & vbNewline
    response.write "</TABLE>"
end if
%>
<%
if len(sBuffer)>4194304 then
    response.write "<BR><TABLE style=""BACKGROUND-COLOR: #FFCC00"" width=""100%"" BORDER=""1"" BORDERCOLOR=""Black"" CELLSPACING=""0"" CELLPADDING=""0"">" & vbNewline
    response.write "  <TR>" & vbNewline
    response.write "    <TD>" & vbNewline
    response.write "      <TABLE style=""BACKGROUND-COLOR: #efefef"" BORDER=""0"">" & vbNewline
    response.write "        <TR>" & vbNewline
    response.write "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""" & "/mcm/default/localized/us" & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
    response.write "          <TD VALIGN=""top""><IMG SRC=""" & "/mcm/default/localized/us" &  "/images/icons/warningSmall.gif"" align=""center"" BORDER=""0"" >&nbsp;</TD>" & vbNewline
    response.write "          <TD class=""clsWizardErrorText"">"
    response.write "Because of the size of this ruleset (" & len(sBuffer) & " bytes) and the configuration on the maximum response accepted by the server (AspMaxRequestEntityAllowed), you may not be able to import this ruleset back into the system. You may wish to use the Excel Export/Import to make your changes."
    
    response.write "</TD>" & vbNewline
    response.write "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""" & "/mcm/default/localized/us" & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
    response.write "        </TR>" & vbNewline
    response.write "      </TABLE>" & vbNewline
    response.write "    </TD>" & vbNewline
    response.write "  </TR>" & vbNewline
    response.write "</TABLE>"
end if
%> 
<DIV align='center'>
<form action="<%=FormFields("SCRIPT_NAME") & "?loadpage=GENERICTABRULESETEXPORT.ASP"%>" method="post" name="RuleSetExportImportFile" id="RuleSetExportImportFile">
<input type='hidden' name='ImportExportAction' value='import'>
<textarea cols='100' rows='35' name='RulesXML'>
<%
        ' Stream out the export buffer
         Dim outStream 
         Set outStream = Server.CreateObject("ADODB.Stream") 
         outStream.Open 
         outStream.Type = 2 'adTypeText 
		 outStream.Charset = "utf-8"
         Response.Codepage = "1252"
         outStream.WriteText sBuffer
         outStream.Position = 0 
         While Not outStream.EOS 
           Response.Write outStream.ReadText(1024) 
         wend 
         outStream.Close
     
%>
</textarea>
<BR>
<script>
//From https (secure) connection, iframe must have a src element to avoid getting "Some items are not secure message" in IE 6 and above
function nullSrc() {  return ''; }
</script>
<iframe id="_export" name="_export" style="display:none;" src='javascript:top.nullSrc();'></iframe>
		           <input type="button" class="clsButtonBlueLarge" name="butAddRule" value="Download As File"" onClick="RunExport();">                     
<% if UCase(session("RATES_EDITMODE")) = "TRUE" then %>               
		           <input type="button" class="clsButtonBlueMedium" name="Import" value="Import" onClick="javascript:document.RuleSetExportImportFile.ImportExportAction.value='import'; document.RuleSetExportImportFile.submit();">
<% end if %>               
		           <!--<input type="button" class="clsButtonBlueMedium" name="Close" value="Close" onClick="javascript:window.close();">-->
 <br>
 </form>             <BR><BR>
      		      <input type="button" class="clsButtonSmall" name="Close" value="Close" onClick="javascript:window.close();">
</div>
</body>
</html>
<%
end if

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Support functions for large form data
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function GetForm
  'Dictionary which will store source fields.
  Dim FormFields
  Set FormFields = CreateObject("Scripting.Dictionary")

  'If there are some POST source data
  If Request.Totalbytes>0 And _
    Request.ServerVariables("HTTP_CONTENT_TYPE") = _
    "application/x-www-form-urlencoded" Then

    on error resume next
    'Read the data
    Dim SourceData
    SourceData = Request.BinaryRead(Request.Totalbytes)

  if err then
    sErrorMessage = "Unable to read the buffer containing the uploaded file. This can possibly be caused by the incoming request buffer being too small for the size of the file. The size of the current request buffer is " & Request.TotalBytes & " bytes. Please have your system administrator check to make sure the IIS configuration setting AspMaxRequestEntityAllowed is at least this size."
    response.write sErrorMessage
    response.end
  end if

    'Convert source binary data To a string
    SourceData = RSBinaryToString(SourceData)

    'Form fields are separated by "&"
    SourceData = split(SourceData, "&")
    Dim Field, FieldName, FieldContents
  
    For Each Field In SourceData
      'Field name And contents is separated by "="
      Field = split(Field, "=")
      FieldName = URLDecode(Field(0))
      FieldContents = URLDecode(Field(1))
      'Add field To the dictionary
      FormFields.Add FieldName, FieldContents
    Next
  end if'Request.Totalbytes>0
  Set GetForm = FormFields
End Function

Function URLDecode(ByVal What)
'URL decode Function
'2001 Antonin Foller, PSTRUH Software, http://www.pstruh.cz
  Dim Pos, pPos

  'replace + To Space
  What = Replace(What, "+", " ")

  on error resume Next
  Dim Stream: Set Stream = CreateObject("ADODB.Stream")
  Stream.Charset = "utf-8"
  If err = 0 Then 'URLDecode using ADODB.Stream, If possible
    on error goto 0
    Stream.Type = 2 'String
    Stream.Open

    'replace all %XX To character
    Pos = InStr(1, What, "%")
    pPos = 1
    Do While Pos > 0
      Stream.WriteText Mid(What, pPos, Pos - pPos) + _
        Chr(CLng("&H" & Mid(What, Pos + 1, 2)))
      pPos = Pos + 3
      Pos = InStr(pPos, What, "%")
    Loop
    Stream.WriteText Mid(What, pPos)

    'Read the text stream
    Stream.Position = 0
    URLDecode = Stream.ReadText

    'Free resources
    Stream.Close
  Else 'URL decode using string concentation
    on error goto 0
    'UfUf, this is a little slow method. 
    'Do Not use it For data length over 100k
    Pos = InStr(1, What, "%")
    Do While Pos>0 
      What = Left(What, Pos-1) + _
        Chr(Clng("&H" & Mid(What, Pos+1, 2))) + _
        Mid(What, Pos+3)
      Pos = InStr(Pos+1, What, "%")
    Loop
    URLDecode = What
  End If
End Function


Function RSBinaryToString(Binary)
  'Antonin Foller, http://www.pstruh.cz
  'RSBinaryToString converts binary data (VT_UI1 | VT_ARRAY)
  'to a string (BSTR) using ADO recordset
  
  Dim RS, LBinary
  Dim outStream   
  Dim outString
  
  Const adLongVarChar = 201
  Set RS = CreateObject("ADODB.Recordset")
  LBinary = LenB(Binary)
  
  If LBinary>0 Then
    RS.Fields.Append "mBinary", adLongVarChar, LBinary
    RS.Open
    RS.AddNew
      RS("mBinary").AppendChunk Binary 
    RS.Update
    

	  'read out data through a stream
    Set outStream = Server.CreateObject("ADODB.Stream") 
    outStream.Open 
    outStream.Type = 2 'adTypeText 
	  outStream.Charset = "utf-8"
    Response.Codepage = "1252"
    outStream.WriteText RS("mBinary")
    outStream.Position = 0 
    While Not outStream.EOS 
      outString = outString & outStream.ReadText(1024) 
    Wend 
    outStream.Close

    
    RSBinaryToString = outString
  Else
    RSBinaryToString = ""
  End If
End Function
%>
