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
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Mandatory
Form.ServiceMsixdefFileName = mam_GetServiceDefForOperationAndType("Add", "SystemAccount") 
Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")

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
' RETURNS		: Return TRUE if ok else FALSE  `
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
   
	'	Service.Properties("Folder").Value = UCase(request.QueryString("IsFolder")) = "TRUE"
    Form("FolderID") = request.QueryString("FolderID")
    PopulateAncestorAccountInfo Form("FolderID")
           
    ' Add confirm Password property
    Service.Properties.Add "confirmPassword", "STRING", "32", TRUE, ""
    
    ' Populate the comboboxes  
    mam_Account_SetDynamicEnumType()
 
    ' Set properties before the dialog pops up    
    Service.Properties("ActionType").value               = Service.Properties("ActionType").EnumType("Both")
    Service.Properties("Operation").Value                = Service.Properties("Operation").EnumType("Add")
	  Service.Properties("_AccountId").Value 	             = MAM().CSR("_AccountId").Value
    Service.Properties("Name_Space").Value               = MAM_CSR_NAME_SPACE
    Service.Properties("timezoneoffset").Value           = -5
    Service.Properties("transactioncookie").Value        = "" 
		Service.Properties("BILLABLE").Enabled 							 = TRUE
    Service.Properties("AccountType").Value              = MAM_ACCOUNT_CREATION_ACCOUNT_TYPE_CSR
    Service.Properties("TaxExempt").Value                = FALSE
    Service.Properties("UsageCycleType").Value           = Service.Properties("UsageCycleType").EnumType.Entries("Monthly").Value
    Service.Properties("DayOfMonth").Value               = 31
    Service.Properties("PaymentMethod").Value            = Empty ' Service.Properties("PaymentMethod").EnumType.Entries(1).Value
    Service.Properties("ContactType").Value              = Service.Properties("ContactType").EnumType.Entries("Bill-To").Value    
    Service.Properties("TimeZoneId").Value               = "23" ' -- CSRs MUST have a timezone of GMT (Monrovia)  for version 2.0 --
    Service.Properties("country").Value                  = Empty ' No Country
    Service.Properties("AccountStatus").Value            = Service.Properties("AccountStatus").EnumType.Entries("Active").Value     
    
    Service.Properties("LoginApplication").Value         = Service.Properties("LoginApplication").EnumType.Entries("CSR").Value 
    
    Service.Properties("confirmPassword").Caption        = "Confirm Password" ' just to prevent localization errors in log
    SetRequiredProperties EventArg

    ' Include Calendar javascript    
    mam_IncludeCalendar
        
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
PRIVATE FUNCTION PopulateAncestorAccountInfo(lngParentFolderID)

    Dim objParentFolderYaac, strUserName, strNameSpace
    
    If IsNumeric(lngParentFolderID) And Len(lngParentFolderID) Then 
    
        Service.Properties("AncestorAccountID").Value = lngParentFolderID
        If CStr(lngParentFolderID) = CStr(MAM_HIERARCHY_ROOT_ACCOUNT_ID) Then
          Service.Properties("ancestorAccount").Value = mam_GetDictionary("TEXT_USERS") & " (" & MAM_HIERARCHY_ROOT_ACCOUNT_ID & ")"
        Else
          Service.Properties("ancestorAccount").Value = mam_GetFieldIDFromAccountIDAtTime(lngParentFolderID, mam_GetSystemUserHierarchyTime())
        End IF
    End If    
   ' Service.Properties("PAYMENT_STARTDATE").Value = CDate(mam_GetGMTDateFormatted())
   ' Service.Properties("PAYMENT_ENDDATE").Value   = Empty
    PopulateAncestorAccountInfo = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetRequiredProperties
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION SetRequiredProperties(EventArg) ' As Boolean

  Service.Properties("UserName").Required          = TRUE
  'Service.Properties("firstname").Required         = TRUE
  'Service.Properties("lastname").Required          = TRUE
  Service.Properties("confirmPassword").Required   = TRUE
  Service.Properties("password_").Required         = TRUE
     
  SetRequiredProperties = TRUE 
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Ok_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
FUNCTION Ok_Click(EventArg) ' As Boolean
        
    Dim strMessage

    OK_Click = FALSE
    
    'Get Ancestor Account ID, if exists
    Dim AncestorAccountID
    If Len(Service.Properties("AncestorAccount").value) Then
      If FrameWork.DecodeFieldID(Service.Properties("AncestorAccount").value, AncestorAccountID) Then
        Service.Properties("AncestorAccountID").value = AncestorAccountID
      Else
        Err.Number = 99
        Err.Description = "Parent Account must contain a valid account ID."
        EventArg.Error.Save Err
        Service.Properties("AncestorAccountID").Value = Empty 
        Exit Function  
      End If  
    Else
      Service.Properties("AncestorAccountID").Value = Empty     
    End If
    Service.Properties("AncestorAccount").value = Empty

    If Service.Properties("password_").Value = Service.Properties("confirmPassword").Value Then
    
      If(Not mam_Account_CheckIfEMailIsValid(EventArg))Then Exit Function

      mam_Account_SetToEmptyAllTheEmptyStringValue
      
      On Error Resume Next        
  	  Service.Meter TRUE
      If Err.Number Then
      
          mdm_MeteringTimeOutManager  Service , _
                                FrameWork.Dictionary.Item("METERING_TIME_OUT_MANAGER_DIALOG").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_TIME_OUT").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_SUCCEEDED").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_WILL_BE_EXECUTED_LATED").Value , _
                                Form.RouteTo    
      
          EventArg.error.Save Err
          Err.Clear
      Else
        
        ' Got to confirm dialog
        strMessage    = Replace(mam_GetDictionary("TEXT_CONFIRM_ADD_CSR"), "[ACCOUNT]", Service.Properties("UserName").Value)
        form.routeto  = mam_ConfirmDialogEncodeAllURLNoRefresh( mam_GetDictionary("TEXT_CONFIRM_ADD_CSR_TITLE"), strMessage, form.routeto )
        OK_Click      = TRUE
      End If
      On Error Goto 0      
    Else           
       EventArg.Error.Number = 1001 ' Error password not confirmed
       EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1001")
    End If

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Cancel_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean
  Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
  Cancel_Click = TRUE
END FUNCTION
%>

