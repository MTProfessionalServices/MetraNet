<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998-2008 by MetraTech Corporation
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
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/mamLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/LogInLib.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%
'<!-- #INCLUDE FILE="../../auth.asp" -->

Form.RouteTo = FrameWork.Dictionary.Item("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    ' Add the EMail Notification on the fly
    Service.Properties.Add "UserName"           , "String" , 32 , True,  Empty
    Service.Properties.Add "OldPassWord"        , "String" , 32 , True,  Empty 
    Service.Properties.Add "NewPassWord"        , "String" , 32 , True,  Empty 
    Service.Properties.Add "ConfirmNewPassWord" , "String" , 32 , True,  Empty 
    Service.Properties.Add "NameSpace"          , "String" , 40 , False,  Empty 
    
    Service("UserName").Caption               = FrameWork.Dictionary.Item("TEXT_CHANGE_PASSWORD_LOGIN")
    Service("OldPassWord").Caption            = FrameWork.Dictionary.Item("TEXT_CHANGE_PASSWORD_OLD_PASSWORD")
    Service("NewPassWord").Caption            = FrameWork.Dictionary.Item("TEXT_CHANGE_PASSWORD_NEW_PASSWORD")
    Service("ConfirmNewPassWord").Caption     = FrameWork.Dictionary.Item("TEXT_CHANGE_PASSWORD_CONFIRM_PASSWORD")
    Service("NameSpace").Caption              = ""
    
    Service("UserName")     = FrameWork.Login
    Service("NameSpace")    = FrameWork.NameSpace
    
    ' Should we show the password expiring soon message?
    If Session("IsPasswordExpiringSoon") = TRUE Then
        FrameWork.Dictionary.Add "mdmIsPasswordExpiringSoon", TRUE
        
        dim days, passwordManager
        set passwordManager = Server.CreateObject("MetraTech.Security.Auth")
        passwordManager.Initialize FrameWork.Login, FrameWork.NameSpace
        days = passwordManager.DaysUntilPasswordExpires()
        dim str
        str = Replace(FrameWork.Dictionary.Item("TEXT_PASSWORD_EXPIRING"), "{0}", days)
        FrameWork.Dictionary.Add "TEXT_PASSWORD_EXPIRING",  str
        
        ' Reset password expiring soon flag so we don't pester the user.
        Session("IsPasswordExpiringSoon") = FALSE
    Else
        FrameWork.Dictionary.Add "mdmIsPasswordExpiringSoon", FALSE
    End If
    
    Form_Initialize = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: OK_Click
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

  OK_Click = FALSE
    
	If Service("NewPassWord") <> Service("ConfirmNewPassWord") Then
    EventArg.Error.Description  = FrameWork.Dictionary.Item("TEXT_CHANGE_PASSWORD_ERROR_OLD_PASSWORD_DOES_NOT_MATCH")
    Exit Function
	End If

 ' Change Password 
  Dim result, passwordManager, objSessionContext
  set passwordManager = Server.CreateObject("MetraTech.Security.Auth")
  passwordManager.Initialize FrameWork.Login, FrameWork.NameSpace
  result = passwordManager.ChangePassword(Service("OldPassWord"), Service("NewPassWord"), FrameWork.SessionContext)

  if not result then
    EventArg.Error.Description  = FrameWork.Dictionary.Item("TEXT_CHANGE_PASSWORD_ERROR_OLD_PASSWORD_DOES_NOT_MATCH")
    Exit Function
  end if
    
  Form.RouteTo = mdm_MsgBoxOk(FrameWork.Dictionary.Item("TEXT_CHANGE_PASSWORD_TITLE"), FrameWork.Dictionary.Item("TEXT_CHANGE_PASSWORD_UPDATE_SUCCEED"), Form.RouteTo, empty) ' As String
    
  OK_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: CANCEL_Click
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION CANCEL_Click(EventArg) ' As Boolean

    CANCEL_Click = TRUE
END FUNCTION

%>
