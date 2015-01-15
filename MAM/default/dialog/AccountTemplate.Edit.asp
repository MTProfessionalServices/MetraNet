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

'MDM Stuff
Form.ServiceMsixdefFileName = mam_GetServiceDefForOperationAndType("UPDATE", Session("MAM_CURRENT_ACCOUNT_TYPE"))
'Form.RouteTo                = mam_GetDictionary("EDIT_ACCOUNT_TEMPLATE")

Call mdm_Main()

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Form_Initialize()                                           '
' Parameters  :                                                             '
' Description :                                                             '
' Returns     : Returns true if ok, else false                              '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Form_Initialize(EventArg)
  Form_Initialize = false
	
  Dim objDyn
  Set objDyn = mdm_CreateObject(CVariables)
  objDyn.Add "0", "0", , , "[TEXT_CURRENT_NODE]"
  objDyn.Add "1", "1", , , "[TEXT_DIRECT_DESCENDANTS]"
  objDyn.Add "2", "2", , , "[TEXT_ALL_DESCENDANTS]"

  Service.Properties.Add "MTWILDCARD", "String", 0, TRUE, ""
  Service.Properties("MTWILDCARD").AddValidListOfValues objDyn	
  
  'Handle tax exempt as string, so it can have no value
  Dim strCaption
  strCaption = Service("TAXEXEMPT").Caption

  Call Service.Properties.Remove("TAXEXEMPT")
  Call Service.Properties.Add("TAXEXEMPT", "STRING", 255, false, Empty)

  Call Service("TAXEXEMPT").SetPropertyType ("ENUM",  "Global",  "BooleanYN")

  Service("TAXEXEMPT").Caption = strCaption
  
  
  Select Case UCase(session("TEMPLATE_ACTION"))
    Case "COPY_ANCESTOR"
      Call LoadTemplate(false)
  
    Case "CLEAR_TEMPLATE"
      Call LoadTemplate(true)

    Case "EDIT_TEMPLATE"
      Call LoadTemplate(false)
      
  End Select     

  'Clear the action
  session("TEMPLATE_ACTION") = ""

  'Check if current node is the same type or not
  If UCase(MAM().Subscriber("AccountType")) = UCase(Session("MAM_CURRENT_ACCOUNT_TYPE")) Then
    Call mdm_GetDictionary.Add("bCurrentNodeExists", true)
  Else
    Call mdm_GetDictionary.Add("bCurrentNodeExists", false)
  End If

  'If CBool(mam_GetDictionary("INCLUDE_FOLDERS_IN_BATCH_OPERATIONS")) Then
  '	mdm_GetDictionary().add "TEXT_INCLUDE_FOLDERS", "&nbsp;" & mam_GetDictionary("TEXT_INCLUDING_FOLDERS")  
  'Else
 	' mdm_GetDictionary().add "TEXT_INCLUDE_FOLDERS", "&nbsp;" & mam_GetDictionary("TEXT_EXCLUDING_FOLDERS")
  'End If
  
  Service("usagecycletype").Required = false
    
  Form_Initialize = true  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub         : LoadTemplate(bClear)                                        '
