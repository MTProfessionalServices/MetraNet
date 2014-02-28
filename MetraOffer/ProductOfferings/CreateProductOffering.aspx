﻿<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="CreateProductOffering.aspx.cs" Inherits="MetraNet.MetraOffer.ProductOfferings.MetraOfferCreateProductOffering" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>


<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<MT:MTTitle ID="MTTitle1" Text="Create Product Offering" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <br /><br />

<div style="width:810px">

  <!-- BE Edit --> 
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" 
    DataBinderInstanceName="MTDataBinder1" 
    meta:resourcekey="MTGenericForm1Resource1"></MTCDT:MTGenericForm>
     
  <!-- Related Entities -->
  <MT:MTPanel ID="PanelRelatedEntities" Text="Add Price List" runat="server" Visible="False">
  </MT:MTPanel>      
  
  <!-- BUTTONS -->
  <div class="Buttons">
     <br />       
     <asp:Button CssClass="button" ID="btnOK" OnClientClick="return ValidateForm();" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_OK %>" meta:resourcekey="btnOKResource1" OnClick="btnOK_Click" TabIndex="100" />&nbsp;&nbsp;&nbsp;
     <asp:Button CssClass="button" ID="btnCancel" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>" CausesValidation="False" meta:resourcekey="btnCancelResource1" OnClick="btnCancel_Click" TabIndex="110" />
     <br />       
  </div>

</div>
  
<br />

  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" ControlId="MTTitle1" 
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
  
  <script language="javascript" type="text/javascript">
    Ext.onReady(function () {
      var tbName = Ext.getCmp('ctl00_ContentPlaceHolder1_tbName');
      tbName.on("blur", function(){
        Ext.getCmp('ctl00_ContentPlaceHolder1_tbDisplayName').setValue(tbName.getValue());
      });
    });
  </script>
</asp:Content>