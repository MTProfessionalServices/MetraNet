<%
  Option Explicit
  
  Dim mstrUser
  Dim mbInvalidUser
  
  Dim mbMPS
  Dim mbMAM
  Dim mbMCM
  Dim mbMOM
  Dim mbMPM
  
  
  mstrUser = request.form("UserName")
  
  select Case UCase(mstrUser)
    Case "SUPERUSER"
      mbMPS = true
      mbMAM = true
      mbMCM = true
      mbMOM = true
      mbMPM = true
      
    Case "CSR"
      %>
        <script language="Javascript">
          top.location.href="MAM_Dummy_Main.html";
        </script>
      <%
            
    Case "SUBSCRIBER"
      %>
        <script language="Javascript">
          top.location.href="MPS_Dummy_Main.html";
        </script>
      <%
      
    Case "FOLDEROWNER"
      mbMPS = true
      mbMAM = true
      mbMCM = false
      mbMOM = false
      mbMPM = false
    
    Case "HIERARCHYMANAGER"
      mbMPS = true
      mbMAM = true
      mbMCM = false
      mbMOM = false
      mbMPM = false
      
    Case "OPERATIONS"
      %>
        <script language="Javascript">
          top.location.href="MOM_Dummy_Main.html";
        </script>
      <%

      
    Case "PRODUCTMANAGER"
      %>
        <script language="Javascript">
          top.location.href="MOM_Dummy_Main.html";
        </script>
      <%
    
'      response.redirect("MCM_Dummy_Main.html")
      
    Case "MISC"
      mbMPS = true
      mbMAM = true
      mbMCM = true
      mbMPM = true
      mbMOM = false
      
    Case Else
      mbInvalidUser = true
  end select
  
%>

<html>
  <head>
    <title>MetraTech version 3.0 GUI Prototypes</title>
 
    <link rel="stylesheet" href="Styles/Styles.css">
    <link rel="stylesheet" type="text/css" href="/mam/default/localized/us/styles/styles.css">
    
    <script language="Javascript">
      //Open a popup window
      function OpenPopupWindow(strHref, strName) {
        window.open(strHref, strName, 'height=768,width=1024,menubar=no,location=no,scrollbars=yes,resizable=yes');
      }
    
    </script>
  </head>
  
  <body style="background-color:white; margin:0">
    <table cellpadding="0" cellspacing="0" border="0" width="438" Height="100%">
        <td align="center" valign="top" bgcolor="#00337c" width="100%">
          <TABLE cellpadding="0" cellspacing="0" border="0" width="100%" height="100%">
            <tr>
              <td width="18" class="loginLeftBevel">
            	  <img align="top" src="/mcm/default/localized/us/images/Header/loginbevelcorner.gif">
              </td>
              <td class="loginTopBevel"></td>
            </tr>

            <TR> 
	            <td valign="top" class="loginLeftBevel">
	              <img align="top" src="/mcm/default/localized/us/images/Header/loginbarleft.gif">
	            </td>
              <TD valign="top" Class='loginBar' nowrap> 
	              <center>
                  MetraTech Applications
	              </center>
              </TD>
            </TR>
            <tr><td height="20" class="loginLeftBevel"></td></tr>
            <TR> 
	            <td class="loginLeftBevel"></td>
              <TD valign="top" ColSpan="2" nowrap>
                <% if mbInvalidUser then %>
                  <P class="clsLoginMessage">
                    <b>For some real fun, log in as one of the following:</b><br><br>
                      SuperUser<br><br>
                      CSR<br><br>
                      Subscriber<br><br>
                      FolderOwner<br><br>
                      HierarchyManager<br><br>
                      Operations<br><br>
                      ProductManager<br><br>
                      Misc<br><br>
                  </P>
                <% else %>
                  <P class='clsLoginMessage'>Welcome <%=mstrUser%>!</P>
                <% end if %>
              </TD>
            </TR>
            <tr><td height="20" class="loginLeftBevel"></td></tr>
            <tr>
            	<td class="loginLeftBevel"></td>
              <td align="center">
                <table>
                <% if mbMPS then %>
                  <tr>
                    <td align="right"><img src="images/MetraBill.gif"></td>
                    <td align="left"><a href="javascript:OpenPopupWindow('MPS_Dummy_Main.html', 'MPS');" class="clsMainMenuLink">MetraView</a></td>
                  </tr>
                  <tr>
                    <td align="left"><br></td>
                  </tr>
                <% end if %>
                
                <% if mbMAM then %>
                  <tr>
                    <td align="right"><img src="images/MAM.gif"></td>
                    <td align="left"><a href="javascript:OpenPopupWindow('MAM_Dummy_Main.html', 'MAM');" class="clsMainMenuLink">Account Manager</a></td>
                  </tr>
                  <tr>
                    <td align="left"><br></td>
                  </tr>
                <% end if %>
                
                <% if mbMCM then %>
                  <tr>
                    <td align="right"><img src="images/MCM.gif"></td>
                    <td align="left"><a href="javascript:OpenPopupWindow('MCM_Dummy_Main.html', 'MCM');" class="clsMainMenuLink">Catalog Manager</a></td>
                  </tr>
                  <tr>
                    <td align="left"><br></td>
                  </tr>
                <% end if %>
                
                <% if mbMOM then %>
                  <tr>
                    <td align="right"><img src="images/MOM.gif"></td>
                    <td align="left"><a href="javascript:OpenPopupWindow('MOM_Dummy_Main.html', 'MOM');" class="clsMainMenuLink">Operations Manager</a></td>
                  </tr>
                  <tr>
                    <td align="left"><br></td>
                  </tr>
                <% end if %>
                
                <% if mbMPM then %>
                  <tr>
                    <td align="right"><img src="images/MPM.gif"></td>
                    <td align="left"><a href="javascript:OpenPopupWindow('MPM_Dummy_Main.html', 'MPM');" class="clsMainMenuLink">Platform Manager</a></td>
                  </tr>
                <% end if %>
                </table>
              </td>
            </tr>              
            <tr><td height="30" class="loginLeftBevel"></td></tr>
            <tr>
            	<td class="loginLeftBevel"></td>
              <td align="center">
                <% if mbInvalidUser then %>
                  <button onclick="javascript:document.location.href='login.html';" name="ok" Class='clsButtonMedium'>Back to Login</button>
                <% else %>
                  <button onclick="javascript:document.location.href='login.html';" name="ok" Class='clsOkButton'>Log Out</button>
                <% end if %>
              </td>
            </tr>
            <tr height="100%"><td class="loginLeftBevel">&nbsp;</td></tr>
          </TABLE>
          <BR>
        </td>
      </tr>
    </table>
  </body>
</html>
 
   