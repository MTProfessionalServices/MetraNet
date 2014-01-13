<!-- #INCLUDE FILE="auth.asp"         -->
<!-- #INCLUDE FILE="default/lib/MomLibrary.asp"  -->
<%
Sub Logout()

   mdm_GarbageCollector

   session.abandon
   response.write "<script>"
   response.write "	top.location =  '" & application("startPage") & "';"
   response.write "</script>"
   response.end
end sub

%>

<html>
<body>
Logging out...
<% Logout %>
</body>
</html>
