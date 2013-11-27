<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Templates_AddTemplate" Title="MetraNet" meta:resourcekey="PageResource1" CodeFile="AddTemplate.aspx.cs" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="MTTitle1" runat="server" Text="Add Template" meta:resourcekey="MTTitle1Resource1" /><br />
  <div style="width:810px">
  
  <MT:MTPanel ID="MTPanel1" Width="630" runat="server" meta:resourcekey="MTTitle1Resource1" Collapsible="false">
  <asp:Panel ID="PanelControls" runat="server" Visible="True">
    <div style="text-align:left; width: 410px;">
      <MT:MTDropDown ID="ddAccountTypes" runat="server" Label="Account Type" LabelWidth="200" ControlWidth="200" ListWidth="200" AllowBlank="False" HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddAccountTypesResource1" ReadOnly="False"></MT:MTDropDown><br />
<%--      <MT:MTCheckBoxControl ID="cbInherit" Checked="true" BoxLabel="Inherit parent template" runat="server" LabelWidth="200" meta:resourcekey="cbInheritResource1" />--%>
    </div> 
  </asp:Panel></MT:MTPanel>
  <asp:Panel ID="PanelMessage" runat="server" Visible="False">
    <br />
    <div class="InfoMessage" style="margin-left:120px;width:400px;">
      <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
    </div>
    <br />
  </asp:Panel>
  
  
  <div  class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center">  
    <center> 
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK"  OnClientClick="if (checkButtonClickCount() == true) {return onOK();} else {return false;}" runat="server" 
              Text="<%$Resources:Resource,TEXT_OK%>" TabIndex="150" />      
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server"
              OnClientClick="return checkButtonClickCount();"
              Text="<%$Resources:Resource,TEXT_CANCEL%>" OnClick="btnCancel_Click"
              CausesValidation="False" TabIndex="160" />
          </td>
        </tr>
      </table> 
       </center>    
    </div>
  </div>
 
  </div>
  <script type="text/javascript">
    // HANDLE OK CLICK
    function onOK()
    {
      var args = "SelectedAccountType=" + Ext.get("ctl00_ContentPlaceHolder1_ddAccountTypes").dom.value + "**";
      args += "InheritParentTemplateString=" + "false";//  Ext.get("ctl00_ContentPlaceHolder1_cbInherit").dom.checked;
      pageNav.Execute("TemplateEvents_OKAddTemplate_Client", args, results);
      return false;
    }
    
    function results(response)
    {
      Ext.UI.msg("Error", response);
    }
  </script>
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="this" BindingSourceMember="AccountTypes" ControlId="ddAccountTypes" ErrorMessageLocation="RedTextAndIconBelow"></MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" ControlId="btnOK" 
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder> 

</asp:Content>

