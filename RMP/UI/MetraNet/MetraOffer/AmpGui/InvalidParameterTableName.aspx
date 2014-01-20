<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="InvalidParameterTableName.aspx.cs" Inherits="AmpInvalidParameterTableName" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script language="javascript" type="text/javascript">

  function closeWindow() {
    top.Ext.getCmp('invalidParameterTableNameWindow').close();
  }

</script>

  <div style="padding-top: 20px;">
  <table style="width: 100%">
    <tr>
      <td width="40px" align="center">
        <asp:Image ID="ErrorImage" runat="server" ImageUrl="/Res/Images/icons/cross_22x22.png"/>
      </td>
      <td width="360px" align="left">
          <MT:MTLabel ID="Message" runat="server"
            Font-Bold="False" ForeColor="Black" Font-Size="9pt" 
            />
      </td>
    </tr>
  </table>
  </div>

  <div style="padding-left: 180px; padding-top: 20px;">
    <MT:MTButton ID="btnOK" runat="server" 
      Text="<%$ Resources:Resource,TEXT_OK %>"  OnClick="btnOK_Click"
      TabIndex="240" meta:resourcekey="btnOKResource1" />      
  </div>

 </asp:Content>

