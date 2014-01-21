<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_AddEditUDRCValues"
  Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" CodeFile="AddEditUDRCValues.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="lblSetUDRCValuesTitle" runat="server" Text="Set Unit Dependent Recurring Charge Values"
      meta:resourcekey="lblSetUDRCValuesTitleResource1"></asp:Label>
  </div>
  <br />
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
    Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  <MT:MTMessage ID="MTMessage1" runat="Server" Text="The UDRC value must be between "
    meta:resourcekey="lblMinMaxVal" WarningLevel="Info" Width="400">
  </MT:MTMessage> 
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server">
  </MTCDT:MTGenericForm>
 
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
 
  <MT:MTDataBinder ID="MTDataBinder1" runat="server" OnAfterBindControl="MTDataBinder1_AfterBindControl">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="MTMessage1" 
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
</asp:Content>
