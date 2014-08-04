<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
  <LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/styles.css'>
	<title>Untitled</title>
</head>

<body>
<%

dim id_pricelist_original
id_pricelist_original = CLng(Request("PricelistId"))

dim new_pricelist_name
new_pricelist_name = Request("NewName")

dim new_pricelist_description
new_pricelist_description = Request("NewDescription")

dim new_pricelist_currency
new_pricelist_currency = Request("NewCurrency")


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
         
	objPriceList.Save
  id_pricelist_new = objPriceList.id
  
  response.write "Created new pricelist '" & objPriceList.Name & "' with id [" & id_pricelist_new & "]<BR>"
  
'Create new rateschedules
dim objRowset
set objRowset = CreateObject("MTSQLRowset.MTSQLRowset.1")

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
<button class="clsButtonBlueXLarge" onclick="GotoPriceList(<%=id_pricelist_new%>);window.close();">Work On New Pricelist</button>
<button class="clsButtonBlueXLarge" onclick="window.close();">Return to current Pricelist</button>
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
