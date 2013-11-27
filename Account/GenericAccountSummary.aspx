<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Account_GenericAccountSummary" Title="MetraNet" 
CodeFile="GenericAccountSummary.aspx.cs" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1"  %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<MT:MTTitle ID="MTTitle1" Text="Account Summary" runat="server" 
    meta:resourcekey="MTTitle1Resource1" /><br />

<div style="width:810px">

  <!-- BILLING INFORMATION --> 
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server"></MTCDT:MTGenericForm>
 
</div>

  <MT:MTDataBinder ID="MTDataBinder1" runat="server" 
    OnAfterBindControl="MTDataBinder1_AfterBindControl">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="MTGenericForm1" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
  <script type="text/javascript">
      Ext.onReady(function () {
          var ddAuthenticationType = Ext.get("ctl00_ContentPlaceHolder1_ddAuthenticationType_readonly_value");
          var ddSecurityQuestion = Ext.get("ctl00_ContentPlaceHolder1_ddInternal_SecurityQuestion_readonly_value");
          if (ddAuthenticationType != null) {
              ddAuthenticationType.dom.style.width = '200px';
              ddAuthenticationType.dom.style.wordWrap = 'break-word';
          }
          if (ddSecurityQuestion != null) {
              ddSecurityQuestion.dom.style.width = '200px';
              ddSecurityQuestion.dom.style.wordWrap = 'break-word';
          }
      });    
  </script>
</asp:Content>

