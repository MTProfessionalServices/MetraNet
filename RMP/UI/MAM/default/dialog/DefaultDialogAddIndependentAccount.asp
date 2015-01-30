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
<!-- #INCLUDE FILE="../../default/Lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../default/lib/CAccountTemplateHelper.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.Version                  = MDM_VERSION ' Set the dialog as a MDM Version 2.0 Dialog
Form.ServiceMsixdefFileName 	= mam_GetAccountCreationMsixdefFileName()
Form.RouteTo			            = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : Form_Initialize
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Form_Initialize = FALSE
    
  	Service.Clear

    mam_Account_AddDynamicProperties
    mam_Account_SetDynamicEnumType
    mam_Account_SetGoodEnumTypeValueToUsageCycleType
    
    InitializeServiceForAddingANewAccount

    mam_Account_SetSubscriberAccountType
				
    'Hierarchy Parent
		Service.Properties("Folder").Value = UCase(request.QueryString("IsFolder")) = "TRUE"

    PopulateAncestorAccountInfo request.QueryString("FolderID")

		mam_Account_GetDefaultsFromTemplate request.QueryString("FolderID")
		
    SetRequiredProperties(EventArg) 
    
    Form("AddUpdateMode") = "Add"

    ' Populate Default Account Pricelist
    PopulateDefaultAccountPricelist

    ' Include Calendar javascript    
    mam_IncludeCalendar
    
    'Check default security policy, only if folder ID is passed
    if len(request.QueryString("FolderID")) > 0 then
      Call CheckDefaultPolicy()
    else
      'Blank the security policy message
      Call Service.Properties.Add("SecurityPolicyMessage" , "String"  , 256 , false, Empty)
      Service.Properties("SecurityPolicyMessage").Value = ""
      Service.Properties("SecurityPolicyMessage").Caption = ""
      Service.Properties("ApplyDefaultSecurityPolicy").Value = false            
    end if
    
    mam_Account_CleanStatusReasonEnumTypeForAddingAccount
		  
    Form_Initialize = Form_Refresh(EventArg)
    
END FUNCTION

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : CheckDefaultPolicy()                                        '
' Description : Check to see if any roles have been setup for the default   '
'             : security policy.  If not, display a warning message.        '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function CheckDefaultPolicy()
  Dim objAuthAccount
  Dim objPolicy
  
  'Do nothing if adding corporate account
  if CLng(request.QueryString("FolderID")) = MAM_HIERARCHY_ROOT_ACCOUNT_ID then
   Service.Properties("ApplyDefaultSecurityPolicy").Enabled = false
   Service.Properties("ApplyDefaultSecurityPolicy").Value = false
   Exit Function 
  end if
  
  Call Service.Properties.Add("SecurityPolicyMessage" , "String"  , 256 , false, Empty)

  On error resume next
  Set	objAuthAccount  = FrameWork.Policy.GetAccountByID(FrameWork.SessionContext, CLng(request.QueryString("FolderID")), mam_ConvertToSysDate(mam_GetHierarchyTime()))
  If err.number <> 0 then
    Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"),  mam_GetDictionary("SUBSCRIBER_FOUND"))
  End If
  On error goto 0     
  
  Set objPolicy       =  objAuthAccount.GetDefaultPolicy(FrameWork.SessionContext)
  
  'If there are no role, get the message
  if objPolicy.GetRolesAsRowset().RecordCount > 0 then
    Service.Properties("ApplyDefaultSecurityPolicy").Enabled = true
    Service.Properties("SecurityPolicyMessage").Value = ""
  else
    Service.Properties("ApplyDefaultSecurityPolicy").Enabled = false
    Service.Properties("ApplyDefaultSecurityPolicy").Value = false
    Service.Properties("SecurityPolicyMessage") = "<div class=""clsNavy"">" & mam_GetDictionary("TEXT_NO_DEFAULT_SECURITY_POLICY_ROLES") & "</div>"
  end if

