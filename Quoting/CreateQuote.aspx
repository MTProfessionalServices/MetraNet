<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="CreateQuote.aspx.cs" Inherits="MetraNet.Quoting.CreateQuote" Title="MetraNet - Create quote"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register TagPrefix="MTCDT" Namespace="MetraTech.UI.Controls.CDT" Assembly="MetraTech.UI.Controls.CDT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <MT:MTTitle ID="CreateQuoteTitle" Text="Create Quote" runat="server" meta:resourcekey="QuoteListTitle" />
  <br />
  <MTCDT:MTGenericForm ID="CreateQuoteForm" runat="server" TemplateName="CreateQuote" DataBinderInstanceName="MTDataBinder1" meta:resourcekey="BMEInstanceForm">
  </MTCDT:MTGenericForm>
 <br /> 

 <MT:MTFilterGrid ID="QuoteAccountsGrid" runat="server" TemplateFileName="Quoting.Accounts" ExtensionName="Core"> </MT:MTFilterGrid>

  <br />
 <div style="width: 810px">
    <MT:MTInlineSearch ID="tbAccount" runat="server" TabIndex="210" AllowBlank="False"
      Label="Add account to quote" HideLabel="False" meta:resourcekey="tbAncestorAccountResource1"></MT:MTInlineSearch>
  </div>
  <br />
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="QuoteAccountsGrid"
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
</asp:Content>
