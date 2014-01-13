<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<%
On Error Resume Next
Session("Role").RemoveMember FrameWork.SessionContext, CLng(request.QueryString("id_acc"))
CheckAndWriteError
%>

<script>
 document.location.href = "RoleMemberSetup.asp?id=<%=Session("Role").id%>&RoleName=<%=server.URLEncode(Session("Role").name)%>";
</script>


