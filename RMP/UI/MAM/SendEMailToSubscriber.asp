<%
Option Explicit
%>
<!-- #INCLUDE FILE="auth.asp" -->
<!-- #INCLUDE FILE="default/lib/mamLibrary.asp"          -->

  <script language="javascript">
  window.open("<%="mailto:" & MAM().Subscriber("email")%>");
  </script>

