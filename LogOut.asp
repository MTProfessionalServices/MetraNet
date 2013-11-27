<%
  On error resume next
  If Session("isAuthenticated") = true Then
   session.abandon
   response.end
  End If
%>