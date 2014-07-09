<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GenericUpdateAccount" Title="MetraNet" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" CodeFile="GenericUpdateAccount.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<MT:MTTitle ID="MTTitle1" Text="Update Account" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />
  
<div style="width:810px">
  <div id="divLblMessage" runat="server" visible="false" >
    <b>
    <div class="InfoMessage" style="margin-left:120px;width:400px;">
      <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
    </div>
    </b>
  </div>

  <!-- BILLING INFORMATION --> 
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" DataBinderInstanceName="MTDataBinder1" meta:resourcekey="MTGenericForm1Resource1"></MTCDT:MTGenericForm>

  <MT:MTCheckBoxControl ID="cbApplyTemplate" runat="server" BoxLabel="Apply Template"
    Text="template" Value="template" TabIndex="95" ControlWidth="200" AllowBlank="False"
    Checked="False" Visible="false" HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbApplyTemplateResource1"
    Name="cbApplyTemplate" OptionalExtConfig="boxLabel:'Apply Template',&#13;&#10;inputValue:'template',&#13;&#10;checked:false"
    ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />  
        
  <!-- BUTTONS -->
  <center>
  <div class="Buttons">
     <br />       
     <asp:Button CssClass="button" ID="btnOK" OnClientClick="return ValidateForm();" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_OK %>" OnClick="btnOK_Click" TabIndex="100" />&nbsp;&nbsp;&nbsp;
     <asp:Button CssClass="button" ID="btnCancel" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>" CausesValidation="False" OnClick="btnCancel_Click" TabIndex="110" />
     <br />       
  </div>
  </center>

</div>
  
<br />

<MT:MTDataBinder ID="MTDataBinder1" runat="server"></MT:MTDataBinder>

</asp:Content>