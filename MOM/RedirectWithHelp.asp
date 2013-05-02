<%
 Session("HelpContext") = Request.QueryString("HelpPage") 
 
 response.redirect Request.QueryString("URL") & "?" & "TransferLocation=" & Request.QueryString("TransferLocation")_
                                              & "&" & "Schema=" & Request.QueryString("Schema")_
                                              & "&" & "xmlFile=" & Request.QueryString("xmlFile")_
                                              & "&" & "CheckLogOn=" & Request.QueryString("CheckLogOn")_

%>