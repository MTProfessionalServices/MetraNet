<%
Option Explicit
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
  <head>
	  <title>All System Information</title>
    <link rel="STYLESHEET" type="text/css" href="../../../default/localized/en-us/styles/styles.css">

    <!-- #INCLUDE FILE="printperfmonvalue.asp" -->
    <!-- #INCLUDE FILE="../Shared/WriteError.asp" -->

    <script language="JavaScript1.2">
      var intIntervalID;
      var bPaused = false;
      var bBodyLoaded = false;

      function RefreshDoc() {
        if(bBodyLoaded == true)
          document.location.href = 'AllInformation.asp';
      }
            
      function BodyLoaded() {
        bBodyLoaded = true;
<%
        if request.QueryString("Pause") <> "true" then
		      response.write "        intIntervalID = setInterval('RefreshDoc()', 5000);" & vbNewline
        end if
%>
      }
      
    </script>
    
<%
On Error Resume Next

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub GetServiceState(strService, strDescription)
  Dim objServiceMonitor ' as object
  Dim strState           ' as string
  Dim strClass
  
  ' create service monitoring object
  set objServiceMonitor = CreateObject("ServiceMonitor.Monitor")
 
  ' get service state
  strState = objServiceMonitor.GetServiceState(strService)


  if strState <> "STARTED" then
    strClass = "clsPerfmonAlert"
  else      
    strClass = "clsPerfmonRow"
  end if  
  
  response.write "      <tr>" & vbNewline
  
  if bOdd = true then  
    response.write "        <td class = ""clsTableTextOddLabel"">" & strDescription & "</td>" & vbNewline
    response.write "        <td class = """ & strClass & "Odd"">" & strState & "</td>" & vbNewline
  else
    response.write "        <td class = ""clsTableTextEvenLabel"">" & strDescription & "</td>" & vbNewline
    response.write "        <td class = """ & strClass & "Even"">" & strState & "</td>" & vbNewline
  end if

  response.write "      </tr>" & vbNewline  

  bOdd = not bOdd
  
  ' cleanup
  Set objServiceMonitor = nothing

