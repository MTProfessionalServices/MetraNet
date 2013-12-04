<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
response.buffer = false
%>
<html>
  <head>
    <link rel="stylesheet" href="<%=Application("APP_HTTP_PATH")%>/default/localized/en-us/styles/styles.css">
  </head>
  
  <body style="margin:5;">
    <div id="loading" name="loading" style="display: block; font-family:Courier;">
    Loading...
    </div>
<%
'View All Rates Test
Dim mobjXML   
Dim mobjXSL
Dim mstrHTML
Dim mobjViewAllRates
Dim mstrXML
Dim mstrPathXSL
Dim Timeout

' Save timeout value and increase it for this page
TimeOut = Server.ScriptTimeout 
Server.ScriptTimeout = 60 * 5    ' set to 5 minutes 

' set help file
Session("HelpContext") = "ViewAllRates.hlp.htm"
  
set mobjViewAllRates = server.CreateObject("viewallrates.rates")
Set mobjXML = server.CreateObject("Microsoft.XMLDOM")
Set mobjXSL = server.CreateObject("Microsoft.XMLDOM")

mstrXML = mobjViewAllRates.GetRatesForAccount("" & MAM().Subscriber("PRICELIST"), mam_GetSubscriberAccountID(), TRUE, TRUE, TRUE, TRUE,MAM().CSR("TimeZoneId")) ' Account ID, Localized?, Progress?, Calendar, LocalTime?, timezoneID

'Uncomment these lines to see the XML coming back...
'response.write "<form><textarea cols='180' rows='40'>" & mstrXML & "</textarea></form>"
'response.end

'Replacing tags by appropriate entries on the dictionary. I wish there was a more efficient way to do this

mstrXML = Replace(mstrXML, "[TEXT_NULL_END_DATE_TYPE]", mam_GetDictionary("TEXT_NULL_END_DATE_TYPE"))
mstrXML = Replace(mstrXML, "[TEXT_NULL_START_DATE_TYPE]", mam_GetDictionary("TEXT_NULL_START_DATE_TYPE"))
mstrXML = Replace(mstrXML, "[TEXT_ABSOLUTE_DATE_TYPE]", mam_GetDictionary("TEXT_ABSOLUTE_DATE_TYPE"))
mstrXML = Replace(mstrXML, "[TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE]", mam_GetDictionary("TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE"))
mstrXML = Replace(mstrXML, "[TEXT_BILLINGCYCLE_DATE_TYPE]", mam_GetDictionary("TEXT_BILLINGCYCLE_DATE_TYPE"))
mstrXML = Replace(mstrXML, "[TEXT_RATES_COLUMN_START_DATE]", mam_GetDictionary("TEXT_RATES_COLUMN_START_DATE"))
mstrXML = Replace(mstrXML, "[TEXT_RATES_COLUMN_END_DATE]", mam_GetDictionary("TEXT_RATES_COLUMN_END_DATE"))
mstrXML = Replace(mstrXML, "[TEXT_PERSONAL_RATE]",  mam_GetDictionary("TEXT_PERSONAL_PRICELIST"))
mstrXML = Replace(mstrXML, "[TEXT_RATES_CALENDAR_NOT_CONFIGURED]", mam_GetDictionary("TEXT_MPTE_NO_CALENDAR_CONFIGURED"))

mstrPathXSL = server.MapPath(Application("APP_HTTP_PATH") & "\default\dialog\rates.xsl")

Call mobjXML.LoadXML(mstrXML)
Call mobjXSL.Load(mstrPathXSL)

mstrHTML = mobjXML.TransformNode(mobjXSL)

%>
    <script language="JavaScript1.2">
  		document.getElementById("loading").style.display = "none";
    </script>  
<%
  If Len(mstrHTML) Then
    response.write mstrHTML
  Else
    response.write mam_GetDictionary("TEXT_NO_RATES_FOUND")
  End If
  
' Set timeout back  
Server.ScriptTimeout = TimeOut   
%>  
  
  </body>
</html>
