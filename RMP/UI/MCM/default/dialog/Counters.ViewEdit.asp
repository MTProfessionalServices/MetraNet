
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
' AUTHOR	    : Srinivasa Kolla
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit

%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form.Modal = TRUE
  Dim objMTProductCatalog
  dim intCounterId, objCounterParameters
  dim objCounter
	Dim objDiscount

  '//COMObject.Log "RUDI FORM INITIALIZE"
  Set objMTProductCatalog = GetProductCatalogObject
  
   dim intDiscountId
  intDiscountId = Clng(Request("PI_ID"))
	Form("PI_ID") = intDiscountId
  
   'We need to load the discount, and see if this counter is selected for Discount Distribution
 Set objDiscount = objMTProductCatalog.GetPriceableItem(intDiscountId)

  
  intCounterId    = request("id")
	
  dim intCPDId
  intCPDId = Clng(Request("CPD_ID"))
  Form("CPD_ID") = intCPDId
    
	
  '// In the context of a product offering discount, we may be creating a new counter
  if intCounterId = "" then
    ' Creating a new counter
    dim strPreferredCounterType
    
    dim objCounterType
    set objCounterType = objMTProductCatalog.GetCounterTypeByName("SumOfOneProperty")
    set objCounter = objCounterType.CreateCounter
    objCounter.Name = "#Discount Owned Counter"
    objCounter.Description = ""
    Form("NEW_COUNTER") = true
  else
    ' Use the existing counter
    set objCounter  = objDiscount.GetCounter(intCPDId)
    objCounter.Name = "#Discount Owned Counter"
    Form("NEW_COUNTER") = false
  end if
  
Service.Properties.Add "DiscountDistributionCheck", "BOOLEAN", 0, FALSE, FALSE
If not objDiscount.GetDistributionCounter Is Nothing then
	Service.Properties("DiscountDistributionCheck").value = CBool(objDiscount.GetDistributionCounter.ID = objCounter.ID)
Else
		Service.Properties("DiscountDistributionCheck").value = false
End If

  
  
  'dim objCounterParameters
  'dim objParameter
  
  'set objCounterParameters = objCounter.Parameters
  'for each objParameter in objCounterParameters
  '  Response.write("Parameter: [" & objParameter.Name & "] [" & objParameter.Kind & "] [" & objParameter.DBType & "]")
  '  Response.write(" = [" & objParameter.Value & "]<BR>")
  'next

    Set COMObject.Instance = objCounter
    
    Service.Properties.Add "TypeID", "INT32", "0", false, 0
    
    Service.Properties("Alias").Required = FALSE ' This property is marked a required though it is not in the dialog - FRED! 6/12/01
    Service.Properties("Formula").Required = FALSE ' This property is marked a required though it is not in the dialog - FRED! 6/12/01
    
    'RESPONSE.WRITE ">>>>" & COMObject.Properties("TypeID") Is NOTHING
   ' RESPONSE.WRITE "<br>>>>>" & REPLACE(COMObject.Properties.ToString(),vbnewline,"<br>")
   ' RESPONSE.END
    SetMSIXPropertyTypeCounterType COMObject.Properties("TypeID"),objMTProductCatalog
        
     Service.Properties.Add "CounterTypeTitle", "String",  256, FALSE, TRUE  
     Service.Properties("CounterTypeTitle") = ""

     Service.Properties.Add "CounterTypeInformation", "String",  256, FALSE, TRUE  
     Service.Properties("CounterTypeInformation") = ""
     
     Form.Grids.Add "CounterParameters"
     RefreshCounterTypeInformation()
     
	
		 
		
    'Form.Grids("ExtendedProperties").Properties("Name").Selected    = 1
    'Form.Grids("ExtendedProperties").Properties("Value").Selected   = 2
    
    'COMObject.Properties.Enabled              = FALSE ' Every control is grayed
    'Form.Grids("ExtendedProperties").Enabled  = FALSE
    
    ' Set the dynamic enum type
		'	response.write TypeName(COMObject.instance) & "<br>"
		' response.write replace(COMObject.Properties.ToString,vbnewline,"<br>")
		' response.end
	
    'SetMSIXPropertyTypeToPriceableItemEnumType  COMObject.Properties("Kind")
    'SetMSIXPropertyTypeToChargeInEnumType       COMObject.Properties("ChargeInAdvance")
  	'SetMSIXPropertyTypeToProrateOnEnumType      COMObject.Properties("ProrationType")
    'SetMSIXPropertyTypeToDayOfMonthEnumType     COMObject.Properties("Cycle.DayOfMonth1")
    'SetMSIXPropertyTypeToDayOfMonthEnumType     COMObject.Properties("Cycle.DayOfMonth2")
    
    
    'mcm_IncludeCalendar ' Support calendar

	  Form_Initialize = TRUE
END FUNCTION

