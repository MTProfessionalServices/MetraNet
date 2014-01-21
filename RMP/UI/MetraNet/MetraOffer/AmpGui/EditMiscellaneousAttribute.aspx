<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="EditMiscellaneousAttribute.aspx.cs" Inherits="AmpEditMiscellaneousAttributePage" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script language="javascript" type="text/javascript">

  function closeWindow() {
    top.Ext.getCmp('editMiscAttributeWindow').close();
  }

</script>
  <table style="width: 100%;">
    <tr>
      <td style="padding-left: 20px; padding-top: 20px;"  valign="bottom" width="15%">
        <MT:MTLabel ID="NameLabel" meta:resourcekey="NameLabel" runat="server" 
          Font-Bold="True" ForeColor="Black" Font-Size="8pt" Text="Name:"/>
      </td>
      <td style="padding-top: 20px;" valign="bottom" align="left" width="85%">
        <MT:MTLabel ID="Name" runat="server" 
          Font-Bold="False" ForeColor="Black" Font-Size="8pt" />
      </td>
    </tr>
    <tr>
      <td style="padding-top: 10px; padding-left: 20px;"  valign="top" width="15%">
        <MT:MTLabel ID="ValueLabel" meta:resourcekey="ValueLabel" runat="server" 
          Font-Bold="True" ForeColor="Black" Font-Size="8pt" Text="Value:"/>
      </td>
      <td style="padding-top: 5px;" width="85%">
         <ampc:AmpTextboxOrDropdown ID="ctrlValue" runat="server"
             TextboxIsNumeric="false">
         </ampc:AmpTextboxOrDropdown>
      </td>
    </tr>
  </table>
  <br/>
  
  <br/>
  <div style="clear:both;">
      <table style="margin-top:30px; margin-left:130px;" cellspacing="30">
        <tr>
          <td>
            <MT:MTButton ID="btnOK" runat="server" 
              Text="<%$ Resources:Resource,TEXT_OK %>"  OnClick="btnOK_Click" 
              OnClientClick="return ValidateForm();" 
              TabIndex="240" meta:resourcekey="btnOKResource1" />      
          </td>
          <td>
            <MT:MTButton ID="btnCancel" runat="server" 
              Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click" 
              CausesValidation="False" TabIndex="250" meta:resourcekey="btnCancelResource1" />
          </td>
        </tr>
      </table>
  </div>

 </asp:Content>