' Description : Load the template, create service properties, etc.          '
' Inputs      : bClear -- Indicates if the template should be cleared.      '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub LoadTemplate(bClear)
  'Service("UsageCycleType").Value = Service("UsageCycleType").EnumType.Entries(mam_GetDictionary("ADD_ACCOUNT_DEFAULT_USAGECYCLETYPE")).Value
  
  If AccountTemplateHelper.TemplateExists Then
    Call mdm_GetDictionary.Add("bTemplateExists", true)
  Else
    Call mdm_GetDictionary.Add("bTemplateExists", false)
  End If
  
  Call AddProperties()
  Set AccountTemplateHelper.MSIXHandler = Service
  Call AccountTemplateHelper.LoadTemplate()
   
  if bClear then
    Call AccountTemplateHelper.ClearTemplate()
  end if
  
  Call InitProperties()
  Call LoadSubscriptionsGrid()
  Call CheckDefaultPolicy()

  ' For account types we need to save the template right away
  Call AccountTemplateHelper.SaveTemplate()  

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub         : AddProperties()                                             '
' Description : Add properties that are not part of the account creation    '
'             : service definition.                                         '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub AddProperties()
  'Add some properties
  Call Service.Properties.Add("AccountTemplateName"         , "String"  , 255 , False, Empty)
	Call Service.Properties.Add("AccountTemplateDescription"  , "String"  , 255 , False, Empty)
  Call Service.Properties.Add("ApplyDefaultSecurityPolicy"  , "Boolean" , 0   , False, Empty)
  Call Service.Properties.Add("BiWeeklyLabelInfo"           , "String"  , 255 , False, Empty)
  Call Service.Properties.Add("SubscriptionsMessage"        , "String"  , 256 , false, Empty)
  Call Service.Properties.Add("SecurityPolicyMessage"       , "String"  , 256 , false, Empty)  
  Call Service.Properties.Add("Payer"                       , "String"  , 255 , false, Empty)
  
  Service.Properties("SecurityPolicyMessage").Caption = ""
  
  'Remove some properties that we don't want to appear
	Call Service.Properties.Remove("_AccountID")
	Call Service.Properties.Remove("Operation")
	Call Service.Properties.Remove("ActionType")
	Call Service.Properties.Remove("ContactType")
	Call Service.Properties.Remove("AccountStartDate")
	Call Service.Properties.Remove("AccountEndDate")
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub         : InitProperties()                                            '
' Description : Init service and product properties for the dialog.         '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub InitProperties()
  Dim objMSIXProperty

  'Remove required flags
  for each objMSIXProperty in Service.Properties
    objMSIXProperty.Required = false
    objMSIXProperty.EnumTypeSupportEmpty = true
  next  
  
  'Set the values
  Service.Properties("AccountTemplateName").Value          = AccountTemplateHelper.Name
	Service.Properties("AccountTemplateDescription").Value   = AccountTemplateHelper.Description
	Service.Properties("ApplyDefaultSecurityPolicy").Value   = AccountTemplateHelper.ApplyDefaultSecurityPolicy
  Service.Properties("Payer").Value                        = mam_GetFieldIDFromAccountID(Service.Properties("PayerID").value)
  
  'Set captions	
	Service.Properties("AccountTemplateName").Caption 			 = mam_GetDictionary("TEXT_TEMPLATE_NAME")
	Service.Properties("AccountTemplateDescription").Caption = mam_GetDictionary("TEXT_TEMPLATE_DESCRIPTION")
	Service.Properties("ApplyDefaultSecurityPolicy").Caption = mam_GetDictionary("TEXT_TEMPLATE_APPLY_SECURITY")
  
  'Avoid localization error in log
  Service("BiWeeklyLabelInfo").Caption = "dummy"

  ' Billing Cycle Data Init
	Call mam_Account_SetBiWeeklyLabelInfo()
	Call mam_Account_SetGoodEnumTypeValueToUsageCycleType()
  Call mam_Account_SetBillingCycleEnumType()
  Call mam_Account_ChangeCurrencyTypeToEnumType()
  
  'Add data for the payer
  Call ProductView.Properties.Add("Payer", "String", 255, false, "", eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)
  ProductView.Properties("Payer").Value = mam_GetFieldIDFromAccountID(ProductView.Properties("PayerID").value)
  ProductView.Properties("Payer").Caption = mam_GetDictionary("TEXT_PAYER")

	Service.Properties("AccountType") = Session("MAM_CURRENT_ACCOUNT_TYPE")
	
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadSubscriptionsGrid()                                     '
' Description : Load information for the subscriptions grid.                '
' Parameters  :                                                             '
' Returns     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function LoadSubscriptionsGrid()
  LoadSubscriptionsGrid = false

  'Check if the grid already exists
  if not Form.Grids.Exist("SubscriptionsGrid") then
    Call Form.Grids.Add("SubscriptionsGrid")
  end if
  
  'Get the subscriptions rowset 
  Set Form.Grids("SubscriptionsGrid").Rowset = AccountTemplateHelper.GetSubscriptionsAsRowset()
  
  'If there are no subscriptions, display a message and hide the grid headers
  if Form.Grids("SubscriptionsGrid").Rowset.RecordCount = 0 then
    Service.Properties("SubscriptionsMessage") = mam_GetDictionary("TEXT_NO_TEMPLATE_SUBSCRIPTIONS")
    Form.Grids("SubscriptionsGrid").Visible = false
  
  'Otherwise, display the grid
  else
    Service.Properties("SubscriptionsMessage") = ""  

    Call Form.Grids("SubscriptionsGrid").Properties.ClearSelection()

    'VT_START & VT_END also part of rowset
          
    'Set the order
    Form.Grids("SubscriptionsGrid").Properties("NM_DISPLAY_NAME").Selected 	= 1
		Form.Grids("SubscriptionsGrid").Properties("B_GROUP").Selected 					= 2
		Form.Grids("SubscriptionsGrid").Properties("NM_GROUPSUBNAME").Selected 	= 3
		Form.Grids("SubscriptionsGrid").Properties("ID_PO").Selected 					  = 4

    'Set the captions
    Form.Grids("SubscriptionsGrid").Properties("ID_PO").Caption							= " "
		Form.Grids("SubscriptionsGrid").Properties("B_GROUP").Caption 					= mam_GetDictionary("TEXT_SUBSCRIPTION_TEMPLATE_GROUP")
		Form.Grids("SubscriptionsGrid").Properties("NM_DISPLAY_NAME").Caption   = mam_GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING")
		Form.Grids("SubscriptionsGrid").Properties("NM_GROUPSUBNAME").Caption   = mam_GetDictionary("TEXT_SUBSCRIPTION_TEMPLATE_GROUP_SUB_NAME")
				
		Form.Grids("SubscriptionsGrid").Properties("NM_DISPLAY_NAME").Sorted    = MTSORT_ORDER_ASCENDING		 
		Form.Grids("SubscriptionsGrid").Width                                   = "100%"
		Form.Grids("SubscriptionsGrid").Visible                                 = true
  end if
  
  LoadSubscriptionsGrid = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : CheckDefaultPolicy()                                        '
