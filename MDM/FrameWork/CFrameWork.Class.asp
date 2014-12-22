<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2002 by MetraTech Corporation
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
' NAME          : CFrameWork.Class.Asp - MetratTech Application FrameWork
' VERSION         : 1.0
' CREATION_DATE   : 01/03/2001
' AUTHOR         : UI Team
' DESCRIPTION     :
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


' FrameWork Error message
PUBLIC CONST FRAMEWORK_ERROR_1000 = "FRAMEWORK_ERROR_1000-Cannot include file [FILE]"

PUBLIC CONST FRAMEWORK_MIN_DATE   = #1753/1/1 00:00:00#

' FrameWork Dynamic ASP Include
PUBLIC CONST  VBSCRIPT_CLASS_PREFIX = "VBSCRIPT.CLASS:"

' MT Logger mode
PUBLIC CONST LOGGER_TRACE    = 6
PUBLIC CONST LOGGER_DEBUG    = 5
PUBLIC CONST LOGGER_INFO     = 4
PUBLIC CONST LOGGER_WARNING  = 3
PUBLIC CONST LOGGER_ERROR    = 2
PUBLIC CONST LOGGER_FATAL    = 1
PUBLIC CONST LOGGER_OFF      = 0

PUBLIC CONST ACCOUNT_TYPE_CSR = "SYSTEMUSER"
PUBLIC CONST ACCOUNT_TYPE_SUB = "CORESUBSCRIBER"
PUBLIC CONST ACCOUNT_TYPE_MOM = "MOM"
PUBLIC CONST ACCOUNT_TYPE_MCM = "MCM"

' Internal names used to stored information in the session
PUBLIC CONST FRAMEWORK_APP_STARTPAGE    	= "FRAMEWORK_APP_STARTPAGE"
PUBLIC CONST FRAMEWORK_APP_FOLDER       	= "FRAMEWORK_APP_FOLDER"
PUBLIC CONST FRAMEWORK_APP_DICTIONARY   	= "FRAMEWORK_APP_DICTIONARY"
PUBLIC CONST FRAMEWORK_APP_LANGUAGE     	= "FRAMEWORK_APP_LANGUAGE"
PUBLIC CONST FRAMEWORK_APP_PATH         	= "FRAMEWORK_APP_PATH"
PUBLIC CONST FRAMEWORK_APP_LANGUAGE_SHORT   = "FRAMEWORK_APP_LANGUAGE_SHORT"
PUBLIC CONST FRAMEWORK_LOCALIZED_PATH   	= "FRAMEWORK_LOCALIZED_PATH"
PUBLIC CONST FRAMEWORK_APP_RCD          	= "FRAMEWORK_APP_RCD"


PUBLIC CONST FRAMEWORK_DEFAULT_LANGUAGE = "en-us"
PUBLIC CONST MTLOGGER_PROG_ID           = "MTLogger.MTLogger.1"

' I added the word alias to when we use the mdm we do have const twice declared
PUBLIC CONST alias_mdm_APP_LANGUAGE           = "mdm_APP_LANGUAGE" ' For these 3 ones the name and the value must be the same...
PUBLIC CONST alias_mdm_APP_FOLDER             = "mdm_APP_FOLDER"
PUBLIC CONST alias_mdm_LOCALIZATION_DICTIONARY= "mdm_LOCALIZATION_DICTIONARY"


PRIVATE CONST FRAMEWORK_INTERNAL_ERROR_1000 = "Cannot create COM object [PROGID]"
PRIVATE CONST FRAMEWORK_INTERNAL_ERROR_1001 = "The Application FrameWork Class cannot be initialized."
PRIVATE CONST FRAMEWORK_INTERNAL_ERROR_1002 = "The Application FrameWork cannot read the XML dictionary files. Look at the log file for more details."

' --- SECURITY --- RMP 3.0
PUBLIC CONST   MT_AUTH_SECURITY_POLICY_PROGID			= "Metratech.MTSecurity"
PUBLIC CONST   MT_AUTH_ACCOUNT_PROGID 						= "Metratech.MTAuthAccount"
PUBLIC CONST   MT_AUTH_ROLE_PROGID 								= "Metratech.MTRole"
PUBLIC CONST   MT_AUTH_SECURITY_CONTEXT_PROGID 		= "Metratech.MTSecurityContext"
PUBLIC CONST   MT_AUTH_COMPOSITE_TYPE_PROGID 			= "Metratech.MTCompositeCapabilityType"
PUBLIC CONST   MT_AUTH_ATOMIC_TYPE_PROGID 				= "Metratech.MTAtomicCapabilityType"
PUBLIC CONST   MT_AUTH_COMPOSITE_PROGID 					= "Metratech.MTCompositeCapability"
PUBLIC CONST   MT_AUTH_PATH_CAP_PROGID 						= "Metratech.MTPathCapability"
PUBLIC CONST   MT_AUTH_ACCESSTYPE_CAP_PROGID 			= "Metratech.MTAccessTypeCapability"
PUBLIC CONST   MT_AUTH_SESSION_CONTEXT_PROGID 		= "Metratech.MTSessionContext"
PUBLIC CONST   MT_AUTH_COMKioskAuth              	= "COMKioskAuth.COMKioskAuth.1"
PUBLIC CONST   MT_AUTH_COMCredentials            	= "ComCredentials.ComCredentials.1"
PUBLIC CONST   MT_AUTH_LOGIN_CONTEXT_PROGID       =  "Metratech.MTLoginContext"

PUBLIC CONST   MT_ADJUSTMENT_CATALOG_PROG_ID      = "MetraTech.Adjustments.AdjustmentCatalog"


'PUBLIC CONST MT_AUTH_SECURITY_POLICY_PROGID     = "MTAuthProto.MTSecurityPolicy"
'PUBLIC CONST MT_AUTH_ACCOUNT_PROGID       			= "MTAuthProto.MTAuthAccount"
'PUBLIC CONST MT_AUTH_ROLE_PROGID         			  = "MTAuthProto.MTRole"
'PUBLIC CONST MT_AUTH_SECURITY_CONTEXT_PROGID    = "MTAuthProto.MTSecurityContext"
'PUBLIC CONST MT_AUTH_LOGIN_CONTEXT_PROGID       =  "MTAuthProto.MTLoginContext"
'PUBLIC CONST MT_AUTH_COMPOSITE_TYPE_PROGID      = "MTAuthProto.MTCompositeCapabilityType"
'PUBLIC CONST MT_AUTH_ATOMIC_TYPE_PROGID         = "MTAuthProto.MTAtomicCapabilityType"
'PUBLIC CONST MT_AUTH_COMPOSITE_PROGID           = "MTAuthProto.MTCompositeCapability"
'PUBLIC CONST MT_AUTH_PATH_CAP_PROGID            = "MTAuthProto.MTPathCapability"
'PUBLIC CONST MT_AUTH_ACCESSTYPE_CAP_PROGID      = "MTAuthProto.MTAccessTypeCapability"

' Object stored in session - Do not change this const because they are duplicated in mdmconst.asp
PUBLIC CONST FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME  = "FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME"
PUBLIC CONST FRAMEWORK_SECURITY_SECURITY_POLICY_SESSION_NAME  = "FRAMEWORK_SECURITY_SECURITY_POLICY_SESSION_NAME"
PUBLIC CONST FRAMEWORK_SECURITY_IS_AUTHENTICATED_SESSION_NAME = "FRAMEWORK_SECURITY_IS_AUTHENTICATED_SESSION_NAME"
PUBLIC CONST FRAMEWORK_SECURITY_ACCOUNT_CATALOG_SESSION_NAME  = "FRAMEWORK_SECURITY_ACCOUNT_CATALOG_SESSION_NAME"
PUBLIC CONST FRAMEWORK_SE_WRITER_SESSION_NAME                 = "FRAMEWORK_SE_WRITER_SESSION_NAME"
PUBLIC CONST FRAMEWORK_SE_READER_SESSION_NAME                 = "FRAMEWORK_SE_READER_SESSION_NAME"
PUBLIC CONST FRAMEWORK_SECURITY_LOGIN_SESSION_NAME            = "FRAMEWORK_SECURITY_LOGIN_SESSION_NAME"
PUBLIC CONST FRAMEWORK_SECURITY_NAMESPACE_SESSION_NAME        = "FRAMEWORK_SECURITY_NAMESPACE_SESSION_NAME"
PUBLIC CONST FRAMEWORK_SECURITY_PRODUCT_CATALOG               = "FRAMEWORK_SECURITY_PRODUCT_CATALOG"

PUBLIC CONST FRAMEWORK_SECURITY_LOG_ON_ERROR_CODE_WRONG_USERNAME_OR_PASSWORD                    = 1
PUBLIC CONST FRAMEWORK_SECURITY_LOG_ON_ERROR_CODE_NO_CAPABILITY_TO_LOG_ON_TO_THIS_APPLICATION   = 2
PUBLIC CONST FRAMEWORK_SECURITY_LOG_ON_ERROR_CODE_OK                       											= 4
PUBLIC CONST FRAMEWORK_SECURITY_LOG_ON_ERROR_CODE_CANNOT_CREATE_COM_OBJECT            					= 8

