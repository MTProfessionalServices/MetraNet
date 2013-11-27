<%
' //==========================================================================
' //
' // Copyright 1998,2001 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //
' //==========================================================================
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' MonitorService.asp                                                         '
' Provide an interface to monitor the pipeline and start/stop it.            ' 
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

%>
<!-- #INCLUDE FILE="../../auth.asp" -->
  <!-- #INCLUDE File="../lib/momLibrary.asp" -->
<%

Dim m_strState   ' as string
  
' -----------------------------------------------------------------------------------
sub GetState(strService)
  Dim objMonitor ' as object
  
  On Error Resume Next
  ' create service monitoring object
  set objMonitor = Server.CreateObject("ServiceMonitor.Monitor")

  m_strState = objMonitor.GetServiceState(strService)
      
  if err then
    Call WriteErrorObject(err)
  end if
    
  select case m_strState
    Case "STARTED"
      response.write "<img border=0 src=""" & "/mpm/default/localized/us" & "/images/ServiceMonitor/green.gif"" alt = ""running"">"
    Case "STOPPED"
      response.write "<img border=0 src=""" & "/mpm/default/localized/us" & "/images/ServiceMonitor/red.gif"" alt = ""stopped"">"
    Case "PENDING"
      response.write "<img border=0 src=""" & "/mpm/default/localized/us" & "/images/ServiceMonitor/yellow.gif"" alt = ""pending"">"
    Case Else
      response.write "<img border=0 src=""" & "/mpm/default/localized/us" & "/images/ServiceMonitor/errorLight.gif"" alt = ""error"">"
  end select
   
end sub

' -----------------------------------------------------------------------------------
sub StartService(strName)
  Dim objMonitor ' as object
  
  On Error Resume Next
  
  ' create service monitoring object
  set objMonitor = Server.CreateObject("ServiceMonitor.Monitor")
  
  ' get service state
  objMonitor.ServiceStart(strName)

  if err then
    Call WriteErrorObject(err)
  end if

end sub

' -----------------------------------------------------------------------------------
sub StopService(strName)
  Dim objMonitor ' as object
  
  On Error Resume Next
  
  ' create service monitoring object
  set objMonitor = Server.CreateObject("ServiceMonitor.Monitor")
  
 
  ' get service state
  objMonitor.ServiceStop(strName)
  
  if err then
    Call WriteErrorObject(err)
  end if

  
end sub

' -----------------------------------------------------------------------------------
sub CheckForUpdate
  Dim strName
  Dim strAction
  
  
  On Error Resume Next

  strName = request.QueryString("service")
  strAction = UCase(request.form("Action"))

   response.write "<b>" & "Pipeline" & ":</b> "
  
    If request.queryString("Update") = "True" then
  
       if strAction = "START" then
         StartService strName
         m_strState = "Starting..."
       end if
       
       if strAction = "STOP" then
         StopService strName
        'm_strState = "Stopping... (Click ""Get Status"" to refresh)"
       end if
       
       if strAction = "STATUS" then
         response.write  m_strState 
         exit sub
       end if
    end if
    
    response.write  m_strState 

  if err then
    Call WriteErrorObject(err)
  end if

end sub

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim mobjMonitor

set mobjMonitor = Server.CreateObject("ServiceMonitor.Monitor")

m_strState = mobjMonitor.GetServiceState("Pipeline") 
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%> 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
  <head>
	  <title>Monitor Service</title>
    <link rel="STYLESHEET" type="text/css" href="<%="/mpm/default/localized/us"%>/styles/styles.css">
    <script language="JavaScript">
      
      var idTimer;
      function CheckRefresh() {
        idTimer = setInterval('RefreshStatus()', 10000);
      }
      
      function RefreshStatus() {
        clearInterval(idTimer);
        document.frmMonitor.Action.value = 'Status';
        document.frmMonitor.submit();
      }
      

      function RunAction(strAction) {
        document.frmMonitor.Action.value = strAction;
        document.frmMonitor.submit();
      }
    </script>
  </head>

  <body class="clsServiceMonitorBody" onLoad="CheckRefresh();">

  <FORM name="frmMonitor" action="MonitorService.asp?service=pipeline&Update=True&CheckLogon=True" method="POST" onsubmit="if(strName == 'Stop') { return confirm('Are you sure you want to stop the service [<%=request.QueryString("service")%>]?'); } else { return true; }">
  <input type="hidden" name="Action">
  <table width="100%" height="100%" cellspacing="0" cellpadding="0">
    <tr>
      <td class="clsStandardText">
<%      Call GetState("Pipeline") %>
      </td>
      <td class="clsStandardText">
<%      Call CheckForUpdate()     %>
      </td>
      <td align="center">
        <table>
<!--          <tr>
            <td align="center">
              <button class="clsButton" onClick="RunAction('Status');">Status</button>
            </td>
          </tr> -->
          <tr>
            <td align="center">
<%            if m_strState = "STOPPED" then                                            %>
                <button class="clsButton" onClick="RunAction('Start');">Start</button>
<%            end if
        
              if m_strState = "STARTED" then                                            %>
                <button class="clsButton" onClick="RunAction('Stop');">Stop</button>        
<%            end if                                                                    %>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>

<!--  <table border=1 width="100%"  cellspacing=0 cellpadding=0>
    <tr>
      <td width="100%">
        <table border=0 width="100%" cellspacing=0 cellpadding=0 >
          <tr>
            <td class="clsServiceMonitorBody" width="30">
          <% Call GetState("Pipeline") %>
            </td>
            <td class="clsServiceMonitorBody" >
          <% Call CheckForUpdate() %>
            </td>
          </tr>
        </table>
        <table border=0 width="100%" cellspacing=0 cellpadding=0>
          <tr>
            <td align="center" class="clsServiceMonitorBody"  width="50%">
            <button class="clsButton" onClick="strName='Status';">Status</button>            

            </td>
            <td align="center"  class="clsServiceMonitorBody" width="33%">
          <%
          if m_strState = "STOPPED" then
          %>
            <button class="clsButton" onClick="strName='Start';">Start</button>

          <%  
          end if
      
        if m_strState = "STARTED" then
        %>
            <button class="clsButton" onClick="strName='Stop';">Stop</button>        

        <%  
        end if
        %>
          </td>
        </tr>
      </table>
    </td>
   </tr>
 </table> -->
</form>

</body>
</html>
