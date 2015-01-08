<!-- #INCLUDE FILE="../../default/lib/MenuLibrary.asp" -->
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2005 by MetraTech Corporation
'  All rights reserved
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
' ----------------------------------------------------------------------------------------------------------------------------------------
' NAME		        : MetraCare Library
' VERSION	        : 5.0
' AUTHOR	        : F.Torres, Kevin A. Boucher
' ----------------------------------------------------------------------------------------------------------------------------------------
PAGE_LANGUAGE = Session("PAGE_LANGUAGE")

PRIVATE m_objFrameWorkSecurity

' Account Creation Service Constants
CONST   eSUBSCRIBER_ACCOUNT_OPERATION_ADD    = 0
CONST   eSUBSCRIBER_ACCOUNT_OPERATION_UPDATE = 1
CONST   eSUBSCRIBER_ACCOUNT_OPERATION_DELETE = 2

CONST   eSUBSCRIBER_ACCOUNT_ACTION_ON_CONTACT = "contact"
CONST   eSUBSCRIBER_ACCOUNT_ACTION_ON_ACCOUNT = "account"
CONST   eSUBSCRIBER_ACCOUNT_ACTION_ON_BOTH    = "both"

' MetraTech Platform global value used when we metered thing to all the CSRS
CONST GLOBAL_CSR_METERED_ACCOUNT_ID = 123

' Account Contact Type Value
CONST   eACCOUNT_TYPE_NONE    = 0
CONST   eACCOUNT_TYPE_BILL_TO = 1
CONST   eACCOUNT_TYPE_SHIP_TO = 2

CONST   eACCOUNT_TYPE_ENUMERATOR_NONE = "None"

' Account Credit
CONST eCREDIT_REQUEST_PENDING_STATUS     = "PENDING"
CONST eCREDIT_REQUEST_PENDING_DENIED     = "DENIED"

CONST MDM_SUBSCRIBER_ROWSET_SESSION_NAME = "MAM:Subscribers.RowSet"

CONST MAM_CSR_NAME_SPACE                 = "system_user"

CONST MAM_SESSION_NAME_LAST_ADDED_ACCOUNT_SERVICE = "MAM:LastAddAccountService"
CONST MAM_SESSION_SUBSCRIBER_CONTACTS_ROWSET      = "MAM:SubscriberContactRowSet"

CONST MAM_ACCOUNT_CREATION_ACCOUNT_ID_PROPERTY    = "_accountid"
CONST MAM_ACCOUNT_CREATION_USER_NAME_PROPERTY     = "username"
CONST MAM_ACCOUNT_CREATION_NAME_SPACE_PROPERTY    = "name_space"
CONST MAM_QUICK_FIND_ALIAS_PROPERTY               = "username"
CONST MAM_ACCOUNT_CREATION_ACCOUNT_TYPE_PROPERTY  = "AccountType"

CONST MAM_TEST_MODE = FALSE ' By turning off and on the bool some dialog behave for test mode...

PUBLIC CONST SUBSCRIBER_NAME_SPACE_TYPE = "system_mps"
PUBLIC CONST CSR_NAME_SPACE_TYPE        = "system_user"

' TODO: Add Account types
CONST MAM_ACCOUNT_CREATION_ACCOUNT_TYPE_CSR             =   "SYSTEMACCOUNT"
CONST MAM_ACCOUNT_CREATION_ACCOUNT_TYPE_SUB_HIERARCHY   =   "CORESUBSCRIBER"
CONST MAM_ACCOUNT_CREATION_ACCOUNT_TYPE_SUB_INDEPENDENT =   "INDEPENDENTACCOUNT"

CONST MAM_HIERARCHY_ROOT_ACCOUNT_ID = 1

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION FrameWorkSecurity() ' SECURITY_CONTEXT_PROGID

		If IsEmpty(m_objFrameWorkSecurity) Then
		
				Set m_objFrameWorkSecurity = New CFrameWorkSecurity
		End If
		Set FrameWorkSecurity = m_objFrameWorkSecurity
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_CheckEndDate(objEventArg,strProperty)

      If objEventArg.UIParameters.Exist(strProperty) Then      
      
          objEventArg.UIParameters(strProperty).Value = mam_SetTimeToDefaultEndDateTimeIfTimeNotSet(objEventArg.UIParameters(strProperty).Value)
      End If
      mam_CheckEndDate = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
FUNCTION mam_SetTimeToDefaultEndDateTimeIfTimeNotSet(strDate)

    Dim varDate
    
    If Len(Trim(strDate))=0 Then
        mam_SetTimeToDefaultEndDateTimeIfTimeNotSet = strDate        
        Exit Function
    End If
    
    On Error Resume Next
    varDate = CDate(strDate)
    
    If Err.Number Then ' Date convertion error we just give up the mdm will take care of it+

        Err.Clear
        mam_SetTimeToDefaultEndDateTimeIfTimeNotSet = strDate        
        Exit Function
    End If
    
    If Hour(varDate)=0 And Minute(varDate)=0 And Second(varDate)=0 And Instr(strDate,":")=0 Then ' This mean the time is not in strDate

        mam_SetTimeToDefaultEndDateTimeIfTimeNotSet = Trim(strDate) & " " & FrameWork.Dictionary().Item("END_OF_DAY").Value
    Else
        mam_SetTimeToDefaultEndDateTimeIfTimeNotSet = strDate
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetDictionary(strName) ' As String

	  mam_GetDictionary = Session("objMAM").Dictionary(strName).value
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mam_GetDictionaryDefault(strName, strDefault) ' As String

	  mam_GetDictionaryDefault = Session("objMAM").Dictionary.GetValue(strName, strDefault)
