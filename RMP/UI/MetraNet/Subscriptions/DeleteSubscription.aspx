<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Subscriptions_DeleteSubscription" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="DeleteSubscription.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <!-- Title Bar -->
  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Delete Subscription" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>
  
  <br />
  
  <!-- Main Form -->
  
  <MT:MTMessage WarningLevel="Warning" Width="400" runat="server" ID="Msg1"  meta:resourcekey="lblMessageResource1"></MT:MTMessage>
  <br />
  <MT:MTPanel runat="server" ID="MTPanel1" Text="Delete Subscription" Width="400"  meta:resourcekey="lblTitleResource1">
    <asp:Label ID="lblPrompt" runat="server" Text="Are you sure you want to delete this subscription?" meta:resourcekey="lblPrompt"></asp:Label>
    <asp:Label ID="lblDisplayName" runat="server" Text="Display Name" meta:resourcekey="lblDisplayNameResource1"></asp:Label> 
  </MT:MTPanel>
  
  <!-- BUTTONS -->
 
    <div  class="x-panel-btns-ct">
    <div style="width:400px" class="x-panel-btns x-panel-btns-center">
     <center>   
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="if (checkButtonClickCount() == true) {return ValidateForm();} else {return false;}" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="17" />
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" OnClientClick="return checkButtonClickCount();" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" OnClick="btnCancel_Click" CausesValidation="False" TabIndex="18"/>
          </td>
        </tr>
      </table>  
       </center>   
    </div>
  </div>
 
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingSource="SubscriptionInstance.ProductOffering" BindingSourceMember="DisplayName"
        ControlId="lblDisplayName" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" ControlId="lblMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>

</asp:Content>



