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
' MetraTech Dialog Manager Page
' 
' DIALOG	    : RateSchedule Edit Window
' DESCRIPTION	: 
' AUTHOR	    : Fabricio Pettena	
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("RATES_RATESCHEDULE_LIST_DIALOG")

mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Populate()
' PARAMETERS		  : 
' DESCRIPTION 		: Check if the time for the end date was set if not we set 23:59:59.
' RETURNS		      : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Populate(EventArg) ' As Boolean
    
      Inherited("Form_Populate") ' First Let us call the inherited event
      
      mcm_CheckEndDate EventArg, "tmpAbsEndDate"
      Form_Populate = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : RetrieveSettings
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION SaveSettings() ' As Boolean

  Select Case COMObject.Properties("EffectiveDate__StartDateType").Value  	
    Case PCDATE_TYPE_NULL
      ' Do we do anything here if the date is null?
    Case PCDATE_TYPE_ABSOLUTE
    	COMObject.Instance.EffectiveDate.StartDate   = COMObject.Properties("tmpAbsStartDate").Value
    Case PCDATE_TYPE_SUBSCRIPTION
    	COMObject.Instance.EffectiveDate.StartOffset = COMObject.Properties("tmpSubsStartDate").Value   	
    Case PCDATE_TYPE_BILLCYCLE
    	COMObject.Instance.EffectiveDate.StartDate 	 = COMObject.Properties("tmpBillStartDate").Value
  End Select
  
  Select Case COMObject.Properties("EffectiveDate__EndDateType").Value
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
' FUNCTION 		    : IsDateInPast
' PARAMETERS		  : 
' DESCRIPTION 		: Test if dates are in the past. Warn is given later on, if so. Note that this assumes that the dates are already validated
'										by ValidateInputValues
' RETURNS		      : Return TRUE if start or end date is in the past

