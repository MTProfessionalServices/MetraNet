<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_CreditCardRemove" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="CreditCardRemove.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">  
  
  <MT:MTTitle ID="MTTitle1" runat="server" Text="Delete Credit Card" meta:resourcekey="MTTitle1Resource1" />
  <br />
  
  <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="ErrorMessage"
    Width="100%"/>
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
    Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
    <div class="InfoMessage" style="margin-left:120px;width:400px;">
      <MT:MTLabel Text="Are you sure you want to remove the credit card below?" runat="server" ID="lblConfirm" meta:resourcekey="lblConfirmResource1" />
      <p />
      <MT:MTLabel ID="lcCCType" runat="Server"/>&nbsp;
      <MT:MTLabel ID="lcAccountNumber" runat="server"/>
      
    </div>
    <center>
      <div class="Buttons">
      <br />
      <asp:Button CssClass="button" ID="btnOK" runat="server" meta:resourcekey="btnOKResource1" OnClick="btnOK_Click"
        TabIndex="390" Text="Yes" Width="50px" />&nbsp;&nbsp;&nbsp;
      <asp:Button CssClass="button" ID="btnCancel" runat="server" CausesValidation="False" meta:resourcekey="btnCancelResource1"
        OnClick="btnCancel_Click" TabIndex="400" Text="No" Width="50px" />
      <br />
    </div>
    </center>
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
        <MT:MTDataBindingItem runat="server" ControlId="MTDataBindingItem2" ErrorMessageLocation="RedTextAndIconBelow">
        </MT:MTDataBindingItem>
      </DataBindingItems>
    </MT:MTDataBinder>
</asp:Content>

