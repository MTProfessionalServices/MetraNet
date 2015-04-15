<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="IssueMiscellaneousAdjustment.aspx.cs" Inherits="Adjustments_IssueMiscellaneousAdjustment" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
  
 <MT:MTPanel ID="MTPanel1" runat="server" Text="Issue Miscellaneous Adjustment" 
    Collapsed="False" Collapsible="True" EnableChrome="True" 
    meta:resourcekey="MTPanel1Resource1" >
    <table id="adjustmentSummary">
    <tr>
      <td colspan="2">
        <MT:MTNumberField ID="adjAmountFld" Label="Amount" runat="server"
          AllowBlank="False" AllowDecimals="True" DecimalPrecision="2" TrailingZeros="true"
          AllowNegative="True" ControlHeight="18" ControlWidth="200"
          HideLabel="False" LabelSeparator=":" LabelWidth="170" Listeners="{}"
          MaxLength="22" MaxValue="999999999999999"
          meta:resourcekey="adjAmountFldResource1" MinLength="0"
          MinValue="-999999999999999" OptionalExtConfig=""
          ReadOnly="False" />
      </td>
    </tr>
    <tr>
      <td colspan="2"><MT:MTNumberField ID="adjAmountFldTaxFederal" Label="Tax Federal" runat="server" 
        AllowBlank="True" AllowDecimals="True" DecimalPrecision="2" TrailingZeros="true" 
        AllowNegative="True" ControlHeight="18" ControlWidth="200" 
        HideLabel="False" LabelSeparator=":" LabelWidth="170" Listeners="{}" 
        MaxLength="22" MaxValue="999999999999999" 
        meta:resourcekey="adjAmountFldResourceTaxFederal" MinLength="0" 
        MinValue="-999999999999999" OptionalExtConfig="" 
        ReadOnly="False" />
      </td>
    </tr>
    <tr>
      <td colspan="2"><MT:MTNumberField ID="adjAmountFldTaxState" Label="Tax State" runat="server" 
        AllowBlank="True" AllowDecimals="True" DecimalPrecision="2" TrailingZeros="true" 
        AllowNegative="True" ControlHeight="18" ControlWidth="200" 
        HideLabel="False" LabelSeparator=":" LabelWidth="170" Listeners="{}" 
        MaxLength="22" MaxValue="999999999999999" 
        meta:resourcekey="adjAmountFldResourceTaxState" MinLength="0" 
        MinValue="-999999999999999" OptionalExtConfig="" 
        ReadOnly="False" />
      </td>
    </tr>
    <tr>
      <td colspan="2"><MT:MTNumberField ID="adjAmountFldTaxCounty" Label="Tax County" runat="server" 
        AllowBlank="True" AllowDecimals="True" DecimalPrecision="2" TrailingZeros="true" 
        AllowNegative="True" ControlHeight="18" ControlWidth="200" 
        HideLabel="False" LabelSeparator=":" LabelWidth="170" Listeners="{}" 
        MaxLength="22" MaxValue="999999999999999" 
        meta:resourcekey="adjAmountFldResourceTaxCounty" MinLength="0" 
        MinValue="-999999999999999" OptionalExtConfig="" 
        ReadOnly="False" />
      </td>
    </tr>
    <tr>
      <td colspan="2"><MT:MTNumberField ID="adjAmountFldTaxLocal" Label="Tax Local" runat="server" 
        AllowBlank="True" AllowDecimals="True" DecimalPrecision="2" TrailingZeros="true" 
        AllowNegative="True" ControlHeight="18" ControlWidth="200" 
        HideLabel="False" LabelSeparator=":" LabelWidth="170" Listeners="{}" 
        MaxLength="22" MaxValue="999999999999999" 
        meta:resourcekey="adjAmountFldResourceTaxLocal" MinLength="0" 
        MinValue="-999999999999999" OptionalExtConfig="" 
        ReadOnly="False" />
      </td>
    </tr>
    <tr>
      <td colspan="2"><MT:MTNumberField ID="adjAmountFldTaxOther" Label="Tax Other" runat="server" 
        AllowBlank="True" AllowDecimals="True" DecimalPrecision="2" TrailingZeros="true" 
        AllowNegative="True" ControlHeight="18" ControlWidth="200" 
        HideLabel="False" LabelSeparator=":" LabelWidth="170" Listeners="{}" 
        MaxLength="22" MaxValue="999999999999999" 
        meta:resourcekey="adjAmountFldResourceTaxOther" MinLength="0" 
        MinValue="-999999999999999" OptionalExtConfig="" 
        ReadOnly="False" />
      </td>
    </tr>
    <tr><td colspan="2" style="text-align: center"><img id="TotalLineAdj" src="/Res/Images/TotalLine.png"></td></tr>
    <tr>
       <td><MT:MTNumberField ID="adjAmountFldTaxToatl" Label="Total Adjustment Being Issued" runat="server"  Enabled="False"
        AllowBlank="True" AllowDecimals="True" DecimalPrecision="2" TrailingZeros="true" 
        AllowNegative="True" ControlHeight="18" ControlWidth="200" 
        HideLabel="False" LabelSeparator=":" LabelWidth="170" Listeners="{}" 
        MaxLength="22" MaxValue="999999999999999" 
        meta:resourcekey="adjAmountFldResourceTaxTotal" MinLength="0" 
        MinValue="-999999999999999" OptionalExtConfig="" 
        ReadOnly="False" />
      </td>
      <td style="vertical-align: top;"><MT:MTLabel ID="lblMaxAmount" runat="server"/></td>
    </tr>
    </table>
    <br/>
    <MT:MTDropDown ID="ddReasonCode" Label="Reason Code" runat="server" 
      AllowBlank="False" HideLabel="False" LabelSeparator=":" Listeners="{}" LabelWidth="170" 
      meta:resourcekey="ddReasonCodeResource1" ReadOnly="False">
    </MT:MTDropDown>
    <MT:MTTextArea ID="adjDescriptionTextBox" Label="Internal Description" runat="server" 
      AllowBlank="True" Height="200px" Width="400px" ControlHeight="200" 
      ControlWidth="400" HideLabel="False" LabelSeparator=":" LabelWidth="170" 
      Listeners="{}" MaxLength="-1" meta:resourcekey="adjDescriptionTextBoxResource1" 
      MinLength="0" OptionalExtConfig="maxLength:Number.MAX_VALUE,
                              minLength:0" ReadOnly="False" ValidationRegex="null" 
      XType="TextArea" XTypeNameSpace="form" />
    <MT:MTTextArea ID="adjSubscriberDescriptionTextBox" Label="Subscriber Description" runat="server" 
      AllowBlank="True" Height="200px" Width="400px" ControlHeight="200"
      ControlWidth="400" HideLabel="False" LabelSeparator=":" LabelWidth="170" 
      Listeners="{}" MaxLength="-1" meta:resourcekey="adjDescriptionTextBoxResource2" 
      MinLength="0" OptionalExtConfig="maxLength:Number.MAX_VALUE,
                              minLength:0" ReadOnly="False" ValidationRegex="null" 
      XType="TextArea" XTypeNameSpace="form" />
    <MT:MTDropDown ID="ddBillingPeriod" Label="Billing Period" runat="server" 
      AllowBlank="False" HideLabel="False" LabelSeparator=":" Listeners="{}" LabelWidth="170" 
      meta:resourcekey="ddBillingPeriod1" ReadOnly="False">
    </MT:MTDropDown>
