<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Subscriptions_SaveSubscriptions" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="SaveSubscriptions.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <!-- Title Bar -->
  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Subscription Created Successfully" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>

  
  <br />
  
  <!-- Main Form -->
 
  
  <MT:MTPanel runat="server" ID="MTPanel1" Width="600" Collapsible="false" Text="Manage Subscriptions" meta:resourcekey="MTPanel1">
    <table border="0" cellpadding="3" cellspacing="3" align="center">
    <tr>
      <td class="CaptionRequired">
        <asp:Label ID="lblSubscription" runat="server" Text="The following Subscription was created successfully:  " meta:resourcekey="lblSubscriptionResource1"></asp:Label>
      </td>
      <td>
        <asp:Label ID="lblDisplayName" runat="server" Text="Display Name" meta:resourcekey="lblDisplayNameResource1"></asp:Label>
      </td>
    </tr>
  </table>
  
  </MT:MTPanel>
    
  <!-- BUTTONS -->

  
    <div  class="x-panel-btns-ct">
    <div style="width:600px" class="x-panel-btns x-panel-btns-center">
    <center>   
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnBackToManage" OnClientClick="return checkButtonClickCount();" Width="150px" runat="server" Text="Manage Subscriptions" OnClick="btnBackToManage_Click" meta:resourcekey="btnBackToManageResource1" />
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" OnClientClick="return checkButtonClickCount();" Width="150px" runat="server" Text="Back to Dashboard" OnClick="btnCancel_Click1" meta:resourcekey="btnCancelResource1" />
          </td>
        </tr>
      </table>
       </center>     
    </div>
  </div>
 
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" BindingSource="SubscriptionInstance.ProductOffering"
        BindingSourceMember="DisplayName" ControlId="lblDisplayName" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" ControlId="btnBackToManage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
  

</asp:Content>

