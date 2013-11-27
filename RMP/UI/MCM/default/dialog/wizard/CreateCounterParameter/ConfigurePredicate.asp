<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: ConfigurePredicate.asp$
' 
'  Copyright 1998,2000,2001,2002 by MetraTech Corporation
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
'  Created by: Kevin A. Boucher
' 
'  $Date: 1/02/02 12:00:08 PM$
'  $Author: Kevin A. Boucher$
'  $Revision: 1$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../../../MCMIncludes.asp" -->
<%
    
Form.Version        = MDM_VERSION     ' Set the dialog version
Form.RouteTo        = Session("LastRolePage")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Dim bReturn 
	Dim objProductCatalog
  Dim PIType
  
  Service.Properties.Clear()
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
  Form("Update") = request.QueryString("Update")
  
  ' Save product view object in form
  Set objProductCatalog = GetProductCatalogObject
  Set PIType = objProductCatalog.GetPriceableItemTypeByName(Session("CounterParameter" & "_PIType"))
  Set Form("objProductView") = PIType.GetProductViewObject()
  
  Form("InitialTemplate") = Form.HTMLTemplateSource  ' Save the initial template so we can use it to render a new dynamic template later
  
  bReturn = DynamicTemplate(EventArg) ' Load the dynamic template for the dialog
		
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation

  Form_Initialize = bReturn
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  DynamicTemplate
' PARAMETERS:  EventArg
' DESCRIPTION:  This function determines what should be placed in the dialog template
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION DynamicTemplate(EventArg)
  Dim objProductCatalog
  Dim objPredicate
  Dim objDyn
	Dim strHTML
  Dim nCount
  Dim PIType
  Dim colProperties
  Dim prop
  
  on error resume next

  ' Setup initial template
  Form.HTMLTemplateSource = Form("InitialTemplate")
	
  If session("CounterParameter" & "_MTCounterParameter").Predicates.Count = 0 Then
    strHTML = "No conditions have been setup.<br>"		
  Else

     nCount = 0
     
     For Each objPredicate in session("CounterParameter" & "_MTCounterParameter").Predicates
     			
        ' Add Productview property
        Service.Properties.Add "PRODUCTVIEWPROPERTY" & nCount, "ENUM", 0, TRUE, ""
        Set objDyn = mdm_CreateObject(CVariables)
        Set objProductCatalog = GetProductCatalogObject
        Set PIType = objProductCatalog.GetPriceableItemTypeByName(Session("CounterParameter" & "_PIType"))
        Set colProperties = PIType.GetProductViewObject().GetProperties()
        For Each prop in colProperties
           objDyn.Add prop.DN , prop.DN , , , prop.DN 
        Next          
        Service.Properties("PRODUCTVIEWPROPERTY" & nCount).AddValidListOfValues objDyn	
        Service.Properties("PRODUCTVIEWPROPERTY" & nCount).Value = objPredicate.ProductViewProperty.DN
        
        ' Add operator
        Service.Properties.Add "OPERATOR" & nCount, "String", 0, TRUE, ""
        Set objDyn = mdm_CreateObject(CVariables)					
        objDyn.Add "equal", MTDECIMALCAPABILITY_OPERATOR_TYPE_EQUAL, , , "="
        objDyn.Add "notequal", MTDECIMALCAPABILITY_OPERATOR_TYPE_NOT_EQUAL, , , "&lt;&gt;"
        objDyn.Add "greater", MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER, , , "&gt;"
        objDyn.Add "greaterequal", MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER_EQUAL, , , "&gt;="
        objDyn.Add "less", MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS, , , "&lt;"																														
        objDyn.Add "lessequal", MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS_EQUAL, , , "&lt;="																														
        Service.Properties("OPERATOR" & nCount).AddValidListOfValues objDyn	
        Service.Properties("OPERATOR" & nCount).Value = objPredicate.Operator
        
        strHTML = strHTML & "<tr>"
        strHTML = strHTML & "  <td nowrap class='clsStandardText'>"
        strHTML = strHTML & "    <SELECT onChange='mdm_RefreshDialogUserCustom(""PropertySwitch"",""" & nCount & """);' class='fieldRequired' name='PRODUCTVIEWPROPERTY" & nCount & "'></SELECT>"
        strHTML = strHTML & "    <SELECT class='fieldRequired' name='OPERATOR" & nCount & "'></SELECT>"          

        ' Add value
        Service.Properties.Add "VALUE" & nCount, "String", 255, TRUE, ""
        Select Case objPredicate.ProductViewProperty.PropertyType
          Case 8 ' MSIX_TYPE_ENUM
            Dim strName
  				  Dim strNameSpace

	  				strNameSpace = objPredicate.ProductViewProperty.EnumNamespace
		  			strName = objPredicate.ProductViewProperty.EnumEnumeration
                    
			  		Service.Properties("VALUE" & nCount).SetPropertyType "ENUM", strNameSpace, strName
          
            strHTML = strHTML & "    <SELECT class='fieldRequired' name='Value" & nCount & "'></SELECT>"          
          Case Else
            strHTML = strHTML & "    <INPUT  class='fieldRequired' name='Value" & nCount & "' type='text'>"   
        End Select
        Service.Properties("VALUE" & nCount).Value = objPredicate.Value

    		strHTML = strHTML & "	   <button onclick='mdm_RefreshDialogUserCustom(this,""" & nCount & """);' name='Remove' Class='clsButtonBlueSmall'>Remove</button>"
		    strHTML = strHTML & "  </td>"
        strHTML = strHTML & "</tr>"
          
        nCount = nCount + 1                        
     Next           			
	End If
  
  ' Display Add button
  strHTML = strHTML & "<tr>"
  strHTML = strHTML & "	 <td><button onclick='mdm_RefreshDialog(this)' name='AddCondition' Class='clsButtonBlueSmall'><MDMLABEL Name='TEXT_ADD'>Add</MDMLABEL></button></td>"
  strHTML = strHTML & "</tr>"  

  
	Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<DYNAMIC_TEMPLATE />", strHTML)
  
  DynamicTemplate = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Refresh
' PARAMETERS:  EventArg
' DESCRIPTION:  Loads the DynamicTemplate using the initial saved template
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Refresh(EventArg) ' As Boolean
	Form_Refresh = DynamicTemplate(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION: AddCondition_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION AddCondition_Click(EventArg) ' As Boolean
  Dim objProductView  
  Dim objPredicate

	Call SyncToScreen()
  
  Set objProductView = session("CounterParameter" & "_ProductViewCatalog").GetProductViewByName("metratech.com/" & session("CounterParameter" & "_PIType"))	
  Set objPredicate = session("CounterParameter" & "_MTCounterParameter").CreatePredicate()

  ' Add blank predicate 
  objPredicate.ProductViewProperty = objProductView.GetProperties.item(0)
  objPredicate.Operator = 3
  'objPredicate.Value = "blah"

	AddCondition_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Remove_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Remove_Click(EventArg) ' As Boolean
	
	Form("RemoveID") = mdm_UIValue("mdmUserCustom")
	
	Call SyncToScreen()
		
  ' Make sure to clear the service properties
	Do while Service.Properties.count
	  Service.Properties.Remove(1)
	Loop
		
	' Remove condition
  session("CounterParameter" & "_MTCounterParameter").RemoveConditionAt(Form("RemoveID"))
		
	Remove_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  PropertySwitch
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION PropertySwitch_Click(EventArg) ' As Boolean
	
	Form("PropertyID") = mdm_UIValue("mdmUserCustom")
  
  If Form("objProductView").GetPropertyByName(Service.Properties("PRODUCTVIEWPROPERTY" & Form("PropertyID")).Value).PropertyType = 8 Then
    Service.Properties("VALUE" & Form("PropertyID")).SetPropertyType "ENUM",  Form("objProductView").GetPropertyByName(Service.Properties("PRODUCTVIEWPROPERTY" & Form("PropertyID")).Value).EnumNamespace, Form("objProductView").GetPropertyByName(Service.Properties("PRODUCTVIEWPROPERTY" & Form("PropertyID")).Value).EnumEnumeration
    Service.Properties("VALUE" & Form("PropertyID")).Value = Service.Properties("VALUE" & Form("PropertyID")).EnumType.Entries(1).Value
  Else
    Service.Properties("VALUE" & Form("PropertyID")).Value = ""
  End If  
	Call SyncToScreen()

	PropertySwitch_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  SyncToScreen
' PARAMETERS:  EventArg
' DESCRIPTION:  Ensures that our in memory objects look like the screen
' RETURNS:  Return TRUE if ok else FALSE
Function SyncToScreen()
     Dim nCount
     Dim objPredicate
     
     nCount = 0
     
     For Each objPredicate in Session("CounterParameter" & "_MTCounterParameter").Predicates
        
        objPredicate.ProductViewProperty = Form("objProductView").GetPropertyByName(Service.Properties("PRODUCTVIEWPROPERTY" & nCount).Value)
        objPredicate.Operator            = CLng(Service.Properties("OPERATOR" & nCount).Value)
        objPredicate.Value               = Service.Properties("VALUE" & nCount).Value
     
        nCount = nCount + 1
     Next
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
  On Error Resume Next

  Call SyncToScreen()

	If(CBool(Err.Number = 0)) then
      On Error Goto 0

      response.write "<script language=""Javascript"">"
    	response.write "  window.opener.location = (window.opener.location);" 
      response.write "  window.close();"
      response.write "</script>"
      response.end

      OK_Click = TRUE
  Else        
      EventArg.Error.Save Err  
      OK_Click = FALSE
  End If
END FUNCTION

%>

