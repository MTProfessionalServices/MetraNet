<%
	Option Explicit
	
  response.expires = 0

'------------------------------------------------------------------------------------------  
 sub GetServiceState(strService, strDescription)
  Dim objPipelineMonitor ' as object
  Dim strState   ' as string
  
  ' create service monitoring object
  set objPipelineMonitor = CreateObject("ServiceMonitor.Monitor")
  
  ' get service state
  strState = objPipelineMonitor.GetServiceState(strService)

  if strState <> "STARTED" then
    strState = "<span class=""clsPerfmonAlert"">" & strState & "</span>"
  end if  
  
  if bOdd = true then  
    response.write "<tr><td class = ""clsTableTextOddLabel"">" & strDescription & "</td><td class = ""clsTableTextOdd"">" & strState & "</td></tr>"
  else
    response.write "<tr><td class = ""clsTableTextEvenLabel"">" & strDescription & "</td><td class = ""clsTableTextEven"">" & strState & "</td></tr>"
  end if
  
  bOdd = not bOdd
    
  ' cleanup
  set objPipelineMonitor = nothing
end sub
'--------------------------------------------------------------------------------------------
%>


<!-- #INCLUDE File="PrintPerfMonValue.asp" -->  
<!-- #INCLUDE File="../Help/setcontext.asp" -->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
  <head>
    <title>General Information - Statistics</title>
    <link rel="STYLESHEET" type="text/css" href="../styles/styles.css">
  </head>

  <body>
    <br><br>
    <table border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="50">&nbsp;</td>
        <td><span class="clsInfoPageHeader">Information - System</span><br><br></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>
          <table border="1" cellspacing="0" cellpadding="2">
            <tr>
              <th colspan="2" class="clsTableHeader">Statistics</th>
            </tr>
<%
Dim fso
Dim drive
Set fso = CreateObject("Scripting.FileSystemObject")

PrintPerfMonValue "CPU Utilization", "\Processor(0)\% Processor Time", "0", "50"
PrintPerfMonValue "Available Memory (Bytes)", "\Memory\Available Bytes", "20000", "INFINITY"
for each drive in fso.Drives
	if drive.DriveType = 2 then	'it is a fixed, non-network, non-removeable, non-CDROM Drive
		PrintPerfMonValue "Free Space on [" & drive.DriveLetter & "] (MB)", "\LogicalDisk(0/" & drive.DriveLetter & ":)\Free Megabytes", "500", "INFINITY"
	end if
next

Set fso = nothing

PrintPerfMonValue "System Up Time (sec.)", "\System\System Up Time", "0", "INFINITY"
%>
          </table>
          <br><br>
          <A href="SystemInformation.asp"><IMG alt="Refresh Page" border =0 src="../images/refresh.gif" ></a>
        </td>
      </tr>
    </table>
    <br>

<%
'GetServiceState "MSMQ", "MSMQ"
'PrintPerfMonValue "MSMQ Journal Queue Size (Bytes)", "\MSMQ Queue(Computer Queues/" & mstrServerName & "\routingqueue)\Bytes in Journal Queue", "0", "INFINITY"
'PrintPerfMonValue "MSMQ Queue Size (Bytes)", "\MSMQ Queue(Computer Queues/" & mstrServerName & "\routingqueue)\Bytes in Queue", "0", "INFINITY"
%>

<%
'PrintPerfMonValue "Web Service Current Connections", "\Web Service(_Total)\Current Connections", "0", "INFINITY"
'PrintPerfMonValue "ASP Requests per sec.", "\Active Server Pages\Requests/Sec", "0", "INFINITY"
'PrintPerfMonValue "ASP Sessions Timed Out", "\Active Server Pages\Sessions Timed Out", "0", "0"
'PrintPerfMonValue "Errors From Script Compilers", "\Active Server Pages\Errors From Script Compilers", "0", "0"
'PrintPerfMonValue "Errors During Script Runtime", "\Active Server Pages\Errors During Script Runtime", "0", "0"
'PrintPerfMonValue "Errors From ASP Preprocessor", "\Active Server Pages\Errors From ASP Preprocessor", "0", "0"
'PrintPerfMonValue "Failed Login Attempts", "\Server\Errors Logon", "0", "0"
%>


<%
'GetServiceState "MSSQLServer", "MSSQLServer"
'PrintPerfMonValue "SQL Connections", "\SQLServer:General Statistics\User Connections", "0", "INFINITY"   
'PrintPerfMonValue "SQL Transactions per sec.", "\SQLServer:Databases(master)\Transactions/sec", "0", "INFINITY"
%>

<%
'GetServiceState "Oracle", "Oracle"
'PrintPerfMonValue "Oracle Connections", "\SQLServer:General Statistics\User Connections", "0", "INFINITY"   
'PrintPerfMonValue "Oracle Transactions per sec.", "\SQLServer:Databases(master)\Transactions/sec", "0", "INFINITY"
%>


<%
' cleanup
'set objMonitor = nothing
%>

  </body>
</html>