PRIVATE FUNCTION RefreshCounterTypeInformation()

  ' See if this counter has any parameters
  if COMObject.Instance.Parameters.count <> 0 then
    Set Form.Grids("CounterParameters").MTCollection() = COMObject.Instance.Parameters

    Form.Grids("CounterParameters").Properties.ClearSelection
    Form.Grids("CounterParameters").Properties("Name").Selected    = 1
    Form.Grids("CounterParameters").Properties("Value").Selected   = 2
    Form.Grids("CounterParameters").Properties("Kind").Selected    = 3
    
    Form.Grids("CounterParameters").Properties("Name").Caption  = FrameWork.GetDictionary("TEXT_COUNTER_ARGUMENT")
    Form.Grids("CounterParameters").Properties("Value").Caption = FrameWork.GetDictionary("TEXT_COUNTER_VALUE")
    Form.Grids("CounterParameters").Properties("Kind").Caption  = "&nbsp;"
    
    Form.Grids("CounterParameters").Visible = true
  Else
    Form.Grids("CounterParameters").Visible = false
  end if

  Form.Grids("CounterParameters").DefaultCellClass = "TableCell"
  Form.Grids("CounterParameters").DefaultCellClassAlt = "TableCellAlt"
    
  Service.Properties("CounterTypeTitle") = COMObject.Instance.formula(3)
  Service.Properties("CounterTypeInformation") = COMObject.Instance.Type.description
  
  RefreshCounterTypeInformation = TRUE
     
END FUNCTION

PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean

'Exit FUNCTION
  'response.write("PT PARAMTABLEID[" & Request("PARAMTABLEID") & "]<BR>")
  'response.write("PRICELIST PICKERIDS[" & Request("PICKERIDS") & "]<BR>")

'c.SetParameter param_name, "ChangedValue"
  
  if UCase(Request("PickerSetCounterParam")) = "TRUE" then 
    'response.write("PickerSetCounterParam<BR>")
    dim strValue
    strValue = Session("ProductViewPropertyPicker_Name")
    
    if Session("ProductViewPropertyPicker_PropertyName")<>"" then
      strValue = strValue & "/" & Session("ProductViewPropertyPicker_PropertyName")
    end if

    COMObject.Instance.GetParameter(Request("PARAMNAME")).Value = strValue
  end if
  
  RefreshCounterTypeInformation     
 
  Form_Refresh = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: SetMSIXPropertyTypeToProrateOnEnumType
' PARAMETERS		:
' DESCRIPTION 	: Set the objMSIXProperty type to enum type Usage Kind.
'                 Because the enum type does not exist yet I hard code the values.
' RETURNS			  :
PUBLIC FUNCTION SetMSIXPropertyTypeCounterType(objMSIXProperty,objMTProductCatalog)
  
  Dim Types, ct, objEnumType
  Set types = objMTProductCatalog.GetCounterTypes
  Set objEnumType = mdm_CreateObject(CVariables)    

  For each ct in types
    objEnumType.Add ct.ID, ct.ID, , , ct.Name ' Name comes back localized
  Next
  
  objMSIXProperty.AddValidListOfValues  objEnumType ' Associate the Cvariables object to the MSIX Properties    
  
  SetMSIXPropertyTypeCounterType = TRUE

END FUNCTION
 
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

