<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: C:\mt\development\UI\MAM\default\dialog\AccountStateEdit.asp$
' 
'  Copyright 1998,2000,2001 by MetraTech Corporation
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
'  $Date: 11/19/2002 12:17:08 PM$
'  $Author: Frederic Torres$
'  $Revision: 7$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
    
' Mandatory
Form.Version        = MDM_VERSION     ' Set the dialog version
Form.RouteTo        = mam_GetDictionary("UPDATE_ACCOUNT_STATE_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
                  
 ' Fix for CR 11232
  Dim newDate
  newDate = DateSerial(request.QueryString("Year"), request.QueryString("Month"), request.QueryString("Day"))
 
  Set Form("CurrentState") = FrameWork.AccountCatalog.GetAccount(CLng(mam_GetSubscriberAccountID()), mam_ConvertToSysDate(CDate(newDate))).GetAccountStateMgr().GetStateObject()                    
  Form("Status")  = request.QueryString("Status")                    
  Form("OldDate") = CDate(newDate)
    
  ' Add dialog properties
  Service.Properties.Add "AccountStatus",    "String",      0,   TRUE, Empty 
  Service.Properties.Add "StartDate",        "String", 0,   TRUE, Empty    
  
  Service.Properties("AccountStatus").SetPropertyType "ENUM", FrameWork.Dictionary.Item("ACCOUNT_CREATION_SERVICE_ENUM_TYPE_LOADING").Value , "AccountStatus"	
      
	' Set Captions 
	Service.Properties("AccountStatus").caption = mam_GetDictionary("TEXT_NEW_ACCOUNT_STATE")
	Service.Properties("StartDate").caption = mam_GetDictionary("TEXT_START_DATE")
  
  Service.Properties("AccountStatus").Value = Form("Status")
'  If UCase(Service.Properties("AccountStatus").Value) = "PF" Then
'   ' allow back to active
'   Call mam_Account_LoadAccountStatusEnumTypeForEdit()
'   Service.Properties("AccountStatus").Enabled = TRUE
'  Else
    Service.Properties("AccountStatus").Enabled = FALSE
'  End IF
  
  Service.properties("StartDate").value = mam_FormatDate(CDate(Form("OldDate")), mam_GetDictionary("DATE_FORMAT")) 
  
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation

  ' Include Calendar javascript    
  mam_IncludeCalendar
		      
	Form_Initialize                   = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
    On Error Resume Next

   'Change Account state
    Form("CurrentState").ChangeState FrameWork.SessionContext, _
									 Nothing, _
									 CLng(mam_GetSubscriberAccountID()), _
									 -1, _
									 CStr(Service.Properties("AccountStatus")),  _
									 mam_NormalDateFormat(Service.Properties("StartDate").Value), _
									 CDate(0)
								
    If(CBool(Err.Number = 0)) then
        On Error Goto 0
        OK_Click = TRUE
    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Cancel_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean

  Cancel_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
'FUNCTION mam_Account_LoadAccountStatusEnumTypeForEdit()
'
'		Dim objNewAccountStatusEnumType
'		
'		Set objNewAccountStatusEnumType = mdm_CreateObject(CVariables)
'		
'		Select Case UCase(Form("CurrentState").Name)		
'				Case "PF"
'          If FrameWork.CheckCoarseCapability("Update account from pending final bill to active") Then         
'           	objNewAccountStatusEnumType.Add "Active"   ,"AC",,,"Active" 
'            objNewAccountStatusEnumType.Add "Closed"   ,"CL",,,"Closed" 
'            objNewAccountStatusEnumType.Add "Pending Final Bill"   ,"PF",,,"Pending Final Bill"             
'          End If
'		End Select
'   		
'	  Set Service("ACCOUNTSTATUS").EnumType.Entries = mdm_CreateObject(MSIXEnumTypeEntries) ' Create a blank enum type
'    Service("ACCOUNTSTATUS").EnumType.Entries.Populate objNewAccountStatusEnumType
'		
'		mam_Account_LoadAccountStatusEnumTypeForEdit = TRUE
'END FUNCTION
%>

