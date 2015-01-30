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
'On Error Resume Next
Dim rs
Dim YAAC
Dim strIDS
Dim i
Dim strID
Dim skipAhead

strID = request.QueryString("ID")

Set YAAC = FrameWork.AccountCatalog.GetAccount(CLng(strID), mam_ConvertToSysDate(mam_GetHierarchyTime()))
Set rs = YAAC.GetAncestorMgr().HierarchySlice(CLng(strID), mam_ConvertToSysDate(mam_GetHierarchyTime())).GetAncestorList()
CheckAndWriteError

If rs.recordcount <> 0 Then

 skipAhead = 0

 ' we may need to skip to Session("HierarchyStartNode")
  If Not IsEmpty(Session("HierarchyStartNode")) Then
    If CStr(Session("HierarchyStartNode")) <> CStr("1") Then
       For i=0 to rs.recordcount -1
         If CStr(rs.value("ID_ANCESTOR")) = CStr(Session("HierarchyStartNode")) Then
           skipAhead = i
           Exit For
         End If
         rs.MoveNext
       Next
    End If
  End If  

  If CStr(strID) = CStr(Session("HierarchyStartNode")) Then
    strIDS =  strID & ","
  Else
    For i=skipAhead to rs.recordcount -1
      strIDS = strIDS & CStr(rs.value("ID_ANCESTOR")) & ","
      rs.MoveNext
    Next
  End If

  If Len(strIDS) Then
    strIDS = Left(strIDS, Len(strIDS) -1)
    response.write " IDS: " & strIDS    
    
    If UCase(request.QueryString("IsSystemUser")) = "TRUE" Then
    %>
    <script language="JavaScript1.2">
      parent.showUserHierarchy();
      ensureUserHierarchy();
      
      function ensureUserHierarchy()
      {
        if((parent.hierarchyUser.document.readyState == "complete"))
        {
          parent.hierarchyUser.FindAccountInHierarchy('<%=strIDS%>', '<%=strID%>', '<%=YAAC.CorporateAccountID%>');
        }
        else
        {
          setTimeout("ensureUserHierarchy()",100);  
        }
      }     
    </script>

    <%
    Else
    %>

    <script language="JavaScript1.2">
      parent.showHierarchy();
      ensureHierarchy();

      function ensureHierarchy()
      {
        if((parent.hierarchy.document.readyState == "complete"))
        {
          parent.hierarchy.FindAccountInHierarchy('<%=strIDS%>', '<%=strID%>', '<%=YAAC.CorporateAccountID%>');    
        }
        else
        {
          setTimeout("ensureHierarchy()",100);  
        }
      }
    </script>
    <%
    End If
  End If
Else
  %>
  <script language="JavaScript1.2">
    alert("Account not found in current hierarchy.");
  </script>
  <%
End If

%>

</body>
</html>
