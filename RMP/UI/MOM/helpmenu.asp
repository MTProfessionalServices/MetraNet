<!-- #INCLUDE FILE="auth.asp" -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>HelpMenu.asp</title>
  <link rel="STYLESHEET" type="text/css" href="<%=Session("LocalizedPath")%>/styles/styles.css">
<%
on error resume next

	Dim mstrHelpURL
	Dim mstrHelpIndexURL 
	Dim objBC	
	Dim fso

	Set objBC = Server.CreateObject("MSWC.BrowserType")
	
	mstrHelpURL = Request.QueryString("HelpURL")
  mstrHelpFile = server.MapPath(Request.QueryString("HelpURL"))
  
	Set fso = server.CreateObject("Scripting.FileSystemObject")
	
  ' if the stream is nothing then let's set a default help file
	if not fso.FileExists(mstrHelpFile) then
    mstrHelpURL = Session("LocalizedPath") & "/help/welcome.htm"
  end if
%>

  <script language="Javascript">
    /////////////////////////////////////////////////////////////
    // Wait for frames to finish loading, then set help url
    function LoadHelpFrame() {
      var bClear = false;
      
      if(parent.fmeHelpHTML.document.readyState == 'complete') {
        if(parent.fmeHelpHTML.BODY.document.readyState == 'complete') {
          //if(parent.fmeHelpHTML.BODY.bsscright.document.readyState == 'complete') {
            parent.fmeHelpHTML.BODY.location.href = '<%=mstrHelpURL%>';
            bClear = true;
          //}
        }
      }
      
      if(!bClear) {
       setTimeout('LoadHelpFrame()', 200);
     }
    }
  </script>
</head>

<body onload="LoadHelpFrame();">
<%'	response.write session("HelpContext") %>
	<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width="140" class="clsHelpHeaderTitle"><img src="<%=Session("LocalizedPath")%>images/top_logo.jpg" border=0 alt=""></td>
           	<TD BACKGROUND="<%=Session("LocalizedPath")%>images/top_fill.jpg" ALIGN="left" WIDTH="284"><IMG WIDTH="284" HEIGHT="47" BORDER="0" ALT="" SRC="<%=Session("LocalizedPath")%>images/top_left.jpg"></TD>
          	<TD BACKGROUND="<%=Session("LocalizedPath")%>images/top_fill.jpg"><IMG HEIGHT="47" BORDER="0" ALT="" SRC="<%=Session("LocalizedPath")%>images/spacer.gif"></TD>            
					</tr>
          <tr>
             <TD COLSPAN="5" ALIGN="left" BACKGROUND="<%=Session("LocalizedPath")%>images/shadow.jpg"><IMG HEIGHT="4" BORDER="0" ALT="" SRC="<%=Session("LocalizedPath")%>images/spacer.gif"></TD>
          </tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</html>
