<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="PaymentTransactions.aspx.cs" Inherits="MetraControl_Payments_PaymentTransactions" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
<div class="CaptionBar">
  <asp:Localize meta:resourcekey="title" runat="server">Payment Transactions</asp:Localize>
</div>

<MT:MTFilterGrid ID="PaymentTransactionList" runat="Server" ExtensionName="PaymentSvr" TemplateFileName="PaymentTransactionList.xml"></MT:MTFilterGrid>

  <script type="text/javascript">

    OverrideRenderer_<%= PaymentTransactionList.ClientID %> = function(cm) {
      cm.setRenderer(cm.getIndexById('Status'), statusColRenderer);
      cm.setRenderer(cm.getIndexById('Amount'), amountColRenderer);
      cm.setRenderer(cm.getIndexById('checker'), checkerColRenderer); 
    };
      
    function checkerColRenderer(value, meta, record, rowIndex, colIndex, store) {
       if(record.data.Status == "FAILURE" || (<%= UI.CoarseCheckCapability("Manual override").ToString().ToLower()%> && record.data.Status == "MANUAL_PENDING")) {
          return"<div class='x-grid3-row-checker'>&#160;</div>";
      }
      
      return " ";
    }
      
    Ext.onReady(function(){
  
      grid_<%= PaymentTransactionList.ClientID %>.getSelectionModel().on("beforerowselect", function(sm, index, keep, record) {

        if(record.data.Status == "FAILURE" || record.data.Status == "MANUAL_PENDING") {
          return true;
        } else {
          Ext.Msg.show({
            title: "Invalid Selection",
            msg: "You may only change the state if it is in FAILURE or MANUALLY_PENDING.",
            buttons: Ext.Msg.OK,              
            icon: Ext.MessageBox.ERROR
          });
          return false;
        }
      });

    });

  </script>

  <div id="results-win" class="x-hidden"> 
    <div id="UpdateStatusWindowTitle" class="x-window-header"><h4><asp:Localize meta:resourcekey="StatusTitle" runat="server">Change Status</asp:Localize></h4></div> 
    <div id="result-content"> 
    </div> 
  </div> 
</asp:Content>

