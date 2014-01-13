<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
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
'
' MetraTech Dialog Manager Framework ASP Dialog Template
' 
' DIALOG	    :
' DESCRIPTION	:
' AUTHOR	    :
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%

' Mandatory
Form.RouteTo = mam_GetDictionary("APPLICATION_LOG_BROWSER_CURRENT_SUBSCRIBER")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
 
    Service.Properties.Add "EVENT_ID" , "Long" , 0 , False,   -1
    Service.Properties.Add "ACTOR_ACCOUNT_ID" , "Long" , 0 , False,  MAM().CSR("_AccountId")
    Service.Properties.Add "ENTITY_TYPE_ID" , "Long" , 0 , False, 1
    Service.Properties("ENTITY_TYPE_ID").AddValidListOfValues Array(1,2), Array("Account","Product Catalog Object")
    Service.Properties.Add "ENTITY_ID" , "Long" , 0 , False, MAM().Subscriber("_AccountId")
    Service.Properties.Add "EVENT_DETAILS" , "String" , 4000, False, ""
    
    Service.Properties("EVENT_DETAILS").Caption = mam_GetDictionary("TEXT_EVENT_DETAILS")
    
    Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
      
	  Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
  On Error Resume Next
  
  dim iEventId, iUserId, iEntityTypeId, iEntityId, sDetails
  iEventId = Service.Properties("EVENT_ID")
  iUserId = Service.Properties("ACTOR_ACCOUNT_ID")
  iEntityTypeId = Service.Properties("ENTITY_TYPE_ID")
  iEntityId = Service.Properties("ENTITY_ID")
  sDetails = Service.Properties("EVENT_DETAILS")

  'response.write("<HR>")
  'response.write("About to create new event with [" & iEventId & "][" & iUserId & "][" & iEntityTypeId & "][" & iEntityId & "][" & sDetails & "]... ")
  'response.end
   
  dim objAuditor
  Set objAuditor = CreateObject("MetraTech.Auditor")
    
  call objAuditor.FireEvent(iEventId, iUserId, iEntityTypeId, iEntityId, sDetails)
    
  If(CBool(Err.Number = 0)) then
    On Error Goto 0
    OK_Click = TRUE
  Else        
    EventArg.Error.Save Err  
    OK_Click = FALSE
  End If
END FUNCTION

%>

