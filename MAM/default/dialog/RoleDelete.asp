<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<HTML>
<HEAD>
 <LINK Localized='TRUE' rel="STYLESHEET" type="text/css" href="/mam/default/localized/en-us/styles/styles.css">  
 </HEAD>
<body>
<%
On Error Resume Next

Call FrameWork.Policy.RemoveRole(FrameWork.SessionContext, CLng(request.QueryString("RoleID")))
CheckAndWriteError 
%>


<script>
 document.location.href = '<%=mam_GetDictionary("MANAGE_ROLES_DIALOG")%>';
</script>
</body>
</html>

