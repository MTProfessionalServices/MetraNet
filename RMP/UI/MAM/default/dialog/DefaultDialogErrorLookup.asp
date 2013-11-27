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

Form.RouteTo                      = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION 	:
' RETURNS		: Return TRUE if ok else FALSE

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Service.Clear 	' Set all the property of the service to empty. 
         					' The Product view if allocated is cleared too.
 
  ' Add confirm Password property
  Service.Properties.Add "ErrorCode", "STRING", "255", TRUE, ""

  Service.Properties("ErrorCode").Value  = "&H"
           
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Ok
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		    : Return TRUE if ok else FALSE
FUNCTION Ok_Click(EventArg) ' As Boolean
   
        on error resume next
        err.number = CLng(Service.Properties("ErrorCode").Value)
        EventArg.error.save err
        OK_Click = FALSE      
  
END FUNCTION

%>

