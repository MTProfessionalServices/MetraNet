<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Templates_SelectGroupSubscriptions" Title="MetraNet" meta:resourcekey="PageResource1" CodeFile="SelectGroupSubscriptions.aspx.cs"  Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="MTTitle1" Text="Select Group Subscriptions" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />
  
  <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" TemplateFileName="AccountTemplateSelectGroupSubscription" ExtensionName="Account"></MT:MTFilterGrid>

  <script type="text/javascript">

      function onCancel_<%= MTFilterGrid1.ClientID %>() {
        if (checkButtonClickCount() == true) {
          pageNav.Execute("TemplateEvents_CancelSelectGroupSubscriptions_Client", null, null);
        }
      }


      function onOK_<%= MTFilterGrid1.ClientID %>() {
        if (checkButtonClickCount() == true) {
          var records = grid_<%= MTFilterGrid1.ClientID %>.getSelectionModel().getSelections();
          var ids = "";
          for (var i = 0; i < records.length; i++) {
            if (i > 0) {
              ids += ",";
            }
            ids += records[i].data.GroupId;
          }

          var args = "IDs=" + ids;
          pageNav.Execute("TemplateEvents_OKSelectGroupSubscriptions_Client", args, null);
        }
      }

  </script>

</asp:Content>

