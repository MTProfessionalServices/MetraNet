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
' NAME		        : MCM - MetraTech Catalog Manager - VBScript Library
' VERSION	        : 1.0
' CREATION_DATE   : 4/6/2001
' AUTHOR	        : UI Team
' DESCRIPTION	    : 
' ----------------------------------------------------------------------------------------------------------------------------------------



'-----------------------------------------------------------------------------
' FUNCTION 			:  
' PARAMETERS		:  
' DESCRIPTION 	: 
' RETURNS			  : 
' 
PUBLIC FUNCTION mcm_GetPricelistXML(idPricelist)

  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject

  Set objMTPricelist = objMTProductCatalog.GetPriceList(idPricelist) 'Form("ID"))

  if true then
    dim objRenderXml
    set objRenderXml = Server.CreateObject("MetraTech.UI.ProductCatalogXml.RenderXML")
    mcm_GetPricelistXML = objRenderXml.GetPricelistXML((objMTPricelist))
    exit function
  else

  dim sXML
  sXML = sXML & "<pricelist>" & vbNewLine
  sXML = sXML & "    <id>" & objMTPricelist.id & "</id>" & vbNewLine
  sXML = sXML & "    <name>" & objMTPricelist.Name & "</name>" & vbNewLine
  'sXML = sXML & "    <displayname>" & objMTPricelist.DisplayName & "</displayname>" & vbNewLine
  sXML = sXML & "    <description>" & objMTPricelist.Description & "</description>" & vbNewLine

  

    dim objRowset
    set objRowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	objRowset.Init "queries\mcm"
  	objRowset.SetQueryTag("__SELECT_PRICEABLE_ITEMS_ON_PRICELIST__")  
    objRowset.AddParam "%%ID_PRICELIST%%", Clng(idPricelist)

    'rowset.SetQueryString("select * from t_acc_usage")
    'rowset.SetQueryString("select au.id_view as 'View Id', d.tx_desc as 'View Name', count(*) as 'Count', sum(au.amount) as 'Amount' from t_acc_usage au join t_description d on au.id_view = d.id_desc and d.id_lang_code =840 group by au.id_view,d.tx_desc")
    dim sSQL
    'sSQL = "select map.id_pi_template as 'id_pi_template',left(bp2.nm_display_name,40) as 'PiDisplayName',bp2.nm_name as 'PiName', map.id_paramtable as 'id_paramtable',left(bp1.nm_display_name,40) as 'PtDisplayName', bp1.nm_name as 'PtName' from t_pl_map map"
    'sSQL = sSQL & " join t_base_props bp1 on map.id_paramtable=bp1.id_prop"
    'sSQL = sSQL & " join t_base_props bp2 on map.id_pi_template=bp2.id_prop"
    'sSQL = sSQL & "where id_pricelist=" & idPricelist
    sSQL = "select rs.id_pi_template as 'id_pi_template',left(bp2.nm_display_name,40) as 'PiDisplayName',bp2.nm_name as 'PiName', rs.id_pt as 'id_pt',left(bp1.nm_display_name,40) as 'PtDisplayName', bp1.nm_name as 'PtName'"
    sSQL = sSQL & " from t_rsched rs"
    sSQL = sSQL & " join t_base_props bp1 on rs.id_pt=bp1.id_prop"
    sSQL = sSQL & " join t_base_props bp2 on rs.id_pi_template=bp2.id_prop"
    sSQL = sSQL & " where rs.id_pricelist=" & idPricelist
    sSQL = sSQL & " group by  rs.id_pi_template,left(bp2.nm_display_name,40),bp2.nm_name , rs.id_pt , left(bp1.nm_display_name,40) , bp1.nm_name"
    sSQL = sSQL & " order by id_pi_template, id_pt"

    'objRowset.SetQueryString(sSQL)
  	objRowset.Execute

    'response.write("There are " & objRowset.recordcount & " rate schedules on this pricelist<br>")
    
    
    dim id_paramtable
    dim id_pi_template
    
    dim id_current_pi
    id_current_pi = 0
    do while not cbool(objRowset.EOF)
    		id_paramtable = objRowset.value("id_pt")
        id_pi_template = objRowset.value("id_pi_template")
        
        if id_pi_template<>id_current_pi then
          if id_current_pi<>0 then
            'Close previous pi
             sXML = sXML & "</priceableitem>"
          end if
            id_current_pi=id_pi_template
            sXML = sXML & "<priceableitem>"
            sXML = sXML & "    <id>"          & id_pi_template & "</id>" & vbNewLine
            sXML = sXML & "    <name>"        & objRowset.value("PiName") & "</name>" & vbNewLine
            sXML = sXML & "    <displayname>" & objRowset.value("PiDisplayName") & "</displayname>" & vbNewLine
        end if         

        'id_pi_template PiDisplayName          PiName     
        sXML = sXML & "<rateschedule>"
            sXML = sXML & "    <paramtable_id>"          & id_paramtable & "</paramtable_id>" & vbNewLine
            sXML = sXML & "    <paramtable>"        & objRowset.value("PtName") & "</paramtable>" & vbNewLine
            sXML = sXML & "    <paramtable_displayname>" & objRowset.value("PtDisplayName") & "</paramtable_displayname>" & vbNewLine
        sXML = sXML & "</rateschedule>"            
   			'response.write(" Param Table [" & id_paramtable & "] Priceable Item [" & id_pi_template & "]<BR>")
  		  'Set objParamTableDef = objMTProductCatalog.GetParamTableDefinition(id_paramtable)
        'response.write(objParamTableDef.ID & "<BR>")
  		  'Set objMTRateSched = objParamTableDef.GetRateSchedule(id_rateschedule)
        'Set objNewMTRateSched = objMTRateSched.CreateCopy
        'objNewMTRateSched.PricelistId = id_pricelist_new
        'objNewMTRateSched.SaveWithRules
    objRowset.MoveNext
    loop
    
    if id_current_pi<>0 then
      'Close previous pi
      sXML = sXML & "</priceableitem>"
    end if
          
    sXML = sXML & "</pricelist>" & vbNewLine
    
    mcm_GetPricelistXML = sXML
    
    end if
    
