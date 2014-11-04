<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="AccountConfigSetSubscriptionParamsList.aspx.cs" Inherits="MetraNet.AccountConfigSets.AccountConfigSetSubscriptionParamsList" Title="MetraNet - SubscriptionParamst for OnBoard templates" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <MT:MTTitle ID="AccountConfigSetListTitle" Text="OnBoard Templates List" runat="server" meta:resourcekey="AccountConfigSetTitle" /><br />

  <MT:MTFilterGrid ID="AccountConfigSetListGrid" runat="server" ExtensionName="Core" 
    TemplateFileName="AccountConfigSets.SubscriptionParamsList" ButtonAlignment="Center" 
    Buttons="None" DefaultSortDirection="Ascending" DisplayCount="True" 
    EnableColumnConfig="True" EnableFilterConfig="True" EnableLoadSearch="False" 
    EnableSaveSearch="False" Expandable="False" ExpansionCssClass="" 
    Exportable="False" FilterColumnWidth="350" FilterInputWidth="220" 
    FilterLabelWidth="75" FilterPanelCollapsed="False" 
    FilterPanelLayout="MultiColumn" 
    MultiSelect="True" PageSize="10" 
    Resizable="True" RootElement="Items" SearchOnLoad="True" 
    SelectionModel="Checkbox" ShowBottomBar="True" ShowColumnHeaders="True" 
    ShowFilterPanel="True" ShowGridFrame="True" ShowGridHeader="True" 
    ShowTopBar="True" TotalProperty="TotalRows">
  </MT:MTFilterGrid>
  
  <script type="text/javascript">    

    function onNew_<%= AccountConfigSetListGrid.ClientID %>() {      
      document.location.href = "ManageAccountConfigSetSubscriptionParams.aspx?mode=ADD";
    }
    
    onOK_<%=AccountConfigSetListGrid.ClientID %> = function(){
     
      var records = grid_<%=AccountConfigSetListGrid.ClientID %>.getSelectionModel().getSelections();
      var ids = "";
      for(var i=0; i < records.length; i++)
      {
        if(i > 0)
        {
          ids += ",";
        }
        ids += records[i].data.AccountConfigSetParametersId;
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
             window.getFrameMetraNet().MainContentIframe.<%= CallbackFunction %>(ids);
          }
        }
      }
      catch(e)
      {
        //Ext.UI.msg("Error", "Couldn't find <%= CallbackFunction %> method.");      
        Ext.UI.msg(TEXT_ERROR_MSG, TEXT_CALLBACK_MSG_1 + TEXT_CALLBACK_MSG_2);      
      }
     
      if(window.getFrameMetraNet().subParamsSelectorWin2 != null)
      {
        window.getFrameMetraNet().subParamsSelectorWin2.hide();
        window.getFrameMetraNet().subParamsSelectorWin2.close();
      }
      
      window.getFrameMetraNet().subParamsSelectorWin2 = null;
    };

  </script>
</asp:Content>