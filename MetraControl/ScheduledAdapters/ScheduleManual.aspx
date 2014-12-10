<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="ScheduleManual.aspx.cs" Inherits="ScheduleManual" Title="MetraNet" meta:resourcekey="PageResource1"
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

    function goBack() {
      window.getFrameMetraNet().MainContentIframe.location.href = 'ScheduledAdaptersList.aspx';
      return false;
    }

    function onCheck() {
    }
  </script>
  <MT:MTPanel ID="RecurrencePatternPanel" runat="server" meta:resourcekey="RecurrencePatternPanelResource1"
    Text="Recurrence Pattern" Width="600">
    <MT:MTLiteralControl ID="DoesNotRecurLiteral" runat="server" Label="Does not recur"
      LabelSeparator="" meta:resourcekey="DoesNotRecurLiteralResource1" />
    <br />
  </MT:MTPanel>
  <div class="x-panel-btns-ct">
    <div style="width: 600px" class="x-panel-btns x-panel-btns-center">
      <center>
        <table cellspacing="0">
          <tr>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="btnSave" runat="server" Text="<%$ Resources:Resource,TEXT_SAVE %>"
                OnClick="btnSave_Click" OnClientClick="return ValidateForm();" TabIndex="150" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="btnCancel" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>"
                OnClientClick="goBack();" CausesValidation="False" TabIndex="160" />
            </td>
          </tr>
        </table>
      </center>
    </div>
  </div>
</asp:Content>
