<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" 
  CodeFile="FailedTransactionsView.aspx.cs" Inherits="FailedTransactionsView" Culture="auto" UICulture="auto" 
  Title="<%$Resources:Resource,TEXT_TITLE%>" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 <script src="js/AjaxProxy.js" type="text/javascript"></script>

  <MT:MTFilterGrid ID="FailedTransactionList" runat="Server" ExtensionName="SystemConfig"
    TemplateFileName="FailedTransactionLayout.xml">
  </MT:MTFilterGrid>

  <script type="text/javascript">

    var refreshEnabled = true;
    var events = new gridEvents();
    window.refreshGridTimeout = setTimeout("events.refreshGrid()", 25000);
    $(window).resize(function () {
      if (win) {
        win['center']();
      }
    });

    OverrideRenderer_<%= FailedTransactionList.ClientID %> = function (cm) {
      var caseNumberColumn = cm.getIndexById('casenumber'),
          errorMessageColumn = cm.getIndexById('errormessage'),
          statusColumn = cm.getIndexById('status'),
          actionColumn = cm.getIndexById('actions');
      if (caseNumberColumn != -1) {
        cm.setRenderer(caseNumberColumn, caseNumberColRenderer);
      }
      if (errorMessageColumn != -1) {
        cm.setRenderer(errorMessageColumn, errorMessageColRenderer);
      }
      if (statusColumn != -1) {
        cm.setRenderer(statusColumn, statusColRenderer);
      }
      if (actionColumn != -1)
        cm.setRenderer(actionColumn, actionsColRenderer);
    };

    GetTopBar_<%= FailedTransactionList.ClientID %> = function () {
      var tbar = new Ext.Toolbar([{
        xtype: 'checkbox',
        boxLabel: window.TEXT_AUTO_REFRESH,
        id: 'cbRefresh',
        checked: false,
        name: 'cbRefresh'
      }]);
      return tbar;
    };

    function gridEvents() {
      this.refreshGrid = function () {
        if (Ext.get("cbRefresh").dom.checked) {
          onRefresh();
        }
        window.refreshGridTimeout = setTimeout("events.refreshGrid()", 25000);
      };
    };

    function onRefresh() {
      if (refreshEnabled) {
        dataStore_<%= FailedTransactionList.ClientID %>.reload();
      }
    };

    function getFailedTransactionParams() {
      var params = GetFiltersToParamList_<%=FailedTransactionList.ClientID %>();
      for (var p in dataStore_<%=FailedTransactionList.ClientID %>.baseParams) {
        params[p] = dataStore_<%=FailedTransactionList.ClientID %>.baseParams[p];
      }
      //copy sortInfo
      for (var prop in dataStore_<%=FailedTransactionList.ClientID %>.sortInfo) {
        if (prop == "field")
          params["sort"] = dataStore_<%=FailedTransactionList.ClientID %>.sortInfo[prop];
        if (prop == "direction")
          params["dir"] = dataStore_<%=FailedTransactionList.ClientID %>.sortInfo[prop];
      }
      return params;
    };

  </script>

  <div id="results-win" class="x-hidden">
    <div id="UpdateStatusWindowTitle" class="x-window-header">
      <h4>
        <%= GetGlobalResourceObject("FailedTransactionResources", "TEXT_CHANGE_TRANSACTION_STATUS").ToString()%></h4>
    </div>
    <div id="result-content">
    </div>
  </div>
  <div id="loader" style="top: 50%; left: 50%; width: 100px; height: 30px; position: absolute;
    margin-top: -65px; margin-left: -15px;">
  </div>
</asp:Content>
