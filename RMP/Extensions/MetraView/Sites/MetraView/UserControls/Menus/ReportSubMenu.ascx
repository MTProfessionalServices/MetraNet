<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_ReportMenu" CodeFile="ReportSubMenu.ascx.cs" %>
<%@ Register src="~/UserControls/MyReports.ascx" tagname="MyReports" tagprefix="uc1" %>
<%@ Register src="~/UserControls/SystemReports.ascx" tagname="SystemReports" tagprefix="uc2" %>

<div class="box200">
  <div class="box200top"></div>
  <div class="boxheader"><asp:Localize meta:resourcekey="Usage" runat="server">Usage</asp:Localize></div>
  <div class="box">
  <ul class="bullets">
    <li><a href="<%=Request.ApplicationPath%>/Usage.aspx"><asp:Localize meta:resourcekey="UsageReport" runat="server">Usage Report</asp:Localize></a></li>
  </ul>
  </div>
</div>

<div class="box200" id="myReportsBox" runat="server">
  <div class="box200top"></div>
  <div class="boxheader"><asp:Localize meta:resourcekey="MyReports" runat="server">My Reports</asp:Localize></div>
  <div class="box">
    <uc1:MyReports ID="myReports"  MaxDisplayItems="5" runat="server" />
  </div>
</div>

<div class="box200" id="sharedReportsBox" runat="server">
  <div class="box200top"></div>
  <div class="boxheader"><asp:Localize meta:resourcekey="SharedReports" runat="server">Shared Reports</asp:Localize></div>
  <div class="box">
    <uc2:SystemReports ID="SystemReports" runat="server" />
  </div>
</div>