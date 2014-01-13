<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_Upsell" CodeFile="Upsell.ascx.cs" %>
<%@ OutputCache Duration="1200" VaryByParam="none" VaryByCustom="username" shared="true" %>

<div class="box200">
  <div class="box200top"></div>
  <div class="box">
    <h6><asp:Localize meta:resourcekey="OnTheGo" runat="server">On The Go?</asp:Localize></h6>
    <div style="text-align:center">
      <a target="_blank" href="http://www.apple.com/iphone/apps-for-iphone/"><img border="0" src="<%=Request.ApplicationPath%>/Images/appstore.png" /></a>
    </div>
    <p>
    <asp:Localize meta:resourcekey="WithOur" runat="server">With our</asp:Localize> <a target="_blank" href="http://www.apple.com/iphone/apps-for-iphone/"><asp:Localize meta:resourcekey="iPhoneApp" runat="server">iPhone app</asp:Localize></a> <asp:Localize meta:resourcekey="ViewOnGo" runat="server">you can view your usage and pay your bill on the go.</asp:Localize>
    </p>
  </div>
</div>


