<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  AccountTemplateHelperTest.asp                                            '
'  Test of the Account Template Helper Functionality                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit

'''''''''''''''''''
Const TEMPLATE_XML_PATH = "c:\development\ui\server\accounttemplatehelper\AccountTemplates.xml"

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Global Variables                                                         '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim mobjATHelper                    'Account Template Helper object
Dim marrPropertyNames               'Name of properties

'Init property names
marrPropertyNames = Array("City", "State", "Zip", "NachoFactor")

Set mobjATHelper = server.CreateObject("ATHelper.Reader")

'Set the path to the templates
mobjATHelper.TemplatePath = TEMPLATE_XML_PATH

'Load the templates
Call mobjATHelper.LoadTemplates()

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ListTemplates                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ListTemplates()
  Dim objTemplate
  Dim objSubscription
  Dim i
  
  Dim strHTML
  
  for each objTemplate in mobjATHelper.Templates("219")
    strHTML = strHTML &  "    <br><br>" & vbNewline
    strHTML = strHTML &  "    <hr size=""1"">" & vbNewline
    strHTML = strHTML &  "    <b>" & objTemplate.Name & "</b>  (" & objTemplate.ParentID & ")<br>" & vbNewline
    strHTML = strHTML &  "    <i>" & objTemplate.Description & vbNewline
    strHTML = strHTML &  "    <br><br>" & vbNewline

    'Properties
    strHTML = strHTML &  "    <u>Properties:</u>" & vbNewline
    strHTML = strHTML &  "    <table border=""0"" cellspacing=""1"" cellpadding=""2"" bgcolor=""black"">" & vbNewline
    strHTML = strHTML &  "      <tr>" & vbNewline
    strHTML = strHTML &  "        <td bgcolor=""white""><b>Property Name</b></td>" & vbNewline
    strHTML = strHTML &  "        <td bgcolor=""white""><b>Template Value</b></td>" & vbNewline
    strHTML = strHTML &  "      </tr>" & vbNewline
    
    for i = 0 to UBound(marrPropertyNames)
      strHTML = strHTML &  "      <tr>" & vbNewline
      strHTML = strHTML &  "        <td  bgcolor=""white"" align=""right"">" & marrPropertyNames(i) & "</td>" & vbNewline
      strHTML = strHTML &  "        <td bgcolor=""white"" align=""left"">" & objTemplate.Properties(marrPropertyNames(i)) & "</td>" & vbNewline
      strHTML = strHTML &  "      </tr>" & vbNewline
    next
    
    strHTML = strHTML &  "    </table>" & vbNewline
    
    'Subscriptions
    strHTML = strHTML &  "    <br><br>" & vbNewline
    strHTML = strHTML &  "    <u>Subscriptions:</u>" & vbNewline
    strHTML = strHTML &  "    <table border=""0"" cellspacing=""1"" cellpadding=""2"" bgcolor=""black"">" & vbNewline
    strHTML = strHTML &  "      <tr>" & vbNewline
    strHTML = strHTML &  "        <td bgcolor=""white""><b>Product Offering GUID</b></td>" & vbNewline
    strHTML = strHTML &  "        <td bgcolor=""white""><b>Subscription Start</b></td>" & vbNewline
    strHTML = strHTML &  "        <td bgcolor=""white""><b>Subscription End</b></td>" & vbNewline
    strHTML = strHTML &  "        <td bgcolor=""white""><b>Group?</b></td>" & vbNewline
    strHTML = strHTML &  "      </tr>" & vbNewline
    
    for each objSubscription in objTemplate.Subscriptions
      strHTML = strHTML &  "      <tr>" & vbNewline
      strHTML = strHTML &  "        <td bgcolor=""white"">" & objSubscription.GUID & "</td>" & vbNewline
      strHTML = strHTML &  "        <td bgcolor=""white"">" & objSubscription.StartDate & "</td>" & vbNewline
      strHTML = strHTML &  "        <td bgcolor=""white"">" & objSubscription.EndDate & "</td>" & vbNewline
      strHTML = strHTML &  "        <td bgcolor=""white"">" & objSubscription.IsGroup & "</td>" & vbNewline
      strHTML = strHTML &  "      </tr>" & vbNewline
    next
    
    strHTML = strHTML &  "    </table>" & vbNewline
  next
  
  
  ListTemplates = strHTML
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<html>
  <head>
    <title>Account Template Helper Test Page</title>
  </head>
  
  <body>
    <h2>Account Templates</h2>
    <%=ListTemplates()%>
  </body>
</html>
