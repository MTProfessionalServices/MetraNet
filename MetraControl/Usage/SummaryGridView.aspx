<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="SummaryGridView.aspx.cs" Inherits="SummaryGridView" Title="<%$Resources:Resource,TEXT_TITLE%>"  Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <table><tr><td valign="top">  
    <MT:MTFilterGrid ID="SummaryGrid" runat="Server" ExtensionName="SystemConfig"></MT:MTFilterGrid>
  </td><td valign="top">
    <br /><div id="chartContainer"></div> 
  </td></tr></table>

 <MT:MTFilterGrid ID="SummaryDetailsGrid" runat="Server"  ExtensionName="SystemConfig" TemplateFileName="This comes from the template file sub grid section..."></MT:MTFilterGrid>
 <MT:MTFilterGrid ID="BeforeAfterGrid" runat="Server"  ExtensionName="SystemConfig" TemplateFileName="UsageBeforeAfterAuditLayout"></MT:MTFilterGrid>

    <script type="text/javascript">

      Ext.onReady(function() {
        var grid = grid_ctl00_ContentPlaceHolder1_SummaryGrid;
        grid.on('rowclick', function (grid, rowIndex, e) {
          grid.getSelectionModel().selectRow(rowIndex);
          var row = grid.store.getAt(rowIndex);
          onShowBeforeAfterGrid(row);
        });
      });
      function onShowBeforeAfterGrid(row) {
        //Set filter based on current row
        var elm;
        elm = Ext.getCmp('filter_id_usage_interval_ctl00_ContentPlaceHolder1_BeforeAfterGrid');
        if (elm != null)
          elm.setValue(row.data.id_usage_interval);
        elm = Ext.getCmp('filter_id_sess_ctl00_ContentPlaceHolder1_BeforeAfterGrid');
        if (elm != null)
          elm.setValue(row.data.id_sess);
        elm = Ext.getCmp('filter_nm_pv_table_ctl00_ContentPlaceHolder1_BeforeAfterGrid');
        if (elm != null)
          elm.setValue(row.data.nm_pv_table);
        elm = Ext.getCmp('combo_filter_b_changed_ctl00_ContentPlaceHolder1_BeforeAfterGrid');
        if (elm != null)
          elm.setValue('Yes');

        //After setting the filter, ask the child grid to refresh
        Reload_ctl00_ContentPlaceHolder1_BeforeAfterGrid();
      }
      function AfterSearch_ctl00_ContentPlaceHolder1_SummaryDetailsGrid() {
        filterPanel_ctl00_ContentPlaceHolder1_SummaryDetailsGrid.setVisible(true);
        filterPanel_ctl00_ContentPlaceHolder1_BeforeAfterGrid.setVisible(true);
        Ext.get('filterPanel_div_ctl00_ContentPlaceHolder1_SummaryDetailsGrid').dom.style.display = 'block';
        Ext.get('filterPanel_div_ctl00_ContentPlaceHolder1_BeforeAfterGrid').dom.style.display = 'block';
      }

      Ext.onReady(function() {
        filterPanel_ctl00_ContentPlaceHolder1_SummaryDetailsGrid.setVisible(false);
        filterPanel_ctl00_ContentPlaceHolder1_BeforeAfterGrid.setVisible(false);
        Ext.get('filterPanel_div_ctl00_ContentPlaceHolder1_SummaryDetailsGrid').dom.style.display = 'none';
        Ext.get('filterPanel_div_ctl00_ContentPlaceHolder1_BeforeAfterGrid').dom.style.display = 'none';
      }); 

    </script>


  <script type="text/javascript">
  OverrideRenderer_<%= SummaryDetailsGrid.ClientID %> = function(cm)
  {
/*    cm.setRenderer(cm.getIndexById('casenumber'), caseNumberColRenderer);
    cm.setRenderer(cm.getIndexById('errormessage'), errorMessageColRenderer);
    cm.setRenderer(cm.getIndexById('status'), statusColRenderer); */
  }
  </script>

  <div id="results-win" class="x-hidden"> 
    <div id="UpdateStatusWindowTitle" class="x-window-header">TEXT_CHANGE_TRANSACTION_STATUS</div> 
    <div id="result-content"> 
    </div> 
  </div> 


</asp:Content>

