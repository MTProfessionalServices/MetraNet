<!-- #INCLUDE FILE="../../auth.asp" -->
<%
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Load Accounts For Pull List From File</title>
  <LINK rel="STYLESHEET" type="text/css" href="/mam/default/localized/en-us/styles/MAMMenu.css">  
  <LINK rel="STYLESHEET" type="text/css" href="/mom/default/localized/en-us/styles/Styles.css">  
  <script language="JavaScript1.2" src="/mpte/shared/browsercheck.js"></script>    
  <!-- xscript language="JavaScript1.2" src="/mpte/shared/PopupModalDialog.js"></script>-->
</head>
     
<body> 
<table border="0" cellpadding="1" cellspacing="0" width="100%"><tr><td Class='CaptionBar' nowrap>
Create Pull List From File
</td></tr></table>
<%
dim sErrorMessage
sErrorMessage = Request("ImportError")

if len(sErrorMessage)>0 then
    'response.write "<div style='padding:10px'>"
    response.write "<TABLE style=""BACKGROUND-COLOR: WhiteSmoke;margin:10px;"" width=""100%"" BORDER=""1"" BORDERCOLOR=""Black"" CELLSPACING=""0"" CELLPADDING=""0"">" & vbNewline
    response.write "  <TR>" & vbNewline
    response.write "    <TD>" & vbNewline
    response.write "      <TABLE style=""BACKGROUND-COLOR: WhiteSmoke"" BORDER=""0"">" & vbNewline
    response.write "        <TR>" & vbNewline
    response.write "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""" & "/mcm/default/localized/us" & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
    response.write "          <TD VALIGN=""top""><IMG SRC=""" & "/mcm/default/localized/us" &  "/images/icons/warningSmall.gif"" align=""center"" BORDER=""0"" >&nbsp;</TD>" & vbNewline
    response.write "          <TD class=""clsWizardErrorText"">"
    response.write "<b>Unable To Import Pull List Accounts File</b><BR>"
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
 
<span align='center'>
<form action="BillingGroupPullListFromFileUpload.asp" method="post" enctype="multipart/form-data" name="RuleSetExportImportFile" id="RuleSetExportImportFile">
<input type='hidden' name='ImportExportAction' value='import'>
<table>
<tr><br><b>Location of file with account list to use for the pull list:</b><br>
<input type="file" name="upfile" size="80" ID="File1">
</td></tr>
<tr><td>The file 
format is a UTF-8 encoded text file that specifies either account IDs separated 
by returns or username comma namespace pairs separated by returns. </td>
<td></tr>
</table>
<BR><BR>
  <input type="button" class="clsButtonXLarge" name="Load Accounts From This File" value="Load Account List From File" onClick="window.document.RuleSetExportImportFile.submit();">&nbsp;&nbsp;
  <input type="button" class="clsButtonMedium" name="Cancel" value="Cancel" onClick="window.close();">
</span>
</body>
</html>

