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
Form.ServiceMsixdefFileName = mam_GetServiceDefForOperationAndType("Update", "SystemAccount") 
Form.HelpFile = "DEFAULTPVBUPDATECSR.hlp.htm"

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
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Call mam_AccountEnumTypeSupportEmpty(Service.Properties)

   	Service.Clear 	' Set all the property of the service to empty.   The Product view if allocated is cleared too.
    
    ' Tell the enum type to use the enum type item name rather that value as index because in the all MAM application we use the name and not the value                
    Service.Properties("Language").EnumType.Flags = eMSIX_ENUM_TYPE_FLAG_USE_NAME_IN_HTML_OPTIONS_TAG_AS_INDEX

    dim ID
    ID = Request.QueryString("AccountId")
    If (Len(ID) = 0) Then
      ID = mam_GetSystemUser().AccountID
    End If  
    Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
 
    If CBool(mam_LoadTempCSRAccount(ID)) Then
      Service.Properties("AncestorAccountID") = Empty
      Service.Properties.Add "ConfirmPassword", "STRING", "255", TRUE, "" ' Add confirm Password property
      
      mam_Account_SetDynamicEnumType()
      
      MAM().TempAccount.CopyTo Service.Properties

      Service.Properties("ActionType").value = Service.Properties("ActionType").EnumType("Both")
      Service.Properties("Operation").Value  = Service.Properties("Operation").EnumType("Update")
      Service.Properties("ContactType").Value  = Service.Properties("ContactType").EnumType("Bill-To")

     SetRequiredProperties(EventArg)
    End IF

    Service.Properties("AccountStartDate").Value = Empty
    Service.Properties("hierarchy_startdate").Value = Empty          
    Service.Properties("hierarchy_enddate").Value = Empty 
    
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetRequiredProperties
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION SetRequiredProperties(EventArg) ' As Boolean

  Service.Properties("UserName").Required          = TRUE
  'Service.Properties("firstname").Required        = TRUE
  'Service.Properties("lastname").Required         = TRUE
  Service.Properties("confirmPassword").Required   = FALSE
  Service.Properties("password_").Required         = FALSE
     
  SetRequiredProperties = TRUE 
END FUNCTION

PRIVATE FUNCTION MakeSureFieldIsMetered(MSIXProperty)
    If Len("" & MSIXProperty.Value)=0 Then
        MSIXProperty.Value = ""
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Ok
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		    : Return TRUE if ok else FALSE
FUNCTION Ok_Click(EventArg) ' As Boolean
   
    Dim strMessage
    
    OK_Click = FALSE
    
    If Not mam_Account_CheckIfEMailIsValid(EventArg) Then Exit Function
    
    If Service.Properties("password_").Value = Service.Properties("confirmPassword").Value Then
    
        mam_Account_UpDateMeteringAccordingIfThereIsOrNotContact
        Call  mam_AccountEnumTypeSupportEmpty(Service.Properties)   
        Call mam_Account_DoNotMeterAccountStateInfo(Service)

        ' By Setting then password to empty it will not be metered execept it it changed in the dialog...
        If(Len(Service("Password_").value)=0)Then Service("Password_").value = Empty
        Service("AncestorAccountID").value = Empty
        On Error Resume Next
        Service.Meter TRUE ' Meter and wait for result
        If(err)Then

          mdm_MeteringTimeOutManager  Service , _
                                FrameWork.Dictionary.Item("METERING_TIME_OUT_MANAGER_DIALOG").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_TIME_OUT").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_SUCCEEDED").Value , _
                                FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_WILL_BE_EXECUTED_LATED").Value , _
                                Form.RouteTo          
        
            EventArg.error.number       = err.number
            EventArg.error.description  = err.description
            OK_Click = FALSE
            Err.Clear
        Else
            
            strMessage    = Replace(mam_GetDictionary("TEXT_CONFIRM_UPDATE_CSR"), "[ACCOUNT]", Service.Properties("UserName").Value)
            form.routeto  = mam_ConfirmDialogEncodeAllURL( mam_GetDictionary("TEXT_CONFIRM_UPDATE_CSR_TITLE"), strMessage, form.routeto )
            OK_Click      = TRUE
        End If
        On Error Goto 0      
    Else             
         EventArg.error.number      = 1001  ' Error password not confirmed
         EventArg.error.description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1001")         
    End If
  
END FUNCTION

%>

