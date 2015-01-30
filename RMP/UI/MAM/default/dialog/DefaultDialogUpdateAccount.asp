<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%    
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2006 by MetraTech Corporation
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
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit 
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
' Mandatory
Form.ServiceMsixdefFileName 	= mam_GetAccountCreationMsixdefFileName()
Form.RouteTo			            = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Form_Initialize = FALSE

  	Service.Clear 	' Set all the property of the service to empty. 
					          ' The Product view if allocated is cleared too.                

    Call mam_AccountEnumTypeSupportEmpty(Service.Properties)
                            
    Dim objMTProductCatalog
    Set objMTProductCatalog = GetProductCatalogObject
    
    ' do not meter payeraccountNS on update                  
    Service("PayerAccountNS").Flags  = Service("PayerAccountNS").Flags  + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING                      
                      
    mam_Account_AddDynamicProperties
    mam_Account_SetDynamicEnumType
    mam_Account_SetGoodEnumTypeValueToUsageCycleType
    GetNameSpaceNameDescription
		
		mam_Account_LoadAccountStatusEnumTypeForUpdate

    ' Store the Account Status before updated by the user.
    Form("PreviousAccountStatus") = Service("AccountStatus").Value
    If(Not InitializeServiceUpdatingAccount())Then Exit Function
    
    SetRequiredProperties(EventArg)
    
    ' Populate Default Account Pricelist
    PopulateDefaultAccountPricelist

	  Form_Initialize = Form_Refresh(EventArg)

    Form("AddUpdateMode") = "Add"  ' We do  support billing cycle in 2.0
    
    ' Include Calendar javascript    
    mam_IncludeCalendar
    
    ' Convert the fields to display a correct "Field ID"
    Service.Properties("PayerAccount").Value    = mam_GetFieldIDFromAccountID(Service.Properties("PayerId").Value)
    Service.Properties("AncestorAccount").Value = mam_GetFieldIDFromAccountID(Service.Properties("AncestorAccountID").Value)

    ' Disabled in 3.6
    Service.Properties("AncestorAccount").Enabled = FALSE
    Service.Properties("HIERARCHY_STARTDATE").Enabled = FALSE
    
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetRequiredProperties
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION SetRequiredProperties(EventArg) ' As Boolean

  Service.Properties("UserName").Required          = TRUE

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

    Form_Paint = AddUpdateAccount_FormPaint(EventArg) ' Share this event with DefaultDialogAddAccount.asp - see accountlib.asp
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Ok
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
    Dim strErrorMessage
    Dim objPriceListEnumTypeBackUp
    Dim resetHierarchyStartDateEnabled	   
    
    booOK               = FALSE
    OK_Click            = FALSE
    lngNewAccountId     = 0

    resetHierarchyStartDateEnabled = Service.Properties("HIERARCHY_STARTDATE").Enabled
    Service.Properties("HIERARCHY_STARTDATE").Enabled = True
    If(Not mam_Account_CheckBillingCycleRule(EventArg)      )Then Exit Function
    If(Not mam_Account_CheckIfEMailIsValid(EventArg)        )Then Exit Function
    
    mam_Account_UpdateBiWeeklyProperties
    mam_Account_UpDateMeteringAccordingIfThereIsOrNotContact
    
    If(Not ValidatePassWord(EventArg))Then Exit Function ' If confirmed password is not equal to password we return to the dialog
    
    ' By Setting then password to empty it will not be metered execept it it changed in the dialog...
    If(Len(Service("Password_").value)=0)Then Service("Password_").value = Empty
    
    ClearPriceListIfValueIsNone objPriceListEnumTypeBackUp
    
    If Not mam_Account_ProcessFieldsID()            Then Exit Function ' The error message is taken care of.
    If Not mam_Account_DoNotMeterAccountStateInfo(service) Then Exit Function

    On Error Resume Next        
    
    ' CR: 10028
    Dim PayerAccountID
    If Len(Service.Properties("PayerAccount").value) Then
      If FrameWork.DecodeFieldID(Service.Properties("PayerAccount").value, PayerAccountID) Then
            Dim objYAAC
            Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(PayerAccountID), mam_ConvertToSysDate(Service.Properties("PAYMENT_STARTDATE").Value))
            If err.number <> 0 then
              EventArg.Error.Save Err  
              OK_Click = FALSE       
              Exit Function
            End if
      End If     
    End If
    
    booOK = Service.Meter(True,objOutPutSession)
	  If(booOK)Then

        On Error Goto 0
        
        Service("PassWord_").Value  =   Empty ' We must reset the password else the value remain in memory and can cause problem if the user call again this dialog - MAM 3.0      
       ' Service.Properties.CopyTo MAM().Subscriber, TRUE

        OK_Click                    =   TRUE
        Form.RouteTo                =   mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_UPDATE_ACCOUNT"), mam_GetDictionary("TEXT_INFO_SUCCEFULLY_UPDATED"), mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountID=" & Service.Properties("_AccountID"))
        Exit Function
	  End If

    mdm_MeteringTimeOutManager  Service , _
                                FrameWork.Dictionary.Item("METERING_TIME_OUT_MANAGER_DIALOG").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_TIME_OUT").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_SUCCEEDED").Value & "<BR>" & FrameWork.Dictionary.Item("TEXT_PLEASE_RELOAD_THE_ACCOUNT").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_WILL_BE_EXECUTED_LATED").Value , _
                                Form.RouteTo    

    Service.Properties("HIERARCHY_STARTDATE").Enabled = resetHierarchyStartDateEnabled

    EventArg.Error.Save Err    
    Service("AccountStatus") = Form("PreviousAccountStatus") ' Restore the initialize account status to avoid user confusion
    
