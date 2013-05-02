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
          params: { "id": accId, "accEffDate": accEffDate, "indent": indent, "page": page },
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
  });
</script>

<div id="reportLevelWrapper">
 <%= GetChargesByFolder() %>
</div>
    
<hr />
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td><asp:Localize meta:resourcekey="SubTotal" runat="server">Sub-Total</asp:Localize></td>
    <td class="amount"><%= GetSubTotalAmount() %></td>
  </tr>
</table> 

<asp:Panel ID="PanelAdjustments" runat="server">  
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td><%= GetAdjustmentDetailLink() %></td>
    <td class="amount"><%= GetPreBillAdjustmentAmount() %></td>
  </tr>
</table>     
</asp:Panel>

<asp:Panel ID="PanelTaxes" runat="server">  
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td><asp:Localize ID="Localize1" meta:resourcekey="Tax" runat="server">Tax</asp:Localize></td>
    <td class="amount"><%= GetTaxAmount() %></td>
  </tr>
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
   