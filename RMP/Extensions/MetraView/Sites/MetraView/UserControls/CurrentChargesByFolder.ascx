<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CurrentChargesByFolder.ascx.cs" Inherits="UserControls_CurrentChargesByFolder" %>
<script type="text/javascript">
  Ext.onReady(function() {
    var wrapper = Ext.fly("reportLevelWrapper");
    wrapper.on("click", function(e) {
      try {
        var target = Ext.get(e.getTarget());
        var accId = target.getAttributeNS('ext', 'accId');
        if (typeof (accId) == 'undefined') return;
        if (typeof (accId) == '') return;
        var accEffDate = target.getAttributeNS('ext', 'accEffDate');

        var position = target.getAttributeNS('ext', 'position');
        var indent = target.getAttributeNS('ext', 'indent');
        var page = target.getAttributeNS('ext', 'page');
        var path = target.getAttributeNS('ext', 'path');
        var currency = target.getAttributeNS('ext', 'currency');
        if (position == "open") {
          Ext.fly(accId).update('');
          var elImg = Ext.fly("img" + accId);
          elImg.dom.src = "Images/bullet-gray.gif";
          target.setAttributeNS('ext', 'position', 'closed');
          return;
        }
        else {
          target.setAttributeNS('ext', 'position', 'open');
        }

        var el = Ext.get(accId);
        var reportLevelSvc = 'AjaxServices/ReportLevelSvc.aspx';
        var mgr = el.getUpdater();
        mgr.update({
          url: reportLevelSvc,
          params: { "id": accId, "accEffDate": accEffDate, "indent": indent, "page": page, "currency": currency },
          text: TEXT_LOADING,
          timeout: 60000
        });
        var elImg = Ext.fly("img" + accId);
        elImg.dom.src = "Images/bullet-gray-down.gif";
      }
      catch (e) {
       // alert(e.message);
        return;
      }
    });
    var wrapper = Ext.fly("subTotalWrapper");
    wrapper.on("click", function (e) {
    try {
        var target = Ext.get(e.getTarget());

        var position = target.getAttributeNS('ext', 'position');
        var indent = target.getAttributeNS('ext', 'indent');
        var page = target.getAttributeNS('ext', 'page');
        var path = target.getAttributeNS('ext', 'path');
        var currency = target.getAttributeNS('ext', 'currency');
        if (position == "open") {
            Ext.get('<%=PanelImpliedTaxes.ClientID %>').setStyle('display', 'none');  // to hide it
            var elImg = Ext.fly("subtotalBullet");
            elImg.dom.src = "Images/bullet-gray.gif";
            target.setAttributeNS('ext', 'position', 'closed');
            return;
        }
        else {
            target.setAttributeNS('ext', 'position', 'open');
        }

        Ext.get('<%=PanelImpliedTaxes.ClientID %>').setStyle('display', 'block');  // to show it
        var elImg = Ext.fly("subtotalBullet");
        elImg.dom.src = "Images/bullet-gray-down.gif";
    }
    catch (e) {
        return;
    }
    });
    var wrapper = Ext.fly("taxWrapper");
    wrapper.on("click", function (e) {
    try {
        var target = Ext.get(e.getTarget());

        var position = target.getAttributeNS('ext', 'position');
        var indent = target.getAttributeNS('ext', 'indent');
        var page = target.getAttributeNS('ext', 'page');
        var path = target.getAttributeNS('ext', 'path');
        var currency = target.getAttributeNS('ext', 'currency');
        if (position == "open") {
            Ext.get('<%=TaxSubTotalsPanel.ClientID %>').setStyle('display', 'none');  // to hide it
            var elImg = Ext.fly("taxBullet");
            elImg.dom.src = "Images/bullet-gray.gif";
            target.setAttributeNS('ext', 'position', 'closed');
            return;
        }
        else {
            target.setAttributeNS('ext', 'position', 'open');
        }

        Ext.get('<%=TaxSubTotalsPanel.ClientID %>').setStyle('display', 'block');  // to show it
        var elImg = Ext.fly("taxBullet");
        elImg.dom.src = "Images/bullet-gray-down.gif";
    }
    catch (e) {
        return;
    }
    });
  });
</script>

<div id="reportLevelWrapper">
 <%= GetChargesByFolder() %>
</div>
    
