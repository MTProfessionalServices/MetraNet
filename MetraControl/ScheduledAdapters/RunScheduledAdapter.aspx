<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="RunScheduledAdapter.aspx.cs" Inherits="MetraNet.MetraControl.ScheduledAdapters.RunScheduledAdapter" %>
<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="RunScheduledAdapterMTTitle" runat="server" meta:resourcekey="RunScheduledAdapterMTTitle" />  
  <MT:MTFilterGrid ID="RunScheduledAdapterGrid" runat="server" TemplateFileName="RunScheduledAdapterGrid" ExtensionName="Core" />
  
  <script type="text/javascript">

    function onRun_<%= RunScheduledAdapterGrid.ClientID %>() {
      var eventIds = GetEventIds();

      if (eventIds.length == 0) {
        top.Ext.Msg.show({
          title: 'Warning',
          msg: 'No adapters were selected for execution',
          buttons: Ext.Msg.OK,
          icon: Ext.MessageBox.WARNING
        });
        var dlg = top.Ext.MessageBox.getDialog();
        var buttons = dlg.buttons;
        for (var i = 0; i < buttons.length; i++) {
          buttons[i].addClass('custom-class');
        }
        return;
      }

      window.CallServer(JSON.stringify({ action: 'run', eventIds: eventIds }));
    }
    
    function GetEventIds() {
      var records = grid_<%= RunScheduledAdapterGrid.ClientID %>.getSelectionModel().getSelections();
      
      var eventIds = "";
      for(var i = 0; i < records.length; i++)
      {
        if(i > 0)
        {
          eventIds += ",";
        }
        eventIds += records[i].data.id_event;
      }
      return eventIds;
    }

    function ReceiveServerData(value) {
      if (typeof value !== 'string' || value === '') {
        return;
      }
      var response = JSON.parse(value);
      if (response.result == 'ok') {
        top.Ext.MessageBox.show({
          title: 'Success',
          msg: response.message,
          buttons: window.Ext.MessageBox.OK,
          icon: window.Ext.MessageBox.INFO
        });
      } else {
        window.Ext.UI.SystemError(response.errorMessage);
      }

      var dlg = top.Ext.MessageBox.getDialog();
      var buttons = dlg.buttons;
      for (var i = 0; i < buttons.length; i++) {
        buttons[i].addClass('custom-class');
      }

      grid_<%= RunScheduledAdapterGrid.ClientID %>.store.reload();
      grid_<%= RunScheduledAdapterGrid.ClientID %>.getSelectionModel().clearSelections();
    }

  </script>

</asp:Content>