'COMObject.Instance.Name = COMObject.Properties("Name")
	COMObject.Instance.Description = Service.Properties("Description").Value

	dim objMTProductCatalog
	Set objMTProductCatalog = GetProductCatalogObject
	dim intDiscountId
	intDiscountId = Form("PI_ID")

	dim objDiscount
	set objDiscount = objMTProductCatalog.GetPriceableItem(intDiscountId)

	dim intCPDId
	intCPDId = Form("CPD_ID")


	if Form("NEW_COUNTER") = true then

		COMObject.Log "Counter.ViewEdit.asp: Adding new counter to Discount[" & intDiscountId & "] and CPD [" & intCPDId & "]"
		
		On Error Resume Next
		objDiscount.SetCounter intCPDId, COMObject.Instance
		ConfigureDiscountDistributionCounter objDiscount, COMObject.Instance
		objDiscount.Save
		If(Err.Number)Then
			EventArg.Error.Save Err
			OK_Click = FALSE
			Err.Clear
			'COMObject.Log "COUNTER: ERROR Saving"
		Else
			COMObject.Log "COUNTER: SAVED"
			OK_Click = TRUE
		End If    
	else
		
		COMObject.Log "Counter.ViewEdit.asp: Saving existing counter"

		On Error Resume Next
		objDiscount.SetCounter intCPDId, COMObject.Instance
		ConfigureDiscountDistributionCounter objDiscount, COMObject.Instance
		'COMObject.Instance.Save
		objDiscount.Save
		If(Err.Number)Then

			EventArg.Error.Save Err
			OK_Click = FALSE
			Err.Clear
			COMObject.Log "COUNTER: ERROR Saving"
		Else
			COMObject.Log "COUNTER: SAVED"
			OK_Click = TRUE
		End If    
	end if
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Sets currency code after selection
PRIVATE FUNCTION  ConfigureDiscountDistributionCounter(objDiscount, objCounter) ' As Boolean
	
	ConfigureDiscountDistributionCounter = FALSE
	
	If not objDiscount.GetDistributionCounter Is Nothing then
		If objDiscount.GetDistributionCounter.ID = objCounter.ID and Service.Properties("DiscountDistributionCheck").value = false then
			objDiscount.SetDistributionCounter(Nothing)
		ElseIf Service.Properties("DiscountDistributionCheck").value then
			objDiscount.SetDistributionCounter(objCounter)
		end if
	Else
		If Service.Properties("DiscountDistributionCheck").value then
			objDiscount.SetDistributionCounter(objCounter)
		End IF
	End If
	
	ConfigureDiscountDistributionCounter = TRUE
	
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ChargeInAdvance_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Sets currency code after selection
PRIVATE FUNCTION  TypeID_Click(EventArg) ' As Boolean
    dim objType
    dim objMTProductCatalog
    Set objMTProductCatalog = GetProductCatalogObject
    set objType = objMTProductCatalog.GetCounterType(Service.Properties("TypeID").Value)
    
    'response.write("type [" & typename(objType) & "]<BR>")
    'response.end
    
    COMObject.Instance.Type = objType
    'COMObject.Instance.Save
    COMObject.Log "RUDI COUNTER: Changed type to [" & Service.Properties("TypeID").Value & "] and SAVED"
    
    'COMObject.Instance.TypeID =  Service.Properties("TypeID").Value
    RefreshCounterTypeInformation
    TypeID_Click = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : CounterParameters_DisplayCell
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION CounterParameters_DisplayCell(EventArg) ' As Boolean

    Dim intKind
    Dim objPreProcessor

    'response.write  EventArg.Grid.SelectedProperty.Name & "<br>"
    
    Select Case lcase(EventArg.Grid.SelectedProperty.Name)
    
        'Case "name"
        
        Case "value"
        
            intKind = CLng(EventArg.Grid.Rowset.Value("kind"))
            if intKind = CounterType_PARAM_CONST then
              EventArg.HTMLRendered = "<td class='" & EventArg.Grid.CellClass & "'>"  & "<input type='text' value='" & EventArg.Grid.Rowset.Value("value") & "'>" & "</td>"
            else
              EventArg.HTMLRendered = "<td class='" & EventArg.Grid.CellClass & "'>"  & EventArg.Grid.Rowset.Value("value") & "</td>"
            end if
            
        Case "kind"
            Set objPreProcessor = mdm_CreateObject(CPreProcessor)
            intKind             = CLng(EventArg.Grid.Rowset.Value("kind"))
            
            If (intKind <> CounterType_PARAM_CONST) Then
                
                ' Build a small csv string (Kind and name counter) which is associated to each edit counter button so when we click 
                ' on any edit counter button we have information on which button to edit...
                objPreProcessor.Add "INFO" , Cstr ( intKind & "," & EventArg.Grid.Rowset.Value("name") )
								
								if (EventArg.Grid.Rowset.Value("ReadOnly")) then
									EventArg.HTMLRendered = objPreProcessor.Process("<td class='" & EventArg.Grid.CellClass & "'><button class='clsButtonBlueMedium' name='EditCounter' OnClick='mdm_RefreshDialogUserCustom(this,""[INFO]"");' style='vertical-align: middle;' disabled>[TEXT_EDIT_COUNTER_PARAMETER]&nbsp;</button></td>")								
								else
									EventArg.HTMLRendered = objPreProcessor.Process("<td class='" & EventArg.Grid.CellClass & "'><button class='clsButtonBlueMedium' name='EditCounter' OnClick='mdm_RefreshDialogUserCustom(this,""[INFO]"");' style='vertical-align: middle;'>[TEXT_EDIT_COUNTER_PARAMETER]&nbsp;<IMG align=middle alt='' border=0 src='/mcm/default/localized/us/images/icons/arrowSelect.gif'></button></td>")
								end if
            Else
                EventArg.HTMLRendered = "<td class='" & EventArg.Grid.CellClass & "'>" & EventArg.Grid.Rowset.RecordCount & "<button>Select</button></td>"
            End If
            
        Case Else
           CounterParameters_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")           
    End Select
        
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : EditCounter_Click
' PARAMETERS		  :
' DESCRIPTION     :
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION EditCounter_Click(EventArg)

    'Form.JavaScriptInitialize = Form("EditCounter.OpenDialog.JavaScript")
    Dim arrValue,objPreProcessor
    
    Set objPreProcessor = mdm_CreateObject(CPreProcessor)
    
    arrValue = Split(mdm_UIValue("mdmUserCustom"),",")
    
    objPreProcessor.Add "INTKIND"   , arrValue(0)
    objPreProcessor.Add "PARAMNAME" , arrValue(1)
    
    Form.JavaScriptInitialize = objPreProcessor.Process("javascript:window.open('ProductviewPropertyPicker.asp?Kind=[INTKIND]&AUTOMATIC=FALSE&MonoSelect=True&IDColumnName=nm_name&Parameters=PickerSetCounterParam|TRUE;PARAMNAME|[PARAMNAME]', '_blank', 'height=100,width=100, resizable=yes, scrollbars=yes,'); return false;")
    
'    response.write Form.JavaScriptInitialize 
 '   response.end
    
    EditCounter_Click = TRUE
END FUNCTION

%>


