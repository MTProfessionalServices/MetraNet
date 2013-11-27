<%@ Page Language="C#" MasterPageFile="~/MasterPages/AccountPageExt.master" AutoEventWireup="true" Inherits="ChangePassword" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="ChangePassword.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<h1><asp:Localize meta:resourcekey="ChangePassword" runat="server">Change Password</asp:Localize></h1>

  <div class="box500">
  <div class="box500top"></div>
  <div class="box">
      <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
    </div>
  </div>

  <div class="box500">
  <div class="box500top"></div>
  <div class="box">
    <MT:MTTextBoxControl ID="tbOldPassword" runat="server" AllowBlank="False" Label="Old Password" OptionalExtConfig="inputType:'password'" TabIndex="110" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelWidth="200" Listeners="{}" meta:resourcekey="tbOldPasswordResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
    <MT:MTPasswordMeter ID="tbNewPassword" runat="server" AllowBlank="False" Label="New Password" TabIndex="120" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelWidth="200" Listeners="{}" meta:resourcekey="tbNewPasswordResource1" ReadOnly="False" XType="PasswordMeter" XTypeNameSpace="ux" />
    <MT:MTTextBoxControl ID="tbConfirmPassword" runat="server" AllowBlank="False" Label="Confirm Password" OptionalExtConfig="inputType:'password',initialPassField:'ctl00_ContentPlaceHolder1_tbNewPassword'" TabIndex="130" VType="password" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelWidth="200" Listeners="{}" meta:resourcekey="tbConfirmPasswordResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
    
     <!-- BUTTONS -->
      <div class="clearer"></div>
      <div class="button">
        <div class="centerbutton">
          <span class="buttonleft"><!--leftcorner--></span>
          <asp:Button OnClick="btnOK_Click" OnClientClick="return ValidateForm();" ID="btnOK"
            runat="server" Text="<%$Resources:Resource,TEXT_OK%>" meta:resourcekey="btnOKResource1" />
          <span class="buttonright"><!--rightcorner--></span>
        </div>
        <span class="buttonleft"><!--leftcorner--></span>
        <asp:Button OnClick="btnCancel_Click" ID="btnCancel" runat="server" CausesValidation="false"
          meta:resourcekey="btnCancelResource1" Text="<%$Resources:Resource,TEXT_CANCEL%>" />
        <span class="buttonright"><!--rightcorner--></span>
      </div>
    
  </div>
  </div>
</asp:Content>

