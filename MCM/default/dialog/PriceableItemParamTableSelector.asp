<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE FILE="../lib/ProductCatalogXml.asp" -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
  <LINK localized="TRUE" rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/styles.css'>
  <LINK rel="STYLESHEET" type="text/css" href="/mcm/default/localized/en-us/styles/NavStyles.css">
  <LINK rel="STYLESHEET" type="text/css" href="/mcm/default/localized/en-us/styles/ListTabs.css">
	<title>Untitled</title>
</head>
<script type="text/javascript">
  if (document.documentElement.attachEvent)
    document.documentElement.attachEvent('onmousedown', function () {
      event.srcElement.hideFocus = true
    });

      var strBaseImagePath = '/mcm/default/localized/en-us/images/Icons/'; //sectionExpand.gif" width="16" height="16" alt="" border="0">")%>';

      function ToggleRow(strRow, strImage) {
        var strImageHref;

        strImageHref = document.all(strImage).href;

        if(document.all(strRow).style.display == '')
        {
          //Hide the row
          document.all(strRow).style.display = 'none';
          
          //Flip the menu image
          if(strImageHref.indexOf('Expand') > -1)
            document.all(strImage).src = strBaseImagePath + 'sectionContract.gif';
          else
            document.all(strImage).src = strBaseImagePath + 'sectionExpand.gif';
          
        }
        else
        {
          //Show the row
          document.all(strRow).style.display = '';
          
          //Flip the menu image
          if(strImageHref.indexOf('Expand') > -1)
            document.all(strImage).src = strBaseImagePath + 'sectionContract.gif';
          else
            document.all(strImage).src = strBaseImagePath + 'sectionExpand.gif';
        }
      }
      

function onParamTableSelected(idPT, idPI, item)
{
  //If the parent of this IFrame has defined a function for 'onParamTableSelected' then call it, otherwise do nothing
  if (parent.onParamTableSelected)
  {
    //alert('Calling parent onParamTableSelected');
    parent.onParamTableSelected(idPT, idPI, item);
  }
}

function showParamTableSelectorTab(sSelectedTab,element)
{

  hideDIV('ParamTableSelectorUsageTab',true);
  hideDIV('ParamTableSelectorRecurringChargeTab',true);
  hideDIV('ParamTableSelectorNonRecurringChargeTab',true);
  hideDIV('ParamTableSelectorDiscountTab',true);
  
  hideDIV('ParamTableSelector' + sSelectedTab + 'Tab',false);
  
  //Update selected tab
  document.all("current").id=""
  element.parentElement.id="current";
  
}

      function hideDIV(sDivName,bDisable)
      {
        if (bDisable)
          document.all(sDivName).style.display = 'none';
        else
          document.all(sDivName).style.display = '';
      }

</script>
<BODY style="margin:10px 14px 6px 5px;">
<form name='test'>
<!-- Selected Parameter Table: <b><input name='CurrentlySelectedParameterTable'></b> -->
<table border=0>
	<tr class="NavigationPaneItem">
		<td colspan="2" style="padding-left:4px;padding-top:4px;">
			<span id="header">
				<ul>
					<li id="current">
						<a onClick="javascript:showParamTableSelectorTab('Usage',this);" href="javascript:void(0);">	<%=FrameWork.GetDictionary("TEXT_USAGE")%>
						</a>
					</li>
					<li>
						<a onClick="javascript:showParamTableSelectorTab('RecurringCharge',this);" href="javascript:void(0);">	<%=FrameWork.GetDictionary("TEXT_RC")%>
						</a>
					</li>
					<li>
						<a onClick="javascript:showParamTableSelectorTab('NonRecurringCharge',this);" href="javascript:void(0);">	<%=FrameWork.GetDictionary("TEXT_NRC")%>
						</a>
					</li>
					<li>
						<a onClick="javascript:showParamTableSelectorTab('Discount',this);" href="javascript:void(0);"> <%=FrameWork.GetDictionary("TEXT_Discounts")%> 
						</a>
					</li>
				</ul>
			</span>
	</tr>
  </table>