' Description : Check to see if any roles have been setup for the default   '
'             : security policy.  If not, display a warning message.        '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function CheckDefaultPolicy()
  Dim objAuthAccount
  Dim objPolicy
  
  On error resume next
	Set	objAuthAccount  = FrameWork.Policy.GetAccountByID(FrameWork.SessionContext, CLng(AccountTemplateHelper.AccountTemplate.AccountID), mam_ConvertToSysDate(mam_GetHierarchyTime()))
  If err.number <> 0 then
    Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"),  mam_GetDictionary("SUBSCRIBER_FOUND"))
  End If
  On error goto 0   
  Set objPolicy       =  objAuthAccount.GetDefaultPolicy(FrameWork.SessionContext)
  
  'If there are no role, get the message
  if objPolicy.GetRolesAsRowset().RecordCount > 0 then
    Service.Properties("ApplyDefaultSecurityPolicy").Enabled = true
    Service.Properties("SecurityPolicyMessage").Value = ""
  else
    Service.Properties("ApplyDefaultSecurityPolicy").Enabled = false
    Service.Properties("ApplyDefaultSecurityPolicy").Value = false
    Service.Properties("SecurityPolicyMessage") = "<table><tr><td><image src=""/mam/default/localized/en-us/images/warning.gif"" width=""16"" height=""16""></td><td>&nbsp;" & mam_GetDictionary("TEXT_NO_DEFAULT_SECURITY_POLICY_ROLES") & "</td></tr></table>"
  end if

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Form_Refresh(EventArg)                                      '
' Description :                                                             '
' Parameters  :                                                             '
' Returns     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Form_Refresh(EventArg)
  Dim arrIDs
  Dim varID

  Form_Refresh = false
  
  'Take appropriate action
  Select Case UCase(mdm_UIValue("PageAction"))
    Case "DELETESUBSCRIPTION"
      if len(mdm_UIValue("ID")) > 0 then
        Call AccountTemplateHelper.RemoveSubscription(mdm_UIValue("ID"))
        If Err.Number <> 0 Then
          EventArg.Error.Save Err  
          Form_Refresh = FALSE                        
        End If
      end if

    Case  "ADDSUBSCRIPTION"
      if len(mdm_UIValue("IDs")) > 0 then
        arrIDs = Split(mdm_UIValue("IDs"), ",")
      
        for each varID in arrIDs
          Call AccountTemplateHelper.AddSubscription(varID, false)
          If Err.Number <> 0 Then
            EventArg.Error.Save Err  
            Form_Refresh = FALSE                        
          End If
        next
      end if
      
    Case "ADDGROUPSUBSCRIPTION"
      if len(mdm_UIValue("IDs")) > 0 then
        arrIDs = Split(mdm_UIValue("IDs"), ",")
        
        for each varID in arrIDs
          Call AccountTemplateHelper.AddSubscription(varID, true)
          If Err.Number <> 0 Then
            EventArg.Error.Save Err  
            Form_Refresh = FALSE                        
          End If          
        next
      end if

  End Select

  'Load an updated subscription grid
  Call LoadSubscriptionsGrid()
  
  'Check default policy
  Call CheckDefaultPolicy()
  
  'Set the billing cycle enum
  Call mam_Account_SetBillingCycleEnumType()
  
  Form_Refresh = true
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
  Dim strVal
  Dim strCaption

  'Set the action so the data will be reloaded
  Session("TEMPLATE_ACTION") = "EDIT_TEMPLATE"
  
  'Get the tax exempt property
  strVal = Service.Properties("TAXEXEMPT").Value

  if len(strVal) > 0 then
    strCaption = Service.Properties("TAXEXEMPT").Caption
    Call Service.Properties.Remove("TAXEXEMPT")
    Call Service.Properties.Add("TAXEXEMPT", "BOOLEAN", 0, false, Empty, eMSIX_PROPERTY_FLAG_METERED)
    Service.Properties("TAXEXEMPT").Value = CBool(strVal)
    Service.Properties("TAXEXEMPT").Caption = strCaption
  end if

  Call mam_Account_UpdateBiWeeklyProperties()
  
	'These are special member that are not the "properties" of the template
  AccountTemplateHelper.Name        								= Service.Properties("AccountTemplateName").Value
  AccountTemplateHelper.Description 								= Service.Properties("AccountTemplateDescription").Value
  AccountTemplateHelper.ApplyDefaultSecurityPolicy 	= Service.Properties("ApplyDefaultSecurityPolicy").Value		

  'Decode the payer
  If Not FrameWork.DecodeFieldIDInMSIXProperty(Service("PAYER"),Service("PAYERID")) Then
    EventArg.Error.Number      = 1028
    EventArg.Error.Description = mam_GetDictionary("MAM_ERROR_1028")
    Exit Function
  End If
  
  'Route to the an OK dialog
  Form.RouteTo = mam_ConfirmDialogEncodeAllURLKeepFrame(mam_getDictionary("TEXT_EDIT_ACCOUNT_TEMPLATE"), mam_getDictionary("TEXT_EDIT_ACCOUNT_TEMPLATE_SUCCESS"), mam_getDictionary("WELCOME_DIALOG"))

  Dim success        
  success = AccountTemplateHelper.SaveTemplate()
  If Not CBool(success) Then
    Err.Number = 2013
    Err.Description = mam_GetDictionary("MAM_ERROR_2013")
    EventArg.Error.Save Err  
    OK_Click = FALSE
    Exit Function
  End If

  If Err.Number <> 0 Then
    EventArg.Error.Save Err  
    OK_Click = FALSE                        
  End If
  
  OK_Click = TRUE  
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Apply_Click(EventArg)                                          '
' Description : Save user changes to the account template.                  '
' Parameters  :                                                             '
' Returns     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Apply_Click(EventArg)
  Dim newCol
  Dim strVal
  Dim strCaption

     
  'Set the action so the data will be reloaded
  Session("TEMPLATE_ACTION") = "EDIT_TEMPLATE"

  'Get the tax exempt property
  strVal = Service.Properties("TAXEXEMPT").Value

  if len(strVal) > 0 then
    strCaption = Service.Properties("TAXEXEMPT").Caption
    Call Service.Properties.Remove("TAXEXEMPT")
    Call Service.Properties.Add("TAXEXEMPT", "BOOLEAN", 0, false, Empty, eMSIX_PROPERTY_FLAG_METERED)
    Service.Properties("TAXEXEMPT").Value = CBool(strVal)
    Service.Properties("TAXEXEMPT").Caption = strCaption
  end if
  
  Call mam_Account_UpdateBiWeeklyProperties()
  
	'These are special member that are not the "properties" of the template
  AccountTemplateHelper.Name        								= Service.Properties("AccountTemplateName").Value
  AccountTemplateHelper.Description 								= Service.Properties("AccountTemplateDescription").Value
  AccountTemplateHelper.ApplyDefaultSecurityPolicy 	= Service.Properties("ApplyDefaultSecurityPolicy").Value		

  'Decode the payer
  If Not FrameWork.DecodeFieldIDInMSIXProperty(Service("PAYER"),Service("PAYERID")) Then
    EventArg.Error.Number      = 1028
    EventArg.Error.Description = mam_GetDictionary("MAM_ERROR_1028")
    Exit Function
  End If

  Apply_Click = AccountTemplateHelper.SaveTemplate()

  If Not CBool(Apply_Click) Then
    Err.Number = 2013
    Err.Description = mam_GetDictionary("MAM_ERROR_2013")
    EventArg.Error.Save Err  
    Apply_Click = FALSE
    Exit Function
  End If

  If CBool(Apply_Click) Then  

    CONST ASP_CALL_TEMPLATE = "[ASP]?MDMReload=TRUE&Mode=Move&AccountID=[ACCOUNTID]&AncestorAccountID=[ANCESTORACCOUNTID]&MoveStartDate=[MOVESTARTDATE]"  

  '  If (CLng(Service.Properties("MTWILDCARD").value) = 0) Then
	'  		Form.RouteTo = PreProcess(ASP_CALL_TEMPLATE, Array("ASP", mam_GetDictionary("ACCOUNT_TEMPLATE_APPLY_TO_MOVED_ACCOUNT_DIALOG"), "ACCOUNTID", mam_GetSubscriberAccountID(), "ANCESTORACCOUNTID"	, mam_GetSubscriberAccountID(),"MOVESTARTDATE", mam_GetHierarchyDate()))    
  '      Session("CANCEL_PAGE") = mam_GetDictionary("EDIT_ACCOUNT_TEMPLATE")
  '      response.redirect Form.RouteTo        
  '  Else 
      Set newCol = Server.CreateObject(MT_COLLECTION_PROG_ID)
      Dim typeCol
      Set typeCol = Server.CreateObject(MT_COLLECTION_PROG_ID)
      Call typeCol.Add(Session("MAM_CURRENT_ACCOUNT_TYPE"))
      
      Call SubscriberYAAC().GetDescendents(newCol, mam_GetHierarchyTime(), CLng(Service.Properties("MTWILDCARD").value), CBool(mam_GetDictionary("INCLUDE_FOLDERS_IN_BATCH_OPERATIONS")), typeCol) 
  
      Set Session("BATCH_TEMPLATE_COLLECTION") = newCol
      If newCol.count > 0 Then
        'If newCol.count = 1 then
  	  	'	Form.RouteTo = PreProcess(ASP_CALL_TEMPLATE, Array("ASP", mam_GetDictionary("ACCOUNT_TEMPLATE_APPLY_TO_MOVED_ACCOUNT_DIALOG"), "ACCOUNTID", newCol.item(1), "ANCESTORACCOUNTID"	, mam_GetSubscriberAccountID(),"MOVESTARTDATE", mam_GetHierarchyDate()))    
        'Else
          Form.RouteTo = PreProcess(ASP_CALL_TEMPLATE, Array("ASP", mam_GetDictionary("ACCOUNT_TEMPLATE_APPLY_TO_MULTI_MOVED_ACCOUNT_DIALOG"), "ACCOUNTID", newCol.item(1), "ANCESTORACCOUNTID", mam_GetSubscriberAccountID(),"MOVESTARTDATE", mam_GetHierarchyDate()))
        'End If
        Session("BATCH_ERROR_RETURN_PAGE") = Form.RouteTo
        Session("CANCEL_PAGE") = "AccountTemplate.Edit.asp"        
        response.redirect Form.RouteTo
      Else
        Err.Number = 2014
        Err.Description = mam_GetDictionary("MAM_ERROR_2014")
        EventArg.Error.Save Err  
        Apply_Click = FALSE
        Exit Function      
      End If  
      
   ' End If
    
  End If

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ---------------------------------------------------------------------------
' FUNCTION    : SubscriptionsGrid_DisplayCell
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : 
PRIVATE FUNCTION SubscriptionsGrid_DisplayCell(EventArg) ' As Boolean

	Dim m_objPP, HTML_LINK_EDIT 

  Select Case LCase(EventArg.Grid.SelectedProperty.Name) 
	
         Case "id_po"

            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='24'>"
			      HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A HREF=""Javascript:msgBox('[REMOVE_MESSAGE]','[ASP_FILE]')""><img align='top' border=0 src='[IMAGE]'></A>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
							
            m_objPP.Add "CLASS"          , EventArg.Grid.CellClass
						m_objPP.Add "IMAGE"  		     , "../localized/en-us/images/delete.gif"
						m_objPP.Add "ASP_FILE"  	   , Session("MAM_TEMPLATE_START_DIALOG") & "?PageAction=DeleteSubscription&mdmAction=Refresh&ID=[SUBSCRIPTION_PO]"
						m_objPP.Add "REMOVE_MESSAGE" , Replace(mam_GetDictionary("TEXT_MSGBOX_REMOVE_TEMPLATE_SUBSCRIPTION"),"[ITEM]",Replace(Form.Grids("SubscriptionsGrid").Properties("NM_DISPLAY_NAME").Value, "'", "&rsquo;"))
						m_objPP.Add "SUBSCRIPTION_PO"  		     , Form.Grids("SubscriptionsGrid").Properties("SUBSCRIPTION_PO").Value
						
						EventArg.HTMLRendered 				= m_objPP.Process(HTML_LINK_EDIT)
            SubscriptionsGrid_DisplayCell = TRUE
      
        Case "b_group"
          if EventArg.Grid.Properties("B_GROUP") then
            EventArg.HTMLRendered =  "<td class=" & EventArg.Grid.CellClass & " align='center'><img src='../localized/en-us/images/check.gif'></td>"
          else
            EventArg.HTMLRendered =  "<td class=" & EventArg.Grid.CellClass & " align='center'>--&nbsp;</td>"
          end if
        
        SubscriptionsGrid_DisplayCell = true

      Case Else
	
  		SubscriptionsGrid_DisplayCell =  Inherited("Grid_DisplayCell(EventArg)")
    End Select
