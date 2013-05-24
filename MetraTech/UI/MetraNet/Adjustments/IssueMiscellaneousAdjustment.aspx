<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="IssueMiscellaneousAdjustment.aspx.cs" Inherits="Adjustments_IssueMiscellaneousAdjustment" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">  
  <MT:MTPanel ID="MTPanel1" runat="server" Text="Issue Miscellaneous Adjustment" 
    Collapsed="False" Collapsible="True" EnableChrome="True" 
    meta:resourcekey="MTPanel1Resource1" >
    <table>
    <tr>
    
    <td><MT:MTNumberField ID="adjAmountFld" Label="Amount" runat="server" 
      AllowBlank="False" AllowDecimals="True" DecimalPrecision="2" TrailingZeros="true" 
      AllowNegative="True" ControlHeight="18" ControlWidth="200" 
      HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      meta:resourcekey="adjAmountFldResource1" MinLength="0" 
      MinValue="-79228162514264337593543950335" OptionalExtConfig="" 
      ReadOnly="False" ValidationRegex="null" 
      XType="LargeNumberField" XTypeNameSpace="ux.form" /></td>
      <td><MT:MTLabel ID="lblMaxAmount" runat="server" /></td>
      </tr>
      </table>
    <MT:MTDropDown ID="ddReasonCode" Label="Reason Code" runat="server" 
      AllowBlank="False" HideLabel="False" LabelSeparator=":" Listeners="{}" 
      meta:resourcekey="ddReasonCodeResource1" ReadOnly="False">
    </MT:MTDropDown>
    <MT:MTTextArea ID="adjDescriptionTextBox" Label="Description" runat="server" 
      AllowBlank="True" Height="200px" Width="400px" ControlHeight="200" 
      ControlWidth="400" HideLabel="False" LabelSeparator=":" LabelWidth="120" 
      Listeners="{}" MaxLength="-1" meta:resourcekey="adjDescriptionTextBoxResource1" 
      MinLength="0" OptionalExtConfig="maxLength:Number.MAX_VALUE,
                              minLength:0" ReadOnly="False" ValidationRegex="null" 
      XType="TextArea" XTypeNameSpace="form" />
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