<%
'mdm_Main
'response.write "<form><textarea cols='100' rows='40'>" & strXML & "</textarea></form>"
'response.end

dim objXML, objXSL, strPathXSL, strHTML
Set objXML = server.CreateObject("Microsoft.XMLDOM")
Set objXSL = server.CreateObject("Microsoft.XMLDOM")


'strXML = "<?xml version=""1.0""?>" & vbCRLF & strXML

'response.write "<form><textarea cols='100' rows='40'>" & strXML & "</textarea></form>"
'response.end
'response.write "Done XML [" & Now & "]"

strPathXSL = server.MapPath(Application("APP_HTTP_PATH") & "\default\dialog\xsl\priceableitem.xsl")

'response.write ("Path is [" & strPathXSL & "]<BR>")
'response.end


Call objXSL.Load(strPathXSL)
Call objXSL.LoadXML(mdm_LocalizeString(objXSL.xml))

objXML.setProperty "SelectionLanguage", "XPath"
objXSL.setProperty "SelectionLanguage", "XPath"

dim strXML

strXML = mcm_GetUsagePriceableItemsXML()
'response.write "<form><textarea cols='100' rows='40'>" & strXML & "</textarea></form>"
'response.end
Call objXML.LoadXML(strXML)
strHTML = objXML.TransformNode(objXSL)

response.write("<div name='ParamTableSelectorUsageTab' id='ParamTableSelectorUsageTab'>")
response.write(strHTML)
response.write("</div>")

strXML = mcm_GetRecurringChargePriceableItemsXML()
Call objXML.LoadXML(strXML)
strHTML = objXML.TransformNode(objXSL)

response.write("<div name='ParamTableSelectorRecurringChargeTab' id='ParamTableSelectorRecurringChargeTab' style='display:none;'>")
response.write(strHTML)
response.write("</div>")

strXML = mcm_GetNonRecurringChargePriceableItemsXML()
Call objXML.LoadXML(strXML)
strHTML = objXML.TransformNode(objXSL)

response.write("<div name='ParamTableSelectorNonRecurringChargeTab' id='ParamTableSelectorNonRecurringChargeTab' style='display:none;'>")
response.write(strHTML)
response.write("</div>")

strXML = mcm_GetDiscountPriceableItemsXML()
Call objXML.LoadXML(strXML)
strHTML = objXML.TransformNode(objXSL)

response.write("<div name='ParamTableSelectorDiscountTab' id='ParamTableSelectorDiscountTab' style='display:none;'>")
response.write(strHTML)
response.write("</div>")


response.end



Dim objMTProductCatalog, objParamTableDef, objMTRateSched
Set objMTProductCatalog = GetProductCatalogObject

dim objMTFilter
Set objMTFilter = mdm_CreateObject(MTFilter)

dim objRowset
set objRowset = objMTProductCatalog.FindPriceableItemsAsRowset(objMTFilter)

response.write("There are [" & objRowset.RecordCount & "] priceable items")

'writeRowsetNameValueTable objRowset
'response.end

dim objPriceableItem
response.write("<table>")

  do while not cbool(objRowset.EOF)
    response.write("<TR class=ClsTableRow>")
 			response.write("<TD>" & objRowset.value("id_prop") & "</TD>")
 			'response.write("<TD>" & objRowset.value("nm_name") & "</TD>")

      set objPriceableItem = objMTProductCatalog.GetPriceableItem(objRowset.value("id_prop"))
      response.write("<TD>" & objPriceableItem.Name & "</TD>")

      dim objPriceableItemType
      set objPriceableItemType = objPriceableItem.PriceableItemType
      
      response.write("<td><table bgcolor='avacado'>")
      response.write("There are [" & objPriceableItemType.GetParamTableDefinitions.Count & "] param tables")

      dim objParamTable
      for each objParamTable in objPriceableItemType.GetParamTableDefinitions 
        response.write("<TR class=ClsTableRow>")
     			response.write("<TD>Param:" & objParamTable.id & "</TD>")
     			response.write("<TD>" & objParamTable.name & "</TD>")

        response.write("</TR>")
        
      next
      response.write("</table></td>")
  
  
        
    response.write("</TR>")
    objRowset.MoveNext
  loop
  
