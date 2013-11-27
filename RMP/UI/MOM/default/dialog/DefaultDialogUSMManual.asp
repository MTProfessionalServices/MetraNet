<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
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
'  $Date$
'  $Author$
'  $Revision$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<%

' Mandatory
Form.RouteTo          = "DefaultDialogUSMManualAction.asp"   ' mom_GetDictionary("USM_GRACE_PERIOD_CONFIG_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
							
  Service.Properties.Add "CloseOpen", MSIXDEF_TYPE_BOOLEAN, 0  , FALSE, true
  Service.Properties.Add "CloseSoftClosed", MSIXDEF_TYPE_BOOLEAN, 0  , FALSE, true
  Service.Properties.Add "CloseExpirationDate", MSIXDEF_TYPE_TIMESTAMP, 0  , FALSE, Empty
  Service.Properties.Add "RunSoftClose", MSIXDEF_TYPE_BOOLEAN, 0  , FALSE, true
  Service.Properties.Add "RunHardClose", MSIXDEF_TYPE_BOOLEAN, 0  , FALSE, true
  
  Service.LoadJavaScriptCode  

  '// If this is not an advanced user then we will have javascript hide all the fields
  if ucase(mdm_GetDictionary().Item("INTERVAL_MANAGEMENT_ADVANCED_USER"))="TRUE" then
    mdm_GetDictionary().Add "SHOW_USM_FIELDS", "true"
  else
    mdm_GetDictionary().Add "SHOW_USM_FIELDS", "false"
  end if
  
  mdm_IncludeCalendar
  
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  
  'response.write("ManualAction [" & request("ManualAction") & "]<BR>")
  session("USM_MANUAL_OPERATION_ManualAction")=request("ManualAction")
  
  'response.write("CloseOpen [" & Service.Properties("CloseOpen") & "]<BR>")
  session("USM_MANUAL_OPERATION_CloseOpen")=Service.Properties("CloseOpen")
  'response.write("CloseSoftClosed [" & Service.Properties("CloseSoftClosed") & "]<BR>")
  session("USM_MANUAL_OPERATION_CloseSoftClosed")=Service.Properties("CloseSoftClosed")

  session("USM_MANUAL_OPERATION_RunSoftClose")=Service.Properties("RunSoftClose")
  session("USM_MANUAL_OPERATION_RunHardClose")=Service.Properties("RunHardClose")
  
  'response.write("ExpirationDateType [" & request("ExpirationDateType") & "]<BR>")
  session("USM_MANUAL_OPERATION_ExpirationDateType")=request("ExpirationDateType")
  
  'response.write("CloseExpirationDate [" & Service.Properties("CloseExpirationDate") & "]<BR>")
  session("USM_MANUAL_OPERATION_CloseExpirationDate")=Service.Properties("CloseExpirationDate")
  
  'response.end
  
  Ok_Click = TRUE  
END FUNCTION

%>