END FUNCTION
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION          : Form_DisplayErrorMessage
' PARAMETERS        :
' DESCRIPTION       : Override the MDM event Form_DisplayErrorMessage, so we can define our own VBScript
'                     to print an error
' RETURNS           :
PUBLIC FUNCTION Form_DisplayErrorMessage(EventArg) ' As Boolean

  Dim strPath, strDetail 
  strPath = mam_GetDictionary("DEFAULT_PATH_REPLACE")

	'-------------------------------
	' Call Error Resolution Roadmap
	'-------------------------------
	Dim strGuide, GuideMode
	' If ROADMAP[error number] is found in the dictionary, then that is displayed in the guide frame...
	'response.write "ROADMAP" & EventArg.Error.number & "<br>"
	strGuide = mam_GetDictionaryDefault("ROADMAP" & EventArg.Error.Number, "")
  GuideMode = mam_ShowGuide(Session("objMAM").Dictionary.PreProcess(strGuide))
  
  If Not GuideMode Then
    ' write clsErrorText style so MDM will pick it up
    Response.write "<style>"
    Response.write ".ErrorCaptionBar{	BACKGROUND-COLOR: #FDFECF;	BORDER-BOTTOM:#9D9F0F solid 1px;	BORDER-LEFT: #9D9F0F solid 1px;	BORDER-RIGHT: #9D9F0F solid 1px;	BORDER-TOP:#9D9F0F solid 1px; COLOR: black;	FONT-FAMILY: Arial;	FONT-SIZE: 10pt;	FONT-WEIGHT: bold;	TEXT-ALIGN: left;	padding-left : 5px;	padding-right : 5px;	padding-top : 2px;	padding-bottom : 2px;}"
    Response.write "</style>"
    Response.write "  <center><TABLE BGCOLOR=""#FFFFC4"" BORDER=""0"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""Black"" style=""margin-top: 5px;"">"
    Response.write "  <TR>"
    Response.write "  <TD Class='ErrorCaptionBar'>" 
    Response.write "   <IMG SRC='/mam/default/localized/en-us/images/error.gif' valign=""center"" BORDER=""0"" >&nbsp;"

    If Len(EventArg.Error.LocalizedDescription) Then     
    
        'SECENG: CORE-4753 CLONE - MSOL BSS 27051 Metracare: Stored cross-site scripting [/mam/default/dialog/ManageRoles.asp in Role Description parameter] (ESR for 26658) (Post-PB)
        'Added HTML encoding
        Response.write  SafeForHtml(Session("objMAM").Dictionary.PreProcess(EventArg.Error.LocalizedDescription)) ' The PreProcess takes care of the key word in the error message      
    ElseIf Len(EventArg.Error.Description) Then   

        'SECENG: CORE-4753 CLONE - MSOL BSS 27051 Metracare: Stored cross-site scripting [/mam/default/dialog/ManageRoles.asp in Role Description parameter] (ESR for 26658) (Post-PB)
        'Added HTML encoding
        Response.write  SafeForHtml(Session("objMAM").Dictionary.PreProcess(EventArg.Error.Description))          ' The PreProcess takes care of the key word in the error message      
    Else

      Response.write FrameWork.GetHTMLDictionaryError("MAM_ERROR_1006") 
    End If
    
    strDetail = "Number=" & EventArg.Error.Number & " Description=" & EventArg.Error.Description & " Source=" & EventArg.Error.Source
    
    strDetail = Replace(strDetail,"\","|")
    strDetail = Replace(strDetail,vbNewLine,"")
    strDetail = Replace(strDetail,Chr(13),"")
    strDetail = Replace(strDetail,Chr(10),"")
    strDetail = Replace(strDetail,"'","\'")
    strDetail = Replace(strDetail,"; ","\n")
    strDetail = Replace(strDetail,";","")
        
    Response.write "<BR><BR><CENTER><FONT size=2><A Name='butDetail' HREF='#' OnClick=""alert('" & strDetail  & "')"">"
    Response.write mam_GetDictionary("MAM_ERROR_ERROR_DETAIL")
    Response.write "</A></CENTER>"
      
    Response.write "    </TD>"  
    Response.write "    </TR>"
    Response.write "  </TABLE></center>"
  End If
  
  Form_DisplayErrorMessage = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_ShowGuide
' PARAMETERS	: strGuide
' DESCRIPTION : Shows the string passed in in the guide frame  - supports keyterms
' RETURNS			:
PUBLIC FUNCTION mam_ShowGuide(strGuide)
 mam_ShowGuide = FALSE 
 
 If CBool(mam_GetDictionary("GUIDE_ON")) Then
	  If Len(strGuide) > 0 Then

      Session("GUIDE_TEXT") = "<img src='/mam/default/localized/en-us/images/warning.gif'>"
    	Session("GUIDE_TEXT") = Session("GUIDE_TEXT") & "&nbsp;&nbsp;" & Session("objMAM").Dictionary.PreProcess(strGuide)
	    response.write "<script language='JavaScript1.2'>if(getFrameMetraNet().guide){getFrameMetraNet().guide.location.href = '" & mam_GetDictionary("ERROR_RESOLUTION_ROADMAP") & "';"
      response.write "getFrameMetraNet().showGuide();}</script>"
      mam_ShowGuide = TRUE 
	  End If	
 End IF   
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_ShowGuideNoWarning
' PARAMETERS	: strGuide
' DESCRIPTION : Shows the string passed in in the guide frame  - supports keyterms, but doesn't show the warning gif
' RETURNS			:
PUBLIC FUNCTION mam_ShowGuideNoWarning(strGuide)
 If CBool(mam_GetDictionary("GUIDE_ON")) Then
	  If Len(strGuide) > 0 Then
    	Session("GUIDE_TEXT") = Session("objMAM").Dictionary.PreProcess(strGuide)
	    response.write "<script language='JavaScript1.2'>if(getFrameMetraNet().guide){getFrameMetraNet().guide.location.href = '" & mam_GetDictionary("ERROR_RESOLUTION_ROADMAP") & "';"
      response.write "getFrameMetraNet().showGuide();}</script>"
	  End If	
 End IF   
END FUNCTION
	
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_Clear()

    Session("mdm_APP_FOLDER")                     = ""
    Set Session("mdm_LOCALIZATION_DICTIONARY")    = Nothing
    Set Session("objMAM")                         = Nothing    
    mam_GarbageCollector
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetMAMFolder() ' As String

	  mam_GetMAMFolder = Session("MDM_APP_FOLDER")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION MAM() ' As Object

	  Set MAM = Session("objMAM")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetImagesPath
' PARAMETERS	:
' DESCRIPTION : Return the current image path. Support Default and Custom folder...
' RETURNS	 	  :
PUBLIC FUNCTION mam_GetImagesPath() ' As String

    Dim strPath

    strPath = UCase(request.serverVariables("PATH_TRANSLATED"))
    If(InStr(strPath,"\DEFAULT\"))Then
        mam_GetImagesPath = mam_GetDictionary("DEFAULT_PATH_REPLACE") & "/images" ' "
    Else
        mam_GetImagesPath = mam_GetDictionary("CUSTOM_PATH_REPLACE") & "/images" ' "
    End If          
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_LoadDictionary(objMAM,strLanguage) ' As Boolean

    DIM APP_FOLDER
    APP_FOLDER          = Session("mdm_APP_FOLDER")    
    mam_LoadDictionary  = FALSE
    
    If UCase(Session("mdm_APP_LANGUAGE")) = UCase(strLanguage) Then
        mam_LoadDictionary = TRUE
        Exit Function
    End If
    objMAM.Dictionary.Clear
    ' Read the dictionary entries that do not need to be localized
    ' Generally it is the mam application logical/physical links
    objMAM.Dictionary.LoadFolder APP_FOLDER & "\default\LinkLookUp", TRUE ' MDM V2 We read also the sub folder level 1
    objMAM.Dictionary.LoadFolder APP_FOLDER & "\custom\LinkLookUp", TRUE ' MDM V2 We read also the sub folder level 1
    
    ' Read the DEFAULT dictionary entries that do need to be localized
    objMAM.Dictionary.LoadFolder APP_FOLDER & "\Default\Localized\" & strLanguage & "\TextLookUp", TRUE ' MDM V2 We read also the sub folder level 1 "
    
    ' Read the CUSTOM dictionary entries that do need to be localized
    ' In the default intall this folder is empty, but if SIs add xml file
    ' They will be loaded! That is part of the MAM Customization logic
    objMAM.Dictionary.LoadFolder APP_FOLDER & "\custom\Localized\" & strLanguage & "\TextLookUp" , TRUE ' MDM V2 We read also the sub folder level 1 "
    
    ' Make sure the dictionary entry for APP_HTTP_PATH agrees with or virtual directory
    objMAM.Dictionary.Add "APP_HTTP_PATH", Application("APP_HTTP_PATH") 
    objMAM.Dictionary.Add "APP_PATH"     , Server.MapPath(Application("APP_HTTP_PATH"))
    
    objMAM.Dictionary.Render
    objMAM.Log "MAM Dictionary Loaded"
 
    objMAM.Log "CSR Language = " & strLanguage
    
    Session("mdm_APP_LANGUAGE")                 = strLanguage
    Set Session("mdm_LOCALIZATION_DICTIONARY")  = objMAM.Dictionary         ' Store the dictionary object for the mdm    
    
    ' MAM 3.0 - This allow to use the FrameWork interface. The class CFrameWork appeard in 2.0 but until 3.0 MAM was not using it.
    ' In 3.0 because we need this class for the security support I make it support other feature like FrameWork.GetDictionary().
    Session    ("FRAMEWORK_APP_LANGUAGE")   = strLanguage
    Set Session("FRAMEWORK_APP_DICTIONARY") = objMAM.Dictionary

    Framework.SetDictionaryCommonEntries    
    
    mam_LoadDictionary = TRUE
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GarbageCollector
' PARAMETERS	:
' DESCRIPTION	: Free any session objects
' RETURNS		  :
PUBLIC FUNCTION mam_GarbageCollector() ' As Boolean
    
    mdm_GarbageCollector
    
    mam_GarbageCollector = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_Terminate() ' As Boolean

    mam_Clear
    mam_Terminate=TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_Initialize() ' As Boolean
  Call MenuInitialize()
  mam_Initialize = TRUE
END FUNCTION  
  
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_FormatDate(strValue) 
' PARAMETERS	: Format the date.
' DESCRIPTION :
' RETURNS			:
Public Function mam_FormatDate(varValue, varFormat)
  if len(varFormat) = 0 then
    mam_FormatDate = FrameWork.MSIXTools.Format(varValue, mam_GetDictionary("DATE_FORMAT"))
  else
    mam_FormatDate = FrameWork.MSIXTools.Format(varValue, varFormat)
  end if
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_FormatDateTime(varValue, varFormat) 
' PARAMETERS	: Format the date.
' DESCRIPTION :
' RETURNS			:
Public Function mam_FormatDateTime(varValue, varFormat)
  if len(varFormat) = 0 then
    mam_FormatDateTime = FrameWork.MSIXTools.Format(varValue, mam_GetDictionary("DATE_TIME_FORMAT"))
  else
    mam_FormatDateTime = FrameWork.MSIXTools.Format(varValue, varFormat)
  end if
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION SubscriberYAAC()
  if not isObject(Session("SubscriberYAAC"))  then
    Set SubscriberYAAC = nothing
  else
		Set SubscriberYAAC = Session("SubscriberYAAC")
  end if
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_ConfirmDialogEncodeAllURL(strTitle, strMessage, strRouteTo)

    mam_ConfirmDialogEncodeAllURL = mam_GetDictionary("CONFIRM_DIALOG") & "?Title=" & Server.URLEncode(strTitle) & "&Message=" & Server.URLEncode(strMessage) & "&RouteTo=" & Server.URLEncode(strRouteTo)
END FUNCTION   

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_ConfirmDialogEncodeAllURLKeepFrame(strTitle, strMessage, strRouteTo)

    mam_ConfirmDialogEncodeAllURLKeepFrame = mam_GetDictionary("CONFIRM_DIALOG") & "?Title=" & Server.URLEncode(strTitle) & "&Message=" & Server.URLEncode(strMessage) & "&RouteTo=" & Server.URLEncode(strRouteTo) & "&KeepFrame=TRUE"
END FUNCTION   
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_ConfirmDialogEncodeAllURLNoRefresh(strTitle, strMessage, strRouteTo)

    mam_ConfirmDialogEncodeAllURLNoRefresh = mam_GetDictionary("CONFIRM_DIALOG") & "?NoMenuRefresh=TRUE&Title=" & Server.URLEncode(strTitle) & "&Message=" & Server.URLEncode(strMessage) & "&RouteTo=" & Server.URLEncode(strRouteTo)
END FUNCTION   

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: SendTemplatedEMail
' DESCRIPTION	: 
' PARAMETERS	:
' RETURNS		  :
PUBLIC Function SendTemplatedEMail(strTemplateFileName, strSendTo, varArrayTags, strLanguage,strErrorMessage) ' As Boolean
       
    Dim strFullTemplateFileName ' As String
    Dim objTextFile				' As Object
    Dim objMsg					' As Object
    Dim objMail					' As Object
	  Dim i						' As Long
	
	  SendTemplatedEMail = FALSE
    
    Set objMsg 		= CreateObject("EMAILMESSAGE.MTEmailMessage.1")
    Set objMail 	= CreateObject("EMAIL.MTEmail.1")
    Set objTextFile = CreateObject(CTextFile)
	
    objMail.init objMsg
	            
    strFullTemplateFileName = strTemplateFileName
	   
	  ' Check If the template exist
    If(Not objTextFile.ExistFile(strFullTemplateFileName))Then
	
		  strErrorMessage	=	"[ERROR]File not found EMailTemplateFileName=" & strFullTemplateFileName
      MAM().Log strErrorMessage,eLOG_DEBUG
		  Exit Function
	  End If
	  MAM().Log "MamCreditLibrary.asp:SendTemplatedEMail() EMailTemplateFileName=" & strFullTemplateFileName,eLOG_DEBUG
        
    objMail.TemplateFileName 	= strFullTemplateFileName
    objMail.TemplateName 		= "default"
    objMail.TemplateLanguage 	= strLanguage
    objMail.LoadTemplate
    
    objMsg.MessageTo = strSendTo
    
 
 	  ' Fill the tags
   	i = 0
	  Do
    		  If(IsEmpty(varArrayTags(i)))Then Exit Do
    	    MAM().Log "MamCreditLibrary.asp:SendTemplatedEMail() " &  "TAGS "  & varArrayTags(i) & " = " & varArrayTags(i+1) , eLOG_DEBUG ' #mark 4/14/00 10:56:49 AM
 	        objMail.AddParam "" & varArrayTags(i),  "" & varArrayTags(i+1) ' "" & to support null
		      i = i + 2
  	Loop        
    
	  MAM().Log "MamCreditLibrary.asp:SendTemplatedEMail() Send Subscriber EMail", eLOG_DEBUG		
	  On Error Resume Next
  	Err.Clear
	  objMail.Send
	  If(err.number)Then
		    strErrorMessage	= " Object EMAIL.MTEmail.1 Function SendMail Raise this " & getLastErrorString() & " . Check If the SMTP Server is installed!"	
	      MAM().Log "MamCreditLibrary.asp:SendTemplatedEMail() " & strErrorMessage , eLOG_DEBUG
	  Else
	      MAM().Log "MamCreditLibrary.asp:SendTemplatedEMail() eMail Sent!" , eLOG_DEBUG
	  End If
	  SendTemplatedEMail = CBool(Err.Number=0)
	  On Error Goto 0	
		
	  Err.Clear		
    Set objMail 	= Nothing
    Set objMsg 		= Nothing
    Set objTextFile = Nothing
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: GetSubscriberLanguageFromAccountID
' DESCRIPTION	: For  the find object does not support to do a search based on
' PARAMETERS	: the account id. So the function return a US all the time. This function is only use for now
'               in the Issue Credit from request eMail notification.
'               The MAM v 1.3 is available only in english so this is not a problem!
'               But we will need to fix this in the future.
' RETURNS		  :
PUBLIC FUNCTION GetSubscriberLanguageFromAccountID(lngAccountID) 

    GetSubscriberLanguageFromAccountID = "US"
END FUNCTION


' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: GetUserNameFromAccountID
' DESCRIPTION	: returns User_Name for account id
' PARAMETERS	: account id
' RETURNS		  :
PUBLIC FUNCTION GetUserNameFromAccountID(lngAccountID) ' as string
  Dim objYAAC

  GetUserNameFromAccountID = ""
  
  If Len(lngAccountID) > 0 Then
  
    On Error Resume Next
    Set objYAAC               = FrameWork.AccountCatalog.GetAccount(CLng(lngAccountID), mam_ConvertToSysDate(mam_GetHierarchyTime()))    
    
    If Err.Number Then
        EventArg.Error.Save Err        
        Form_DisplayErrorMessage EventArg
        Response.End
    End If
    'SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
    GetUserNameFromAccountID  = SafeForHtml(objYAAC.LoginName)
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_IncludeCalendar
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_IncludeCalendar() ' As Boolean
    ' Load the Calendar widget
    Form.Widgets.Add "Calendar", server.MapPath("/mdm/common/Widgets/Calendar/Calendar.Header.htm"), server.MapPath("/mdm/common/Widgets/Calendar/Calendar.Footer.htm")
    mam_IncludeCalendar = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_IncludeProgress
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_IncludeProgress() ' As Boolean
    ' Load the Progress widget
    'Form.Widgets.Add "Progress", server.MapPath("/mdm/common/Widgets/Progress/Progress.Header.htm"), server.MapPath("/mdm/common/Widgets/Progress/Progress.Footer.htm")
    mam_IncludeProgress = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetSubscriberAccountID
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetSubscriberAccountID() ' As long

  On Error Resume next

  mam_GetSubscriberAccountID = CLng(MAM().Subscriber("_AccountID"))
  If err.number <> 0 then
    mam_GetSubscriberAccountID = 0
  End If
      
  On Error Goto 0
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetSubscriberPayer
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetSubscriberPayer() ' As long

    mam_GetSubscriberPayer = MAM().Subscriber("payerID")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetAccountCreationMsixdefFileName
' PARAMETERS	:
' DESCRIPTION : 
' RETURNS			:
PUBLIC FUNCTION mam_GetAccountCreationMsixdefFileName()

    mam_GetAccountCreationMsixdefFileName = mam_GetServiceDefForOperation("Add")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetAccountCreationMsixdefFileNameForSystemAccount
' PARAMETERS	:
' DESCRIPTION : 
' RETURNS			:
PUBLIC FUNCTION mam_GetAccountCreationMsixdefFileNameForSystemAccount()

    mam_GetAccountCreationMsixdefFileNameForSystemAccount = mam_GetServiceDefForOperationAndType("Add", "SystemAccount")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_Audit
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_Audit(strMessage,amount)

' This is kind of two tier but what the hell.
' TODO: Need to update this method to use the latest auditing component/support

  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\audit"
	rowset.SetQueryTag("__INSERT_GEN_AUDIT__")  
	rowset.AddParam "%%AUDIT_DESC%%",         CStr(strMessage)
	rowset.AddParam "%%AUDIT_AMOUNT%%",       CStr(amount)
	rowset.AddParam "%%AUDIT_CSRID%%",        CStr(MAM().CSR("UserName"))
	rowset.AddParam "%%AUDIT_SUBSCRIBER_ID%%",CStr(mam_GetSubscriberAccountID())
	rowset.Execute

END FUNCTION

' This is for PROTOTYPING ONLY
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: ExecuteSQL(strSQL)
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
'PUBLIC FUNCTION ExecuteSQL(strSQL)
'    dim rowset
'    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
'    rowset.Init "queries\audit" 'dummy
'    rowset.SetQueryString strSQL
'    rowset.Execute
'		set ExecuteSQL = rowset
'END FUNCTION

' This is for PROTOTYPING ONLY
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: GetAccountID(strName)
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
FUNCTION GetAccountID(strName)
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.Init "queries\audit"
    rowset.SetQueryString "select * from t_account_mapper where nm_login = " & strName
    rowset.Execute
    If rowset.EOF Then
      GetAccountID = 0
      Exit Function
    End If
    rowset.MoveFirst
    GetAccountID = rowset.value("id_acc")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetIssueCreditMaxAmount(strSuperUserLimit)
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetIssueCreditMaxAmount(strSuperUserLimit)

	Dim objCapabilities, objCapability, decValue, tmpValue
	
	If FrameWork.SecurityContext.IsSuperUser() Then

			mam_GetIssueCreditMaxAmount = strSuperUserLimit
			Exit Function
	End If

	decValue               = CDbl(0)
  Set objCapabilities    = FrameWork.SecurityContext.GetCapabilitiesOfType("Apply Adjustments")
  
	For Each objCapability In objCapabilities
	
			tmpValue = CDbl(objCapability.GetAtomicDecimalCapability().GetParameter().Value)
			If tmpValue > decValue Then decValue = tmpValue
	Next
	mam_GetIssueCreditMaxAmount = decValue
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_IsUserACsr()
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_IsUserACsr()
  mam_IsUserACsr = Session("MAM_USER_NAME_SPACE") = MAM_CSR_NAME_SPACE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_IsUserASubscriber()
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_IsUserASubscriber()
  mam_IsUserASubscriber = Session("MAM_USER_NAME_SPACE") = "mt"
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetUserNameSpace()
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetUserNameSpace()
  mam_GetUserNameSpace = Session("MAM_USER_NAME_SPACE") 
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetGMTTimeFormatted()
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetGMTTimeFormatted()
    mam_GetGMTTimeFormatted = mdm_GetGMTTimeFormatted(mam_GetDictionary("DATE_TIME_FORMAT"))
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_ConvertToSysDate()
' PARAMETERS	: localized date
' DESCRIPTION : Converts localized date to sysdate format
' RETURNS			: sysdate
PUBLIC FUNCTION mam_ConvertToSysDate(localeDate)
   mam_ConvertToSysDate = localeDate&""
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_DateFromLocaleString()
' PARAMETERS	: string with localized date
' DESCRIPTION : Returns date type from string. (CORE-8563 - CDate converts properly in all localizations. It only does not like "." symbols)
' RETURNS			: date
PUBLIC FUNCTION mam_DateFromLocaleString(dateString)
  If Len(dateString) = 0 Then
      mam_DateFromLocaleString = ""
  Else
      mam_DateFromLocaleString = CDate(Replace(dateString,".","/"))
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetNormalDateFormat()
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_NormalDateFormat(strdate)
    if(Len(strdate)=0) Then
        mam_NormalDateFormat = ""
    else
        mam_NormalDateFormat = mdm_NormalDateFormat(strdate, mam_GetDictionary("DATE_TIME_FORMAT"))
    end If
END FUNCTION
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetGMTTime()
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetGMTTime()
    mam_GetGMTTime = mdm_GetGMTTime()
END FUNCTION
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetGMTDateFormatted()
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetGMTDateFormatted()
    mam_GetGMTDateFormatted = mdm_GetGMTTimeFormatted(mam_GetDictionary("DATE_FORMAT"))
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetGMTDate()
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetGMTDate()
    mam_GetGMTDate = mdm_GetGMTTimeFormatted("mm/dd/yyyy")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetGMTEndOfTheDayFormatted()
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetGMTEndOfTheDayFormatted()
   mam_GetGMTEndOfTheDayFormatted = CDate(mam_GetGMTDateFormatted() & " " & mam_GetDictionary("END_OF_DAY"))
END FUNCTION  


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetGMTEndOfTheDay()
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mam_GetGMTEndOfTheDay()
   mam_GetGMTEndOfTheDay = CDate(mam_GetGMTDate() & " " & mam_GetDictionary("END_OF_DAY"))
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' ---------------------------------------------------------------------------------------------------------------------------------------
' CLASS : CMAMFinder
' ---------------------------------------------------------------------------------------------------------------------------------------
' ---------------------------------------------------------------------------------------------------------------------------------------
CLASS CMAMFinder

    Private m_objFilter        
    Private m_objJoinFilter
    Public  SubscriberFound
    Public  Rowset
    Public  MaxNumberOfRows
    Public  NameSpaceType
    Public  ContactType
    Public  m_collColumns
    Public  m_collOrder
    Public  AccountTypes
    
    PRIVATE SUB Class_Initialize()
    
      'Set m_objFilter     = CreateObject("MTSQLRowset.MTDataFilter")
      'Set m_objFilter     = FrameWork.AccountCatalog.GetMAMFilter() ' Return the default filter for the account status. For example we only want to see AccountStatus In (Active,Suspended). Configuration file extension\core\account\AccountStates.xml      
      Set m_objJoinFilter = Nothing
      MaxNumberOfRows     = mam_GetDictionary("MAX_NUMBER_OF_ROWS_RETURNED_BY_FIND")
      NameSpaceType       = SUBSCRIBER_NAME_SPACE_TYPE
      ContactType         = mam_GetDictionary("CONTACT_TYPE_RESTRICTION_WHEN_LOOK_UP_ACCOUNT")
      AccountTypes         = ""
      Set m_collColumns = Nothing
      Set m_collOrder = Nothing
    END SUB

    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    ' Function    : CreateFilter(bAccount)                                  '
    ' Description : If bAccount is true, get the filter from the account    '
    '             : catalog, otherwise create one.                          '
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    Public Function CreateFilter(bAccount)
      if bAccount then
        Set m_objFilter = FrameWork.AccountCatalog.GetMAMFilter()
      else
        Set m_objFilter = server.CreateObject("MTSQLRowset.MTDataFilter")
      end if
      
      CreateFilter = true
    
    End Function

    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    'Function     : AddColumn(strColumn)                                    '
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    Public Function AddColumn(strColumn)
      
      if len(strColumn) > 0 then
        if m_collColumns is nothing then
          Set m_collColumns = server.createObject("MetraTech.MTCollectionEx")
        end if
      
        Call m_collColumns.Add(strColumn)
      end if   
    
    End Function

    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    ' Function    : AddOrderProp                                            '
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    Public Function AddOrderProp(strOrderProp)

      if len(strOrderProp) > 0 then
        if m_collOrder is nothing then
          Set m_collOrder = server.CreateObject("MetraTech.MTCollectionEX")
        end if
        
        Call m_collOrder.Add(strOrderProp)
      end if
      
    End Function

    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    PUBLIC FUNCTION AddFilter(strColumn, lngOperator , strValue)
        Dim val
        val = Trim(strValue)
        If Len(val) = 0 or val = "%" or val = "*" Then
          AddFilter = True
          exit Function
        End If
        
        m_objFilter.Add strColumn , CLNG(lngOperator), val
        AddFilter = TRUE
    END FUNCTION
    
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''    
    PUBLIC FUNCTION Find(strDate)
        
        Dim  booOK 
        Find = FALSE

        ' Add Account Types Filter
        If Len(AccountTypes) > 0 Then
          Call AddFilter("AccountTypeName" , MT_OPERATOR_TYPE_IN , AccountTypes) ' Format for AccountTypes = "'CORESUBSCRIBER', 'GSMSERVICEACCOUNT'"
        End If
        
        If Len(NameSpaceType) > 0 Then 
          Call AddFilter("_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType)
          
        '  If UCase(NameSpaceType) = UCase(SUBSCRIBER_NAME_SPACE_TYPE) Then
        '    'Always return the MPS namespace of the Payer for subscribers
        '    Call AddFilter("_PayerAccountNSType", MT_OPERATOR_TYPE_EQUAL, SUBSCRIBER_NAME_SPACE_TYPE)
        '  End If
        End If
                
       ' If Len(ContactType) Then 
       ' 
       '     Set m_objJoinFilter = CreateObject("MTSQLRowset.MTDataFilter")
       '     m_objJoinFilter.Add "ContactType" , MT_OPERATOR_TYPE_EQUAL , ContactType
       ' End If

        On error resume next
        ' If transaction was set in session, pass it in
        if(mam_GetTransaction() Is Nothing) Then
        
          booOK = MAM().Find3(FrameWork.AccountCatalog, m_collColumns, m_objFilter, m_objJoinFilter, strDate, SubscriberFound, Rowset, MaxNumberOfRows)
        else
          dim trx
          set trx = SESSION("TRANSACTION").GetTransaction()
          booOK = MAM().Find3(FrameWork.AccountCatalog, m_collColumns, m_objFilter, m_objJoinFilter, strDate, SubscriberFound, Rowset, MaxNumberOfRows, trx)
        end if
        
        If Err.Number=0 Then
            Find = booOK 
        Else
            CheckAndWriteError
        End If
        On Error Goto 0
        
    END FUNCTION
   
END CLASS

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION     :  mam_SetupCSR(strLogon, strNameSpace, strNameSpaceType)
' PARAMETERS   :  
' DESCRIPTION  :  Takes in a CSR logon and setups the MAM CSR object appropriately
' RETURNS      :  True / False
PUBLIC FUNCTION mam_SetupCSR(strLogon, strNameSpace, strNameSpaceType) ' as boolean

  mam_SetupCSR = FALSE

  Dim rs
  Set rs = FrameWork.AccountCatalog.FindAccountByNameAsRowset(mam_ConvertToSysDate(mam_GetHierarchyTime()), strLogon, strNameSpace, NULL)

  If rs.RecordCount >= 1 Then 
 
    MAM().SetActiveCSRAccountType "SystemAccount" 
    MAM().CSR.SetPropertiesFromRowset rs    
    
    MAM().CSR.Language = PAGE_LANGUAGE 'MAM().CSR("Language").EnumType.Entries.ItemByValue(MAM().CSR("Language").Value).Name 
    MAM().CSR("Language").Value = PAGE_LANGUAGE 'MAM().CSR.Language  
    mam_loadDictionary Session("objMAM"), MAM().CSR("Language").value
    
    SET Session("mdm_LOCALIZATION_DICTIONARY") = Session("objMAM").Dictionary
          
    Set Session("CSR_YAAC") = FrameWork.AccountCatalog.GetActorAccount()

    Dim objLanguageContext
    dim objSessionContext
    mam_LoadDictionary MAM(), PAGE_LANGUAGE'MAM().CSR.Language
    ' g. cieplik CR 12683 Load the dictionary based upon the CSR's language code, added for localization support of adjustments        
	  set objLanguageContext = CreateObject("MetraTech.Localization.LanguageList")
    SET objSessionContext = Session(FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME)    
    objSessionContext.LanguageID = objLanguageContext.GetLanguageID(PAGE_LANGUAGE)
    SET Session(FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME) = objSessionContext    

    mam_SetupCSR = TRUE
  Else
    mam_SetupCSR = FALSE    
  End If
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_GetHTTPCallToFindASubscriberAndSetItAsCurrent
' DESCRIPTION	: 
' PARAMETERS	:
' RETURNS		  :
PUBLIC FUNCTION mam_GetHTTPCallToFindASubscriberAndSetItAsCurrent(strUserName, strNameSpace, strRouteTo) ' As String
  on error resume next
  Dim accountID
  accountID = mam_GetAccountIDFromUserNameNameSpace(strUserName, strNameSpace)
  
  If Len(CStr(accountID)) > 0 AND err.number = 0 Then
    mam_GetHTTPCallToFindASubscriberAndSetItAsCurrent = mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=" & accountID & "&RouteTo=" & Server.URLEncode(strRouteTo)
  Else
    mam_GetHTTPCallToFindASubscriberAndSetItAsCurrent = mam_GetDictionary("SUBSCRIBER_FOUND")
  End If  
  on error goto 0
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_ExistLogin
' DESCRIPTION	: Return TRUE if username / namespace exist today or in the future
' PARAMETERS	: UserName, NameSpace
' RETURNS		  : TRUE / FALSE
PUBLIC FUNCTION mam_ExistLogin(strUserName, strNameSpace) ' As String
  On error resume next
  Dim objAccount
  Dim objMAMFinder 
  mam_ExistLogin = False
  
  Set objAccount = mdm_CreateObject("COMKiosk.COMAccount.1")
  objAccount.Initialize
  objAccount.GetAccountInfo strUserName, strNameSpace'

  If err.number = 0 Then
     mam_ExistLogin = True
     On error goto 0
     Exit Function
  End If

  ' If we didn't find the login existing today, then
  ' make sure it doesn't exist at the end of time either
  ' since accounts can be created in the future...
  Set objMAMFinder = New CMAMFinder
  Call objMAMFinder.CreateFilter(True)
  objMAMFinder.AddFilter MAM_ACCOUNT_CREATION_USER_NAME_PROPERTY , MT_OPERATOR_TYPE_EQUAL, CStr(strUserName)
  objMAMFinder.AddFilter MAM_ACCOUNT_CREATION_NAME_SPACE_PROPERTY, MT_OPERATOR_TYPE_EQUAL, CStr(strNameSpace)
  If(objMAMFinder.Find(FrameWork.RCD().GetMaxDate()))Then 
    If(objMAMFinder.SubscriberFound > 0) Then
      mam_ExistLogin = True
    End IF
  End If  
    
  On error goto 0 
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_LoadTempAccount
' DESCRIPTION	:
' PARAMETERS	:
' RETURNS		  :
PUBLIC FUNCTION mam_LoadTempAccount(lngAccountID)
  mam_LoadTempAccount = FALSE

  Dim rs
  Set rs = FrameWork.AccountCatalog.FindAccountByIDAsRowset(mam_ConvertToSysDate(mam_GetHierarchyTime()), lngAccountID, NULL)

  If rs.RecordCount >= 1 Then
    Call MAM().SetActiveTempAccountType(rs.Value("AccountType"))
    MAM().TempAccount.SetPropertiesFromRowset rs 
    
    mam_LoadTempAccount = TRUE
  Else
    mam_LoadTempAccount = FALSE
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_LoadTempCSRAccount
' DESCRIPTION	:
' PARAMETERS	:
' RETURNS		  :
PUBLIC FUNCTION mam_LoadTempCSRAccount(lngAccountID)
  mam_LoadTempCSRAccount = FALSE

  Dim rs
  Set rs = FrameWork.AccountCatalog.FindAccountByIDAsRowset(mam_ConvertToSysDate(mam_GetHierarchyTime()), lngAccountID, NULL)

  If rs.RecordCount >= 1 Then
    Call MAM().SetActiveTempAccountType(rs.Value("AccountType"))
    MAM().TempAccount.SetPropertiesFromRowset rs 
    
    mam_LoadTempCSRAccount = TRUE
  Else
    mam_LoadTempCSRAccount = FALSE
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_GetHierarchyTime
' DESCRIPTION	: Gets the time set in the hierarchy pane.
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION mam_GetHierarchyTime() 
  If IsEmpty(Session("HIERARCHY_HELPER")) Then
    mam_GetHierarchyTime =  CDate(mam_GetGMTEndOfTheDay())
  Else
    mam_GetHierarchyTime = CDate(Session("HIERARCHY_HELPER").SnapShot)
  End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_GetSystemUserHierarchyTime
' DESCRIPTION	: Gets the time set in the system user hierarchy pane.
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION mam_GetSystemUserHierarchyTime() 
  If IsEmpty(Session("SYSTEM_USER_HIERARCHY_HELPER")) Then
    mam_GetSystemUserHierarchyTime = CDate(mam_GetGMTEndOfTheDay())
  Else
    mam_GetSystemUserHierarchyTime = CDate(Session("SYSTEM_USER_HIERARCHY_HELPER").SnapShot)
  End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_GetTransaction
' DESCRIPTION	: Gets the transaction (IMTTransactionObject from 'TRANSACTION' session variable)
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION mam_GetTransaction() 
  If IsObject(Session("TRANSACTION")) Then
    Set mam_GetTransaction = Session("TRANSACTION")
  Else
    Set mam_GetTransaction = Nothing
  End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_GetHierarchyDate
' DESCRIPTION	: Gets the date set in the hierarchy pane.
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION mam_GetHierarchyDate() ' returns DATE
  Dim objTools
  Set objTools = CreateObject(MSIXTOOLS_PROG_ID)
  
  If IsEmpty(Session("HIERARCHY_HELPER")) Then
     mam_GetHierarchyDate = CDate(objTools.Format(objTools.GetCurrentGMTTime(), mam_GetDictionary("DATE_FORMAT")))
  Else
    mam_GetHierarchyDate = CDate(objTools.Format(Session("HIERARCHY_HELPER").SnapShot, mam_GetDictionary("DATE_FORMAT")))
  End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_GetUserNameNameSpaceFromAccountID
' DESCRIPTION	:
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION mam_GetUserNameNameSpaceFromAccountID(lngAccountID, strUserName, strNameSpace)

    Dim objParentFolderYaac
  
    Set objParentFolderYaac   = FrameWork.AccountCatalog.GetAccount(lngAccountID, mam_ConvertToSysDate(mam_GetHierarchyTime()))
    strUserName               = objParentFolderYaac.LoginName
    strNameSpace              = objParentFolderYaac.NameSpace        
    
    mam_GetUserNameNameSpaceFromAccountID = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_GetUserNameNameSpaceFromAccountIDForSystemUser
' DESCRIPTION	:
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION mam_GetUserNameNameSpaceFromAccountIDForSystemUser(lngAccountID, strUserName, strNameSpace)

    Dim objParentFolderYaac
  
    Set objParentFolderYaac   = FrameWork.AccountCatalog.GetAccount(lngAccountID, mam_ConvertToSysDate(mam_GetSystemUserHierarchyTime()))
    strUserName               = objParentFolderYaac.LoginName
    strNameSpace              = objParentFolderYaac.NameSpace        
    
    mam_GetUserNameNameSpaceFromAccountIDForSystemUser = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_GetFieldIDFromAccountID
' DESCRIPTION	:
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION mam_GetFieldIDFromAccountID(lngAccountID)

  Dim strFullName, objYaac

  If Len("" & lngAccountID) = 0 Then Exit Function
  If CLng(lngAccountID) = -1 Then Exit Function
  If CStr(lngAccountID) = "EOF()" Then Exit Function
  
  on error resume next
      
      If CLng(lngAccountID) = MAM_HIERARCHY_ROOT_ACCOUNT_ID then
        strFullName = mam_GetDictionary("TEXT_CORPORATE_ACCOUNT")
      Else
                'Set objYaac = FrameWork.AccountCatalog.GetAccount(lngAccountID, mam_GetHierarchyTime())
        'strFullName = objYaac.AccountName  
        'stop
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\Account"
	rowset.SetQueryTag("__GET_ACCOUNT_DATA__")  
	rowset.AddParam "%%COLUMN_NAMES%%", "HierarchyName"
	rowset.AddParam "%%ACCOUNT_VIEW_NAME%%", "VW_HIERARCHYNAME"
	rowset.AddParam "%%ACCOUNT_ID%%", CStr(lngAccountID)
	rowset.Execute

    if not rowset.EOF then
        rowset.MoveFirst
        
        strFullName = rowset.value("HierarchyName")
    else
     strFullName = ""
    End If

      End If

      If err.number <> 0 Then
        mam_GetFieldIDFromAccountID = -1
        Exit Function
      End If 
  on error goto 0
  
  strFullName = Trim(strFullName)
  if (Len(strFullName) = 0) then
    mam_GetFieldIDFromAccountID = lngAccountID
  else
    mam_GetFieldIDFromAccountID = SafeForHtml(strFullName) & " (" & lngAccountID & ")"
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_GetFieldIDFromAccountIDAtTime
' DESCRIPTION	:
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION mam_GetFieldIDFromAccountIDAtTime(lngAccountID, strTime)

  Dim strFullName, objYaac

  If Len("" & lngAccountID) = 0 Then Exit Function
  If lngAccountID = -1 Then Exit Function
  If lngAccountID = "EOF()" Then Exit Function
  
  on error resume next

      If CLng(lngAccountID) = MAM_HIERARCHY_ROOT_ACCOUNT_ID then
        strFullName = mam_GetDictionary("TEXT_CORPORATE_ACCOUNT")
      Else
        Set objYaac = FrameWork.AccountCatalog.GetAccount(lngAccountID, mam_ConvertToSysDate(CDate(strTime)))
        strFullName = objYaac.AccountName  
      End If 
  
      If err.number <> 0 Then
        mam_GetFieldIDFromAccountIDAtTime = -1
        Exit Function
      End If 
  on error goto 0
  
  strFullName = Trim(strFullName)
  if (Len(strFullName) = 0) then
    mam_GetFieldIDFromAccountIDAtTime = lngAccountID
  else
    mam_GetFieldIDFromAccountIDAtTime = strFullName & " (" & lngAccountID & ")"
  end If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_GetPathFromAccountID
' DESCRIPTION	:
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION mam_GetPathFromAccountID(lngAccountID)
  Dim objYaac
  
  Set objYaac = FrameWork.AccountCatalog.GetAccount(lngAccountID, mam_ConvertToSysDate(mam_GetHierarchyTime()))
              
  mam_GetPathFromAccountID = objYaac.HierarchyPath
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_GetAccountIDFromUserNameNameSpace
' DESCRIPTION	:
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION mam_GetAccountIDFromUserNameNameSpace(strUserName, strNameSpace)
    Dim objYaac

    Set objYaac = FrameWork.AccountCatalog.GetAccountByName(strUserName, strNameSpace, mam_ConvertToSysDate(mam_GetHierarchyTime()))
    mam_GetAccountIDFromUserNameNameSpace = objYaac.AccountID
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  CheckAndWriteError
' DESCRIPTION	:  This function is mainly used on delete dialogs that do not have a UI
'                if an error is thrown, then the error message will be displayed and the page ended.
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION CheckAndWriteError()
    If(err.number)Then  
      EventArg.Error.Save Err
      EventArg.Error.LocalizedDescription = EventArg.Error.Description
      response.write "<html><head><LINK rel='STYLESHEET' type='text/css' href='" & mam_GetDictionary("DEFAULT_PATH_REPLACE") & "/styles/styles.css'></head><body>"  
      Form_DisplayErrorMessage EventArg
      response.write "</body></html>"
      Response.End
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' When we update an account we only pass the value we want to update.
' By default a MSIXHandler initialize the enum type with the first value
' available if the enum type value is empty! We do not want this behavior!
' I create the property EnumTypeSupportEmpty that cancel the behavior at the
' Property level! So here I do a loop; Plus I set all the value to empty.
' After this function you must set the property you want to update,
' plus the required : ActionType, Operation, UserName, _AccountID; AccountType is required if
' there is contact...
PRIVATE FUNCTION mam_PrepareServiceForQuickUpdateAccount()

  Dim objMSIXProperty
  For Each objMSIXProperty In Service.Properties
  
      objMSIXProperty.EnumTypeSupportEmpty = TRUE ' Only enum type really matter here
      objMSIXProperty.Value                = Empty
  Next
  mam_PrepareServiceForQuickUpdateAccount = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_GetDisplayEndDate(datDate)
' DESCRIPTION	: 
' PARAMETERS	:
' RETURNS		  :
PUBLIC FUNCTION mam_GetDisplayEndDate(datDate)

    If FrameWork.IsInfinity(datDate) Then

          mam_GetDisplayEndDate = "<img src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/infinity.gif" & "'>"

    ElseIf FrameWork.IsMinusInfinity(datDate) Then
    
          mam_GetDisplayEndDate = "<img src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/minusinfinity.gif" & "'>"                              
    Else    
         ' mam_GetDisplayEndDate = Service.Tools.ConvertFromGMT(datDate, MAM().CSR("TimeZoneId").Value)
          mam_GetDisplayEndDate = mdm_Format(datDate,mam_GetDictionary("DATE_FORMAT"))
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_AccountTemplateDialogViewAndEditInitialize()
' DESCRIPTION	: 
' PARAMETERS	:
' RETURNS		  :
PUBLIC FUNCTION mam_AccountTemplateDialogViewAndEditInitialize()

    ' Must be set before we load the template properties.
    Service("UsageCycleType").Value = Service("UsageCycleType").EnumType.Entries(mam_GetDictionary("ADD_ACCOUNT_DEFAULT_USAGECYCLETYPE")).Value
    
		' Create and stored in the FORM() object an MSIXAccountTemplateInstance
		Set AccountTemplate = AccountTemplateHelper.AccountTemplate(MAM().Subscriber("_ACCOUNTID").Value)
		
		Set AccountTemplate.MSIXHandler = Service ' Pass to the account template the property definition		
    
		If Not AccountTemplate.Load() Then Exit Function ' Load the account template info from the database

		Service.Properties.Add "AccountTemplateName"         , "String" , 255 , False, Empty ' Special case for the Account Template Member
		Service.Properties.Add "AccountTemplateDescription"  , "String" , 255 , False, Empty
		Service.Properties.Add "ApplyDefaultSecurityPolicy"  , "Boolean" , 0 , False, Empty
		
		PrepareMSIXProperties
		
		Service.Properties("AccountTemplateName").Value          = Form("MSIX_ACCOUNT_TEMPLATE").Name
		Service.Properties("AccountTemplateDescription").Value   = Form("MSIX_ACCOUNT_TEMPLATE").Description
		Service.Properties("ApplyDefaultSecurityPolicy").Value   = Form("MSIX_ACCOUNT_TEMPLATE").ApplyDefaultSecurityPolicy
		
		Service.Properties("AccountTemplateName").Caption 			 = "Account Template Name"
		Service.Properties("AccountTemplateDescription").Caption = "Account Template Description"
		Service.Properties("ApplyDefaultSecurityPolicy").Caption = "Apply Default Security Policy"

    ' Billing Cycle Data Init
    Service.Properties.Add "BiWeeklyLabelInfo"        , "String"  , 255, False, Empty        
    Service("BiWeeklyLabelInfo").Caption = "dummy" ' to avoid localization error logged in mtlog.txt
	  mam_Account_SetBiWeeklyLabelInfo ' Init the field
	  mam_Account_SetGoodEnumTypeValueToUsageCycleType ' Re populate the enum type according the definition BillngCycle.xml
    
    mam_Account_SetBillingCycleEnumType
    mam_Account_ChangeCurrencyTypeToEnumType()
    
    mam_AccountTemplateDialogViewAndEditInitialize = TRUE
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  RefreshSubscriberYAAC
' DESCRIPTION	:  Reloads the yaacs properties
' PARAMETERS	:  ref date
' RETURNS		  :
Function RefreshSubscriberYAAC()
        
   Call SubscriberYAAC().Refresh(mam_GetHierarchyTime())

End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  GetNameIDLink
' DESCRIPTION	:  Returns a link that opens the account
' PARAMETERS	:  sFullName (name to display as link) or iAccId/sAccName to build that string,
'                 and boolean bFolder telling whether this is a folder or not
' RETURNS		  :
Function mam_GetNameIDLink(sFullName, iAccId, sAccName, bFolder)
	Dim sHTML, sImage
	
	If IsEmpty(sFullName) Then ' We will build it according to name and id
		sFullName = sAccName & " (" & iAccId & ")"
	End If

    sFullName = SafeForHtml(sFullName)
  sImage = ""
	
	If IsEmpty(Session("okToManageAccounts")) Then
		Session("okToManageAccounts") = CBool(FrameWork.CheckCoarseCapability("Manage Account Hierarchies") or FrameWork.CheckCoarseCapability("Manage independent accounts") or FrameWork.CheckCoarseCapability("Manage Owned Accounts"))
	End If
  
  ' Check if account is a csr.  CR:8581
  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  rowset.Init "queries\audit"
  'rowset.SetQueryString "select * from t_account where id_acc = " & iAccID
  rowset.SetQueryString "select * from t_account acc inner join t_account_mapper map on map.id_acc = acc.id_acc where acc.id_acc = " & iAccID
  rowset.Execute
  
  Dim AccountType, NameSpace
  If rowset.EOF Then
    AccountType = "CORESUBSCRIBER"
    NameSpace = "mt"
  Else
    rowset.MoveFirst
    AccountType = rowset.value("id_type")
    NameSpace = rowset.value("nm_space")    
  End If
  
  Dim bCSR
  If UCase(AccountType) = "SYSTEMACCOUNT" or UCase(NameSpace) = "SYSTEM_USER" Then
    bCSR = true
  Else
    bCSR = false
	End If
  
	If Not bCSR Then
    if Session("okToManageAccounts") Then
  		sHTML = "<a target='hidden' href='" &  "/MetraNet/ManageAccount.aspx" & "?id=" & iAccID & "'>" & sImage & " " & sFullName & "</a>"
    else
      sHTML = sFullName
    end if  
	Else
    if Session("okToManageAccounts") Then
  		sHTML = "<a target='hidden' href='" &  "/MetraNet/ManageAccount.aspx" & "?id=" & iAccID & "'>" & sImage & " " & sFullName & "</a>"
    else
      sHTML = sFullName
    end if  
	End If
	mam_GetNameIDLink = sHTML
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_LoadSubscriberAccount
' DESCRIPTION	: 
' PARAMETERS	:  lngAccountID
' RETURNS		  :
Function mam_LoadSubscriberAccount(lngAccountID)
  mam_LoadSubscriberAccount = FALSE

  ' Make sure we have an account id
  If lngAccountID = "" Then
      If mam_AccountFound(FALSE) Then
        mam_LoadSubscriberAccount = FALSE
      End If
      Exit Function
  End If

  ' Make sure we have an account id
  If lngAccountID = "NULL" Then
      If mam_AccountFound(FALSE) Then
        strRouteTo = mam_GetDictionary("WELCOME_DIALOG")
        mam_LoadSubscriberAccount = TRUE
      End If
      Exit Function
  End If
    
  Dim rs
  On error resume next
  Set rs = FrameWork.AccountCatalog.FindAccountByIDAsRowset(mam_ConvertToSysDate(mam_GetHierarchyTime()), lngAccountID, NULL)
  If err.number > 0 or IsEmpty(rs) Then
      If mam_AccountFound(FALSE) Then
        mam_LoadSubscriberAccount = FALSE
      End If
      Exit Function
  End If
  On error goto 0
   
  If rs.RecordCount >= 1 Then
 
    If UCase(rs.Value("AccountType")) = "SYSTEMACCOUNT" Then
      mam_LoadSystemUser lngAccountID, true
      Exit Function
    End If
     
    Call MAM().SetActiveAccountType(rs.Value("AccountType"))
    MAM().Subscriber.SetPropertiesFromRowset rs

    ' Always use the name for the following enum values (USAGECYCLETYPE, STARTMONTH, DAYOFWEEK)
    Dim prop
    For Each prop in MAM().Subscriber
       If UCase(prop.Name) = "USAGECYCLETYPE" or _
          UCase(prop.Name) = "STARTMONTH" or _
          UCase(prop.Name) = "LANGUAGE" or _ 
          UCase(prop.Name) = "DAYOFWEEK" Then
        If prop.IsEnumType Then
          If Not IsNull(prop.Value) Then
            prop.Value = prop.EnumType.Entries.ItemByValue(prop.Value).Name
          End If
        End If
       End If 
    Next
    
    mam_ConvertPriceListIDToString

    If mam_AccountFound(TRUE) Then        ' Load the account info in the main menu  
      mam_LoadSubscriberAccount = TRUE
    End If
  Else
    If mam_AccountFound(FALSE) Then
      mam_LoadSubscriberAccount = FALSE
    End If
  End If
  
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  WriteUnableToLoad
' DESCRIPTION	: 
' PARAMETERS	: 
' RETURNS		  : 
Function WriteUnableToLoad(strText, depricatedParam) 
  response.write "<html>"
  response.write " <head>"
  response.write "  <LINK Localized='TRUE' rel='STYLESHEET' type='text/css' href='/mam/default/localized/en-us/styles/styles.css'>"
  response.write " </head>"
  response.write " <body>"
  response.write " <TABLE border='0' cellpadding='1' cellspacing='0' width='100%'>"
  response.write " <tr>"
  response.write "  <td Class='CaptionBar' nowrap>" & mam_GetDictionary("TEXT_UNABLE_TO_LOAD_ACCOUNT")& "</td>"
  response.write " </tr>"
  response.write "</TABLE><br>"

  response.write strText
  
  response.write " </body>"
  response.write "</html>"
  response.end
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  
' DESCRIPTION	:  
' PARAMETERS	:  
' RETURNS		  :
PUBLIC FUNCTION mam_ConvertPriceListIDToString()

    Dim strImage, strPriceListID, objPricelist, acctID, objMTProductCatalog
    
    mam_ConvertPriceListIDToString = FALSE
  
    ' Massage Subscriber Rowset
    ' I have to go and get the pricelist name, because the finder only gives me the ID...
    ' but I need to meter the name... It is important that we do this every time we find a new subscriber
    If IsValidObject(MAM().Subscriber("PRICELIST")) Then
      
      strPriceListID = CStr("" & MAM().Subscriber("PRICELIST").value) ' Convert to a string to support oracle decimal and add a "" & to support NULL
      
      If Len(strPriceListID) Then
      
        If IsNumeric(strPriceListID) Then
      
          Set objMTProductCatalog = GetProductCatalogObject
          acctID = mam_GetSubscriberAccountID()             
          Set objPricelist = objMTProductCatalog.GetPriceList(CLng(strPriceListID))
          
          MAM().Subscriber("PRICELIST").value = objPricelist.Name 
 
          mam_ConvertPriceListIDToString = TRUE
        End If
      End If      
    End If
END FUNCTION   

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  
' DESCRIPTION	:  
' PARAMETERS	:  
' RETURNS		  :
PUBLIC FUNCTION mdm_ApplicationValidDate(varDate)

    If Len("" & varDate)=0 Then
        mdm_ApplicationValidDate = varDate
        Exit Function
    End If

    If FrameWork.IsValidDate(varDate,TRUE) Then 
        mdm_ApplicationValidDate = varDate
    Else
        Err.Raise 1,"MDM", PreProcess(mdm_GetMDMLocalizedError("MDM_ERROR_1027"),Array("DATE",varDate))
    End If      
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mam_GetCurrencyForAccountID
' PARAMETERS	: account id
' DESCRIPTION : get the currency for a given account id
' RETURNS			: currency as string
PUBLIC FUNCTION mam_GetCurrencyForAccountID(accountID)
    mam_GetCurrencyForAccountID = ""
    
    Dim acc_adapter 
    Set acc_adapter = Server.CreateObject("MTAccount.MTAccountServer.1")
    acc_adapter.initialize("Internal")

    Dim acc_prop_coll
    Set acc_prop_coll = Server.CreateObject("MTAccount.MTAccountPropertyCollection.1")
    Set acc_prop_coll = acc_adapter.GetData("metratech.com/internal", accountID)
    
    ' I want to use syntax like this:
    ' mam_GetCurrencyForAccountID = acc_prop_coll.get_Item("CURRENCY")
    Dim obj
    For Each obj In acc_prop_coll
        If obj.Name = "CURRENCY" Then
          mam_GetCurrencyForAccountID = obj.Value
        End If
    Next
    
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_GetSystemUser
' DESCRIPTION	: Get the currently selected sytem user.  
' PARAMETERS	:  
' RETURNS		  :
Public Function mam_GetSystemUser()
  if isObject(session("CURRENT_SYSTEM_USER")) then
    Set mam_GetSystemUser = Session("CURRENT_SYSTEM_USER")
  else
    Set mam_GetSystemUser = nothing
  end if
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_LoadSystemUser(lngID, bFlipMenu)
' DESCRIPTION	: Load the System User and store it.  
' PARAMETERS	: ID of the System User.
' RETURNS		  :
Public Function mam_LoadSystemUser(lngID, bFlipMenu)
  
  Set Session("CURRENT_SYSTEM_USER") = FrameWork.AccountCatalog.GetAccount(CLng(lngID), mam_ConvertToSysDate(mam_GetSystemUserHierarchyTime()))
  
  if not session("CURRENT_SYSTEM_USER") is nothing then
    mam_LoadSystemUser = true
    Call mam_SystemUserFound(bFlipMenu)
  else
    mam_LoadSystemUser = false
    Call mam_SystemUserFound(false)
  end if

End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  
' DESCRIPTION	:  
' PARAMETERS	:  
' RETURNS		  :
PUBLIC FUNCTION GetAssociation(mgr, acc)
  Dim assoc
  Set assoc = mgr.CreateAssociationAsOwner()

  assoc.RelationType = Service.Properties("Relationship").Value
  assoc.PercentOwnership = Service.Properties("Percentage").Value
  assoc.StartDate = CDate(Service.Properties("StartDate").Value)
  If Len(Service.Properties("EndDate")) > 0 Then  
    assoc.EndDate = CDate(Service.Properties("EndDate").Value)    
  Else
    assoc.EndDate = CDate(FrameWork.RCD().GetMaxDate())
  End If
  assoc.OwnedAccount = acc
  
  If Not Form Is Nothing Then
    If Form.Exist("OldStartDate")Then
      If IsEmpty(Form("OldStartDate")) Then
        assoc.OldStartDate = CDate(FrameWork.RCD().GetMinDate())
      else 
        assoc.OldStartDate = CDate(Form("OldStartDate"))    
      End If
    End IF
    
    If Form.Exist("OldEndDate")Then
      If IsEmpty(Form("OldEndDate")) Then
        assoc.OldEndDate = CDate(FrameWork.RCD().GetMaxDate())
      else 
        assoc.OldEndDate = CDate(Form("OldEndDate"))    
      End If
    End If
  
  End IF
  
  Set GetAssociation = assoc
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  
' DESCRIPTION	:  
' PARAMETERS	:  
' RETURNS		  :
PUBLIC FUNCTION GetAssociationAsOwned(mgr, acc)
  Dim assoc
  Set assoc = mgr.CreateAssociationAsOwned()

  assoc.RelationType = Service.Properties("Relationship").Value
  assoc.PercentOwnership = Service.Properties("Percentage").Value
  assoc.StartDate = CDate(mam_NormalDateFormat(Service.Properties("StartDate").Value))
  If Len(Service.Properties("EndDate")) > 0 Then  
    assoc.EndDate = CDate(mam_NormalDateFormat(Service.Properties("EndDate").Value))    
  Else
    assoc.EndDate = CDate(mam_NormalDateFormat(FrameWork.RCD().GetMaxDate()))
  End If
  assoc.OwnerAccount = acc

  If Not Form Is Nothing Then
    If Form.Exist("OldStartDate")Then
      If IsEmpty(Form("OldStartDate")) Then
        assoc.OldStartDate = CDate(FrameWork.RCD().GetMinDate())
      else 
        assoc.OldStartDate = CDate(Form("OldStartDate"))    
      End If
    End IF
    
    If Form.Exist("OldEndDate")Then
      If IsEmpty(Form("OldEndDate")) Then
        assoc.OldEndDate = CDate(FrameWork.RCD().GetMaxDate())
      else 
        assoc.OldEndDate = CDate(Form("OldEndDate"))    
      End If
    End If
  
  End IF
  
  Set GetAssociationAsOwned = assoc
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_GetAccountType
' DESCRIPTION	:  Returns an AccountType object from a collection of all account tyes that has been stored in session
' PARAMETERS	:  AccountType name (not case sensitive)
' RETURNS		  :  AccountType object
Public Function mam_GetAccountType(strType)

  If IsEmpty(Session("AccountTypes")) Then
    Set Session("AccountTypes") = Server.CreateObject("MetraTech.Accounts.Type.AccountTypeCollection")
  End If
  
  Set mam_GetAccountType = Session("AccountTypes").GetAccountType(strType)
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_GetServiceDefForOperation
' DESCRIPTION	:  Returns the servicedef for the specified operation, based on the active account type
' PARAMETERS	:  Opertaion
' RETURNS		  :  Service Definition, and sets MAM_DYNAMIC_TITLE
PUBLIC FUNCTION mam_GetServiceDefForOperation(strOperation)
  Dim strAccountType
   
  If Len(mdm_UIValue("AccountType")) Then
    strAccountType = mdm_UIValueDefault("AccountType", "IndependentAccount")
  Else
    If IsValidObject(Session("SubscriberYAAC")) Then
      strAccountType = Session("SubscriberYAAC").AccountType   
    End If  
  End If

  mam_GetServiceDefForOperation = mam_GetServiceDefForOperationAndType(strOperation, strAccountType)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_GetServiceDefForOperationAndType
' DESCRIPTION	:  Returns the servicedef for the specified operation and type
' PARAMETERS	:  Opertaion, AccountType
' RETURNS		  :  Service Definition, and sets MAM_DYNAMIC_TITLE
PUBLIC FUNCTION mam_GetServiceDefForOperationAndType(strOperation, strAccountType)
   
  If Len(strAccountType) > 0 Then
    Session("MAM_OPERATION_DEF") = MAM().GetAccountTypeMsixdef(strAccountType, strOperation) & ".msixdef"
    Session("MAM_DYNAMIC_TITLE") = strOperation & " " & strAccountType    
    Session("MAM_CURRENT_ACCOUNT_TYPE") = strAccountType
  End If

  mam_GetServiceDefForOperationAndType = Session("MAM_OPERATION_DEF")
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  mam_GetServiceFQNForOperationAndType
' DESCRIPTION	:  Returns the FQN for the specified operation and type
' PARAMETERS	:  Opertaion, AccountType
' RETURNS		  :  Service Definition, and sets MAM_DYNAMIC_TITLE
PUBLIC FUNCTION mam_GetServiceFQNForOperationAndType(strOperation, strAccountType)
   
  If Len(strAccountType) > 0 Then
    Session("MAM_OPERATION_DEF") = MAM().GetAccountTypeMsixdef(strAccountType, strOperation)
    Session("MAM_DYNAMIC_TITLE") = strOperation & " " & strAccountType    
    Session("MAM_CURRENT_ACCOUNT_TYPE") = strAccountType
  End If

  mam_GetServiceFQNForOperationAndType = Session("MAM_OPERATION_DEF")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  LocalizeProductView
' DESCRIPTION	:  Localizes a Properties object based on the msix for the add operation
' PARAMETERS	:  Props
' RETURNS		  :  TRUE / FALSE
PUBLIC FUNCTION LocalizeProductView(props)
  Dim displayName, fqn, prop
  For Each prop in props
    fqn = Replace(mam_GetServiceDefForOperation("Add"), ".msixdef", "/") & prop.Name
    Service.Tools.GetLocalizedString MAM().CSR("Language"), fqn, displayName
    If Len(displayName) = 0 Then
      prop.Caption = prop.Name & " {NL}"
    Else
      prop.Caption = displayName
    End If  
  Next

  LocalizeProductView = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		:  UseHTTPSOnClientCalls
' DESCRIPTION	:  Should client calls use SSL (HTTPS), checks to see if an SSL BLADE has been configured in HierarchyInformation.xml
' PARAMETERS	:  
' RETURNS		  :  TRUE / FALSE
PUBLIC FUNCTION UseHTTPSOnClientCalls()

  If UCase(mam_GetDictionary("SSL_BLADE_IN_USE")) = "TRUE" Then
    UseHTTPSOnClientCalls = TRUE
    Exit Function
  End If
  
  If UCase(request.ServerVariables("HTTPS")) = "OFF" Then
    UseHTTPSOnClientCalls = FALSE
  Else
    UseHTTPSOnClientCalls = TRUE
  End If  
END FUNCTION

%>

