<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="EditBillSoftExemptions.aspx.cs" Inherits="Tax_EditBillSoftExemptions" meta:resourcekey="PageResource1" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<MT:MTPanel ID="MTPanel1" runat="server"
    Collapsed="False" Collapsible="True" EnableChrome="True" Text="Edit BillSoft Exemption" meta:resourcekey="MTPanel1Resource1" >
  
    <asp:HiddenField ID="tbExemptionId" runat="server" />

    <MT:MTNumberField ID="tbIdAcc" runat="server" 
      TabIndex="100" ControlHeight="18" ControlWidth="200" 
      AllowDecimals="False" AllowNegative="False" AllowBlank="False" ReadOnly="False" 
      meta:resourcekey="tbIdAccResource" LabelWidth="120" LabelSeparator=":" HideLabel="False" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      MinLength="0" MinValue="0" 
      ValidationRegex="null" XType="LargeNumberField" XTypeNameSpace="ux.form" Listeners="{}" 
      />

    <MT:MTCheckBoxControl ID="cbApplyDescendents" runat="server" 
      TabIndex="110" ControlWidth="200" Checked="False" ReadOnly="False" 
      meta:resourcekey="cbApplyDescendentsResource1" BoxLabel="" HideLabel="False" 
      XType="Checkbox" XTypeNameSpace="form" Listeners="{}" Name="cbApplyDescendents" 
      />

    <MT:MTNumberField ID="tbPcode" runat="server" 
      TabIndex="120" ControlHeight="18" ControlWidth="200" 
      AllowDecimals="False" AllowNegative="False" AllowBlank="False" ReadOnly="False" 
      meta:resourcekey="tbPcodeResource" LabelWidth="120" LabelSeparator=":" HideLabel="False" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      MinLength="0" MinValue="-79228162514264337593543950335" 
      ValidationRegex="null" XType="LargeNumberField" XTypeNameSpace="ux.form" Listeners="{}" 
      />

    <MT:MTNumberField ID="tbCertificateId" runat="server" 
      TabIndex="130" ControlHeight="18" ControlWidth="200" 
      AllowDecimals="False" AllowNegative="False" AllowBlank="False" ReadOnly="False" 
      meta:resourcekey="tbCertificateIdResource" LabelWidth="120" LabelSeparator=":" HideLabel="False" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      MinLength="0" MinValue="0" 
      ValidationRegex="null" XType="LargeNumberField" XTypeNameSpace="ux.form" Listeners="{}" 
      />

    <MT:MTDropDown ID="ddTaxLevel" runat="server" 
      TabIndex="140" AllowBlank="False" ReadOnly="False" Editable="True" 
      meta:resourcekey="ddTaxLevelResource" LabelSeparator=":" HideLabel="False" 
      Listeners="{}" >
    </MT:MTDropDown>

    <MT:MTNumberField ID="tbTaxType" runat="server" 
      TabIndex="150" ControlHeight="18" ControlWidth="200" 
      AllowDecimals="False" AllowNegative="False" AllowBlank="False" ReadOnly="False" 
      meta:resourcekey="tbTaxTypeResource" LabelWidth="120" LabelSeparator=":" HideLabel="False" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      MinLength="0" MinValue="0" 
      ValidationRegex="null" XType="LargeNumberField" XTypeNameSpace="ux.form" Listeners="{}" 
      />

  <MT:MTDatePicker ID="dpStartDate" runat="server" Label="Exemption Start Date" AllowBlank="true" ControlHeight="18" ControlWidth="120" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="dpStartDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT" ReadOnly="False" TabIndex="160" XType="DateField" LabelSeparator=":" XTypeNameSpace="form" />
  <MT:MTDatePicker ID="dpEndDate" runat="server" Label="Exemption End Date" AllowBlank="true" ControlHeight="18" ControlWidth="120" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="dpEndDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT" ReadOnly="False" TabIndex="170" XType="DateField" LabelSeparator=":" XTypeNameSpace="form" />

  <div  class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK"  OnClientClick="return ValidateForm();" runat="server" 
              Text="<%$ Resources:Resource,TEXT_OK %>" OnClick="btnOK_Click" TabIndex="180" 
              meta:resourcekey="btnOKResource1" />      
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" 
              Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click" 
              CausesValidation="False" TabIndex="190" meta:resourcekey="btnCancelResource1" />
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>
  </MT:MTPanel>
</asp:Content>