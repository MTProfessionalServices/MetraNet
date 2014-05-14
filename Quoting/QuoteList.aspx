<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="QuoteList.aspx.cs" Inherits="MetraNet.Quoting.QuotesList" Title="MetraNet - Update Account" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <MT:MTTitle ID="QuoteListTitle" Text="Quotes List" runat="server" meta:resourcekey="QuoteListTitle" /><br />

  <MT:MTFilterGrid ID="QuoteListGrid" runat="server" ExtensionName="Core" 
    TemplateFileName="Quoting.ListQuotes" ButtonAlignment="Center" 
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
    var textConvert = '<%=GetGlobalResourceObject("JSConsts", "TEXT_CONVERT")%>';
    var textView = '<%=GetGlobalResourceObject("JSConsts", "TEXT_VIEW")%>';
    
    OverrideRenderer_<%=QuoteListGrid.ClientID%> = function(cm) {
      cm.setRenderer(cm.getIndexById('Actions'), actionsColumnRenderer);
    };

    function actionsColumnRenderer(value, meta, record) {
      var str = "";
      var entityId = record.data.IdQuote;
      var status = String.format("{0}", record.data.Status);

      // Convert Quote  
      if(status == 'Complete')
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"convert\" href=\"javascript:onConvert('{0}')\"><img src=\"/Res/Images/icons/arrow_rotate_clockwise.png\" title=\"{1}\" alt=\"{1}\"/></a>", entityId, String.escape(textConvert));

//      // Edit Quote
//      str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"edit\" href=\"javascript:onEdit('{0}')\"><img src=\"/Res/Images/icons/table_edit.png\" title=\"{1}\" alt=\"{1}\"/></a>", entityId, String.escape(textEdit));

      // View Quote     
      str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"delete\" href=\"CreateQuote.aspx?mode=VIEW&quoteId={0}\"><img src=\"/Res/Images/icons/application_view_detail.png\" title=\"{1}\" alt=\"{1}\"/></a>", entityId, String.escape(textView));
      
      // Delete Quote     
      str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"delete\" href=\"javascript:onDelete('{0}')\"><img src=\"/Res/Images/icons/cross.png\" title=\"{1}\" alt=\"{1}\"/></a>", entityId, String.escape(textDelete));
      return str;
    }

    function onNew_<%= QuoteListGrid.ClientID %>() {
      var accountsFilterValue = "<%= AccountsFilterValue %>";
      document.location.href = String.format("CreateQuote.aspx{0}", accountsFilterValue == "ALL" ? "" : "?Accounts=ONE");
    }
    
    function onEdit(entityId) {
      alert("Does not implement");
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
    }
    
    function onDeleteBulk_<%= QuoteListGrid.ClientID %>() {
      var entityIds = GetQuoteIds();

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
    }
    
    function onConvert(entityId) {
      top.Ext.MessageBox.show({
        title: textConvert,
        msg: String.format('<%=GetGlobalResourceObject("JSConsts", "TEXT_CONVERT_MESSAGE")%>', entityId),
        buttons: window.Ext.MessageBox.OKCANCEL,
        fn: function(btn) {
          if (btn == 'ok') {
            window.CallServer(JSON.stringify({ action: 'convertOne', entityId: entityId }));
          }
        },
        animEl: 'elId',
        icon: window.Ext.MessageBox.QUESTION
      });
    }
    
    function GetQuoteIds()
    {
      var records = grid_<%= QuoteListGrid.ClientID %>.getSelectionModel().getSelections();
      var quoteIds = "";
      for(var i = 0; i < records.length; i++)
      {
        if(i > 0)
        {
          quoteIds += ",";
        }
        quoteIds += records[i].data.IdQuote;
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
      grid_<%= QuoteListGrid.ClientID %>.store.reload();
      grid_<%= QuoteListGrid.ClientID %>.getSelectionModel().clearSelections();
    }

  </script>
</asp:Content>