END FUNCTION


function mcm_GetProductOfferingXML(id)
  Dim strBuffer
  Dim objMTProductOffering
  Dim objPriceableItemRowset
  
  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject

  Set objMTProductOffering  = objMTProductCatalog.GetProductOffering(id) 'Form("ID"))

  if true then
    dim objRenderXml
    set objRenderXml = Server.CreateObject("MetraTech.UI.ProductCatalogXml.RenderXML")
    mcm_GetProductOfferingXML = objRenderXml.GetProductOfferingXML((objMTProductOffering))
    exit function
  else
    strBuffer = strBuffer & "<productoffering>" & vbNewLine
    strBuffer = strBuffer & "    <id>" & objMTProductOffering.id & "</id>" & vbNewLine
    strBuffer = strBuffer & "    <name>" & objMTProductOffering.Name & "</name>" & vbNewLine
    strBuffer = strBuffer & "    <displayname>" & objMTProductOffering.DisplayName & "</displayname>" & vbNewLine
    strBuffer = strBuffer & "    <description>" & objMTProductOffering.Name & "</description>" & vbNewLine
  
    Set objPriceableItemRowset = objMTProductOffering.GetPriceableItemsAsRowset()
    call GetProductOfferingPriceableItemsXML(objPriceableItemRowset,strBuffer,true,objMTProductOffering.NonSharedPriceListID,objMTProductCatalog)
    
    strBuffer = strBuffer & "</productoffering>" & vbNewLine
  
    mcm_GetProductOfferingXML = strBuffer
  end if
  
end function