PUBLIC CONST MTDECIMALCAPABILITY_OPERATOR_TYPE_NONE = 0          ' no operator defined
PUBLIC CONST MTDECIMALCAPABILITY_OPERATOR_TYPE_LIKE = 1          ' LIKE
PUBLIC CONST MTDECIMALCAPABILITY_OPERATOR_TYPE_LIKE_W = 2        ' LIKE that adds wildcard to value (for convenience)
PUBLIC CONST MTDECIMALCAPABILITY_OPERATOR_TYPE_EQUAL = 3         ' =
PUBLIC CONST MTDECIMALCAPABILITY_OPERATOR_TYPE_NOT_EQUAL = 4     ' !=
PUBLIC CONST MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER = 5       '  >
PUBLIC CONST MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER_EQUAL = 6 ' >=
PUBLIC CONST MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS = 7          ' <
PUBLIC CONST MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS_EQUAL = 8    ' <=
		
PUBLIC FrameWork                ' As CFrameWork ' The Instance is automaticaly created if this file is included.
Set FrameWork = New CFrameWork  ' Allocate the instance


' -- METRATIME --
PUBLIC CONST METRATIMECLIENT_PROG_ID  = "MetraTech.MetraTimeClient"

If(UCase(Request.QueryString("ShowHelp"))="TRUE")Then FrameWork.OpenHelpForm

