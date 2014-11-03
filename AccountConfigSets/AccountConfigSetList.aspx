<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="AccountConfigSetList.aspx.cs" Inherits="MetraNet.AccountConfigSets.AccountConfigSetList" Title="MetraNet - OnBoard templates" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <MT:MTTitle ID="AccountConfigSetListTitle" Text="OnBoard Templates List" runat="server" meta:resourcekey="AccountConfigSetTitle" /><br />

  <MT:MTFilterGrid ID="AccountConfigSetListGrid" runat="server" ExtensionName="Core" 
    TemplateFileName="AccountConfigSets.AccountConfigSetList" ButtonAlignment="Center" 
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
    var textDelete = '<%=GetGlobalResourceObject("JSConsts", "TEXT_DELETE")%>';
    var textTerminate = '<%=GetGlobalResourceObject("JSConsts", "TEXT_TERMINATE")%>';
    var textView = '<%=GetGlobalResourceObject("JSConsts", "TEXT_VIEW")%>';    
    
    OverrideRenderer_<%=AccountConfigSetListGrid.ClientID%> = function(cm) {
      cm.setRenderer(cm.getIndexById('Actions'), actionsColumnRenderer);
    };

    function actionsColumnRenderer(value, meta, record) {
      var str = "";
      var entityId = record.data.AcsId;
      
      // Edit ACS
      str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"edit\" href=\"ManageAccountConfigSet.aspx?mode=EDIT&acsId={0}\"><img src=\"/Res/Images/icons/table_edit.png\" title=\"{1}\" alt=\"{1}\"/></a>", entityId, String.escape(textEdit));

      // View ACS      
      str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"view\" href=\"ManageAccountConfigSet.aspx?mode=VIEW&acsId={0}\"><img src=\"/Res/Images/icons/application_view_detail.png\" title=\"{1}\" alt=\"{1}\"/></a>", entityId, String.escape(textView));
      
      // Delete ACS     
      str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"delete\" href=\"javascript:onDelete('{0}')\"><img src=\"/Res/Images/icons/cross.png\" title=\"{1}\" alt=\"{1}\"/></a>", entityId, String.escape(textDelete));
      
      if(record.data.Enabled)
      // Terminate ACS     
      str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"delete\" href=\"javascript:onTerminate('{0}')\"><img src=\"/Res/Images/icons/stop2.png\" title=\"{1}\" alt=\"{1}\"/></a>", entityId, String.escape(textTerminate));
      
      return str;
    }

    function onNew_<%= AccountConfigSetListGrid.ClientID %>() {      
      document.location.href = "ManageAccountConfigSet.aspx?mode=ADD";
    }
    
    function onDelete(entityId) {
      top.Ext.MessageBox.show({
        title: textDelete,
        msg: String.format('<%=GetGlobalResourceObject("JSConsts", "TEXT_DELETE_MESSAGE")%>', entityId),
        buttons: window.Ext.MessageBox.OKCANCEL,
        fn: function(btn) {
          if (btn == 'ok') {
            window.CallServer(JSON.stringify({ action: 'deleteOne', entityId: entityId }));
          }
        },
        animEl: 'elId',
        icon: window.Ext.MessageBox.QUESTION
      });
      
      var dlg = top.Ext.MessageBox.getDialog();
	    var buttons = dlg.buttons;
	    for (i = 0; i < buttons.length; i++) {
      buttons[i].addClass('custom-class');
     }
    }

    function onTerminate(entityId) {
      top.Ext.MessageBox.show({
        title: textTerminate,
        msg: String.format('<%=GetGlobalResourceObject("JSConsts", "TEXT_TERMINATE_MESSAGE")%>', entityId),
        buttons: window.Ext.MessageBox.OKCANCEL,
        fn: function(btn) {
          if (btn == 'ok') {
            window.CallServer(JSON.stringify({ action: 'terminateOne', entityId: entityId }));
          }
        },
        animEl: 'elId',
        icon: window.Ext.MessageBox.QUESTION
      });
      
      var dlg = top.Ext.MessageBox.getDialog();
	    var buttons = dlg.buttons;
	    for (i = 0; i < buttons.length; i++) {
      buttons[i].addClass('custom-class');
     }
    }
    
    function onDeleteBulk_<%= AccountConfigSetListGrid.ClientID %>() {
      var entityIds = GetAcsIds();

      if (entityIds.length == 0)
      {
        return;
      }

      top.Ext.MessageBox.show({
        title: textDelete,
        msg: '<%=GetGlobalResourceObject("JSConsts", "TEXT_DELETE_SELECTED_ROWS")%>',
        buttons: window.Ext.MessageBox.OKCANCEL,
        fn: function(btn) {
          if (btn == 'ok') {
            window.CallServer(JSON.stringify({ action: 'deleteBulk', entityIds: entityIds }));
          }
        },
        animEl: 'elId',
        icon: window.Ext.MessageBox.QUESTION
      });
      
        var dlg = top.Ext.MessageBox.getDialog();
	      var buttons = dlg.buttons;
	      for (i = 0; i < buttons.length; i++) {
        buttons[i].addClass('custom-class');
      }
    }

    function onTerminateBulk_<%= AccountConfigSetListGrid.ClientID %>() {
      var entityIds = GetAcsIds();

      if (entityIds.length == 0)
      {
        return;
      }

      top.Ext.MessageBox.show({
        title: textTerminate,
        msg: '<%=GetGlobalResourceObject("JSConsts", "TEXT_TERMINATE_SELECTED_ROWS")%>',
        buttons: window.Ext.MessageBox.OKCANCEL,
        fn: function(btn) {
          if (btn == 'ok') {
            window.CallServer(JSON.stringify({ action: 'terminateBulk', entityIds: entityIds }));
          }
        },
        animEl: 'elId',
        icon: window.Ext.MessageBox.QUESTION
      });
      
        var dlg = top.Ext.MessageBox.getDialog();
	      var buttons = dlg.buttons;
	      for (i = 0; i < buttons.length; i++) {
        buttons[i].addClass('custom-class');
      }
    }
    
    function GetAcsIds()
    {
      var records = grid_<%= AccountConfigSetListGrid.ClientID %>.getSelectionModel().getSelections();
      var quoteIds = "";
      for(var i = 0; i < records.length; i++)
      {
        if(i > 0)
        {
          quoteIds += ",";
        }
        quoteIds += records[i].data.AcsId;
      }
      return quoteIds;
    }

    function ReceiveServerData(value) {
      if (typeof value !== 'string' || value === '') {
        return;
      }
      var response = JSON.parse(value);
      if (response.result !== 'ok') {
        window.Ext.UI.SystemError(response.errorMessage);
      }
      grid_<%= AccountConfigSetListGrid.ClientID %>.store.reload();
      grid_<%= AccountConfigSetListGrid.ClientID %>.getSelectionModel().clearSelections();
    }

  </script>
</asp:Content>