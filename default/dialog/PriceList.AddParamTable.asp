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
' MetraTech Dialog Manager Demo
' 
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : F.Torres
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE FILE="../lib/ProductCatalogXml.asp" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("PRICE_LIST_VIEW_EDIT_DIALOG")

mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form.Modal = TRUE   ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will not terminate the dialog
                      ' but do a last rendering/refresh.

  Form("PRICELIST_ID") = request("ID")
  Form("FramedPriceList") = request("FramedPriceList")
  
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
                  

  'SECENG: Fix ESR-3159: BC: Error when adding the new Parameter Table to Price List with more id length more than 5
  'Parameter table id size enlarged to 8. 
  Service.Properties.Add "ADD_PARAMTABLEID"     , "string", 8, False , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ADD_PRICEABLEITEMID"     , "string", 8, False , Empty, eMSIX_PROPERTY_FLAG_NONE

  Service.Properties.Add "InitiallyExpanded"     , "string", 50, False , Empty, eMSIX_PROPERTY_FLAG_NONE
  
  '//Used to set the correct javascript on the page
  if (request("State")="Collapsed") then
    Service.Properties("InitiallyExpanded").Value = "false"
  else
    Service.Properties("InitiallyExpanded").Value = "true"
  end if
  
  'Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, _
  '                                   "<PARAM_TABLE_SELECTOR />", _
  '                                   getParamTableSelectorHTML())

  Service.Properties.Add "Description"      , "string", 0, False , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "tmpAbsStartDate"  , MSIXDEF_TYPE_TIMESTAMP ,0 ,FALSE , Empty
  Service.Properties.Add "tmpAbsEndDate"	  , MSIXDEF_TYPE_TIMESTAMP ,0 ,FALSE , Empty
  Service.Properties.Add "tmpSubsStartDate" , MSIXDEF_TYPE_INT32 		 ,0 ,FALSE , 0
  Service.Properties.Add "tmpSubsEndDate"	  , MSIXDEF_TYPE_INT32 		 ,0 ,FALSE , 0
  Service.Properties.Add "tmpBillStartDate" , MSIXDEF_TYPE_TIMESTAMP ,0 ,FALSE , Empty
  Service.Properties.Add "tmpBillEndDate"	  , MSIXDEF_TYPE_TIMESTAMP ,0 ,FALSE , Empty 
  
  ' Now we populate the tmp properties with the correct values depending on
  ' the start and end date types
  'call LoadSettings()
      
  mcm_IncludeCalendar
  
  Service.LoadJavaScriptCode
  
  Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  'On Error Resume Next

    session("RATES_PARAMTABLE_ID") = Service("ADD_PARAMTABLEID")
  	session("RATES_PRICEABLEITEM_ID") = Service("ADD_PRICEABLEITEMID")

  dim idPI, idPT, idPL
  
  idPI = Service("ADD_PRICEABLEITEMID")
  idPT = Service("ADD_PARAMTABLEID")
  idPL = Form("PRICELIST_ID")
  
    
	On Error Resume Next
	If (not ValidateInputValues()) Then
		if Form("StartDateAfterEndDate") then
	  	EventArg.Error.Number = COMObject.Tools.MakeItUserVisibleMTCOMError(1004)
   		EventArg.Error.Description = FrameWork.GetDictionary("MCM_ERROR_1004")		
		else
	  	EventArg.Error.Number = COMObject.Tools.MakeItUserVisibleMTCOMError(1002)
   		EventArg.Error.Description = FrameWork.GetDictionary("MCM_ERROR_1002")
		end if
   	OK_Click = FALSE
   	Exit Function
	End If
	
'	If (IsDateInPast()) And (Form("DateIsInThePastWarningDisplayed") = FALSE) Then
'	  EventArg.Error.Number = COMObject.Tools.MakeItUserVisibleMTCOMError(1003)
'   	EventArg.Error.Description = FrameWork.GetDictionary("MCM_ERROR_1003")
'		Form("DateIsInThePastWarningDisplayed") = TRUE
'   	OK_Click = FALSE
'   	Exit Function
'	Else
		' Reset Form variable so if we refresh this dialog, everything is clean.
