<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998 - 2002 by MetraTech Corporation
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
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' DIALOG	    : Counter Parameter Edit
' DESCRIPTION	: 
' AUTHOR	    : K. Boucher
' VERSION	    : V3.5
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>

<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
Form.RouteTo        = "ManageDiscountCounters.asp"

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
   
  Form("EditMode") = request.QueryString("EditMode") 

  Dim objMTProductCatalog  
  Dim strHTML
  Dim objPredicate
  Dim objEnumTypeconfig
  
  Set objEnumTypeconfig   = server.CreateObject("Metratech.MTEnumConfig.1")
  
  Set objMTProductCatalog = GetProductCatalogObject
  Set Form("objCounterParameter") = objMTProductCatalog.GetCounterParameter(CLng(request.QueryString("COUNTER_PARAM_ID")))
  
  Service.Properties.Add "Name",        "String", 255, TRUE, Form("objCounterParameter").Name
  Service.Properties.Add "DisplayName", "String", 255, TRUE, Form("objCounterParameter").DisplayName 
  Service.Properties.Add "Group",       "String", 255, TRUE, ""      
  Service.Properties.Add "Description", "String", 255, TRUE, Form("objCounterParameter").Description
  Service.Properties.Add "Value",       "String", 255, TRUE, Form("objCounterParameter").Value

  
  Service.Properties("Name").Caption = "Name"
  Service.Properties("DisplayName").Caption = "Display Name"  
  Service.Properties("Group").Caption = "Group"  
  Service.Properties("Description").Caption = "Description"
  Service.Properties("Value").Caption = "Value"

  Service.Properties("Name").Enabled = FALSE
  Service.Properties("DisplayName").Enabled = FALSE  
  Service.Properties("Group").Enabled = FALSE  
  Service.Properties("Description").Enabled = FALSE
  Service.Properties("Value").Enabled = FALSE
    
  ' List predicates
  If Form("objCounterParameter").Predicates.Count = 0 Then
    strHTML = strHTML & "<tr><td class=""CaptionEW"">There is currently no predicate configured.<br><br></td></tr>"
  Else
      strHTML = strHTML & "<tr><td>Predicate:<br></td></tr>"
      For Each objPredicate in Form("objCounterParameter").Predicates
        strHTML = strHTML & "<tr><td class ='clsWizardPromptOdd'>" & objPredicate.ProductViewProperty.DN 
  			Select Case objPredicate.Operator
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>=" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_NOT_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&lt;&gt;"  
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&gt;" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&gt;=" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&lt;" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&lt;=" 
          End Select          
        If objPredicate.ProductViewProperty.PropertyType = 8 Then
          strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>" & objEnumTypeconfig.GetEnumWithValue(objPredicate.ProductViewProperty.EnumNamespace, objPredicate.ProductViewProperty.EnumEnumeration, objPredicate.value) & "</td></tr>"    
        Else
          strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>" & objPredicate.value & "</td></tr>"            
        End If
      Next
  End If  
        
  mdm_GetDictionary().Add "CONDITIONS_HTML", strHTML
  
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  On Error Resume Next

  Dim objMTCounterParameter
  Dim objProductViewCatalog
  Dim objProductView  
  Dim objPredicate
  
  Set objProductViewCatalog = server.CreateObject("Metratech.ProductViewCatalog")
  Set objMTCounterParameter = server.CreateObject("Metratech.MTCounterParameter")
  Set objProductViewCatalog.SessionContext = FrameWork.SessionContext
  Set objProductView = objProductViewCatalog.GetProductViewByName("metratech.com/audioconfcall")
	
  If UCase(Form("Update")) = "TRUE" Then
    ' UPDATE 

  Else
    ' ADD
    
    ' Parameters
    objMTCounterParameter.Value = "metratech.com/audioconfcall/amount"
    objMTCounterParameter.Name = "Conf Call amount for Bridge1 bridge"
    objMTCounterParameter.Description = "Conf Call amount for Bridge1 bridge"
    objMTCounterParameter.DisplayName = "Conf Call amount for Bridge1 bridge"
    
    ' Parameter Predicates
    Set objPredicate = objMTCounterParameter.CreatePredicate()
    objPredicate.ProductViewProperty = objProductView.GetPropertyByName("SystemName")
    objPredicate.Operator = 3 'EQUALS
    objPredicate.Value = "Bridge1"
  
    objMTCounterParameter.Save
    
  End If
    
	If (Err.Number) Then
	  EventArg.Error.Save Err
	  OK_Click = FALSE
	  Err.Clear
  Else
	  OK_Click = TRUE
  End If    
END FUNCTION

%>