function GetProductOfferingPriceableItemsXML(objPriceableItemRowset,strBuffer,bTopLevel,idNonSharedPriceListForPO, objMTProductCatalog)
  
  dim i,iKind,id
  dim objMTPriceableItem, objChildPriceableItemRowset

  strBuffer = strBuffer & "    <priceableitems>" & vbNewLine
  
  for i=0 to objPriceableItemRowset.RecordCount-1
    '//Properties are different depending on if the list came from the PO or a PI... UUUGGGGHHH!
    if bTopLevel then
      id = objPriceableItemRowset.value("id_prop")
    else
      id = objPriceableItemRowset.value("id_pi_instance")
    end if
    
    iKind=CLng(objPriceableItemRowset.value("n_kind"))
    
    strBuffer = strBuffer & "      <priceableitem>" & vbNewLine
    strBuffer = strBuffer & "        <id>" & id & "</id>" & vbNewLine
    'strBuffer = strBuffer & "    <type>" & objPriceableItemRowset.value("id_pi_type") & "</type>" & vbNewLine
    'strBuffer = strBuffer & "    <template>" & objPriceableItemRowset.value("id_pi_template") & "</template>" & vbNewLine  
    strBuffer = strBuffer & "        <name>" & objPriceableItemRowset.value("nm_name") & "</name>" & vbNewLine
    strBuffer = strBuffer & "        <displayname>" & objPriceableItemRowset.value("nm_display_name") & "</displayname>" & vbNewLine
    strBuffer = strBuffer & "        <description>" & objPriceableItemRowset.value("nm_desc") & "</description>" & vbNewLine
    strBuffer = strBuffer & "        <kind>" & iKind & "</kind>" & vbNewLine
    
  '  if iKind=10 or iKind=15 then
      set objMTPriceableItem = objMTProductCatalog.GetPriceableItem(id)
      set objChildPriceableItemRowset = objMTPriceableItem.GetChildrenAsRowset()
    
      call GetProductOfferingPriceableItemsXML(objChildPriceableItemRowset,strBuffer,false,idNonSharedPriceListForPO,objMTProductCatalog)
  '  end if
    
    'ok - let's go deeper and get the GetNonICBPriceListMappingsAsRowset and make links to the rates
    If IsValidObject(objMTPriceableItem) Then
        strBuffer = strBuffer & "      <pricelistmappings>" & vbNewLine
        Dim objPriceListMappingsRowset, j
        set objPriceListMappingsRowset = objMTPriceableItem.GetNonICBPriceListMappingsAsRowset()
        'strBuffer = strBuffer & "    <divid>" & id & "</divid>" & vbNewLine
        for j=0 to objPriceListMappingsRowset.RecordCount - 1
            strBuffer = strBuffer & "      <pricelistmapping>" & vbNewLine
