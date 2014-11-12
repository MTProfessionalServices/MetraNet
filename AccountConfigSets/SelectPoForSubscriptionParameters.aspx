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

      try
      {
        if(window.getFrameMetraNet().MainContentIframe)
        {
          if(window.getFrameMetraNet().MainContentIframe.ticketFrame)
          {
            if(window.getFrameMetraNet().MainContentIframe.ticketFrame.fmeTemplatePage)
            {
           
              window.getFrameMetraNet().MainContentIframe.ticketFrame.fmeTemplatePage.<%= CallbackFunction %>(ids);
            }
            else
            {            
              window.getFrameMetraNet().MainContentIframe.ticketFrame.<%= CallbackFunction %>(ids);
            }
          }
          else
          {
          if(window.getFrameMetraNet().subParamsSelectorWin2){
             window.getFrameMetraNet().subParamsSelectorWin2.<%= CallbackFunction %>(ids);
             }
          else{
             window.getFrameMetraNet().MainContentIframe.<%= CallbackFunction %>(ids);
             }
          }
        }
      }
      catch(e)
      {
        //Ext.UI.msg("Error", "Couldn't find <%= CallbackFunction %> method.");      
        Ext.UI.msg(TEXT_ERROR_MSG, TEXT_CALLBACK_MSG_1 + TEXT_CALLBACK_MSG_2);      
      }
     
      if(window.getFrameMetraNet().accountSelectorWin != null)
      {
        window.getFrameMetraNet().accountSelectorWin.close();
      }

      if(window.getFrameMetraNet().accountSelectorWin2 != null)
      {
        window.getFrameMetraNet().accountSelectorWin2.close();
      }      
      window.getFrameMetraNet().accountSelectorWin = null;
      window.getFrameMetraNet().accountSelectorWin2 = null;           
    };        
  </script>
</asp:Content>