response.end
'Create new pricelist
  Dim objPriceList
  set objPriceList = objMTProductCatalog.CreatePriceList
  
  objPriceList.Name = new_pricelist_name
  objPriceList.Description = new_pricelist_description
  objPriceList.CurrencyCode = new_pricelist_currency
  
  'Currently this indicates that the price list is a regular pricelist and not a ICB specific pricelist
  objPriceList.Shareable = true
         
	objPriceList.Save
  id_pricelist_new = objPriceList.id
  
  response.write "Created new pricelist '" & objPriceList.Name & "' with id [" & id_pricelist_new & "]<BR>"
  
'Create new rateschedules


' initialize the rowset ...
objRowset.Init ("\\Reporting")

objRowset.SetQueryString("select * from t_rsched where id_pricelist=" & id_pricelist_original & " order by id_pt")

objRowset.Execute

'writeRowsetNameValueTable objRowset

response.write("There are " & objRowset.recordcount & " rate schedules to copy for this pricelist<BR>")

dim id_paramtable
dim id_rateschedule
dim objNewMTRateSched

  do while not cbool(objRowset.EOF)
  		id_paramtable = objRowset.value("id_pt")
      id_rateschedule = objRowset.value("id_sched")
 			response.write(" Param Table [" & id_paramtable & "] Rate Schedule [" & id_rateschedule & "]<BR>")
		  Set objParamTableDef = objMTProductCatalog.GetParamTableDefinition(id_paramtable)
      'response.write(objParamTableDef.ID & "<BR>")
		  Set objMTRateSched = objParamTableDef.GetRateSchedule(id_rateschedule)
      Set objNewMTRateSched = objMTRateSched.CreateCopy
      objNewMTRateSched.PricelistId = id_pricelist_new
      objNewMTRateSched.SaveWithRules
  objRowset.MoveNext
  loop




sub writeRowsetNameValueTable(objRowset)

  dim fieldValue
  dim fieldDisplayName
  dim fieldType
  dim i
  
  if not cbool(objRowset.EOF) then
    response.write("<table><TR class=ClsTableRowHeader>")
  	for i = 0 to objRowset.count -1
  		
      fieldDisplayName=objRowset.name(i)
  		'//fieldValue=objRowset.value(i)
      fieldType=objRowset.type(i)
  		' //if objRowset.type(i) = "date" then
  			' //fieldValue=getUserAdjustedDT(fieldValue)
  		' //end if
  
  			response.write("<TD>" & i & ":" & fieldDisplayName & " [" & fieldType & "]</TD>")
  	next
    response.write("</TR>")
  else
    response.write("[Empty Rowset]<BR>")
  end if
  
  do while not cbool(objRowset.EOF)
    response.write("<TR class=ClsTableRow>")
  	for i = 0 to objRowset.count - 1
  		fieldValue=objRowset.value(i)
 			response.write("<TD>" & fieldValue & "</TD>")
  	next
    response.write("</TR>")
    objRowset.MoveNext
  loop
  
	' finish the name-value pair grid
	response.write("</TABLE>")
  
  end sub%>




<div align="center">
<% =strHTML%>
<br><br>
<button class="clsButtonBlueXLarge" onclick="GotoPriceList(<%=id_pricelist_new%>);window.close();"><%=FrameWork.GetDictionary("TEXT_Work_On_New_Pricelist")%></button>
<button class="clsButtonBlueXLarge" onclick="window.close();"><%=FrameWork.GetDictionary("TEXT_Return_to_current_Pricelist")%></button>
</div>
<script>
function GotoPriceList(idPricelist)
{
  if (window.opener.parent!=null) 
  {
    window.opener.parent.document.location.href = "/mcm/default/dialog/Pricelist.ViewEdit.Frame.asp?ID=" + idPricelist;
  }
}
</script>

</body>


</html>
