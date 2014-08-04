<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"          -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
 <HEAD>
  <LINK rel="STYLESHEET" type="text/css" href="/mom/default/localized/en-us/styles/Styles.css">  
  <title>Test Advanced User Setting</title>
 </HEAD>

<body>

<%
  dim sState
  dim sNextState
  if ucase(mdm_GetDictionary().Item("INTERVAL_MANAGEMENT_ADVANCED_USER"))="TRUE" then
    sState = "Normal"
    sNextState = "Advanced"
    mdm_GetDictionary().Add "INTERVAL_MANAGEMENT_ADVANCED_USER", "FALSE"
  else
    sState = "Advanced"
    sNextState= "Normal"
    mdm_GetDictionary().Add "INTERVAL_MANAGEMENT_ADVANCED_USER", "TRUE"
  end if
  
  response.write("The user is now considered <strong>" & sState & "</strong> for the remainder of this session.<BR>")
  'response.write("<a href='testResetAdvancedUser.asp'>Click Here To Change To '" & sNextState & "' User</a>")

%>
<div align=center><br>
<a href='testResetAdvancedUser.asp'>Click Here To Change To '<%=sNextState%>' User</a>
</div>
</body>
</html>
