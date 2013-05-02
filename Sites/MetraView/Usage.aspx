<%@ Page Language="C#" MasterPageFile="~/MasterPages/ReportsPageExt.master" AutoEventWireup="true" Inherits="Usage" CodeFile="Usage.aspx.cs" Culture="auto" UICulture="auto" Title="<%$Resources:Resource,TEXT_TITLE%>"%>
<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>
<%@ Register src="UserControls/CurrentCharges.ascx" tagname="CurrentCharges" tagprefix="uc5" %>
<%@ Register src="UserControls/CurrentChargesByFolder.ascx" tagname="CurrentChargesByFolder" tagprefix="uc6" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">  
  <h1><asp:Localize meta:resourcekey="Usage" runat="server">Usage</asp:Localize></h1>
  
  <div class="box500">
  <div class="box500top"></div>
  <div class="box">
    <div class="left">
      <MT:MTDatePicker ID="startDate" Label="View usage from" LabelSeparator="" meta:resourcekey="startDateResource1" LabelWidth="100" ControlWidth="100" runat="server" />
    </div>
    <div class="left">
      <MT:MTDatePicker ID="endDate" Label="to" LabelSeparator="" LabelWidth="20" ControlWidth="100" runat="server"  meta:resourcekey="endDateResource1" />
    </div>

    <div class="left">&nbsp;&nbsp;</div>
    <div class="button">
      <span class="buttonleft"><!--leftcorner--></span>
      <asp:Button ID="btnLoadUsage" runat="server" onclick="BtnLoadUsageClick" OnClientClick="return ValidateDateRange();" Text="<%$Resources:Resource,TEXT_GO%>"  />
      <span class="buttonright"><!--rightcorner--></span>
    </div><!--/button-->
    <div class="left">&nbsp;&nbsp;</div>
    <asp:Panel ID="PanelOwnedAccounts" Visible="false" runat="server">    
      <strong><asp:Localize meta:resourcekey="ShowReportFor" runat="server">Show Report For:</asp:Localize></strong>
      <asp:DropDownList ID="ddOwnedAccounts" runat="server" AutoPostBack="True" onselectedindexchanged="ddOwnedAccounts_SelectedIndexChanged"></asp:DropDownList>
    </asp:Panel>
    <div class="clearer"></div>
  </div>
  </div>

  <div class="box500plain">
  <div class="box500plaintop"></div>
  <div class="box">
    <asp:Panel ID="PanelCurrentCharges" runat="server">
      <h6><asp:Localize meta:resourcekey="Charges" runat="server">Charges</asp:Localize> <small>[ <a href="<%= UI.DictionaryManager["UsagePage"] + "?view=details"%>"><asp:Localize meta:resourcekey="DetailedView" runat="server">Detailed View</asp:Localize></a> ]</small></h6>   
      <uc5:CurrentCharges ID="CurrentCharges1" runat="server" />
    </asp:Panel>
    <asp:Panel Visible="false" ID="PanelCurrentChargesByFolder" runat="server">
      <h6><asp:Localize meta:resourcekey="ChargeDetails" runat="server">Charge Details</asp:Localize> <small>[ <a href="<%= UI.DictionaryManager["UsagePage"] + "?view=summary" %>"><asp:Localize meta:resourcekey="SummaryView" runat="server">Summary View</asp:Localize></a> ]</small></h6>   
      <uc6:CurrentChargesByFolder ID="CurrentChargesByFolder1" runat="server" />
    </asp:Panel>
  </div>
  <div class="box500plainbtm"></div>
  </div>
  
    <script language="javascript" type="text/javascript">
      Ext.onReady(function() {
        var startCtl = Ext.getCmp('<%=startDate.ClientID %>');
        var endCtl = Ext.getCmp('<%=endDate.ClientID %>');
        function clearControl(ctrl) {
          startCtl.clearInvalid();
          if (!startCtl.validate()) {
            startCtl.markInvalid();
          }

          endCtl.clearInvalid();
          if (!endCtl.validate()) {
            endCtl.markInvalid();
          }                    
        }

        startCtl.on('change', clearControl);
        endCtl.on('change', clearControl);

        startCtl.on('select', clearControl);
        endCtl.on('select', clearControl);

      });

      function ValidateDateRange() {
        var startCtl = Ext.getCmp('<%=startDate.ClientID %>');
        var endCtl = Ext.getCmp('<%=endDate.ClientID %>');

        if (!startCtl.validate() || !endCtl.validate()) {
          return false;
        }
        var startDt = "";
        var endDt = "";

        if (startCtl != null) {
          startDt = startCtl.getValue();
        }

        if (endCtl != null) {
          endDt = endCtl.getValue();
        }

        if (Date.parseDate(startDt, DATE_FORMAT) > Date.parseDate(endDt, DATE_FORMAT)) {
          var sErr = '<%= Resources.ErrorMessages.ERROR_END_DATE_BEFORE_START_DATE %>';
          startCtl.markInvalid(sErr);
          endCtl.markInvalid(sErr);
          return false;
        }

        return true;
      }
  </script>
</asp:Content>