'		Form("DateIsInThePastWarningDisplayed") = FALSE
'	End If

  '//Get ready to creat rate schedules
  dim objProdCat
  Set objProdCat = GetProductCatalogObject

  dim objNewRateSchedule
  set objNewRateSchedule = CreateRateSchedule(false,idPI,idPT,idPL,objProdCat)
  
  objNewRateSchedule.Description = Service.Properties("Description").Value

	'Grab start and end dates out of request
  objNewRateSchedule.EffectiveDate.StartDateType = Request.Form("EffectiveDate__StartDateType")
  objNewRateSchedule.EffectiveDate.EndDateType =  Request.Form("EffectiveDate__EndDateType")
 
  Set COMObject.Instance = objNewRateSchedule   
  If Not IsValidObject(COMObject.Instance) Then
    Response.write FrameWork.GetDictionary("ERROR_ITEM_NOT_FOUND") & Request.QueryString(idPL)
    Response.end
  End If

  call SaveSettings(objNewRateSchedule.EffectiveDate.StartDateType,  objNewRateSchedule.EffectiveDate.EndDateType)

  call COMObject.Instance.Save

  mcmTriggerUpdateOfPricelistNavigationPane 
    
  OK_Click = TRUE  
  GetBack()
END FUNCTION

FUNCTION CreateRateSchedule(bRatesPOBased,idPI,idPT,idPL,objProdCat)

dim objNewRateSchedule
set objNewRateSchedule = nothing

'Let's temporarily retrieve the IDs from the session
'pi_id = Clng(session("RATES_PRICEABLEITEM_ID"))
'pt_id = Clng(session("RATES_PARAMTABLE_ID"))
'pl_id = Clng(session("RATES_PRICELIST_ID"))

'We need this object anyway to look up the Editing Screen for this particular parameter table
dim objParamTable
Set objParamTable = objProdCat.GetParamTableDefinition(idPT)

if bRatesPOBased then
	'Set objPriceableItem = objProdCat.GetPriceableItem(pi_id)
	'Set objPricelistMapping = objPriceableItem.GetPriceListMapping(pt_id)
	'Set objNewRateSchedule = objPricelistMapping.CreateRateSchedule()
else
	Set objNewRateSchedule = objParamTable.CreateRateSchedule(idPL, idPI)
end if

set CreateRateSchedule = objNewRateSchedule
END FUNCTION


PRIVATE FUNCTION SaveSettings(startDateType, endDateType) ' As Boolean

  Select Case startDateType 	
    Case PCDATE_TYPE_NULL
      ' Do we do anything here if the date is null?
    Case PCDATE_TYPE_ABSOLUTE
    	COMObject.Instance.EffectiveDate.StartDate   = COMObject.Properties("tmpAbsStartDate").Value
    Case PCDATE_TYPE_SUBSCRIPTION
    	COMObject.Instance.EffectiveDate.StartOffset = COMObject.Properties("tmpSubsStartDate").Value   	
    Case PCDATE_TYPE_BILLCYCLE
    	COMObject.Instance.EffectiveDate.StartDate 	 = COMObject.Properties("tmpBillStartDate").Value
  End Select
  
   Select Case endDateType
    Case PCDATE_TYPE_NULL
      ' Do we do anything here if the date is null?
    Case PCDATE_TYPE_ABSOLUTE
    	COMObject.Instance.EffectiveDate.EndDate   = COMObject.Properties("tmpAbsEndDate").Value
    Case PCDATE_TYPE_SUBSCRIPTION
    	COMObject.Instance.EffectiveDate.EndOffset = COMObject.Properties("tmpSubsEndDate").Value   	
    Case PCDATE_TYPE_BILLCYCLE
    	COMObject.Instance.EffectiveDate.EndDate 	 = COMObject.Properties("tmpBillDate").Value
  End Select
  
  SaveSettings = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ValidateInputValues
