<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<%

' Mandatory
Form.RouteTo                      = "welcome.asp"

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
        
    ' Add the EMail Notification on the fly
    Service.Properties.Add "MOM_VERSION" , "String"     , 255 , False,   GetMTAppVersion()
    Service.Properties.Add "MTMSIX_VERSION" , "String"  , 255 , False,   CStr(Service.Version())
    Service.Properties.Add "MTVBLIB_VERSION" , "String" , 255 , False,   CStr(mtvblib_Version())
    Service.Properties.Add "MDM_VERSION" , "String"     , 255 , False,   CStr(MDM_VERSION)
	  Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: GetAppVersion()
' PARAMETERS	:
' DESCRIPTION : Return the MT App Version
' RETURNS		  : 
PRIVATE FUNCTION GetMTAppVersion() ' As String
  Dim objV
  Set objV = CreateObject("VersionReporting.VersionTool")
  GetMTAppVersion = objV.GetVersion()
END FUNCTION

%>
