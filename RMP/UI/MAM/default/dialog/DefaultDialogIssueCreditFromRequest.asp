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
<!-- #INCLUDE FILE="../../default/lib/MamCreditLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

Private Const SUB_TEMPLATE_FILE_NAME = "DefaultCreditRequestInfo.htm"

Form.ServiceMsixdefFileName 	    = "metratech.com\AccountCredit.msixdef"
Form.MsixdefExtension             = "Core"
Form.RouteTo			                = mam_GetDictionary("CREDIT_REQUESTS_BROWSER")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	  Service.Clear ' Set all the property of the service to empty. 

    mam_SetTemporaryEnumTypeForAccountCredit
    
	  Form_Initialize = InitCreditFromCreditRequest(Request.QueryString("SessionId")) ' The function is at the end of this file
  
    Service("Status").EnumType.Entries.Add "",""," "    ' Add a blank entry
    Service("Status").Value = ""                       ' Select the blank entry

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Paint
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Paint(EventArg) ' As Boolean

  	Dim objProductViewCreditRequests
	  Dim varHTMLTemplateForTheCreditRequest
    Dim strTemplateFolder
    Dim objTextFile

    strTemplateFolder = mdm_GetDialogPhysicalPath()
    Set objTextFile   = mdm_CreateObject(CTextFile)

    	
	  ' Get a reference to the CreditRequests object the right credit request to be update is already
  	' selected at this stage...
  	Set objProductViewCreditRequests 			= Session("ProductViewCreditRequests")
	  ' Select the right credit request    
    
    objProductViewCreditRequests.RenderLocalizationMode = TRUE ' We want all the enum type value to be localized while the HTML Rendering Process
		
  	' Render the credit request template...
	  ' 
  	' The rendering will return the localized value for all the enum type : eXSERVICE_RENDER_FLAG_LOCALIZE_ENUM_TYPE
  	' The rendering will not add/populate the form tag of the CreditRequest because
  	' we do not need it. Plus it interfere with <FORM> for the dialog Credit.
	  If(objProductViewCreditRequests.RenderHTML(objTextFile.LoadFile(strTemplateFolder & ANTI_SLASH & SUB_TEMPLATE_FILE_NAME)    , _
                                              varHTMLTemplateForTheCreditRequest                          , _
                                              request.serverVariables("URL")                              , _
                                              eMSIX_RENDER_FLAG_DEFAULT_VALUE-eMSIX_RENDER_FLAG_RENDER_FORM_TAG  _
                                              ))Then
                                              

		  ' Add to the current Credit remplate the parsed template Credit Requets
  		' We add it at the beginning...
      
	  	EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[CREDIT_REQUEST_HTML]",varHTMLTemplateForTheCreditRequest)
	Else
  		response.write "RenderHTML() function failed in DefaultDialogIssueCreditFromRequest_Open() file DefaultDialogIssueCreditFromRequest.asp"
	End If	
  Set Session("XServiceCreditRequests") = Nothing
	Form_Paint = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Ok
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
    
    Dim objCreditStatusEnumType   ' As Variant
    Dim strConfirmationMessageID  ' As String
    Dim dblAmount
    Dim booTmpValue
    
    booTmpValue = Service("EMailNotification")
    Service("EMailNotification").SetPropertyType MSIXDEF_TYPE_STRING ' Turn it into a boolean so it can support a check box
    Service("EMailNotification") = IIF(booTmpValue,"Y","N")
    
    If(CheckIfEMailIsRequiredAndBlank(EventArg))Then 
    
        ChangeEMailNotificationTypeFromStringToBoolean ' Convert EMailNotification from string to Boolean 
        Exit Function
    End If        
    
    Service.Properties("_Amount").Operation "*",-1 ' Set Amount a negativ - support of decimal...
    Service.Properties("CreditAmount").Value    =  Service.Properties("_Amount").Value              ' Set the Credited Amount

    ' Load the status enum type because we need to compare some enum type id value - and i am not supposed to hard code this in a program
    If(Not Service.Tools.GetLocalizedEnumType(MAM().CSR("Language"),"metratech.com","SubscriberCreditAccountRequestStatus", objCreditStatusEnumType, mdm_InternalCache))Then
    
        ChangeEMailNotificationTypeFromStringToBoolean ' Convert EMailNotification from string to Boolean
        Service.Log "GetLocalizedEnumType('US','metratech.com','SubscriberCreditAccountRequestStatus' FAILED" , eLOG_ERROR        
        EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1005")
        Exit Function    
    End If
                
    If(Service("Status").Value = objCreditStatusEnumType("DENIED").Value)Then ' Test if we denied...
        
        Service.Properties("CreditAmount").Value  =   0
        Service.Properties("_Amount").Value       =   0        
        dblAmount                                 =   Service.Properties("RequestAmount").Value
    Else
        dblAmount                                 =   Service.Properties("_Amount").Value
    End If
    
    On Error Resume Next
	  Service.Meter TRUE
    If(CBool(Err.Number = 0)) Then
    
        On Error Goto 0
        OK_Click = TRUE
        
        ' THE BUG HAS BEEN FIXED IN MDM 2.1
        ' While the property is converted back to a string the enumtype property is still valid and will be used in the next
        ' function mam_TestAndSendCreditEMailNotification(); Since it is the end of 2.0 I do not want to change the function
        ' MSIXHandler.SetPropertyType, but the function should do first thing is clear the property enum type...
        ' Set Service.Properties("EMailNotification").EnumType = Nothing        
        
        ' WE DO NOT HAVE THE NAME AND THE LANGUAGE
        'mam_TestAndSendCreditEMailNotification "##NO_NAME","US",dblAmount
        
        strConfirmationMessageID = IIF(Service("Status") = objCreditStatusEnumType("DENIED"),"TEXT_ISSUE_CREDIT_CONFIRM_DENIED","TEXT_ISSUE_CREDIT_CONFIRM")
        
        If(mam_TestAndSendCreditEMailNotification("",GetSubscriberLanguageFromAccountID(Service("_AccountId")),dblAmount))Then
        
            Form.RouteTo    = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_ISSUE_CREDIT_TITLE"), mam_GetDictionary(strConfirmationMessageID), Form.RouteTo)        
            OK_Click        = TRUE
        Else

            Form.RouteTo    = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_ISSUE_CREDIT_TITLE"), mam_GetDictionary(strConfirmationMessageID) & FrameWork.GetHTMLDictionaryError("MAM_ERROR_1011"), Form.RouteTo)
            OK_Click        = TRUE
        End If
    Else
        Service.Properties("_Amount").Operation "*",-1 ' Set Amount a negativ - support of decimal...
        ChangeEMailNotificationTypeFromStringToBoolean ' Convert EMailNotification from string to Boolean 
        EventArg.Error.Save Err
        OK_Click = FALSE
    End If
