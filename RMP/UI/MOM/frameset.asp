<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: frameset.asp$
' 
'  Copyright 1998-2003 by MetraTech Corporation
'  All rights reserved.
' 
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' 
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
' 
'  Created by: F.Torres
' 
'  $Date: 9/24/2002 1:24:20 PM$
'  $Author: Rudi Perkins$
'  $Revision: 23$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="default/lib/momLibrary.asp" -->
<%  
  Private strPipelineHTMLFile
  Private lngFrameHeight
  Private objBC
  	
  Set objBC           = Server.CreateObject("MSWC.BrowserType")  
  Session("Browser")  = objBC.browser
  
  'If(mom_IsPaymentServerMachine())Then  
  'End If
  
  If(mom_IsUserAdministrator())Then
      Session("SECURE")   = "TRUE"

      'strPipelineHTMLFile = "/mpm/MonitorService.asp?Service=Pipeline&CheckLogOn=TRUE"
      
      'strPipelineHTMLFile = "/mpm/default/dialog/MonitorService.asp?Service=Pipeline&CheckLogOn=TRUE"
      strPipelineHTMLFile = "default/dialog/MonitorService.asp?Service=Pipeline"
      
  Else
      strPipelineHTMLFile = "AdministratorRightNeeded.asp"
  End If
  lngFrameHeight = 60  
%>
<html>
  <head><title>MetraControl</title>
</head>

<script language="JavaScript1.2">

  function resizeIt(){
    
    if(parent.document.all("fmeAll").all("fmeBottom").cols == "0,*"){
      parent.document.all("fmeAll").all("fmeBottom").cols = "200,*";
    }
    else{
      parent.document.all("fmeAll").all("fmeBottom").cols = "0,*";
    }
  } 
</script>
    
  <!-- Main Frame -->
  <frameset name="fmeAll" rows="40,*,0" framespacing="0" frameborder="No" border="1" bordercolor="#D5D793">

    <!-- Title -->
	  <frame src="default/dialog/header.asp" name="fmeTop" frameborder="No" scrolling="No" marginwidth="0" marginheigth="0" framespacing="0">

    <!-- Frame to contain Menu (left) and Main frame (right)-->
    <frameset  cols="200,*" framespacing="0" frameborder="1" name="fmeBottom">

      <frameset cols="*,1" framespacing="0" frameborder="1">
        <frame src="default/dialog/Menu.asp" name="fmeNavBar" frameborder="No" scrolling="Auto" marginwidth="0" marginheight="0" framespacing="0">
        <frame name="bevel" src="bevel.html" noresize border="0" FRAMEBORDER="0" SCROLLING="no" MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">
      </frameset>
   
      <frameset rows="1,*" border="0" FRAMESPACING="0" FRAMEBORDER="0" border="0"> 
        <frame noresize name="topcurve" src="topcurve.html" border="0" FRAMEBORDER="0" SCROLLING="no" MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">
         <frame noresize src="default/dialog/welcome.asp" name="fmeMain" frameborder="No" border="0" bordercolor="#D5D793" scrolling="Auto" marginwidth="10" marginheight="10" framespacing="0">
      </frameset>
   </frameset>
 </frameset>

  <body>
    <noframes>
    Your browser must support frames to use the MetraTech Operations Manager.
    </noframes>
  </body>
 
</html>
