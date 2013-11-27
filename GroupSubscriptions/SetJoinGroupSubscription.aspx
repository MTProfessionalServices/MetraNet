<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_SetJoinGroupSubscription"
  Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" CodeFile="SetJoinGroupSubscription.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
  
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="PageTitle" runat="server" Text="Group Subscription Properties"
      meta:resourcekey="PageTitle"></asp:Label>
  </div>
  <br />
  <div>
    <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
      Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  </div>
  <div id="divLblMessage" runat="server" visible="false" >
    <b>
      <div class="InfoMessage" style="margin-left:120px;width:400px;">
        <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
      </div>
    </b>
  </div>
  <MT:MTPanel ID="Panel1" runat="server" meta:resourcekey="lblSetJoinGroupSubscriptionsTitleResource1">
    <MT:MTTextBoxControl ID="tbAccountName" runat="server" AllowBlank="true" Label="Account Name"
      TabIndex="150" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
      LabelWidth="120" Listeners="{}" meta:resourcekey="tbUserNameResource1" ReadOnly="true"
      XType="TextField" XTypeNameSpace="form" />
    <MT:MTDatePicker ID="MTEffecStartDatePicker" runat="server" AllowBlank="False" Label="Effective Start Date"
      TabIndex="170" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
      LabelWidth="120" Listeners="{}" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;altFormats:DATE_TIME_FORMAT"
      ReadOnly="False" XType="DateField" XTypeNameSpace="form" Width="300px"  meta:resourcekey="tbEffStartDate" />
    <MT:MTDatePicker ID="MTEffecEndDatePicker" runat="server" AllowBlank="False" Label="Effective End Date"
      TabIndex="190" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
      LabelWidth="120" Listeners="{}" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT"
      ReadOnly="False" XType="DateField" XTypeNameSpace="form" Width="300px" meta:resourcekey="tbEffEndDate"  />
  </MT:MTPanel>
  
  <div class="x-panel-btns-ct">
    <div style="width: 725px" class="x-panel-btns x-panel-btns-center">
    <center>
      <table cellspacing="0">
        <tr>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="return ValidateForm();" Width="50px" runat="server"
              Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="390" />
          </td>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>"
              CausesValidation="False" TabIndex="400" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table>
       </center>
    </div>
  </div>
 
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
</asp:Content>
