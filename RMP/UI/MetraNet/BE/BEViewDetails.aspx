<%@ Page Title="" ValidateRequest="false" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="BEViewDetails" CodeFile="BEViewDetails.aspx.cs" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<%@ Register src="../UserControls/BreadCrumb.ascx" tagname="BreadCrumb" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<div style="width:810px">

  <!-- BE Edit --> 
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" 
    DataBinderInstanceName="MTDataBinder1" 
    meta:resourcekey="MTGenericForm1Resource1"></MTCDT:MTGenericForm>
     
  <!-- Related Entities -->
  <MT:MTPanel ID="PanelRelatedEntities" runat="server" Visible="False">
  </MT:MTPanel>      
  
  <!-- BUTTONS -->
  <div class="Buttons">
     <br />       
     <asp:Button CssClass="button" ID="btnOK" OnClientClick="return ValidateForm();" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_OK %>" meta:resourcekey="btnOKResource1" OnClick="btnOK_Click" TabIndex="100" />&nbsp;&nbsp;&nbsp;
     <br />       
  </div>

</div>
  
<br />

<MT:MTDataBinder ID="MTDataBinder1" runat="server">
  <DataBindingItems>
    <MT:MTDataBindingItem runat="server" ControlId="MTTitle1" 
      ErrorMessageLocation="RedTextAndIconBelow">
    </MT:MTDataBindingItem>
  </DataBindingItems>
  </MT:MTDataBinder>
</asp:Content>

