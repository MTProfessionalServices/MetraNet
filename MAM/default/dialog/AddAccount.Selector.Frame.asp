<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
	<title>Select Account Type</title>
</head>

  <frameset id="fmeSelector" name="fmeSelector" rows="27,*" framespacing="0" frameborder="no">
    <frame id="fmeSelect" name="fmeSelect" src="AddAccount.Selector.asp?mdmReload=<%=Server.URLEncode(Request("mdmReload"))%>&AccountType=<%=Server.URLEncode(Request("AccountType"))%>&AncestorID=<%=Server.URLEncode(Request("AncestorID"))%>" frameborder="No" scrolling="NO" marginwidth="0" marginheight="0" framespacing="0" NORESIZE>
    <frame id="fmeAddPage" name="fmeAddPage" src="blank.htm" frameborder="No" border="0" scrolling="Auto" marginwidth="10" marginheight="10" framespacing="0">
  </frameset>

</html>
