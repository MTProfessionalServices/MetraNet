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
' AUTHOR	    : Rudi
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE VIRTUAL="/mcm/default/lib/MultiTenancyLib.asp"-->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = true
Form.RouteTo        = FrameWork.GetDictionary("RATES_PRICELIST_LIST_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject    
  
  FrameWork.Dictionary().Add "PLDeleteErrorMode", FALSE
	
  Form.Modal = TRUE   ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will not terminate the dialog
                      ' but do a last rendering/refresh.

  Form("PL_ID") = Request.QueryString("ID")
  dim objPricelist
  set objPricelist = objMTProductCatalog.GetPriceList(Form("PL_ID"))
  'Set COMObject.Instance = objMTProductCatalog.GetPriceList(Form("PL_ID"))
  'COMObject.Properties.Enabled              = FALSE ' Every control is grayed
  'COMObject.Properties("CURRENCYCODE").AddValidListOfValues Array("US$","CH$","DM$")

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
                  
  Service.Properties.Add "NewName"     , "string", 255, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "NewDescription"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "NewCurrency"    , "string", 255, TRUE, "", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "OriginalName"     , "string", 255, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "OriginalDescription"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "OriginalCurrency"      , "string", 3, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ChangeCurrencyOnNewPricelist"      , "boolean", 1, TRUE, FALSE, eMSIX_PROPERTY_FLAG_NONE
  'Service.Properties.Add "InvestigationReasonCode"    , "string", 255, FALSE, "", eMSIX_PROPERTY_FLAG_NONE
  
  Service.Properties("OriginalName").Value   = objPricelist.Name
  Service.Properties("OriginalName").Enabled = FALSE

  Service.Properties("OriginalDescription").Value   = objPricelist.Description
  Service.Properties("OriginalDescription").Enabled = FALSE

  Service.Properties("OriginalCurrency").Value   = objPricelist.CurrencyCode
  Service.Properties("OriginalCurrency").Enabled = FALSE

  Dim newPriceListName
  ' If this is a tenant admin, remove Tenant Prefix before prefixing with "Copy of"
  If Session("isTenantUser") Then
    newPriceListName = FrameWork.GetDictionary("TEXT_WIZARD_COPY_NAME_PREFIX") & " " & Replace(objPricelist.Name, Session("topLevelAccountUserName") + ":", "")
  Else
    newPriceListName = FrameWork.GetDictionary("TEXT_WIZARD_COPY_NAME_PREFIX") & " " & objPricelist.Name
  End If
    
  Service.Properties("NewName").Value   = newPriceListName
  Service.Properties("NewDescription").Value   = objPricelist.Description
  Service.Properties("NewCurrency").SetPropertyType "ENUM","Global/SystemCurrencies","SystemCurrencies"
  'Service.Properties("NewCurrency").Value = objPricelist.CurrencyCode
  
  'Service.Properties("tx_typ_space").AddValidListOfValues "__GET_NAME_SPACE_TYPE_LIST__",,,,mom_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH")
  
    ' We only accept the following chars
  'Service("nm_space").StringID = TRUE
  Service.LoadJavaScriptCode  
  
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

  
  dim id_pricelist_original
  id_pricelist_original = Form("PL_ID")

  dim new_pricelist_name
  new_pricelist_name = Service.Properties("NewName").Value
  
  dim new_pricelist_description
  new_pricelist_description = Service.Properties("NewDescription").Value
  
  dim new_pricelist_currency
  'new_pricelist_currency = Service.Properties("NewCurrency").Value

  if Service.Properties("ChangeCurrencyOnNewPricelist").Value then
    new_pricelist_currency = Service.Properties("NewCurrency").Value
  else
    new_pricelist_currency = Service.Properties("OriginalCurrency").Value
  end if
  
  'mdm_TerminateDialogAndExecuteDialog "PriceList.Copy.Execute.asp?PricelistId=" & Form("PL_ID") & "&NewName=" & Server.UrlEncode(Service.Properties("NewName").Value) & "&NewDescription=" & Server.UrlEncode(Service.Properties("NewDescription").Value) & "&NewCurrency=" & Server.UrlEncode(new_pricelist_currency)
  
'response.write("Original Price List ID [" & id_pricelist_original & "]")
'response.end

  dim id_pricelist_new
  
  Dim objMTProductCatalog, objParamTableDef, objMTRateSched
  Set objMTProductCatalog = GetProductCatalogObject


'Create new pricelist
  Dim objPriceList
  set objPriceList = objMTProductCatalog.CreatePriceList
  
  objPriceList.Name = new_pricelist_name
  objPriceList.Description = new_pricelist_description
  objPriceList.CurrencyCode = new_pricelist_currency
  
  'Currently this indicates that the price list is a regular pricelist and not a ICB specific pricelist
  objPriceList.Shareable = true

  ' If this is a tenant admin, Prefix PL name with Tenant name
  If Session("isTenantUser") Then
    objPriceList.Name = Session("topLevelAccountUserName") + ":" + objPriceList.Name
  End If

  objPriceList.Save
  
  If(Err.Number)Then
      EventArg.Error.Save Err
      OK_Click = FALSE
      exit function
  End If
  
  id_pricelist_new = objPriceList.id
  
  'response.write "Created new pricelist '" & objPriceList.Name & "' with id [" & id_pricelist_new & "]<BR>"
  
  'Create new rateschedules
  dim objRowset
  set objRowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
  
  ' initialize the rowset ...
  objRowset.Init ("\\Reporting")
  
  objRowset.SetQueryString("select * from t_rsched where id_pricelist=" & id_pricelist_original & " order by id_pt")
  
  objRowset.Execute

'writeRowsetNameValueTable objRowset

'response.write("There are " & objRowset.recordcount & " rate schedules to copy for this pricelist<BR>")

  dim id_paramtable
  dim id_rateschedule
  dim objNewMTRateSched
  
    do while not cbool(objRowset.EOF)
    		id_paramtable = objRowset.value("id_pt")
        id_rateschedule = objRowset.value("id_sched")
   			response.write(" Param Table [" & id_paramtable & "] Rate Schedule [" & id_rateschedule & "]<BR>")
  		  Set objParamTableDef = objMTProductCatalog.GetParamTableDefinition(id_paramtable)
  		  Set objMTRateSched = objParamTableDef.GetRateSchedule(id_rateschedule)
        Set objNewMTRateSched = objMTRateSched.CreateCopy
        objNewMTRateSched.PricelistId = id_pricelist_new
        objNewMTRateSched.SaveWithRules
    objRowset.MoveNext
    loop

  If(Err.Number)Then
      EventArg.Error.Save Err
      OK_Click = FALSE
  Else
        Response.Write "<script language=""javascript"" type=""text/javascript"">"
        Response.Write " window.parent.close();"
        Response.Write "</script>"
        Response.End

        OK_Click = TRUE
  End If 
END FUNCTION

' FUNCTION 		    : Cancel_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Cancel_Click(EventArg) ' As Boolean

  
        Response.Write "<script language=""javascript"" type=""text/javascript"">"
        Response.Write " window.parent.close();"
        Response.Write "</script>"
        Response.End

        Cancel_Click = TRUE

END FUNCTION

%>
