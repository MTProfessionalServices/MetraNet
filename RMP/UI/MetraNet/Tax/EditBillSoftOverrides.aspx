<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="EditBillSoftOverrides.aspx.cs" Inherits="Tax_EditBillSoftOverrides" meta:resourcekey="PageResource1" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<mt:mtpanel ID="MTPanel1" runat="server"
    Collapsed="False" Collapsible="True" EnableChrome="True" 
    Text="BillSoft Overrides" meta:resourcekey="MTPanel1Resource1" >
    
    <asp:HiddenField ID="tbOverrideId" runat="server" />

    <MT:MTNumberField ID="tbIdAcc" runat="server" 
      TabIndex="100" ControlHeight="18" ControlWidth="200" 
      AllowDecimals="False" AllowNegative="False" AllowBlank="False" ReadOnly="False" 
      meta:resourcekey="tbIdAccResource" LabelWidth="120" LabelSeparator=":" HideLabel="False" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      MinLength="0" MinValue="0" 
      ValidationRegex="null" XType="LargeNumberField" XTypeNameSpace="ux.form" Listeners="{}" 
      />

    <MT:MTNumberField ID="tbPcode" runat="server" 
      TabIndex="110" ControlHeight="18" ControlWidth="200" 
      AllowDecimals="False" AllowNegative="False" AllowBlank="False" ReadOnly="False" 
      meta:resourcekey="tbPcodeResource" LabelWidth="120" LabelSeparator=":" HideLabel="False" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      MinLength="0" MinValue="0" 
      ValidationRegex="null" XType="LargeNumberField" XTypeNameSpace="ux.form" Listeners="{}" 
      />

    <MT:MTNumberField ID="tbTaxType" runat="server" 
      TabIndex="120" ControlHeight="18" ControlWidth="200" 
      AllowDecimals="False" AllowNegative="False" AllowBlank="False" ReadOnly="False" 
      meta:resourcekey="tbTaxTypeResource" LabelWidth="120" LabelSeparator=":" HideLabel="False" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      MinLength="0" MinValue="0" 
      ValidationRegex="null" XType="LargeNumberField" XTypeNameSpace="ux.form" Listeners="{}" 
      />

    <MT:MTCheckBoxControl ID="cbApplyDescendents" runat="server" 
      TabIndex="130" ControlWidth="200" 
      Checked="False" AllowBlank="False" ReadOnly="False"
      meta:resourcekey="cbApplyDescendentsResource1" BoxLabel="" HideLabel="False" 
      XType="Checkbox" XTypeNameSpace="form" Listeners="{}" 
      Name="cbApplyDescendents" 
      /> 

    <MT:MTCheckBoxControl ID="MTReplaceTaxLevel1" runat="server" 
      TabIndex="140" ControlWidth="200" 
      Checked="False" AllowBlank="False" ReadOnly="False"
      meta:resourcekey="cbReplaceTaxLevelResource1" BoxLabel="" HideLabel="False" 
      XType="Checkbox" XTypeNameSpace="form" Listeners="{}" 
      Name="MTReplaceTaxLevel1" 
      /> 
    
    <MT:MTDropDown ID="MTDropDownScope" runat="server" 
      TabIndex="150" AllowBlank="False" ReadOnly="False" Editable="True"
      meta:resourcekey="ddScope" LabelSeparator=":" HideLabel="False" 
      Listeners="{}" >
    </MT:MTDropDown>

    <MT:MTDropDown ID="MTDropDownTaxLevel" runat="server" 
      TabIndex="160" AllowBlank="False" ReadOnly="False" Editable="True"
      meta:resourcekey="ddTaxLevel" LabelSeparator=":" HideLabel="False" 
      Listeners="{}" >
    </MT:MTDropDown>

    <MT:MTNumberField ID="tbTaxRate" runat="server" 
      TabIndex="170" ControlHeight="18" ControlWidth="200" 
      AllowDecimals="True" AllowNegative="True" AllowBlank="False" ReadOnly="False" TrailingZeros="False" 
      meta:resourcekey="tbTaxRateResource1" LabelWidth="120" LabelSeparator=":" HideLabel="False" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      MinLength="0" MinValue="-79228162514264337593543950335" 
      ValidationRegex="null" XType="LargeNumberField" XTypeNameSpace="ux.form" Listeners="{}" />

    <!-- CORE-5960: "Disabling" Excess Tax Rate and Limit Indicator at UI level for Release 6.8.1. -->
    <MT:MTNumberField ID="tbExcessTaxRate" runat="server" 
      TabIndex="180" ControlHeight="18" ControlWidth="200" 
      AllowDecimals="True" AllowNegative="True" AllowBlank="False" ReadOnly="False" TrailingZeros="False" 
      meta:resourcekey="tbExcessTaxRateResource1" LabelWidth="120" LabelSeparator=":" HideLabel="False" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      MinLength="0" MinValue="-79228162514264337593543950335" 
      ValidationRegex="null" XType="LargeNumberField" XTypeNameSpace="ux.form" Listeners="{}" 
      Visible="false" />

    <MT:MTNumberField ID="tbLimitIndicator" runat="server" 
      TabIndex="190" ControlHeight="18" ControlWidth="200" 
      AllowDecimals="False" AllowNegative="False" AllowBlank="False" ReadOnly="False" 
      meta:resourcekey="tbLimitIndicatorResource1" LabelWidth="120" LabelSeparator=":" HideLabel="False" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      MinLength="0" MinValue="-79228162514264337593543950335" 
      ValidationRegex="null" XType="LargeNumberField" XTypeNameSpace="ux.form" Listeners="{}" 
      Visible="false" />
    
    <MT:MTDatePicker ID="dpStartDate" runat="server" Label="Override Effective Date" AllowBlank="true" ControlHeight="18" ControlWidth="120" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="dpStartDateResource1" 
      OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT" 
      ReadOnly="False" TabIndex="200" XType="DateField" LabelSeparator=":" XTypeNameSpace="form" />

    <div  class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK"  OnClientClick="return ValidateForm();" runat="server" 
              Text="<%$ Resources:Resource,TEXT_OK %>" OnClick="btnOK_Click" TabIndex="210" 
              meta:resourcekey="btnOKResource1" />      
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" 
              Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click" 
              CausesValidation="False" TabIndex="220" meta:resourcekey="btnCancelResource1" />
          </td>
        </tr>
      </table> 
    </center>    
    </div>
    </div>
  </mt:mtpanel>
</asp:Content>

