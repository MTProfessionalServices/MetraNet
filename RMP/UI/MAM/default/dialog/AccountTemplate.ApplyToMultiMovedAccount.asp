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
'
' MetraTech Dialog Manager Framework ASP Dialog 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CBatchError.asp" -->
<!-- #INCLUDE FILE="../../default/lib/CAccountTemplateHelper.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%

' Mandatory
Form.ServiceMsixdefFileName = mam_GetServiceDefForOperationAndType("UPDATE", Session("MAM_CURRENT_ACCOUNT_TYPE"))
Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    Dim strPropertiesHTMLDif
		Dim MSIXAccountTemplate, objPropertiesAdvicesRowSet

		Form("AncestorAccountID") = Request.QueryString("AncestorAccountID")
		Form("AccountID") 				= Request.QueryString("AccountID")
    Form("MoveStartDate") 		= Request.QueryString("MoveStartDate")
    Set Form("colAccountIDs") = Session("BATCH_TEMPLATE_COLLECTION")

    ' Force Subscriptions
    Service.Properties.Add "ForceSubscriptions", "BOOLEAN", 0, FALSE, TRUE, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
    Service.Properties("ForceSubscriptions").Caption = "Automatically end conflicting subscriptions"

    ' Update Properties
    Service.Properties.Add "UpdateProperties", "BOOLEAN", 0, FALSE, TRUE, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
    Service.Properties("UpdateProperties").Caption = "Apply the following checked template properties to accounts"
    
    ' Update Subscriptions
    Service.Properties.Add "UpdateSubscriptions", "BOOLEAN", 0, FALSE, TRUE, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
    Service.Properties("UpdateSubscriptions").Caption = "Apply the following checked subscriptions to accounts"    
    
		' Load properties
		Call MAM().SetActiveTempAccountType(Session("MAM_CURRENT_ACCOUNT_TYPE"))
				
		' Intialize the template helper
    Call AccountTemplateHelper.Initialize(Form("AncestorAccountID"), Session("MAM_CURRENT_ACCOUNT_TYPE"))
    
    ' Load the template
    if not AccountTemplateHelper.LoadTemplate then
      exit function
    end if
    
    ' Init dynamic properties (date, etc)
    if not InitSubscriptionsDynamicProperties() then
      exit function
    end if

    ' Load the suggested subscriptions
    if not LoadSuggestedSubscriptionsGrid() then
      exit function
    end if
    
	  ' Show template properties in a grid
		Form.Grids.Add "PropertiesGrid"
						
	 	Set Form.Grids("PropertiesGrid").RowSet = AccountTemplateHelper.GetTemplatePropertiesAsRowset(MAM().TempAccount)		
	 
	  If Form.Grids("PropertiesGrid").Rowset.RecordCount = 0 Then
		      Service.Properties("UpdateProperties").Value = FALSE
	   			Form.Grids("PropertiesGrid").Visible = FALSE
		Else
					Form.Grids("PropertiesGrid").Properties.ClearSelection 
					Form.Grids("PropertiesGrid").Properties.SelectAll
					
					Form.Grids("PropertiesGrid").Properties("Reserved").Selected 	= 1
					Form.Grids("PropertiesGrid").Properties("Caption").Selected 	= 2
					Form.Grids("PropertiesGrid").Properties("Value").Selected    	= 3
				
					Form.Grids("PropertiesGrid").Properties("Reserved").Caption		= " "
					Form.Grids("PropertiesGrid").Properties("Caption").Caption		= mdm_GetDictionaryValue("TEXT_ACCOUNT_TEMPLATE_PROPERTY_NAME","")
					Form.Grids("PropertiesGrid").Properties("Value").Caption	  	= mdm_GetDictionaryValue("TEXT_ACCOUNT_TEMPLATE_TEMPLATE_VALUE","")
					Form.Grids("PropertiesGrid").Visible = TRUE
	  End If
    
    mam_IncludeCalendar
    
		CancelRequiredProperties		
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

  'Get the subscriptions from the MSIX account template
  Set Form.Grids("SubscriptionsGrid").Rowset = AccountTemplateHelper.GetSubscriptionsAsRowset()
  
  'personalization
   if Not FrameWork.CheckCoarseCapability("Create subscription") then   
      Form.Grids("SubscriptionsGrid").Visible = false
      Call mdm_GetDictionary.Add("bSubscriptions", false)
      LoadSuggestedSubscriptionsGrid  = true          
      Exit Function
   end if 
   
  'If there are no subscriptions, hide the grid
  if Form.Grids("SubscriptionsGrid").Rowset.RecordCount = 0 then
    Form.Grids("SubscriptionsGrid").Visible = false
		Call mdm_GetDictionary.Add("bSubscriptions", false)
  else
    'Setup the grid
		Call mdm_GetDictionary.Add("bSubscriptions", true)
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
  Call Service.Properties.Add("Subscribe_EffectiveEndDate"  , "TimeStamp" , 0, false,  Empty)
  Call Service.Properties.Add("StartNextBillingPeriod"      , "Boolean"   , 0, false,  Empty)
  Call Service.Properties.Add("EndNextBillingPeriod"        , "Boolean"   , 0, false,  Empty)  
 
  'Set values
  Service.Properties("Subscribe_EffectiveStartDate").Value = CDate(Form("MoveStartDate"))
  Service.Properties("Subscribe_EffectiveEndDate").Value 	 = Empty
  Service.Properties("StartNextBillingPeriod").Value       = FALSE
  Service.Properties("EndNextBillingPeriod").Value         = FALSE

  'Set captions
  Service.Properties("Subscribe_EffectiveStartDate").Caption = mam_GetDictionary("TEXT_APPLY_TEMPLATE_SUBSCRIPTIONS_EFFECTIVE_START_DATE")
  Service.Properties("Subscribe_EffectiveEndDate").Caption   = mam_GetDictionary("TEXT_APPLY_TEMPLATE_SUBSCRIPTIONS_EFFECTIVE_END_DATE")
  Service.Properties("StartNextBillingPeriod").Caption       = mam_GetDictionary("TEXT_SUBSCRIPTION_NEXT_BILLING_PERIOD_START")  
  Service.Properties("EndNextBillingPeriod").Caption         = mam_GetDictionary("TEXT_SUBSCRIPTION_NEXT_BILLING_PERIOD_END")  
        
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
  'Checkbox for group
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
PUBLIC FUNCTION CANCEL_Click(EventArg)		
    Form.RouteTo = mam_getDictionary("WELCOME_DIALOG")
		CANCEL_Click = TRUE
