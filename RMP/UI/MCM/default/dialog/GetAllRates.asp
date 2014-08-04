<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<%
Response.Buffer = False
%>
<html>
  <head>
    <link rel="stylesheet" href="<%=Application("APP_HTTP_PATH")%>/default/localized/en-us/styles/styles.css">
  </head>
  
  <body leftmargin="5" rightmargin="5">
    <div id="loading" name="loading" style="display: block; font-family:Courier;">
    Loading...
    </div>
<%
'View All System Rates
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

Set mobjViewAllRates = server.CreateObject("viewallrates.rates")
Set mobjXML = server.CreateObject("Microsoft.XMLDOM")
Set mobjXSL = server.CreateObject("Microsoft.XMLDOM")

mstrXML = mobjViewAllRates.GetAllRatesByProductOffering(TRUE, TRUE, TRUE, FALSE)' Localized?, Progress?, Calendar?, LocalTime?, timezoneID

'Replacing tags by appropriate entries on the dictionary. I wish there was a more efficient way to do this

mstrXML = Replace(mstrXML, "[TEXT_NULL_END_DATE_TYPE]", FrameWork.GetDictionary("TEXT_NULL_END_DATE_TYPE"))
mstrXML = Replace(mstrXML, "[TEXT_NULL_START_DATE_TYPE]", FrameWork.GetDictionary("TEXT_NULL_START_DATE_TYPE"))
mstrXML = Replace(mstrXML, "[TEXT_ABSOLUTE_DATE_TYPE]", FrameWork.GetDictionary("TEXT_ABSOLUTE_DATE_TYPE"))
mstrXML = Replace(mstrXML, "[TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE]", FrameWork.GetDictionary("TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE"))
mstrXML = Replace(mstrXML, "[TEXT_BILLINGCYCLE_DATE_TYPE]", FrameWork.GetDictionary("TEXT_BILLINGCYCLE_DATE_TYPE"))
mstrXML = Replace(mstrXML, "[TEXT_RATES_COLUMN_START_DATE]", FrameWork.GetDictionary("TEXT_RATES_COLUMN_START_DATE"))
mstrXML = Replace(mstrXML, "[TEXT_RATES_COLUMN_END_DATE]", FrameWork.GetDictionary("TEXT_RATES_COLUMN_END_DATE"))
mstrXML = Replace(mstrXML, "[TEXT_RATES_CALENDAR_NOT_CONFIGURED]", FrameWork.GetDictionary("TEXT_MPTE_NO_CALENDAR_CONFIGURED"))

'Uncomment these lines to see the XML coming back...
'response.write Server.HTMLEncode(mstrXML)
'response.end

mstrPathXSL = server.MapPath(Application("APP_HTTP_PATH") & "/default/dialog/GetRates.xsl")

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
    response.write FrameWork.GetDictionary("TEXT_NO_RATES_FOUND")
  End If

' Set timeout back  
Server.ScriptTimeout = TimeOut     
%>  
  
  </body>
</html>
