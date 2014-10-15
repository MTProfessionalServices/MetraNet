<%@ Page Title="Delete Report Definition" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="DeleteExistingReportDefinition.aspx.cs" Inherits="DataExportReportManagement_DeleteExistingReportDefinition" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <div class="CaptionBar">
    <asp:Label ID="Label2" runat="server" Text="Report Definition Deleted" meta:resourcekey="Label2Resource1"></asp:Label>
  </div>
  
  <br />
  <MT:MTPanel Collapsible="false" runat="server" ID="Panel1" Text="Report Definition Deleted" meta:resourcekey="Label2Resource1">
  <asp:Label ID="Label1" runat="server" Text="The Report Definition was deleted successfully." meta:resourcekey="Label1Resource1"></asp:Label>
   </MT:MTPanel> 
  
    <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">   
    <center>
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
              <MT:MTButton  ID="btnBack" runat="server" Text="Back"  OnClick="btnBack_Click" meta:resourcekey="btnBackResource1" />
          </td>
        </tr>
      </table>  
      </center>   
    </div>
  </div>
  </asp:Content>

