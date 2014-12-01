<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true"
  CodeFile="RunScheduledAdapter.aspx.cs" Inherits="MetraNet.MetraControl.ScheduledAdapters.RunScheduledAdapter" %>

<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <MT:MTTitle ID="RunScheduledAdapterMTTitle" runat="server" />
  <MT:MTFilterGrid ID="RunScheduledAdapterGrid" runat="server" TemplateFileName="RunScheduledAdapterGrid.xml"
    ExtensionName="Core" />
  <script type="text/javascript">
    OverrideRenderer_<%= RunScheduledAdapterGrid.ClientID %> = function(cm) {
      cm.setRenderer(cm.getIndexById('tx_display_name'), DisplayNameRenderer);
      cm.setRenderer(cm.getIndexById('tx_desc'), DescriptionRenderer);
    };
    
    function DisplayNameRenderer(value, meta, record) {
      var displayNameText = String.format("<b><img src='/Res/Images/adapter_scheduled.gif' align='absmiddle' border='0'/>&nbsp;{0}</b>", record.data.tx_display_name);
      return displayNameText;
    }
    
    function DescriptionRenderer(value, meta, record) {
      return record.data.tx_desc;
    }
    
    var textSuccess = '<%=GetGlobalResourceObject("JSConsts", "SUCCESS")%>';
    var titleNoSelection = '<%=GetGlobalResourceObject("JSConsts", "TEXT_NO_SELECTION")%>';
    var textNoSelection = '<%=GetGlobalResourceObject("JSConsts", "TEXT_ERROR_SELECT")%>';
    
    function onCancel_<%= RunScheduledAdapterGrid.ClientID %>() {
      window.location.href = "/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/ScheduledAdapter.Run.List.asp";
      return false;
    }

    function onRun_<%= RunScheduledAdapterGrid.ClientID %>() {
      var eventIds = GetEventIds();

      if (eventIds.length == 0) {
        top.Ext.Msg.show({
          title: titleNoSelection,
          msg: textNoSelection,
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
        onCancel_<%= RunScheduledAdapterGrid.ClientID %>();
      } else {
        window.Ext.UI.SystemError(response.errorMessage);
      }
    }

  </script>
</asp:Content>
