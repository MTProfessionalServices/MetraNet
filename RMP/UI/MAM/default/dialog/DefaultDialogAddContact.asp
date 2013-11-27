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
<!-- #INCLUDE FILE="../../default/Lib/MTProductCatalog.Library.asp" --> 
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 


<%
' Mandatory
If(mdm_UIValue("UIUpdateMode"))Then
  Form.ServiceMsixdefFileName 	= mam_GetServiceDefForOperationAndType("Update",Session("SubscriberYAAC").AccountType)
else
  Form.ServiceMsixdefFileName 	= mam_GetServiceDefForOperationAndType("Add",Session("SubscriberYAAC").AccountType)

end if

Form.RouteTo			            = mam_GetDictionary("SUBSCRIBER_CONTACTS_BROWSER")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : Form_Initialize
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Dim objRowSet
     
    Form_Initialize = FALSE


    Form("UIUpdateMode") = Request.QueryString("UIUpdateMode")
  	Service.Clear
                    
    ' Add internal property that use to build the UI logic. these property will not be metered
    Service.Properties.Add "UIUpdateMode" , "Boolean" , 00 , False, FALSE  ' Add or update UI mode.
    
    If(UCase(Request.QueryString("UIUpdateMode"))="TRUE")Then

       ' Get the rowset used but DefaultPVContact.asp
       Set objRowSet = Session(MAM_SESSION_SUBSCRIBER_CONTACTS_ROWSET)
       
       ' Find in the row set the row with the account type to modify
       If(Not objRowSet.Find("ContactType",Request.QueryString("ContactType")))Then Exit Function
       
       ' Populate the service with the contact information
       Service.Properties.SetPropertiesFromRowset objRowSet

       Service("UIUpdateMode") = TRUE
    End If
    
    If(Service("UIUpdateMode"))Then      
        If(Not InitializeServiceUpdating() )Then Exit Function
    Else
        If(Not InitializeServiceForAdding())Then Exit Function
    End If
    
    ' Here we decide if we going to show the account type in a :
    '   - combox box : mode add contact
    '   - static text: mode update contact
    ' We add the entry CONTACT_TYPE_CONTROL to the dictionary, this entry is used in the HTML Template
    If(Service("UIUpdateMode"))Then
        mdm_GetDictionary.Add "CONTACT_TYPE_CONTROL" , Service("ContactType").LocalizedValue
    Else
        mdm_GetDictionary.Add "CONTACT_TYPE_CONTROL" , "<SELECT tabindex='15' class='clsInputBox' name='ContactType'></SELECT>"
        CleanAccountTypeEnumFromAlreadyAddContact
    End If
    
    mam_Account_SetDynamicEnumType
        
    SetRequiredProperties(EventArg)
    
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetRequiredProperties
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION SetRequiredProperties(EventArg) ' As Boolean

  ' No more required in MAM 2.0

  'Service.Properties("FirstName").Required         = TRUE
  'Service.Properties("LastName").Required          = TRUE
  'Service.Properties("address1").Required          = TRUE
  'Service.Properties("city").Required              = TRUE
  'Service.Properties("state").Required             = TRUE
  'Service.Properties("zip").Required               = TRUE
  'Service.Properties("COUNTRY").Required           = TRUE

  SetRequiredProperties = TRUE 
END FUNCTION