End Sub
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WriteInfoHeader(strHeader, intColSpan, strClass)
  
  response.write "            <tr>" & vbNewline
  response.write "              <th align=""center"" colspan=""" & intColSpan & """ class=""" & strClass & """>" & strHeader & "</th>" & vbNewline
  response.write "            </tr>" & vbNewline

End Sub
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WriteSystemInformation()
  
  Dim fso         'as file system object
  Dim drive       'as file system drive object
  
  'Create the file system object
  Set fso = CreateObject("Scripting.FileSystemObject")
  
  'check for an error
  if err then
    WriteErrorObject Err
  end if
  
  'write the table
  response.write "          <table width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" & vbNewline
  WriteInfoHeader "System", 2, "clsTableHeader"

  'write the data
  PrintPerfMonValue "CPU Utilization", "\Processor(0)\% Processor Time", "0", "50"
  PrintPerfMonValue "Available Memory (Bytes)", "\Memory\Available Bytes", "20000", "INFINITY"
              
  for each drive in fso.Drives
    if drive.DriveType = 2 then	'it is a fixed, non-network, non-removeable, non-CDROM Drive
      PrintPerfMonValue "Free Space on [" & drive.DriveLetter & "] (MB)", "\LogicalDisk(0/" & drive.DriveLetter & ":)\Free Megabytes", "500", "INFINITY"
    end if
  next

  Set fso = nothing

  PrintPerfMonValue "System Up Time (sec.)", "\System\System Up Time", "0", "INFINITY"

  'Close the table
  response.write "          </table>" & vbNewline
  
End Sub
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WritePipelineServerInformation()
  
  On Error Resume Next
  
  response.write "          <table width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" & vbNewline
  WriteInfoHeader "Pipeline Server", 2, "clsTableHeader"
  
  GetServiceState "Pipeline", "Pipeline"

  PrintPerfMonValue "% Capacity", "\MetraTech Pipeline\% Capacity", "0", "INFINITY"
  PrintPerfMonValue "Sessions", "\MetraTech Pipeline\Sessions", "0", "INFINITY"       
  PrintPerfMonValue "Sessions per sec.", "\MetraTech Pipeline\Sessions/sec", "0", "INFINITY"              

  response.write "          </table>" & vbNewline

End Sub
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WriteMeteringServerInformation()

  response.write "          <table width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" & vbNewline
  WriteInfoHeader "Metering Server", 2, "clsTableHeader"

  GetServiceState "MSMQ", "MSMQ"

  PrintPerfMonValue "MSMQ Journal Queue Size (Bytes)", "\MSMQ Queue(Computer Queues/" & mstrServerName & "\routingqueue)\Bytes in Journal Queue", "0", "INFINITY"
  PrintPerfMonValue "MSMQ Queue Size (Bytes)", "\MSMQ Queue(Computer Queues/" & mstrServerName & "\routingqueue)\Bytes in Queue", "0", "INFINITY"
  PrintPerfMonValue "MSMQ Number of Active Sessions", "\MSMQ Service\Sessions", "0", "INFINITY"
  PrintPerfMonValue "MSMQ Total Messages in all Queues", "\MSMQ Service\Total messages in all queues", "0", "INFINITY"

  response.write "          </table>" & vbNewline

End Sub
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WritePresentationServerInformation()

  response.write "          <table width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" & vbNewline

  WriteInfoHeader "Presentation Server", 2, "clsTableHeader"
  
  PrintPerfMonValue "Web Server Current Connections", "\Web Service(_Total)\Current Connections", "0", "INFINITY"
  PrintPerfMonValue "Connention Attempts per sec.", "\Web Service(_Total)\Connection Attempts/sec", "0", "INFINITY"
  PrintPerfMonValue "ASP Requests per sec.", "\Active Server Pages\Requests/Sec", "0", "INFINITY"
  PrintPerfMonValue "ASP Sessions Timed Out", "\Active Server Pages\Sessions Timed Out", "0", "0"
  PrintPerfMonValue "Errors From Script Compilers", "\Active Server Pages\Errors From Script Compilers", "0", "0"
  PrintPerfMonValue "Errors During Script Runtime", "\Active Server Pages\Errors During Script Runtime", "0", "0"
  PrintPerfMonValue "Errors From ASP Preprocessor", "\Active Server Pages\Errors From ASP Preprocessor", "0", "0"

  response.write "          </table>" & vbNewline

End Sub
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WriteLoggingInformation(strLog)
  Dim objAudit

  On Error Resume Next
  
	Set objAudit = CreateObject("Logging.Log")
  if strLog = "Pipeline" then
    objAudit.doInit "/MTAdmin/AdminLogging/Logging.xml"
  elseif strLog = "Metering Server" then
    objAudio.doInit "/MTAdmin/AdminLogging/msix/Logging.xml"
  end if
  
  
  response.write "          <table width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" & vbNewline

  WriteInfoHeader strLog, 2, "clsTableHeader"
    
  response.write "            <tr>" & vbNewline
  response.write "              <td class=""clsTableTextEvenLabel""><nobr>Log File Size (Bytes)</nobr></td>" & vbNewline
  response.write "              <td class=""clsTableTextEven"" align=""right""><nobr>" & FormatNumber(objAudit.GetFileSize,0,,,true) & "</nobr></td>" & vbNewline
  response.write "            </tr>" & vbNewline
  response.write "            <tr>" & vbNewline
  response.write "              <td class=""clsTableTextOddLabel"">Last Modified</td>" & vbNewline
  response.write "              <td class=""clsTableTextOdd"" align=""right"">&nbsp;" & objAudit.GetFileDate & "</td>" & vbNewline
  response.write "            </tr>" & vbNewline
  response.write "            <tr>" & vbNewline
  response.write "              <td class=""clsTableTextEvenLabel"">Warnings</td>" & vbNewline
  response.write "              <td class=""clsTableTextEven"" align=""right"">&nbsp;56</td>" & vbNewline
  response.write "            </tr>" & vbNewline
  response.write "            <tr>" & vbNewline
  response.write "              <td class=""clsTableTextOddLabel"">Errors</td>" & vbNewline
  response.write "              <td class=""clsTableTextOdd"" align=""right"">&nbsp;16</td>" & vbNewline
  response.write "            </tr>" & vbNewline
  response.write "            <tr>" & vbNewline
  response.write "              <td class=""clsTableTextEvenLabel"">Fatals</td>" & vbNewline
  response.write "              <td class=""clsTableTextEven"" align=""right"">&nbsp;</td>" & vbNewline
  response.write "            </tr>" & vbNewline
  response.write "          </table>" & vbNewline

  Set objAudit = nothing
  
End Sub
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>

  </head>

  <body onload="javascript:BodyLoaded();">
    <br>
    <div align="center" class="clsInfoPageHeader">All System Information</div>
<%
    if request.QueryString("Pause") = "true" then
      response.write "    <div align=""center""><a class=""clsInfoPagePause"" href=""AllInformation.asp?Pause=false"">(Click here to Resume Updating)</a>" & vbNewline
    else
      response.write "    <div align=""center""><a class=""clsInfoPagePause"" href=""AllInformation.asp?Pause=true"">(Click here to Stop Updating)</a>" & vbNewline
    end if
%>
    <div align="center" class="clsInfoPagePause"><%=time%></div>
    
    <hr size="1" width="75%">
 
    <div align="center">
    <table width=750 border="0" cellspacing="5" cellpadding="5">
      <tr>
        <td width="350" valign="top">
<%        WriteSystemInformation              %>
        </td>

        <!-- Spacer between the information cells -->
        <td width="50">&nbsp;</td>

        <td width="350" valign="top">
<%        WriteMeteringServerInformation      %>
        </td>
      </tr>
      
      <!-- Vertical Spacer -->
      <tr>
        <td colspan=3>&nbsp;&nbsp;</td>
      </tr>
      
      <tr>
        <td valign="top">
<%        WritePipelineServerInformation      %>      
        </td>
        
        <!-- Horizontal spacer -->
        <td width="50" valign="top">&nbsp;</td>
        
        <td valign="top">
<%        WritePresentationServerInformation  %>
        </td>
      </tr>
  
      <!-- Vertical spacer -->
      <tr>
        <td>&nbsp;</td>
      </tr>
    </table>
    
    <br>
    <br>
    <div align="center" class="clsInfoPageHeader">All System Logs</div>
    <hr size="1" width="75%">
    
    <table width="700">
      <tr>
        <td width="310" valign="top">
<%        WriteLoggingInformation "Pipeline"                %>
        </td>            
        
        <td width="90">&nbsp;</td>
        
        <td width="310" valign="top">
<%        WriteLoggingInformation "Metering Server"         %>
        </td>
      </tr>
    </table>
    </div>

    <hr size="1" width="75%">

  </body>
</html>
