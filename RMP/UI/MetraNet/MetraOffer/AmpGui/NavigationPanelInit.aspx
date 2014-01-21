<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="NavigationPanelInit.aspx.cs" Inherits="AmpNavigationPanelInitPage" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<!-- Using a table here so that the width of the iframe will stay consistent across multiple browsers: IE8, IE9, Chrome, Firefox-->
<table width="100%">
<tr>
<td Width="200px" valign=top>
  <MT:MTPanel ID="AmpWizardNavigationPanel" runat="server" Collapsible="False"  Width="200px">
    <div style="width: 200px">
      
      
      <asp:SiteMapDataSource ID="SiteMapDataSource1" runat="server" 
        SiteMapProvider="AmpWizardProvider" ShowStartingNode="False"/>
      <asp:TreeView ID="TreeView1" runat="server" DataSourceID="SiteMapDataSource1" 
        Target="Frame1" NodeIndent="15" 
        SelectedNodeStyle-Font-Bold="true" 
        SelectedNodeStyle-ForeColor="White" 
        SelectedNodeStyle-BackColor="Highlight"
        >
      </asp:TreeView>
    </div>
 
  </MT:MTPanel> 
</td>
<td>
<!-- Don't put a div around the iframe; it constrains the iframe's width. -->
<!-- In the iframe, specify dimensions inside the style attribute
     to accommodate different browsers. -->
<!-- iframe width is 100% so that it will fill the entire td width in multiple browsers-->
<!-- The first page of the AMP wizard is the General Information page. -->
<iframe id="Frame1" name="Frame1" src="GeneralInformation.aspx" 
        frameborder="0" scrolling="no"
        style="width:100%; height:830px; padding : 0 0;" 
></iframe>
</td></tr></table>

<%
/*
<!-- 
 When loading up the navigation panel, this onReady() method modifies the markup
 of the nonclickable nodes to make it possible to highlight them when the user
 arrives at one of those pages by clicking on a button in another page.
 Nonclickable nodes are defined in AmpWizard.sitemap with empty url's and
 description attributes that name the page.  ASP.NET then expresses the nonclickable nodes
 as span tags with title attributes that name the page.  This onReady() method 
 changes those title attributes to data attributes for two reasons:
 (1) This eliminates tooltips on the nonclickable nodes in the nav panel.
 (2) When the app loads a page that is nonclickable on the nav panel,
 the updateNavPanel() method in AmpWizard.js can now look at the data attribute
 to find and highlight the matching nonclickable node.
-->
*/
%>
<script type="text/javascript">
  Ext.onReady(function() {
    var spanElems = document.getElementsByTagName("span");
    for (var i = 0; i < spanElems.length; i++) {
      var spanElem = spanElems[i];
      var pagename = spanElem.getAttribute("title");
      if ((pagename != null) && (pagename.length > 0)) {
        spanElem.removeAttribute("title");
        spanElem.setAttribute("data", pagename);
      }
    }
  });
</script>

</asp:Content>