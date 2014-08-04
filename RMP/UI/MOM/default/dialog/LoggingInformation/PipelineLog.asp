<!-- #INCLUDE FILE="../../../auth.asp" --> 
<!-- #INCLUDE File="../help/setcontext.asp" --> 
<%
 ' Always force page refresh
  response.expires = 0

  On Error Resume Next
'  Dim myHTML     ' as string
'	Dim objEditXML ' as object
  Dim objAudit   ' as object
'	Dim bError	   ' as boolean
'	Dim strError   ' as string
	
'	bError = false
	
'  Set objEditXML = Server.CreateObject("EditXML.Render")
	Set objAudit = Server.CreateObject("Logging.Log")
		
	' Initialize the EditXML object	
	'objEditXML.DoInit()
  objAudit.DoInit("/MTAdmin/AdminLogging/Logging.xml")
  
   ' If Err Then
    '    bError = true
		'strError = "Unable to load xml file..."
	'end if
%>		

<html>
  <head>
    <title>Logging - Pipeline</title>
    <link rel="STYLESHEET" type="text/css" href="../../../default/localized/en-us/styles/styles.css">

<!--    <script language="JavaScript1.2" src="../Shared/edit.js">
    </script>

    <script langauge="JavaScript1.2">
      SetCurrentVisibleTag('div1List1');
    </script> -->
    
  </head>
  <body>
  	<br><br>
    <table>
      <tr>
        <td width="50">&nbsp;</td>
        <td><span class="clsInfoPageHeader">Logging - Pipeline</span><br><br></td>
      </tr>
      <tr>
        <td width="50">&nbsp;</td>
        <td>

<%
' Start the logger
'objAudit.StartLogger

' strEditImage = "../images/edit.gif"
' objEditXML.GetEditableGroup "clsTableTextOdd", "clsTableTextEven", true, cstr(strEditImage), 1
' objEditXML.GetGroupEditDivTags 1


%>
        <table border="1" cellspacing="0" cellpadding="2">
          <tr>
            <th colspan="2" class="clsTableHeader">General Status</th>
          </tr>
          <tr>
            <td class="clsTableTextEvenLabel">System Log File Size (Bytes)</td>
            <td class="clsTableTextEven"><%= FormatNumber(objAudit.GetFileSize,0,,,true) %></td>
          </tr>
          <tr>
            <td class="clsTableTextOddLabel">Last Modified</td>
            <td class="clsTableTextOdd"><%= objAudit.GetFileDate %></td>
          </tr>
        </table>
        <p>
<%
if objEditXML.GetNode("//xmlconfig/logging_config/logsocket") <> "0" then
%>
        <table border="1" cellspacing="0" cellpadding="2">
          <tr>
            <th colspan="2" class="clsTableHeader">Current System Log</th>
          </tr>
          <tr>
            <td class="clsTableTextEvenLabel">
            	<applet
                codebase=/mom/default/dialog/LoggingInformation
            		code=LogReader.class
          	  	name=LogReader
            		width=600
      	  	    height=400  VIEWASTEXT>
            		<param name=port value="9001">
          	  	<param name=form_background value="FFFFFF">
            		<param name=form_foreground value="000000">
             		<param name=text_background value="FFFFFF">
      	      	<param name=text_foreground value="000000">
          	  	<param name=font value="Arial">
            		<param name=font_size value="10">
            		<param name=list_size value="200">
            	</applet>
            </td>
          </tr>
        </table>
        <br><br>
<%
end if

if "File does not exist." <> objAudit.GetFileSize then
%>
        <a href="LoggingInformation/download.asp?Filename=<%= objAudit.GetFileName %>">Download Log</a>
<% 
end if 
%>
        </td>
      </tr>
    </table>
  </body>
</html>
