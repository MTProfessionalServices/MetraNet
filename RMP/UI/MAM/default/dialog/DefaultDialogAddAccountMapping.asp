<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
' 
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
'  Created by: Kevin A. Boucher
' 
'  $Date$
'  $Author$
'  $Revision$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Mandatory
Form.ServiceMsixdefFileName       = "metratech.com\AccountMapping.msixdef"
Form.RouteTo                      = Mam().dictionary("EDIT_MAPPING_DIALOG")
Form.HelpFile                     = "DEFAULTPVBMAPPING.hlp.htm"

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  Service("Operation") = Service("Operation").EnumType("Add")
  
  Service.Properties("NewNameSpace").AddValidListOfValues "__GET_NONE_PRESENTATION_NAME_SPACE_LIST__",,,,mam_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH")
  Service.Properties("NewNameSpace").Value   = Mam().Subscriber("Name_Space")
  Service.Properties("NameSpace").Value 	   = Mam().Subscriber("Name_Space")
  Service.Properties("LoginName").Value      = Mam().Subscriber("UserName")
  
  Service.Properties("NewLoginName").Required  = TRUE
  Service.Properties("NewLoginName").Caption   = mam_GetDictionary("TEXT_ALIAS")
  Service("NewNameSpace").Caption              = mam_GetDictionary("TEXT_EXTERNAL_SYSTEM")
    
  ' We only accept the following chars
  Service("NewNameSpace").StringID = TRUE
  Service("NewLoginName").StringID = TRUE
  Service("NameSpace").StringID    = TRUE
  Service("LoginName").StringID    = TRUE
  Service.LoadJavaScriptCode
  
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    On Error Resume Next

    ' If Meter() failed it will update the EventInfo.Error Object so we do not have to do it
	  Service.Meter TRUE
    If(CBool(Err.Number = 0)) then
        On Error Goto 0
        OK_Click = TRUE
    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE
    End If
    Err.Clear   
END FUNCTION

%>

