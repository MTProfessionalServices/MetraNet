<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_SaveGroupSubscription"
  Title="<%$Resources:Resource,TEXT_TITLE%>" CodeFile="SaveGroupSubscription.aspx.cs" Culture="auto" UICulture="auto"%>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <!-- Main Form -->
  <MT:MTPanel ID="MTPanel1" runat="server" meta:resourcekey="lblTitleResource1">
    <table border="0" cellpadding="3" cellspacing="3" align="center">
      <tr>
        <td class="CaptionRequired">
          <asp:Label ID="lblGroupSubscription" runat="server" meta:resourcekey="lblGroupSubscriptionResource1"></asp:Label>
        </td>
        <td>
          <asp:Label ID="lblDisplayName" runat="server" meta:resourcekey="lblDisplayNameResource1"></asp:Label>
        </td>
      </tr>
    </table>
    <asp:Label ID="LblCreate" runat="server" Visible="false" Text="The following Group Subscription was created successfully:"
      meta:resourcekey="lblCreatedResource1"></asp:Label>
    <asp:Label ID="LblUpdate" runat="server" Visible="false" Text="The following Group Subscription was updated successfully:"
      meta:resourcekey="lblUpdatedResource1"></asp:Label>
  </MT:MTPanel>

  <div class="x-panel-btns-ct">
    <div style="width: 725px" class="x-panel-btns x-panel-btns-center">
      <center>
      <table cellspacing="0">
        <tr>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnBackToManage" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_MANAGE_GRPSUB%>"
              OnClick="btnBackToManage_Click" TabIndex="390" />
          </td>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnBackToDashboard" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_BACK_DASHBOARD%>"
              CausesValidation="False" TabIndex="400" OnClick="btnBackToDashboard_Click" />
          </td>
        </tr>
      </table>
      </center>
    </div>
  </div>
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" BindingSource="GroupSubscriptionInstance"
        BindingSourceMember="Name" ControlId="lblDisplayName" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" ControlId="btnBackToManage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
</asp:Content>
