<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Templates_SelectGroupSubscriptions" Title="MetraNet" meta:resourcekey="PageResource1" CodeFile="SelectGroupSubscriptions.aspx.cs"  Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="MTTitle1" Text="Select Group Subscriptions" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />
  <MT:MTPanel ID="MTPanel1" runat="server" Text="Subscription Span" meta:resourcekey="SubscriptionSpanPanel">
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
          var GrSubNames = "";
          var PONames = "";
          var StartDates = "";
          var EndDates = "";
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
              GrSubNames += ",";
              PONames += ",";
              StartDates += ",";
              EndDates += ",";
            }
            ids += records[i].data.GroupId;
            GrSubNames += records[i].data.Name;
            if (records[i].data['ProductOffering#DisplayName'] != null) {
              PONames += records[i].data['ProductOffering#DisplayName'];
            }
            if (startDate == "") {
              if (records[i].data['SubscriptionSpan#StartDate'] != null) {
                StartDates += records[i].data['SubscriptionSpan#StartDate'];
              }
            } else {
              StartDates += startDate;
            }
            if (endDate == "") {
              if (records[i].data['SubscriptionSpan#EndDate'] != null) {
                EndDates += records[i].data['SubscriptionSpan#EndDate'];
              }
            } else {
              EndDates += endDate;
            }
          }

          var args = "IDs=" + ids + ";sep;" + GrSubNames + ";sep;" + PONames + ";sep;" + StartDates + ";sep;" + EndDates; 
          pageNav.Execute("TemplateEvents_OKSelectGroupSubscriptions_Client", args, null);
        }
      }

  </script>

</asp:Content>