End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
PRIVATE FUNCTION PopulateAncestorAccountInfo(lngParentFolderID)

    Dim objParentFolderYaac, strUserName, strNameSpace
    
    If IsNumeric(lngParentFolderID) And Len(lngParentFolderID) Then 
    
        Service.Properties("AncestorAccountID").Value = lngParentFolderID
        If CStr(lngParentFolderID) = CStr(MAM_HIERARCHY_ROOT_ACCOUNT_ID) Then
         Service.Properties("ancestorAccount").Value = mam_GetDictionary("TEXT_CORPORATE_ACCOUNT") & " (" & MAM_HIERARCHY_ROOT_ACCOUNT_ID & ")"
        Else
          mam_GetUserNameNameSpaceFromAccountID lngParentFolderID, strUserName, strNameSpace
          Service.Properties("ancestorAccount").Value = mam_GetFieldIDFromAccountID(lngParentFolderID)
        End IF
    End If   
    Service.Properties("PAYMENT_STARTDATE").Value = CDate(mam_GetGMTDateFormatted())
    Service.Properties("PAYMENT_ENDDATE").Value   = Empty
    PopulateAncestorAccountInfo = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetRequiredProperties
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION SetRequiredProperties(EventArg) ' As Boolean

  Service.Properties("UserName").Required          = TRUE
  Service.Properties("PassWord_").Required         = TRUE
 
  SetRequiredProperties = TRUE 
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Refresh
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean
    mam_Account_SetBillingCycleEnumType
    
    ' Populate Default Account Pricelist
    PopulateDefaultAccountPricelist
   
    Form_Refresh = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Paint
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Paint(EventArg) ' As Boolean

	  Form_Paint = AddUpdateAccount_FormPaint(EventArg) ' Share this event with DefaultDialogUpdateAccount.asp - see accountlib.asp
    mdm_GetDictionary().Add "LOGINVALIDATEDMESSAGE", ""
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ValidateLogin_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION ValidateLogin_Click(EventArg)

    ' If the login exist then the login is not valid
    If(Len(Service("UserName")) > 0) Then
    
      If(mam_ExistLogin(Service("UserName"),Service("Name_Space")))Then
      
              mdm_GetDictionary().Add "LOGINVALIDATEDMESSAGE", mam_GetDictionary("TEXT_ADD_ACCOUNT_LOGIN_NOT_VALIDATED")
      Else
              mdm_GetDictionary().Add "LOGINVALIDATEDMESSAGE", mam_GetDictionary("TEXT_ADD_ACCOUNT_LOGIN_VALIDATED")
      End If        
    Else
        mdm_GetDictionary().Add "LOGINVALIDATEDMESSAGE", mam_GetDictionary("TEXT_ADD_ACCOUNT_LOGIN_NOT_VALIDATED")
    End If
    ValidateLogin_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

    Dim lngNewAccountId  ' As Long
    Dim objOutPutSession ' As COMMeterLib.Session
    Dim strNewRouteToPage
    Dim booOK
    Dim strError
    Dim strLanguage
    Dim strRouteTo
    Dim objPriceListEnumTypeBackUp ' We store a ref from the enum type price list, because we going to clear it, but is case of an error we need to restore it...
    
    booOK               = FALSE
    OK_Click            = FALSE
    lngNewAccountId     = 0

    mam_Account_UpDateMeteringAccordingIfThereIsOrNotContact
    ' MAM 3.0 - We have to meter both to force the creation of the record in t_av_contact
	' This way, we dont have to change a lot of code in the backend.  This is good for
	' performance reasons as well, because an additional select would not have to be done
	' to retrieve the properties.  Additionally, an extra record in the database with all
	' null values, hopefully should not change the disk storage situation.
	Service.Properties("ActionType").value = Service("ActionType").EnumType.Entries("Both")
	
	
    ClearPriceListIfValueIsNone objPriceListEnumTypeBackUp

    If(CheckIfEMailIsRequiredAndBlank(EventArg)       )Then Exit Function
    If(Not mam_Account_CheckBillingCycleRule(EventArg))Then Exit Function
    If(Not mam_Account_CheckIfEMailIsValid(EventArg)  )Then Exit Function
        
    mam_Account_UpdateBiWeeklyProperties
            
    If(Not ValidatePassWord(EventArg))Then Exit Function ' If confirmed password is not equal to password we return to the dialog 
    
    mam_Account_SetToEmptyAllTheEmptyStringValue

    If Not mam_Account_ProcessFieldsID() Then Exit Function ' The error message is taken care of.

    If Not mam_Account_SetSubscriberAccountType Then Exit Function
    
    On Error Resume Next
    booOK = Service.Meter(True,objOutPutSession)
    
	  If(booOK)Then

          On Error Goto 0

          If(IsValidObject(objOutPutSession))Then
          
              Err.Clear
              lngNewAccountId 									= objOutPutSession.GetProperty("_AccountId")  ' Read the service output parameter
							Service.Properties("_AccountID") 	= lngNewAccountId ' Set the  new AccountID , next dialogs will use it -- MAM 3.0
              
              If(Err.Number=0)Then
              
                  mdm_LogWarning "Account Created. AccountId=" & lngNewAccountId
                  
                  ' Call the function AddPrimaryAlias() and update the status, stored in the property MappingAddedSucceed
                  Service("MappingAddedSucceed") = IIF(AddPrimaryAlias(EventArg) , mam_GetDictionary("TEXT_OK") , mam_GetDictionary("TEXT_FAILED"))
                  If(Len(Service("PrimaryAlias"))=0)Then
                  
                      Service("MappingAddedSucceed") = mam_GetDictionary("TEXT_NONE") '  Clear the field because there is no mapping and I do not want to print SUCCEED
                  End If
                  
                  If(Service("EMailNotification"))And(Len(Service("EMail")))Then ' EMail Notification
                      
                      ' Retreive the enum type language name
                      strLanguage = Service("Language").EnumType.Entries.ItemByValue(Service("Language")).name

                      ' Call the email notification and set the Succeed or Fail message
                      Service("EMailNotificationStatus") = IIF(mam_AddAccountEMailNotification(strLanguage),mam_GetDictionary("TEXT_SUCCEED"),FrameWork.GetHTMLDictionaryError("MAM_ERROR_1011"))
                  End If
                  
                  ' Goto the confirm dialog 
                  ' Store the service for the next dialog. The next dialog will free this instance
                  Set Session(MAM_SESSION_NAME_LAST_ADDED_ACCOUNT_SERVICE) = Service
                  
                  ' If we added a corporate account call the refresh cache method
                  Dim ancestorID 
                  FrameWork.DecodeFieldID Service.Properties("ancestorAccount"), ancestorID
                  If CLng(ancestorID) = MAM_HIERARCHY_ROOT_ACCOUNT_ID and CBool(Service("folder")) Then
                  
                      FrameWork.AccountCatalog.Refresh()
                      Set Session("CSR_YAAC") = FrameWork.AccountCatalog.GetActorAccount()
                  End If
                  If(Err.Number=0)Then
                  
                      Form.RouteTo        =   mam_GetDictionary("ADD_ACCOUNT_CONFIRM_INFO_DIALOG") & "?Parent=" & Service.Properties("AncestorAccountID").value
                      OK_Click            =   TRUE
                      Exit Function
                  Else
                      EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1032") ' If we are unable to refresh account catalog
                  End IF
              Else                   
                  EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1019") ' This error will never occur but...
              End If
          Else          
              EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1018") ' This error will never occur but...
          End If
    Else

        mdm_MeteringTimeOutManager  Service , _
                                    FrameWork.Dictionary.Item("METERING_TIME_OUT_MANAGER_DIALOG").Value , _
                                    FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_TIME_OUT").Value , _
                                    FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_SUCCEEDED").Value & "<BR>" & FrameWork.Dictionary.Item("TEXT_PLEASE_RELOAD_THE_ACCOUNT").Value , _
                                    FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_WILL_BE_EXECUTED_LATED").Value , _
                                    Form.RouteTo
    
        If Err.Number = AccountCreationService_ERROR_MAPPING_ALREADY_EXIST Then
        
            EventArg.Error.Save Err ' If the metering failed...        
            EventArg.Error.LocalizedDescription = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1022")
        Else
        
            EventArg.Error.Save Err ' If the metering failed...        
        End If        
	  End If
    mdm_LogError EventArg.Error.ToString()
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PRIVATE FUNCTION CheckIfEMailIsRequiredAndBlank(EventArg) ' As Boolean

  CheckIfEMailIsRequiredAndBlank = FALSE
  
  If(Service("EMailNotification"))Then
  
      If(Len(TRIM(Service("EMail")))=0)Then
      
          EventArg.Error.Description      = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1003")
          CheckIfEMailIsRequiredAndBlank  = TRUE
      End If
  End If  
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PRIVATE FUNCTION GeneratePassWord_Click(EventArg) ' As Boolean

    Service("PassWord_")          = Service.Tools.GeneratePassword()
    Service("ConfirmedPassWord")  = Service("PassWord_")
