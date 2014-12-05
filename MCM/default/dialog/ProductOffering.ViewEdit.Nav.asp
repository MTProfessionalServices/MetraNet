<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE FILE="../lib/ProductCatalogXml.asp" -->

<%

'//Reset the flag in the dictionary to indicated that we have refreshed the nav pane
mdm_GetDictionary().Add "TRIGGER_UPDATE_OF_PO_NAVIGATION_PANE", "FALSE"

'Dim objMTProductCatalog
'Set objMTProductCatalog = GetProductCatalogObject

dim objXML, objXSL, strPathXSL, strHTML
Set objXML = server.CreateObject("Microsoft.XMLDOM")
Set objXSL = server.CreateObject("Microsoft.XMLDOM")

dim strXML
strXML = mcm_GetProductOfferingXML(request.querystring("id"))

'strXML = "<?xml version=""1.0""?>" & vbCRLF & strXML

'response.write "<form><textarea cols='100' rows='40'>" & strXML & "</textarea></form>"
'response.end
'response.write "Done XML [" & Now & "]"

strPathXSL = server.MapPath(Application("APP_HTTP_PATH") & "\default\dialog\xsl\productoffering.xsl")

'response.write ("Path is [" & strPathXSL & "]<BR>")
'response.end
Call objXML.LoadXML(strXML)


Call objXSL.Load(strPathXSL)

objXML.setProperty "SelectionLanguage", "XPath"
objXSL.setProperty "SelectionLanguage", "XPath"


strHTML = objXML.TransformNode(objXSL)


'response.write("<pre>" & strHTML & "</pre>")

'response.end
  
%>

<script>
var currentlySelectedItem=0;

function ShowItemAsSelected(id)
{
  var tempElement;
  if (currentlySelectedItem==id)
    return;
    
  if (currentlySelectedItem!=0)
  {
    if ((tempElement=document.getElementById(currentlySelectedItem))!=null)
    {
      var sClassName = tempElement.className;
      tempElement.className = sClassName.substring(0,sClassName.length-8);
      //alert("New Class is [" + tempElement.className + "]");
    }
  }
  
  if (tempElement=document.getElementById(id))
    tempElement.className = tempElement.className + "Selected"; 
  
  currentlySelectedItem = id;
}

function NavigateToItem(id,iKind)
{
  //window.alert("Id [" + id + "] Kind[" + iKind + "]");
  
  ShowItemAsSelected(id);

<%
  'SECENG: Added HTML encoding
  response.write "poId = " & SafeForHtml(request.querystring("id")) & ";"
%>
  
  switch (iKind) {
    case -1:
      //Custom case for Product Offering
      sNewLocation="ProductOffering.ViewEdit.asp?ID=" + poId;
      break;
    case -2:
      //Custom case for Product Offering (Tab To Add Items)
      sNewLocation="ProductOffering.ViewEdit.Items.asp?ID=" + poId + "&Tab=2";
      break;
    case 10:
      sNewLocation="PriceableItem.Usage.ViewEdit.asp?ID=" + id + "&EditMode=False&POBased=True&AUTOMATIC=False&Kind="+iKind+"&mdmReload=True&POID=" + poId;
      break;
    case 15:
      sNewLocation="PriceableItem.Usage.ViewEdit.asp?ID=" + id + "&EditMode=False&POBased=True&AUTOMATIC=False&Kind="+iKind+"&mdmReload=True&POID=" + poId;
      break;
    case 25:
    case 20:
      sNewLocation="PriceableItem.RecurringCharge.ViewEdit.asp?ID=" + id + "&EditMode=False&POBased=True&AUTOMATIC=False&Kind="+iKind+"&mdmReload=True&POID=" + poId;
      break;
    case 30:
      sNewLocation="PriceAbleItem.NonRecurring.ViewEdit.asp?ID=" + id + "&EditMode=False&POBased=True&AUTOMATIC=False&Kind="+iKind+"&mdmReload=True&POID=" + poId;
      break;
    case 40:
      sNewLocation="PriceableItem.Discount.ViewEdit.asp?ID=" + id + "&EditMode=False&POBased=True&AUTOMATIC=False&Kind="+iKind+"&mdmReload=True&POID=" + poId;
      break;
      
    default:
      alert("Default");
      sNewLocation="PriceableItem.Usage.ViewEdit.asp?ID=" + id + "&EditMode=False&POBased=True&AUTOMATIC=False&Kind=10&mdmReload=True&POID=" + poId;
  }
  
  //window.alert("Main [" + parent.ProductOfferingMain.location + "]");
  if ((parent!=null) && (parent.ProductOfferingMain!=null))
  {
    parent.ProductOfferingMain.location = sNewLocation;
  }
  else
  {
    window.open(sNewLocation,"","");
  }
  
}

///////////////////////////////////////////////
function NavigateToRates(id,pi_id)
{
  ShowItemAsSelected(id + '_' + pi_id);
<%
  response.write "poId = " & request.querystring("id") & ";"
%>
  sNewLocation = "Rates.RateSchedule.List.asp?Title=TEXT_CHOOSE_RATE_SCHEDULE&ID=" + id + "&PT_ID=" + id + "&PI_ID=" + pi_id + "&&Parameters=Title|TEXT_CHOOSE_RATE_SCHEDULE;POBased|TRUE&POBased=TRUE&Rates=TRUE&mdmReload=True";
  if ((parent!=null) && (parent.ProductOfferingMain!=null))
  {
    parent.ProductOfferingMain.location = sNewLocation;
    window.location = window.location;
  }
  else
  {
    window.open(sNewLocation,"","");
  }
}

  function NavigateToPreviousSearchResults()
  {
   var master = false;
   if(location.search.split('Master=')[1]){
    master = location.search.split('Master=')[1];
   }
   var targetURL="/MetraNet/MetraOffer/ProductOfferings/ProductOfferingsList.aspx?PreviousResultView=True+&Master="+master;
   window.parent.location.href = targetURL;
   window.parent.close(); 
  }

  var last;
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
      
</script>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
  <LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/styles.css'>
  <LINK rel='STYLESHEET' type='text/css' href='/mcm/default/localized/en-us/styles/Navstyles.css'>  
	<title>Untitled</title>
</head>

<body class="side">

<div align="center">
<% =strHTML%>
<br><br>
</div>
<script>
ShowItemAsSelected(<%=request.querystring("id")%>);
</script>

</body>


</html>