END FUNCTION


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : AddSubscription_Click(EventArg)                             '
' Description : Refresh the form so that current values are stored in the   '
'             : session object, then route to the subscription page.        '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function AddSubscription_Click(EventArg)
 ' Call mdm_Terminate()
  Response.Redirect "AccountTemplate.ProductOfferingPicker.asp?MonoSelect=TRUE&Parameters=PageAction|AddSubscription;mdmAction|Refresh;MonoSelect=TRUE&NextPage=" & Server.URLEncode(Session("MAM_TEMPLATE_START_DIALOG"))
  AddSubscribtion_Click = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : AddGroupSubscription_Click(EventArg)                        '
' Description : Refresh the form so that current values are stored in the   '
'             : session object, then route to the subscription page.        '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function AddGroupSubscription_Click(EventArg)
 ' Call mdm_Terminate()
  Response.Redirect "AccountTemplate.GroupSubscriptionPicker.asp?MonoSelect=TRUE&Parameters=IDColumnName|ID_SUB;PageAction|AddGroupSubscription;mdmAction|Refresh;MonoSelect=TRUE&NextPage=" & Server.URLEncode(Session("MAM_TEMPLATE_START_DIALOG"))
  AddGroupSubscribtion_Click = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : AddGroupSubscription_Click(EventArg)                        '
