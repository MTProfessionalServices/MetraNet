<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: s:\UI\MOM\default\dialog\IntervalManagement.StateChange.asp$
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
'  Created by: Rudi, Kevin
' 
'  $Date: 10/29/2002 3:06:56 PM$
'  $Author: Rudi Perkins$
'  $Revision: 1$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!--METADATA TYPE="TypeLib" NAME="MetraTech.UsageServer" UUID="{b6ad949f-25d4-4cd5-b765-3f6199ecc51c}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/IntervalManagementLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

' Mandatory
Form.RouteTo = "" 
Form.Modal = TRUE
Form.ErrorHandler = false

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_Initialize
' PARAMETERS : EventArg
' DESCRIPTION:
' RETURNS    : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  Framework.AssertCourseCapability "Manage EOP Adapters", EventArg
  Service.Clear
	
  Form("IntervalID") = Request.QueryString("IntervalID")
  
  Service.LoadJavaScriptCode  
  
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : OK_Click
' PARAMETERS : EventArg
' DESCRIPTION:
' RETURNS    : Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
    'On Error Resume Next
    
    Dim booRetVal
    booRetVal=true
        
    Dim objClient
    Set objClient = mom_GetUsageServerClientObject()

	objClient.SetIntervalAsBlockedForNewAccounts CLng(Form("IntervalID"))

    If(Err.Number)Then 
      EventArg.Error.Save Err 
      EventArg.Error.Description = EventArg.Error.Description
      booRetVal = False
    End If          
       
    OK_Click = booRetVal

END FUNCTION

%>


