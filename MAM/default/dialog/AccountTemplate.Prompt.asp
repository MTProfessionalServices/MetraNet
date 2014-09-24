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
' AccountTemplate.Edit.asp                                                  '
' Handle editing of the account templates associated with folders in the    '
' hierarchy.                                                                '
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

Const ASP_CALL_TEMPLATE = "[ASP]?WorkFlowName=TemplateWorkflowMove&Mode=Move&AccountID=[ACCOUNTID]&AncestorAccountID=[ANCESTORACCOUNTID]&MoveStartDate=[MOVESTARTDATE]&Types=[TYPES]"

'Send payer
Call mdm_Main()

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Form_Initialize()                                           '
' Parameters  :                                                             '
' Description :                                                             '
' Returns     : Returns true if ok, else false                              '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Form_Initialize(EventArg)
  Dim objAccountCol
  Call response.redirect(mam_ConfirmDialogEncodeAllURL(mam_getDictionary("TEXT_MOVE_ACCOUNTS"), mam_getDictionary("TEXT_ACCOUNTS_MOVED_SUCCESSFULLY"), mam_getDictionary("WELCOME_DIALOG")))
  
  Form_Initialize = false
  
  Set objAccountCol = session("BATCH_TEMPLATE_COLLECTION")
  
  ' if ancestor is root - nothing to do. Templates can not be located on the root
  if (request.QueryString("AncestorAccountID") = 1) then
    Call response.redirect(mam_ConfirmDialogEncodeAllURL(mam_getDictionary("TEXT_MOVE_ACCOUNTS"), mam_getDictionary("TEXT_ACCOUNTS_MOVED_SUCCESSFULLY"), mam_getDictionary("WELCOME_DIALOG")))
  end if

  ' Get string (strMessageTypes) containing a list of types being moved,
  ' and if there is more than one type set bMultipleTypes to true
  Dim id, objYAAC, node, col, accType, accTypeFirst, ancestorName, bFirst, strMessageTypes, bMultipleTypes
  bMultipleTypes = FALSE
  bFirst = TRUE
  Set col = Server.CreateObject(MT_COLLECTION_PROG_ID)

  ' Get the name of the ancestor account
  Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(Request.QueryString("AncestorAccountID")), mam_ConvertToSysDate(mam_GetHierarchyTime()))
  ancestorName = objYAAC.AccountName

  For Each id in objAccountCol
    Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(id), mam_ConvertToSysDate(mam_GetHierarchyTime()))
    
    accType = objYAAC.AccountType
    If bFirst Then
      accTypeFirst = accType
      strMessageTypes = accType
      Session("MAM_CURRENT_ACCOUNT_TYPE") = accType
      bFirst = FALSE
    End If

    If accType <> accTypeFirst Then
      ' We have more than one account type, so create message
      If instr(strMessageTypes, accType) = 0 Then
        strMessageTypes = strMessageTypes & ", " & accType
      End If  
      bMultipleTypes = TRUE
    End If
  Next

  'If there is no template, and we are dealing with a single type just redirect to a confirm dialog
  If Not bMultipleTypes Then
      ' Intialize the template helper
    Call AccountTemplateHelper.Initialize(Request.QueryString("AncestorAccountID"), Session("MAM_CURRENT_ACCOUNT_TYPE"))
    If AccountTemplateHelper.NoAncestorWithTemplate Then
      Call response.redirect(mam_ConfirmDialogEncodeAllURL(mam_getDictionary("TEXT_MOVE_ACCOUNTS"), mam_getDictionary("TEXT_ACCOUNTS_MOVED_SUCCESSFULLY"), mam_getDictionary("WELCOME_DIALOG")))
    End If
  End If
   
	Form.RouteTo = PreProcess(ASP_CALL_TEMPLATE, _
                              Array("ASP"               , mam_GetDictionary("ACCOUNT_TEMPLATE_APPLY_TO_MULTI_MOVED_ACCOUNT_DIALOG"), _
                                    "ACCOUNTID"         , CLng(objAccountCol.item(1)), _
                                    "ANCESTORACCOUNTID"	, request.QueryString("AncestorAccountID"), _
                                    "TYPES"	            , Server.URLEncode(strMessageTypes), _
                                    "MOVESTARTDATE"     , request.QueryString("MoveStartDate")))  
   
  'Add the prompt
  Call Service.Properties.Add("ACCOUNT_TEMPLATE_APPLY_PROMPT", "String", 0, false, empty)

  Service.Properties("ACCOUNT_TEMPLATE_APPLY_PROMPT") = "You moved account(s) having the following different account types (" &strMessageTypes & ").<br><br> "
  Service.Properties("ACCOUNT_TEMPLATE_APPLY_PROMPT") = Service.Properties("ACCOUNT_TEMPLATE_APPLY_PROMPT") & replace(mam_GetDictionary("TEXT_ACCOUNT_TEMPLATE_APPLY_PROMPT"), "[FOLDER_NAME]", ancestorName)
  Call mdm_GetDictionary.Add("bCloseOnly", false)
   
  Form_Initialize = true  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Cancel_Click(EventArg)                                      '
' Description : Discard user changes to the account template.               '
' Parameters  :                                                             '
' Returns     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Cancel_Click(EventArg)
  Form.RouteTo = mam_getDictionary("WELCOME_DIALOG")
  Cancel_Click = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : OK_Click(EventArg)                                          '
' Description : Save user changes to the account template.                  '
' Parameters  :                                                             '
' Returns     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function OK_Click(EventArg)
  OK_Click = true
End Function
%>

