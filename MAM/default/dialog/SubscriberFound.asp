<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/mamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
response.expires = -1000
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2000 by MetraTech Corporation
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' VERSION : Kona
' ----------------------------------------------------------------------------------------------------------------------------------------
Dim lngAccountId
Dim strRouteTo
Dim strShowBackSelectionButton

lngAccountId                = mdm_UIValueDefault("AccountId","NULL")
strRouteTo                  = mdm_UIValueDefault("RouteTo",mam_GetDictionary("SUMMARY_ACCOUNT_INFO_DIALOG"))
strShowBackSelectionButton  = mdm_UIValueDefault("ShowBackSelectionButton","FALSE")

If CBool(mam_LoadSubscriberAccount(lngAccountID)) Then
 
  If(Len(strShowBackSelectionButton))Then
    If(CBool(strShowBackSelectionButton)) Then
      strRouteTo = strRouteTo & "?ShowBackSelectionButton=" & strShowBackSelectionButton
    End If  
  End If

  ' Write script to refresh MAIN MENU frame
  response.Write "<script language=""JavaScript1.2"">"             & vbNewline
  response.Write "  if(getFrameMetraNet().menu) getFrameMetraNet().menu.location.reload();"      & vbNewline 
  response.Write "</script>"                                       & vbNewline 
         
  response.Write "<script language=""JavaScript1.2"">"             & vbNewLine
  response.Write "if (document.images) {"                          & vbNewLine
  response.Write "  location.replace(""" & strRouteTo & """); }"   & vbNewLine
  response.Write "else {"                                          & vbNewLine
  response.Write "  location.href = """ & strRouteTo & """;"       & vbNewLine
  response.Write "} </script>"                                     & vbNewLine

Else

  Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"), mam_GetDictionary("SUBSCRIBER_FOUND"))

End If


%>