<hr />
<asp:Panel ID="subTotalWithExpanderPanel" runat="server">
<div id="subTotalWrapper">
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td>
        <img id="subtotalBullet" border="0" src="images/bullet-gray.gif" />
        <a style="text-decoration:none;cursor:pointer;" ext:position="closed" ext:indent="0">
        <asp:Localize meta:resourcekey="SubTotal" runat="server">Sub-Total</asp:Localize>
        </a>
    </td>
    <td class="amount"><%= GetSubTotalAmount() %></td>
  </tr>
</table> 
</div>
</asp:Panel>
<asp:Panel ID="subTotalPanel" runat="server">
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td>
        <asp:Localize meta:resourcekey="SubTotal" runat="server">Sub-Total</asp:Localize>
    </td>
    <td class="amount"><%= GetSubTotalAmount() %></td>
  </tr>
</table>
</asp:Panel>

<asp:Panel ID="PanelImpliedTaxes" runat="server" style="display:none;">  
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5%"></td>
    <td><asp:Localize ID="Usage" meta:resourcekey="Usage" runat="server">Usage</asp:Localize></td>
    <td class="amount"><%= GetUsageAmount() %></td>
  </tr>
  <tr>
    <td width="5%"></td>
    <td><asp:Localize ID="Localize1" meta:resourcekey="ImpliedTax" runat="server">Included Tax</asp:Localize></td>
    <td class="amount"><%= GetImpliedTaxAmount() %></td>
  </tr>
  </table>
<div ID="IncludedInformationalTaxDiv" runat="server">
<table width="100%" cellspacing="0" cellpadding="0">
  <tr style="color:gray">
    <td width="5%" height="30px"></td>
    <td>(<asp:Localize ID="IncludedInformationalTax" meta:resourcekey="IncludedInformationalTax" runat="server">Included Informational Tax</asp:Localize></td>
    <td class="amount"><%= GetImplInfTaxAmount() %>)</td>
  </tr>
</table>
</div>
</asp:Panel>

<asp:Panel ID="PanelAdjustments" runat="server">  
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td><%= GetAdjustmentDetailLink() %></td>
    <td class="amount"><%= GetPreBillAdjustmentAmount() %></td>
  </tr>
</table>     
</asp:Panel>

<asp:Panel ID="PanelTaxes" runat="server">  
<div id="taxWrapper">
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td>
        <img id="taxBullet" border="0" src="images/bullet-gray.gif" />
        <a style="text-decoration:none;cursor:pointer;" ext:position="closed" ext:indent="0">
        <asp:Localize ID="ImpliedTax" meta:resourcekey="Tax" runat="server">Tax</asp:Localize>
        </a>
      </td>
    <td class="amount"><%= GetBillableTaxAmount() %></td>
  </tr>
</table>
</div>

<asp:Panel ID="TaxSubTotalsPanel" runat="server" style="display:none;">  
<table width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="5%"></td>
        <td><asp:Localize ID="ActualTax" meta:resourcekey="ActualTax" runat="server">Actual Tax</asp:Localize></td>
        <td class="amount"><%= GetNonImpliedTaxAmount()%></td>
    </tr>
</table>
<div ID="InformationalTaxDiv" runat="server">
<table width="100%" cellspacing="0" cellpadding="0">
    <tr style="color:gray">
        <td width="5%" height="30px"></td>
        <td>(<asp:Localize ID="InformationalTax" meta:resourcekey="InformationalTax" runat="server">Informational Tax</asp:Localize></td>
        <td class="amount"><%= GetInformationalTaxAmount() %>)</td>
    </tr>
</table>
</div>
</asp:Panel>

<table width="100%" cellspacing="0" cellpadding="0" >
  <tr>
    <td><asp:Localize meta:resourcekey="TaxAdjustments" runat="server">Tax Adjustments</asp:Localize></td>
    <td class="amount"><%= GetTaxAdjustmentAmount() %></td>
  </tr>
</table>     
</asp:Panel>

<table width="100%" cellspacing="0" cellpadding="0"> 
  <tr class="subtotal">
    <td><asp:Localize meta:resourcekey="TotalCharges" runat="server">Total Charges</asp:Localize></td>
    <td class="amount"><%= GetTotalCurrentChargesAmount() %></td>
  </tr>
</table>    

<asp:Panel ID="PanelCurrentTotalAmount" runat="server">
  <hr />
  <table width="100%" cellspacing="0" cellpadding="0">
    <tr class="subtotal">
      <td><asp:Localize meta:resourcekey="Total" runat="server">Total</asp:Localize></td>
      <td class="amount"><%= GetCurrentTotalAmount() %></td>
    </tr>
  </table>   
</asp:Panel>
   