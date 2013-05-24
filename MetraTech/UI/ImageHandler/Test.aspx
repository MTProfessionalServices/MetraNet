<%@ Page language="c#" Codebehind="Test.aspx.cs" AutoEventWireup="false" Inherits="ImageHandler.WebForm1" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" > 

<html>
  <head>
    <title>Test</title>
    <meta name="GENERATOR" Content="Microsoft Visual Studio .NET 7.1">
    <meta name="CODE_LANGUAGE" Content="C#">
    <meta name=vs_defaultClientScript content="JavaScript">
    <meta name=vs_targetSchema content="http://schemas.microsoft.com/intellisense/ie5">
    
    <style>
    .ClsTableRow{
	background: #99CCFF;
	font : 12;
}

.ClsTableRowHeader{
	background: #6699CC;
	font : 12;
	color: White;
	border: none;
	/*font-weight: bold;*/
}

.ClsTitle{
	/*background: #6699CC;*/
	font : 18px;
	font-weight : bold;
	min-width : 100%;
	color: #191970;
}

.ClsErrorMessage{
	font : 12;
	color : Red;
}

A{
	color: #003399;
}
</style>
  </head>
  <body MS_POSITIONING="GridLayout" bgcolor="white">
	
    <form id="Form1" method="post" runat="server">
    
      Image Handler Test Page<hr size=1>

      <img src="/ImageHandler/images/account/coresubscriber/account.gif?Payees=1&State=SU&Folder=False&R=33&G=48&B=107">
      <img src="/ImageHandler/images/account/coresubscriber/account.gif?Payees=1&State=AC&Folder=False">      
      <img src="/ImageHandler/images/account/coresubscriber/account.gif?Payees=1&State=SU&Folder=True">
      <img src="/ImageHandler/images/account/coresubscriber/account.gif?Payees=0&State=AC&Folder=True">
      <img src="/ImageHandler/images/account/coresubscriber/account.gif?Payees=1&State=SU&Folder=True&FolderOpen=True">
      
      <hr size=1>
      <b>Enumerating Current Account Icon Directories</b><br>
     <%
      //using System.IO;
      
      System.IO.DirectoryInfo di = new System.IO.DirectoryInfo(@"s:\metratech\ui\imagehandler\images\account");
      System.IO.DirectoryInfo[] dirs = di.GetDirectories("*.*");
      foreach (System.IO.DirectoryInfo diNext in dirs) 
      {
          Response.Write("<table width='250px'><tr><td colspan='2' class='ClsTableRowHeader' style='text-align:right;'><b>" + diNext.Name + "</b></td></tr>");
          %>
          <tr><td class='ClsTableRow' style='text-align:right;'>Payer:</td><td class='ClsTableRow'><img src="/ImageHandler/images/account/<%Response.Write(diNext.Name);%>/account.gif?Payees=1&State=AC&Folder=False"></td>
          <tr><td class='ClsTableRow' style='text-align:right;'>Container:</td><td class='ClsTableRow'><img src="/ImageHandler/images/account/<%Response.Write(diNext.Name);%>/account.gif?Payees=0&State=AC&Folder=True"></td>
          <tr><td class='ClsTableRow' style='text-align:right;'>Payer & Container & Suspended:</td><td class='ClsTableRow'><img src="/ImageHandler/images/account/<%Response.Write(diNext.Name);%>/account.gif?Payees=1&State=SU&Folder=True"></td>
          <tr><td class='ClsTableRow' style='text-align:right;'>Payer & Container & Open:</td><td class='ClsTableRow'><img src="/ImageHandler/images/account/<%Response.Write(diNext.Name);%>/account.gif?Payees=1&State=SU&Folder=True&FolderOpen=True"></td>
          <tr><td class='ClsTableRow' style='text-align:right;'>Payer & Suspended & Background set:</td><td class='ClsTableRow'><img src="/ImageHandler/images/account/<%Response.Write(diNext.Name);%>/account.gif?Payees=1&State=SU&Folder=False&R=33&G=48&B=107"></td>
          <%
          Response.Write("</table><BR>");
      }

     %>
     
    <hr size=1>
    <table width='250px'><tr><td colspan='2' class='ClsTableRowHeader' style='text-align:right;'><b>Product Catalog - Parameter Tables</b></td></tr>
    <tr><td class='ClsTableRow' style='text-align:right;'>Default:</td><td class='ClsTableRow'><img src="/ImageHandler/images/ProductCatalog/ParamTable/paramtable.gif"></td></tr>
    <tr><td class='ClsTableRow' style='text-align:right;'>Calendar (Custom):</td><td class='ClsTableRow'><img src="/ImageHandler/images/productcatalog/paramtable/metratech_com/calendar/paramtable.gif"></td></tr>
    <tr><td class='ClsTableRow' style='text-align:right;'>Doesn't Exist (will use default):</td><td class='ClsTableRow'><img src="/ImageHandler/images/productcatalog/paramtable/newthing/something/paramtable.gif"></td></tr>
    </table>
    
    <hr size=1>
    <table width='250px'><tr><td colspan='2' class='ClsTableRowHeader' style='text-align:right;'><b>Product Catalog - Priceable Items</b></td></tr>
    <tr><td class='ClsTableRow' style='text-align:right;'>Default:</td><td class='ClsTableRow'><img src="/ImageHandler/images/ProductCatalog/PriceableItem/priceableitem.gif"></td></tr>
    <tr><td class='ClsTableRow' style='text-align:right;'>Usage Charge (Defaulted to type):</td><td class='ClsTableRow'><img src="/ImageHandler/images/ProductCatalog/PriceableItem/10/AudioConfCall/priceableitem.gif"></td></tr>
    <tr><td class='ClsTableRow' style='text-align:right;'>Aggregate Usage Charge (Defaulted to type):</td><td class='ClsTableRow'><img src="/ImageHandler/images/ProductCatalog/PriceableItem/15/AudioConfCall/priceableitem.gif"></td></tr>
    <tr><td class='ClsTableRow' style='text-align:right;'>Recurring Charge (Defaulted to type):</td><td class='ClsTableRow'><img src="/ImageHandler/images/ProductCatalog/PriceableItem/20/Monthly%20Per-Subscription%20Recurring%20Charge/priceableitem.gif"></td></tr>
    <tr><td class='ClsTableRow' style='text-align:right;'>Non-Recurring Charge (Defaulted to type):</td><td class='ClsTableRow'><img src="/ImageHandler/images/ProductCatalog/PriceableItem/30/Monthly%20Per-Subscription%20Recurring%20Charge/priceableitem.gif"></td></tr>
    <tr><td class='ClsTableRow' style='text-align:right;'>Discount (Defaulted to type):</td><td class='ClsTableRow'><img src="/ImageHandler/images/ProductCatalog/PriceableItem/40/Weekly%20Flat%20Rate%20Discount/priceableitem.gif"></td></tr>
    <tr><td class='ClsTableRow' style='text-align:right;'>Song Downloads (Custom):</td><td class='ClsTableRow'><img src="/ImageHandler/images/ProductCatalog/PriceableItem/15/Song%20Downloads/priceableitem.gif"></td></tr>
    </table>
    
     </form>
	
  </body>
</html>
