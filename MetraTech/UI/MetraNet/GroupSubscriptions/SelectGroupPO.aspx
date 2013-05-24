<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_SelectGroupPO" Title="MetraNet"
  Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="SelectGroupPO.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>

  <div class="CaptionBar">
    <asp:Label ID="lblSubscribeToPOTitle" runat="server" Text="Subscribe to Product Offering"
      meta:resourcekey="lblSubscribeToPOTitleResource1"></asp:Label>
  </div>
  <MT:MTFilterGrid ID="POGrid" runat="server" TemplateFileName="GroupPOListLayoutTemplate"
    ExtensionName="Account">
  </MT:MTFilterGrid>

  <script type="text/javascript">
    
    // Custom Renderers
    OverrideRenderer_<%= POGrid.ClientID %> = function(cm)
    {
      cm.setRenderer(cm.getIndexById('DisplayName'), hiddenIDRenderer);
      cm.setRenderer(cm.getIndexById('EffectiveTimeSpan#StartDate'), DateRenderer);
      cm.setRenderer(cm.getIndexById('EffectiveTimeSpan#EndDate'), DateRenderer);
    };
    
    var GridRowID = 0;
    hiddenIDRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";

      // Display DisplayName inside a span with the GridRowID
      GridRowID++;
      str += String.format("<span id='GridRowID_{0}'>{1}</span>", GridRowID, record.data.DisplayName);
      return str;
    }
          
    // Event Handlers
    function onOK_<%= POGrid.ClientID %>()
    {
      var record = grid_<%= POGrid.ClientID %>.getSelectionModel().getSelected();
      var args = "ProductOfferingId=" + record.data.ProductOfferingId;      
      pageNav.Execute("GroupSubscriptionsEvents_OKSelectProductOffering_Client", args, null);
    }
    
    function onCancel_<%= POGrid.ClientID %>()
    {
      pageNav.Execute("GroupSubscriptionsEvents_CancelSelectProductOffering_Client", null, null);
    }
  </script>

</asp:Content>
