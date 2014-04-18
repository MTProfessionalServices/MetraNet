<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="CreateQuote.aspx.cs" Inherits="MetraNet.Quoting.CreateQuote" Title="MetraNet - Create quote"
  Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <MT:MTTitle ID="CreateQuoteTitle" Text="Create Quote" runat="server" />
  <br />
  <%--<MTCDT:MTGenericForm ID="CreateQuoteForm" runat="server" TemplateName="CreateQuote" DataBinderInstanceName="MTDataBinder1" meta:resourcekey="BMEInstanceForm">
  </MTCDT:MTGenericForm>--%>
  <br />
  <%--<MT:MTFilterGrid ID="QuoteAccountsGrid" runat="server" TemplateFileName="Quoting.Accounts" ExtensionName="Core"> </MT:MTFilterGrid>
  --%>
  <MT:MTPanel ID="MTPanelQuoteParameters" runat="server" Text="Quote parameters" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelQuoteParametersResource">
    <MT:MTTextBoxControl ID="MTTextBoxControlQuoteDescription" Label = "Quote Description" LabelWidth="200" runat="server"/>
    <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="dpStartDate"
      Label="Start date" LabelWidth="200" meta:resourcekey="dpStartDateResource1" ReadOnly="False"
      runat="server"></MT:MTDatePicker>
    <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="dpEndDate"
      Label="End date" LabelWidth="200" meta:resourcekey="dpEndDateResource1" ReadOnly="False"
      runat="server"></MT:MTDatePicker>
    <MT:MTCheckBoxControl ID="MTCheckBoxPdf" BoxLabel = "Generate PDF" runat="server" LabelWidth="200" meta:resourcekey="MTCheckBoxPdfResource" />
  </MT:MTPanel>
  <br />
  <MT:MTPanel ID="MTPanelQuoteAccounts" runat="server" Text="Accounts for quote" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelQuoteAccountsResource">
    <MT:MTCheckBoxControl BoxLabel="Is GroupSubscription" ID="MTCheckBoxControlIsGroupSubscription" Text = "Is GroupSubscription" runat="server" LabelWidth="200"  />
    <MT:MTDropDown ID="MTDropDownCorporateAccount" Label = "Corporate Account" LabelWidth="200" runat="server" meta:resourcekey="MTDropDownCorporateAccountResource" />
    <MT:MTInlineSearch ID="MTInlineSearchAddAccount" runat="server" TabIndex="210" AllowBlank="False"
      Label="Add account to quote" LabelWidth="200" HideLabel="False" meta:resourcekey="tbAncestorAccountResource1"></MT:MTInlineSearch>
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelProductOfferings" runat="server" Text="Product offerings for quote" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelProductOfferingsResource">
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelUDRCMetrics" runat="server" Text="UDRC metrics for quote" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelUDRCResource">
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelICBs" runat="server" Text="ICBs for quote" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelICBResource">
  </MT:MTPanel>
  <div class="x-panel-btns-ct">
    <div style="width: 630px" class="x-panel-btns x-panel-btns-center">
      <div style="text-align: center;">
        <table>
          <tr>
            <td class="x-panel-btn-td">
              <asp:HiddenField ID="hdSelectedItemsList" runat="server" />
              <MT:MTButton ID="MTButtonGenerateQuote" runat="server" OnClick="btnGenerateQuote_Click"
                TabIndex="150" meta:resourcekey="btnGenerateQuoteResource1" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTButton2" runat="server" OnClick="btnCancel_Click" CausesValidation="False"
                TabIndex="160" meta:resourcekey="btnCancelResource1" />
            </td>
          </tr>
        </table>
      </div>
    </div>
  </div>
  <%--<MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="CreateQuoteForm"
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>--%>
</asp:Content>
