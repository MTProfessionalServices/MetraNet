<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_SetUDRCAccount"
  Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" CodeFile="SetUDRCAccount.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="lblSetUDRChargeAccountTitle" runat="server" Text="Unit Dependent Recurring Charge Account Configuration"
      meta:resourcekey="lblSetUDRChargeAccountTitleResource1"></asp:Label>
  </div>
  <br />
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
    Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server">
  </MTCDT:MTGenericForm>
  <input type="hidden" id="AcctIdTextBox" runat="server" />
  
  <div class="x-panel-btns-ct">
    <div style="width: 725px" class="x-panel-btns x-panel-btns-center">
    <center>
      <table cellspacing="0">
        <tr>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="return Validate();" Width="50px" runat="server"
              Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="390" />
          </td>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>"
              CausesValidation="False" TabIndex="400" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table>
      </center>
    </div>
  </div>
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>

  <script type="text/javascript">
       function Validate()
       {
       
           if(Ext.get("ctl00_ContentPlaceHolder1_tbChargeAccountId").dom.value == '')
           { 
              return false;
           }
           
          var accIDregex = new RegExp('.*\\((\\d+)\\)');
           var acctID = Ext.get("ctl00_ContentPlaceHolder1_tbChargeAccountId").dom.value + '';
           var matches = acctID.match(accIDregex);          
           if(matches == null)
           {
              Ext.get("<%=AcctIdTextBox.ClientID %>").dom.value = 0; 
           }
           else
           {
              Ext.get("<%=AcctIdTextBox.ClientID %>").dom.value = matches[1];               
           }
           return ValidateForm();
           
           
       
       }
  </script>

</asp:Content>
