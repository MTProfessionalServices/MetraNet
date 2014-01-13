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
' DIALOG	:
' DESCRIPTION	:
' AUTHOR	:
' VERSION	:
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit 
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamCreditLibrary.asp" -->

<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
' Mandatory Constants
Form.ServiceMsixdefFileName 	    = "metratech.com\AccountCredit.msixdef" 	' Set the service definition msixdef file name
Form.RouteTo			                = mam_GetDictionary("WELCOME_DIALOG")

Form.MsixdefExtension             = "Core"

mdm_Main ' Invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION 	:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	  Service.Clear 	' Set all the property values of the service to empty.
                    ' The Product view if defined is cleared too.
			
		Service.Properties.Add "MAX_AUTHORIZED_AMOUNT"  , "String" , 255 , False, Empty ' String because display purpose only
		
		' Get the max amount of credit the csr can issue
  	Service.Properties("MAX_AUTHORIZED_AMOUNT").Value = FrameWork.GetDecimalCapabilityMaxAmountAsString("Apply Adjustments",mam_GetDictionary("SUPER_USER_ISSUE_CREDITS_MAX_AMOUNT"))
		
  	Service.Properties("CreditTime").Value 	          = FrameWork.MetraTimeGMTNow()
  	Service.Properties("_AccountID").Value 	          = MAM().Subscriber("_AccountId")
  	Service.Properties("_Currency").Value 	          = MAM().Subscriber("Currency")
  	Service.Properties("EMailAddress").Value          = MAM().Subscriber("EMail")
  	Service.Properties("Issuer").Value 		            = MAM().CSR("_AccountId")
  	Service.Properties("AccountingCode").Value        = ""
    Service.Properties("RequestID").Value             = -1 ' -1 mean that the credit has no credit request...
    Service.Properties("EMailText").Value             = ""
    
    ChangeEMailNotificationTypeFromStringToBoolean TRUE
    
    ' Set a value to this properties because they are required and not part
    ' of the UI. So when then MDM check for all required properties set,
    ' it raises an error. which a I do not want...
    Service.Properties("RequestAmount").Value 	      =     0
    Service.Properties("CreditAmount").Value 	        =     0
    
    mam_SetTemporaryEnumTypeForAccountCredit          ' Set the enum type on the fly while waiting for boris
    Service.Properties("Status").Value                = Service.Properties("Status").EnumType.Entries("Approved").Value
    
    Service.Properties("ContentionSessionID").Value   = "-"   ' Old stuff from 1.2
    Service.Properties("ReturnCode").Value            = 0     ' Old stuff from 1.2   
       
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Ok
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Dim booTmpValue
    
    Ok_Click = FALSE
    
       
    ' Convert EMailNotification from Boolean to Char (Y,N)
    booTmpValue = Service.Properties("EMailNotification").Value
    Service.Properties("EMailNotification").SetPropertyType MSIXDEF_TYPE_STRING ' Turn it into a boolean so it can support a check box
    Service.Properties("EMailNotification").Value     = IIF(booTmpValue,"Y","N")

    If(CheckIfEMailIsRequiredAndBlank(EventArg))Then 
    
        ChangeEMailNotificationTypeFromStringToBoolean FALSE ' Convert EMailNotification from string to Boolean 
        Exit Function
    End If        
    
    If(Len(Service.Properties("EmailAddress").Value))Then
    
    	  If(Not Service.Tools.EMailAddressValid(Service.Properties("EMailAddress").Value))Then
    
	    	    EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1000")
            ChangeEMailNotificationTypeFromStringToBoolean FALSE ' Convert EMailNotification from string to Boolean 
    		    Exit Function
    	  End If
    End If
    
    ' Set all to the same value here and all 0<
    Service.Properties("_Amount").Operation "*",-1 ' Support DECIMAL
    Service.Properties("RequestAmount").Value 	    =     Service.Properties("_Amount").Value
    Service.Properties("CreditAmount").Value 	      =     Service.Properties("_Amount").Value

    On Error Resume Next
    
    Dim objOutputSession
    Dim booOk
    
    booOK = Service.Meter(True,objOutPutSession)
    
    If(CBool(Err.Number = 0)) then
    
        On Error Goto 0
        
        'If the status is still pending, then there was an auth failure and a credit request was credit by the
        'pipeline.  This request needs to be approved/denied by a CSR with the appropriate capability.
        Dim strStatus
        
        'Get the output parameter
        strStatus = objOutPutSession.GetProperty("Status")
        
        'If pending, display a message to the user
        if UCase(strStatus) = UCase("Pending") then
          Const TEMPMESSAGE = "The account credit auth/auth check failed, so a credit request was created."
          Form.RouteTo      = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_ISSUE_CREDIT_TITLE"), TEMPMESSAGE, Form.RouteTo)        
          OK_Click          = true
          Exit Function
        end if
        
        ' THE BUG HAS BEEN FIXED IN MDM 2.1
        ' While the property is converted back to a string the enumtype property is still valid and will be used in the next
        ' function mam_TestAndSendCreditEMailNotification(); Since it is the end of 2.0 I do not want to change the function
        ' MSIXHandler.SetPropertyType, but the function should do first thing is clear the property enum type...
        ' Set Service.Properties("EMailNotification").EnumType = Nothing
        
        Service.Properties("_Amount").Operation "*",-1 ' Support DECIMAL
        
        If(mam_TestAndSendCreditEMailNotification(MAM().CSR("LastName") & " " & MAM().Subscriber("FirstName"), MAM().Subscriber("Language"), CStr(Service.Properties("_Amount"))))Then
        
            Form.RouteTo    = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_ISSUE_CREDIT_TITLE"), mam_GetDictionary("TEXT_ISSUE_CREDIT_CONFIRM"), Form.RouteTo)        
            OK_Click        = TRUE
        Else

            Form.RouteTo    = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_ISSUE_CREDIT_TITLE"), mam_GetDictionary("TEXT_ISSUE_CREDIT_CONFIRM") & FrameWork.GetHTMLDictionaryError("MAM_ERROR_1011"), Form.RouteTo)
            OK_Click        = TRUE
        End If                
    Else
        Service.Properties("_Amount").Operation "*",-1 ' Support DECIMAL
        EventArg.Error.Save Err  
        
        'If  EventArg.Error.Err=-2147467259 Then ' Because the error is not properly documented in the mt_global_msg.dll this will occur in mile stone 2        
        '    EventArg.Error.LocalizedDescription = EventArg.Error.Description
        'End If
        OK_Click = FALSE
        ChangeEMailNotificationTypeFromStringToBoolean FALSE ' Convert EMailNotification from string to Boolean 
    End If
    Err.Clear
    
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ChangeEMailNotificationTypeFromStringToBoolean
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION ChangeEMailNotificationTypeFromStringToBoolean(booSetValueBasedOnEMailAddr) ' As Boolean

    ' I do it this way because in 1.2 and 1.3 service, this field is a string 1 -  old way to support boolean
    ' Convert EMailNotification from Char (Y,N) to Boolean
    Service.Properties("EMailNotification").SetPropertyType MSIXDEF_TYPE_BOOLEAN ' Turn it into a boolean so it can support a check box
    If(booSetValueBasedOnEMailAddr)Then
    
        Service.Properties("EMailNotification").Value     = CBool(Len("" & Service.Properties("EMailAddress").Value))
    End If
END FUNCTION

%>

