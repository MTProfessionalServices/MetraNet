<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="MessagePage" Title="MetraNet" CodeFile="MessagePage.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <!-- Title Bar -->
  <MT:MTTitle ID="lblTitle" Text="Confirmation" runat="server" /><br />

  <!-- Main Form -->
  <div style="width:400px">
    <br />
    <div id="MessageDiv" class="InfoMessage" style="margin-left:120px;width:400px;" runat="server">
      <asp:Label ID="lblMessage" runat="server"></asp:Label>
    </div>
    <br />

    <!-- BUTTONS -->
    <div class="Buttons">
       <br />       
       <asp:Button CssClass="button" ID="btnOK" Width="50px" runat="server" OnClick="btnOK_Click" TabIndex="150" Text="<%$Resources:Resource,TEXT_OK%>"/>&nbsp;&nbsp;&nbsp;
       <br />       
    </div>
   
  </div>
</asp:Content>

