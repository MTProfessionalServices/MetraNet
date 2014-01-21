<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Account_ContactUpdate" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="ContactUpdate.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="Label1" runat="server" Text="Contact Information" meta:resourcekey="Label1Resource1"></asp:Label>
  </div>
  <br />

<div style="width:810px">
  <div id="divLblMessage" runat="server" visible="false" >
    <b>
    <div class="InfoMessage" style="margin-left:120px;width:400px;">
      <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
    </div>
    </b>
  </div>

  <!-- BILLING INFORMATION --> 
  <MT:MTDropDown ID="ddContactType" runat="server" Label="Contact Type" TabIndex="1" ControlWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddContactTypeResource1" ReadOnly="False"></MT:MTDropDown>
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server"></MTCDT:MTGenericForm>
  
  <!-- BUTTONS -->


    <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">   
      <center>
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="return ValidateForm();" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" meta:resourcekey="btnOKResource1" OnClick="btnOK_Click" TabIndex="500" />
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" CausesValidation="False" meta:resourcekey="btnCancelResource1" TabIndex="501" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table> 
        </center>    
    </div>
  </div>
</div>
<br />

  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
     <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Contact"
        BindingSourceMember="ContactType" ControlId="ddContactType" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>

</asp:Content>

