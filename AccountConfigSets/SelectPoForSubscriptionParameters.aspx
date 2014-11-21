<%@ Page AutoEventWireup="true" Culture="auto" Inherits="MetraNet.AccountConfigSets.SelectPoForSubscriptionParameters"
  Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" CodeFile="SelectPoForSubscriptionParameters.aspx.cs"
  Title="MetraNet" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>
  <MT:MTFilterGrid ID="POListGrid" runat="server" TemplateFileName="AccountConfigSets.PoList.xml"
    ExtensionName="Core">
  </MT:MTFilterGrid>
  <script type="text/javascript">    
    
    // Event Handlers
    
    onOK_<%=POListGrid.ClientID %> = function()
    {
      var records = grid_<%=POListGrid.ClientID %>.getSelectionModel().getSelections();
      var ids = "";
      for(var i=0; i < records.length; i++)
      {
        if(i > 0)
        {
          ids += ",";
        }
        ids += records[i].data.ProductOfferingId;
      }

      try {
        var mainFrame = window.getFrameMetraNet().MainContentIframe;
        var subpFrame = window.getFrameMetraNet().Ext.getDom("subParamsSelectorWin2");
        if (mainFrame) {
          if (mainFrame.ticketFrame) {
            if (mainFrame.ticketFrame.fmeTemplatePage) {
              mainFrame.ticketFrame.fmeTemplatePage.<%= CallbackFunction %>(ids);
            } else {
              mainFrame.ticketFrame.<%= CallbackFunction %>(ids);
            }
          } else {
            if (subpFrame) {
              if (subpFrame.contentWindow) 
                subpFrame.contentWindow.<%= CallbackFunction %>(ids);
               else 
                subpFrame.<%= CallbackFunction %>(ids);
            } else {
              mainFrame.<%= CallbackFunction %>(ids);
            }
          }
        }
      } catch(e) {
        window.Ext.UI.msg(window.TEXT_ERROR_MSG, window.TEXT_CALLBACK_MSG_1 + " <%= CallbackFunction %> " + window.TEXT_CALLBACK_MSG_2);
      }
    };        
  </script>
</asp:Content>