END FUNCTION
 
PRIVATE FUNCTION ValidatePassWord(EventArg) ' As Boolean

  If(Service("ConfirmedPassWord") = Service("PassWord_"))Then
      ValidatePassWord            = TRUE
  Else
      ValidatePassWord            = FALSE

      EventArg.Error.Description  = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1001")
  End If
END FUNCTION
    

PRIVATE FUNCTION InitializeServiceUpdatingAccount()

       FrameWork.Dictionary.Add "DEFAULT_DIALOG_UPDATE_DIALOG",TRUE

        ' Copy all the data from the MAM subscriber object into the Service object so 
        MAM().Subscriber.CopyTo Service.Properties
        
        Service.Properties("timezoneoffset").Value       = -5
        Service.Properties("transactioncookie").Value    = ""
        
        ' Default Properties Initialization
        Service.Properties("ActionType").value           = Service.Properties("ActionType").EnumType.Entries("Both").Value
        Service.Properties("Operation").Value            = Service.Properties("Operation").EnumType.Entries("Update").Value
       ' Service.Properties("SecurityQuestion").value     = Service.Properties("SecurityQuestion").EnumType.Entries("None").Value
        
        ' Bill-To only in this dialog
        Service.Properties("ContactType").Value          = Service.Properties("ContactType").EnumType.Entries("Bill-To").Value
        
        ' Set the dynamic property BiWeeklyLabelInfo with startmonth, start day and start year
        mam_Account_SetBiWeeklyLabelInfo
        
        ' Tell the enum type to use the enum type item name rather that value as index because in the all MAM
        ' application we use the name and not the value                        
        Service.Properties("Language").EnumType.Flags     = eMSIX_ENUM_TYPE_FLAG_USE_NAME_IN_HTML_OPTIONS_TAG_AS_INDEX
        
        ' 3.0 - we do not allow updating currency on hierarchy accounts
        Service.Properties("CURRENCY").Enabled = False

        ' 3.01 - Do not allow the hierarchy startdate to change for the corporate account:  cr #8285
	      If CLng(Service.Properties("AncestorAccountID").Value) = MAM_HIERARCHY_ROOT_ACCOUNT_ID then
          FrameWork.Dictionary.Add "SHOW_HIERARCHY_CALANDER",FALSE
	        Service.Properties("HIERARCHY_STARTDATE").Enabled = False	
	      Else
          FrameWork.Dictionary.Add "SHOW_HIERARCHY_CALANDER", TRUE
	        Service.Properties("HIERARCHY_STARTDATE").Enabled = True	
        End If
        
        InitializeServiceUpdatingAccount = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: GetNameSpaceNameDescription
' PARAMETERS		:
' DESCRIPTION   : 
' RETURNS			  : 
PRIVATE  FUNCTION GetNameSpaceNameDescription() ' As Boolean

    Dim strError
    Dim objMTSQLRowset
    Set objMTSQLRowset = mdm_CreateObject(MTSQLRowset)
    
    Service("NameSpaceDescription") = Empty
    
    If(Service.Tools.ExecSQL(mam_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH"),"__GET_NAME_SPACE_INFO_FROM_NAME__",objMTSQLRowset,"NAME_SPACE",Service("Name_Space").Value))Then
    
        If(objMTSQLRowset.RecordCount)Then
            Service("NameSpaceDescription") = objMTSQLRowset.Value("tx_desc")
        End If
    End If
    
    If(Len(Service("NameSpaceDescription"))=0)Then    
    
        GetNameSpaceNameDescription     = FALSE
        strError                        = Replace(FrameWork.GetHTMLDictionaryError("MAM_ERROR_1004"),"[NAME_SPACE]",Service("Name_Space").Value)
        Service("NameSpaceDescription") = strError
        Service.Log strError,eLOG_ERROR
    Else
        GetNameSpaceNameDescription = TRUE
    End If    
END FUNCTION

PUBLIC FUNCTION butUpDateStatus_Click(EventArg)
    mdm_TerminateDialogAndExecuteDialog "DefaultDialogUpdateAccountStatus.asp"
END FUNCTION

PRIVATE FUNCTION RefreshPage_Click(EventArg) ' As Boolean

    Call response.redirect( mam_GetDictionary("SUBSCRIBER_FOUND") &"?AccountId=" & mam_GetSubscriberAccountID() & "&ForceLoad=TRUE" & "&RouteTo=" & mam_GetDictionary("UPDATE_ACCOUNT_INFO_DIALOG"))

    RefreshPage_Click = TRUE
END FUNCTION
%>

