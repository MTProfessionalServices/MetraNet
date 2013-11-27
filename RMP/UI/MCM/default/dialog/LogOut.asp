<%
Option Explicit

session.abandon

%>
<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<html>
  <body>
   <center><b>Goodbye.</b>
   <br><br>
   Click <a href="<%=SafeForHtmlAttr(request("urlredirect"))%>">here</a> to login again.</center>
  </body>
</html>
