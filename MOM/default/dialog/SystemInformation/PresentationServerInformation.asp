<%
  response.expires = 0

'  On Error Resume Next
  
%>

<!-- #INCLUDE File="PrintPerfMonValue.asp" -->
<%'<!-- #INCLUDE File="../help/setcontext.asp" -->
%>

<html>

  <head>
    <title>Presentation Server - Statistics</title>
    <link rel="STYLESHEET" type="text/css" href="../../../default/localized/en-us/styles/styles.css">

  </head>

  <body>
    <br><br>
    <table border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="50">&nbsp;</td>
        <td><span class="clsInfoPageHeader">Information - Presentation Server</span><br><br></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>      
          <table border="1" cellspacing="0" cellpadding="2">
            <tr>
              <th colspan="2" class="clsTableHeader">Statistics</th>
            </tr>
<%
'            PrintPerfMonValue "Web Server Current Connections", "\Web Service(_Total)\Current Connections", "0", "INFINITY"
'            PrintPerfMonValue "Connention Attempts per sec.", "\Web Service(_Total)\Connection Attempts/sec", "0", "INFINITY"
            PrintPerfMonValue "ASP Requests per sec.", "\Active Server Pages\Requests/Sec", "0", "INFINITY"
            PrintPerfMonValue "ASP Sessions Timed Out", "\Active Server Pages\Sessions Timed Out", "0", "0"
            PrintPerfMonValue "Errors From Script Compilers", "\Active Server Pages\Errors From Script Compilers", "0", "0"
            PrintPerfMonValue "Errors During Script Runtime", "\Active Server Pages\Errors During Script Runtime", "0", "0"
            PrintPerfMonValue "Errors From ASP Preprocessor", "\Active Server Pages\Errors From ASP Preprocessor", "0", "0"
%>
          </table>
          <br><br>
          <a href="PresentationServerInformation.asp"><img border=0 alt="Refresh Page" src="../../../default/localized/en-us/images/refresh.gif"></a>
        </td>
      </tr>
    </table>
    <br>


<%
' cleanup
set objMonitor = nothing
%>
  </body>
</html>
