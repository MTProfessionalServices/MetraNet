<%@ Page AutoEventWireup="true" Culture="auto" Inherits="MetraNet.Quoting.SelectPOForQuote"
  Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" CodeFile="SelectPOForQuote.aspx.cs"
  Title="MetraNet" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Reference Page="~/Quoting/CreateQuote.aspx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>
  <MT:MTFilterGrid ID="POForQuoteGrid" runat="server" TemplateFileName="Quoting.PoList.xml"
    ExtensionName="Core">
  </MT:MTFilterGrid>
  <script type="text/javascript">    
    
    // Event Handlers
    
    onOK_<%=POForQuoteGrid.ClientID %> = function()
    {
     
      var records = grid_<%=POForQuoteGrid.ClientID %>.getSelectionModel().getSelections();
      var ids = "";
      for(var i=0; i < records.length; i++)
      {
        if(i > 0)
        {
          ids += ",";
        }
        ids += records[i].data.PoId;
      }

      try
      {
        if(window.getFrameMetraNet().MainContentIframe)
        {
          if(window.getFrameMetraNet().MainContentIframe.ticketFrame)
          {
            if(window.getFrameMetraNet().MainContentIframe.ticketFrame.fmeTemplatePage)
            {
           
              window.getFrameMetraNet().MainContentIframe.ticketFrame.fmeTemplatePage.<%= CallbackFunction %>(ids, records);
            }
            else
            {            
              window.getFrameMetraNet().MainContentIframe.ticketFrame.<%= CallbackFunction %>(ids, records);
            }
          }
          else
          {
             window.getFrameMetraNet().MainContentIframe.<%= CallbackFunction %>(ids, records);
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
