<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_DeleteGroupSubscriptionMembers"
  Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" CodeFile="DeleteGroupSubscriptionMembers.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <br />
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
    Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  <MT:MTMessage ID="Message1" runat="server" meta:resourcekey="InfoMsg" WarningLevel="Info"
    Width="400">
  </MT:MTMessage>
  <div id="divLblMessage" runat="server" visible="false" >
    <b>
      <div class="InfoMessage" style="margin-left:120px;width:400px;">
        <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
      </div>
    </b>
  </div>

  <MT:MTPanel runat="server" ID="MTPanel1">
    <MT:MTMessage ID="Message2" runat="server" Text="Are you sure you want to delete?"
      meta:resourcekey="lblConfirmResource1" WarningLevel="Warning" Width="300">
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
        <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
        </MT:MTDataBindingItem>
      </DataBindingItems>
    </MT:MTDataBinder>
</asp:Content>
