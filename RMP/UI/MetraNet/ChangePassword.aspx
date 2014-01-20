<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="ChangePassword" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="ChangePassword.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" Text="Change Password" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

  <!-- Main Form -->
  <div style="width:400px">
    <br />
    
    <div style="margin-left:10px">
    <MT:MTPanel Collapsible="false" Text="Change Password" meta:resourcekey="MTTitle1Resource1" Width="630" ID="MyPanel1" runat="Server">    
        <div class="InfoMessage" style="margin-left:120px;width:400px;">
          <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
        </div>
        <br />
        <MT:MTTextBoxControl ID="tbUserName" runat="server" AllowBlank="False" Label="User Name" TabIndex="100" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="tbUserNameResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbOldPassword" runat="server" AllowBlank="False" Label="Old Password" OptionalExtConfig="inputType:'password'" TabIndex="110" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="tbOldPasswordResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
        <MT:MTPasswordMeter ID="tbNewPassword" runat="server" AllowBlank="False" Label="New Password" TabIndex="120" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="tbNewPasswordResource1" ReadOnly="False" XType="PasswordMeter" XTypeNameSpace="ux" />
        <MT:MTTextBoxControl ID="tbConfirmPassword" runat="server" AllowBlank="False" Label="Confirm Password" OptionalExtConfig="inputType:'password',initialPassField:'ctl00_ContentPlaceHolder1_tbNewPassword'" TabIndex="130" VType="password" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="tbConfirmPasswordResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
     </MT:MTPanel>

  <!-- BUTTONS -->
  <div  class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK"  OnClientClick="return ValidateForm();" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="150" meta:resourcekey="btnOKResource1" />      
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" OnClick="btnCancel_Click" CausesValidation="False" TabIndex="160" meta:resourcekey="btnCancelResource1" />
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>
 </div>
</div> 
</asp:Content>

