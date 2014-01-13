<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultPVBMapping.asp$
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
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: Kevin A. Boucher$
'  $Revision: 1$
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

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return FALSE to cancel the dialog
FUNCTION Form_Initialize(EventArg) ' As Boolean

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
                    
  ' Set properties
  Service("Operation") = Service("Operation").EnumType("Delete")
  
  Service.Properties("LoginName").Value      = Request.QueryString("nm_login")
  Service.Properties("NameSpace").Value 	   = Request.QueryString("nm_space")
  Service.Properties("NewLoginName").Value   = "dummy"
  Service.Properties("NewNameSpace").Value   = "dummy"

  
  On Error Resume Next   
  Service.Meter TRUE
  If(Err.Number)Then
      EventArg.Error.Save Err  
      Form_DisplayErrorMessage EventArg
      response.end
  End If

	Form_Initialize = FALSE 'Returning FALSE cancels the dialog
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Cancel_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean
  Dim strRouteTo
  
  strRouteTo  = Mam().dictionary("EDIT_MAPPING_DIALOG") & "?mdmAction=" & MDM_ACTION_REFRESH & "&Dummy=" & Service.Tools.WindowsAPI.GetTickCount()
  Service.Log "GOTO TO " & strRouteTo  
  Form.RouteTo = strRouteTo
  Cancel_Click = TRUE
END FUNCTION

 %>