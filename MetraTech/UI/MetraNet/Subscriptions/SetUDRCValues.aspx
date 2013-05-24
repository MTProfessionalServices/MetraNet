<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Subscriptions_SetUDRCValues" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="SetUDRCValues.aspx.cs" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <asp:PlaceHolder ID="PlaceHolderJavaScript" runat="server"></asp:PlaceHolder>    
  <!-- Title Bar -->
  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Set Unit Dependent Recurring Charge Values" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>
  
  <br />
  <asp:PlaceHolder ID="PlaceHolderUDRCs" runat="server"></asp:PlaceHolder>
  <br />
  
   <!-- OK / Cancel Buttons -->
  <center>
  <table border="0" cellpadding="2" cellspacing="1" align="center">
    <tr>
      <td><br /><br />
        <asp:Button CssClass="button" ID="btnBack" OnClientClick="return checkButtonClickCount();" Width="50px" runat="server" Text="Back" OnClick="btnBack_Click" meta:resourcekey="btnBackResource1" />&nbsp;&nbsp;&nbsp;
        <asp:Button CssClass="button" ID="btnOK" OnClientClick="return checkButtonClickCount();" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click"/>&nbsp;&nbsp;&nbsp;
        <asp:Button CssClass="button" ID="btnCancel" OnClientClick="return checkButtonClickCount();" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" OnClick="btnCancel_Click"/>
      </td>
    </tr>
  </table>
  </center>
</asp:Content>

