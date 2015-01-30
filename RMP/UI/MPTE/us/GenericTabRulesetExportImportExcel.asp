  <!-- #INCLUDE VIRTUAL = "/mpte/shared/CheckConnected.asp" -->
<%

dim bDebug
bDebug = false

Response.Buffer = false

Session.CodePage = 65001
Response.CharSet = "utf-8"

'Response.Write("Preparing to export file<BR>")

dim sBuffer
dim sErrorMessage

if request("ImportError")<>"" then
  sErrorMessage = request("ImportError")
end if

if request("ImportExportAction")="Export" then
  '// Get the ruleset xml from the ruleset currently in session
  dim objRuleSet
  set objRuleSet = session("RuleSet")
  
  dim objRulesetConverter
  set objRulesetConverter = CreateObject("MetraTech.UI.Utility.RuleSetImportExport")
  
  
  sBuffer="Rudi was here"
  
    dim strFilename
    dim nParameterTableID
    dim objMTProductCatalog
    dim objParamTable

    nParameterTableID = session("CurrMTRateSchedule").Properties("ParameterTableID").value
    Set objMTProductCatalog = GetProductCatalogObject
    Set objParamTable = objMTProductCatalog.GetParamTableDefinition(nParameterTableID)
    
    'strFilename = "export_" & Replace(objParamTable.name, ".", "_") & ".xml"
    strFilename = Replace(objParamTable.name, ".", "_") & ".xml"
    strFilename = Replace(strFilename, "/", "_")
    strFilename = Replace(strFilename, "\", "_")

    dim sExcelBuffer,arrErrors
    '//ESR-5932
    response.Clear
    set arrErrors=objRulesetConverter.ExportToExcel(objParamTable.name, session("RuleSet"), sExcelBuffer)
    
    if arrErrors.Count > 0 then
      '//There were errors
      response.write("Errors exporting ruleset<BR>")
      dim i
      for i=0 to arrErrors.Count-1
       response.write( arrErrors(i) & "<BR>")
      next
      response.end
    end if

    if bDebug then
        response.write("Filename[" & strFilename & "]<BR>")
        response.write("<textarea cols='80' rows='100'>" & sExcelBuffer & "</textarea>")
        response.end
    else 
  	    'response.contentType = "application/save"
        'response.addheader "Content-Disposition", "filename=" & strFilename 
        response.AddHeader "Content-Type", "application/x-msdownload" 
        response.AddHeader "Content-Disposition","attachment;filename=" & strFilename

        'response.write(sExcelBuffer)

        ' Stream out the export buffer
         Dim outStream 
         Set outStream = Server.CreateObject("ADODB.Stream") 
         outStream.Open 
         outStream.Type = 2 'adTypeText 
         outStream.WriteText sExcelBuffer
         outStream.Position = 0 
         While Not outStream.EOS 
           Response.Write outStream.ReadText(1024) 
         wend 
         outStream.Close
     
         response.end
    end if
end if

'// See if we want to download the file
if request("ExportDownload")<>"" then
   
    'dim strFilename
    'dim nParameterTableID
    'dim objMTProductCatalog
    'dim objParamTable

    nParameterTableID = session("CurrMTRateSchedule").Properties("ParameterTableID").value
    Set objMTProductCatalog = GetProductCatalogObject
    Set objParamTable = objMTProductCatalog.GetParamTableDefinition(nParameterTableID)
    
    strFilename = "export_" & Replace(objParamTable.name, ".", "_") & ".txt"
    strFilename = Replace(strFilename, "/", "_")
    strFilename = Replace(strFilename, "\", "_")

  	response.contentType = "application/save"
    response.addheader "Content-Disposition", "filename=" & strFilename 
    response.write(sBuffer)
else


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title><%=FrameWork.GetDictionary("TEXT_IMPORT_FROM_EXCEL")%></title>
  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET1")%>">
  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET2")%>">
  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET3")%>">
  <script language="JavaScript1.2" src="/mpte/shared/browsercheck.js"></script>    
  <script language="JavaScript1.2" src="/mpte/shared/PopupModalDialog.js"></script>
</head>
     
<body onBlur="javascript:LostFocus();" onFocus="javascript:GotFocus('window');" onLoad="javascript:SizeWindow();"> 
<table border="0" cellpadding="1" cellspacing="0" width="100%"><tr><td Class='CaptionBar' nowrap>
<%=FrameWork.GetDictionary("TEXT_IMPORT_FROM_EXCEL")%>
</td></tr></table>
<%
if len(sErrorMessage)>0 then
    'response.write "<div style='padding:10px'>"
    response.write "<TABLE style=""BACKGROUND-COLOR: #FFCC00;margin:10px;"" width=""100%"" BORDER=""1"" BORDERCOLOR=""Black"" CELLSPACING=""0"" CELLPADDING=""0"">" & vbNewline
    response.write "  <TR>" & vbNewline
    response.write "    <TD>" & vbNewline
    response.write "      <TABLE style=""BACKGROUND-COLOR: #FFCC00"" BORDER=""0"">" & vbNewline
    response.write "        <TR>" & vbNewline
    response.write "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""" & "/mcm/default/localized/us" & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
    response.write "          <TD VALIGN=""top""><IMG SRC=""" & "/mcm/default/localized/us" &  "/images/icons/warningSmall.gif"" align=""center"" BORDER=""0"" >&nbsp;</TD>" & vbNewline
    response.write "          <TD class=""clsWizardErrorText"">"
    response.write "<b>Unable To Import Excel XML File</b><BR>"
    response.write sErrorMessage
    response.write "</TD>" & vbNewline
    response.write "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""" & "/mcm/default/localized/us" & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
    response.write "        </TR>" & vbNewline
    response.write "      </TABLE>" & vbNewline
    response.write "    </TD>" & vbNewline
    response.write "  </TR>" & vbNewline
    response.write "</TABLE>"
    'response.write "</div>"
end if


%>
 
<DIV align='center'>
<form action="<%=request("SCRIPT_NAME") & "?loadpage=GENERICTABRULESETEXPORTIMPORTEXCELUPLOAD.ASP"%>" method="post" enctype="multipart/form-data" name="RuleSetExportImportFile" id="RuleSetExportImportFile">
<input type='hidden' name='ImportExportAction' value='import'>

<FORM METHOD=POST ENCTYPE="multipart/form-data" ACTION="">
<table>
<tr><td><b><%=FrameWork.GetDictionary("TEXT_LOCATION_OF_EXCEL")%>:</b></td></tr>
<tr><td><input type="file" name="upfile" size="80"></td></tr>
</table>
<BR><BR>
  <input type="button" class="clsButtonXLarge" name="Import This Excel File" value="Import This Excel File" onClick="window.document.RuleSetExportImportFile.submit();">&nbsp;&nbsp;
  <input type="button" class="clsButtonMedium" name="Cancel" value="Cancel" onClick="window.close();">
</div>
</body>
</html>
<%
end if
%>
