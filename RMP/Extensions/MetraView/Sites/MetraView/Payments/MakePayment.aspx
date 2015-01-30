<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_MakePayment" CodeFile="MakePayment.aspx.cs" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Src="../UserControls/PayerInfo.ascx" TagName="PayerInfo" TagPrefix="uc2" %>
<%@ Register Src="../UserControls/BillAndPayments.ascx" TagName="BillAndPayments" TagPrefix="uc4" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

<script type="text/javascript">

  function onChange() {
    if (Ext.get("ctl00_ContentPlaceHolder1_rcSchedulePaymentDate") != null) {
      var SchedulePayment = Ext.get("ctl00_ContentPlaceHolder1_rcSchedulePaymentDate").dom.checked;
      if (SchedulePayment) {
        Ext.get("ctl00_ContentPlaceHolder1_dpSchedulePaymentDate").dom.disabled = false;
      } else {
        Ext.get("ctl00_ContentPlaceHolder1_dpSchedulePaymentDate").dom.disabled = true;
      }
    }

    //which radio is checked
    if (Ext.get("ctl00_ContentPlaceHolder1_rcTotalAmountDue") != null) {
      if (Ext.get("ctl00_ContentPlaceHolder1_rcTotalAmountDue").dom.checked) {
        Ext.get("ctl00_ContentPlaceHolder1_tbOtherAmount").dom.disabled = true;
      } else {
        Ext.get("ctl00_ContentPlaceHolder1_tbOtherAmount").dom.disabled = false;
      }
    }

    // only enable payment method drop down if Existing Payment Method radio button is checked
    if (Ext.get("ctl00_ContentPlaceHolder1_rcExistingPaymentMethod") != null) {
      if (Ext.get("ctl00_ContentPlaceHolder1_rcExistingPaymentMethod").dom.checked) {
        Ext.getCmp("<%=ddPaymentMethod.ClientID%>").enable();
      } else {
        Ext.getCmp("<%=ddPaymentMethod.ClientID%>").disable();
      }
    }
  }

  function CheckOtherAmount() {
    Ext.get("ctl00_ContentPlaceHolder1_rcOtherAmount").dom.checked = true;
//    var v = Ext.get("ctl00_ContentPlaceHolder1_tbOtherAmount").dom.value;
//    if (v != "") {
//      Ext.get("ctl00_ContentPlaceHolder1_rcOtherAmount").dom.checked = true;
//    }
  }