</MT:MTPanel>
  <div id="CreditNotesPanelDiv" runat="server">
    <MT:MTPanel ID="MTPanel2" runat="server" Text="Issue Credit Note For This Adjustment"
      Collapsed="False" Collapsible="True" EnableChrome="True"
      meta:resourcekey="MTPanel2Resource1">
      <MT:MTCheckBoxControl ID="cbIssueCreditNote" runat="server" BoxLabel="Issue Credit Note For This Adjustment"
        TabIndex="240" ControlWidth="400" Checked="False" HideLabel="True" LabelSeparator=":" LabelWidth="170"
        Listeners="{ 'check' : { fn: this.enableControls, scope: this } }" meta:resourcekey="cbIssueCreditNoteResource1"
        Name="cbIssueCreditNote" ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />
      <br />
      <MT:MTDropDown ID="ddTemplateTypes" runat="server" Label="Credit Note Template To Use"
        LabelWidth="170" AllowBlank="False" HideLabel="False" LabelSeparator=":" Listeners="{}"
        meta:resourcekey="ddTemplateTypesResource1" ReadOnly="False" Enabled="False">
      </MT:MTDropDown>
      <MT:MTTextArea ID="CommentTextBox" Label="Comment" runat="server"
        AllowBlank="True" Height="200px" Width="400px" ControlHeight="200"
        ControlWidth="400" HideLabel="False" LabelSeparator=":" LabelWidth="170"
        Listeners="{}" MaxLength="255" meta:resourcekey="CommentTextBoxResource1"
        MinLength="0"
        ReadOnly="False" Enabled="False" ValidationRegex="null"
        XType="TextArea" XTypeNameSpace="form" />
    </MT:MTPanel>
  </div>
  <div class="x-panel-btns-ct">
    <div style="width: 630px" class="x-panel-btns x-panel-btns-center">
      <center>
        <table cellspacing="0">
          <tr>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTButton1" OnClientClick="if(checkButtonClickCount()){return ValidateForm();} else {return false;}"
                runat="server" Text="<%$ Resources:Resource,TEXT_OK %>" OnClick="btnOK_Click"
                TabIndex="150" meta:resourcekey="btnOKResource1" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTButton2" runat="server"
                Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click"
                CausesValidation="False" TabIndex="160" meta:resourcekey="btnCancelResource1" />
            </td>
          </tr>
        </table>
      </center>
    </div>
  </div>
  <script type="text/javascript" src="../Scripts/jquery-1.7.2.js"></script>
  <script type="text/javascript" src="IssueMiscellaneousAdjustment.aspx.js?v=1.1"></script>
</asp:Content>

