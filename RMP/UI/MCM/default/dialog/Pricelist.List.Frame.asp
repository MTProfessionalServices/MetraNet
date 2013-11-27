<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<!-- frames -->
<!--<frameset cols="275px,*" rows="100%" framespacing="0" frameborder="0" border="0">
    <frame name="ProductOfferingNav" src="ProductOffering.ViewEdit.Nav.asp?ID=<%=request.QueryString("id")%>" scrolling="auto" frameborder="0">
    <frame name="ProductOfferingMain" src="ProductOffering.ViewEdit.asp?ID=<%=request.QueryString("id")%>" scrolling="auto" frameborder="0">
</frameset>-->

<script>
function doFullSize()
{
  if (document.all("PriceListFrame").cols=="0px,*")
  {
    document.all("PriceListFrame").cols="350px,*";
  }
  else
  {
    document.all("PriceListFrame").cols="0px,*";
  }
}
</script>

<frameset name="PriceListFrame" rows="100%" cols="350px,*" framespacing="0" frameborder="0">
    <frameset name="PriceListFind" rows="*,0" FRAMESPACING="0" FRAMEBORDER="0" border="0">
        <frame src="/mcm/default/dialog/Pricelist.Find.asp" name="menu" id="menu" frameborder="0" scrolling="Yes" marginwidth="0" marginheight="0" border="0" FRAMESPACING="0">
        <frame name="PricelistNav" src="blank.htm" scrolling="auto" frameborder="0">
    </frameset>
    <frame name="PricelistMain" src="Rates.AllPricelists.List.asp?LinkColumnMode=TRUE&POBased=FALSE&Parameters=LinkColumnMode|TRUE;Rates|TRUE;POBased|FALSE;Title|TEXT_RATES_ALLPRICELISTS_CHOOSE_PRICEABLE_ITEM;kind=10&NextPage=Pricelist.ViewEdit.Frame.asp&Title=TEXT_RATES_ALLPRICELISTS_LIST&Rates=TRUE" scrolling="auto" frameborder="0">
</frameset>





</html>
