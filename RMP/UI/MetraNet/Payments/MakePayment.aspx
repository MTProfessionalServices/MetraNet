<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_MakePayment" CodeFile="MakePayment.aspx.cs" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <script type="text/javascript">

    function onChange() {
      var SchedulePayment = Ext.get("ctl00_ContentPlaceHolder1_rcSchedulePaymentDate").dom.checked;
      if (SchedulePayment) {
        Ext.get("ctl00_ContentPlaceHolder1_dpSchedulePaymentDate").dom.disabled = false;
      } else {
        Ext.get("ctl00_ContentPlaceHolder1_dpSchedulePaymentDate").dom.disabled = true;
      }
      //which radio is checked
      if (Ext.get("ctl00_ContentPlaceHolder1_rcTotalAmountDue").dom.checked) {
        Ext.get("ctl00_ContentPlaceHolder1_tbOtherAmount").dom.disabled = true;
      } else {
        Ext.get("ctl00_ContentPlaceHolder1_tbOtherAmount").dom.disabled = false;
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
 
  <MT:MTTitle ID="MTTitle1" Text="Make a Payment" runat="server" meta:resourcekey="MakePayment" />
  <br />

  <MT:MTPanel ID="panel1" runat="server" Text="Payment Information" Collapsible="false" meta:resourcekey="panel1">
    <div class="left" style="width: 120px;">
      <h6>
        <asp:Label ID="lblPaymentAmount" runat="server" meta:resourcekey="lblPaymentAmount"></asp:Label></h6>
    </div>
    <div class="left">
      <MT:MTRadioControl LabelWidth="0" HideLabel="true" Label="" ID="rcTotalAmountDue" meta:resourcekey="rcTotalAmountDue"
        runat="server" Listeners="{ 'check' : onChange }" BoxLabel="Total amount due,"
        Name="r1" Text="1" Value="1" TabIndex="15" />
      <div>
        <div class="left" style="width: 120px;">
          <MT:MTRadioControl LabelWidth="0" HideLabel="true" ID="rcOtherAmount" runat="server"
            Listeners="{ 'check' : onChange }" BoxLabel="Other Amount" Name="r1" Text="2" Value="2"
            TabIndex="16" ControlWidth="50" meta:resourcekey="rcOtherAmount" />
        </div>
        <div class="left">
          <MT:MTNumberField MinValue="0" AllowNegative="false" AllowDecimals="true" ID="tbOtherAmount"
            DecimalPrecision="2" TrailingZeros="true"
            runat="server" ControlWidth="60" LabelSeparator="" LabelWidth="0" HideLabel="false"
            AllowBlank="True" Listeners="{ 'focus' : CheckOtherAmount }" />
        </div>
        <div class="clearer">
        </div>
      </div>
    </div>
    <div class="clearer">
    </div>
    <hr />
    <div class="left" style="width: 120px;">
      <h6>
        <asp:Label ID="lblPaymentMethod" runat="server" meta:resourcekey="lblPaymentMethod"></asp:Label></h6>
    </div>
    <div class="left">
      <div id="divExistingMethods" runat="server">
        <div id="Div3" style="float: left; width: 160px;">
          <MT:MTRadioControl LabelWidth="0" ID="rcExistingPaymentMethod" runat="server" Listeners="{ 'check' : onChange }"
            BoxLabel="Existing Payment Method" Name="r3" Text="1" Value="1" TabIndex="15" meta:resourcekey="rcExistingPaymentMethod" />
        </div>
        <div style="float: left; width: 100px">
          <MT:MTDropDown ControlWidth="170" LabelWidth="0" HideLabel="true" ID="ddPaymentMethod"
            AllowBlank="true" runat="server">
          </MT:MTDropDown>
        </div>
        <div class="clearer">
        </div>
      </div>
      <MT:MTRadioControl LabelWidth="0" ID="rcAddACHAccount" runat="server" Listeners="{ 'check' : onChange }"
        BoxLabel="Checking/Savings Account" Name="r3" Text="2" Value="2" TabIndex="16"
        meta:resourcekey="rcAddACHAccount" />
      <MT:MTRadioControl LabelWidth="0" ID="rcAddCreditCard" runat="server" Listeners="{ 'check' : onChange }"
        BoxLabel="Credit/debit card" Name="r3" Text="3" Value="3" TabIndex="17" meta:resourcekey="rcAddCreditCard" />
    </div>
    <div class="clearer">
    </div>
    <hr />
    <div class="left" style="width: 120px;">
      <h6>
        <asp:Label ID="lblPaymentDate" runat="server" meta:resourcekey="lblPaymentDate"></asp:Label></h6>
    </div>
    <div class="left">
      <MT:MTRadioControl ID="rcPayNow" LabelWidth="0" runat="server" BoxLabel="Pay Now"
        Name="r2" Text="1" Value="1" TabIndex="17" meta:resourcekey="rcPayNow" Listeners="{ 'check' : onChange }" />
      <div style="width: 300px;">
        <div id="Div1" style="float: left; width: 150px;">
          <MT:MTRadioControl LabelWidth="0" ID="rcSchedulePaymentDate" runat="server" BoxLabel="Schedule Payment Date"
            Name="r2" Text="2" Value="2" TabIndex="18" meta:resourcekey="rcSchedulePaymentDate"
            Listeners="{ 'check' : onChange  }" />
        </div>
        <div id="Div2" style="float: left; width: 130px;">
          <MT:MTDatePicker ID="dpSchedulePaymentDate" runat="server" AllowBlank="True" TabIndex="220"
            ControlWidth="80" HideLabel="true" LabelSeparator="" LabelWidth="0" Listeners="{}"
            OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT"
            ReadOnly="False" XType="DateField" XTypeNameSpace="form"/>
        </div>
        <div class="clearer">
        </div>
      </div>
      <div class="clearer">
      </div>
    </div>
    <div class="clearer">
    </div>
  </MT:MTPanel>

  <!-- Buttons -->
  <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center"> 
      <center>  
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" meta:resourcekey="Cancel" OnClick="btnCancel_Click"
             CausesValidation="False" Text="Cancel" />
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnNext" runat="server" OnClientClick="return ValidateForm();" meta:resourcekey="btnNext"
              OnClick="btnNext_Click" Text="Next" />
          </td>
        </tr>
      </table>  
     </center>   
    </div>
  </div>

  <script type="text/javascript">
    Ext.onReady(function () {
      onChange();
    });    
  </script>
</asp:Content>