'            If IsNull(objPriceListMappingsRowset.value("tpl_nm_name")) Then
'              strBuffer = strBuffer & "    <warning>" & "y" & "</warning>" & vbNewLine
'            else
'              strBuffer = strBuffer & "    <warning>" & "n" & "</warning>" & vbNewLine              
'            End If

            'strBuffer = strBuffer & "    <pi_id>"          & id & "</pi_id>" & vbNewLine
            strBuffer = strBuffer & "        <paramtable_id>"          & objPriceListMappingsRowset.value("id_paramtable") & "</paramtable_id>" & vbNewLine
            strBuffer = strBuffer & "        <paramtable_name>"     & objPriceListMappingsRowset.value("tpt_nm_name") & "</paramtable_name>" & vbNewLine        
            '//Override default displayname in case it was not specified
            dim sDisplayName
            sDisplayName = objPriceListMappingsRowset.value("nm_display_name") '& " - " & objPriceListMappingsRowset.value("tpt_nm_name")
            if IsNull(sDisplayName) then
              sDisplayName = ""
            end if            
            if len(ltrim(sDisplayName))=0 then
              sDisplayName = objPriceListMappingsRowset.value("tpt_nm_name")
            end if
            strBuffer = strBuffer & "        <paramtable_displayname>" & sDisplayName & "</paramtable_displayname>" & vbNewLine        
            
            strBuffer = strBuffer & "        <pricelist_id>"    & objPriceListMappingsRowset.value("id_pricelist") & "</pricelist_id>" & vbNewLine              

            if (len(objPriceListMappingsRowset.value("tpl_nm_name"))>0) then
              strBuffer = strBuffer & "        <pricelist_name>"      & objPriceListMappingsRowset.value("tpl_nm_name") & "</pricelist_name>" & vbNewLine              
            end if
            
            if (objPriceListMappingsRowset.value("id_pricelist")=idNonSharedPriceListForPO) then
              strBuffer = strBuffer & "        <nonsharedpricelist>"     & "TRUE" & "</nonsharedpricelist>" & vbNewLine        
            else
              strBuffer = strBuffer & "        <nonsharedpricelist>"     & "FALSE" & "</nonsharedpricelist>" & vbNewLine        
            end if

            if (objPriceListMappingsRowset.value("b_canICB")="Y") then
              strBuffer = strBuffer & "        <allowicb>"     & "TRUE" & "</allowicb>" & vbNewLine        
            else
              strBuffer = strBuffer & "        <allowicb>"     & "FALSE" & "</allowicb>" & vbNewLine        
            end if
            
            'strBuffer = strBuffer & "    <canicb>"         & objPriceListMappingsRowset.value("b_canICB") & "</canicb>" & vbNewLine

            strBuffer = strBuffer & "      </pricelistmapping>"& vbNewLine        
            objPriceListMappingsRowset.MoveNext
        next
    
        strBuffer = strBuffer & "      </pricelistmappings>" & vbNewLine
    End If

          
    strBuffer = strBuffer & "      </priceableitem>" & vbNewLine
   
    objPriceableItemRowset.MoveNext
  next

  strBuffer = strBuffer & "    </priceableitems>" & vbNewLine
  
  GetProductOfferingPriceableItemsXML=true
end function

function mcm_GetUsagePriceableItemsXML()
  dim objMTFilter
  Set objMTFilter = mdm_CreateObject(MTFilter)

          '// Ugly hack because usage can be kind = 10 or kind = 15 and filter does not do 'or'
        '// Thank you, DeMorgan, may you rest in peace
        '// Who is DeMorgan? Fred!
        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_RECURRING)
        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_NON_RECURRING)
        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_DISCOUNT)
        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_RECURRING_UNIT_DEPENDENT)

  mcm_GetUsagePriceableItemsXML = mcm_GetPriceableItemsXML(objMTFilter)
end function

function mcm_GetRecurringChargePriceableItemsXML()
  dim objMTFilter
  Set objMTFilter = mdm_CreateObject(MTFilter)

        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_USAGE)
        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_NON_RECURRING)
        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_DISCOUNT)
        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_USAGE_AGGREGATE)

  mcm_GetRecurringChargePriceableItemsXML =  mcm_GetPriceableItemsXML(objMTFilter)
end function

function mcm_GetNonRecurringChargePriceableItemsXML()
  dim objMTFilter
  Set objMTFilter = mdm_CreateObject(MTFilter)
  objMTFilter.Add "Kind", OPERATOR_TYPE_EQUAL, CLng(PI_TYPE_NON_RECURRING)

  mcm_GetNonRecurringChargePriceableItemsXML = mcm_GetPriceableItemsXML(objMTFilter)
end function

function mcm_GetDiscountPriceableItemsXML()
  dim objMTFilter
  Set objMTFilter = mdm_CreateObject(MTFilter)
  objMTFilter.Add "Kind", OPERATOR_TYPE_EQUAL, CLng(PI_TYPE_DISCOUNT)

  mcm_GetDiscountPriceableItemsXML = mcm_GetPriceableItemsXML(objMTFilter)
end function

function mcm_GetPriceableItemsXML(objMTFilter)

   dim strBuffer
   
  if true then
    dim objRenderXml
    set objRenderXml = Server.CreateObject("MetraTech.UI.ProductCatalogXml.RenderXML")
    mcm_GetPriceableItemsXML = objRenderXml.GetPriceableItemsXML((objMTFilter))
    exit function
  else

   Dim objMTProductCatalog 
   Set objMTProductCatalog = GetProductCatalogObject

   'dim objMTFilter
   'Set objMTFilter = mdm_CreateObject(MTFilter)

   dim objRowset
   set objRowset = objMTProductCatalog.FindPriceableItemsAsRowset(objMTFilter)

   'response.write("There are [" & objRowset.RecordCount & "] priceable items")