END FUNCTION		

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PUBLIC FUNCTION OK_Click(EventArg)		

  on error resume next 	

	OK_Click = FALSE

  Set Session("LAST_BATCH_ERRORS") = BatchError.GetBatchErrorRS() ' Clean any old errors

  ' Update Properties  
  If CBool(Service.Properties("UpdateProperties").Value) Then
    Call AccountTemplateHelper.ApplyTemplatesToAccounts(Form("colAccountIDs"))

    'check if there were any errors
    Set Session("LAST_BATCH_ERRORS") = BatchError.GetBatchErrorRS()

    ' Handle errors  
    If Session("LAST_BATCH_ERRORS").RecordCount > 0 Then
      Err.number = 1052
      Err.Description = mam_GetDictionary("MAM_ERROR_1052")
      EventArg.Error.Save Err
        
      OK_Click = FALSE  
      Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
      Response.Redirect mdm_GetCurrentFullURL()            
      Exit Function
    End If
        
  End if


  ' Update Subscriptions
  If CBool(Service.Properties("UpdateSubscriptions").Value) Then
	  Set Session("LAST_BATCH_ERRORS") = UpdateAccountsWithSubscriptions(Form("colAccountIDs")) 

    ' Handle errors  
    If Session("LAST_BATCH_ERRORS").RecordCount > 0 Then
      Err.number = 1052
      Err.Description = mam_GetDictionary("MAM_ERROR_1052")
      EventArg.Error.Save Err
        
      OK_Click = FALSE  
      Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
      Response.Redirect mdm_GetCurrentFullURL()            
      Exit Function
    End If
  	  
  End if	  

                  
  If(CBool(Err.Number = 0)) then
      On Error Goto 0
        
      Form.RouteTo = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_APPLY_TEMPLATE_TO_MOVED_ACCOUNT"), mam_GetDictionary("TEXT_INFO_SUCCEFULLY_UPDATED"), Form.RouteTo)
      Response.Redirect Form.RouteTo 	      
      OK_Click = TRUE
  Else
      EventArg.Error.Save Err 
        
      OK_Click = FALSE       
      Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
      Response.Redirect mdm_GetCurrentFullURL()   
  End If              

	OK_Click = TRUE	