END FUNCTION
 
 
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PRIVATE FUNCTION ValidatePassWord(EventArg) ' As Boolean

  If(Service("ConfirmedPassWord") = Service("PassWord_"))Then
      ValidatePassWord            = TRUE
  Else
      ValidatePassWord            = FALSE
      EventArg.Error.Description  = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1001")
  End If
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PRIVATE FUNCTION AddPrimaryAlias(EventArg) ' As Boolean
  
  Dim MappingService
  Dim strServiceMsixDefFile
  
  If(Len(Service("PrimaryAlias")))Then
  
      strServiceMsixDefFile = "metratech.com\AccountMapping.msixdef"
      AddPrimaryAlias       = FALSE
      Set MappingService    = mdm_CreateObject(MSIXHandler)
      
      ' Load the AccountMapping Service to be able to meter it
      If(MappingService.Initialize(strServiceMsixDefFile,,mdm_GetSessionVariable("mdm_APP_LANGUAGE"),mdm_GetSessionVariable("mdm_APP_FOLDER"),mdm_GetMDMFolder(),mdm_InternalCache))Then
      
          MappingService.Properties("Operation")              = Service("Operation").EnumType("Add")
          MappingService.Properties("NameSpace").Value 	      = Service("Name_Space")
          MappingService.Properties("LoginName").Value        = Service("UserName")
          MappingService.Properties("NewLoginName").Value     = Service("PrimaryAlias")
          MappingService.Properties("NewNameSpace").Value     = mam_GetDictionary("ADD_ACCOUNT_DEFAULT_NAME_SPACE_FOR_PRIMARY_ALIAS")
          MappingService.Properties("_Timestamp").Value       = Service("accountstartdate")
                    
          On Error Resume Next
          MappingService.Meter TRUE
          If(Err.Number)Then
              EventArg.Error.Save Err
              MappingService.Log EventArg.Error.ToString , eLOG_ERROR
          Else
              AddPrimaryAlias = TRUE
          End If
          On Error Goto 0      
      End If
  Else  
      AddPrimaryAlias = TRUE ' If there is no alias the function return TRUE
  End If  
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PRIVATE FUNCTION InitializeServiceForAddingANewAccount()

    FrameWork.Dictionary.Add "DEFAULT_DIALOG_UPDATE_DIALOG",FALSE

    ' Default Properties Initialization
    Service.Properties("ActionType").value           = Service("ActionType").EnumType.Entries("Both")
    Service.Properties("Operation").Value            = Service("Operation").EnumType.Entries("Add")
    Service.Properties("_AccountId").Value 	         = 0
    Service.Properties("TimeZoneId").Value           = mam_GetDictionary("DEFAULT_TIME_ZONE_ID")
    
    Service.Properties("TaxExempt").Value            = mam_GetDictionary("DEFAULT_TAX_EXEMPT")
    Service.Properties("DayOfMonth").Value           = 31
    Service.Properties("timezoneoffset").Value       = -5
    Service.Properties("transactioncookie").Value    = ""
    Service.Properties("Name_Space").Value           = mam_GetDictionary("ADD_ACCOUNT_DEFAULT_NAME_SPACE_FOR_BRANDED_SITE")
    Service.Properties("PrimaryAlias")               = ""
    Service.Properties("StatusReason").value         = Service("StatusReason").EnumType.Entries("None")
    Service.Properties("SecurityQuestion").value     = Service("SecurityQuestion").EnumType.Entries("None")
        
    ' When we add an account the status must be Active value = A
    Service.Properties("AccountStatus")              = Service("AccountStatus").EnumType.Entries("Active")
    
    ' default payment method is cash or check
    Service.Properties("PaymentMethod")              = Service("PaymentMethod").EnumType.Entries("CashOrCheck")
    
    ' Bill-To only in this dialog
    Service.Properties("ContactType").Value          = Service("ContactType").EnumType.Entries("Bill-To")
    
    ' Default country, read from XML dictionary there fore customizable
    Service.Properties("Country").Value             = mam_GetDictionary("DEFAULT_COUNTRY_ENUM_TYPE_VALUE")
    
    ' MAM 2.0
    Service.Properties("CURRENCY").Value           = mam_GetDictionary("ADD_ACCOUNT_DEFAULT_CURRENCY")
    Service.Properties("USAGECYCLETYPE").Value     = mam_GetDictionary("ADD_ACCOUNT_DEFAULT_USAGECYCLETYPE")
    
    ' MAM 3.0
    FrameWork.Dictionary.Add "SHOW_CURRENCY", TRUE 
          
    InitializeServiceForAddingANewAccount           = TRUE
END FUNCTION        



%>