'writeRowsetNameValueTable objRowset
'response.end
   call GetPriceableItemsXML(objRowset,strBuffer,true, objMTProductCatalog)

   mcm_GetPriceableItemsXML = strBuffer
   end if

end function

function GetPriceableItemsXML(objPriceableItemRowset,strBuffer,bTopLevel, objMTProductCatalog)
  
  dim i,iKind,id
  dim objPriceableItem, objChildPriceableItemRowset

  strBuffer = strBuffer & "<priceableitems>" & vbNewLine

  for i=0 to objPriceableItemRowset.RecordCount-1
    '//Properties are different depending on if the list came from the PO or a PI... UUUGGGGHHH!
    if bTopLevel then
      id = objPriceableItemRowset.value("id_prop")
    else
      id = objPriceableItemRowset.value("id_template")
    end if
    
    iKind=CLng(objPriceableItemRowset.value("n_kind"))
    
    strBuffer = strBuffer & "  <priceableitem>" & vbNewLine
    strBuffer = strBuffer & "    <id>" & id & "</id>" & vbNewLine
    'strBuffer = strBuffer & "    <type>" & objPriceableItemRowset.value("id_pi_type") & "</type>" & vbNewLine
    'strBuffer = strBuffer & "    <template>" & objPriceableItemRowset.value("id_pi_template") & "</template>" & vbNewLine  
    strBuffer = strBuffer & "    <name>" & objPriceableItemRowset.value("nm_name") & "</name>" & vbNewLine
    strBuffer = strBuffer & "    <displayname>" & objPriceableItemRowset.value("nm_display_name") & "</displayname>" & vbNewLine
    strBuffer = strBuffer & "    <description>" & objPriceableItemRowset.value("nm_desc") & "</description>" & vbNewLine
    strBuffer = strBuffer & "    <kind>" & iKind & "</kind>" & vbNewLine
    
  '  if iKind=10 or iKind=15 then
      set objPriceableItem = objMTProductCatalog.GetPriceableItem(id)
      set objChildPriceableItemRowset = objPriceableItem.GetChildrenAsRowset()
    
      call GetPriceableItemsXML(objChildPriceableItemRowset,strBuffer,false,objMTProductCatalog)
  '  end if
    
      dim objPriceableItemType
      set objPriceableItemType = objPriceableItem.PriceableItemType
      
      'response.write("<td><table bgcolor='avacado'>")
      'response.write("There are [" & objPriceableItemType.GetParamTableDefinitions.Count & "] param tables")

      strBuffer = strBuffer & "  <parametertables>" & vbNewLine
 
      dim objParamTable
      for each objParamTable in objPriceableItemType.GetParamTableDefinitions 
        strBuffer = strBuffer & "  <parametertable>" & vbNewLine
            strBuffer = strBuffer & "    <id>"          & objParamTable.id & "</id>" & vbNewLine
            strBuffer = strBuffer & "    <name>"          & objParamTable.name & "</name>" & vbNewLine

            '//Override default displayname in case it was not specified
            dim sDisplayName
            sDisplayName = objParamTable.DisplayName
            if IsNull(sDisplayName) then
              sDisplayName = ""
            end if            
            if len(ltrim(sDisplayName))=0 then
              sDisplayName = objParamTable.name
            end if

            strBuffer = strBuffer & "    <displayname>"          & sDisplayName & "</displayname>" & vbNewLine
        strBuffer = strBuffer & "  </parametertable>" & vbNewLine
      next
      strBuffer = strBuffer & "  </parametertables>" & vbNewLine


          
    strBuffer = strBuffer & "  </priceableitem>" & vbNewLine
   
    objPriceableItemRowset.MoveNext
  next
  strBuffer = strBuffer & "</priceableitems>" & vbNewLine
  
  GetPriceableItemsXML=true
end function

%>
