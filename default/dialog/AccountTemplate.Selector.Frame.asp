<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
	<title>Select Account Type</title>
</head>

  <frameset id="fmeSelector" name="fmeSelector" rows="<%=GetFrameSize()%>,*" framespacing="0" frameborder="no">
    <frame id="fmeSelect" name="fmeSelect" src="AccountTemplate.Selector.asp?Types=<%=Server.URLEncode(Request("Types"))%>&mdmCurrentTab=<%=Server.URLEncode(Request("mdmCurrentTab"))%>&mdmReload=TRUE" frameborder="No" scrolling="auto" marginwidth="0" marginheight="0" framespacing="0" NORESIZE>
    <frame id="fmeTemplatePage" name="fmeTemplatePage" src="blank.htm" frameborder="No" border="0" scrolling="Auto" marginwidth="10" marginheight="10" framespacing="0">
  </frameset>

</html>
<%
PUBLIC FUNCTION GetFrameSize()
  If Len(Request.QueryString("Types")) > 0 Then
    GetFrameSize = "82"
  Else
    GetFrameSize = "52"
  End If
END FUNCTION
%>