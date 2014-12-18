<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998-2003 by MetraTech Corporation
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
' NAME		        : mom - MetraTech Account Manager - VBScript Library
' VERSION	        : 1.0
' CREATION_DATE     : 09/xx/2000
' AUTHOR	        : F.Torres.
' DESCRIPTION	    : Contains different usefull functions for theM App.
'               
' ----------------------------------------------------------------------------------------------------------------------------------------

CONST GLOBAL_CSR_METERED_ACCOUNT_ID               =   123

CONST mom_DEFAULT_NAME_SPACE                      =   "system_user"
CONST mom_CSR_NAME_SPACE                          =   "system_user"
CONST mom_OPS_NAME_SPACE                          =   "system_user"
CONST mom_LANGUAGE                                =    "en-us"

CONST mom_TEST_MODE                               =   true ' By turning of and on the bool some dialog behave for test mode...

CONST MOM_SESSION_CSR_TIME_ZONE_ID  = "MOM_SESSION_CSR_TIME_ZONE_ID"


PUBLIC CONST MTFilter             = "MTSQLRowset.MTDataFilter"

'Public Enum MTOpertorType
PUBLIC CONST OPERATOR_TYPE_LIKE          = 1             'LIKE
PUBLIC CONST OPERATOR_TYPE_LIKE_W        = 2             'LIKE that adds wildcard to value (for convenience)
PUBLIC CONST OPERATOR_TYPE_EQUAL         = 3             ' =
PUBLIC CONST OPERATOR_TYPE_NOT_EQUAL     = 4             ' !=
PUBLIC CONST OPERATOR_TYPE_GREATER       = 5             ' >
PUBLIC CONST OPERATOR_TYPE_GREATER_EQUAL = 6             ' >=
PUBLIC CONST OPERATOR_TYPE_LESS          = 7             ' <
PUBLIC CONST OPERATOR_TYPE_LESS_EQUAL    = 8             ' <=

