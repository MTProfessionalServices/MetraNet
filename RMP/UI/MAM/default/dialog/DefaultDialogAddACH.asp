<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultPVBMapping.asp$
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
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: Kevin A. Boucher$
'  $Revision: 1$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../default/lib/PaymentServerLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Mandatory
Form.ServiceMsixdefFileName       = "metratech.com\ps_ach_addaccountandpaymentmethod.msixdef"
Form.RouteTo                      = Mam().dictionary("PAYMENT_METHODS_DIALOG")
Form.Localize                     = FALSE
mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  Form_Initialize
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
  
  Service.Properties.Add "defaultpayment", "Boolean", 00, False, TRUE  ' Add the default payment flag on the fly

  Service.Properties("reserved1").Value        = "1"
  Service.Properties("reserved2").Value        = "2"
  Service.Properties("testsession").Value      = 0
  Service.Properties("authreceived").Value     = 0
  Service.Properties("retryonfailure").Value   = 0
  Service.Properties("numberretries").Value    = 0
  Service.Properties("confirmrequested").Value = 0
  Service.Properties("delay").Value            = 0
  Service.Properties("billearly").Value        = 0
  Service.Properties("retaincardinfo").Value   = 1
  Service.Properties("email").Value            = MAM().Subscriber("email")
  Service.Properties("_AccountID").Value       = MAM().Subscriber("_AccountId")
  
  Service("Country").SetPropertyType "ENUM","global","CountryName"
  Service("country").Value = MAM().Subscriber("Country") 
        
  SetRequiredProperties(EventArg) 

  Service.Properties("bankaccounttype").Caption = mam_GetDictionary("TEXT_BANK_ACCOUNT_TYPE")
  Service.Properties("bankaccountnum_").Caption = mam_GetDictionary("TEXT_BANK_ACCOUNT_NUMBER")
  Service.Properties("bankname").Caption = mam_GetDictionary("TEXT_BANK_NAME")
  Service.Properties("customername").Caption   = mam_GetDictionary("TEXT_CUSTOMER_NAME_ACH")
  Service.Properties("address").Caption        = mam_GetDictionary("TEXT_ADDRESS")
  Service.Properties("city").Caption           = mam_GetDictionary("TEXT_CITY")
  Service.Properties("state").Caption          = mam_GetDictionary("TEXT_STATE")
  Service.Properties("zip").Caption            = mam_GetDictionary("TEXT_ZIP")
  Service.Properties("COUNTRY").Caption        = mam_GetDictionary("TEXT_COUNTRY")
  Service.Properties("routingnumber").Caption  = mam_GetDictionary("TEXT_ROUTING_NUMBER")
    
  'remove none
  'If Service.Properties("bankaccounttype").EnumType.Entries.exist("none") Then
  '  Service.Properties("bankaccounttype").EnumType.Entries.remove "none"
  'End If
    
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetRequiredProperties
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION SetRequiredProperties(EventArg) ' As Boolean

  Service.Properties("bankaccounttype").Required = TRUE
  Service.Properties("bankaccountnum_").Required = TRUE
  Service.Properties("bankname").Required       = TRUE
  Service.Properties("customername").Required   = TRUE
  Service.Properties("address").Required        = TRUE
  Service.Properties("city").Required           = TRUE
  Service.Properties("state").Required          = TRUE
  Service.Properties("zip").Required            = TRUE
  Service.Properties("COUNTRY").Required        = TRUE
  Service.Properties("routingnumber").Required = TRUE

  SetRequiredProperties = TRUE 
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  OK_Click
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    On Error Resume Next
           
    ' Meter
	  Service.Meter TRUE, , mam_getDictionary("PAYMENT_SERVER_NAME_IN_SERVERS_XML")
    If(CBool(Err.Number = 0)) then

       On Error Goto 0
       OK_Click = TRUE

       'OK_Click = RunPrenote(EventArg)
       
       'If OK_Click Then
         If Service.Properties("defaultpayment") Then
            OK_Click = SetAsPrimary(EventArg)
         End If
       'End If
       
       If Not OK_Click Then
        EventArg.Error.Save Err  
       End If
       
    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE
    End If
    Err.Clear   
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetAsPrimary
' PARAMETERS :  EventArg
' DESCRIPTION:  Set as primary payment method
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION SetAsPrimary(EventArg) ' As Boolean
  Dim PrimaryService
  Dim strServiceMsixDefFile
  
    strServiceMsixDefFile = "metratech.com\ps_ach_updateprimaryindicator.msixdef"
    SetAsPrimary          = FALSE
    Set PrimaryService    = mdm_CreateObject(MSIXHandler_PROG_ID)
    
    If(PrimaryService.Initialize(strServiceMsixDefFile,,mdm_GetSessionVariable("mdm_APP_LANGUAGE"),mdm_GetSessionVariable("mdm_APP_FOLDER"),mdm_GetMDMFolder(),mdm_InternalCache))Then
  
        PrimaryService.Properties("_AccountID")            = Service("_AccountID")
        PrimaryService.Properties("routingnumber").Value   = Service("routingnumber")
        PrimaryService.Properties("lastfourdigits").Value  = Right(Service("bankaccountnum_"), 4)
        PrimaryService.Properties("bankaccounttype").Value = Service("bankaccounttype")
        PrimaryService.Properties("testsession").Value     = Service("testsession")
        
        On Error Resume Next
        PrimaryService.Meter TRUE, , mam_getDictionary("PAYMENT_SERVER_NAME_IN_SERVERS_XML")
        If(Err.Number)Then
            EventArg.Error.Save Err
            Service.Log EventArg.Error.ToString,eLOG_ERROR
        Else
            SetAsPrimary = UsePaymentServer
        End If
        On Error Goto 0      
    End If

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  RunPrenote
' PARAMETERS :  EventArg
' DESCRIPTION:  meter ps_ach_prenote
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION RunPrenote(EventArg) ' As Boolean
  Dim PrenoteService
  Dim strServiceMsixDefFile
  
    strServiceMsixDefFile = "metratech.com\ps_ach_prenote.msixdef"
    RunPrenote            = FALSE
    Set PrenoteService    = mdm_CreateObject(MSIXHandler_PROG_ID)
    
    If(PrenoteService.Initialize(strServiceMsixDefFile,,mdm_GetSessionVariable("mdm_APP_LANGUAGE"),mdm_GetSessionVariable("mdm_APP_FOLDER"),mdm_GetMDMFolder(),mdm_InternalCache))Then
  
        PrenoteService.Properties("customername")           = Service("customername")
        PrenoteService.Properties("address").Value          = Service("address")
        PrenoteService.Properties("city").Value             = Service("city")
        PrenoteService.Properties("state").Value            = Service("state")
        PrenoteService.Properties("zip").Value              = Service("zip")
        PrenoteService.Properties("country").Value          = Service("country")
        PrenoteService.Properties("_Amount").Value          = 0
        PrenoteService.Properties("currency").Value        = MAM().Subscriber("currency")
        PrenoteService.Properties("bankname").Value         = Service("bankname")
        PrenoteService.Properties("routingnumber").Value    = Service("routingnumber")
        PrenoteService.Properties("bankaccountnum_").Value  = Service("bankaccountnum_")
        PrenoteService.Properties("bankaccounttype").Value  = Service("bankaccounttype")
        PrenoteService.Properties("testsession").Value      = Service("testsession")     
            
        On Error Resume Next
        PrenoteService.Meter TRUE, , mam_getDictionary("PAYMENT_SERVER_NAME_IN_SERVERS_XML")
        If(Err.Number)Then
            Err.description = mam_GetDictionary("TEXT_PS_PRENOTE_FAILURE")
            EventArg.Error.Save Err
            Service.Log mam_GetDictionary("TEXT_PS_PRENOTE_FAILURE"), eLOG_ERROR
        Else
            RunPrenote = TRUE
        End If
        On Error Goto 0      
    End If

END FUNCTION

%>

