<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Subscriptions_SelectPO" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="SelectPO.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>
  
  <div class="CaptionBar">
    <asp:Label ID="lblSubscribeToPOTitle" runat="server" Text="Subscribe to Product Offering" meta:resourcekey="lblSubscribeToPOTitleResource1"></asp:Label>
  </div>

  <MT:MTFilterGrid ID="MyGrid1" runat="server" TemplateFileName="POListLayoutTemplate.xml" ExtensionName="Account"></MT:MTFilterGrid>

    
  <script type="text/javascript">    
    // Custom Renderers
    OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
    {
      var internalId = cm.getIndexById('InternalInformationURL');
      if(internalId != -1)
      {
       cm.setRenderer(cm.getIndexById('InternalInformationURL'), internalColRenderer);
      }
            
      var externalId = cm.getIndexById('ExternaInformationURL');
      if(externalId != -1)
      {
       cm.setRenderer(cm.getIndexById('ExternalInformationURL'), externalColRenderer);
      }
      cm.setRenderer(cm.getIndexById('DisplayName'), hiddenIDRenderer);
      cm.setRenderer(cm.getIndexById('HasRecurringCharges'), CheckRenderer);
      cm.setRenderer(cm.getIndexById('HasDiscounts'), CheckRenderer);
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
    
    internalColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";

      // Display InternalInformationURL
      var internalUrl = record.data.InternalInformationURL;
      if(internalUrl != null)
      {
        if(internalUrl.length > 1)
        {
          str += String.format("<a href=\"JavaScript:getFrameMetraNet().Ext.UI.NewWindow('{1}', 'InternalWin', '{0}');\"><img border='0' src='/Res/Images/Icons/information.png'></a>&nbsp;", internalUrl, TEXT_INTERNAL);
        }
      }
      return str;
    }
    
    externalColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";

      // Display ExternalInformationURL
      var externalUrl = record.data.ExternalInformationURL;
      if(externalUrl != null)
      {
        if(externalUrl.length > 1)
        {
          str += String.format("<a href=\"JavaScript:getFrameMetraNet().Ext.UI.NewWindow('{1}', 'ExternalWin', '{0}');\"><img border='0' src='/Res/Images/Icons/world_go.png'></a>&nbsp;", externalUrl, TEXT_EXTERNAL);
        }
      }
      return str;
    }
        
    // Event Handlers
    function onOK_<%= MyGrid1.ClientID %>() {
      if (checkButtonClickCount() == true) {
        var record = grid_<%= MyGrid1.ClientID %>.getSelectionModel().getSelected();
        if (record != null) {
          var args = "ProductOfferingId=" + record.data.ProductOfferingId;
          pageNav.Execute("SubscriptionsEvents_SubscribeToPO_Client", args, null);
        } else {
          pageNav.Execute("SubscriptionsEvents_CancelSubscriptions_Client", null, null);
        }
      }
    }

    function onCancel_<%= MyGrid1.ClientID %>() {
      if (checkButtonClickCount() == true) {
        pageNav.Execute("SubscriptionsEvents_CancelSubscriptions_Client", null, null);
      }
    }
  </script>  
        
</asp:Content>

