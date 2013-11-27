<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' //==========================================================================
' //
' // Copyright 2000-2005 by MetraTech Corporation
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
Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Call mdm_Main()

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Form_Initialize(EventArg)                                   '
' Description :                                                             '
' Inputs      :                                                             '
' Outputs     : boolean                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Form_Initialize(Event_Arg)
  Form_Initialize = false

  ' Get the right summary dialog for the Account Type and redirect
  If IsValidObject(Session("SubscriberYAAC")) Then
    Form.RouteTo = mam_GetDictionaryDefault(Session("SubscriberYAAC").AccountType & "_SUMMARY_DIALOG", mam_GetDictionary("GENERIC_SUMMARY_DIALOG")) & "?AccountType=" & Session("SubscriberYAAC").AccountType & "&MDMReload=TRUE"
  End If
 
  Call mdm_TerminateDialogAndExecuteDialog(Form.RouteTo)

  Form_Initialize = true
End Function
%>