<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Templates_SelectSubscriptions" Title="MetraNet" CodeFile="SelectSubscriptions.aspx.cs" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="MTTitle1" Text="Select Subscriptions" runat="server" meta:resourcekey="lblSelectSubscriptionsResource1"  /><br />
  <MT:MTPanel runat="server" Text="Subscription Span" meta:resourcekey="SubscriptionSpanPanel">
          <MT:MTDatePicker ID="tbStartDate" runat="server" AllowBlank="True" Label="Subscriptions Start Date"
            TabIndex="220" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
            LabelWidth="120" Listeners="{}" meta:resourcekey="StartDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10; altFormats:DATE_TIME_FORMAT"
            ReadOnly="False" XType="DateField" XTypeNameSpace="form" />
    <br/>
          <MT:MTDatePicker ID="tbEndDate" runat="server" AllowBlank="True" Label="Subscriptions End Date"
            TabIndex="220" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
            LabelWidth="120" Listeners="{}" meta:resourcekey="EndDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10; altFormats:DATE_TIME_FORMAT"
            ReadOnly="False" XType="DateField" XTypeNameSpace="form" />
  </MT:MTPanel>
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
        var startDate = "";
        var endDate = "";
        var stCmp = Ext.getCmp("<%=tbStartDate.ClientID%>");
        if (stCmp !== undefined && stCmp != null) {
          var dt = stCmp.getValue();
          if (dt !== undefined && dt != null && dt != "") {
            startDate = dt.format("m/d/Y");
          }
        }
        var endCmp = Ext.getCmp("<%=tbEndDate.ClientID%>");
        if (endCmp !== undefined && endCmp != null) {
          var edt = endCmp.getValue();
          if (edt !== undefined && edt != null && edt != "") {
            endDate = edt.format("m/d/Y");
          }
        }
        for (var i = 0; i < records.length; i++) {
          if (i > 0) {
            ids += ",";
            PONames += ",";
          }
          ids += records[i].data.ProductOfferingId;
           PONames += records[i].data.DisplayName;
        }

        var args = "IDs=" + ids + ";sep;" + PONames  + ";sep;" + startDate + ";sep;" + endDate;  
        pageNav.Execute("TemplateEvents_OKSelectSubscriptions_Client", args, null);
      }
    }

</script>
</asp:Content>