CLASS CFrameWork ' -- The FrameWork Class --
			
		 ' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		 '
		 '                                                                               SECURITY FUNCTIONS RMP 3.0 
		 '
		 ' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	    ' -- Private Members Definition
	    Private m_booMDMMode            ' As Boolean
	    Private m_objError              ' As CFrameWorkError
      Private m_objRCD                ' As RCD 
      Private m_objMSIXTools
      Private m_objMetraTimeClient
      Private m_objConfigHelper
      Private m_objTextFile
      Private m_objAdjustmentCatalog

	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : 
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :                      
      PUBLIC PROPERTY GET ConfigHelper()
      
        If IsEmpty(Session("FRAMEWORK_CONFIG_HELPER")) Then
            Set Session("FRAMEWORK_CONFIG_HELPER") = CreateObject("MTConfigHelper.ConfigHelper")
            Session("FRAMEWORK_CONFIG_HELPER").Initialize FALSE
        End If
        Set ConfigHelper = Session("FRAMEWORK_CONFIG_HELPER")
      END PROPERTY

	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : 
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :                      
     PUBLIC PROPERTY GET MSIXTools()
        If IsEmpty(m_objMSIXTools) Then Set m_objMSIXTools = CreateObject("MTMSIX.MSIXTools")
        Set MSIXTools =  m_objMSIXTools
     END PROPERTY

	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : 
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :                      
     PUBLIC PROPERTY GET TextFile()
        If IsEmpty(m_objTextFile) Then Set m_objTextFile = CreateObject("MTVBLIB.CTextFile")
        Set TextFile =  m_objTextFile
     END PROPERTY
     
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : 
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :                     
     PUBLIC PROPERTY GET MetraTimeClient()
     
        If IsEmpty(m_objMetraTimeClient) Then Set m_objMetraTimeClient = CreateObject(METRATIMECLIENT_PROG_ID)
        Set MetraTimeClient = m_objMetraTimeClient
     END PROPERTY

	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : 
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :                     
     PUBLIC PROPERTY GET MetraTimeGMTNow()
        
        MetraTimeGMTNow = MetraTimeClient.GetMTOleTime()
        If Err.Number Then
          MTNow = Empty
        End If
     END PROPERTY
     
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : 
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :                     
     PUBLIC PROPERTY GET MetraTimeGMTEndOfCurrentMonth()
     
         MetraTimeGMTEndOfCurrentMonth = LastDayOfMonth(MetraTimeGMTNow)
     END PROPERTY     
    
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : 
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :                    
     PUBLIC PROPERTY GET MetraTimeGMTBeginOfCurrentMonth()
     
        MetraTimeGMTBeginOfCurrentMonth = FirstDayOfMonth(MetraTimeGMTNow)
     END PROPERTY         
    
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : 
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :                    
    PRIVATE FUNCTION FirstDayOfMonth(datDate)
    
       Dim d, lngMonth ' As Date
       d          = LastDayOfMonth(datDate) ' Get the end of the month
       d          = DateAdd("d", -(Day(d)-1), d)       
       FirstDayOfMonth = d
    END FUNCTION         
    
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : 
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :                    
    PRIVATE FUNCTION LastDayOfMonth(datDate)
    
       Dim d ' As Date
       d              = DateAdd("m", 1, datDate)
       d              = DateAdd("d", -Day(d), d)       
       LastDayOfMonth = d
    END FUNCTION         

	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : 
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :                
     PUBLIC FUNCTION RemoveTime(datDate)     
          RemoveTime = CDate(Int(CDbl(CDate(datDate))))
      END FUNCTION
            
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : Login
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :            
      PUBLIC PROPERTY GET Login() 
          Login = Session(FRAMEWORK_SECURITY_LOGIN_SESSION_NAME)
      END PROPERTY
      
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : NameSpace
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :      
      PUBLIC PROPERTY GET NameSpace() 
          NameSpace = Session(FRAMEWORK_SECURITY_NAMESPACE_SESSION_NAME)
      END PROPERTY

      ' ---------------------------------------------------------------------------------------------------------------------------------------
      ' FUNCTION          : Form_DisplayErrorMessage
      ' PARAMETERS        :
      ' DESCRIPTION       : Custom error box for login pages - MAM, MCM, MOM - not - MPM or samplesite
      ' RETURNS           :
      PUBLIC FUNCTION DisplayLoginErrorMessage(EventArg) ' As Boolean
      
        Dim strPath,   strDetail 
        strPath = Framework.GetDictionary("DEFAULT_PATH_REPLACE")
      
        ' write clsErrorText style so MDM will pick it up
        Response.write "<style>"
        Response.write ".ErrorCaptionBar{	BACKGROUND-COLOR: #FDFECF;	BORDER-BOTTOM:#9D9F0F solid 1px;	BORDER-LEFT: #9D9F0F solid 1px;	BORDER-RIGHT: #9D9F0F solid 1px;	BORDER-TOP:#9D9F0F solid 1px; COLOR: black;	FONT-FAMILY: Arial;	FONT-SIZE: 10pt;	FONT-WEIGHT: bold;	TEXT-ALIGN: left;	padding-left : 5px;	padding-right : 5px;	padding-top : 2px;	padding-bottom : 2px;}"
        Response.write ".Error{ position:absolute; top:155px; left:200px; z-index:500; width:250px; filter: alpha(opacity=80); overflow:hidden; }"
        Response.write "</style>"
        Response.write "<div class='Error'>"
        Response.write " <center><TABLE BGCOLOR=""#FFFFC4"" BORDER=""0"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""Black"" style=""margin-top: 5px;"">"
        Response.write "  <TR>"
        Response.write "  <TD Class='ErrorCaptionBar'>" 
        Response.write "   <IMG SRC='" & strPath & "/images/error.gif' valign=""center"" BORDER=""0"" >&nbsp;"
      	
        If Len(EventArg.Error.LocalizedDescription) Then
      	    
            Response.write  FrameWork.Dictionary.PreProcess(EventArg.Error.LocalizedDescription)
      			
        ElseIf Len(EventArg.Error.Description) Then   
      
            Response.write  FrameWork.Dictionary.PreProcess(EventArg.Error.Description)
      
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
        Response.write "</A></CENTER>"
        Response.write "    </TD>"  
        Response.write "    </TR>"
        Response.write "  </TABLE></center>"
        Response.write "</div>"
      
        DisplayLoginErrorMessage = TRUE
      END FUNCTION
        
      ' ---------------------------------------------------------------------------------------------------------------------------------------
      ' FUNCTION          : GetLoginErrorMessage
      ' PARAMETERS        :
      ' DESCRIPTION       : GetLoginErrorMessage string
      ' RETURNS           :
      PUBLIC FUNCTION GetLoginErrorMessage(EventArg) ' As Boolean
        Dim strPath,   strDetail 
        strPath = Framework.GetDictionary("DEFAULT_PATH_REPLACE")
        
        GetLoginErrorMessage = ""
        If Len(EventArg.Error.LocalizedDescription) Then
            GetLoginErrorMessage = GetLoginErrorMessage &  FrameWork.Dictionary.PreProcess(EventArg.Error.LocalizedDescription)
        ElseIf Len(EventArg.Error.Description) Then   
            GetLoginErrorMessage = GetLoginErrorMessage &  FrameWork.Dictionary.PreProcess(EventArg.Error.Description)
        End If
        
        strDetail = "Number=" & EventArg.Error.Number & " Description=" & EventArg.Error.Description & " Source=" & EventArg.Error.Source
        
        strDetail = Replace(strDetail,"\","|")
        strDetail = Replace(strDetail,vbNewLine,"")
        strDetail = Replace(strDetail,Chr(13),"")
        strDetail = Replace(strDetail,Chr(10),"")
        strDetail = Replace(strDetail,"'","\'")
        strDetail = Replace(strDetail,"; ","\n")
        strDetail = Replace(strDetail,";","")
            
        GetLoginErrorMessage = GetLoginErrorMessage & "<BR><BR><CENTER><FONT size=2><A Name='butDetail' HREF='#' OnClick=""alert('" & strDetail  & "')"">"
        GetLoginErrorMessage = GetLoginErrorMessage & "</A></CENTER>"
      END FUNCTION
              
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : LogOn
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :
		 PUBLIC FUNCTION LogOn(strApplicationEnumTypeValue, strLogin, strPassWord, strNameSpace, strTicket, strErrorMessage) ' As Boolean

					Dim objLoginContext, objSessionContext, objAccountCatalog

					LogOn = FRAMEWORK_SECURITY_LOG_ON_ERROR_CODE_CANNOT_CREATE_COM_OBJECT
					
					On Error Resume Next
					Set Session(FRAMEWORK_SECURITY_SECURITY_POLICY_SESSION_NAME) = Server.CreateObject(MT_AUTH_SECURITY_POLICY_PROGID)
					If Err.Number Then strErrorMessage = GetVBErrorString() : Exit Function
					
					Set objLoginContext = CreateObject(MT_AUTH_LOGIN_CONTEXT_PROGID)
					If Err.Number Then strErrorMessage = GetVBErrorString() : Exit Function

          Dim auth
          set auth = Server.CreateObject("MetraTech.Security.Auth")
          auth.InitializeWithLanguage strLogin, strNameSpace, GetLanguageIntegerCode(Session("PAGE_LANGUAGE"))
          If Len(strTicket) > 0 Then 'If a ticket is passed, use it
            LogOn = auth.LoginWithTicket(strTicket, objSessionContext)
          Else
            LogOn = auth.Login(strPassWord, strApplicationEnumTypeValue, objSessionContext)
          End if

 					If Err.Number Then 
  			  		strErrorMessage = GetVBErrorString()
        			LogOn           = FRAMEWORK_SECURITY_LOG_ON_ERROR_CODE_WRONG_USERNAME_OR_PASSWORD
							Exit Function
					End If
					
         ' On Error Goto 0
					
					If IsValidObject(objSessionContext) Then
					
							Set Session(FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME) = objSessionContext
							
							If CheckApplicationLogOnCapability(strApplicationEnumTypeValue) Then
              
      						Session(FRAMEWORK_SECURITY_IS_AUTHENTICATED_SESSION_NAME)    = TRUE
                  Session(FRAMEWORK_SECURITY_LOGIN_SESSION_NAME)               = strLogin
                  Session(FRAMEWORK_SECURITY_NAMESPACE_SESSION_NAME)           = strNameSpace
                  Set Session(FRAMEWORK_SECURITY_ACCOUNT_CATALOG_SESSION_NAME) = Server.CreateObject(MT_ACCOUNT_CATALOG_PROG_ID) ' Create and initialize an Account Catalog Object

                  AccountCatalog.Init SessionContext
                  
							Else
									Session(FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME)   = Empty ' Clear the session context
							End If
					End If      
	   END FUNCTION
       
    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION 			: GetProductCatalogObject
    ' PARAMETERS		:
    ' DESCRIPTION 	:
    ' RETURNS			  :
	  PUBLIC PROPERTY GET ProductCatalog()
    
        If IsEmpty(Session(FRAMEWORK_SECURITY_PRODUCT_CATALOG)) Then
            Set Session(FRAMEWORK_SECURITY_PRODUCT_CATALOG) = Server.CreateObject(MT_PRODUCT_CATALOG_PROG_ID)
            Session(FRAMEWORK_SECURITY_PRODUCT_CATALOG).SetSessionContext(SessionContext)
        
        
        End If
    
        Set ProductCatalog = Session(FRAMEWORK_SECURITY_PRODUCT_CATALOG)        
        
     END PROPERTY
     
	  
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : SessionContext
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :
	   PUBLIC PROPERTY GET SessionContext()
	
	     Set SessionContext = Session(FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME)
	   END PROPERTY

	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : 
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :     
     PUBLIC PROPERTY GET AdjustmentCatalog()
  
        If(IsEmpty(m_objAdjustmentCatalog)) Then
        
            Set m_objAdjustmentCatalog = CreateObject(MT_ADJUSTMENT_CATALOG_PROG_ID)
            m_objAdjustmentCatalog.Initialize(SessionContext())
        End If
        Set AdjustmentCatalog = m_objAdjustmentCatalog
     END PROPERTY
     
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : AccountCatalog
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :
	   PUBLIC PROPERTY GET AccountCatalog()
	
	      Set AccountCatalog = Session(FRAMEWORK_SECURITY_ACCOUNT_CATALOG_SESSION_NAME)
	   END PROPERTY   
    
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : SecurityContext
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :
	   PUBLIC PROPERTY GET SecurityContext()
	
  	     Set SecurityContext = SessionContext.SecurityContext
	   END PROPERTY
	
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : Policy
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :
	   PUBLIC PROPERTY GET Policy()
	  
	  	   Set Policy = Session(FRAMEWORK_SECURITY_SECURITY_POLICY_SESSION_NAME)
	   END PROPERTY
	
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : AccountID
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :
	   PUBLIC PROPERTY GET AccountID()
	
		     AccountID = SecurityContext.AccountID
	   END PROPERTY
	
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     :
	   ' PARAMETERS   :
	   ' DESCRIPTION  :
	   ' RETURNS      :
	   PRIVATE FUNCTION GetVBErrorString() ' As String
	
	       GetVBErrorString = "error=" & CStr(Err.Number) & " description=" & Err.Description & " source=" & Err.Source
	   END FUNCTION
	
	   
     
    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION     : GetDecimalCapabilityMaxAmount
    ' PARAMETERS   :
    ' DESCRIPTION  :
    ' RETURNS      :       
    PUBLIC FUNCTION GetDecimalCapabilityMaxAmount(strCapability)
    
      	Dim objCapabilities, objCapability, tmpValue, objDecimal, strHTML
        
        GetDecimalCapabilityMaxAmount = 0
        
      	If SecurityContext.IsSuperUser() Then      
      			GetDecimalCapabilityMaxAmount = -1
      			Exit Function
      	End If

        Set objCapabilities = SecurityContext.GetCapabilitiesOfType(strCapability)
        
      	For Each objCapability In objCapabilities

            GetDecimalCapabilityMaxAmount = CDBL(objCapability.GetAtomicDecimalCapability().GetParameter().Value)
            Exit Function
      	Next      	
    END FUNCTION    
    
    PUBLIC FUNCTION GetDecimalCapabilityMaxAmountAsString(strCapability,strSuperUserLimit)
    
      	Dim objCapabilities, objCapability, tmpValue, objDecimal, strHTML
        
      	If SecurityContext.IsSuperUser() Then
      
            GetDecimalCapabilityMaxAmountAsString = strSuperUserLimit
      			Exit Function
      	End If

        Set objCapabilities    = SecurityContext.GetCapabilitiesOfType(strCapability)
        
        strHTML = strHTML & "<table cellspacing=1 cellpadding=0>"
      	For Each objCapability In objCapabilities
        
            strHTML = strHTML & "<tr>"
            strHTML = strHTML & "<td>" & objCapability.GetAtomicEnumCapability().GetParameter().Value _
                              & "</td><td>" & objCapability.GetAtomicDecimalCapability().GetParameter().Test & "&nbsp;" _
                              & "</td><td>" & objCapability.GetAtomicDecimalCapability().GetParameter().Value & "</td>"
            strHTML = strHTML & "</tr>"                              
      	Next
        strHTML = strHTML & "</table>"
      	GetDecimalCapabilityMaxAmountAsString = strHTML
    END FUNCTION
     
	  
	  PUBLIC FUNCTION CheckApplicationLogOnCapability(strApplicationEnumTypeValue)
	  
		   Dim objCapTypeS, objCapType, objAtomicCap
		   
		   CheckApplicationLogOnCapability = FALSE
		   
		   If SecurityContext.IsSuperUser() Then 
		   
		   	  CheckApplicationLogOnCapability = TRUE
			     Exit Function
		   End If
			 
			 CheckApplicationLogOnCapability = CheckCapability("Application LogOn",strApplicationEnumTypeValue)
		   
		   'Set objCapTypeS = GetCapabilities("Application LogOn")\		   
		   'For Each objCapType in objCapTypeS
		  ' 
			'     Set objAtomicCap = objCapType.GetAtomicEnumCapability()
			'		 
		  '	   If IsValidObject(objAtomicCap) Then
		  '   
		  '  	   		objAtomicCap.Value              = strApplicationEnumTypeValue
			'      	  CheckApplicationLogOnCapability = SecurityContext.CheckAccess(objCapType)
			'     End If
	   'Next
	  END FUNCTION
	  
	  PUBLIC PROPERTY GET GetCapabilities(strCapablityName)
		
	  	 	Set GetCapabilities = Nothing
		    Set GetCapabilities = SecurityContext.GetCapabiltiesOfType(CSTR(strCapablityName))
	  END PROPERTY
		
	  PUBLIC PROPERTY GET GetCapabiltyOfType(strCapablityName,lngIndex)
		
				Dim  objCapabilities
				
				Set GetCapabiltyOfType = Nothing                                                
		    Set objCapabilities    = SecurityContext.GetCapabilitiesOfType(strCapablityName)
				
				If objCapabilities.Count >= lngIndex Then
				
						Set GetCapabiltyOfType = objCapabilities.Item(lngIndex) 
				End If
	  END PROPERTY		
	
	
	 PUBLIC FUNCTION CheckCoarseCapability(strCapability) ' As Boolean
	 
	     Dim objCapabilityInstance ' As Object
	     
  	   CheckCoarseCapability = FALSE

	     On Error Resume Next
	     Set objCapabilityInstance = Policy.GetCapabilityTypeByName(strCapability).CreateInstance()
	     If Err.Number Then
        	 Err.Clear ' We need to clear the error else the MDM will use it		  
    	     Exit Function
	     Else

	         CheckCoarseCapability = SecurityContext.CoarseHasAccess(objCapabilityInstance)
	     End If
	 END FUNCTION

   PUBLIC FUNCTION AssertCourseCapability(strCapability,EventArg)

     If Not FrameWork.CheckCoarseCapability(strCapability) Then
       EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("FRAMEWORK_ERROR_1004") & " " & strCapability
       EventArg.Error.Number      = 1004
       response.write "<html><head><LINK rel='STYLESHEET' type='text/css' href='" & mom_GetDictionary("DEFAULT_PATH_REPLACE") & "/styles/styles.css'></head><body>"  
       Form_DisplayErrorMessage EventArg
       response.write "</body></html>"
       mdm_TerminateDialog
       Response.End
  	 End If
     
     AssertCourseCapability = true 
	 END FUNCTION
      		 
	 PUBLIC FUNCTION CheckCapability(strCapability, strParameter) ' As Boolean
	 
	     Dim objCapabilityInstance ' As Object
			 Dim objCapabilityAtomicInstance ' As Object
	     
	     CheckCapability = FALSE
	   
	     On Error Resume Next
			 Set objCapabilityInstance = Policy.GetCapabilityTypeByName(strCapability).CreateInstance()
			 If Err.Number Then   	
            Err.Clear ' We need to clear the error else the MDM will use it		 
	  		   	Exit Function
	     Else
  			 	 Set objCapabilityAtomicInstance          = objCapabilityInstance.GetAtomicEnumCapability()
					 objCapabilityAtomicInstance.SetParameter strParameter
	         CheckCapability                          = SecurityContext.CheckAccess(objCapabilityInstance)
           If Err.Number=0 Then
              CheckCapability = TRUE
           Else
              Err.Clear ' We need to clear the error else the MDM will use it		 
              CheckCapability = FALSE                
           End If
	     End If
	   END FUNCTION
		 
		 ' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		 '
		 '                                                                               GENERAL RMP 2.0 
		 '
		 ' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		 
  			
	
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Initialize
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC FUNCTION Initialize(booMDMMode) ' As Boolean
	    
	        Dim strMessage
	        
	        ' -- Call the Application_OnStart Event for the first user that start the application 
	        ' -- I think it is not thread safe... But it should be ok for now!
	        If(IsEmpty(Application (FRAMEWORK_APP_STARTPAGE)))Then 
	            
	            Application_OnStart
	            
	            Application (FRAMEWORK_APP_STARTPAGE)  = Mid(request.ServerVariables("SCRIPT_NAME"), 1, instr(2, request.ServerVariables("SCRIPT_NAME"), "/") - 1)
	            Application("APP_HTTP_PATH")           = Application (FRAMEWORK_APP_STARTPAGE)   ' Compatibility with MAM and MOM 1.3
	            Application(FRAMEWORK_APP_PATH)        = Server.MapPath(Application (FRAMEWORK_APP_STARTPAGE))
	        End If
	
	        If(IsEmpty(Session(FRAMEWORK_APP_LANGUAGE)))Then        
	        
	            CheckInternalStuff booMDMMode
	        
	            ' Setup application start page
             if(instr(1, request.ServerVariables("QUERY_STRING"), "language%3d")=0) then
	                if(not IsEmpty(Session("PAGE_LANGUAGE"))) then
                    Session(FRAMEWORK_APP_LANGUAGE) = Session("PAGE_LANGUAGE")
                  else                  
                    Session(FRAMEWORK_APP_LANGUAGE) = FRAMEWORK_DEFAULT_LANGUAGE                      
                  end if
            
              else
                  dim lang
                  lang = mid(Request.ServerVariables("QUERY_STRING"), instr(1, request.ServerVariables("QUERY_STRING"), "language%3d")+11, 5)
                    Session(FRAMEWORK_APP_LANGUAGE) = lang
              end if

	            Session    (FRAMEWORK_APP_FOLDER)     = Server.MapPath(Application(FRAMEWORK_APP_STARTPAGE))
	            Set Session(FRAMEWORK_APP_DICTIONARY) = Server.CreateObject("MTMSIX.Dictionary")
	            
	            ' -- For Compatibility with the past --
	            Session    ("LocalizedPath")          = Application (FRAMEWORK_APP_STARTPAGE) & "/default/localized/" & Session(FRAMEWORK_APP_LANGUAGE)
	            
	            m_booMDMMode = booMDMMode
	            
	            If(MDMmode())Then ' To Assure MDM Compatibility
	            
	                Set Session(alias_mdm_LOCALIZATION_DICTIONARY)     =  Session(FRAMEWORK_APP_DICTIONARY)
	                    Session(alias_mdm_APP_FOLDER)                  =  Application(FRAMEWORK_APP_PATH)
	                    Session(alias_mdm_APP_LANGUAGE)                =  Session(FRAMEWORK_APP_LANGUAGE)
	            End If

				dim langFull
				langFull = Session(FRAMEWORK_APP_LANGUAGE)
				Session(FRAMEWORK_APP_LANGUAGE_SHORT) = Right(langFull, (Len(langFull)-InStrRev(langFull, "-")))
				
	            strMessage = vbNewline  & "*****************************************************************" & vbNewline
	            strMessage = strMessage & " Starting Framework - " & Now                                      & vbNewline
	            strMessage = strMessage & "*****************************************************************"
	            Log strMessage, LOGGER_INFO
	
	            Session_OnStart ' -- Call the Session_OnStart Event for the first time the user initialize the frame work
	        End If
          
          SetDictionaryCommonEntries
          
	        Initialize = TRUE
	    END FUNCTION
	
  PUBLIC FUNCTION SetDictionaryCommonEntries()
    Dictionary.Add "HTTP_COMMON", "/MDM/Common"
    Dictionary.Add "PATH_COMMON", Server.MapPath("/MDM/Common/")
  END FUNCTION
  
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Initialize
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PRIVATE  FUNCTION CheckInternalStuff(booMDMMode) ' As Boolean    
	    
	        CheckNecessaryCOMObject MTLOGGER_PROG_ID
	        
	        If(booMDMMode)Then
	        
		          CheckNecessaryCOMObject "MTVBLIB.CVariable" ' Check MTVBLIB.DLL is there
		          CheckNecessaryCOMObject "MTMSIX.Dictionary" ' Check MTMSIX.DLL is there
	        End If
	    END FUNCTION
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Initialize
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PRIVATE FUNCTION CheckNecessaryCOMObject(strProgId) ' As Boolean        
	        Dim obj
	
	        Set obj = CreateObject(strProgId)
	        If(obj Is Nothing)Then
	        
	            Response.Write Replace(FRAMEWORK_INTERNAL_ERROR_1000,"[PROGID]",strProgId) & "<br>"
	            Response.Write FRAMEWORK_INTERNAL_ERROR_1001 & "<br>"
	            Response.End
	        End If
	    END FUNCTION
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : CreateObject
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PRIVATE  FUNCTION CreateObject(strProgId)
	
	        On Error Resume Next
	        Set CreateObject = Server.CreateObject(strProgId)
	        If(Err.Number)Then
					
	          	Set CreateObject = Nothing
		          Err.Clear
	        End If
	    END FUNCTION
	  
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Error
	    ' PARAMETERS  :
	    ' DESCRIPTION  : Return the CFrameWorkError object associated with the current instance of the FrameWork. The Error object will go away
	    '                 when the page is finished.
	    ' RETURNS     :
	    PRIVATE PROPERTY GET Error() ' As CFrameWorkError
	    
	        If (IsEmpty(m_objError)) Then Set m_objError = New CFrameWorkError
	        Set Error = m_objError
	    END PROPERTY
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : LocalizedPath
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PRIVATE PROPERTY GET LocalizedPath() ' As String
	        
	        LocalizedPath = Application (FRAMEWORK_APP_STARTPAGE) & "/default/localized/" & Session(FRAMEWORK_APP_LANGUAGE)
	    END PROPERTY
	   
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Logger
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PRIVATE PROPERTY GET Logger() ' As "MTLogger.MTLogger.1"        
	    
	        If(IsEmpty(Session("FRAMEWORK_APP_MTLOGGER")))Then 
	        
	            Set Session("FRAMEWORK_APP_MTLOGGER") = Server.CreateObject(MTLOGGER_PROG_ID)
	            Session("FRAMEWORK_APP_MTLOGGER").Init "logging", FRAMEWORK_APPLICATION_NAME
	        End If
	        Set Logger = Session("FRAMEWORK_APP_MTLOGGER")
	    END PROPERTY
	
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Log
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC FUNCTION Log(strText,lngLogMode) ' As Boolean
	    
	          Logger.LogThis CLng(lngLogMode), CStr(strText)
	          Log = TRUE
	    END FUNCTION
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC FUNCTION GetDictionary(strName) ' As String
	    
	       GetDictionary = Dictionary.GetValue(strName)
	    END FUNCTION
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC FUNCTION GetDictionaryDefault(strName, strDefault) ' As String
	    
	       GetDictionary = Dictionary.GetValue(strName, strDefault)
	    END FUNCTION
	        
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC FUNCTION LogOut() ' As Boolean
	    
	        Session_OnEnd ' Call the Event
	        
	        CleanSession  ' Free all objects store in the session        
	        Session.Abandon
	    END FUNCTION    
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : MDMMode
	    ' PARAMETERS  :
	    ' DESCRIPTION  : Returns TRUE if the FrameWork was initialized to work with the MDM.
	    '                 Read-only. Can only be set at initialization time.
	    ' RETURNS     :
	    PUBLIC PROPERTY GET MDMmode() ' As Boolean
	    
	        MDMmode = m_booMDMMode
	    END PROPERTY    
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : ApplicationPath
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC PROPERTY GET ApplicationPath() ' As Boolean
	    
	        ApplicationPath = Session(mdm_APP_FOLDER)
	    END PROPERTY
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : ApplicationPath
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC PROPERTY GET WidgetsPath() ' As Boolean
	    
	        WidgetsPath = Server.MapPath("/mdm")  & "\Common\Widgets"
	    END PROPERTY
	    
	
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Language
	    ' PARAMETERS  :
	    ' DESCRIPTION  : 
	    ' RETURNS     :
	    PUBLIC PROPERTY GET Language() ' As Boolean
	
	        If(IsEmpty(Session(FRAMEWORK_APP_LANGUAGE)))Then Session(FRAMEWORK_APP_LANGUAGE) = FRAMEWORK_DEFAULT_LANGUAGE
	
	        Language = Session(FRAMEWORK_APP_LANGUAGE)
	    END PROPERTY
	    
	    PUBLIC PROPERTY LET Language(v)
	    
	        Session(FRAMEWORK_APP_LANGUAGE) = v
	    END PROPERTY
	   
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Dictionary
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC PROPERTY GET Dictionary() ' As MTMSIX.Dictionary
	    
	       Set Dictionary = Session(FRAMEWORK_APP_DICTIONARY)
	    END PROPERTY
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC PROPERTY GET ApplicationURL() ' As String
	    
	       ApplicationURL = Application (FRAMEWORK_APP_STARTPAGE) 
	    END PROPERTY
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC PROPERTY GET ApplicationFolder() ' As String
	    
	       ApplicationFolder = Session(FRAMEWORK_APP_FOLDER)
	    END PROPERTY
  
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION :
	    ' RETURNS     :           
      PUBLIC PROPERTY GET RCD() ' As String
          If IsEmpty(m_objRCD) Then
             Set m_objRCD = Server.CreateObject(MT_RCD_PROG_ID)
          End If
          Set RCD = m_objRCD
	    END PROPERTY

      ' ---------------------------------------------------------------------------------------------------------------------------------------
      ' FUNCTION    :  GetLangaugesArray
      ' PARAMETERS  :
      ' DESCRIPTION :  Get list of languages form t_language table and return as array
      ' RETURNS     :  Array of language codes
      PUBLIC FUNCTION GetLanguagesArray() ' as array
    	    Dim languages()
    	    Dim rowset
          Dim i
          
          Set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
          rowset.Init "queries\audit" 'dummy
          rowset.SetQueryString "select * from t_language order by tx_lang_code" 
          rowset.Execute
          
          For i=0 to rowset.RecordCount - 1
            Redim Preserve languages(i+1)
            languages(i+1) = rowset.Value("tx_lang_code")
            rowset.MoveNext
          Next
          
          GetLanguagesArray = languages
      END FUNCTION
    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION :
	    ' RETURNS     :     
      PUBLIC FUNCTION IsInfinity(datDate)
      	
        	IsInfinity = CBool(CDate(datDate) = RCD().GetMaxDate())
	    END FUNCTION
      
      PUBLIC FUNCTION IsMinusInfinity(datDate)
      	
        	IsMinusInfinity = CBool(CDate(datDate) = FRAMEWORK_MIN_DATE)
	    END FUNCTION      
      
      PUBLIC FUNCTION GetMinDate()          
          GetMinDate = FRAMEWORK_MIN_DATE
      END FUNCTION
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC FUNCTION LoadDictionary() ' As Boolean
	
	        Dictionary.Clear
	        
	        ' Read the DEFAULT dictionary entries that do NOT need to be localized    
	        LoadDictionarySubFolders ApplicationFolder & "\Default\Dictionary"
	        
	        ' Read the DEFAULT dictionary entries that do need to be localized    
	        LoadDictionarySubFolders ApplicationFolder & "\Default\Localized\" & Language & "\Dictionary"                '"
	
	        ' Read the CUSTOM dictionary entries that do NOT need to be localized    
	        LoadDictionarySubFolders ApplicationFolder & "\Custom\Dictionary"
	        
	        ' Read the CUSTOM dictionary entries that do need to be localized    
	        LoadDictionarySubFolders ApplicationFolder & "\Custom\Localized\" & Language & "\Dictionary"                '"
	         
	        ' Make sure the dictionary entry for APP_HTTP_PATH agrees with or virtual directory
	        Dictionary.Add "APP_HTTP_PATH"       , Application(FRAMEWORK_APP_STARTPAGE) ' For Compatibility with the path
	        Dictionary.Add "HTTP_PATH"           , Application(FRAMEWORK_APP_STARTPAGE)
          Dictionary.Add "APP_PATH"            , Server.MapPath(Application(FRAMEWORK_APP_STARTPAGE))

	        Dictionary.Render ' Replace internal Tags...
          
          SetDictionaryCommonEntries	                  
          
	    END FUNCTION
	
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PRIVATE FUNCTION LoadDictionarySubFolders(strFolder) ' As Boolean
	    
	        ' Read the DEFAULT dictionary entries that do NOT need to be localized
	        If( Not Dictionary.LoadFolder(strFolder,TRUE) ) Then ' Read the first sub level of folder...
	        
	            Response.Write FRAMEWORK_INTERNAL_ERROR_1002
	            Response.End
	        End If
	    END FUNCTION
	
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION   :
	    ' RETURNS     :
	    PRIVATE SUB Class_Terminate() ' As Boolean
	    END SUB
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Initialize
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PRIVATE SUB Class_Initialize() ' As Boolean
	    END SUB
	        
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION   : CleanSession
	    ' PARAMETERS :
	    ' DESCRIPTION : Free all objects store in the session!
	    ' RETURNS    :
	    PRIVATE FUNCTION CleanSession() ' As Boolean
	    
	        Dim itm
	        
	        FrameWork.Log "CleanSession()",LOGGER_DEBUG    
	        
	        For Each itm in Session.Contents
	        
	            If(IsObject(Session(itm)))Then Set Session(itm) = Nothing                  
	            
	            Session(itm) = Empty
	        Next
	        CleanSession = TRUE
	    END FUNCTION      
	    
	    '
	    ' ############# The following properties are not so important - we may get rid of it! ######################
	    '
	    
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : ReDirect
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC FUNCTION ReDirect(strLinkName) ' As Boolean
	    
	        Response.ReDirect(Dictionary.GetValue(strLinkName))
	        ReDirect = TRUE
	    END FUNCTION
	    '
	    
	    '---------------------------------------------------------------------------------------------------------------------------------------    
	    ' FUNCTION    : Transfer
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC FUNCTION Transfer(strLinkName) ' As Boolean
	    
	        Server.Transfer(Dictionary.GetValue(strLinkName))
	
	    END FUNCTION
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : SetLocation
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC FUNCTION SetLocation(strLinkName) ' As Boolean
	  
	        response.write "  <script language=""Javascript"">" & vbNewline
	        response.write "    document.location.href='" & Dictionary.GetValue(strLinkName) & "';" & vbNewline
	        response.write "  </script>" & vbNewline
	    END FUNCTION
	    '---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION  :
	    ' RETURNS     :
	    PUBLIC PROPERTY GET Browser() ' As Boolean
	    
	        Dim objBC
	        
	        Set objBC = Server.CreateObject("MSWC.BrowserType") 
	        Browser   = objBC.browser        
	    END PROPERTY        
	 
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : TestMode
	    ' PARAMETERS  :
	    ' DESCRIPTION  : 
	    ' RETURNS     :
	    PUBLIC PROPERTY GET TestMode() ' As Boolean
	
	        TestMode = CBool(Session("FRAMEWORK_APP_TEST_MODE")) ' The function CBool takes care of the case the session variable is not initiliazed to FALSE or TRUE, CBool(Empty) returns FALSE.
	    END PROPERTY
	    
	    PUBLIC PROPERTY LET TestMode(v)
	    
	        Session("FRAMEWORK_APP_TEST_MODE") = v
	    END PROPERTY
	
	    PUBLIC PROPERTY GET DebugMode() ' As Boolean
	        DebugMode = false
	    END PROPERTY
	        
	    PUBLIC FUNCTION OpenHelpForm()
	          
	        Dim mstrHelpContext   'help context, in this case is the URL of a screen
	        Dim mstrHelpIndexURL  'URL to the help index
	        Dim mstrHelpTitle    'Title of the help page
	        Dim strHelpURL
	
	        mstrHelpContext   = Session("HelpContext") ' Get the help context
	        If(Len(mstrHelpContext))Then
	            Dim objTextFile
	            set objTextFile = server.CreateObject(CTextFile)
	            
	            strHelpURL = LocalizedPath & "/help/" & mstrHelpContext
	                        
	            If Not (objTextFile.ExistFile(server.MapPath(strHelpURL))) Then
	              strHelpURL = LocalizedPath & "/help/" & "welcome.hlp.htm"   ' % % % %  HARD CODED
	            End If
	
	        Else
	            strHelpURL = LocalizedPath & "/help/" & "welcome.hlp.htm"   ' % % % %  HARD CODED
	        End If
	                
	        mstrHelpTitle = FrameWork.Dictionary.GetValue("TEXT_APPLICATION_TITLE","Main Help")
	        
	        mstrHelpIndexURL = LocalizedPath & "/help/mcm.htm" ' % % % % % HARD CODED
	      
	       'write the html page
	       response.write "<html>" 		& vbNewline
	       response.write " <head>" 	& vbNewline
	       response.write "  <title>" & mstrHelpTitle & "</title>" & vbNewline
	       response.write " </head>" 	& vbNewline
	       response.write "" 					& vbNewline
	       response.write " <frameset rows='43px,*' frameborder=0 marginwidth=0 marginheight=0>" & vbNewline
	        
	       response.write "  <frame src='/mcm/helpmenu.asp?HelpURL=" & strHelpURL & "' name='fmeHelpTop' scrolling='no' marginwidth=0 marginheight=0 noresize>" & vbNewline  
	       response.write "   <frame src=""" & mstrHelpIndexURL & """ name=""fmeHelpHTML"" scrolling=""auto"" marginwidth=0 marginheight=0>" & vbNewline
	       response.write " </frameset>" 	& vbNewline
	       response.write "" 							& vbNewline
	       response.write " <body>" 			& vbNewline
	       response.write " </body>" 			& vbNewline
	       response.write "</html>" 			& vbNewline
	    END FUNCTION
	    
		  
		  PUBLIC FUNCTION GetHTMLDictionaryError(strName)
		
		    GetHTMLDictionaryError = "<INPUT Type='HIDDEN' Name='" & strName & "' Value='TRUE'>" & Session("mdm_LOCALIZATION_DICTIONARY").Item(strName).Value
		  END FUNCTION
    
	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : DecodeFieldIDInMSIXProperty
	   ' PARAMETERS   :
     '                  objMSIXSourceProperty - MSIXProperty Object which contains the value to parse
     '                  objMSIXDestProperty -   MSIXProperty Object where to store the ID 
	   ' DESCRIPTION  :
     '                 Parse the value of objMSIXSourceProperty and get the ID, 
     '                 Set the flag eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING to the objMSIXSourceProperty
     '                 Set the ID in the value of objMSIXDestProperty.
     '
     '              objMSIXSourceProperty and objMSIXDestProperty can be the same MSIX Property.
     '              
     '              Sample:
     '
     '              If Not FrameWork.DecodeFieldIDInMSIXProperty(Service("ANCESTORACCOUNT"),Service("ANCESTORACCOUNTID")) Then
     '
     '
     '
	   ' RETURNS      : Return TRUE if an valid id was found.    
      PUBLIC FUNCTION DecodeFieldIDInMSIXProperty(objMSIXSourceProperty,objMSIXDestProperty) ' As Boolean
       
        Dim lngID
        
        DecodeFieldIDInMSIXProperty = FALSE
        
        If DecodeFieldID(objMSIXSourceProperty.Value,lngID) Then
        
            ' Set the flag so we will not meter the property in the next metering
            If Not CBool(objMSIXSourceProperty.Flags And eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING) Then 
            
                objMSIXSourceProperty.Flags = objMSIXSourceProperty.Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
            End If
            
            objMSIXDestProperty.Value       = lngID ' Where objMSIXSourceProperty and objMSIXDestProperty are the same property.
            DecodeFieldIDInMSIXProperty     = TRUE
        End If
      END FUNCTION
      

	   ' ---------------------------------------------------------------------------------------------------------------------------------------
	   ' FUNCTION     : DecodeFieldID
	   ' PARAMETERS   :
     '                  strValue - string to parse. may contains the following : 123, (123), Demo (123), Frederic Torres (123)
     '                  lngID - Will contain the ID
	   ' DESCRIPTION  :
	   ' RETURNS      : Return TRUE if an valid id was found.
      PUBLIC FUNCTION DecodeFieldID(ByVal strValue, ByRef lngID) ' As Boolean
          on error resume next
          Dim lngPos, lngPos2
          
          DecodeFieldID = FALSE
      
          If Len(Trim(strValue))=0 Then ' If there is nothing to parse we regard this as not an error
          
              lngID = Empty
              DecodeFieldID     = TRUE
              on error goto 0
              Exit Function              
          End If
      
          If IsNumeric(Trim(strValue)) And Len(Trim(strValue)) Then
          
              ' Make sure the numeric number is not of the form, "(num)", because it will be translated to a negative value.
              lngPos = InStrRev(strValue,"(")
              If lngPos Then
              lngPos2  = InStr(CLng(lngPos),strValue,")")
              strValue = Mid(strValue,lngPos+1,lngPos2-lngPos-1)
              End If  
                    
              lngID             = CLng(Trim(strValue))
              DecodeFieldID     = TRUE
              on error goto 0
              Exit Function
          End If
          
          lngPos = InStrRev(strValue,"(")
          If lngPos Then
          
              lngPos2  = InStr(CLng(lngPos),strValue,")")
              strValue = Mid(strValue,lngPos+1,lngPos2-lngPos-1)
              
              If IsNumeric(Trim(strValue)) Then
              
                  lngID             = CLng(Trim(strValue))
                  DecodeFieldID     = TRUE
                  on error goto 0
                  Exit Function
              End If
          End If    
          on error goto 0
          ' We Return error - decoding failed    
      END FUNCTION
      
     PUBLIC FUNCTION GetEnumTypeInternalDBID(strNameSpace, strEnumTypeName, strValue) 

          Dim objEnumTypeconfig ' As Object    

          Set objEnumTypeconfig   = CreateObject("Metratech.MTEnumConfig.1")
          GetEnumTypeInternalDBID = objEnumTypeconfig.GetID(strNameSpace, strEnumTypeName, strValue)
    END FUNCTION
    
    PUBLIC FUNCTION GetEnumTypeValueFromID(lngID)
      
          Dim objEnumTypeconfig ' As Object
          
          Set objEnumTypeconfig  = CreateObject("Metratech.MTEnumConfig.1") ' create the object and add it to the cache...
          GetEnumTypeValueFromID = objEnumTypeconfig.GetEnumeratorValueByID(lngID)
    END FUNCTION
    
    PUBLIC FUNCTION LocalizeBoolean(booValue)    
    
       LocalizeBoolean = Dictionary.Item(IIF(booValue,"TEXT_YES","TEXT_NO")).Value
    END FUNCTION
      
  '-----------------------------------------------------------------------------
  ' FUNCTION 			: IsValidDate
  ' PARAMETERS		: dateStr, bTime
  ' DESCRIPTION 	: Validates the string as a date according to some properties
  ' 								in the XML configuration.
  '						
  ' RETURNS			  : TRUE if dateStr contains a valid date string, FALSE if not.
  ' 
  	PUBLIC FUNCTION IsValidDate(dateStr, bTime)
  	
  		Dim vFormatTemplate, vInput
  		Dim vDateTemplate, vDateInput
  		Dim cDateSep, cTimeSep
  		Dim sValidChars
  		Dim iDay, iMonth, iYear, iHour, iMin, iSec, sAMPM
  		Dim i
  		
  		' Start by testing whether this is considered a date by the system	
  		If Not IsDate(dateStr) Then
  			IsValidDate = FALSE
  			Exit Function
  		End If
  		
  		' Get the valid characters
  	  sValidChars = Framework.GetDictionary("MDM_TYPE_TIMESTAMP_CHARS")
  
  		' Check if each character on the input string is a valid character according to the string above
  		For i = 1 To Len(dateStr)
  			If InStr(sValidChars, Mid(dateStr, i, 1)) = 0 Then
  				IsValidDate = False
  				Exit Function
  			End If
  		Next
  	
  		' Separate template into the date subtemplate and time subtemplate, and maybe the AMPM piece
  		vFormatTemplate = Split(Framework.GetDictionary("DATE_TIME_FORMAT"), " ")
  		
  		cDateSep = Framework.GetDictionary("DATE_SEPARATOR")'MID(vFormatTemplate(0), 3, 1)
  		cTimeSep = ":"
  		
  		' Do the same thing for our input string
  		vInput = Split(dateStr, " ")
  		
  		' At this point we have 2 arrays with date, time and AMPM strings. Last 2 are optional
  		
  		' First handle the date part
  		vDateTemplate = Split(vFormatTemplate(0), cDateSep)
  		vDateInput = Split(vInput(0), cDateSep)
  		
  		IsValidDate = TRUE
  		
  		'Validate token by token, date first
  		For i = 0 to UBound(vDateTemplate) ' vDateTemplate is the date-only component of this input
  		
  			If Not IsNumeric(vDateInput(i)) Then
  				IsValidDate = FALSE
  				exit function	
  			End If
  			
  			Select Case UCase(vDateTemplate(i))
  				Case "DD", "D"
  					iDay = Clng(vDateInput(i))
  					If iDay < 1 or iDay > 31 Then
  						IsValidDate = FALSE
  						exit function
  					End If								
  				Case "MM", "M"
  					iMonth = Clng(vDateInput(i))
  					If iMonth < 1 or iMonth > 12 Then
  						IsValidDate = FALSE
  						exit function
  					End If								
  				Case "YY", "YYYY"
  					iYear = Clng(vDateInput(i))
  					If Len(vDateInput(i)) = 2 Then
  						If iYear >= 30 Then
  							iYear = iYear + 1900
  						Else	
  							iYear = iYear + 2000
  						End If
  					End If
  					
  					If iYear < 1930 or iYear > 2038 Then
  						IsValidDate = FALSE
  						exit function
  					End If					
  				Case Else 'error
  					IsValidDate = FALSE
  					exit function
  			End Select
  		Next
  		
  		' Now do the same for the time piece
  		Dim vTimeTemplate, vTimeInput
  		If Ubound(vInput) <= 0 Then ' If no time is specified
  			exit function			
  		' There shouldn't be a time component but it is part of the input - return FALSE	
  		Elseif Not bTime Then
  			bValidDate = FALSE
  			exit function	
  		End If
  		
  		vTimeTemplate = Split(vFormatTemplate(1), cTimeSep)
  		vTimeInput = Split(vInput(1), cTimeSep)
  		
  		For i = 0 to UBound(vTimeTemplate)
            Dim iCurSegment
            
  		    If (i <= UBound(vTimeInput)) Then
  		        iCurSegment = vTimeInput(i)
  		    Else
                iCurSegment = 0
  		    End if
  		    
  			If Not IsNumeric(iCurSegment) Then
  				IsValidDate = FALSE
  				exit function	
  			End If
  
  			Select Case UCase(vTimeTemplate(i))
  				Case "HH"
  					iHour = Clng(iCurSegment)
  					If iHour < 0 or iHour > 24 Then
  						IsValidDate = FALSE
  						exit function
  					End If
  				Case "MM"
  					iMin = Clng(iCurSegment)
  					If iMin < 0 or iMin > 60 Then
  						IsValidDate = FALSE
  						exit function
  					End If								
  				Case "SS"
  					iSec = Clng(iCurSegment)
  					If iSec < 0 or iSec > 60 Then
  						IsValidDate = FALSE
  						exit function
  					End If
  				Case Else ' Error
  					IsValidDate = FALSE
  					exit function					
  			End Select
  		Next
  		
  		' Finally check for AMPM string and validate time properly
  		If UBound(vFormatTemplate) = 2  Then' AMPM string included
  			If UBound(vInput) = 2 Then
  				sAMPM = vInput(2)
  				If iHour < 1 or iHour > 12 Then
  					IsValidDate = FALSE
  					exit function					
  				End If
  			Else
  				' Hum, we require the input to be in AMPM format, but none was specified
  				IsValidDate = FALSE
  				exit function				
  			End If
  		' Else we have a 24 hour format, probably do nothing here - the check for 0 <= x <= 24 has been made already		
  		End If
  		
  		' Ok, check to see if that day exists on that month/year
  		Dim feb_days
  		' First, is this a leap year?
      If (iYear mod 4) <> 0 Then
  			feb_days = 28
      Elseif (iYear mod 400) = 0 Then
  			feb_days = 29
      Elseif (iYear mod 100) = 0 Then
  			feb_days = 28
      Else
  			feb_days = 29
  		End If
  		' Now do day validation according to month
  		Select Case iMonth
  			Case 4, 6, 9, 11
  				If iDay > 30 Then
  					IsValidDate = FALSE
  					exit function
  				End If
  			Case 2
  				If iDay > feb_days Then
  					IsValidDate = FALSE
  					exit function				
  				End if
  			Case Else
  				' Else we are ok cause we already validated this before
  		End Select
  		
  	END FUNCTION
    
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    ' Function    : CollectionToRowset(collItems, strProperties, strColumns)  '
    ' Description : Return a simulated rowset containing data from the        '
    '             : collection of objects                                     '
    ' Inputs      : collItems -- Collection of objects.                       '
    '             : strProperties -- CSV string with property names to get.   '
    '             : strColumns -- CSV string with names of columsn that       '
    '             :               correspond to the properties.               '
    ' Outputs     : MTMSIX.MTSQLRowsetSimulator object                        '
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    PUBLIC FUNCTION CollectionToRowset(collItems, strProperties, strColumns, arrExtra)
    
      Dim objItem           ' Each item in collection
      Dim arrProperties     ' Array of properties
      Dim arrColumns        ' Array of columns
      Dim objRS             ' Recordset to return
      Dim i                 ' Counter
      Dim intNumExtra       ' Extra columns to add
      Dim intCount
      
      if len(strProperties) > 0 and len(strColumns) > 0 then
      
        arrProperties = split(strProperties, ",")
        arrColumns = split(strColumns, ",")
        
        'Make sure the same number of proeprty names and column names were specified
        if UBound(arrProperties) = UBound(arrColumns) then
          
          'Create our simulator
          Set objRS = server.CreateObject("MTMSIX.MTSQLRowsetSimulator")
          
          if isArray(arrExtra) then
            intNumExtra = UBound(arrExtra) + 1
          else
            intNumExtra = 0
          end if
          
          'Initialize
          Call objRS.Initialize(collItems.count, UBound(arrProperties) + 1 + intNumExtra)
          
          'Set the column names
          for i = 0 to UBound(arrProperties)
            objRS.Name(i) = arrColumns(i)
            
          next
          
          'Add the additional columns
          for i = 0 to intNumExtra - 1
            objRS.Name(UBound(arrProperties) + i + 1) = arrExtra(i)
          next
  
  
          'Move to start
          Call objRS.MoveFirst()
          
          'Iterate through the collections and properties
          intCount = 0
          for each objItem in collItems
            intCount = intCount + 1

            for i = 0 to UBound(arrProperties)
              objRS.Value(i) = eval("objItem." & arrProperties(i))
            next
            
            'Add values
            for i = 0 to intNumExtra - 1
              objRS.Value(UBound(arrProperties) + i + 1) = intCount
            next
            
            Call objRS.MoveNext()
          next
          
          'Set the return value and exit
   '       response.end
          Set CollectionToRowset = objRS
          Exit Function
        end if
      end if
      
      Set CollectionToRowset = nothing
      
    END FUNCTION
    

    '-----------------------------------------------------------------------------
    ' FUNCTION 			: ExecuteSQLQuery
    ' PARAMETERS		: 
    '                 - strFolderInit : relative path to the queries files : queries\audit
    '                 - strSQL : The SQL statment with [XX] for the parameter
    '                 - arrDefines : an array of name, value list : Array("ID",12,"NAME","Fred")
    '                                if you have no parameter pass Array()
    ' DESCRIPTION 	:
    ' RETURNS			  :    
    PUBLIC FUNCTION ExecuteSQLQuery(strFolderInit, strSQL, arrDefines)      
      Set LastRowset = Server.CreateObject("MTSQLRowset.MTSQLRowset.1")
    	LastRowset.Init strFolderInit
      LastRowset.SetQueryString(PreProcess(strSQL,arrDefines))
      LastRowset.Execute
      ExecuteSQLQuery = TRUE
    END FUNCTION
    
    PUBLIC PROPERTY GET LastRowset()
        Set LastRowset = Session("FRAMEWORK_LAST_ROWSET")
    END PROPERTY
    PUBLIC PROPERTY SET LastRowset(v)
        Set Session("FRAMEWORK_LAST_ROWSET") = v
    END PROPERTY

    '-----------------------------------------------------------------------------
    ' FUNCTION 			: ExecuteQueryTag
    ' PARAMETERS		: 
    ' DESCRIPTION 	: This one is not finished because we cannot pass parameter
    ' RETURNS			  :
    PUBLIC FUNCTION ExecuteQueryTag(strFolderInit, strQueryTag, SQLParamArray)
    
      Dim i
      
      Set LastRowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
    	LastRowset.Init strFolderInit
      LastRowset.SetQueryTag(strQueryTag)

      For i = 0 To UBound(SQLParamArray) Step 2
    
          LastRowset.AddParam "%%" & SQLParamArray(i) & "%%", "" & SQLParamArray(i + 1)
      Next
      LastRowset.Execute
      ExecuteQueryTag = TRUE
    END FUNCTION    
    
    PUBLIC FUNCTION GetPricteAbleItemTypeFQN(lngPID)
        GetPricteAbleItemTypeFQN = ProductCatalog.GetPriceableItemType(lngPID).GetProductViewObject().Name    
    END FUNCTION        

    '-----------------------------------------------------------------------------
    ' FUNCTION 			: GetMTCollectionFromCSVID
    ' PARAMETERS		: 
    ' DESCRIPTION 	: Return a MTCollectionEx object from a CSV string containing IDs
    ' RETURNS			  :    
    PUBLIC FUNCTION GetMTCollectionFromCSVID(strIDs)
    
        Dim strID, IDs
       
        Set IDs = CreateObject("MetraTech.MTCollectionEx")
        
        For Each strID in Split(strIDs,",")
        
            IDs.Add Clng(strID)
        Next
        Set GetMTCollectionFromCSVID = IDs
    END FUNCTION
    
    '-----------------------------------------------------------------------------
    ' FUNCTION 			: GetCSVIdsFromMTCollection
    ' PARAMETERS		: 
    ' DESCRIPTION 	: Return a CSV string from a MTCollection containing IDs or anything
    ' RETURNS			  :        
    PUBLIC FUNCTION GetCSVIdsFromMTCollection(objIDs)
    
        Dim objID, strCSV
        
        For Each objID In objIDs
        
            strCSV = strCSV & objID & ","
        Next
        strCSV = Mid(strCSV,1,Len(strCSV)-1)
        GetCSVIdsFromMTCollection = strCSV
    END FUNCTION    
    
    PUBLIC FUNCTION Include(strFilter)
    
        Include = FALSE
        
        Dim Entry, strIncludeFileName, strClassID, booIncludeIt
        
        For Each Entry In Dictionary
        
            booIncludeIt = FALSE
            
            If InStr(UCase(Entry.Name),VBSCRIPT_CLASS_PREFIX)=1 Then
            
                strClassID = Mid(Entry.Name,Len(VBSCRIPT_CLASS_PREFIX)+1)
                If strFilter="*" Then
                    booIncludeIt = TRUE
                Else
                    Response.Write "FrameWork.Include ""*"" Only supported": Response.End                                            
                End If
                
                If booIncludeIt Then
                    
                    strIncludeFileName = Dictionary.Item("APP_PATH").Value & "\" & Entry.Value
                    
                    If Not IncludeFile(strIncludeFileName) Then
                    
                        Response.Write Replace(FRAMEWORK_ERROR_1000,"[FILE]",strIncludeFileName)
                        Response.End
                    End If                    
                  End If
            End If
        Next
        Include = TRUE
    END FUNCTION
        
    PRIVATE FUNCTION IncludeFile(strIncludeFileName)
        Dim oFS, oFile
        
        IncludeFile = FALSE
        
        On Error Resume Next
        Set oFS = CreateObject("Scripting.FileSystemObject")
        If Err.Number Then
            Exit Function
        End If
                
        Set oFile= oFS.OpenTextFile(strIncludeFileName)
        If Err.Number Then
            Exit Function
        End If
                
        Dim strSource
        strSource = oFile.ReadAll()
        
        strSource = Replace(strSource, "<"+CHR(37),"") '  Remove the asp tag < % and % >
        strSource = Replace(strSource, CHR(37)+">","")
        
        ExecuteGlobal strSource
        
        If Err.Number Then
            Exit Function
        End If
                
        oFile.Close
        
        IncludeFile = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION GetLanguageIntegerCode(strLanguageCode)
        
        Select Case UCase(strLanguageCode)
            Case "US":GetLanguageIntegerCode=840                
            Case "CN":GetLanguageIntegerCode=156
            Case "DE":GetLanguageIntegerCode=276
            Case "FR":GetLanguageIntegerCode=0
        End Select
    END FUNCTION
    
    PUBLIC FUNCTION GetLocalizedString(strLanguage,strFQN)
        Dim strDisplayName
        strDisplayName = Empty
        Service.Tools.GetLocalizedString strLanguage,strFQN,strDisplayName
        GetLocalizedString = strDisplayName
    END FUNCTION
    
    PUBLIC FUNCTION GetLocalizedProperty(strLanguage,strFQN1, strFQN2, strPropertyName)
        Dim strDisplayName
        strDisplayName = Empty
        Service.Tools.GetLocalizedString strLanguage,strFQN1 & "/"  & strPropertyName,strDisplayName
        If IsEmpty(strDisplayName) Then
            Service.Tools.GetLocalizedString strLanguage,strFQN2 & "/"  & strPropertyName,strDisplayName
        End If
        GetLocalizedProperty = strDisplayName
    END FUNCTION    
    
    PUBLIC FUNCTION GetLanguageDisplayInformation(iLanguageId)

      dim objLanguageList
      set objLanguageList = Server.CreateObject("MetraTech.Localization.LanguageList")
  
      Dim objHtmlParser 
      Set objHtmlParser = mdm_CreateObject("MTMSIX.CHtmlParser")    

      GetLanguageDisplayInformation = objHtmlParser.GetLanguageDisplayInformation(objLanguageList.GetLanguageCode(iLanguageId), FrameWork.Dictionary)

    END FUNCTION

    PUBLIC FUNCTION GetLanguageCodeForCurrentUser()
    
      dim objLanguageList
      set objLanguageList = Server.CreateObject("MetraTech.Localization.LanguageList")
      
      GetLanguageCodeForCurrentUser = objLanguageList.GetLanguageCode(Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME").LanguageId)
    END FUNCTION
    
    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION    : GetDescriptionFromID
    ' PARAMETERS  : ID, language code
    ' DESCRIPTION : returns localized description
    ' RETURNS     : localized description
    PUBLIC FUNCTION GetDescriptionFromID(lngID, strLanguageCode)
      If IsEmpty(Application("COMLocaleTranslator")) Then
        Set Application("COMLocaleTranslator") = server.CreateObject("MetraTech.COMLocaleTranslator.1")
      End If  
        Application("COMLocaleTranslator").Init strLanguageCode         
        Application("COMLocaleTranslator").LanguageCode = strLanguageCode
      GetDescriptionFromID = Application("COMLocaleTranslator").GetDescription(lngID)
    END FUNCTION
    
    PUBLIC FUNCTION Format(varData, strFormat)
        Format = Service.Tools.Format(varData, strFormat)
    END FUNCTION
    
    PUBLIC FUNCTION FormatAmount(varData)
        FormatAmount = Service.Tools.Format(varData, FrameWork.Dictionary().Item("AMOUNT_FORMAT").Value)
    END FUNCTION    

END CLASS		
	

CLASS CFrameWorkError

    Public Number
    Public Description
    Public Source
    Public LocalizedDescription
    
    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION    :
    ' PARAMETERS  :
    ' DESCRIPTION   :
    ' RETURNS     :
    PRIVATE FUNCTION Save() ' As Boolean
    
        Number        				= Err.Number
        Description   				= Err.Description
        Source        				= Err.Source        
        LocalizedDescription 	= Description        
        Save          				= TRUE
    END FUNCTION

    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION    :
    ' PARAMETERS  :
    ' DESCRIPTION :
    ' RETURNS     :
    PRIVATE FUNCTION LocalizedString() ' As String
    
        LocalizedString = "" & Err.Number & " Description:" & LocalizedDescription & " Source:" & Source
    END FUNCTION


END CLASS


PUBLIC FUNCTION CDec(varValue) ' As Variant Decimal
	Dim o
  Dim tmpVarValue

  ' CORE-4729:
  ' This VBScript CDec() function is aware of Session.LCID.
  ' However, MSIXTools is not aware of Session.LCID and requires
  ' that the decimal separator be a period.  Therefore, we must
  ' convert the decimal separator before calling MSIXTools.

  ' First remove any thousand separators (in case they are periods).
  ' Then change the decimal separator to a period.
  tmpVarValue = Replace(varValue, GetThousandSeparator(), "")
  tmpVarValue = Replace(tmpVarValue, GetDecimalSeparator(), ".")

	set o = CreateObject("MTMSIX.MSIXTools")
	CDec = o.CDecimal(tmpVarValue)
END FUNCTION

%>
