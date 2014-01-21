<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="ApprovalFrameworkManagement_ChangeSubmittedConfirmation" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="ChangeSubmittedConfirmation.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <div class="CaptionBar">
    <asp:Label ID="lblCaption" runat="server" Text="Change Submitted Confirmation" meta:resourcekey="lblCaptionResource1"></asp:Label>
  </div>
  
  <br />
  <MT:MTPanel Collapsible="false" runat="server" ID="Panel1" Text="Change Submitted Successfully to Approval Framework" meta:resourcekey="Panel1Resource1">
  <asp:Label ID="lblContents" runat="server" Text="Change Submitted Successfully to Approval Framework." meta:resourcekey="lblContentsResource1"></asp:Label>
   </MT:MTPanel> 
  
    <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">   
    <center>
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
              <MT:MTButton  ID="btnOK" runat="server" Text="OK"  OnClick="btnOK_Click" meta:resourcekey="btnOKResource1" />
          </td>
        </tr>
      </table>  
      </center>   
    </div>
  </div>
  
  </asp:Content>

