<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>
<!-- frames -->
<!--<frameset cols="275px,*" rows="100%" framespacing="0" frameborder="0" border="0">
    <frame name="ProductOfferingNav" src="ProductOffering.ViewEdit.Nav.asp?ID= <%=SafeForHtmlAttr(request.QueryString("id"))%>" scrolling="auto" frameborder="0">
    <frame name="ProductOfferingMain" src="ProductOffering.ViewEdit.asp?ID= <%=SafeForHtmlAttr(request.QueryString("id"))%>" scrolling="auto" frameborder="0">
</frameset>-->

<script>
function doFullSize()
{
  if (document.all("PricelistView").cols=="0px,*")
  {
    document.all("PricelistView").cols="350px,*";
  }
  else
  {
    document.all("PricelistView").cols="0px,*";
  }
}
</script>

<frameset name="PricelistView" rows="100%" cols="350px,*" framespacing="0" frameborder="0">
    <frameset name="PricelistNav" rows="200,*" FRAMESPACING="0" FRAMEBORDER="0" border="0">
        <frame src="/mcm/default/dialog/Pricelist.Find.asp" name="menu" id="menu" frameborder="0" scrolling="Yes" marginwidth="0" marginheight="0" border="0" FRAMESPACING="0">
        <frame name="PricelistSelected" src="Pricelist.ViewEdit.Nav.asp?ID=<%=SafeForHtmlAttr(request.QueryString("id"))%>" scrolling="auto" frameborder="0">
    </frameset>
    <frame name="PricelistMain" src="Pricelist.ViewEdit.asp?ID=<%=SafeForHtmlAttr(request.QueryString("id"))%>" scrolling="auto" frameborder="0" />
</frameset>
</html>
