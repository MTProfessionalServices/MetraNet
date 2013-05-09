<%
' //==========================================================================
' // Copyright 1998, 2001 by MetraTech Corporation
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
' //==========================================================================

  On Error Resume Next
%>
<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''  
%>
<html>
  <head>
	  <title>MetraTech Account Manager</title>
   
    <script language="JavaScript">
	    setInterval('SetStatus()', 1000);

      function SetStatus() {
        //status = new Date();
      }
    
      function RefreshWindows() {
        //top.fmeMain.location.reload();
	 	    //top.fmeNavBar.location.reload();
      }
    
      function resizeIt(){
        
        if(parent.document.all("fmeAll").all("fmeBottom").cols == "0,*"){
          parent.document.all("fmeAll").all("fmeBottom").cols = "284,*";
        }
        else{
          parent.document.all("fmeAll").all("fmeBottom").cols = "0,*";
        }
      }      
        
      var idTimer;
      
      function StartLoadTimer() {
//        idTimer = setInterval('MenuLoaded()', 5000);
        MenuLoaded()
      }
      
      function MenuLoaded() {
        parent.document.all("fmeAll").rows = "66,*,0";
        parent.document.all("fmeBottom").cols = "284,*";
//        clearInterval(idTimer);
      }

    </script>
  </head>

  <!-- Main Frame -->
  <frameset onLoad="javascript:StartLoadTimer();" name="fmeAll" onresize="RefreshWindows();" rows="0,0,*" framespacing="0" frameborder="No" border="0" bordercolor="#D5D793"> 

    <!--Platform Manager Title -->
	  <frame src="header.asp" name="fmeTop" frameborder="No" scrolling="No" marginwidth="0" marginheigth="0" framespacing="0">

    <!-- Frame to contain Menu (left) and Main frame (right)-->
    <frameset  cols="0,*" framespacing="0" frameborder="No" name="fmeBottom">
      <frameset cols="*,5" framespacing="0" frameborder="No" border="0">
        <frame src="menu.asp" name="fmeNavBar" frameborder="No" scrolling="Auto" marginwidth="0" marginheight="0" framespacing="0">
        <frame name="bevel" src="bevel.html" noresize border="0" FRAMEBORDER="0" SCROLLING="no" MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">
      </frameset>

      <frameset rows="11,*" border="0" FRAMESPACING="0" FRAMEBORDER="0" border="0"> 
        <frame noresize name="topcurve" src="topcurve.html" border="0" FRAMEBORDER="0" SCROLLING="no" MARGINWIDTH="0" MARGINHEIGHT="0" FRAMESPACING="0">
        <frame noresize src="welcome.asp" name="fmeMain" frameborder="No" border="0" bordercolor="#D5D793" scrolling="Auto" marginwidth="10" marginheight="10" framespacing="0">
      </frameset>
   </frameset>
 </frameset>

  <noframes>
  <h3>Your browser must support frames to use the MetraTech Platform Manager.</h3>  
  </noframes>
  
  <body>
  <%CheckPageForError("")%>
  </body>
  
</html>