FUNCTION IsDateInPast()

	IsDateInPast = FALSE
	if COMObject.Properties("EffectiveDate__StartDateType").Value = PCDATE_TYPE_ABSOLUTE then
		if CDate(COMObject.Properties("tmpAbsStartDate").Value) < FrameWork.MetraTimeGMTNow then
			IsDateInPast = TRUE
		end if
	end if
	
	if COMObject.Properties("EffectiveDate__EndDateType").Value = PCDATE_TYPE_ABSOLUTE then
		if CDate(COMObject.Properties("tmpAbsEndDate").Value) < FrameWork.MetraTimeGMTNow then
			IsDateInPast = TRUE
		end if
	end if
	
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ValidateInputValues
' PARAMETERS		  : 
' DESCRIPTION 		: Checks validity of date input, including if end date comes after start date
' RETURNS		      : Return TRUE if ok else FALSE
FUNCTION ValidateInputValues()

	ValidateInputValues = TRUE
	Form("StartDateAfterEndDate") = FALSE
	
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
' FUNCTION 		    : LoadSettings
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION LoadSettings() ' As Boolean

  Select Case COMObject.Properties("EffectiveDate__StartDateType").Value  	
  Case PCDATE_TYPE_NULL
    ' Do we do anything here if the date is null?
  Case PCDATE_TYPE_ABSOLUTE
  	COMObject.Properties("tmpAbsStartDate").Value  = COMObject.Properties("EffectiveDate__StartDate").Value
  Case PCDATE_TYPE_SUBSCRIPTION
		COMObject.Properties("tmpSubsStartDate").Value = COMObject.Properties("EffectiveDate__StartOffset").Value  	
  Case PCDATE_TYPE_BILLCYCLE
  	COMObject.Properties("tmpBillStartDate").Value = COMObject.Properties("EffectiveDate__StartDate").Value
  End Select
  
  Select Case COMObject.Properties("EffectiveDate__EndDateType").Value
  Case PCDATE_TYPE_NULL
    ' Do we do anything here if the date is null?
  Case PCDATE_TYPE_ABSOLUTE
  	COMObject.Properties("tmpAbsEndDate").Value  = COMObject.Properties("EffectiveDate__EndDate").Value
  Case PCDATE_TYPE_SUBSCRIPTION
  	COMObject.Properties("tmpSubsEndDate").Value = COMObject.Properties("EffectiveDate__EndOffset").Value 
  Case PCDATE_TYPE_BILLCYCLE
  	COMObject.Properties("tmpBillEndDate").Value = COMObject.Properties("EffectiveDate__EndDate").Value
  End Select
	
  LoadSettings = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject    
  Dim objMTParamTable
  Dim objMTRateSchedule
	
  Form.Modal = TRUE   ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will not terminate the dialog
                      ' but do a last rendering/refresh.

  ' Find the PriceableItem and store it into the MDM COM Object, this will take care of the sub object like EffectiveDate  
	
	Form("DateIsInThePastWarningDisplayed") = FALSE

  Set objMTParamTable = objMTProductCatalog.GetParamTableDefinition(CLng(Request.QueryString("PT_ID")))
  If Not IsValidObject(objMTParamTable) Then
    Response.write FrameWork.GetDictionary("ERROR_ITEM_NOT_FOUND") & Request.QueryString("PT_ID")
    Response.end
  End If

  Set COMObject.Instance = objMTParamTable.GetRateSchedule(CLng(Request.QueryString("RS_ID")))   
  If Not IsValidObject(COMObject.Instance) Then
    Response.write FrameWork.GetDictionary("ERROR_ITEM_NOT_FOUND") & Request.QueryString("RS_ID")
    Response.end
  End If
  
	'Response.write (COMObject.Instance.EffectiveDate.StartDateType)
	'Response.write (COMObject.Instance.EffectiveDate.EndDateType)
  ' We are going to create temp properties in this COMObj so we can display only the desired fields in the final screen
  ' All the other variables that are not relevant are simply blank, according to the start and end date types
  
  COMObject.Properties.Add "tmpAbsStartDate"  , MSIXDEF_TYPE_TIMESTAMP ,0 ,FALSE , Empty
  COMObject.Properties.Add "tmpAbsEndDate"	  , MSIXDEF_TYPE_TIMESTAMP ,0 ,FALSE , Empty
  COMObject.Properties.Add "tmpSubsStartDate" , MSIXDEF_TYPE_INT32 		 ,0 ,FALSE , 0
  COMObject.Properties.Add "tmpSubsEndDate"	  , MSIXDEF_TYPE_INT32 		 ,0 ,FALSE , 0
  COMObject.Properties.Add "tmpBillStartDate" , MSIXDEF_TYPE_TIMESTAMP ,0 ,FALSE , Empty
  COMObject.Properties.Add "tmpBillEndDate"	  , MSIXDEF_TYPE_TIMESTAMP ,0 ,FALSE , Empty 
  
  ' Now we populate the tmp properties with the correct values depending on
  ' the start and end date types
  call LoadSettings()
      
  mcm_IncludeCalendar
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

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
	
	If (IsDateInPast()) And (Form("DateIsInThePastWarningDisplayed") = FALSE) Then
	  EventArg.Error.Number = COMObject.Tools.MakeItUserVisibleMTCOMError(1003)
   	EventArg.Error.Description = FrameWork.GetDictionary("MCM_ERROR_1003")
		Form("DateIsInThePastWarningDisplayed") = TRUE
   	OK_Click = FALSE
   	Exit Function
	Else
		' Reset Form variable so if we refresh this dialog, everything is clean.
		Form("DateIsInThePastWarningDisplayed") = FALSE
	End If
	
	'Now we have to translate back the tmp Types into real properties
	'So we grab the values of the tmp properties and set them back on the
	'real properties based on the start and end date types
	call SaveSettings()
	' This is a RateSchedule, so we will call SaveWithRules
	call COMObject.Instance.Save
    
	If (Err.Number) Then
    EventArg.Error.Save Err
    OK_Click = FALSE
    Err.Clear
  Else
    OK_Click = TRUE
  End If    
END FUNCTION
%>
