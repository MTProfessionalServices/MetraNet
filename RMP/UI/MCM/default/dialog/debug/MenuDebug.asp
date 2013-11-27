<script language="JavaScript1.2">
/////////////////////////////////////////////
// DEBUG FUNCTIONS
/////////////////////////////////////////////
function Debug()
{
 window.open('MDMMonitor.asp', 'Debug', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')
}

function Reload()
{
  window.open('debug/ReloadStaticData.asp', 'ReloadDictionary', 'height=200,width=300, resizable=yes, scrollbars=yes, status=yes')
}

function ErrorLookup()
{
  window.open('ErrorLookup.asp', 'ErrorLookup', 'height=300,width=500, resizable=yes, scrollbars=yes, status=yes')
}  

function ViewSource()
{
  var WshShell = new ActiveXObject('WScript.Shell');
  var strFile = new String(parent.ticketFrame.document.location);
  strFile = strFile.substring(strFile.lastIndexOf("/"));
  // we don't need the querystring to get the file
  if(strFile.lastIndexOf("?") > 0) {
    strFile = strFile.slice(1, strFile.lastIndexOf("?"));
    strFile = "/" + strFile
  }  
  strFile = '<%=GetSourceDir()%>' + strFile;
  
  WshShell.Run('notepad ' + strFile);
}

function StyleGuide()
{
 window.open('StyleGuide.asp', 'Style', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')
}

</script>

<!-- DEBUG MENU -->
<font size="-1">
<a href="JavaScript:StyleGuide();">Style Guide</a>&nbsp;&nbsp;                  
<a href="JavaScript:ViewSource();">View Source</a>&nbsp;&nbsp;
<a href="JavaScript:ErrorLookup();">Error Lookup</a>&nbsp;&nbsp; 
<a href="JavaScript:Debug();">Debug</a>&nbsp;&nbsp; 
<a href="JavaScript:Reload();">Reload Dictionary</a>&nbsp;&nbsp; 
<a href="debug/KillSession.asp" target="ticketFrame">Reset Session</a>&nbsp;&nbsp; 
</font>
                  
<%
Function GetSourceDir()
  GetSourceDir = server.MapPath(FrameWork.GetDictionary("APP_HTTP_PATH"))  
  GetSourceDir = replace(GetSourceDir, "\", "\\")
  GetSourceDir = GetSourceDir & "\\default\\dialog"
End Function

%>
