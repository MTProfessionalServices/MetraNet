<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="ChangeFailedTransactionStatus.aspx.cs" Inherits="MetraControl_FailedTransactions_ChangeStatus" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <asp:Panel ID="PanelEditStatus" runat="server">
    <MT:MTTitle ID="MTTitle1" Text="Change Case / Failed Transaction Status" runat="server"  meta:resourcekey="lblTitleResource1" />
    <br />
  
    <MT:MTRadioControl ID="radOpen" BoxLabel="<b>Open</b> - This transaction is currently unresolved." Name="r1" Text="N" Value="N" ControlWidth="300" runat="server" meta:resourcekey="radOpenResource1" />
    <MT:MTRadioControl ID="radUnder" BoxLabel="<b>Under Investigation</b> - This transaction is currently unresolved but is being investigated." Name="r1" Text="I" Value="I" ControlWidth="500" runat="server" meta:resourcekey="radUnderResource1" />
    <MT:MTDropDown ID="ddInvestigationReasonCode" LabelWidth="250" Label="Reason Code" AllowBlank="true" runat="server" meta:resourcekey="ddInvestigationReasonCodeResource1" 
    Listeners="{ 'select' : this.onChange_ddInvestigationReasonCode, scope: this }">
    </MT:MTDropDown>
    <MT:MTRadioControl ID="radCorrected" BoxLabel="<b>Corrected</b> - This transaction has been resolved and is ready to be resubmitted." Name="r1" Text="C" Value="C" ControlWidth="500" runat="server"  meta:resourcekey="radCorrectedResource1"/>
    <MT:MTCheckBoxControl ID="cbResubmitNow" LabelWidth="175" BoxLabel="Resubmit Now" runat="server" meta:resourcekey="cbResubmitNowResource1" />
    <MT:MTRadioControl ID="radDismissed" BoxLabel="<b>Dismissed</b> - This transaction cannot be resolved or it is not cost effective to do so." Name="r1" Text="P" Value="P" ControlWidth="500" runat="server" meta:resourcekey="radDismissedResource1" />
    <MT:MTDropDown ID="ddDismissedReasonCode" LabelWidth="250" Label="Reason Code" AllowBlank="true" runat="server" meta:resourcekey="ddDismissedReasonCodeResource1"
    Listeners="{ 'select' : this.onChange_ddDismissedReasonCode, scope: this }">
    </MT:MTDropDown>
    <br />
    <MT:MTTextArea ID="tbComment" Label="Comment" runat="server" ControlHeight="60" ControlWidth="400" Height="60px" Width="400px" meta:resourcekey="tbCommentResource1" />

    <!-- BUTTONS -->
    <div class="x-panel-btns-ct">
      <div style="width:725px" class="x-panel-btns x-panel-btns-center">   
       <center>
        <table cellspacing="0">
          <tr>
            <td  class="x-panel-btn-td">
              <asp:Button ID="btnOK" class="x-btn-text" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClientClick="if (checkRadioButtons()) { return ValidateForm(); } else {return false;}" OnClick="btnOK_Click" TabIndex="390" />
            </td>
          </tr>
        </table> 
        </center>      
      </div>
    </div>
  </asp:Panel>

  <script type="text/javascript">    
    // Check if any of the radio buttons was selected or not. If one of them is checked, return true. Otherwise, alert the user and return false.
    function checkRadioButtons() {
      var radOpenChecked = Ext.get("<%=radOpen.ClientID%>").dom.checked;
      var radUnderChecked = Ext.get("<%=radUnder.ClientID%>").dom.checked;
      var radCorrectedChecked = Ext.get("<%=radCorrected.ClientID%>").dom.checked;
      var radDismissedChecked = Ext.get("<%=radDismissed.ClientID%>").dom.checked;
      if (radOpenChecked || radUnderChecked || radCorrectedChecked || radDismissedChecked) {
        return true;
      }
      Ext.Msg.alert('<%=GetLocalResourceObject("lblTitleResource1.Text").ToString()%>', '<%=GetLocalResourceObject("pleaseSelectNewStatusMessage.Text").ToString()%>');
      return false;
    }

    function onChange_ddInvestigationReasonCode(field, newvalue, oldvalue) {
      var radUnder = Ext.getCmp('<%=radUnder.ClientID%>');
      radUnder.setValue(true);
    }

    function onChange_ddDismissedReasonCode(field, newvalue, oldvalue) {
      var radDismissed = Ext.getCmp('<%=radDismissed.ClientID%>');
      radDismissed.setValue(true);
    } 
    
    // Check rerun isComplete progress via ajax
    function checkProgress(id) {
      Ext.UI.startLoading(document.body, '<asp:Localize meta:resourcekey="ResubmitProgress" runat="server">' + TEXT_RESUBMIT_FAILED + '</asp:Localize>');
      
      // add delay for loading...
      setTimeout(function () { finishCheckProgress(id); }, 4000);
    }

    function finishCheckProgress(id) {
      Ext.Ajax.request({
        url: 'AjaxServices/CheckRerunComplete.aspx',
        params: { id: id },
        scope: this,
        disableCaching: true,
        callback: function (options, success, response) {
          var responseJSON = Ext.decode(response.responseText);
          if (responseJSON) {
            if (responseJSON.Success = true) {
              Ext.UI.doneLoading(document.body);
              refreshAndClose();
            }
          }
          else {
            setTimeout(function () { checkProgress(id);}, 1000);
          }
        }
      });
    }

    // refresh parent grid and close popup window
    function refreshAndClose() {
      //if (parent.grid_ctl00_ContentPlaceHolder1_FailedTransactionList!=null)
      //  parent.grid_ctl00_ContentPlaceHolder1_FailedTransactionList.store.reload();
      if (parent.winGridToRefresh != null)
        parent.winGridToRefresh.store.reload();

      parent.win.hide();

      if (document.documentMode == 7 || document.documentMode == 8) {
        parent.document.location.href = parent.document.location.href;
      }
    }

    //Hacky work around for IE javascript Ext.Fly not an object error
    Ext.override(Ext.EventObjectImpl, {
      getTarget: function (selector, maxDepth, returnEl) {
        var targetElement;

        try {
          targetElement = selector ? Ext.fly(this.target).findParent(selector, maxDepth, returnEl) : this.target;
        } catch (e) {
          targetElement = this.target;
        }

        return targetElement;
      }
    });

  </script>
  <asp:Literal ID="jsCheckProgress" runat="server"></asp:Literal>
</asp:Content>

