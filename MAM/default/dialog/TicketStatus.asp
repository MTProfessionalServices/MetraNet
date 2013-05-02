<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------
'  Copyright 1998,2000,2001 by MetraTech Corporation
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
' ---------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
    
' Mandatory
Form.Version        = MDM_VERSION     ' Set the dialog version
Form.RouteTo        = mam_GetDictionary("WELCOME_DIALOG")

Call mdm_Main()                       ' invoke the mdm framework

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Form_Initialize(EventArg)                                   '
' Description :                                                             '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function Form_Initialize(EventArg)
  Dim strErrorCode
  
  'Depending on the return code, display error or success
  strErrorCode = request.queryString("errorcode")
  
  if len(strErrorCode) > 0 then
    'Try to get a specific error message
    Call mdm_GetDictionary.Add("TICKET_STATUS_TITLE", mam_GetDictionary("TEXT_MPS_TICKET_FAILED"))
    if mdm_GetDictionary.Exist("TEXT_MPS_TICKET_FAIL_STATUS_" & strErrorCode) then    
      Call mdm_GetDictionary.Add("TICKET_STATUS_TEXT", mam_GetDictionary("TEXT_MPS_TICKET_FAIL_STATUS_" & strErrorCode))
    else
      Call mdm_GetDictionary.Add("TICKET_STATUS_TEXT", mam_GetDictionary("MAM_ERROR_1006"))
    end if
  else
    Call mdm_GetDictionary.Add("TICKET_STATUS_TITLE", mam_GetDictionary("TEXT_MPS_TICKET_SUCCESS"))
    Call mdm_GetDictionary.Add("TICKET_STATUS_TEXT", mam_GetDictionary("TEXT_MPS_TICKET_SESSION_ENDED"))
  end if
  
  Form_Initialize = true
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : OK_Click(EventArg)                                          '
' Description :                                                             '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function OK_Click(EventArg)
  OK_Click = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>