</script>
  <h1><asp:Localize ID="Localize1" meta:resourcekey="MakePayment" runat="server" Text="Make a Payment"></asp:Localize></h1>
  
  <div class="box500">
    <div class="box500top"></div>
    <div class="box">
      <table cellspacing="10" cellpadding="0">
        <tr>
          <td width="50%">
            <asp:Localize ID="Localize6" meta:resourcekey="InstructionsText" runat="server" Text="Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat"></asp:Localize>
          </td>
          <td width="50%" style="vertical-align:top">
            <uc4:BillAndPayments ID="BillAndPayments2" runat="server" HidePaymentButton="true" />
          </td>
        </tr>
      </table>
      <div class="clearer"></div>
    </div>
  </div>
  
  <div class="box500">
    <div class="box500top"></div>
    <div class="box">
      <div class="left"  style="width: 120px;">
      <h6 style="font-size:12px"><asp:Label ID="lblPaymentAmount" runat="server" meta:resourcekey="lblPaymentAmount"></asp:Label></h6>
      </div>
      <div class="left">
        <MT:MTRadioControl LabelWidth="0" HideLabel="true" ID="rcTotalAmountDue" runat="server" Listeners="{ 'check' : onChange }" BoxLabel="Total amount due,"
          Name="r1" Text="1" Value="1" TabIndex="15" meta:resourcekey="rcTotalAmountDue" />
        <div>
          <div class="left" style="width: 150px;white-space:nowrap">
            <MT:MTRadioControl  LabelWidth="0" HideLabel="true" ID="rcOtherAmount" runat="server" Listeners="{ 'check' : onChange }" BoxLabel="Other Amount" Name="r1"
              Text="2" Value="2" TabIndex="16" ControlWidth="50" meta:resourcekey="rcOtherAmount"/>
          </div>
          <div class="left">
            <MT:MTNumberField MinValue="0" AllowNegative="false" AllowDecimals="true" ID="tbOtherAmount" runat="server" ControlWidth="60" LabelSeparator=""
              LabelWidth="0" HideLabel="false" AllowBlank="True" DecimalPrecision="2" TrailingZeros="true"
              Listeners="{ 'focus' : CheckOtherAmount }" ControlHeight="25" />
          </div>
          <div class="Left" style="padding-top:3px;padding-left:2px">
            <MT:MTLabel ID="lbTrailingCurrencySymbol" runat="server" />
          </div>
          <div class="clearer"></div>
        </div>
        </div>
        <div class="clearer"></div>
      
      <hr />
      <div class="left"  style="width: 120px;">
        <h6 style="font-size:12px"><asp:Label ID="lblPaymentMethod" runat="server"  meta:resourcekey="lblPaymentMethod"></asp:Label></h6>
      </div>
      <div class="left">
        <div id="divExistingMethods" runat="server">
          <div id="Div3" style="float:left; width:160px;">
          <MT:MTRadioControl LabelWidth="0"  ID="rcExistingPaymentMethod" runat="server" Listeners="{ 'check' : onChange }" BoxLabel="Existing Payment Method"
            Name="r3" Text="1" Value="1" TabIndex="15" meta:resourcekey="rcExistingPaymentMethod" /></div>
            <div style="float:left; width:100px" >
          <MT:MTDropDown ControlWidth="170" LabelWidth="0" HideLabel="true" ID="ddPaymentMethod"  AllowBlank="true" runat="server"></MT:MTDropDown></div>
          <div class="clearer"></div>
        </div>
        <MT:MTRadioControl LabelWidth="0"  ID="rcAddACHAccount" runat="server" Listeners="{ 'check' : onChange }" BoxLabel="Checking/Savings Account"
          Name="r3" Text="2" Value="2" TabIndex="16" meta:resourcekey="rcAddACHAccount" />
        <MT:MTRadioControl LabelWidth="0"  ID="rcAddCreditCard" runat="server" Listeners="{ 'check' : onChange }" BoxLabel="Credit/debit card"
          Name="r3" Text="3" Value="3" TabIndex="17" meta:resourcekey="rcAddCreditCard" />
      </div>
      <div class="clearer"></div>
        
        
      <hr />
      
      <div class="left"  style="width: 120px;">
      <h6 style="font-size:12px"><asp:Label ID="lblPaymentDate" runat="server" meta:resourcekey="lblPaymentDate"></asp:Label></h6>
      </div>   
      <div class="left">
      <MT:MTRadioControl ID="rcPayNow" LabelWidth="0"  runat="server" BoxLabel="Pay Now" Name="r2"
        Text="1" Value="1" TabIndex="17" meta:resourcekey="rcPayNow" Listeners="{ 'check' : onChange }" />
      <div style="width: 300px;">
        <div id="Div1" style="float: left; width: 150px;">
          <MT:MTRadioControl LabelWidth="0"  ID="rcSchedulePaymentDate" runat="server" BoxLabel="Schedule Payment Date"
            Name="r2" Text="2" Value="2" TabIndex="18" meta:resourcekey="rcSchedulePaymentDate" Listeners="{ 'check' : onChange  }" />
        </div>
        <div id="Div2" style="float: left; width: 130px;">
          <MT:MTDatePicker ID="dpSchedulePaymentDate" runat="server" AllowBlank="True" TabIndex="220"
            ControlWidth="80" HideLabel="true" LabelSeparator="" LabelWidth="0" Listeners="{}"
            OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT"
            ReadOnly="False" XType="DateField" XTypeNameSpace="form" />
        </div>
        <div class="clearer"></div>
      </div>
      
      <div class="clearer"></div>
      </div>
      
      
      <div class="clearer"></div>
    </div>
    
  </div>
  
  
  <div>
    <div class="left">
    <div id="divCancel" runat="server" class="button">
      <span class="buttonleft"><!--leftcorner--></span>
      <asp:LinkButton ID="btnCancel" runat="server" CausesValidation="False" OnClick="btnCancel_Click" Text="Cancel" meta:resourcekey="Cancel"></asp:LinkButton>
      <span class="buttonright"><!--rightcorner--></span>
    </div>
    </div>

    <div class = "right">
      <div id="divNext" runat="server" class="button">
        <span class="buttonleft"><!--leftcorner--></span>
        <asp:LinkButton ID="btnNext" runat="server" OnClientClick="return ValidateForm();" OnClick="btnNext_Click"  meta:resourcekey="btnNext" Text="Next"></asp:LinkButton>
        <span class="buttonright"><!--rightcorner--></span>
    </div>
    </div>
  </div>

  <script type="text/javascript">
    Ext.onReady(function() {
      onChange();
    });    
  </script>
  
  </asp:Content>
