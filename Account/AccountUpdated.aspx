<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Account_AccountUpdated" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="AccountUpdated.aspx.cs" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 <%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

 
  <div class="CaptionBar">
    <asp:Label ID="Label2" runat="server" Text="Account Updated" meta:resourcekey="Label2Resource1"></asp:Label>
  </div>
  <br />

    <MT:MTPanel Collapsible="false" runat="server" ID="Panel1" Text="Account Updated" meta:resourcekey="Label2Resource1">
  
  <asp:Label ID="Label1" runat="server" Text="The account was updated successfully." meta:resourcekey="Label1Resource1"></asp:Label>
  </MT:MTPanel>
  <!-- BUTTONS -->
  
      <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">  
    <center>
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
     <MT:MTButton ID="btnOK" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="150" meta:resourcekey="btnOKResource1"/>&nbsp;&nbsp;&nbsp;
          </td>
        </tr>
      </table>   
      </center>   
    </div>
  </div>

  
  <script type="text/javascript">
    Account.Refresh();
  </script>
</asp:Content>

