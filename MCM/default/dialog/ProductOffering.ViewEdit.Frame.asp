<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<head>
	<title>Untitled</title>
</head>

<frameset name="ProductOfferingView" cols="300px,*" framespacing="0" frameborder="0">
    <!--
    <frameset name="ProductOfferingNav" rows="150,*" FRAMESPACING="0" FRAMEBORDER="0" border="0">
        <frame src="/mcm/default/dialog/ProductOffering.Find.asp?State=Collapsed" name="ProductOfferingFind" id="ProductOfferingFind" frameborder="0" scrolling="No" marginwidth="0" marginheight="0" border="0" FRAMESPACING="0">
        <frame name="ProductOfferingSelected" src="ProductOffering.ViewEdit.Nav.asp?ID=<%=SafeForHtmlAttr(request.QueryString("id"))%>" scrolling="auto" frameborder="0">
    </frameset>
    -->
    <frame name="ProductOfferingSelected" src="ProductOffering.ViewEdit.Nav.asp?ID=<%=SafeForHtmlAttr(request.QueryString("id"))%>&Master=<%=SafeForHtmlAttr(request.QueryString("Master"))%>" scrolling="auto" frameborder="0">
    <frame name="ProductOfferingMain" src="ProductOffering.ViewEdit.asp?ID=<%=request.QueryString("id")%>&Master=<%=SafeForHtmlAttr(request.QueryString("Master"))%>" scrolling="auto" frameborder="0">
</frameset>

</html>
