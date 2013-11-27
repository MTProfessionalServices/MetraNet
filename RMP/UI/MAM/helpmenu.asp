<!-- #INCLUDE FILE="auth.asp" -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>HelpMenu.asp</title>
  <link rel="STYLESHEET" type="text/css" href="<%=Session("LocalizedPath")%>/styles/styles.css">
<%
On error resume next

	Dim mstrHelpURL
	Dim mstrHelpIndexURL 
	Dim fso
  
	
	mstrHelpURL = Request.QueryString("HelpURL")
  mstrHelpFile = server.MapPath(Request.QueryString("HelpURL"))
  
	Set fso = server.CreateObject("Scripting.FileSystemObject")

  'If the file does not exist, use the standard
	if not fso.FileExists(mstrHelpFile) then
    mstrHelpURL = Session("LocalizedPath") & "/help/welcome.hlp.htm"
  end if
%>
  <script language="Javascript">
    /////////////////////////////////////////////////////////////
    // Wait for frames to finish loading, then set help url
    function LoadHelpFrame() {
      var bClear = false;
      
      if(parent.fmeHelpHTML.document.readyState == 'complete') {
        if(parent.fmeHelpHTML.helpbody.document.readyState == 'complete') {
          if(parent.fmeHelpHTML.helpbody.bsscright.document.readyState == 'complete') {
            parent.fmeHelpHTML.helpbody.bsscright.location.href = '<%=mstrHelpURL%>';
            bClear = true;
          }
        }
      }
      
      if(!bClear) {
       setTimeout('LoadHelpFrame()', 200);
     }
    }
  </script>
</head>

<body onLoad="javascript:LoadHelpFrame();">
<%	'response.write "Current help context:  " & session("HelpContext") %>
</body>
</html>
