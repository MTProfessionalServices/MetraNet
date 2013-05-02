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
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Mandatory
Form.ServiceMsixdefFileName 			= mam_GetAccountCreationMsixdefFileName()
Form.RouteTo											= Mam().dictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION			:  Form_Initialize
' PARAMETERS		:  EventArg
' DESCRIPTION 	:
' RETURNS 			:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

	Service.Clear 	' Set all the property of the service to empty.
									' The Product view if allocated is cleared too.

	InitializeServiceUpdatingAccount

	Service.Properties("password_").Value 		 = Service.Tools.GeneratePassword()

	' Store the generated pass word in the page so FredRunner can read and test the pass word...
	Service.Properties.Add "GeneratedPassWord" , "String" , 255, False,EMpty
	Service.Properties("GeneratedPassWord").Value = Service.Properties("password_").Value
	Service.Properties("GeneratedPassWord").Caption = "Dummy"

  Service.Properties("AccountStartDate").Value = Empty
  Service.Properties("hierarchy_startdate").Value = Empty          
  Service.Properties("hierarchy_enddate").Value = Empty 
  
	Service.Configuration.CheckRequiredField = FALSE

	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:	Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

		On Error Resume Next

		'mam_Account_UpDateMeteringAccordingIfThereIsOrNotContact
		

		Service.Meter TRUE
		If(CBool(Err.Number = 0)) then

				On Error Goto 0

				If(SendGeneratePasswordEMail(EventArg))Then

						Form.RouteTo	= mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_GENERATE_PASSWORD"), mam_GetDictionary("TEXT_INFO_SUCCEFULLY_UPDATED"), Form.RouteTo)
				Else
						' Tell the user that the new pass word was set but the email notification failed
						Form.RouteTo	= mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_GENERATE_PASSWORD"), mam_GetDictionary("TEXT_INFO_SUCCEFULLY_UPDATED") & FrameWork.GetHTMLDictionaryError("MAM_ERROR_1011"), Form.RouteTo)
						OK_Click			= TRUE
				End If
				OK_Click				= TRUE
		Else
    
          mdm_MeteringTimeOutManager  Service , _
                                FrameWork.Dictionary.Item("METERING_TIME_OUT_MANAGER_DIALOG").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_TIME_OUT").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_SUCCEEDED").Value & "<BR>" & FrameWork.Dictionary.Item("TEXT_PLEASE_RELOAD_THE_ACCOUNT").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_WILL_BE_EXECUTED_LATED").Value , _
                                Form.RouteTo      
    
				EventArg.Error.Save Err
				OK_Click = FALSE
		End If
		Err.Clear

END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: NotifySubscriberWithEMail()
' DESCRIPTION : The function may raise an error too. If the strSubscriberEMailAddress returns true.
' PARAMETERS	:
' RETURNS 		: TRUE if ok
PRIVATE FUNCTION SendGeneratePasswordEMAIL(EventArg) ' As Boolean

		Dim strTemplateFileName

		If(Service("EMailNotification"))Then

				strTemplateFileName = mam_GetMAMFolder() & "\" & mam_GetDictionary("GENERATE_PASSWORD_EMAIL_TEMPLATE") ' "

				' Add this for the email template
				Service.Properties.Add "Time" 	 , "String"  , 255, False, FrameWork.MetraTimeGMTNow()
				Service.Properties("Time").Caption = "Dummy Time"

				On Error Resume Next
				Service.SendTemplatedEMail strTemplateFileName, "" & Service("EMAIL").Value,,,Service.Properties("Language").Value
				SendGeneratePasswordEMAIL = CBool(Err.Number=0)
				On Error Goto 0
				
		Else
				SendGeneratePasswordEMAIL = TRUE ' If the csr select email notification = no we just return TRUE
		End If
		
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: NotifySubscriberWithEMail()
' DESCRIPTION : The function may raise an error too. If the strSubscriberEMailAddress returns true.
' PARAMETERS	:
' RETURNS 		: TRUE if ok
PRIVATE FUNCTION InitializeServiceUpdatingAccount() ' As Boolean

				'MAM().Subscriber.CopyTo Service.Properties	 ' Copy all the data from the MAM subscriber object into the Service object so
        
        mam_PrepareServiceForQuickUpdateAccount

				If(Not Service.Properties.Exist("EMailNotification"))Then

						Service.Properties.Add "EMailNotification"				, "Boolean" , 00 , False, mam_GetDictionary("DEFAULT_DEFAULT_ADD_ACCOUNT_EMAIL_NOTIFICATION")  ' Add the EMail Notification on the fly
						Service("EMailNotification").Value		= CBool(Len("" & MAM().Subscriber("EMail").Value)) ' If the subscriber has an email we select email notification = yes
				        Service("EMail").Value = MAM().Subscriber("EMail").Value
				End If

				'Service.Properties("timezoneoffset").Value 			= -5
				'Service.Properties("transactioncookie").Value		= ""

				' Default Properties Initialization
				Service.Properties("ActionType").value					 = Service.Properties("ActionType").EnumType.Entries("account").Value
				Service.Properties("Operation").Value 					 = Service.Properties("Operation").EnumType.Entries("Update").Value
        Service.Properties("UserName").Value 					   = MAM().Subscriber("UserName").Value
        Service.Properties("_AccountID").Value 					 = MAM().Subscriber("_AccountID").Value
        Service.Properties("Billable").Value 					   = MAM().Subscriber("Billable").Value
        Service.Properties("Name_Space").Value 					 = MAM().Subscriber("Name_Space").Value
      	Service.Properties("AccountType").Value 				 = MAM().Subscriber("AccountType").Value
        Service.Properties("Language").Value             = MAM().Subscriber("Language").Value


				' Bill-To only in this dialog
				Service.Properties("ContactType").Value = Service.Properties("ContactType").EnumType.Entries("Bill-To").Value

				InitializeServiceUpdatingAccount = TRUE
END FUNCTION


%>

