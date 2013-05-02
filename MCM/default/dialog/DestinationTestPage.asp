<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<html>
<head>
  <LINK rel="STYLESHEET" type="text/css" href="<%=SafeForHtmlAttr(FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH"))%>/styles/styles.css">
</head>
<body>
<div class="CaptionBar">Destination Test Page</div>
<hr size=1>
<%
'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
'Added output encoding for protect from HTML and JavaScript injection
'Response.write "Test QueryString:" & Request.QueryString()
Response.write "Test QueryString:" & SafeOutQueryStringForHtml()
%>
</body>
</html>
