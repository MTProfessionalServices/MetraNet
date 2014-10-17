<%@ Page Title="" ValidateRequest="false" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="BEEdit" CodeFile="BEEdit.aspx.cs" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<%@ Register src="../UserControls/BreadCrumb.ascx" tagname="BreadCrumb" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<MT:MTTitle ID="MTTitle1" Text="Edit BE" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <uc1:BreadCrumb ID="BreadCrumb1" runat="server" /> 
  <br /><br />
  
  <p id="pNumberUpdatingRecords"><b><%=strNumberUpdatingRecords %></b></p>

<div style="width:810px">

  <!-- BE Edit --> 
  <MTCDT:MTGenericForm ID="BMEInstanceForm" runat="server" 
    DataBinderInstanceName="MTDataBinder1" 
    meta:resourcekey="BMEInstanceForm"></MTCDT:MTGenericForm>
     
  <!-- Related Entities -->
  <MT:MTPanel ID="PanelRelatedEntities" runat="server" Visible="False">
  </MT:MTPanel>      
  
  <!-- BUTTONS -->
  <div class="Buttons">
     <br />       
     <asp:Button CssClass="button" ID="btnOK" OnClientClick="getCheckedCheckboxes(); return (ValidateForm() && showBulkUpdateConfirm(this.id));" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_OK %>" meta:resourcekey="btnOKResource1" OnClick="btnOK_Click" TabIndex="100" />&nbsp;&nbsp;&nbsp;
     <asp:Button CssClass="button" ID="btnCancel" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>" CausesValidation="False" meta:resourcekey="btnCancelResource1" OnClick="btnCancel_Click" TabIndex="110" />
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
  
  <asp:HiddenField runat="server" ID="hfCheckedCheckboxes"/>
  <asp:HiddenField runat="server" ID="hfDeniedProperties"/>
  <div id="divPanelRender" style="display: none; width: 250px;"></div>
  <script type="text/javascript" src="BEEdit.aspx.js"></script>
  <script type="text/javascript" src="/Res/ux/jpath/jpath.js?v=6.5"></script>
</asp:Content>