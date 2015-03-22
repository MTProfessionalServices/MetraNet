<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="ApplyAccountConfigSets.aspx.cs" Inherits="MetraNet.AccountConfigSets.ApplyAccountConfigSets" Title="MetraNet - OnBoard templates" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <MT:MTTitle ID="ApplyAccountConfigSetsTitle" Text="Apply OnBoard Templates" runat="server" meta:resourcekey="ApplyAccountConfigSetsTitle" /><br />
  
  <div class="x-panel-btns-ct">
    <div style="width: 720px" class="x-panel-btns x-panel-btns-center">
      <MT:MTPanel Collapsible="false" runat="server" ID="PanelWithMessage">
       <asp:Label ID="MTapiOutputText" runat="server"></asp:Label>
      </MT:MTPanel> 
       <MT:MTPanel Collapsible="false" runat="server" ID="PanelWithQuestion">
       <asp:Label ID="MTquestionText" runat="server"></asp:Label>
      </MT:MTPanel> 
      <div style="text-align: center; width: 25%; margin: auto;">
        <table>          
          <tr>            
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnContinue" runat="server" 
                OnClick="btnContinue_Click" Visible="False" TabIndex="150" meta:resourcekey="btnContinueResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnCancel" runat="server" OnClick="btnClose_Click" Visible="False" TabIndex="160" meta:resourcekey="btnCancelResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnClose" runat="server" OnClick="btnClose_Click" CausesValidation="False"
                TabIndex="170" meta:resourcekey="btnCloseResource" />
            </td>
          </tr>
        </table>
      </div>
    </div>
  </div>
</asp:Content>