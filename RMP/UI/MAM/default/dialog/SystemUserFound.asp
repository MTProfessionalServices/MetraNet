<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Copyright 1998,2000 by MetraTech Corporation                             '
'  All rights reserved.                                                     '
'                                                                           '
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES       '
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of          '
'  example, but not limitation, MetraTech Corporation MAKES NO              '
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY      '
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR           '
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,                 '
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.                                  '
'                                                                           '
'  Title to copyright in this software and any associated                   '
'  documentation shall at all times remain with MetraTech Corporation,      '
'  and USER agrees to preserve the same.                                    '
'                                                                           '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/mamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Call LoadAndRedirect()

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadAndRedirect()                                           '
' Description : Attempt to load the system user.  If successful,            '
'             : redirect to the specified page.                             '
' Inputs      : URL parameters                                              '
' Outputs     : None                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function LoadAndRedirect()
  Dim lngID
  Dim strRouteTo
  
  lngID       = mdm_UIValueDefault("AccountId", "")
  strRouteTo  = mdm_UIValueDefault("RouteTo", mam_GetDictionary("SYSTEM_USER_SUMMARY_DIALOG"))

  if mam_LoadSystemUser(lngID, true) then
    'reload the menu
    response.write "<script language=""Javascript"">" & vbNewline
    response.write "  if(getFrameMetraNet().menu)"                   & vbNewline
    response.write "    getFrameMetraNet().menu.location.href = '" & mam_GetDictionary("GLOBAL_MAIN_MENU") & "?bSystemUser=TRUE';" & vbNewline
    response.write "  document.location.href = '" & strRouteTo & "';" & vbNewline
    response.write "  parent.hideUserHierarchy();" & vbNewline
    response.write "</script>" & vbNewline

  else
    Call WriteUnableToLoad(mam_GetDictionary("TEXT_SYTEM_USER_UNABLE_TO_LOAD"), "")  
  end if


End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
