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
'  Created by: Rudi
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
Form.RouteTo			              = mom_GetDictionary("INTERVAL_MANAGEMENT_DIALOG")
Form.Modal=true

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
                  
  'Service.Properties.Add "nm_space"     , "string", 40, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  'Service.Properties.Add "tx_desc"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "newState" , "string", 40 , TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE

  'Service.Properties.Add "Interval" , "integer", 40 , TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  
  Form("IntervalID")=request("IntervalID")
  Form("State")=request("State")
  
  mdm_GetDictionary().Add "INTERVAL_STATE_NAME", request("StateName")
  mdm_GetDictionary().Add "INTERVAL_STATE", request("State")
  mdm_GetDictionary().Add "SHOW_ALL_INTERVAL_STATES", request("ShowAllStates")
  if lcase(request("IntervalActive"))="true" and request("State") = "1" then
    mdm_GetDictionary().Add "SHOW_INTERVAL_ACTIVE_STATE_WARNING", 1
  else
    mdm_GetDictionary().Add "SHOW_INTERVAL_ACTIVE_STATE_WARNING", 0
  end if
  Service.Properties("newState").AddValidListOfValues Array(0,1,2,3,4,5),Array("New", "Open", "Soft Close Pending", "Soft Closed", "Hard Close Pending", "Hard Closed")
  
  
  ' We only accept the following chars
  'Service("nm_space").StringID = TRUE
  Service.LoadJavaScriptCode  
  
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    'On Error Resume Next
    
    'response.write("new state is:" & Service("newState"))
    'response.end
    
    Dim booRetVal    
    dim objUsageServer
    set objUsageServer = CreateObject("COMUsageServer.COMUsageServer.1")

    'wscript.echo "Testing UsageServer.SetIntervalState"
    objUsageServer.SetUsageIntervalState Form("IntervalID"), Service("newState")

    
    'booRetVal = Service.Tools.ExecSQL(mom_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH"), "__ADD_NAME_SPACE__", objRowset, "NM_SPACE", Service("NM_SPACE"), "TX_DESC", Service("TX_DESC"), "TX_TYP_SPACE", Service("TX_TYP_SPACE"))
    If true then '(booRetVal) then
        
        OK_Click = TRUE
    Else            
        EventArg.Error.Description = mom_GetDictionary("MOM_ERROR_1006")
        OK_Click = FALSE
    End If
    Err.Clear   
END FUNCTION

%>


