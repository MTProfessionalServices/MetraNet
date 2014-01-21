<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="UnlockAccount" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="UnlockAccount.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" Text="Lock / Unlock Account" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

  <!-- Main Form -->
  <div style="width:400px">
    <br />
    <div class="InfoMessage" style="margin-left:120px;width:400px;">
      <asp:Label ID="lblMessage" runat="server"></asp:Label>
    </div>
    <br />

<center>
    <!-- BUTTONS -->
    <div class="Buttons" style="margin-left:120px;width:400px;">
       <br />       
       <asp:Button CssClass="button" ID="btnLock" runat="server" Text="Lock Account" OnClick="btnLock_Click" TabIndex="150" meta:resourcekey="btnLockResource1" />&nbsp;&nbsp;&nbsp;
       <asp:Button CssClass="button" ID="btnUnlock" runat="server" Text="Unlock Account" OnClick="btnUnLock_Click" TabIndex="150" meta:resourcekey="btnUnLockResource1" />&nbsp;&nbsp;&nbsp;
       <asp:Button CssClass="button" ID="btnCancel" Width="80px" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click" CausesValidation="False" TabIndex="160" />
       <br />       
    </div>
  </center> 
  </div>
  
</asp:Content>

