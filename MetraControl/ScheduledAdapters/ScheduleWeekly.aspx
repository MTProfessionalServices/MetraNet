<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="ScheduleWeekly.aspx.cs" Inherits="ScheduleWeekly" Title="MetraNet" meta:resourcekey="PageResource1"
  Culture="auto" UICulture="auto" %>

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

    function onCheck() {
    }

    function onSaveClick() {
      if ((Ext.getCmp("<%=sbWeekly.ClientID %>").getValue() == '') || (Ext.getCmp("<%=ddWeeks.ClientID %>").getValue() == '') || (Ext.getCmp("<%=tbStartTime.ClientID %>").getValue() == '')) {
        top.Ext.Msg.show({
          title: TEXT_ERROR_MSG,
          msg: TEXT_INVALID_RECUR_PATTERN,
          buttons: Ext.Msg.OK,
          icon: Ext.MessageBox.INFO
        });
      }
      Ext.get("<%=dayOfWeek.ClientID %>").dom.value = Ext.getCmp("<%=sbWeekly.ClientID %>").getValue();
      return ValidateForm();
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
    <MT:MTDropDown ID="ddWeeks" runat="server" AllowBlank="False" Label="Week(s)" TabIndex="100"
      ControlWidth="40" ListWidth="40" HideLabel="False" LabelSeparator=":" Listeners="{}"
      meta:resourcekey="ddWeeksResource1" ReadOnly="False" LabelWidth="140">
    </MT:MTDropDown>
    <MT:MTSuperBoxSelect ID="sbWeekly" runat="server" FieldLabel="on" ControlWidth="200"
      Width="200" LabelSeparator=":" LabelWidth="140" VType="null" meta:resourcekey="sbWeeklyResource1"
      AllowBlank="False" TabIndex="110"></MT:MTSuperBoxSelect>
    <MT:MTTextBoxControl ID="tbStartTime" runat="server" AllowBlank="False" Label="Execution Times"
      TabIndex="120" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
      LabelWidth="140" Listeners="{}" meta:resourcekey="tbStartTimeResource1" ReadOnly="False"
      XType="TextField" XTypeNameSpace="form" />
  </MT:MTPanel>
  <MT:MTPanel ID="StartOfRecurrencePanel" runat="server" meta:resourcekey="StartOfRecurrencePanelResource1"
    Text="Start of recurrence" Width="600">
    <MT:MTDatePicker ID="tbStartDate" runat="server" AllowBlank="False" Label="Start Date"
      TabIndex="130" ControlWidth="100" ControlHeight="18" HideLabel="False" LabelSeparator=":"
      LabelWidth="140" Listeners="{}" meta:resourcekey="tbStartDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;altFormats:DATE_TIME_FORMAT"
      ReadOnly="False" XType="DateField" XTypeNameSpace="form" />
  </MT:MTPanel>
  <input type="hidden" runat="server" id="dayOfWeek" />
  <!-- BUTTONS -->
  <div class="x-panel-btns-ct">
    <div style="width: 600px" class="x-panel-btns x-panel-btns-center">
      <center>
        <table cellspacing="0">
          <tr>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="btnSave" runat="server" Text="<%$ Resources:Resource,TEXT_SAVE %>"
                OnClick="btnSave_Click" OnClientClick="return onSaveClick();" TabIndex="140" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="btnCancel" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>"
                OnClientClick="goBack();" CausesValidation="False" TabIndex="150" />
            </td>
          </tr>
        </table>
      </center>
    </div>
  </div>
</asp:Content>
