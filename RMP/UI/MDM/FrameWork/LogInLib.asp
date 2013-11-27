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
' NAME		        : MetraTech - Log In Lib - VBScript Library
' VERSION	        : 1.0
' CREATION_DATE   : 10/25/2000
' AUTHOR	        : F.Torres.
' DESCRIPTION	    : A Finally Resusable VBScript library to log in into the metra tech system
' ----------------------------------------------------------------------------------------------------------------------------------------

PUBLIC  CONST LOGIN_LIB_KIOSK_AUTH_SESSION_NAME = "objKioskAuth"
PUBLIC  CONST COMKioskAuth                      = "COMKioskAuth.COMKioskAuth.1"
PUBLIC  CONST COMCredentials                    = "ComCredentials.ComCredentials.1"

PRIVATE CONST LOGIN_LIB_LOGIN_ERROR     = "An unrecoverable error occurred. The error is [ERROR]. Please retry your request and if the error persists, contact the system administrator."





' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : 
' PARAMETERS	  :
' DESCRIPTION 	: 
' RETURNS		    :
PUBLIC FUNCTION LoginLib_LogOn(strLogOn, strPassWord, strNameSpace, strTicket, strErrorMessage)

  Dim credObj
  
  loginlib_Initialize
	
	Set credObj = CreateObject(COMCredentials) ' Create a credentials object object to authenticate the user
 
	credObj.loginID 		  = strLogon
	credObj.pwd 			    = strPassword
	credObj.name_space 		= strNameSpace
  credObj.ticket 			  = CStr(strTicket)

  On Error Resume Next
	LoginLib_LogOn = Application(LOGIN_LIB_KIOSK_AUTH_SESSION_NAME).IsAuthentic(credObj)
  
  If(err.Number)Then
  
      strErrorMessage = err.number & " " & err.description & " " & err.source
      strErrorMessage = Replace(LOGIN_LIB_LOGIN_ERROR,"[ERROR]",strErrorMessage)
      LoginLib_LogOn  = FALSE
  Else
      Session(LOGIN_LIB_LOGIN)      = strLogOn
      Session(LOGIN_LIB_NAMESPACE)  = strNameSpace
      Session(LOGIN_LIB_ACCOUNTID)  = LoginLib_GetAccountId(strLogOn, strNameSpace)
  End If
  'On Error Goto 0
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : LoginLib_GetAccountId
' PARAMETERS	  :
' DESCRIPTION 	: 
' RETURNS		    :
PUBLIC FUNCTION LoginLib_GetAccountId(strLogOn, strNameSpace)

            dim objAccount
            set objAccount = mdm_CreateObject("COMKiosk.COMAccount.1")
            objAccount.Initialize
            objAccount.GetAccountInfo strLogOn, strNameSpace
            LoginLib_GetAccountId = objAccount.AccountId

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : LoginLib_GetLoginInfo 
' PARAMETERS	  :
' DESCRIPTION 	: 
' RETURNS		    :
PUBLIC FUNCTION LoginLib_GetLoginInfo(strLogOn, strNameSpace)

    strLogOn              = Session(LOGIN_LIB_LOGIN)
    strNameSpace          = Session(LOGIN_LIB_NAMESPACE)
    LoginLib_GetLoginInfo = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : loginlib_Initialize
' PARAMETERS	  :
' DESCRIPTION 	:  Create and store at the application level the object COMKioskAuth.COMKioskAuth.1
' RETURNS		    :
PRIVATE FUNCTION loginlib_Initialize()

    If(Not IsObject(Application(LOGIN_LIB_KIOSK_AUTH_SESSION_NAME)))Then
  
    	  Set Application(LOGIN_LIB_KIOSK_AUTH_SESSION_NAME) = CreateObject(COMKioskAuth)
        Application(LOGIN_LIB_KIOSK_AUTH_SESSION_NAME).Initialize
    End If
    loginlib_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : 
' PARAMETERS	  :
' DESCRIPTION 	: 
' RETURNS		    :
PUBLIC FUNCTION LoginLib_LogOut()

    LoginLib_GarbageCollector
    
    session.abandon
    
    If(Len(Application("startPage")))Then
    
        response.write "<script>"
        response.write "	top.location =  '" & Application("startPage") & "';"
        response.write "</script>"
    End If    
    response.end    
    LoginLib_LogOut = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : GarbageCollector
' PARAMETERS	  :
' DESCRIPTION 	: Free Objects instance store in the session!
' RETURNS		    :
PRIVATE FUNCTION LoginLib_GarbageCollector() ' As Boolean

    Dim itm
   
    For Each itm in Session.Contents
    
        If(IsObject(Session(itm)))Then
        
            Set Session(itm) = Nothing
        End If
    Next
    LoginLib_GarbageCollector = TRUE
END FUNCTION





' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : LoginLib_EncrypteString
' PARAMETERS	  :
' DESCRIPTION 	:
' RETURNS		    :
PRIVATE FUNCTION LoginLib_EncrypteString(strString, strEncryptedString) ' As Boolean

    Dim COMKioskObject
    
    loginlib_Initialize
    
    Set COMKioskObject = Application(LOGIN_LIB_KIOSK_AUTH_SESSION_NAME)
    
    On Error Resume Next
    strEncryptedString  = COMKioskObject.HashString(CStr(strString))
    LoginLib_EncrypteString = CBool(Err.Number=0)
    On Error Goto 0
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : CheckAndWriteError
' PARAMETERS	  :
' DESCRIPTION 	: Check and print the error!
' RETURNS		    :
PUBLIC FUNCTION loginlib_CheckAndWriteError() ' As Boolean
	if err then

  	response.write("<FONT FACE=""ARIAL"" SIZE=""2"">")
	  response.write("<B>An unrecoverable error occurred. The error is:</B><BR>")

  	response.write("<UL>")
	  response.write("<LI>Error Number: " &  Hex(err.number)  & "<BR>")
  	response.write("<LI>Description: " &  err.description  & "<BR>")
	  response.write("<LI>Source: " &  err.source  & "<BR>")
  	response.write("</UL>")

	  response.write("Please retry your request and if the error persists, contact the system administrator.")

  	err.clear
    CheckAndWriteError = FALSE
	  response.end
      
  Else
      CheckAndWriteError = TRUE    
	end if
End FUNCTION
%>