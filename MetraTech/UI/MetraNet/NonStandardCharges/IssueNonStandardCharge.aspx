<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="IssueNonStandardCharge.aspx.cs" Inherits="NonStandardCharges_IssueNonStandardCharge" meta:resourcekey="PageResource1" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTPanel ID="MTPanel1" runat="server"
    Collapsed="False" Collapsible="True" EnableChrome="True" Text="Issue Nonstandard Charge"
    meta:resourcekey="MTPanel1Resource1" >
    <table>
      <tr>
      <td>
    <MT:MTNumberField ID="tbQuantity" runat="server" AllowBlank="True" 
      ControlHeight="18" ControlWidth="200" HideLabel="False" LabelSeparator=":" 
      LabelWidth="120" Listeners="{}" MaxLength="-1" 
      meta:resourcekey="tbQuantityResource1" MinLength="0" OptionalExtConfig="" 
      ReadOnly="False" ValidationRegex="null" 
      XType="LargeNumberField" XTypeNameSpace="ux.form" AllowDecimals="False" 
      AllowNegative="False" 
      MaxValue="79228162514264337593543950335" 
      MinValue="0" />
      </td>
      <td>
      <MT:MTLabel ID="lblMaxAmount" runat="server" />
      </td>
      </tr>
      </table>
    <MT:MTNumberField ID="tbRate" runat="server" AllowBlank="False" 
      ControlHeight="18" ControlWidth="200" HideLabel="False" LabelSeparator=":" 
      LabelWidth="120" Listeners="{}" MaxLength="-1" 
      meta:resourcekey="tbRateResource1" MinLength="0" OptionalExtConfig="" 
      ReadOnly="False" ValidationRegex="null" 
      XType="LargeNumberField" XTypeNameSpace="ux.form" AllowDecimals="True" 
      AllowNegative="False" DecimalPrecision="2" TrailingZeros="true" 
      MaxValue="79228162514264337593543950335" 
      MinValue="0" />
    <MT:MTNumberField ID="tbRate3" runat="server" AllowBlank="True" 
      ControlHeight="18" ControlWidth="200" HideLabel="False" LabelSeparator=":" 
      LabelWidth="120" Listeners="{}" MaxLength="-1" 
      meta:resourcekey="tbRate3Resource1" MinLength="0" OptionalExtConfig="" 
      ReadOnly="False" ValidationRegex="null" 
      XType="LargeNumberField" XTypeNameSpace="ux.form" AllowDecimals="True" 
      AllowNegative="False" DecimalPrecision="2" TrailingZeros="true" 
      MaxValue="79228162514264337593543950335" 
      MinValue="0" />
    <MT:MTTextBoxControl ID="tbGLCode" runat="server" AllowBlank="True" 
      ControlHeight="18" ControlWidth="200" HideLabel="False" LabelSeparator=":" 
      LabelWidth="120" Listeners="{}" MaxLength="-1" 
      meta:resourcekey="tbGLCodeResource1" MinLength="0" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null" ReadOnly="False" ValidationRegex="null" 
      XType="TextField" XTypeNameSpace="form" />
    <MT:MTDropDown ID="ddReasonCode" runat="server" AllowBlank="False" 
      HideLabel="False" LabelSeparator=":" Listeners="{}" 
      meta:resourcekey="tbReasonCodeResource1" ReadOnly="False">
    </MT:MTDropDown>
    <MT:MTTextArea ID="taDescription" runat="server" AllowBlank="True" 
      Height="200px" Width="400px" 
      ControlHeight="200" ControlWidth="400" HideLabel="False" LabelSeparator=":" 
      LabelWidth="120" Listeners="{}" MaxLength="-1" 
      meta:resourcekey="taDescriptionResource1" MinLength="0" OptionalExtConfig="maxLength:Number.MAX_VALUE,
                              minLength:0" ReadOnly="False" ValidationRegex="null" 
      XType="TextArea" XTypeNameSpace="form" />
    <MT:MTDropDown ID="ddAdditionalCode" runat="server" AllowBlank="False" 
      HideLabel="False" LabelSeparator=":" Listeners="{}" 
      meta:resourcekey="ddAdditionalCodeResource1" ReadOnly="False"></MT:MTDropDown>
    <MT:MTDropDown ID="ddBillingPeriod" Label="Billing Period" runat="server" 
      AllowBlank="False" HideLabel="False" LabelSeparator=":" Listeners="{}" 
      meta:resourcekey="ddBillingPeriod1" ReadOnly="False">
    </MT:MTDropDown>

      <div  class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK"  OnClientClick="return ValidateForm();" runat="server" 
              Text="<%$ Resources:Resource,TEXT_OK %>" OnClick="btnOK_Click" TabIndex="150" 
              meta:resourcekey="btnOKResource1" />      
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" 
              Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click" 
              CausesValidation="False" TabIndex="160" meta:resourcekey="btnCancelResource1" />
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>
</MT:MTPanel>
</asp:Content>
