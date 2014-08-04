<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Account_SelectAccountType" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="SelectAccountType.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <MT:MTTitle ID="MTTitle1" runat="server" Text="Add Account" meta:resourcekey="MTTitle1Resource1" /><br />

  <MT:MTPanel Collapsible="false" Text="Select Account Type" Width="630" ID="pnlMain"  meta:resourcekey="pnlMain" runat="Server">
    <MT:MTDropDown ID="ddAccountTypes" runat="server" Label="Select account type to create" LabelWidth="250" ControlWidth="200" ListWidth="200" AllowBlank="False" HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddAccountTypesResource2" ReadOnly="False"></MT:MTDropDown><br />
  </MT:MTPanel>
  
  <div class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center">  
    <center> 
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK"  Width="50px" runat="server" OnClick="btnOK_Click" Text="<%$Resources:Resource,TEXT_OK%>"/>
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" Width="50px" runat="server" OnClick="btnCancel_Click" Text="<%$Resources:Resource,TEXT_CANCEL%>"/>
          </td>
        </tr>
      </table>   
      </center>  
    </div>
  </div>
  
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="this" BindingSourceMember="AccountTypes" ControlId="ddAccountTypes" ErrorMessageLocation="RedTextAndIconBelow"></MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>

</asp:Content>

