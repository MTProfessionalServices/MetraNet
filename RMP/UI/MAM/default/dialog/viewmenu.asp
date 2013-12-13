<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE FILE="../../auth.asp" --> 
<html>
  <head>
    <link rel="stylesheet" href="/mam/default/localized/en-us/styles/styles.css">
  </head>
  
  <body style="margin:5;">
      <table style="border:solid black 1px;" bgcolor="white">
      <tr>
         <td class="TableHeader">Menu</td>  
         <td class="TableHeader">Account Type</td>              
         <td class="TableHeader">Capability</td>
      </tr>     
        
<%
'View Menu capabilities
Dim mobjXML   
Dim mobjXSL
Dim mstrHTML

Set mobjXML = server.CreateObject("Msxml2.DOMDocument.4.0")
Set mobjXSL = server.CreateObject("Msxml2.DOMDocument.4.0")

mobjXML.async = false
mobjXSL.async = false

Call mobjXSL.Load(server.MapPath("/mam" & "\default\dialog\" & "menu.xsl"))

%>
  <tr>
    <td colspan="2" class="sectionCaptionBar">Core Subscriber Menu</td>     
  </tr>     
<%
Call mobjXML.Load(server.MapPath("/mam" & "\default\menu\" & "CoreSubscriberMenu.xml") )
mstrHTML = mobjXML.TransformNode(mobjXSL)
response.write mstrHTML

%>
  <tr>
    <td colspan="2" class="sectionCaptionBar">System User Menu</td>     
  </tr>     
<%

Call mobjXML.Load(server.MapPath("/mam" & "\default\menu\" & "SystemUserMenu.xml") )
mstrHTML = mobjXML.TransformNode(mobjXSL)
response.write mstrHTML

%>
  <tr>
    <td colspan="2" class="sectionCaptionBar">Actions Menu</td>     
  </tr>     
<%

Call mobjXML.Load(server.MapPath("/mam" & "\default\menu\" & "ActionsMenu.xml") )
mstrHTML = mobjXML.TransformNode(mobjXSL)
response.write mstrHTML

%>
  
  </table>
  
  </body>
</html>
