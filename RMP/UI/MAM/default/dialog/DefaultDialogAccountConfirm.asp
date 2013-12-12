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
' NAME	      :
' DESCRIPTION	:
' AUTHOR	    :
' VERSION	    :
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/CAccountTemplateHelper.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
Form.RouteTo = mam_GetDictionary("HIERARCHY_REFRESH_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : Form_Open 
' PARAMETERS	  :
' DESCRIPTION 	: NEW EVENT - called all the time
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Open(EventArg) ' As Boolean
  SetAddAccountServiceInstance FALSE ' Retreive the Service object from the session - Mandatory
  Form_Open = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : Form_Initialize
' PARAMETERS	  :
' DESCRIPTION 	:
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Form("AccountID")         = Service.Properties("_ACCOUNTID").Value
    Form("AncestorAccountID") = Service.Properties("AncestorAccountID").Value
    
    'If this is a corporate account, don't do anything
    if Form("AncestorAccountID") = MAM_HIERARCHY_ROOT_ACCOUNT_ID then
      call response.redirect( mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=" & Form("AccountID") & "&ForceLoad=TRUE")
' old    call response.redirect(mam_GetHTTPCallToFindASubscriberAndSetItAsCurrent(Service("UserName"),Service("Name_Space"),Empty))
    end if
    
    If IsEmpty(Form("AncestorAccountID")) Then ' no ancestor
    
        mdm_GetDictionary().Add "DEFAULT_DIALOG_ACCOUNT_CONFIRM.SHOW_SUBSCRIPTIONS_GRID", FALSE
    Else
        'Initialize the template helper
        Call AccountTemplateHelper.Initialize(Service.Properties("ancestorAccountID").Value, Service.Properties("AccountType").Value)

        'Load the properties
        if not AccountTemplateHelper.LoadTemplate() then
          exit function
        end if
        
        'Load suggested subscriptions
        if not LoadSuggestedSubscriptionsGrid() then
          exit function
        end if
        
        'If subscriptions are present, init some dynamic properties
        if AccountTemplateHelper.GetSubscriptionsAsRowset().RecordCount > 0 and FrameWork.CheckCoarseCapability("Create subscription") then
          if not InitSubscriptionsDynamicProperties() then
            exit function
          end if
          
          Call mdm_GetDictionary().Add("DEFAULT_DIALOG_ACCOUNT_CONFIRM.SHOW_SUBSCRIPTIONS_GRID", true)
        else
          Call mdm_GetDictionary().Add("DEFAULT_DIALOG_ACCOUNT_CONFIRM.SHOW_SUBSCRIPTIONS_GRID", false)
        end if
    End If

    mam_IncludeCalendar
      
	  Form_Initialize = TRUE
END FUNCTION

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : LoadSuggestedSubscriptionsGrid()                            '
' Description : Load the grid for the suggested subscriptions.  Currently   '
'             : returns all subscriptions, with no checks for users that    '
'             : may already have the subscription.                          '
' Inputs      :                                                             '
' Outputs     : boolean                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function LoadSuggestedSubscriptionsGrid()

  LoadSuggestedSubscriptionsGrid = false
  
  'Add the grid if necessary
  if not Form.Grids.Exist("SubscriptionsGrid") then
    Call Form.Grids.Add("SubscriptionsGrid")
  end if

  Set Form.Grids("SubscriptionsGrid").Rowset = AccountTemplateHelper.GetSubscriptionsAsRowset()
  
  'If there are no subscriptions, hide the grid
  if Form.Grids("SubscriptionsGrid").Rowset.RecordCount = 0 then
    Form.Grids("SubscriptionsGrid").Visible = false
  else
    'Setup the grid
    Call Form.Grids("SubscriptionsGrid").Properties.ClearSelection()
    
    'Order
		Form.Grids("SubscriptionsGrid").Properties("ID_PO").Selected 					  = 1
		Form.Grids("SubscriptionsGrid").Properties("NM_DISPLAY_NAME").Selected 	= 2
    Form.Grids("SubscriptionsGrid").Properties("B_GROUP").Selected 					= 3
    Form.Grids("SubscriptionsGrid").Properties("NM_GROUPSUBNAME").Selected  = 4

    'Captions
		Form.Grids("SubscriptionsGrid").Properties("ID_PO").Caption							= " " ' Must be blank - Place Holder
		Form.Grids("SubscriptionsGrid").Properties("B_GROUP").Caption 					= mam_GetDictionary("TEXT_GROUP_SUBSCRIPTION")
		Form.Grids("SubscriptionsGrid").Properties("NM_DISPLAY_NAME").Caption 	= mam_GetDictionary("TEXT_SUBSCRIPTION_NAME")
		Form.Grids("SubscriptionsGrid").Properties("NM_GROUPSUBNAME").Caption   = mam_GetDictionary("TEXT_SUBSCRIPTION_TEMPLATE_GROUP_SUB_NAME")

    'Other info
		Form.Grids("SubscriptionsGrid").Properties("NM_DISPLAY_NAME").Sorted    = MTSORT_ORDER_ASCENDING		 
		Form.Grids("SubscriptionsGrid").Visible = true
  end if
  
  LoadSuggestedSubscriptionsGrid  = true

End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : InitSubscriptionsDynamicProperties()                        '
' Description : Initialize the dynamic properties, such as dates, for       '
'             : subscriptions.                                              '
' Inputs      :                                                             '
' Outputs     : boolean                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function InitSubscriptionsDynamicProperties()
  InitSubscriptionsDynamicProperties = false
  
  'Add properties
  Call Service.Properties.Add("Subscribe_EffectiveStartDate", "TimeStamp" , 0, false,  Empty)
  Call Service.Properties.Add("Subscribe_EffectiveEndDate", "TimeStamp" , 0, false,  Empty)
  Call Service.Properties.Add("StartNextBillingPeriod", "Boolean"   , 0, false,  Empty)
  Call Service.Properties.Add("EndNextBillingPeriod", "Boolean"   , 0, false,  Empty)  
 
  'Set values
  Service.Properties("Subscribe_EffectiveStartDate").Value = mam_GetHierarchyDate()
  Service.Properties("Subscribe_EffectiveEndDate").Value = Empty
  Service.Properties("StartNextBillingPeriod").Value =	FALSE
  Service.Properties("EndNextBillingPeriod").Value = FALSE
  
  'Set captions
  Service.Properties("Subscribe_EffectiveStartDate").Caption = mam_GetDictionary("TEXT_APPLY_TEMPLATE_SUBSCRIPTIONS_EFFECTIVE_START_DATE")
  Service.Properties("Subscribe_EffectiveEndDate").Caption = mam_GetDictionary("TEXT_APPLY_TEMPLATE_SUBSCRIPTIONS_EFFECTIVE_END_DATE")
  Service.Properties("StartNextBillingPeriod").Caption = mam_GetDictionary("TEXT_SUBSCRIPTION_NEXT_BILLING_PERIOD_START")  
  Service.Properties("EndNextBillingPeriod").Caption = mam_GetDictionary("TEXT_SUBSCRIPTION_NEXT_BILLING_PERIOD_END")  
        
  InitSubscriptionsDynamicProperties = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : SubscriptionsGrid_DisplayCell(EventArg)                     '
' Description : Custom to handle check box for bGroup                       '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function SubscriptionsGrid_DisplayCell(EventArg) ' As Boolean
  if UCase(EventArg.Grid.SelectedProperty.Name) = "B_GROUP" then
    if EventArg.Grid.Properties("B_GROUP") then
      EventArg.HTMLRendered =  "<td class=" & EventArg.Grid.CellClass & " align='center'><img src='../localized/en-us/images/check.gif'></td>"
      SubscriptionsGrid_DisplayCell = true
    else
      EventArg.HTMLRendered =  "<td class=" & EventArg.Grid.CellClass & " align='center'>--&nbsp;</td>"
      SubscriptionsGrid_DisplayCell = true
    end If
    
  'Checkbox to apply subscription
  elseif UCase(EventArg.Grid.SelectedProperty.Name) = "ID_PO" then
    EventArg.HTMLRendered = "<td class=" & EventArg.Grid.CellClass & "><input name=""_ATHS_|" & EventArg.Grid.SelectedProperty.Value & "|" & EventArg.Grid.Properties("B_GROUP") & """ type=""checkbox"" checked></td>"
    
  else
    SubscriptionsGrid_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
  end if
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean
  on error resume next
  OK_Click = FALSE  
      
  If Not IsEmpty(Form("AncestorAccountID")) Then ' Apply the subscriptions
      If Not UpdateAccountWithSubscriptions(EventArg) Then 
          EventArg.Error.Save Err  	      
          Exit Function
      End If
  End If
  
	' Load the account info in MAM().Subscriber object - And let us go the the summary dialog...
  Form.RouteTo =  mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=" & Form("AccountID") & "&ForceLoad=TRUE"
'old	Form.RouteTo = mam_GetHTTPCallToFindASubscriberAndSetItAsCurrent(Service("UserName"),Service("Name_Space"),mam_GetDictionary("SUMMARY_ACCOUNT_INFO_DIALOG"))  
	
  If(CBool(Err.Number = 0)) then
      SetAddAccountServiceInstance TRUE ' Clear the service stored session
      On Error Goto 0
      OK_Click = TRUE
  Else        
      EventArg.Error.Save Err  
      OK_Click = FALSE
  End If  
  
END FUNCTION

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PRIVATE FUNCTION Cancel_Click(EventArg) ' As Boolean

  Form.RouteTo = mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountID=" & Service.Properties("_AccountID")
  SetAddAccountServiceInstance TRUE ' Clear the service stored session  

  Cancel_Click = TRUE
END FUNCTION

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PRIVATE FUNCTION SetAddAccountServiceInstance(booDelete)
    Set Service = Session(MAM_SESSION_NAME_LAST_ADDED_ACCOUNT_SERVICE) ' Store the service for the next dialog
    If(booDelete)Then
        Set Session(MAM_SESSION_NAME_LAST_ADDED_ACCOUNT_SERVICE) = Nothing ' Free the instance...
    End If
END FUNCTION

    
%>

