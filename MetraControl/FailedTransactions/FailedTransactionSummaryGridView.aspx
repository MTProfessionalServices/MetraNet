<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="FailedTransactionSummaryGridView.aspx.cs" Inherits="FailedTransactionSummaryGridView" Title="<%$Resources:Resource,TEXT_TITLE%>"  Culture="auto" UICulture="auto" %>
<%@ Import Namespace="Resources" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 <script src="js/AjaxProxy.js" type="text/javascript"></script>
  <table>
    <tr>
      <td valign="top">
        <MT:MTFilterGrid ID="SummaryGrid" runat="Server" ExtensionName="SystemConfig">
        </MT:MTFilterGrid>
      </td>
      <td valign="top">
        <br />
        <div id="chartContainer">
        </div>
      </td>
    </tr>
  </table>
  <MT:MTFilterGrid ID="SummaryDetailsGrid" runat="Server" ExtensionName="SystemConfig"
    TemplateFileName="This comes from the template file sub grid section...">
  </MT:MTFilterGrid>
  <script type="text/javascript">

    var refreshEnabledSummaryGrid = false,
        refreshEnabled = true,
        subGridRefresh;
    createRefreshElements();

    $(window).resize(function () {
      if (win) {
        win['center']();
      }
    });

    this.events = new RunRefreshProcess();
    window.refreshGridTimeout = setTimeout("this.events.refreshGrid()", 25000);

    function RunRefreshProcess() {
      this.refreshGrid = function () {
        if (Ext.get('cbRefreshSummaryGrid') && Ext.get('cbRefreshSummaryGrid').dom.checked) {
          if (refreshEnabled) {
            dataStore_<%=SummaryGrid.ClientID %>.reload();
          }
        }
        if (Ext.get('cbRefreshSummaryDetailsGrid') && Ext.get('cbRefreshSummaryDetailsGrid').dom.checked) {
          if (refreshEnabledSummaryGrid) {
            dataStore_<%=SummaryDetailsGrid.ClientID %>.reload();
          }
        }
        window.refreshGridTimeout = setTimeout("events.refreshGrid()", 25000);
      };
    };

    function createRefreshElements() {
      GetTopBar_<%=SummaryDetailsGrid.ClientID %> = function () {
        var tbar = new Ext.Toolbar([{
          xtype: 'checkbox',
          boxLabel: window.TEXT_AUTO_REFRESH,
          id: 'cbRefreshSummaryDetailsGrid',
          checked: false,
          name: 'cbRefreshSummaryDetailsGrid'
        }]);
        return tbar;
      };

      GetTopBar_<%=SummaryGrid.ClientID %> = function () {
        var tbar = new Ext.Toolbar([{
          xtype: 'checkbox',
          boxLabel: window.TEXT_AUTO_REFRESH,
          id: 'cbRefreshSummaryGrid',
          checked: false,
          name: 'cbRefreshSummaryGrid'
        }]);
        return tbar;
      };
    };

    function AfterSearch_ctl00_ContentPlaceHolder1_SummaryDetailsGrid() {
      filterPanel_<%= SummaryDetailsGrid.ClientID %>.setVisible(true);
      window.refreshEnabledSummaryGrid = true;

      Ext.get(filterPanel_div_<%= SummaryDetailsGrid.ClientID %>).dom.style.display = 'block';
    };

    Ext.onReady(function () {
      filterPanel_<%= SummaryDetailsGrid.ClientID %>.setVisible(false);
      window.refreshEnabledSummaryGrid = false;
      Ext.get(filterPanel_div_<%= SummaryDetailsGrid.ClientID %>).dom.style.display = 'none';
    });

    Ext.onReady(function () {
      subGridRefresh = dataStore_<%=SummaryGrid.ClientID%>;
    });

    OverrideRenderer_<%= SummaryDetailsGrid.ClientID %> = function (cm) {
      var caseNumberColumn = cm.getIndexById('casenumber'),
          errorMessageColumn = cm.getIndexById('errormessage'),
          statusColumn = cm.getIndexById('status');
      if (caseNumberColumn != -1) {
        cm.setRenderer(caseNumberColumn, caseNumberColRenderer);
      }
      if (errorMessageColumn != -1) {
        cm.setRenderer(cm.getIndexById('errormessage'), errorMessageColRenderer);
      }
      if (statusColumn != -1) {
        cm.setRenderer(cm.getIndexById('status'), statusColRenderer);
      }
    };

    function getFailedTransactionParams() {
      var params = GetFiltersToParamList_<%=SummaryDetailsGrid.ClientID %>();
      for (var p in dataStore_<%=SummaryDetailsGrid.ClientID %>.baseParams) {
        params[p] = dataStore_<%=SummaryDetailsGrid.ClientID %>.baseParams[p];
      }
      //copy sortInfo
      for (var prop in dataStore_<%=SummaryDetailsGrid.ClientID %>.sortInfo) {
        if (prop == "field")
          params["sort"] = dataStore_<%=SummaryDetailsGrid.ClientID %>.sortInfo[prop];
        if (prop == "direction")
          params["dir"] = dataStore_<%=SummaryDetailsGrid.ClientID %>.sortInfo[prop];
      }
      var template = "<%=Request["SummaryGrid_TemplateFileName"] %>";
      params['queryParam'] = "";
      switch (template.toLocaleLowerCase()) {
        case 'FailedTransactionIntervalTypeSummaryLayout'.toLocaleLowerCase():
          params['queryParam'] = 'GetTransactionIntervalTypeDetail';
          break;
        default:
          params['queryParam'] = 'GetUnresolvedFailedTransactionList';
          break;
      }
      return params;
    };

  </script>
  <div id="results-win" class="x-hidden">
    <div id="UpdateStatusWindowTitle" class="x-window-header">
       <h4> <%= GetGlobalResourceObject("FailedTransactionResources", "TEXT_CHANGE_TRANSACTION_STATUS").ToString()%></h4>
    </div>
    <div id="result-content">
    </div>
  </div>
    <div id="loader" style="top: 50%; left: 50%; width: 100px; height: 30px; position: absolute;
    margin-top: -65px; margin-left: -15px;">
  </div>
</asp:Content>

