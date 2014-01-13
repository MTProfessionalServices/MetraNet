<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<%
On Error Resume Next

Call Session("ActiveYAAC").RemovedOwnedFolderById(CLng(request.QueryString("ID")))
CheckAndWriteError

%>

<script>
 document.location.href =  '<%=mam_GetDictionary("FOLDER_OWNER_SETUP_DIALOG") & "?MODE=" & Session("FOLDER_OWNER_MODE")%>';
</script>


