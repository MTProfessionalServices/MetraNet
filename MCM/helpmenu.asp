<!-- #INCLUDE FILE="auth.asp" -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
	<title>HelpMenu.asp</title>
  <link rel="STYLESHEET" type="text/css" href="<%=Session("LocalizedPath")%>/styles/styles.css">
  <SCRIPT language="JavaScript" src="/mpte/shared/browsercheck.js"></SCRIPT>
<%

on error resume next

	Dim mstrHelpURL
	Dim mstrHelpIndexURL 
	'Dim objBC	
	Dim fso
  Dim strmTextStream

	'Set objBC = Server.CreateObject("MSWC.BrowserType")
	
	mstrHelpURL = Request.QueryString("HelpURL")
  mstrHelpFile = server.MapPath(Request.QueryString("HelpURL"))
  
	Set fso = server.CreateObject("Scripting.FileSystemObject")
	Set	strmTextStream = fso.OpenTextFile(mstrHelpFile)
	
  ' if the stream is nothing then let's set a default help file
	if strmTextStream is nothing then	
    mstrHelpURL = Session("LocalizedPath") & "/help/welcome.htm"
  end if

%>

<SCRIPT language=Javascript1.2>

   //These functions are used to set the help page to the correct context sensitive location    
    var bc = new BrowserCheck(); 
    
    if (bc.ie)
    {
      var intIntervalID;
		  intIntervalID = setInterval('LoadHelpFrame()', 100);
    }
    
    function LoadHelpFrame() {
      if (bc.ie)
      {
        //window.alert("This is IE");
        if (parent.document.readyState == "complete")
        {
 			    clearInterval(intIntervalID);
			    if (parent.fmeHelpHTML.BODY)
			      parent.fmeHelpHTML.BODY.location.href='<% = SafeForJs(mstrHelpURL) %>';
			    else
			      window.alert("Unable to set context sensitive help page. The id 'BODY' could not be located in the help generated frameset.");
        }
      }
      else
      {
        if (parent.fmeHelpHTML.helpbody)
          parent.fmeHelpHTML.helpbody.bsscright.location.href='<% = SafeForJs(mstrHelpURL) %>';
        else
		  window.alert("Unable to set context sensitive help page. The id 'helpbody' could not be located in the RoboHelp generated frameset.");

      } 
    }

  	</SCRIPT>
</head>

<body style="margin:0px;border:0px;" onload="LoadHelpFrame();"></body>
</html>
