<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="TestControls" Title="MetraNet" CodeFile="TestControls.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<%@ Register src="UserControls/Hierarchy.ascx" tagname="Hierarchy" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
<script type="text/javascript">
  function onChange(selectField, value)
  {
    if(value == "c") {
      Ext.getCmp("ctl00_ContentPlaceHolder1_MTDropDown1").disable();
    }
    else {
      Ext.getCmp("ctl00_ContentPlaceHolder1_MTDropDown1").enable();
    }
  }
</script>

<MT:MTTitle ID="MTTitle1" Text="Test Controls" runat="server" />

  <uc1:Hierarchy ID="Hierarchy1" StartAccountType="system_mps" runat="server" />

<br />
  
<div style="width:810px">

  <div id="leftColumn" style="float:left; width:400px;">
    <MT:MTTextBoxControl ID="MTExtControl1" runat="server" AllowBlank="True" HideLabel="False" Label="First Name" Text="Kevin" TabIndex="1" /><br />
    <MT:MTTextBoxControl ID="MTTextBoxControl1" runat="server" AllowBlank="True" HideLabel="False" Label="Last Name" Text="Boucher" ReadOnly="True" TabIndex="2" />
    <span style="float:right">readonly</span><br />
    <MT:MTTextBoxControl ID="MTTextBoxControl2" runat="server" AllowBlank="True" HideLabel="True" Label="No Label" Text="No Label" TabIndex="3" /><br />
    &nbsp;<br />
    <MT:MTDropDown ID="ddBlank" runat="server" Label="No Blank" AllowBlank="False" Listeners="{ 'change' : { fn: this.onChange, scope: this } }" Name="MTDropDown2" TabIndex="4">
      <asp:ListItem>a</asp:ListItem>
      <asp:ListItem>b</asp:ListItem>
      <asp:ListItem>c</asp:ListItem>
    </MT:MTDropDown><span style="float:right">with change event</span><br />
    <MT:MTDropDown ID="MTDropDown1" runat="server" AllowBlank="True" Label="Allow Blank" Name="MTDropDown1" TabIndex="5">
      <asp:ListItem>None</asp:ListItem>
      <asp:ListItem>a</asp:ListItem>
      <asp:ListItem>b</asp:ListItem>
      <asp:ListItem>c</asp:ListItem>
    </MT:MTDropDown>&nbsp;<br />
    <MT:MTTextBoxControl ID="tbAlpha" runat="server" Label="Alpha" VType="alpha" TabIndex="6" Name="alpha" />
    <br />
    <MT:MTTextBoxControl ID="MTTextBoxControl6" runat="server" Label="Email" VType="email" TabIndex="7" />
    <br />
    <MT:MTNumberField ID="MTNumberField1" runat="server" Label="Number" MaxValue="1000"
      MinValue="-1000" AllowDecimals="True" TabIndex="8" />
    <br />
    &nbsp;<MT:MTNumberField ID="MTNumberField2" runat="server" AllowDecimals="False"
      Label="1 to 10" MaxValue="10" MinValue="1" TabIndex="9" />
    <br />
    <MT:MTNumberField ID="MTNumberField3" runat="server" TabIndex="20"
      Label="LargeNumberField" XType="LargeNumberField" XTypeNameSpace="ux.form" 
      AllowDecimals="True"  DecimalSeparator="." DecimalPrecision="10" />
    <br />
    <MT:MTDatePicker ID="MTDatePicker2" runat="server" Label="A Date" />
    <br />
    <MT:MTLiteralControl ID="MTLiteralControl1" runat="server" Label="Literal Control"
      Text="This is just text..." />
  </div>

  <div id="rightColumn" style="float:right; width:400px;">
    <MT:MTTextBoxControl ID="MTTextBoxControl3" runat="server" AllowBlank="False" HideLabel="False" Label="Required 1" Text="blah" TabIndex="10" /><br />
    <MT:MTTextBoxControl ID="MTTextBoxControl4" runat="server" AllowBlank="False" HideLabel="False" Label="Required 2" TabIndex="11" /><br />
    <MT:MTTextBoxControl ID="MTTextBoxControl5" runat="server" AllowBlank="True" HideLabel="False" Label="Other" TabIndex="12" /><br />
    <MT:MTCheckBoxControl ID="cb1" runat="server" BoxLabel="My Checkbox" LabelWidth="120" Name="cb1" Text="11" Value="11" TabIndex="13" /><br />
    <MT:MTCheckBoxControl ID="cb2" runat="server" BoxLabel="My Checkbox2" Name="cb2" Text="22" Value="22" TabIndex="14" />
    <br />
    <br />
    <MT:MTRadioControl ID="MTRadioControl1" runat="server" BoxLabel="My Radio1" Name="r1" Text="1" Value="1" TabIndex="15" />
    <MT:MTRadioControl ID="MTRadioControl2" runat="server" BoxLabel="My Radio2" Name="r1" Text="2" Value="2" TabIndex="16" />
    <br />
    <br />
    <MT:MTLabel ID="MTLabel1" runat="server" CssClass="ImportantMessage" Text="This is an important message!" />
    <br />
    <br />
    <MT:MTLabel ID="MTLabel2" runat="server" Text="This is just some text." />
    <br />
    <MT:MTTextArea ID="MTTextArea1" runat="server" Label="TextArea" ControlHeight="60" ControlWidth="250" Height="60px" Width="250px" MaxLength="1000" />
    <br />
  </div>
  
  <div style="clear:both">
    <MT:MTSection ID="MTSection1" runat="server" Text="Just a Section" />
    <br />
    <br />
    &nbsp;</div>
   
   <div>
     <MT:MTHtmlEditor ID="MTHtmlEditor1" runat="server" ControlHeight="100" ControlWidth="700"
    HideLabel="True" Label="My HTML Editor" Text="test" />
   </div> 
  
  <br />
   
  <table border="0" cellpadding="2" cellspacing="1" align="center">
    <tr>
      <td><br />
        <asp:Button CssClass="button" ID="btnOK" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" meta:resourcekey="btnOKResource1" OnClick="btnOK_Click" TabIndex="17" />&nbsp;&nbsp;&nbsp;
        <asp:Button CssClass="button" ID="btnCancel" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" CausesValidation="False" meta:resourcekey="btnCancelResource1" TabIndex="18" />
      </td>
    </tr>
  </table>  


</div>


</asp:Content>

