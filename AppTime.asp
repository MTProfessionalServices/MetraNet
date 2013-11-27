<%
on error resume next
If Request("tbAppTime") <> "" Then
  Dim objHC 
  Set objHC = server.CreateObject("MTHierarchyHelper.HierarchyHelper")
  Set objHC.actorYaac = Session("CSR_YAAC")
  objHC.SnapShot = CDate(Request("tbAppTime"))
  Set session("HIERARCHY_HELPER") = objHC
  Set session("SYSTEM_USER_HIERARCHY_HELPER") = objHC
  Session("isAuthenticated") = false
End IF

Response.Write "OK"
on error goto 0
%>