PRIVATE FUNCTION Form_Terminate(EventArg) ' As Boolean

    Set Session(MAM_SESSION_SUBSCRIBER_CONTACTS_ROWSET) = Nothing ' Free the row set in the session
    Session(MAM_SESSION_SUBSCRIBER_CONTACTS_ROWSET) = Empty
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Ok
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  
    OK_Click = FALSE
   
    ' Because we have a problem with DayOfWeek due to My Euro friend Roman
    ' I do this which cannot hurt...
    If(Service("DayOfWeek").IsValueDecimal())Then
    
        Service("DayOfWeek") = CLng(Service("DayOfWeek"))
    End If
    
    If(Not mam_Account_CheckIfEMailIsValid(EventArg))Then Exit Function
      
    mam_Account_CheckIfCountryIsEmptyStringBeforeMetering   
      
    On Error Resume Next
    Err.Clear
    
    'Only meter CONTACT information
    Service.Properties("taxexempt").Flags = Service.Properties("taxexempt").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("TaxExemptID").Flags = Service.Properties("TaxExemptID").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("TimezoneID").Flags = Service.Properties("TimezoneID").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("PaymentMethod").Flags = Service.Properties("PaymentMethod").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("SecurityQuestion").Flags = Service.Properties("SecurityQuestion").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("SecurityAnswer").Flags = Service.Properties("SecurityAnswer").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("InvoiceMethod").Flags = Service.Properties("InvoiceMethod").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("UsageCycleType").Flags = Service.Properties("UsageCycleType").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("Language").Flags = Service.Properties("Language").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("StatusReason").Flags = Service.Properties("StatusReason").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("StatusReasonOther").Flags = Service.Properties("StatusReasonOther").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("currency").Flags = Service.Properties("currency").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("pricelist").Flags = Service.Properties("pricelist").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("billable").Flags = Service.Properties("billable").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("folder").Flags = Service.Properties("folder").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("AccountStatus").Flags = Service.Properties("AccountStatus").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("timezoneoffset").Flags = Service.Properties("timezoneoffset").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("TruncateOldSubscriptions").Flags = Service.Properties("TruncateOldSubscriptions").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("ApplyDefaultSecurityPolicy").Flags = Service.Properties("ApplyDefaultSecurityPolicy").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Service.Properties("ApplyAccountTemplate").Flags = Service.Properties("ApplyAccountTemplate").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
   ' Service.Properties("state").Flags = Service.Properties("state").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    'Service.Properties("timezoneoffset").Flags = Service.Properties("timezoneoffset").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING

    Service.Meter True
	  If(Err.Number=0)Then
        
        On Error goto 0
        
        OK_Click = TRUE

        ' We goind to reload the subsriber info by doing a find
        mam_GetHTTPCallToFindASubscriberAndSetItAsCurrent Service("username"), Service("name_space") , Empty ' Load the subscriber new data
        
        ' Route to the confirm page
        Form.RouteTo = mam_ConfirmDialogEncodeAllURL (mam_GetDictionary("TEXT_CONTACT"), mam_GetDictionary(IIF(Service("UIUpdateMode"),"TEXT_INFO_SUCCEFULLY_UPDATED","TEXT_INFO_SUCCEFULLY_ADDED")), Form.RouteTo)
        Exit Function
    Else
        EventArg.Error.Save Err
	  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : InitializeServiceForAdding
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PRIVATE FUNCTION InitializeServiceForAdding()

        ' Copy all the data from the MAM subscriber object into the Service object so 
        ' Just because AccountCreation required most of the property event in the case of adding contact it does not use them
        MAM().Subscriber.CopyTo Service.Properties
        
        mam_ClearContact Service
        
        Service.Properties("timezoneoffset").Value       = -5
        Service.Properties("transactioncookie").Value    = ""
        Service.Properties("PassWord_").Value            = Empty
        
        ' Default Properties Initialization
        Service.Properties("ActionType").value           = Service.Properties("ActionType").EnumType.Entries("Contact").Value
        Service.Properties("Operation").Value            = Service.Properties("Operation").EnumType.Entries("Update").Value

        Service.Properties("_AccountId").Value 	         = Session("SubscriberYAAC").AccountId
        
        ' We can only add an account ship-to
        Service.Properties("ContactType").Value          = Service.Properties("ContactType").EnumType.Entries("Ship-To").Value
        Service.Properties("AccountType").Value			 = Session("SubscriberYAAC").AccountType
        
        
        InitializeServiceForAdding = TRUE
END FUNCTION        

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : InitializeServiceUpdating
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PRIVATE FUNCTION InitializeServiceUpdating()

        ' Copy all the data from the MAM subscriber object into the Service object so 
        ' Just because AccountCreation required most of the property event in the case of adding contact it does not use them
        'MAM().Subscriber.CopyTo Service.Properties
        
        Service.Properties("timezoneoffset").Value       = -5
        Service.Properties("transactioncookie").Value    = ""
        Service.Properties("PassWord_").Value            = Empty
        
        Service.Properties("ActionType").value           = Service.Properties("ActionType").EnumType.Entries("Contact").Value
        Service.Properties("Operation").Value            = Service.Properties("Operation").EnumType.Entries("Update").Value
        
        ' in this screen we only allowed to update the bill to information        
        InitializeServiceUpdating= TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : CleanAccountTypeEnumFromAlreadyAddContact
' PARAMETERS		  :
' DESCRIPTION 		: Delete from the AccountType enum type all the entries that were already created.
'                   Note : we duplicate the enum type.
' RETURNS		      :
PRIVATE FUNCTION CleanAccountTypeEnumFromAlreadyAddContact()

    Dim objRowSet
    Dim objMSIXEnumTypeEntry
    Dim objMSIXEnumTypeEntries
    
    Set objMSIXEnumTypeEntries = mdm_CreateObject(MSIXEnumTypeEntries) ' Create a new blank enum type
    
    ' This rowset contains all the contact type of the current subscriber
    Set objRowSet = Session(MAM_SESSION_SUBSCRIBER_CONTACTS_ROWSET) 'This session object is stored in DefaultPVContact.asp
    
    ' Clone the enum type entries object collection
    For Each objMSIXEnumTypeEntry In Service.Properties("ContactType").EnumType.Entries
    
        objMSIXEnumTypeEntries.Add objMSIXEnumTypeEntry.Name,objMSIXEnumTypeEntry.Value,objMSIXEnumTypeEntry.Caption
    Next
    
    objRowSet.MoveFirst ' Loop around all the account type of the current subscriber
    Do While Not objRowSet.Eof
    
        Set objMSIXEnumTypeEntry = Service("ContactType").EnumType.Entries.ItemByValue(objRowSet.Value("ContactType"))        
        If(IsValidObject(objMSIXEnumTypeEntry))Then
            
            objMSIXEnumTypeEntries.Remove objMSIXEnumTypeEntry.Name ' This AccountType was already created remove it from the combo box
        End If
        objRowSet.MoveNext
    Loop

    ' Remove none because we cannot add NONE Account type.
    If(Service("ContactType").EnumType.Entries.Exist("None"))Then
    
        objMSIXEnumTypeEntries.Remove Service("ContactType").EnumType("None").Name
    End If    
    
    '  plug the new enum type
    Set Service.Properties("ContactType").EnumType.Entries = objMSIXEnumTypeEntries    
END FUNCTION  

%>


