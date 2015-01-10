<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="FailedTransactionSummaryGridView.aspx.cs" Inherits="FailedTransactionSummaryGridView" Title="<%$Resources:Resource,TEXT_TITLE%>"  Culture="auto" UICulture="auto" %>
<%@ Import Namespace="Resources" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <table>
    <tr>
      <td valign="top">
        <MT:MTFilterGrid ID="SummaryGrid" runat="Server" ExtensionName="SystemConfig"></MT:MTFilterGrid>
      </td>
      <td valign="top">
        <br />
        <div id="chartContainer"></div> 
      </td>
    </tr>
  </table>
  <MT:MTFilterGrid ID="SummaryDetailsGrid" runat="Server"  ExtensionName="SystemConfig" TemplateFileName="This comes from the template file sub grid section..."></MT:MTFilterGrid>

  <script type="text/javascript">
    function AfterSearch_ctl00_ContentPlaceHolder1_SummaryDetailsGrid() {
      filterPanel_ctl00_ContentPlaceHolder1_SummaryDetailsGrid.setVisible(true);
      window.Ext.get('filterPanel_div_ctl00_ContentPlaceHolder1_SummaryDetailsGrid').dom.style.display = 'block';
    }

    Ext.onReady(function() {
      filterPanel_ctl00_ContentPlaceHolder1_SummaryDetailsGrid.setVisible(false);
      window.Ext.get('filterPanel_div_ctl00_ContentPlaceHolder1_SummaryDetailsGrid').dom.style.display = 'none';
    }); 
  </script>
  
  <script type="text/javascript">
    OverrideRenderer_<%= SummaryDetailsGrid.ClientID %> = function(cm) {
      cm.setRenderer(cm.getIndexById('casenumber'), caseNumberColRenderer);
      cm.setRenderer(cm.getIndexById('errormessage'), errorMessageColRenderer);
      cm.setRenderer(cm.getIndexById('status'), statusColRenderer);
    }
  </script>

  <div id="results-win" class="x-hidden"> 
    <div id="UpdateStatusWindowTitle" class="x-window-header" > "<%= GetGlobalResourceObject("FailedTransactionResources", "TEXT_CHANGE_TRANSACTION_STATUS")%>"</div> 
    <div id="result-content"> 
    </div> 
  </div> 

</asp:Content>

