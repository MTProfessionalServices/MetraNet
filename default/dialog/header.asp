<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title><%=Session("objMAM").Dictionary("TEXT_APPLICATION_TITLE")%></title>
  
  <script language="JavaScript1.2">
      var winHelp;
      var winNew;
      // 'SECENG: Encoding added
	  var strFlip = '<%=SafeForJS(UCase(Request.QueryString("Flip")))%>';
    
      ///////////////////////////////////////////////////////////////////////////////////    
  		function OpenHelp() {
      
  			if(winHelp){
        
  				if(!winHelp.closed) winHelp.close();
        }				
       // 'SECENG: Changed old help path to new help system CORE-4774 CLONE - MSOL BSS 27970 Unauthenticated Info Disclosure on /MOM/help.asp (post-pb)
        winHelp = window.open('<%=Session("objMAM").Dictionary("APP_HTTP_PATH")%>/../MetraNetHelp/en-US/index.htm', 'HelpWindow', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes');
  		}
    
      ///////////////////////////////////////////////////////////////////////////////////
      function LogOut() {
        window.parent.location = "logout.asp?urlredirect=<%=Mid(request.ServerVariables("SCRIPT_NAME"), 1, instr(2, request.ServerVariables("SCRIPT_NAME"), "/") - 1)%>"
  		}    
 
      ///////////////////////////////////////////////////////////////////////////////////          	
  		function FullScreen() {

        if(strFlip == "TRUE")
        {
         strFlip = "FALSE"
        }
        else
        {
         strFlip = "TRUE"
        }

        parent.resizeIt();    
        window.location = "header.asp?Flip=" + strFlip;
  	  }
 	
      ///////////////////////////////////////////////////////////////////////////////////  
      function newSession(strURL) {
        var objXML = new ActiveXObject("MSXML2.DOMDocument.3.0");
        objXML.async = false;
        objXML.validateOnParse = false;
        objXML.resolveExternals = false; 
        
        objXML.load(strURL);
        if(!checkParseError(objXML, 'Unable to launch new browser.')) {
          var objNode = objXML.selectSingleNode("URL");
          
          // Launch new browser with new session
          try {
           var WshShell = new ActiveXObject('WScript.Shell');
           WshShell.Run('IEXPLORE.EXE ' + objNode.text);
          }
          catch (e) {
           alert("Please set your MetraCare server as a trusted site in your security settings. [" + e + "]");
          } 
        }
      }
      
      ///////////////////////////////////////////////////////////////////////////////////  
      function checkParseError(objXML, strError) {
        var node;
        node = objXML.selectSingleNode("timeout"); // check for timeout
        if(node != null) {
          eval(node.text);
          return(true);
        }
       
        if(objXML.parseError.errorCode != 0) {
          alert(strError + ":  " + objXML.parseError.reason);
          return(true);
        }
        return(false);
      }            
	</script>	
  <style type="text/css">
    <!--
    .gradBG {
    	background-color: #0066CC;
    	background-image: url(../localized/en-us/images/header/gradient.gif);
    	background-position: right;
    	background-repeat: repeat-y;
      color: white;
      font-size: 11px;
    	font-family: Arial Unicode MS, Lucida Sans Unicode, Tahoma, Verdana, Arial, Helvetica, sans-serif;
    }
    -->
  </style>
</HEAD>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<table width="100%" height="56" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td bgcolor="#FFFFFF"><img src="<%=Session("LocalizedPath")%>images/Header/spacer.gif" width="1" height="1"></td>
  </tr>
  <tr>
    <td><table width="100%" height="56" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="183"><img src="<%=Session("LocalizedPath")%>images/Header/metranet.jpg" width="183" height="44"></td>
        <td rowspan="2"><table width="100%" height="56" border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td nowrap height="18" colspan="3" align="right" class="gradBG">
              <%
              ' Set server description
              Dim objVersionInfo, serverDescription
              Set objVersionInfo= CreateObject("MetraTech.Statistics.VersionInfo")
              serverDescription = objVersionInfo.GetServerDescription("")
              response.write serverDescription
              If instr(1,UCase(serverDescription),"PRODUCTION") Then
              %>
                 <img src="<%=Session("LocalizedPath")%>images/Header/production.gif" width="10" height="10">
              <%
              End If
              %>
              <img src="<%=Session("LocalizedPath")%>images/Header/spacer.gif" width="10" height="14">
            </td>
          </tr>
          <tr>
            <td height="1" colspan="3" bgcolor="#FFFFFF"><img src="<%=Session("LocalizedPath")%>images/Header/spacer.gif" width="1" height="1"></td>
          </tr>
          <tr>
            <td width="10" bgcolor="#99CC33"><img src="<%=Session("LocalizedPath")%>images/Header/spacer.gif" width="10" height="10"></td>
            <td bgcolor="#99CC33"><img src="<%=Session("LocalizedPath")%>images/Header/metranet.gif" width="100" height="17"></td>
            <td nowrap width="100%" align="right" valign="middle" bgcolor="#99CC33">

              <%
              If UCase(Request.QueryString("Flip")) = "TRUE" Then
              %>
                <a class="clsHeaderToolbar" href="JavaScript:FullScreen();"><img border="0" alt="<%=Session("objMAM").Dictionary("TEXT_FULLSCREEN")%>" src="<%=Session("LocalizedPath")%>images/Header/left_nav_on.gif" width="25" height="25"></a>
              <%
              Else
              %>
                <a class="clsHeaderToolbar" href="JavaScript:FullScreen();"><img border="0" alt="<%=Session("objMAM").Dictionary("TEXT_FULLSCREEN")%>" src="<%=Session("LocalizedPath")%>images/Header/left_nav_off.gif" width="25" height="25"></a>
              <%
              End If
              %>
            
              <img src="<%=Session("LocalizedPath")%>images/Header/spacer.gif" width="10" height="10">            
              <a class="clsHeaderToolbar" href="JavaScript:newSession('<%=Session("objMAM").Dictionary("APP_HTTP_PATH")%>/NewSession.asp');"><img border="0" alt="<%=Session("objMAM").Dictionary("TEXT_NEW_SESSION")%>" src="<%=Session("LocalizedPath")%>images/Header/new_window.gif" width="25" height="25"></a>
              <img src="<%=Session("LocalizedPath")%>images/Header/spacer.gif" width="10" height="10">
              <a class="clsHeaderToolbar" href="javascript:OpenHelp();"><img border="0" alt="<%=Session("objMAM").Dictionary("TEXT_HELP")%>" src="<%=Session("LocalizedPath")%>images/Header/help.gif" width="25" height="25"></a>
              <img src="<%=Session("LocalizedPath")%>images/Header/spacer.gif" width="10" height="10">
              <a class="clsHeaderToolbar" href="JavaScript:LogOut();"><img border="0" alt="<%=Session("objMAM").Dictionary("TEXT_MAM_LOG_OUT")%>" src="<%=Session("LocalizedPath")%>images/Header/exit.gif" width="25" height="25"></a>
              <img src="<%=Session("LocalizedPath")%>images/Header/spacer.gif" width="10" height="10">              
            </td>
          </tr>
        </table></td>
      </tr>
      <tr>
        <td height="12" background="<%=Session("LocalizedPath")%>images/Header/logo_bottom.gif"><img src="<%=Session("LocalizedPath")%>images/Header/spacer.gif" width="10" height="12"></td>
        </tr>
      <tr>
        <td colspan="2" bgcolor="#000000"><img src="<%=Session("LocalizedPath")%>images/Header/spacer.gif" width="1" height="1"></td>
        </tr>
    </table></td>
  </tr>
</table>

    
    <div id="divBevel1" class="clsFixedPos" style="left:0px; top:58px; z-index:0;">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
       <tr>
        <td valign="top" width="100%" background="<%=Session("LocalizedPath")%>images/Header/headerfill.gif">&nbsp;</td>       
       </tr>
      </table>
    </div> 

</body>

</html>
