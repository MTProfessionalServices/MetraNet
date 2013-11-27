<%
' heartbeat.asp - Checks simple vital signs of the webserver.
On Error Resume Next
Response.Buffer = False

Function CheckObject(obj)
  Set o = Server.CreateObject(obj)
  Set o = Nothing
  o = Empty  
  If CheckError Then
    WriteFailed
    Exit Function
  End If
  WriteOK
End Function

Function WriteOK()
  Response.Write "[<span class='ok'>OK</span>]"
End Function

Function WriteFailed()
  Response.Write "[<span class='failed'>FAILED</span>]"
End Function

Function CheckError()
  CheckError = FALSE
  If err.number <> 0 Then
    response.Write err.Description
    CheckError = TRUE
    err.clear
    Exit Function
  End If 
End Function
%>

<html>
  <head>
    <title>MetraTech Corp. - Webserver Vital Signs</title>
    <style>
      BODY {
        color:black;
        background-color:white-smoke;
      }
      DIV.container {
        width:800px;
      }
      TD {
        border-bottom:dashed 1px silver;
      }
      TD.check {
        white-space:nowrap;
      }
      TD.status {
        text-align:right;
        width:100%;
      }
      SPAN.ok {
        color:green;
      }
      SPAN.failed {
        color:red;
      }
    </style>

  </head>
  
  <body>
    <h4>Webserver Vital Signs</h4>  
    
    <div class="container">
  
        <table cellpadding=0 cellspacing=2>
          <tr><td class="check">Application initialized</td><td class="status">&nbsp;<% If UCase(CheckError()) = "FALSE" Then WriteOK %></td></tr>

          <tr><td class="check">Checking MSIXHandler</td><td class="status"><% CheckObject("MTMSIX.MSIXHandler") %></td></tr>
          <tr><td class="check">Checking MSIXTools</td><td class="status"><% CheckObject("MTMSIX.MSIXTools") %></td></tr>
          <tr><td class="check">Checking MSIXCache</td><td class="status"><% CheckObject("MTMSIX.MSIXCache") %></td></tr>
          <tr><td class="check">Checking Dictionary</td><td class="status"><% CheckObject("MTMSIX.Dictionary") %></td></tr>
          <tr><td class="check">Checking MDMForm</td><td class="status"><% CheckObject("MTMSIX.MDMForm") %></td></tr>
        </table>

        <%
        Session.Abandon
        %>
        <br/><br/>
        Session Closed.

    </div> 
  
  </body>
  
</html>