END FUNCTION

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : UpdateAccountsWithSubscriptions(colAccountIDs)              '
' Description :                                                             '
' Inputs      : Collection of account ids                                   '
' Outputs     : Returns Batch Error Rowset                                  '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PUBLIC FUNCTION UpdateAccountsWithSubscriptions(colAccountIDs)
	on error resume next
	Dim booOK, v, arrVar, lngPOID, objUIItems, bGroup, rs

  mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
	
	For Each v In objUIItems
	
			arrVar = Split(v.name,"|")
			
			Select Case arrVar(0)
			
					Case "_ATHS_"
							lngPOID = arrVar(1)
              
              if UCase(arrVar(2)) = "TRUE" then
                bGroup = true
              else
                bGroup = false
              end if  
              
              Call BatchSubscribeToProductOffering(colAccountIDs, lngPOID, Service("Subscribe_EffectiveStartDate"), Service("Subscribe_EffectiveEndDate"), Service("StartNextBillingPeriod"), Service("EndNextBillingPeriod"), bGroup)

              dim i
              set rs = Session("LAST_BATCH_ERRORS")
              If rs.RecordCount > 0 Then
                rs.MoveFirst
                for i=1 to rs.RecordCount
                  Call BatchError.Add(rs.Value("id_acc"), rs.Value("accountname"), Session("EXTRA_ERROR_INFO") & ":  " & rs.Value("description"))
                  rs.MoveNext
                Next
              End If  
              Session("EXTRA_ERROR_INFO") = ""
			End Select
	Next			
	Set UpdateAccountsWithSubscriptions = BatchError.GetBatchErrorRS()
  On Error Goto 0
END FUNCTION

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : BatchSubscribeToProductOffering                             '
' Description : Subscribe a group of accounts.                              '
' Inputs      : colAccountIDs, lngPOID, strStartDate, strEndDate,           '
'               bEffectiveNextPeriod, bGroup                                '
' Outputs     : true, false                                                 '
'               Session("LAST_BATCH_ERRORS"), Session("EXTRA_ERROR_INFO")   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function BatchSubscribeToProductOffering(colAccountIDs, lngPOID, strStartDate, strEndDate, bStartNextBillingPeriod, bEndNextBillingPeriod, bGroup)
  On Error Resume Next

  Dim objProductCatalog
  Dim objGSubMember
  Dim objCol
  Dim bModified
  Dim objSC
  Dim objGroupSub
  Dim i
    
  BatchSubscribeToProductOffering = False
  
  ' Create objects
  Set objProductCatalog = GetProductCatalogObject()
  Set objCol = Server.CreateObject("Metratech.MTCollection.1")
  Set objSC = Server.CreateObject("Metratech.MTSubscriptionCatalog.1")
  objSC.SetSessionContext FrameWork.SessionContext

  If bGroup Then
    Set objGroupSub = objProductCatalog.GetGroupSubscriptionByID(lngPOID)
  End If

  
  For i = 1 To colAccountIDs.count
    Set objGSubMember = Server.CreateObject("MTProductCatalog.MTSubInfo.1")
    
    ' Populate MTSubInfo
    objGSubMember.AccountID = colAccountIDs.item(i)
    objGSubMember.ProdOfferingID = lngPOID

    If bGroup Then
      objGSubMember.CorporateAccountID = objGroupSub.CorporateAccount
      objGSubMember.GroupSubID = objGroupSub.GroupID
    End If  
    
    objGSubMember.SubsStartDate = strStartDate
    objGSubMember.SubsStartDateType = IIF(bStartNextBillingPeriod , PCDATE_TYPE_BILLCYCLE , PCDATE_TYPE_ABSOLUTE)
        
    If Len(strEndDate) > 0 Then
      objGSubMember.SubsEndDate = strEndDate
    Else
      objGSubMember.SubsEndDate = FrameWork.RCD().GetMaxDate()  
    End If
    objGSubMember.SubsEndDateType = IIF(bEndNextBillingPeriod , PCDATE_TYPE_BILLCYCLE , PCDATE_TYPE_ABSOLUTE)
    
    ' Add MTSubInfo to collection
    Call objCol.Add(objGSubMember)
  Next
      
  ' Handle group subscriptions and non-group subscriptions differently
  If bGroup Then
    ' Call SubscribeToGroups
    Set Session("LAST_BATCH_ERRORS") = objSC.SubscribeToGroups(objCol, nothing, CBool(Service.Properties("ForceSubscriptions").Value), CBool(bModified))
    Session("EXTRA_ERROR_INFO") = objProductCatalog.GetGroupSubscriptionByID(lngPOID).Name
  Else
    ' Call SubscribeAccounts
    Set Session("LAST_BATCH_ERRORS") = objSC.SubscribeAccounts (objCol, nothing, CBool(Service.Properties("ForceSubscriptions").Value), CBool(bModified))
    Session("EXTRA_ERROR_INFO") = objProductCatalog.GetProductOfferingByID(lngPOID).Name
  End If
  
  If Session("LAST_BATCH_ERRORS").RecordCount > 0 Then
    BatchSubscribeToProductOffering = False  
  Else
    BatchSubscribeToProductOffering = True
  End If
  
  On Error Goto 0
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PRIVATE FUNCTION CancelRequiredProperties() ' As Boolean

	Dim p
	For Each p in Service.Properties
	
		p.Required = FALSE
	Next
	CancelRequiredProperties = TRUE
END FUNCTION

%>

