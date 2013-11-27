<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<%
On Error Resume Next

'
' CODE NOT USED - Fred!
'

'WE DO NOT RUN THIS CODE... YOU MUST ASSIGN A PAYER TO SOMEONE ELSE....
'If UCase(Request.QueryString("Type")) = "SINGLE" Then
'	  Dim rowset
'    Set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
'    rowset.Init "queries\audit" 'dummy
'    rowset.SetQueryString "delete from t_payment_redirection where id_payee = " & Request.QueryString("id") 
'    rowset.xecute
'  	CheckAndWriteError
'Else'
'
'End IF		
%>

<script>
 document.location.href = "PayerSetup.asp"
</script>


