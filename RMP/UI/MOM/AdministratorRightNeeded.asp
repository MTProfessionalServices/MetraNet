<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultPVBMapping.asp$
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
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: Kevin A. Boucher$
'  $Revision: 1$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="auth.asp" -->
<!-- #INCLUDE FILE="default/lib/momLibrary.asp" -->
<%  

%>
<html>
<head>
  <LINK rel="STYLESHEET" type="text/css" href="/mom/default/localized/en-us/styles/dialogstyles.css">  
</head>
<TABLE BGCOLOR="WhiteSmoke" BORDER="1" CELLSPACING="0" CELLPADDING="0" BORDERCOLOR="Black">
  <TR>
    <TD>
      <TABLE BGCOLOR="WhiteSmoke" BORDER="0" CELLSPACING="0" CELLPADDING="0" BGCOLOR="WhiteSmoke">
        <TR>
          <TD WIDTH=10 HEIGHT=16><IMG SRC="/mom/default/localized/en-us/images/spacer.gif" WIDTH="10" HEIGHT="16" BORDER="0"></TD>
          <TD VALIGN="top"><IMG SRC="/mom/default/localized/en-us/images/error.gif" align="center" WIDTH="38" HEIGHT="37" BORDER="0" ></TD>
          <TD><BR><font size='2' >
          <% =mom_GetDictionary("TEXT_MOM_ADMINISTRATOR_RIGHTS_NEEDED") %>
          </TD>
          <TD WIDTH=10 HEIGHT=16><IMG SRC="/mom/default/localized/en-us/images/spacer.gif" WIDTH="10" HEIGHT="16" BORDER="0"></TD>
        </TR>
        <TR>
          <TD>&nbsp</TD>
        </TR>
      </TABLE>
    </TD>
  </TR>
</TABLE>
</body>
</html>
