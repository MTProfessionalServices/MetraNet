<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="SummaryGridView.aspx.cs" Inherits="SummaryGridView" Title="<%$Resources:Resource,TEXT_TITLE%>"  Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 <MT:MTFilterGrid ID="SummaryGrid" runat="Server" ExtensionName="SystemConfig"></MT:MTFilterGrid>
 <MT:MTFilterGrid ID="SummaryDetailsGrid" runat="Server"  ExtensionName="SystemConfig" TemplateFileName="UsageBeforeAfterAuditLayout"></MT:MTFilterGrid>
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

</asp:Content>