'PropValType
'PUBLIC CONST PROP_TYPE_UNKNOWN = 0
'PUBLIC CONST PROP_TYPE_DEFAULT = 1
'PUBLIC CONST PROP_TYPE_INTEGER = 2
'PUBLIC CONST PROP_TYPE_DOUBLE = 3
'PUBLIC CONST PROP_TYPE_STRING = 4
'PUBLIC CONST PROP_TYPE_DATETIME = 5
'PUBLIC CONST PROP_TYPE_TIME = 6
'PUBLIC CONST PROP_TYPE_BOOLEAN = 7
'PUBLIC CONST PROP_TYPE_SET = 8
'PUBLIC CONST PROP_TYPE_OPAQUE = 9
'PUBLIC CONST PROP_TYPE_ENUM = 10
'PUBLIC CONST PROP_TYPE_DECIMAL = 11
  
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION mom_GetDictionary(strName) ' As String
	mom_GetDictionary = Session("mdm_LOCALIZATION_DICTIONARY").item(strName).value
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION          : Form_DisplayErrorMessage
' PARAMETERS        :
' DESCRIPTION       : Override the MDM event Form_DisplayErrorMessage, so we can define our own VBScript
'                     to print an error
' RETURNS           :
PUBLIC FUNCTION Form_DisplayErrorMessage(EventArg) ' As Boolean
  
  Dim strPath, strDetail
  strPath = mom_GetDictionary("DEFAULT_PATH_REPLACE")
  
  ' write clsErrorText style so MDM will pick it up
  Response.write "<style>"
  Response.write ".ErrorCaptionBar{	BACKGROUND-COLOR: #FDFECF;	BORDER-BOTTOM:#9D9F0F solid 1px;	BORDER-LEFT: #9D9F0F solid 1px;	BORDER-RIGHT: #9D9F0F solid 1px;	BORDER-TOP:#9D9F0F solid 1px; COLOR: black;	FONT-FAMILY: Arial;	FONT-SIZE: 10pt;	FONT-WEIGHT: bold;	TEXT-ALIGN: left;	padding-left : 5px;	padding-right : 5px;	padding-top : 2px;	padding-bottom : 2px;}"
  Response.write "</style>"
  Response.write "  <center><BR><TABLE WIDTH=""95%"" BGCOLOR=""#FFFFC4"" BORDER=""0"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""Black"" style=""margin-top: 5px;"">"
  Response.write "  <TR>"
  Response.write "  <TD Class='ErrorCaptionBar'>" 
  Response.write "   <IMG SRC='" & strPath & "/images/error.gif' valign=""center"" BORDER=""0"" >&nbsp;"

  If Len(EventArg.Error.LocalizedDescription) Then     
  
      Response.write  EventArg.Error.LocalizedDescription  
      
  ElseIf Len(EventArg.Error.Description) Then   

      Response.write EventArg.Error.Description
  Else
      Response.write mom_GetDictionary("MOM_ERROR_1002") 
  End If
  
  ' Change in MOM 3.0
  'strDetail = EventArg.Error.ToString()
  strDetail = "Number=" & EventArg.Error.Number & " (0x" & Hex(EventArg.Error.Number) & ")" & vbNewLine & "Description=" & EventArg.Error.Description & vbNewLine & "Source=" & EventArg.Error.Source
  
  strDetail = Replace(strDetail,"\","\\")
  strDetail = Replace(strDetail,vbNewLine,"\n")
  strDetail = Replace(strDetail,Chr(13),"\n")
  strDetail = Replace(strDetail,Chr(10),"")
  strDetail = Replace(strDetail,"""","\""")
  strDetail = Replace(strDetail,"'","\'")
  strDetail = Replace(strDetail,"; ","\n")
  'strDetail = Replace(strDetail,";","")
    
  Response.write "<script>var strErrorMessageDetail='"& strDetail & "';</script>"
  Response.write "<BR><BR><CENTER><FONT size=2><A Name='butDetail' title='" & mom_GetDictionary("MoM_ERROR_ERROR_DETAIL_DESCRIPTION") & "' HREF='#' OnClick=""alert(strErrorMessageDetail)"">"
  Response.write mom_GetDictionary("MoM_ERROR_ERROR_DETAIL")
  Response.write "</A></CENTER>"
    
  Response.write "    </TD>"
  Response.write "    </TR>"
  Response.write "  </TABLE></center>"
  Form_DisplayErrorMessage = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION mom_Clear()

    Session("mdm_APP_FOLDER")                     = ""
    Set Session("mdm_LOCALIZATION_DICTIONARY")    = Nothing
    Set Session("objMAM")                         = Nothing
    mdm_GarbageCollector
    mom_GarbageCollector
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION mom_GetMOMFolder() ' As String

	mom_GetMOMFolder = Session("MDM_APP_FOLDER")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION mom_GetImagesPath() ' As String

    mom_GetImagesPath = mom_GetDictionary("DEFAULT_PATH_REPLACE") & "/images"
    ' mom_GetImagesPath = Session("LocalizedPath") & "/images" ' Both syntax are correct - I just wanted to let you know
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mom_GarbageCollector
' PARAMETERS	:
' DESCRIPTION 	: Free the dictionary and then all objects instance store in the session!
' RETURNS		:
FUNCTION mom_GarbageCollector() ' As Boolean

    mdm_GarbageCollector
    
    mom_GarbageCollector = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
FUNCTION mom_Terminate() ' As Boolean

    mom_Clear
    mom_Terminate=TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION mom_GetLocalizeImagePath()

    mom_GetLOcalizeImagePath="/mom/default/localized/en-us/images"
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
FUNCTION mom_Initialize() ' As Boolean

    mom_Initialize=TRUE
END FUNCTION    

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mom_FormatDate(strValue) 
' PARAMETERS	: Format the date.
' DESCRIPTION :
' RETURNS			:
Public Function mom_FormatDate(varValue, varFormat)
  if len(varFormat) = 0 then
    mom_FormatDate = FrameWork.MSIXTools.Format(varValue, mam_GetDictionary("DATE_FORMAT"))
  else
    mom_FormatDate = FrameWork.MSIXTools.Format(varValue, varFormat)
  end if
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mom_FormatDateTime(varValue, varFormat) 
' PARAMETERS	: Format the date.
' DESCRIPTION :
' RETURNS			:
Public Function mom_FormatDateTime(varValue, varFormat)
  if len(varFormat) = 0 then
    mom_FormatDateTime = FrameWork.MSIXTools.Format(varValue, mom_GetDictionary("DATE_TIME_FORMAT"))
  else
    mom_FormatDateTime = FrameWork.MSIXTools.Format(varValue, varFormat)
  end if
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION mom_ConfigDialog(strTitle, strMessage, strRouteTo)

    mom_ConfigDialog    = mom_GetDictionary("CONFIRM_DIALOG") & "?Title=" & Server.URLEncode(strTitle) & "&Message=" & Server.URLEncode(strMessage) & "&RouteTo=" & strRouteTo
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mom_GetAccountID
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION mom_GetAccountID(strUserName,strNameSpace, lngAccountID, strErrorMessage) ' As Boolean

  Dim objMTSQLRowset  
  Set objMTSQLRowset = mdm_CreateObject(MTSQLRowset)
  
  If(Service.Tools.ExecSQL(mom_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH"),"__GET_ACCOUNT_ID__",objMTSQLRowset,"USER_NAME",strUserName,"NAME_SPACE",strNameSpace))Then
  
      lngAccountID        = objMTSQLRowset.Value("id_acc")
      mom_GetAccountID    = TRUE
  Else
      strErrorMessage = mom_GetDictionary("MOM_ERROR_1005")
      Service.Log strErrorMessage , eLOG_ERROR
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mom_LoadCSRInform
' PARAMETERS		:
' DESCRIPTION 	: Once the login is done we load the csr information. for  we need the TimeZoneID only
' RETURNS			  :
FUNCTION mom_LoadCSRInformation(Service,lngAccountID,strErrorMessage) ' As Boolean

  Dim objMTSQLRowset
  Dim strFQN
  Dim strEnumType
  Dim objAccountCreationService
  Dim strEnumTypeEnumerator
  Dim objMSIXTool
  
  Set objMTSQLRowset            = mdm_CreateObject(MTSQLRowset)
  Set objAccountCreationService = mdm_CreateObject(MSIXHandler)
  Set objMSIXTool               = mdm_CreateObject(MSIXTools)
  mom_LoadCSRInformation        = FALSE
  
  ' Get the     
  If(Service.Tools.ExecSQL(mom_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH"),"__GET_TIME_ZONE_ID_FQN__",objMTSQLRowset,"ACCOUNT_ID",lngAccountID,"LANGUAGE",LCase(mom_LANGUAGE)))Then
  
      strFQN                = objMTSQLRowset.Value("TimeZoneIDFQN")      
      Session(MOM_SESSION_CSR_TIME_ZONE_ID) = objMSIXTool.GetEnumValueByFQN("Global/TimeZoneID/" & strFQN)      
      mom_LoadCSRInformation = TRUE
  Else
      mom_LoadCSRInformation  = FALSE
      strErrorMessage         = mom_GetDictionary("MOM_ERROR_1003")
      Service.Log strErrorMessage,eLOG_ERROR 
  End If
END FUNCTION

PUBLIC FUNCTION mom_GetCSRTimeZoneID() ' As long

  mom_GetCSRTimeZoneID  = Session(MOM_SESSION_CSR_TIME_ZONE_ID)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mom_IsUserAdministrator() 
' PARAMETERS		:
' DESCRIPTION   :
' RETURNS			  : 
PUBLIC FUNCTION mom_IsUserAdministrator() ' As Boolean

  Dim objNetUser
  
  Set objNetUser          =  Server.CreateObject("MTNetUser.UserInfo")
  mom_IsUserAdministrator =  objNetUser.CheckForGroup(request.ServerVariables("LOGON_USER"),request.ServerVariables("SERVER_NAME"),"Administrators") OR objNetUser.CheckForGroup(request.ServerVariables("LOGON_USER"),request.ServerVariables("SERVER_NAME"),"Power Users")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : IsPaymentServerMachine
' PARAMETERS    :
' DESCRIPTION   : Return main xml menu file. Test if the MOM is intalled on the MPM Machine or the Payment Server Machine
' RETURNS       :
PRIVATE FUNCTION mom_IsPaymentServerMachine() ' As String
    Dim objTool
    
    Set objTool                 = Server.CreateObject("MTMSIX.MSIXTools")    
    mom_IsPaymentServerMachine  = objTool.IsPaymentServerMachine()
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : mom_GetMenuName
' PARAMETERS    :
' DESCRIPTION   : Return the main xml menu file name according if the machine is a payment server machine
'                 or a rmp machine or a demo machine which may contain both! In that case we use
'                 the environment variable MOM.MENU.NAME!
'                 Return a relative path.
' RETURNS       :
PRIVATE FUNCTION mom_GetMenuName() ' As String

    Dim strMenuFileCSVList, arrMenuFile, strMenuFile
    Dim objTextFile, strXMLMenu, strGeneratedXMLMenuFileName, strMenuPath, strMainXML

		Set objTextFile 						= CreateObject(CTextFile)
		 
		strMenuPath									= Server.MapPath(session("VIRTUAL_DIR")) & "\" & mdm_GetDictionary().Item("MOM_MENU_DEFINITION_FOLDER") & "\menu"
		strGeneratedXMLMenuFileName = strMenuPath & "\menu.temp.xml" ' Generated Menu
		
		strMenuFileCSVList      		= mdm_GetDictionary().Item(mdm_GetDictionary().Item("MOM_MENU_DEFINITION")) ' Double lookp up		
    
    ' Detect payment server and load  the files name entries that describe the payment server entries
    If mom_IsPaymentServerMachine() Then
        strMenuFileCSVList = strMenuFileCSVList & vbNewLine & mdm_GetDictionary().Item("PAYMENT_SERVER_MOM_MENU_LIST") ' Double lookp up		
    End If
    
		strMenuFileCSVList      		= Replace(strMenuFileCSVList,vbCR,"")		
		strMenuFileCSVList      		= Replace(strMenuFileCSVList,vbLF,"")				
		strMenuFileCSVList      		= Replace(strMenuFileCSVList,vbTAB,"")				
		strMenuFileCSVList      		= Replace(strMenuFileCSVList," ","")
		arrMenuFile     						= Split(strMenuFileCSVList,",")
		
		For Each strMenuFile In arrMenuFile
		
				strXMLMenu = strXMLMenu & objTextFile.LoadFile(strMenuPath & "\" & strMenuFile) & vbNewLine
		Next
		strMainXML 			= objTextFile.LoadFile(strMenuPath & "\menu.reserved.xml") & vbNewLine ' Load the template menu xml file
		strMainXML 			= Replace(strMainXML,"[CONTENT]",strXMLMenu) ' Insert the menu definition
		objTextFile.LogFile strGeneratedXMLMenuFileName, strMainXML, TRUE	' Write the temporary xml menu file
		mom_GetMenuName = strGeneratedXMLMenuFileName ' Return the file name to user		
END FUNCTION


PRIVATE FUNCTION GetMomMenuFileName()

    GetMomMenuFileName = mdm_GetDictionaryValue("MOM.MENU.FILENAME","")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mom_GetAccountCreationMsixdefFileName
' PARAMETERS		:
' DESCRIPTION 	: Return the file name of the AccountCreation.msixdef file. By default the dictionary entry ACCOUNT_CREATION_MSIXDEF_FILE_NAME
'                 is empty so we will use metratech.com\AccountCreation.msixdef, which use the MSIXHandler+RCD object to retreive the metratech.com\AccountCreation.msixdef
'                 stored in core. If the entry is defined it implement a full path+ full name. The MSIXHandler will read then the file without using the RCD.
'                 See the VB COM Object MT MAM.
' RETURNS			  :
PUBLIC FUNCTION mom_GetAccountCreationMsixdefFileName()

    mom_GetAccountCreationMsixdefFileName = mdm_GetDictionary().Item("ACCOUNT_CREATION_MSIXDEF_FILE_NAME")
END FUNCTION
Function FolderExists(fldr)
   Dim fso
   Set fso = CreateObject("Scripting.FileSystemObject")
      FolderExists = fso.FolderExists(fldr)
End Function
FUNCTION InitializeApplication() ' As Boolean

    DIM APP_FOLDER, objDictionary, objRCD
            If(IsEmpty(Session("mdm_APP_LANGUAGE")))Then        
        	    if(instr(1, request.ServerVariables("QUERY_STRING"), "language%3d")=0) then
	                Session("mdm_APP_LANGUAGE") = mom_LANGUAGE
              else
                  dim lang
                  lang = mid(Request.ServerVariables("QUERY_STRING"), instr(1, request.ServerVariables("QUERY_STRING"), "language%3d")+11, 5)
                  if(not FolderExists(Application("startPage")  & "/default/localized/" & lang)) then
                    lang = mom_LANGUAGE
                  end if
                  Session("mdm_APP_LANGUAGE") = lang 
              end if
            end if
    FrameWork.Initialize TRUE
    
    Set objRCD                = CreateObject("Metratech.RCD")    
    Session("VIRTUAL_DIR")    = mid(request.ServerVariables("SCRIPT_NAME"), 1, instr(2, request.ServerVariables("SCRIPT_NAME"), "/") - 1)
    Session("EXTENSION_DIR")  = objRCD.ExtensionDir
    Session("INSTALL_DIR")    = objRCD.InstallDir
    
    ' setup application start page
    Application("startPage")                    = Mid(request.ServerVariables("SCRIPT_NAME"), 1, instr(2, request.ServerVariables("SCRIPT_NAME"), "/") - 1)   '"
    Session("LocalizedPath")                    = Application("startPage")  & "/default/localized/" & Session("mdm_APP_LANGUAGE")
    APP_FOLDER                                  = Server.MapPath("/mom")
    Session("mdm_APP_FOLDER")                   = APP_FOLDER ' Store the application folder for the mdm
    Application("APP_HTTP_PATH")                = Mid(request.ServerVariables("SCRIPT_NAME"), 1, instr(2, request.ServerVariables("SCRIPT_NAME"), "/") - 1) ' " 
    Session("VIRTUAL_DIR")                      = Mid(request.ServerVariables("SCRIPT_NAME"), 1, instr(2, request.ServerVariables("SCRIPT_NAME"), "/") - 1) ' "
    Set Session("mdm_LOCALIZATION_DICTIONARY")  = FrameWork.Dictionary
    'Session("mdm_APP_LANGUAGE")                 = mom_LANGUAGE    
    
    LoadDictionary APP_FOLDER, Session("mdm_APP_LANGUAGE") , FrameWork.Dictionary '"
    
    InitializeApplication = TRUE
END FUNCTION

FUNCTION LoadDictionary(APP_FOLDER,strLanguage,objDictionary) ' As Boolean

    objDictionary.Clear
    
    ' Read the dictionary entries that do not need to be localized
    ' Generally it is the mam application logical physical links
    objDictionary.LoadFolder APP_FOLDER & "\default\LinkLookUp" , TRUE ' MDM V2 Read dictionary sub folder
    
    ' Read the DEFAULT dictionary entries that do need to be localized
    objDictionary.LoadFolder APP_FOLDER & "\Default\Localized\" & strLanguage & "\TextLookUp", TRUE ' MDM V2 Read dictionary sub folder
    
    ' Read the dictionary entries that do not need to be localized
    ' Generally it is the mam application logical physical links
    objDictionary.LoadFolder APP_FOLDER & "\custom\LinkLookUp" , TRUE ' MDM V2 Read dictionary sub folder
    
    ' Read the DEFAULT dictionary entries that do need to be localized
    objDictionary.LoadFolder APP_FOLDER & "\custom\Localized\" & strLanguage & "\TextLookUp", TRUE ' MDM V2 Read dictionary sub folder    
    
    ' Make sure the dictionary entry for APP_HTTP_PATH agrees with or virtual directory   '"
    objDictionary.Add "APP_HTTP_PATH" , application("APP_HTTP_PATH")
    objDictionary.Add "APP_PATH" , Server.MapPath(application("APP_HTTP_PATH"))
    
    objDictionary.Render    
    
    LoadDictionary = TRUE
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION mom_GetUsageServerClientObject() ' As String
    dim objUSM
    set objUSM = CreateObject("MetraTech.UsageServer.Client")
    set objUSM.SessionContext=FrameWork.SessionContext

	set mom_GetUsageServerClientObject = objUSM
END FUNCTION

PRIVATE FUNCTION mom_RetrieveBackoutRerunObject(lngReRunId)

    Dim objReRun
    
    lngReRunId              = CLng(lngReRunId)
    Set objReRun            = Server.CreateObject(MT_BILLING_RERUN_PROG_ID)
    objReRun.Login FrameWork.SessionContext
    objReRun.ID             = lngReRunId
    Set mom_RetrieveBackoutRerunObject = objReRun
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION mom_GetDurationMessage(dtStart,dtEnd) ' As String
  dim iDuration,sDuration
  iDuration = DateDiff("n",dtStart,dtEnd)
  if not isnull(iDuration)  then
    if iDuration = 0 then
      iDuration = DateDiff("s",dtStart,dtEnd)
      sDuration = " [" & iDuration & " second" & iif(iDuration=1,"","s") & "]"
    else
      sDuration = " [" & iDuration & " minute" & iif(iDuration=1,"","s") & "]"                          
    end if
    mom_GetDurationMessage=dtStart & sDuration
  else
    mom_GetDurationMessage=""
  end if
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION mom_GetAdapterInstanceStatusMessage(sStatusCode,dtEffectiveDate)

  dim sStatusText
  select case sStatusCode
    case "ReadyToRun"
      sStatusText = "Ready To Run"
    case "ReadyToReverse"
      sStatusText = "Ready To Reverse"
    case "NotYetRun"
      sStatusText = "Not Yet Run"
    
    case else
      sStatusText = sStatusCode
  end select
  
  if not isNull(dtEffectiveDate) then
    sStatusText = sStatusText & " after " & dtEffectiveDate
  end if
  mom_GetAdapterInstanceStatusMessage = sStatusText
END FUNCTION


FUNCTION mom_GetAdapterRunReverseStatusErrorMessage(sErrorCode) ' As Rowset

  select case RTRIM(LTRIM(sErrorCode))
    case "Succeeded":
      mom_GetAdapterRunReverseStatusErrorMessage = mom_GetDictionary("MoM_ERROR_AdapterRunReverseStatusErrorMessage_Succeeded") 
    case "Failed":
      mom_GetAdapterRunReverseStatusErrorMessage = mom_GetDictionary("MoM_ERROR_AdapterRunReverseStatusErrorMessage_Failed") 
    case "ReadyToRun":
      mom_GetAdapterRunReverseStatusErrorMessage = mom_GetDictionary("MoM_ERROR_AdapterRunReverseStatusErrorMessage_ReadyToRun") 
    case "Running":
      mom_GetAdapterRunReverseStatusErrorMessage = mom_GetDictionary("MoM_ERROR_AdapterRunReverseStatusErrorMessage_Running") 
    case "Reversing":
      mom_GetAdapterRunReverseStatusErrorMessage = mom_GetDictionary("MoM_ERROR_AdapterRunReverseStatusErrorMessage_Reversing") 
    case "NotImplemented":
      mom_GetAdapterRunReverseStatusErrorMessage = mom_GetDictionary("MoM_ERROR_AdapterRunReverseStatusErrorMessage_NotImplemented") 
    case "NotYetRun", "ReadyToRun":
      mom_GetAdapterRunReverseStatusErrorMessage = mom_GetDictionary("MoM_ERROR_AdapterRunReverseStatusErrorMessage_NotYetRun") 
    case "Missing":
      mom_GetAdapterRunReverseStatusErrorMessage = mom_GetDictionary("MoM_ERROR_AdapterRunReverseStatusErrorMessage_Missing") 
    case "NotCreated":
      mom_GetAdapterRunReverseStatusErrorMessage = mom_GetDictionary("MoM_ERROR_AdapterRunReverseStatusErrorMessage_NotCreated") 
    case else:
      mom_GetAdapterRunReverseStatusErrorMessage = mom_GetDictionary("MoM_ERROR_AdapterRunReverseStatusErrorMessage_UNKOWN")  & sErrorCode
  end select
END FUNCTION

FUNCTION mom_GetBackoutRerunSynchronousOperationSetting() ' As Boolean
  mom_GetBackoutRerunSynchronousOperationSetting = false
END FUNCTION

PRIVATE FUNCTION mom_CheckError(sOperation) ' As Boolean

    mom_CheckError = FALSE
    If(Err.Number)Then 
        EventArg.Error.Save Err 
        EventArg.Error.Description = EventArg.Error.Description & "; Operation=" & sOperation
        Err.Clear 
        Exit Function
    End If        
    Err.Clear
    mom_CheckError = TRUE
END FUNCTION

PUBLIC FUNCTION mom_ConfirmDialogEncodeAllURL(strTitle, strMessage, strRouteTo, bDisplayAsError)
    'mam_ConfirmDialogEncodeAllURL = mam_GetDictionary("CONFIRM_DIALOG") & "?Title=" & Server.URLEncode(strTitle) & "&Message=" & Server.URLEncode(strMessage) & "&RouteTo=" & Server.URLEncode(strRouteTo)
    mom_ConfirmDialogEncodeAllURL = mom_GetDictionary("CONFIRM_DIALOG") & "?Title=" & Server.URLEncode(strTitle) & "&Message=" & Server.URLEncode(strMessage) & "&RouteTo=" & Server.URLEncode(strRouteTo) & "&DisplayAsError=" 
    if bDisplayAsError then
      mom_ConfirmDialogEncodeAllURL = mom_ConfirmDialogEncodeAllURL & "true"
    else
      mom_ConfirmDialogEncodeAllURL = mom_ConfirmDialogEncodeAllURL & "false"
    end if
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    AddQuickSearchFields
' PARAMETERS:  
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION mom_AddQuickSearchFieldsForAccounts(strMDMPropertyName)
   Dim objSearchOn
   Set objSearchOn = mdm_CreateObject(CVariables)

   'objSearchOn.Add "username","username",,,"User Name"
   'objSearchOn.Add "phonenumber","phonenumber",,,"Phonenumber"
   'objSearchOn.Add "invoice","invoice",,,"Invoice ID"
  objSearchOn.LoadCSVString mom_GetDictionary("ACCOUNT_QUICK_SEARCH_FIELD_LIST")
  
'AddValidListOfValueFromDictionaryCollection
   Service.Properties(strMDMPropertyName).AddValidListOfValues objSearchOn
   Service.Properties(strMDMPropertyName).EnumTypeSupportEmpty = FALSE
   
   mom_AddQuickSearchFieldsForAccounts = TRUE
END Function 
%>

