<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master"
  AutoEventWireup="true" CodeFile="UpdateExistingReportDefinition.aspx.cs" Inherits="DataExportReportManagement_UpdateExistingReportDefinition"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" Text="Update Existing Report Definition" runat="server"
    meta:resourcekey="MTTitle1Resource1" />
  <br />
  <br />
  <!-- From Add Parameters Template -->
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" DataBinderInstanceName="MTDataBinder1"
    meta:resourcekey="MTGenericForm1Resource1" EnableChrome="True">
  </MTCDT:MTGenericForm>
  <MT:MTPanel ID="rptPanel" runat="server" meta:resourcekey="MTSection2Resource1" Collapsible="False"
    Text="Report Definition Details" Collapsed="False" EnableChrome="True">
    <div id="leftColumn" class="LeftColumn">
      <MT:MTTextBoxControl ID="tbReportTitle" runat="server" AllowBlank="True" Label="Report Title"
        TabIndex="20" ControlWidth="200" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null,maxLength:50" ControlHeight="18" HideLabel="False"
        LabelWidth="120" meta:resourcekey="tbReportTitleResource1" ReadOnly="True" XTypeNameSpace="form"
        LabelSeparator=":" Listeners="{}" MaxLength="-1" MinLength="0" ValidationRegex="null"
        XType="TextField" />
      <MT:MTTextBoxControl ID="tbReportDescription" runat="server" AllowBlank="True" Label="Description"
        TabIndex="20" ControlWidth="200" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null,maxLength:50" ControlHeight="18" HideLabel="False"
        LabelWidth="120" meta:resourcekey="tbReportDescriptionResource1" ReadOnly="False"
        XTypeNameSpace="form" LabelSeparator=":" Listeners="{}" MaxLength="-1" MinLength="0"
        ValidationRegex="null" XType="TextField" />
      <MT:MTDropDown ID="ddQueryTagList" runat="server" AutoPostBack="True" Label="Query Tag"
        HideLabel="False" LabelWidth="120" meta:resourcekey="ddQueryTagListResource1">
      </MT:MTDropDown>
      <MT:MTCheckBoxControl ID="chkPreventAdhocExecution" runat="server" AllowBlank="True"
        BoxLabel="Prevent Adhoc Execution" TabIndex="5" meta:resourcekey="chkPreventAdhocExecutionResource1"
        ReadOnly="False" Checked="False" HideLabel="False" Listeners="{}" Name="chkPreventAdhocExecution"
        OptionalExtConfig="boxLabel:'Prevent Adhoc Execution',
                                            inputValue:'',
                                            checked:false" XType="Checkbox" XTypeNameSpace="form">
      </MT:MTCheckBoxControl>
    </div>
    <div style="clear: both">
    </div>
  </MT:MTPanel>
  <div class="x-panel-btns-ct">
    <div style="width: 630px" class="x-panel-btns x-panel-btns-center">
      <center>
        <table cellspacing="0">
          <tr>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTButton1" OnClientClick="return ValidateForm();" runat="server"
                Text="<%$ Resources:Resource,TEXT_OK %>" OnClick="btnOK_Click" TabIndex="150" meta:resourcekey="btnOKResource1" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTButton2" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>"
                OnClick="btnCancel_Click" CausesValidation="False" TabIndex="160" meta:resourcekey="btnCancelResource1" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTButton3" runat="server" Text="Manage Report Parameters" OnClick="btnManageReportParameters_Click"
                CausesValidation="False" TabIndex="160" meta:resourcekey="btnManageReportParametersResource1" />
            </td>
          </tr>
        </table>
      </center>
    </div>
  </div>
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingSource="exportreportdefinition"
        BindingSourceMember="ReportQueryTag" ControlId="ddQueryTagList" BindingProperty="SelectedValue"
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem2" runat="server" BindingSource="exportreportdefinition"
        BindingSourceMember="ReportTitle" ControlId="tbReportTitle" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem3" runat="server" BindingSource="exportreportdefinition"
        BindingSourceMember="ReportDescription" ControlId="tbReportDescription" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem4" runat="server" BindingProperty="Checked"
        BindingSource="exportreportdefinition" BindingSourceMember="bPreventAdhocExecution"
        ControlId="chkPreventAdhocExecution" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
</asp:Content>
