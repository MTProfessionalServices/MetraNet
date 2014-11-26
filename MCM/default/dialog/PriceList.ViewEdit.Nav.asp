<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE FILE="../../default/lib/ProductCatalogXML.asp" --><%

'//Reset the flag in the dictionary to indicated that we have refreshed the nav pane
mdm_GetDictionary().Add "TRIGGER_UPDATE_OF_PRICELIST_NAVIGATION_PANE", "FALSE"

Dim objMTProductCatalog
Set objMTProductCatalog = GetProductCatalogObject


dim objXML, objXSL, strPathXSL, strHTML
Set objXML = server.CreateObject("Microsoft.XMLDOM")
Set objXSL = server.CreateObject("Microsoft.XMLDOM")

dim strXML
strXML = mcm_GetPricelistXML(request.querystring("id"))


'strXML = "<?xml version=""1.0""?>" & vbCRLF & strXML

'response.write "<form><textarea cols='100' rows='40'>" & strXML & "</textarea></form>"
'response.end
'response.write "Done XML [" & Now & "]"

strPathXSL = server.MapPath(Application("APP_HTTP_PATH") & "\default\dialog\xsl\pricelist.xsl")

'response.write ("Path is [" & strPathXSL & "]<BR>")
'response.end
Call objXML.LoadXML(strXML)


Call objXSL.Load(strPathXSL)
Call objXSL.LoadXML(mdm_LocalizeString(objXSL.xml))

objXML.setProperty "SelectionLanguage", "XPath"
objXSL.setProperty "SelectionLanguage", "XPath"


strHTML = objXML.TransformNode(objXSL)


'response.write(strHTML)

'response.end
  
%>

<script>
function NavigateToPricelistViewEdit(id)
{
  var sNewLocation = "PriceList.ViewEdit.asp?ID=" + id + "&EditMode=False"
  if ((parent!=null) && (parent.PricelistMain!=null))
  {
    parent.PricelistMain.location = sNewLocation;
  }
  else
  {
    window.open(sNewLocation,"","");
  }
}
function OpenAddRateScheduleWindow()
{
<%
  response.write "id_pricelist = " & request.querystring("id") & ";"
%>
  OpenDialogWindow('PriceList.AddParamTable.asp?ID=' + id_pricelist, 'height=800,width=1000,resizable=yes,scrollbars=yes');
}

///////////////////////////////////////////////
function NavigateToRates(id,pi_id,id_pricelist)
{

  var sNewLocation = "Rates.RateSchedule.List.asp?Title=TEXT_CHOOSE_RATE_SCHEDULE&ID=" + id + "&PT_ID=" + id + "&PL_ID=" + id_pricelist + "&PI_ID=" + pi_id + "&Parameters=Title|TEXT_CHOOSE_RATE_SCHEDULE;POBased|TRUE&POBased=FALSE&Rates=TRUE&mdmReload=True";
  //alert(id_pricelist);
  //alert(sNewLocation);
  //return;
  
  if ((parent!=null) && (parent.PricelistMain!=null))
  {
    parent.PricelistMain.location = sNewLocation;
  }
  else
  {
    window.open(sNewLocation,"","");
  }
  
}


function NavigateToPreviousSearchResults()
{
    var targetURL="/MetraNet/MetraOffer/PriceLists/PriceListsList.aspx";
    window.parent.location.href = targetURL;
    window.parent.close();
}

var last;
</script>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
  <LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/styles.css'>
  <LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/Navstyles.css'>  
	<title>Untitled</title>
	<SCRIPT language="JavaScript" src="/mpte/shared/browsercheck.js"></SCRIPT>	
  <SCRIPT language="JavaScript" src="/mcm/default/lib/PopupEdit.js"></SCRIPT>	
</head>
<body class="side" style="margin:10px 14px 6px 5px;">

<div align="center">
<% =strHTML%>
<br><br>

</div>


</body>


</html>
