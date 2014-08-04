<%
  response.expires = 0

  On Error Resume Next

' --------------------------------------------------------------------------------------  
sub GetPipelineState()
  Dim objPipelineMonitor ' as object
  Dim strState           ' as string
  Dim strClass
  
  ' create service monitoring object
  set objPipelineMonitor = CreateObject("ServiceMonitor.Monitor")
 
  ' get service state
  strState = objPipelineMonitor.GetServiceState("Pipeline")


  if strState <> "STARTED" then
    strClass = "clsPerfmonAlert"
  else      
    strClass = "clsPerfmonRow"
  end if  
  
  response.write "      <tr>" & vbNewline
  
  if bOdd = true then  
    response.write "        <td class = ""clsTableTextOddLabel"">Pipeline Service State</td>" & vbNewline
    response.write "        <td class = """ & strClass & "Odd"">" & strState & "</td>" & vbNewline
  else
    response.write "        <td class = ""clsTableTextEvenLabel"">Pipeline Service State</td>" & vbNewline
    response.write "        <td class = """ & strClass & "Even"">" & strState & "</td>" & vbNewline
  end if

  response.write "      </tr>"  

  ' cleanup
  set objPipelineMonitor = nothing
end sub

%>
<!-- #INCLUDE File="PrintPerfMonValue.asp" -->
<!-- #INCLUDE File="../help/setcontext.asp" --> 
<html>
  <head>
    <title>Pipeline Server - Statistics</title>
    <link rel="STYLESHEET" type="text/css" href="../../../default/localized/en-us/styles/styles.css">
  </head>

  <body>
    <br>
    <br>

    <table border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="50">&nbsp;</td>
        <td><span class="clsInfoPageHeader">Information - Pipeline Server</span><br><br></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>
          <table border="1" cellspacing="0" cellpadding="2">
            <tr>
              <th colspan="2" class="clsTableHeader">Statistics</th>
            </tr>
<%      GetPipelineState
        bOdd = false
'        PrintPerfMonValue "% Capacity", "\MetraTech Pipeline\% Capacity", "0", "INFINITY"
'        PrintPerfMonValue "Sessions", "\MetraTech Pipeline\Sessions", "0", "INFINITY"       
'        PrintPerfMonValue "Sessions per sec.", "\MetraTech Pipeline\Sessions/sec", "0", "INFINITY"              
%>
          </table>
          <br><br>
          <a href="PipelineServerInformation.asp"><img border=0 alt="Refresh Page" src="../../../default/localized/en-us/images/refresh.gif"></a>
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
