<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master"  AutoEventWireup="true" 
  CodeFile="FailedTransactionPendingResubmits.aspx.cs" Inherits="FailedTransactionInResubmit" Culture="auto" 
  UICulture="auto"  %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <script src="js/AjaxProxy.js" type="text/javascript"></script>

  <MT:MTFilterGrid ID="FailedTransactionPendingResubmitsList" runat="Server" ExtensionName="SystemConfig" 
    TemplateFileName="FailedTransactionPendingResubmits.xml">
  </MT:MTFilterGrid>

  <script type="text/javascript">
    var refreshEnabled = true;
    $(window).resize(function() {
      if(win) {
        win['center']();
      }
    });
    
     OverrideRenderer_<%= FailedTransactionPendingResubmitsList.ClientID %> = function(cm) {
       var errorMessageColumn = cm.getIndexById('errormessage'),
           statusColumn = cm.getIndexById('status');
       if(errorMessageColumn != -1) {
         cm.setRenderer(errorMessageColumn, errorMessageColRenderer);
       }
       if(statusColumn != -1) {
         cm.setRenderer(statusColumn, statusColRenderer);
       }
     };
    GetTopBar_<%= FailedTransactionPendingResubmitsList.ClientID %> = function () {
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
      this.refreshGrid = function() {
        if (Ext.get("cbRefresh") && Ext.get("cbRefresh").dom.checked) {
          onRefresh();
        }
        window.refreshGridTimeout = setTimeout("events.refreshGrid()", 25000);
      };
    };
    // start event polling
   var events = new gridEvents();
   window.refreshGridTimeout = setTimeout("events.refreshGrid()", 25000);
    
   function onRefresh() {
     if (refreshEnabled) {
       dataStore_<%= FailedTransactionPendingResubmitsList.ClientID %>.reload();
     }
   };

  </script>

  <div id="results-win" class="x-hidden"> 
    <div id="UpdateStatusWindowTitle" class="x-window-header"><h4><%= GetGlobalResourceObject("FailedTransactionResources", "TEXT_CHANGE_TRANSACTION_STATUS").ToString()%></h4></div> 
    <div id="result-content"> 
    </div> 
  </div>
    <div id="loader"style="top:50%; left: 50%; width: 100px; height: 30px; position: absolute; margin-top: -65px; margin-left: -15px;"></div>
</asp:Content>