' PARAMETERS		  : 
' DESCRIPTION 		: Checks validity of date input, including if end date comes after start date
' RETURNS		      : Return TRUE if ok else FALSE
FUNCTION ValidateInputValues()

	ValidateInputValues = TRUE
	Form("StartDateAfterEndDate") = FALSE
  Exit Function

	Select Case COMObject.Properties("EffectiveDate__StartDateType").Value
		Case PCDATE_TYPE_ABSOLUTE
			if not IsDate(COMObject.Properties("tmpAbsStartDate").Value) then
				ValidateInputValues = FALSE
				Exit Function
			end if
		Case PCDATE_TYPE_SUBSCRIPTION
			if not IsNumeric(COMObject.Properties("tmpSubsStartDate").Value) then
				ValidateInputValues = FALSE
				Exit Function
			end if
		Case PCDATE_TYPE_BILLCYCLE
			if not IsDate(COMObject.Properties("tmpBillStartDate").Value) then
				ValidateInputValues = FALSE
				Exit Function
			end if
	End Select

	Select Case COMObject.Properties("EffectiveDate__EndDateType").Value
		Case PCDATE_TYPE_ABSOLUTE
			if not IsDate(COMObject.Properties("tmpAbsEndDate").Value) then
				ValidateInputValues = FALSE
				Exit Function
			else
				'Here we will check to see if the start date is before the end date, when it makes sense
				if COMObject.Properties("EffectiveDate__StartDateType").Value = PCDATE_TYPE_ABSOLUTE then
					if CDate(COMObject.Properties("tmpAbsStartDate").Value) > CDate(COMObject.Properties("tmpAbsEndDate").Value) then
						ValidateInputValues = FALSE
						Form("StartDateAfterEndDate") = TRUE
					end if
				elseif COMObject.Properties("EffectiveDate__StartDateType").Value = PCDATE_TYPE_BILLCYCLE then
					if CDate(COMObject.Properties("tmpBillStartDate").Value) > CDate(COMObject.Properties("tmpAbsEndDate").Value) then
						ValidateInputValues = FALSE
						Form("StartDateAfterEndDate") = TRUE
					end if					 
				end if
			end if
		Case PCDATE_TYPE_SUBSCRIPTION
			if not IsNumeric(COMObject.Properties("tmpBillEndDate").Value) then
				ValidateInputValues = FALSE
				Exit Function
			else
				if CLng(COMObject.Properties("tmpSubsStartDate").Value) > CLng(COMObject.Properties("tmpSubsEndDate").Value) then
					ValidateInputValues = FALSE
					Form("StartDateAfterEndDate") = TRUE
				end if				
			end if
		Case PCDATE_TYPE_BILLCYCLE
			if not IsNumeric(COMObject.Properties("tmpSubsEndDate").Value) then
				ValidateInputValues = FALSE
				Exit Function
			else
				if COMObject.Properties("EffectiveDate__StartDateType").Value = PCDATE_TYPE_BILLCYCLE then
					if CDate(COMObject.Properties("tmpBillStartDate").Value) > CDate(COMObject.Properties("tmpBillEndDate").Value) then
						ValidateInputValues = FALSE
						Form("StartDateAfterEndDate") = TRUE
					end if
				end if
			end if
	End Select
	
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : CANCEL_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Cancel_Click(EventArg) ' As Boolean
  CANCEL_Click = TRUE
  GetBack()
END FUNCTION

FUNCTION GetBack()
  dim idPL
  idPL = Form("PRICELIST_ID")

  GetBack = TRUE
  
  If(Len(Form("FramedPriceList")) > 0 and UCase(Form("FramedPriceList")) = "TRUE") Then
    Response.Redirect("/mcm/default/dialog/Pricelist.ViewEdit.Frame.asp?ID=" + idPL + "&LinkColumnMode=TRUE&Rates=TRUE&POBased=FALSE&Title=TEXT_RATES_ALLPRICELISTS_CHOOSE_PRICEABLE_ITEM&kind=10")
  Else
    Response.Redirect("/mcm/default/dialog/Pricelist.ViewEdit.asp?ID=" + idPL)
  End If
END FUNCTION
%>



