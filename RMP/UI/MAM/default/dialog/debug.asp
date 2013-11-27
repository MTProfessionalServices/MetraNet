<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/mamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 

<b>Kona Debug Info</b><hr size=1>
<%

response.Write "<b>Subscriber</b><hr size=1>"
response.Write MAM().Subscriber.ToString(TRUE)
response.Write "<br>"

response.Write "<b>CSR</b><hr size=1>"
response.Write MAM().CSR.ToString(TRUE)
response.Write "<br>"

response.Write "<b>TempAccount</b><hr size=1>"
response.Write MAM().TempAccount.ToString(TRUE)
response.Write "<br>"


%>
