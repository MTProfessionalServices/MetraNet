<%
  response.expires = 0

  On Error Resume Next
  
  '------------------------------------------------------------------------------------------  
 sub GetServiceState(strService, strDescription)
  Dim objPipelineMonitor ' as object
  Dim strState   ' as string
  
  ' create service monitoring object
  set objPipelineMonitor = CreateObject("ServiceMonitor.Monitor")
  
  ' get service state
  strState = objPipelineMonitor.GetServiceState(strService)

  if strState <> "STARTED" then
    strState = "<font color=""red"">" & strState & "</font>"
  end if  

  response.write "      <tr>" & vbNewline  
  if bOdd = true then  
    response.write "        <td class = ""clsTableTextOddLabel"">" & strDescription & "</td>" & vbNewline
    response.write "        <td class = ""clsTableTextOdd"">" & strState & "</td>" & vbNewline
  else
    response.write "        <td class = ""clsTableTextEvenLabel"">" & strDescription & "</td>" & vbNewline
    response.write "        <td class = ""clsTableTextEven"">" & strState & "</td>" & vbNewline
  end if
  response.write "      </tr>" & vbNewline  

  bOdd = not bOdd
    
  ' cleanup
  set objPipelineMonitor = nothing
end sub
  
%>
<!-- #INCLUDE File="PrintPerfMonValue.asp" -->
<!-- #INCLUDE File="../help/setcontext.asp" -->

<html>

  <head>
    <title>Metering Server - Statistics</title>
    <link rel="STYLESHEET" type="text/css" href="../../../default/localized/en-us/styles/styles.css">
  </head>

  <body>
    <br><br>
    <table border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="50">&nbsp;</td>
        <td><span class="clsInfoPageHeader">Information - Metering Server</span><br><br></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>      
          <table border="1" cellspacing="0" cellpadding="2">
            <tr>
              <th colspan="2" class="clsTableHeader">Statistics</th>
            </tr>
      <%
      GetServiceState "MSMQ", "MSMQ"
      PrintPerfMonValue "MSMQ Journal Queue Size (Bytes)", "\MSMQ Queue(Computer Queues/" & mstrServerName & "\routingqueue)\Bytes in Journal Queue", "0", "INFINITY"
      PrintPerfMonValue "MSMQ Queue Size (Bytes)", "\MSMQ Queue(Computer Queues/" & mstrServerName & "\routingqueue)\Bytes in Queue", "0", "INFINITY"
      PrintPerfMonValue "MSMQ Number of Active Sessions", "\MSMQ Service\Sessions", "0", "INFINITY"
      PrintPerfMonValue "MSMQ Total Messages in all Queues", "\MSMQ Service\Total messages in all queues", "0", "INFINITY"
      %>
          </table>
          <br><br>
          <a href="MeteringServerInformation.asp"><img border=0 alt="Refresh Page" src="../../../default/localized/en-us/images/refresh.gif"></a>
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
