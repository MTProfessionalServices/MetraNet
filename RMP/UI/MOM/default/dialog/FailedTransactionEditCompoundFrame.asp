<!-- #INCLUDE FILE="../../auth.asp" --> 
<html>
<%
dim idFailure
if request("IdFailure")="" then
  response.write("Error: IdFailure was not passed")
  response.end
else
  idFailure=request("IdFailure")
end if

'6.4
dim idFailureCompoundSessionIdQueryString
if request("FailureCompoundSessionId")="" then
  idFailureCompoundSessionIdQueryString = ""
else
  idFailureCompoundSessionIdQueryString="&FailureCompoundSessionId=" & request("FailureCompoundSessionId")
end if

%>
<HEAD>
<TITLE>Edit Failed Transaction</TITLE>
</HEAD>
<frameset rows="370,*">
    <frame name="EditParent" src="FailedTransactionEditCompoundParent.asp?IdFailure=<%=idFailure%><%=idFailureCompoundSessionIdQueryString%>" marginwidth="10" marginheight="10" scrolling="auto" frameborder="0">
    <frame name="EditChildList" src="blank.htm" marginwidth="10" marginheight="10" scrolling="auto" frameborder="0">
</frameset>
</html>
