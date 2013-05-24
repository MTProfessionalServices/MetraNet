<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="FailedTransactionsView.aspx.cs" Inherits="FailedTransactionsView" Culture="auto" UICulture="auto" Title="<%$Resources:Resource,TEXT_TITLE%>" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<MT:MTFilterGrid ID="FailedTransactionList" runat="Server" ExtensionName="SystemConfig" TemplateFileName="FailedTransactionLayout.xml"></MT:MTFilterGrid>

  <script type="text/javascript">
  OverrideRenderer_<%= FailedTransactionList.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('casenumber'), caseNumberColRenderer);
    cm.setRenderer(cm.getIndexById('errormessage'), errorMessageColRenderer);
    cm.setRenderer(cm.getIndexById('status'), statusColRenderer); 
    cm.setRenderer(cm.getIndexById('actions'), actionsColRenderer); 
  }
  </script>

  <div id="results-win" class="x-hidden"> 
    <div id="UpdateStatusWindowTitle" class="x-window-header"><h4><%= GetGlobalResourceObject("FailedTransactionResources", "TEXT_CHANGE_TRANSACTION_STATUS").ToString()%></h4></div> 
    <div id="result-content"> 
    </div> 
  </div> 
</asp:Content>

