<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: C:\mt\development\UI\MAM\default\dialog\AccountStateUpdate.asp$
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
'  $Date: 11/19/2002 12:17:09 PM$
'  $Author: Frederic Torres$
'  $Revision: 13$
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
        
  Dim objTempYAAC
  'Set objTempYAAC = FrameWork.AccountCatalog.GetAccount(CLng(mam_GetSubscriberAccountID()), CDate(mam_GetDictionary("END_OF_TIME")))
  Set objTempYAAC = FrameWork.AccountCatalog.GetAccount(CLng(mam_GetSubscriberAccountID()), mam_ConvertToSysDate(Session("MAX_END_DATE")))
  
  Set Form("CurrentState") = objTempYAAC.GetAccountStateMgr().GetStateObject()    
    
  ' Add dialog properties
  Service.Properties.Add "CurrentStatus",    "String",      0,   TRUE, Empty
  Service.Properties.Add "AccountStatus",    "String",      0,   TRUE, Empty 
  Service.Properties.Add "StartDate",        "String", 0,   TRUE, Empty    
  
  Service.Properties("AccountStatus").SetPropertyType "ENUM", FrameWork.Dictionary.Item("ACCOUNT_CREATION_SERVICE_ENUM_TYPE_LOADING").Value , "AccountStatus"
  Service.Properties("CurrentStatus").SetPropertyType "ENUM", FrameWork.Dictionary.Item("ACCOUNT_CREATION_SERVICE_ENUM_TYPE_LOADING").Value , "AccountStatus"
    
  ' Get list of possible states we can change to
  Call mam_Account_LoadAccountStatusEnumTypeForUpdate()
    
	' Set Captions 
  Service.Properties("CurrentStatus").caption = mam_GetDictionary("TEXT_CURRENT_ACCOUNT_STATE") 
	Service.Properties("AccountStatus").caption = mam_GetDictionary("TEXT_NEW_ACCOUNT_STATE")
	Service.Properties("StartDate").caption = mam_GetDictionary("TEXT_START_DATE")
	
  ' Get Current State and disable dropdown
  Service.Properties("CurrentStatus").Value = Form("CurrentState").Name
  Service.Properties("CurrentStatus").Enabled = FALSE
     
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
									 mam_DateFromLocaleString(Service.Properties("StartDate").Value), _
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

'      <enum name="AccountStatus">
'          <description></description>
'          <entries>
'            <entry name="PendingActiveApproval">
'              <value>PA</value>
'            </entry>
'            <entry name="Active">
'              <value>AC</value>
'            </entry>
'            <entry name="Suspended">
'              <value>SU</value>
'            </entry>
'            <entry name="PendingFinalBill">
'              <value>PF</value>
'            </entry>
'            <entry name="Closed">
'              <value>CL</value>
'            </entry>
'            <entry name="Archived">
'              <value>AR</value>
'            </entry>
'            <!-- TODO - RVM: To be taken out later -->
'            <entry name="Inactive">
'              <value>I</value>
'            </entry>
'            <entry name="Pending">
'              <value>P</value>
'            </entry>
'            <!-- TODO - RVM: To be taken out later -->
'          </entries>
'        </enum>

FUNCTION mam_Account_LoadAccountStatusEnumTypeForUpdate()

		Dim objNewAccountStatusEnumType
		
		Set objNewAccountStatusEnumType = mdm_CreateObject(CVariables)

		Select Case UCase(Form("CurrentState").Name)		
        Case "PA"
              
         'If FrameWork.CheckCoarseCapability("Update account from pending active approval to active") Then         
           	objNewAccountStatusEnumType.Add "Active"   ,"AC",,,"Active" 
         ' End If
				Case "AC"
          If FrameWork.CheckCoarseCapability("Update account from active to suspended") Then 
        	  objNewAccountStatusEnumType.Add "Suspended","SU",,,"Suspended"
          End If
          If FrameWork.CheckCoarseCapability("Update account from active to closed") Then 
            objNewAccountStatusEnumType.Add "Closed"   ,"CL",,,"Closed" 
          End If
				Case "SU"
          If FrameWork.CheckCoarseCapability("Update account from suspended to active") Then         
           	objNewAccountStatusEnumType.Add "Active"   ,"AC",,,"Active" 
          End If
				Case "PF"
          If FrameWork.CheckCoarseCapability("Update account from pending final bill to active") Then         
           	objNewAccountStatusEnumType.Add "Active"   ,"AC",,,"Active" 
          End If          
		End Select
   		
	  Set Service("ACCOUNTSTATUS").EnumType.Entries = mdm_CreateObject(MSIXEnumTypeEntries) ' Create a blank enum type
    Service("ACCOUNTSTATUS").EnumType.Entries.Populate objNewAccountStatusEnumType
		
		mam_Account_LoadAccountStatusEnumTypeForUpdate = TRUE
END FUNCTION
%>