' Description : Refresh the form so that current values are stored in the   '
'             : session object, then route to the default policy page.      '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Public Function EditDefaultSecurityPolicy_Click(EventArg)
'  Call mdm_Terminate()
'  Response.Redirect mam_GetDictionary("MANAGE_DEFAULT_SECURITY_DIALOG") & "&NextPage=" & mam_GetDictionary("EDIT_ACCOUNT_TEMPLATE") & server.URLEncode("?mdmAction=Refresh")
'  EditDefaultSecurityPolicy_Click = true
'End Function

' ???
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Paint
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Paint(EventArg) ' As Boolean
	  Form_Paint = AddUpdateAccount_FormPaint(EventArg) ' Share this event with DefaultDialogUpdateAccount.asp - see accountlib.asp
END FUNCTION

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Delete_Click(EventArg)                                      '
' Description : Delete the template.                                        '
' Parameters  :                                                             '
' Returns     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Delete_Click(EventArg)
  On Error Resume Next

  Dim success  
  
  ' Get a Fresh YAAC
  Set Session("SubscriberYAAC") = FrameWork.AccountCatalog.GetAccount(CLng(mam_GetSubscriberAccountID()), mam_ConvertToSysDate(mam_GetHierarchyTime()))
          
  ' Delete the account template
  success = SubscriberYAAC().DeleteTemplate(AccountTemplateHelper.AccountTemplate.TemplateAccountTypeID)
 
  If Not CBool(success) Then
    Err.Number = 2011
    Err.Description = mam_GetDictionary("MAM_ERROR_2011")
    EventArg.Error.Save Err  
    Delete_Click = FALSE
    Exit Function
  End If
    
  If(CBool(Err.Number = 0)) then
      Form.RouteTo = mam_ConfirmDialogEncodeAllURLKeepFrame(mam_getDictionary("TEXT_DELETE_ACCOUNT_TEMPLATE"), mam_getDictionary("TEXT_DELETE_ACCOUNT_TEMPLATE_SUCCESS"), mam_getDictionary("WELCOME_DIALOG"))
      Call Response.Redirect(Form.RouteTo)
      On Error Goto 0
      Delete_Click = TRUE
  Else        
      EventArg.Error.Save Err  
      Delete_Click = FALSE
  End If
   
End Function
%>

