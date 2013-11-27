<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' //==========================================================================
' //
' // Copyright 2000-2002 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //
' //=========================================================================='

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' AccountTemplate.EditStart.asp                                             '
' Starting page for editing account templates.  If a template does not      '
' not exist for the folder, the user is prompted whether to create a new,   '
' blank template, or to create a new template that is a copy of the         '
' closest ancestor's template.                                              '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../default/lib/CAccountTemplateHelper.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Call mdm_Main()

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Form_Initialize(EventArg)                                   '
' Description : Perform form initialization                                 '
' Inputs      :                                                             '
' Outputs     : boolean                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Form_Initialize(Event_Arg)
  Form_Initialize = false

  Session("MAM_CURRENT_ACCOUNT_TYPE") = mdm_UIValue("AccountType")
  Form.RouteTo = mam_GetDictionaryDefault("EDIT_ACCOUNT_TEMPLATE_" & mdm_UIValue("AccountType"), mam_GetDictionary("EDIT_ACCOUNT_TEMPLATE_GENERIC")) & "?mdmReload=true&AccountType=" & Session("MAM_CURRENT_ACCOUNT_TYPE")
  Session("MAM_TEMPLATE_START_DIALOG") = mam_GetDictionaryDefault("EDIT_ACCOUNT_TEMPLATE_" & mdm_UIValue("AccountType"), mam_GetDictionary("EDIT_ACCOUNT_TEMPLATE_GENERIC"))
  
  'Initialize the instance of the helper
  Call AccountTemplateHelper.Initialize(MAM().Subscriber("_ACCOUNTID").Value, Session("MAM_CURRENT_ACCOUNT_TYPE"))

  If AccountTemplateHelper.TemplateExists Then
    Call RedirectToNextDialog()
  Else
    Call WriteUserPrompt()
  End If

  Form_Initialize = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : RedirectToNextDialog()                                      '
' Description : Redirect the page to the next dialog.                       '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function RedirectToNextDialog()
  Session("TEMPLATE_ACTION") = "EDIT_TEMPLATE"
  Call mdm_TerminateDialogAndExecuteDialog(Form.RouteTo)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteUserPrompt()                                           '
' Description : Provide the necessary data for the MDM to render the prompt '
'             : asking the user if he/she wants to use the template of an   '
'             : ancestor for the basis of a new template.                   '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function WriteUserPrompt()
  Dim strAncestor
  
  Call Service.Properties.Add("ANCESTOR_NAME"         , "String", 256, false, Empty)
  Call Service.Properties.Add("USE_ANCESTOR_TEMPLATE" , "String", 256, false, Empty)
  
  if AccountTemplateHelper.NoAncestorWithTemplate then
    Service.Properties("USE_ANCESTOR_TEMPLATE") = mam_GetDictionary("TEXT_CREATE_NEW_TEMPLATE")
  else
    strAncestor = AccountTemplateHelper.GetAncestorName()
    Service.Properties("USE_ANCESTOR_TEMPLATE") = mam_GetDictionary("TEXT_USE_ANCESTOR_TEMPLATE")
    Service.Properties("ANCESTOR_NAME") = strAncestor
  end if
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : OK_Click(EventArg)                                          '
' Description : Handle case where the user wants to copy the template from  '
'             : the parent.                                                 '
' Inputs      :                                                             '
' Outputs     : boolean                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function OK_Click(EventArg)
  session("TEMPLATE_ACTION") = "COPY_ANCESTOR"
  OK_Click = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Cancel_Click(EventArg)                                      '
' Description : Handle case where the user does not want to use an          '
'             : ancestor template.                                          '
' Inputs      :                                                             '
' Outputs     : boolean                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Cancel_Click(EventArg)
  
  'Check if the user is replying to a question of whether to create a new 
  'template, or the question of whether to copy a template from an 
  'ancestor or not.
  
  'If there is an ancestor template, then cancel means don't copy
  if AccountTemplateHelper.NoAncestorWithTemplate then
    Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
  else
    session("TEMPLATE_ACTION") = "CLEAR_TEMPLATE"
    Cancel_Click = true
  end if

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>