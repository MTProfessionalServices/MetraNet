<!-- #INCLUDE FILE="../../auth.asp" --> 

<%
on error resume next

sub RunAdapters()
sAdapterList = Request.Form("RunAdapterSelect")
sAdapterNameList = Request.Form("AdapterName")

'response.write(sAdapterList)
'response.write(sAdapterNameList)

IntervalId = Request.Form("IntervalId")

response.write("Interval Id:" & SafeForHtml(IntervalId) & "<BR>")

if sAdapterList <> "" then
  arrAdapterList = split(sAdapterList, ",")
  
  dim objUsageServer
  set objUsageServer = CreateObject("COMUsageServer.COMUsageServer.1")

  for i = 0 to ubound(arrAdapterList)
    arrAdapterInfo = split(arrAdapterList(i),"~")
    response.write SafeForHtml("Running Adapter " & i & ": Name[" & arrAdapterInfo(1) & "] [" & arrAdapterInfo(0) & "] ")
    if len(arrAdapterInfo(2)) then
      sConfigFile = arrAdapterInfo(2)
      response.write "<BR>Using Config file [" & SafeForHtml(sConfigFile) & "]"
    else
      sConfigFile = ""
    end if
	  response.write "<BR>"
    response.flush
    err.clear
    objUsageServer.InvokeAdapterForInterval arrAdapterInfo(0), arrAdapterInfo(1), IntervalId, sConfigFile
    if err.number then
      response.write "ERROR: " & SafeForHtml(err.description) & "<BR>"
    else
      response.write "Done<BR>"
    end if
    response.flush
  next
else
  response.write "Error... no adapter selected"
  response.end
end if

end sub
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
   <head>
      <title>
         Running Adapters...
      </title>
      <link rel='STYLESHEET' type='text/css' href=
      '/mom/default/localized/en-us/styles/DialogStyles.css'>
      <link rel='STYLESHEET' type='text/css' href=
      '/mom/default/localized/en-us/styles/MenuStyles.css'>
      <link rel='STYLESHEET' type='text/css' href=
      '/mom/default/localized/en-us/styles/styles.css'>
   </head>
   <body class="clsInnerBody">
      <table border="0" cellpadding="0" cellspacing="0" width="100%">
         <tr>
            <td class="CaptionBar" nowrap>
               Running Adapters...
            </td>
         </tr>
      </table>
      <br>
       
      <div align="center">
         <form name="frmAdapterList" action="defaultDialogIntervalRunAdapter.asp" method="post">
         <!--<input name='IntervalId' value='<%=Request("IntervalId")%>' type='hidden'>-->
            <table class="clsDialogEditTable" width="100%" border="0"
            cellpadding="1" cellspacing="0">
               <tr class='TableHeader'>
                  <td align='left' colspan='5'>
                  </td>
               </tr>
               
             <%
              RunAdapters
             %>
            </table>
            <BR>
            
            
            
            <button class='clsButtonSmall' name='EditMapping' onclick="window.opener.location=window.opener.location;window.close();">
            Close</button>&nbsp;
            
         </form>
      </div>
   </body>
</html>


