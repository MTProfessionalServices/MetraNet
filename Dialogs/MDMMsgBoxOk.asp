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
' DIALOG	    : MsgBoxOk.asp
' DESCRIPTION	: Implement a Message Box Ok Dialog. The function mdm_MsgBoxOk from the mdmLibrary.asp
'               Allow to call this dialog...
' AUTHOR	    : Boucher and Torres
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit 
%>
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<%

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	Service.Clear 	

  Form.RouteTo = Request.QueryString("RouteTo")
  
  Service.Properties.Add "Title"         , "String"  , 255 , False, ""
  Service.Properties.Add "Message"       , "String"  , 255 , False, ""
                                
	Service.Properties("title").Value 	   = Request.QueryString("Title")
	Service.Properties("message").Value 	 = Request.QueryString("Message")

	Form_Initialize = TRUE
END FUNCTION

%>

