<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<%
If IsEmpty(Session("GUIDE_TEXT")) Then
  Session("GUIDE_TEXT") = "No errors."
End IF
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Error Resolution Roadmap</title>
<LINK rel='STYLESHEET' type='text/css' href='/mam/default/localized/en-us/styles/Grid.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mam/default/localized/en-us/styles/MAMMenu.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mam/default/localized/en-us/styles/RuleEditor_styles.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mam/default/localized/en-us/styles/styles.css'>
<LINK rel='STYLESHEET' type='text/css' href='/mam/default/localized/en-us/styles/tab_styles.css'>	
</head>

<body topmargin="0" rightmargin="0" leftmargin="0">

	<div style="padding:10px">
  
		<div class="clsGuide">
			<table width="100%">
		  	<tr>
  			  <td><font size="2"><%=SafeForHtml(Session("GUIDE_TEXT"))%></font></td>
				 </tr>
			</table>
  	</div>
  </div>	

</body>
</html>
