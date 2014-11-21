<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="AccountConfigSetSubscriptionParamsList.aspx.cs" Inherits="MetraNet.AccountConfigSets.AccountConfigSetSubscriptionParamsList" Title="MetraNet - SubscriptionParamst for OnBoard templates" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Reference Page="~/AccountConfigSets/ManageAccountConfigSet.aspx" %>
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
    var textEdit = '<%=GetGlobalResourceObject("JSConsts", "TEXT_EDIT")%>';
    var textView = '<%=GetGlobalResourceObject("JSConsts", "TEXT_VIEW")%>';
    
    OverrideRenderer_<%=AccountConfigSetListGrid.ClientID%> = function(cm) {
      cm.setRenderer(cm.getIndexById('Actions'), actionsColumnRenderer);
    };

    function actionsColumnRenderer(value, meta, record) {
      var str = "";
      var entityId = record.data.AccountConfigSetParametersId;
      
      // Edit ACS
      str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"edit\" href=\"ManageSubscriptionParameters.aspx?mode=EDIT&acsId={0}\"><img src=\"/Res/Images/icons/table_edit.png\" title=\"{1}\" alt=\"{1}\"/></a>", entityId, String.escape(textEdit));

      // View ACS      
      str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"view\" href=\"ManageSubscriptionParameters.aspx?mode=VIEW&acsId={0}\"><img src=\"/Res/Images/icons/application_view_detail.png\" title=\"{1}\" alt=\"{1}\"/></a>", entityId, String.escape(textView));
      
      return str;
    }


    function onNew_<%= AccountConfigSetListGrid.ClientID %>() {      
      document.location.href = "ManageSubscriptionParameters.aspx?mode=ADD";
    }
    
    onOK_<%=AccountConfigSetListGrid.ClientID %> = function()
    {
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

      try {
        var mainFrame = window.getFrameMetraNet().MainContentIframe;
        if (mainFrame) {
          if (mainFrame.ticketFrame) {
            if (mainFrame.ticketFrame.fmeTemplatePage) {
              mainFrame.ticketFrame.fmeTemplatePage.<%= CallbackFunction %>(ids);
            } else {
              mainFrame.ticketFrame.<%= CallbackFunction %>(ids);
            }
          } else {
            mainFrame.<%= CallbackFunction %>(ids);
          }
        }
      } catch(e) {
        window.Ext.UI.msg(window.TEXT_ERROR_MSG, window.TEXT_CALLBACK_MSG_1 + " <%= CallbackFunction %> " + window.TEXT_CALLBACK_MSG_2);
      }
    };  

  </script>
</asp:Content>