END FUNCTION

PRIVATE FUNCTION Form_Terminate(EventArg)

    Set Session("ProductViewCreditRequests")   = Nothing
END FUNCTION
 
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: InitCreditFromCreditRequest
' PARAMETERS		:
' DESCRIPTION 		: Move the Selected CRedit Request product view row into a Credit Service Object
' RETURNS			: Return TRUE if ok.
PRIVATE FUNCTION InitCreditFromCreditRequest(lngSessionId) ' As Boolean

	Dim objProductViewCreditRequests
    
  Set objProductViewCreditRequests           = Session("ProductViewCreditRequests")
	
	If(Not objProductViewCreditRequests Is Nothing)Then
    
        ' Set the selected credit request
        If(mdm_FindInRowSet(objProductViewCreditRequests.Properties.RowSet,"SessionId",lngSessionId))Then
    				
    		' Prepopulate the credit with the information from the Credit Request
            Service("ReturnCode")		        = 0
            Service("ContentionSessionID")	= "-"            
            
            Service("RequestID")		        = objProductViewCreditRequests("SessionId")
    		    Service("_AccountId")		        = objProductViewCreditRequests("SubscriberAccountId")
    		    Service("_currency") 		        = objProductViewCreditRequests("Currency")
            
            ' Do not forget property _Amount, CreditAmount and RequestAmount are stored negatif
            ' Here the multiply by -1 go from 0< to >0
        		Service("_Amount") 		          = objProductViewCreditRequests("Amount").Operation("*",-1)
            
            
            ' The requested amount is the request Amount! Right! The Amount from the credit request is negativ
            ' so here I set the Credit RequestAmount Property and I am all set!
            Service("RequestAmount") 	      = objProductViewCreditRequests("Amount")
            
        		Service("Status")		            = objProductViewCreditRequests("Status")
        		Service("Reason")		            = objProductViewCreditRequests("Reason")	
            Service("Other")		            = objProductViewCreditRequests("Other")	
        		Service("EMailAddress") 	      = objProductViewCreditRequests("EMailAddress")
            
        		
            
            ChangeEMailNotificationTypeFromStringToBoolean
            
            Service("EMailNotification")	  = objProductViewCreditRequests("EMailNotification")
                                    
            Service("InvoiceComment")	      = objProductViewCreditRequests("Description")
    		    Service("CreditTime")		        = FrameWork.MetraTimeGMTNow()
        		Service("Issuer")		            = MAM().CSR("_AccountId")
            Service("EMailText")		          = ""
            
            ' Set a value to this property because it is required and not part
            ' of the UI. So when then MDM check for all required properties set,
            ' it raises an error. which a I do not want...
            Service("CreditAmount") 	        = 0
                        
    		    InitCreditFromCreditRequest = TRUE
        End If
	End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ChangeEMailNotificationTypeFromStringToBoolean
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION ChangeEMailNotificationTypeFromStringToBoolean() ' As Boolean

    ' I do it this way because in 1.2 and 1.3 service, this field is a string 1 -  old way to support boolean
    ' Convert EMailNotification from Char (Y,N) to Boolean
    Service("EMailNotification").SetPropertyType MSIXDEF_TYPE_BOOLEAN ' Turn it into a boolean so it can support a check box
    Service("EMailNotification")     = CBool(Len("" & Service.Properties("EMailAddress").Value))
END FUNCTION
%>

