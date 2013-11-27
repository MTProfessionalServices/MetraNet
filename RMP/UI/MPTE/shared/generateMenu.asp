<%
' //==========================================================================
' // @doc $Workfile$
' //
' // Copyright 1998 by MetraTech Corporation
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
' // Created by: Dave Wood
' //
' // $Date$
' // $Author$
' // $Revision$
' //==========================================================================

'----------------------------------------------------------------------------
'  DESCRIPTION - This file is used to draw out a navigation menu 
'----------------------------------------------------------------------------



'----------------------------------------------------------------------------
'  METHODS
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: writeTabMenu
'   Description: writes out a Tab-sytle menu.  Assumes that the correct styles
'             have already been defined and included in another file and 
'             the required images exist.
'   Parameters: iarrstrLinks - array of links for the menu
'               iarrstrLabels - array of labels (names) to use
'               iintSelected - the index of the currently selected menu option
'   Return Value: none
'-----------------------------------------------------------------------------
sub writeTabMenu(iarrstrLinks, iarrstrLabels, iintSelected)
  dim i
  dim intSelected
  dim strStartCap
  dim strServerName
  
  strServerName = request.ServerVariables("SERVER_NAME")
  
  intSelected = CLng(iintSelected)
  
  if ubound(iarrstrLinks) < 1 then
    exit sub
  end if
  
  if ubound(iarrstrLinks) <> ubound(iarrstrLabels) then
    exit sub
  end if
  
  if intSelected > ubound(iarrstrLinks) then
    response.write "exiting because of selected check<BR>"
    response.write intSelected & " > " & ubound(iarrstrLinks)
    exit sub
  end if
    
%>
  <table width="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0">
  <TR>
    <TD>
      <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
        <tr>
          <TD width="10"></TD>
          <% if intSelected = 0 then %>
            <TD><img SRC="<%=session("VIRTUAL_DIR")%>/us/images/tab_on_leftcap.gif"  BORDER="0" ALT=""></TD>
          <% else %>
            <TD ><img SRC="<%=session("VIRTUAL_DIR")%>/us/images/tab_off_leftcap.gif"  BORDER="0" ALT=""></TD>
          <% end if %>
          
          <% 
            for i = 0 to ubound(iarrstrLinks)
              if intSelected = i then
          %>    
                <TD ALIGN="center" BACKGROUND="http://<%=strServerName%><%=session("VIRTUAL_DIR")%>/us/images/tab_on.gif">
                  <span class="clsGenericEditTopMenuChosen"><%=iarrstrLabels(i)%></span></TD>
              <% if i = ubound(iarrstrLinks) then %>
                <TD><img SRC="<%=session("VIRTUAL_DIR")%>/us/images/tab_on_end_stop.gif"  BORDER="0" ALT=""></TD>
              <% else %>
                <TD><img SRC="<%=session("VIRTUAL_DIR")%>/us/images/tab_on_end_to_tab_off.gif" BORDER="0" ALT=""></TD>
              <% end if %>
              
          <%  else %>
                <TD ALIGN="center" BACKGROUND="http://<%=strServerName%><%=session("VIRTUAL_DIR")%>/us/images/tab_off.gif">
                  <a class="clsGenericEditTopMenu" href="<%=iarrstrLinks(i)%>"><%=iarrstrLabels(i)%></a></TD>
              <% if i = ubound(iarrstrLinks) then %>
                <TD><img SRC="<%=session("VIRTUAL_DIR")%>/us/images/tab_off_end_stop.gif"  BORDER="0" ALT=""></TD>
              <% elseif intSelected = i + 1 then %>
                <TD><img SRC="<%=session("VIRTUAL_DIR")%>/us/images/tab_off_end_to_tab_on.gif"  BORDER="0" ALT=""></TD>
              <% else %>
                <TD><img SRC="<%=session("VIRTUAL_DIR")%>/us/images/tab_off_end_to_tab_off.gif"  BORDER="0" ALT=""></TD>
              <% end if %>
          <%  end if %>
          <% next %>    
        </tr>
      </table>
    </TD>
  </TR>
  <TR VALIGN="top"><TD><img src="http://<%=strServerName%><%=session("VIRTUAL_DIR")%>/us/images/tab_line.gif" WIDTH="100%" HEIGHT="3" BORDER="0" ALT=""></TD></TR>
  </TABLE>    
<%
end sub




%>
