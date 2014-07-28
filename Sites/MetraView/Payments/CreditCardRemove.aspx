<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_CreditCardRemove" Culture="auto"
  meta:resourcekey="PageResource1" UICulture="auto" CodeFile="CreditCardRemove.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <h1>
    <asp:Localize ID="Localize1" meta:resourcekey="RemoveCC" runat="server">Remove Credit Card</asp:Localize></h1>
  <div class="box500">
    <div class="box500top">
    </div>
    <div class="box">
      <div class="left">
        <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="ErrorMessage"
          Width="100%" />
        <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
          Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
        <div class="InfoMessage" style="margin-left: 90px; width: 300px;">
          <MT:MTLabel Text="Are you sure you want to remove the credit card below?" runat="server"
            ID="lblConfirm" meta:resourcekey="lblConfirmResource1" />
          <p />
          <MT:MTLabel ID="lcCCType" runat="Server" />
          &nbsp;
          <MT:MTLabel ID="lcAccountNumber" runat="server" />
        </div>
        <div class="button">
          <div class="centerbutton">
            <span class="buttonleft">
              <!--leftcorner-->
            </span>
            <asp:Button OnClick="btnOK_Click" OnClientClick="return ValidateForm();" ID="btnOK"
              runat="server" Text="<%$Resources:Resource,TEXT_YES%>" />
            <span class="buttonright">
              <!--rightcorner-->
            </span>
          </div>
          <span class="buttonleft">
            <!--leftcorner-->
          </span>
          <asp:Button OnClick="btnCancel_Click" ID="btnCancel" runat="server" CausesValidation="false"
            Text="<%$Resources:Resource,TEXT_NO%>" />
          <span class="buttonright">
            <!--rightcorner-->
          </span>
        </div>
      </div>
    </div>
    <div class="clearer">
    </div>
  </div>
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingMode="OneWay"
        BindingSource="CreditCard" BindingSourceMember="CreditCardType" ControlId="lcCCType"
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem2" runat="server" BindingMode="OneWay"
        BindingSource="CreditCard" BindingSourceMember="AccountNumber" ControlId="lcAccountNumber"
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
</asp:Content>
