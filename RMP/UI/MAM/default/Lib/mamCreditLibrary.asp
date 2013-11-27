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
' MAM Credit Library
' 
' MODULE	    :
' DESCRIPTION	: This file use the mdm.asp file and mamLibrary.asp file. So these file must be included
'                 before this one.
' AUTHOR	    :
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_IssueCreditEMailNotification()
' DESCRIPTION	: The function may raise an error too. If the strSubscriberEMailAddress returns true.
' PARAMETERS	:
'                 strSubscriberFullName - Is not used
' RETURNS		: TRUE if ok
Function mam_IssueCreditEMailNotification(strSubscriberFullName,strSubscriberEMailAddress) ' As Boolean

    Dim strErrorMessage
    Dim strTemplateFileName
    
    If(Len(CStr("" & strSubscriberEMailAddress)))Then
      
        If(Service("_Amount").Operation("<=",0))Then
        
            Service("_Amount").Operation "*",-1 
        End If
        
        If(Service("RequestAmount").Operation("<=",0))Then
      
            Service("RequestAmount").Operation "*",-1 
        End If
        
        If(Service("Status")=eCREDIT_REQUEST_PENDING_DENIED)Then
        
            strTemplateFileName = mam_GetMAMFolder() & "\" & mam_GetDictionary("ISSUE_CREDIT_EMAIL_TEMPLATE_DENIED") ' "
        Else
            strTemplateFileName = mam_GetMAMFolder() & "\" & mam_GetDictionary("ISSUE_CREDIT_EMAIL_TEMPLATE_APPROVED") ' "
        End If

        On Error Resume Next
        mam_IssueCreditEMailNotification	=	Service.SendTemplatedEMail(strTemplateFileName,strSubscriberEMailAddress)
        On Error Goto 0        
    Else
        mam_IssueCreditEMailNotification	=	TRUE
    End If
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_TestAndSendCreditEMailNotification()
' DESCRIPTION	: This function is called by the dialogs : DefaultDialogIssueCreditFromRequest.tpl.asp and DefaultDialogIssueCredit.tpl.asp.
'               In this dialog we need to pass the language because MAM
' PARAMETERS	:
' RETURNS		: TRUE if ok
FUNCTION mam_TestAndSendCreditEMailNotification(strSubscriberFullName,strSubscriberLanguage,dblAmount) ' As Boolean

    If(Service.Properties("EMailNotification").BooleanValue)Then ' Use BooleanValue to support old and new msix boolean
    
        mam_TestAndSendCreditEMailNotification = mam_IssueCreditEMailNotification(strSubscriberFullName,Service("EMailAddress"))
    Else        
        mam_TestAndSendCreditEMailNotification = TRUE
    End If    
END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_SetTemporaryEnumTypeForAccountCredit
' DESCRIPTION	: Because AccountCredit and AccountCrediyRequest Status and Reason are
'               not set as enum type but string in the service definition. 
'               We set the enum type dynamically for the time of the UI
' PARAMETERS	:
' RETURNS		  :
FUNCTION mam_SetTemporaryEnumTypeForAccountCredit() ' As Boolean

    Service("Status").SetPropertyType  "ENUM",  "metratech.com",  "SubscriberCreditAccountRequestStatus"      
    'Service("Reason").SetPropertyType  "ENUM",  "metratech.com",  "SubscriberCreditAccountRequestReason"    
    
    If(Service("Status").EnumType.Entries.Exist("Pending"))Then
    
        Service("Status").EnumType.Entries.Remove Service("Status").EnumType("Pending").Name
    End If
    mam_SetTemporaryEnumTypeForAccountCredit = TRUE
END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_SetTemporaryEnumTypeForAccountCredit
' DESCRIPTION	:
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION CheckIfEMailIsRequiredAndBlank(EventArg) ' As Boolean

    CheckIfEMailIsRequiredAndBlank = FALSE
    
    If(Service.Tools.BooleanValue(Service("EMailNotification")))Then
    
        If(Len(TRIM(Service("EMailAddress")))=0)Then
        
            EventArg.Error.Description      = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1003")
            CheckIfEMailIsRequiredAndBlank  = TRUE
        End If
    End If
END FUNCTION

%>
