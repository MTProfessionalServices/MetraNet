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
' DIALOG	:
' DESCRIPTION	:
' AUTHOR	:
' VERSION	:
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

mdm_Main                                            ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION 	:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	Service.Clear 	' Set all the property values of the service to empty.
                    ' The Product view if defined is cleared too.
                   
                      
  Form("ReLoadAccount") = IIF(Len(Request.QueryString("ReLoadAccount")),CBool(Request.QueryString("ReLoadAccount")),FALSE)

  Form.RouteTo = Request.QueryString("RouteTo")
  
  Service.Properties.Add "Title"         , "String"  , 255 , False, ""
  Service.Properties.Add "Message"       , "String"  , 255 , False, ""
  Service.Properties.Add "SecretInput"   , "String"  , 255 , False, ""
                                
	Service.Properties("title").Value 	       = Request.QueryString("Title")
	Service.Properties("message").Value 	     = Request.QueryString("Message")
  Service.Properties("SecretInput").Value    = UCase(Request.QueryString("NoMenuRefresh"))
  
  
  If UCase(Request.QueryString("KeepFrame")) = "TRUE" Then
    Call mdm_GetDictionary.Add("bKeepFrame", true)
  Else
    Call mdm_GetDictionary.Add("bKeepFrame", false)
  End If  
  
	Service.Properties("title").Caption        = "dummy"
	Service.Properties("message").Caption      = "dummy"
  
	Form_Initialize = TRUE
END FUNCTION

PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

  If Form("ReLoadAccount") Then
  
      'Call response.redirect( mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=" & mam_GetSubscriberAccountID() & "&ForceLoad=TRUE")'
      
      Form.Routeto = mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=" & mam_GetSubscriberAccountID() & "&ForceLoad=TRUE"
  Else
      ' Close the dialog and goto the next dialog
  End If  
  OK_Click = TRUE
END FUNCTION

%>

