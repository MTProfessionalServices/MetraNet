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

Option Explicit
On Error Resume Next
%>


<html>
  <head>
  	<title>MetraTech Corp.</title>
    <link rel="STYLESHEET" type="text/css" href="styles/styles.css">  
      	
  	<script>
  		var winHelp;
  		
  		function OpenHelp() {
  			if (winHelp)
  				if (!winHelp.closed)
  					winHelp.close();
  				
  			winHelp = window.open('help/help.asp', 'HelpWindow', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes');
  		}
  
      var winAbout;
      
  		function About(){
  			if (winHelp)
  				if (!winHelp.closed)
  					winHelp.close();
  				
  			winAbout = window.open('About.asp', 'About', 'height=450,width=350, resizable=no, scrollbars=no, status=no');
  		}
      
      function FullScreen() {
        parent.resizeIt();    
      }
      
      function CalcPosition(intOffset) {
        var intPos;

        if(document.body.clientWidth < 560)
          intPos = 560 - intOffset;
        else
          intPos = document.body.clientWidth - intOffset;
        
        return(intPos);
      }
      
      function SetPosition() {
        //Before setting dynamic properties, set the width of the header image
        divBevel1.style.left = 0
        divBevel1.style.top = 57

      }
  	</script>	

  </head>

  <body style="margin:0" onLoad="SetPosition();"> 
    <!-- Header Table -->
    <table width="100%" border="0" cellspacing="0" cellpadding="0" border="0">
      <tr valign="bottom">
        <td align="right" width="1%" id="cellLeft"><img src="images/headerleft.gif"></td>
        <td background="images/headerright.gif" align="right">
          <table cellspacing="0" cellpadding="5">
            <tr>
              <td><a class="clsHeaderToolbar" href="javascript:FullScreen();"><img src="images/resize.gif" border="0" alt="Resize Screen"></a></td>
              <td><a class="clsHeaderToolbar" href="javascript:OpenHelp();"><img src="images/help.gif" border="0" alt="Open Help"></a></td>
            </tr>
          </table>
        </td>              
      </tr>
    </table>
    
    <div class="clsApplicationHeader">
      Account Manager
    </div>
    
    <div id="divBevel1" class="clsFixedPos">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
       <tr>
        <td valign="top" width="100%" background="images/headerfill.gif">&nbsp;</td>       
       </tr>
      </table>
    </div>    
  </body>
</html>
