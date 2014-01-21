<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_DeleteGroupSubscription"
  Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" CodeFile="DeleteGroupSubscription.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <br />
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
    Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  <!-- Main Form -->
  <MT:MTPanel runat="server" ID="MTPanel1">
    <MT:MTMessage ID="lblMessage" WarningLevel="Warning" runat="server" Text="You are about to permanently delete this group subscription and all contained data from the system. This is only allowed if there was never any participation in this group subscription. This group subscription will be removed from any account templates it may have been assigned to. " meta:resourcekey="lblMessageResource1" Width="650">
    </MT:MTMessage>
  </MT:MTPanel>
 
  <div class="x-panel-btns-ct">
    <div style="width: 725px" class="x-panel-btns x-panel-btns-center">
     <center>
      <table cellspacing="0">
        <tr>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>"
              OnClick="btnOK_Click" TabIndex="390" />
          </td>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>"
              CausesValidation="False" TabIndex="400" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table>
       </center>
    </div>
  </div>
 
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="lblMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
</asp:Content>
