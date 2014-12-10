<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="ScheduleMinutely.aspx.cs" Inherits="ScheduleMinutely" Title="MetraNet"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <script type="text/javascript">
    Ext.onReady(function () {
      // Record the initial values of the page's controls.
      // (Note:  This is called here, and not on the master page,
      // because the call to document.getElementById() returns null
      // if executed on the master page.)
      var el = document.getElementById("ctl00_PanelActiveAccount");
      if (el != null)
        el.style.display = 'none';
    });

    function validate() {
      if ((Ext.get("<%=tbDays.ClientID %>").dom.value == '') && (Ext.get("<%=ddHours.ClientID %>").dom.value == '0') && (Ext.get("<%=ddMinutes.ClientID %>").dom.value == '0')) {
        top.Ext.Msg.show({
          title: TEXT_ERROR_MSG,
          msg: TEXT_INVALID_RECUR_PATTERN,
          buttons: Ext.Msg.OK,
          icon: Ext.MessageBox.INFO
        });
        return false;
      }
      else {
        return ValidateForm();
      }
    }

    function goBack() {
      window.getFrameMetraNet().MainContentIframe.location.href = 'ScheduledAdaptersList.aspx';
      return false;
    }
  
  </script>
  <MT:MTPanel ID="RecurrencePatternPanel" runat="server" meta:resourcekey="RecurrencePatternPanelResource1"
    Text="Recurrence Pattern" Width="600">
    <MT:MTLiteralControl ID="RecurEveryLiteral" runat="server" Label="Recur every" LabelWidth="170"
      LabelSeparator="" meta:resourcekey="RecurEveryLiteralResource1" />
    <MT:MTTextBoxControl ID="tbDays" runat="server" AllowBlank="True" Label="Day(s)"
      TabIndex="200" ControlWidth="30" ControlHeight="18" HideLabel="False" LabelSeparator=":"
      LabelWidth="140" Listeners="{}" meta:resourcekey="tbDaysResource1" ReadOnly="False"
      XType="TextField" XTypeNameSpace="form" />
    <MT:MTDropDown ID="ddHours" runat="server" AllowBlank="True" Label="Hour(s)" TabIndex="210"
      ControlWidth="40" ListWidth="40" HideLabel="False" LabelSeparator=":" Listeners="{}"
      meta:resourcekey="ddHoursResource1" ReadOnly="False" LabelWidth="140">
    </MT:MTDropDown>
    <MT:MTDropDown ID="ddMinutes" runat="server" AllowBlank="True" Label="Minute(s)"
      TabIndex="220" ControlWidth="40" ListWidth="40" HideLabel="False" LabelSeparator=":"
      Listeners="{}" meta:resourcekey="ddMinutesResource1" ReadOnly="False" LabelWidth="140">
    </MT:MTDropDown>
  </MT:MTPanel>
  <MT:MTPanel ID="StartOfRecurrencePanel" runat="server" meta:resourcekey="StartOfRecurrencePanelResource1"
    Text="Start of recurrence" Width="600">
    <MT:MTDatePicker ID="tbStartDate" runat="server" AllowBlank="False" Label="Start Date"
      TabIndex="230" ControlWidth="100" ControlHeight="18" HideLabel="False" LabelSeparator=":"
      LabelWidth="140" Listeners="{}" meta:resourcekey="tbStartDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;altFormats:DATE_TIME_FORMAT"
      ReadOnly="False" XType="DateField" XTypeNameSpace="form" />
    <MT:MTTextBoxControl ID="tbStartTime" runat="server" AllowBlank="False" Label="Start Time"
      TabIndex="240" ControlWidth="60" ControlHeight="18" HideLabel="False" LabelSeparator=":"
      LabelWidth="140" Listeners="{}" meta:resourcekey="tbStartTimeResource1" ReadOnly="False"
      XType="TextField" XTypeNameSpace="form" />
  </MT:MTPanel>
  <!-- BUTTONS -->
  <div class="x-panel-btns-ct">
    <div style="width: 600px" class="x-panel-btns x-panel-btns-center">
      <center>
        <table cellspacing="0">
          <tr>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="btnSave" runat="server" Text="<%$ Resources:Resource,TEXT_SAVE %>"
                OnClientClick="return validate();" OnClick="btnSave_Click" TabIndex="250" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="btnCancel" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>"
                OnClientClick="goBack();" CausesValidation="False" TabIndex="260" />
            </td>
          </tr>
        </table>
      </center>
    </div>
  </div>
</asp:Content>
