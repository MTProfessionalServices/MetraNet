<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Templates_SelectSubscriptions" Title="MetraNet" CodeFile="SelectSubscriptions.aspx.cs" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="MTTitle1" Text="Select Subscriptions" runat="server" meta:resourcekey="lblSelectSubscriptionsResource1"  /><br />
  
  <MT:MTFilterGrid ID="MTFilterGrid1" AjaxTimout="120000" runat="server" TemplateFileName="AccountTemplateSelectSubscription" ExtensionName="Account" ></MT:MTFilterGrid>

<script type="text/javascript">

    function onCancel_<%= MTFilterGrid1.ClientID %>() {
      if (checkButtonClickCount() == true) {
        pageNav.Execute("TemplateEvents_CancelSelectSubscriptions_Client", null, null);
      }
    }


    function onOK_<%= MTFilterGrid1.ClientID %>() {
      if (checkButtonClickCount() == true) {
        var records = grid_<%= MTFilterGrid1.ClientID %>.getSelectionModel().getSelections();
        var ids = "";
        var PONames = "";
        for (var i = 0; i < records.length; i++) {
          if (i > 0) {
            ids += ",";
            PONames += ",";
          }
          ids += records[i].data.ProductOfferingId;
           PONames += records[i].data.DisplayName;
        }

        var args = "IDs=" + ids + ";sep;" + PONames ;  
        pageNav.Execute("TemplateEvents_OKSelectSubscriptions_Client", args, null);
      }
    }

</script>
</asp:Content>


